#!/usr/bin/env python3
"""
Generate the DM-T1 / DM-T2 sign-off validation SQL + DOCX (load audit / technical) for the
MAXIMUS and OPUS partner Data Vault projects.

    python3 BGIL_DBT/validation/tools/gen_dm_t.py

Outputs (overwritten), one pair per check and project:
    BGIL_DBT/validation/DM-T/DM-T{1,2}_{MAXIMUS,OPUS}.{sql,docx}

DM-T1  Load metadata populated and correct on every row of every hub, link and satellite:
       LOAD_DATETIME / RECORD_SOURCE (and DBT_RUN_TS where the table carries it) not null,
       LOAD_DATETIME not a sentinel / not in the future / not after DBT_RUN_TS, and
       RECORD_SOURCE one of the values the models can write (parsed from the feeds).
DM-T2  Hash key integrity (DV2.0): column types BINARY(16); no null / wrong-length hash keys;
       hub hash key = MD5 recomputed from the stored business key; no collisions
       (one hub key -> two business keys, one link key -> two FK combinations).
"""
import re
import sys
from collections import OrderedDict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import gen_dm_k as K  # noqa: E402
import gen_dm_a as A  # noqa: E402
import gen_dm_r as R  # noqa: E402

lit = A.lit
VAULT_DB, VAULT_SCHEMA = K.VAULT.split(".")
SENTINEL = "'1990-01-01'"  # anything earlier is treated as a placeholder load date


# ---------------------------------------------------------------------------------------
# Tables + the RECORD_SOURCE values the models can write
# ---------------------------------------------------------------------------------------
class Table:
    def __init__(self, project, kind, name, pk, ldts="LOAD_DATETIME", run_ts=False, fks=(), bk=None, prefix=None):
        self.project, self.kind, self.name, self.pk, self.ldts = project, kind, name, pk, ldts
        self.run_ts, self.fks, self.bk, self.hash_prefix = run_ts, list(fks), bk, prefix
        self.rs_values, self.rs_patterns, self.notes = [], [], []
        self.object_group = None

    @property
    def fq(self):
        return f"{K.VAULT}.{self.name}"

    def scope(self, alias=""):
        a = f"{alias}." if alias else ""
        if self.object_group:
            return f"{a}RECORD_SOURCE = '{self.object_group}'"
        return f"startswith({a}RECORD_SOURCE, '{self.project}_')"

    def add_arm(self, arm):
        if arm.kind == "stitch":
            tags = sorted({s["source_tag"] for s in arm.stitch["sources"]})
            alt = "|".join(re.escape(t) for t in tags)
            pat = f"^({alt})(, ({alt}))*$"
            if pat not in self.rs_patterns:
                self.rs_patterns.append(pat)
            return
        rs = arm.lookup.get("record_source")
        if rs and re.fullmatch(r"'[^']*'", rs):
            if rs.strip("'") not in self.rs_values:
                self.rs_values.append(rs.strip("'"))
        else:
            self.notes.append(f"{arm.label}: RECORD_SOURCE not a constant ({rs}) -- not in the expected set")

    def rs_ok(self, alias=""):
        a = f"{alias}." if alias else ""
        parts = []
        if self.rs_values:
            parts.append(f"{a}RECORD_SOURCE in ({', '.join(lit(v) for v in self.rs_values)})")
        parts += [f"regexp_like({a}RECORD_SOURCE, {lit(p)})" for p in self.rs_patterns]
        return "(" + " or ".join(parts) + ")" if parts else None


def build_tables(project, md, sats, links):
    tables = []
    hubs = {h.name: h for h in (K.build_maxi() if project == "MAXIMUS" else K.build_opus())}
    for path in sorted((md / "raw_vault" / "standard" / "hubs").glob("*.sql")):
        name = path.stem.upper()
        srcs, pk, nk = K.hub_meta(path)
        h = hubs[name]
        pre = {re.match(r"\s*'([^']*)'", b.nk).group(1) for b in h.branches}
        t = Table(project, "hub", name, pk, bk=nk, prefix=pre.pop() if len(pre) == 1 else None)
        for s in srcs:
            if K.is_disabled(K.read(K.find_model(md, s))):
                continue
            for _, arm in R.link_feed_arms(md, s):
                t.add_arm(arm)
        tables.append(t)
    for ln in links:
        t = Table(project, "link", ln.name, ln.pk, ln.ldts, fks=ln.fks)
        for _, arm in ln.feeds:
            t.add_arm(arm)
        tables.append(t)
    for s in sats:
        sql = K.read(s.path)
        meta = K.yaml_block(sql)
        extra = meta.get("src_extra_columns") or []
        extra = [extra] if isinstance(extra, str) else extra
        run_ts = "multi_source" in s.macro or "DBT_RUN_TS" in [e.upper() for e in extra]
        t = Table(project, "satellite", s.name, s.pk, s.ldts, run_ts=run_ts)
        if s.object_cols:
            t.object_group = project
            t.rs_values = [project]
        else:
            for g in s.groups.values():
                for arm in g.arms:
                    t.add_arm(arm)
        t.notes += [f"Excluded feed: {x}" for x in s.skipped]
        tables.append(t)
    return tables


# ---------------------------------------------------------------------------------------
# DM-T1
# ---------------------------------------------------------------------------------------
def t1_select(t):
    ok = t.rs_ok()
    run = (f"count_if(DBT_RUN_TS is null)" if t.run_ts else "null")
    after = (f"count_if({t.ldts} > DBT_RUN_TS)" if t.run_ts else "null")
    return f"""select '{t.project}' as project, '{t.kind}' as table_type, '{t.name}' as table_name,
       count(*) as rows_in_scope,
       count_if({t.ldts} is null) as null_load_datetime,
       count_if(nullif(trim(RECORD_SOURCE), '') is null) as null_record_source,
       {run} as null_dbt_run_ts,
       count_if({t.ldts} < {SENTINEL}) as placeholder_load_datetime,
       count_if({t.ldts} > dateadd(day, 1, current_timestamp()::timestamp_ntz)) as future_load_datetime,
       {after} as load_after_run_ts,
       {f"count_if(not {ok})" if ok else "null"} as unexpected_record_source,
       {f"array_slice(array_agg(distinct iff(not {ok}, RECORD_SOURCE, null)), 0, 5)" if ok else "null"} as unexpected_examples,
       iff(null_load_datetime = 0 and null_record_source = 0 and coalesce(null_dbt_run_ts, 0) = 0
           and placeholder_load_datetime = 0 and future_load_datetime = 0 and coalesce(load_after_run_ts, 0) = 0
           and coalesce(unexpected_record_source, 0) = 0, 'PASS', 'FAIL') as status
  from {t.fq}
 where {t.scope()}"""


def t1_section(t):
    exp = ", ".join(t.rs_values[:6]) + (f" (+{len(t.rs_values) - 6} more)" if len(t.rs_values) > 6 else "")
    if t.rs_patterns:
        exp += ("; " if exp else "") + f"{len(t.rs_patterns)} stitch pattern(s) (comma-joined contributing tables)"
    note = (f"{t.kind} {t.name}; rows scoped to {t.scope()}. Expected RECORD_SOURCE: {exp or 'none parsed'}. "
            f"{'DBT_RUN_TS present (load_after_run_ts checked). ' if t.run_ts else 'No DBT_RUN_TS column on this table. '}"
            + " ".join(t.notes))
    return dict(project=t.project, hub=f"{t.kind.upper()}  {t.name}", status="Implemented",
                pass_criteria="status = PASS (every metadata count = 0)", note=note.strip(),
                queries=[("SQL query", t1_select(t) + ";")])


def t1_summary(project, tables):
    sql = ("select * from (\n" + A.ind("\nunion all\n".join(t1_select(t) for t in tables), 4) +
           "\n)\norder by iff(status = 'FAIL', 0, 1), table_type, table_name;")
    return dict(project=project, hub=f"Summary: every {project} hub, link and satellite in one query", status="Implemented",
                pass_criteria="0 rows with status = FAIL",
                note=("The same per-table query as the sections below, unioned -- run this for the evidence and use "
                      "the sections to drill into a FAIL."), queries=[("SQL query", sql)])


# ---------------------------------------------------------------------------------------
# DM-T2
# ---------------------------------------------------------------------------------------
def t2_types(project, tables):
    names = ", ".join(lit(t.name) for t in tables)
    sql = f"""select '{project}' as project, table_name, column_name, data_type, character_maximum_length as byte_length,
       iff(data_type = 'BINARY' and character_maximum_length = 16, 'PASS', 'FAIL') as status
  from {VAULT_DB}.INFORMATION_SCHEMA.COLUMNS
 where table_schema = '{VAULT_SCHEMA}'
   and table_name in ({names})
   and (column_name like '%\\\\_HKEY' escape '\\\\' or column_name like 'HASHDIFF%')
 order by iff(status = 'FAIL', 0, 1), table_name, column_name;"""
    return dict(project=project, hub="Hash column types (all tables)", status="Implemented",
                pass_criteria="every row status = PASS (BINARY(16))",
                note="Every *_HKEY and HASHDIFF column of the project's hubs, links and satellites must be BINARY(16) (MD5_BINARY).",
                queries=[("SQL query", sql)])


def t2_hub(t):
    recompute = (f"MD5_BINARY(NULLIF(UPPER(TRIM(CAST('{t.hash_prefix}' || {t.bk} AS VARCHAR))), ''))"
                 if t.hash_prefix else None)
    mismatch = f"count_if({t.pk} is not null and {t.bk} is not null and {t.pk} <> {recompute})" if recompute else "null"
    sql = f"""with c as (
    select {t.pk} as hkey, count(distinct {t.bk}) as bks
      from {t.fq} where {t.scope()} group by {t.pk} having count(distinct {t.bk}) > 1
)
select '{t.project}' as project, 'hub' as table_type, '{t.name}' as table_name,
       count(*) as rows_in_scope,
       count_if({t.pk} is null) as null_hkey,
       count_if({t.pk} is not null and length({t.pk}) <> 16) as wrong_length_hkey,
       {mismatch} as hkey_not_recomputable,
       (select count(*) from c) as collisions,
       iff(null_hkey = 0 and wrong_length_hkey = 0 and coalesce(hkey_not_recomputable, 0) = 0 and collisions = 0, 'PASS', 'FAIL') as status
  from {t.fq}
 where {t.scope()}"""
    note = (f"Recompute: {recompute or 'n/a (feeds use more than one NK prefix)'} must equal {t.pk}. "
            f"collisions = hash keys carrying more than one {t.bk}. Overlaps DM-K3 (nulls) and DM-K4 (uniqueness) "
            f"but adds the recompute and length checks.")
    return sql, note


def t2_link(t):
    combo = " || '|' || ".join(f"coalesce(to_varchar({f}, 'HEX'), '^^')" for f in t.fks)
    nulls = " + ".join(f"count_if({f} is null)" for f in t.fks)
    lens = " or ".join(f"length({f}) <> 16" for f in [t.pk] + t.fks)
    sql = f"""with c as (
    select {t.pk} as hkey from {t.fq} where {t.scope()}
     group by {t.pk} having count(distinct {combo}) > 1
)
select '{t.project}' as project, 'link' as table_type, '{t.name}' as table_name,
       count(*) as rows_in_scope,
       count_if({t.pk} is null) as null_hkey,
       {nulls} as null_fk_hkeys,
       count_if({lens}) as wrong_length_hkey,
       (select count(*) from c) as collisions,
       iff(null_hkey = 0 and null_fk_hkeys = 0 and wrong_length_hkey = 0 and collisions = 0, 'PASS', 'FAIL') as status
  from {t.fq}
 where {t.scope()}"""
    return sql, (f"FK hash keys {', '.join(t.fks)}. collisions = one link hash key with more than one FK combination "
                 f"(the link key no longer identifies one relationship).")


def t2_sat(t):
    sql = f"""select '{t.project}' as project, 'satellite' as table_type, '{t.name}' as table_name,
       count(*) as rows_in_scope,
       count_if({t.pk} is null) as null_hkey,
       count_if({t.pk} is not null and length({t.pk}) <> 16) as wrong_length_hkey,
       count_if(HASHDIFF is null) as null_hashdiff,
       iff(null_hkey = 0 and wrong_length_hkey = 0 and null_hashdiff = 0, 'PASS', 'FAIL') as status
  from {t.fq}
 where {t.scope()}"""
    return sql, "Satellite hash key and HASHDIFF populated and 16 bytes. HASHDIFF correctness itself is DM-H1 (a)."


def t2_section(t):
    sql, note = {"hub": t2_hub, "link": t2_link, "satellite": t2_sat}[t.kind](t)
    return dict(project=t.project, hub=f"{t.kind.upper()}  {t.name}", status="Implemented",
                pass_criteria="status = PASS", note=note, queries=[("SQL query", sql + ";")])


# ---------------------------------------------------------------------------------------
COMMON = [("Owner", "LUMIQ"), ("Vault location", K.VAULT)] + K.COMMON_OVERVIEW[2:] + [
    ("Scope", "Every hub, link and satellite the project's models load (standard + augmented). Rows scoped by the "
              "project's RECORD_SOURCE prefix (OBJECT satellites: RECORD_SOURCE = project). Shared physical tables "
              "appear in both project files, each checking its own rows; rows owned by neither are listed by the "
              "DM-K2 ownership sweep."),
]
CHECKS = OrderedDict([
    ("DM-T1", dict(
        title="DM-T1  |  Load Audit — Load Metadata Populated",
        subtitle="Load date/timestamp and record source populated and correct on every row. Pass criterion: 0 rows with missing metadata.",
        overview=[("Check ID", "DM-T1"), ("Category", "Load audit"), ("Sign-off criterion", "Load metadata populated"),
                  ("Method", "Per table: null / placeholder / future LOAD_DATETIME, LOAD_DATETIME after DBT_RUN_TS, null "
                             "RECORD_SOURCE, RECORD_SOURCE outside the values the models write"),
                  ("Evidence required", "Metadata completeness query"),
                  ("Pass criteria / tolerance", "0 rows with missing metadata")] + COMMON + [
                  ("Placeholder date", f"LOAD_DATETIME earlier than {SENTINEL} (catches the macros' 1900-01-01 sentinel)."),
                  ("Expected RECORD_SOURCE", "Parsed from every feed: stg2 '!<constant>' values, stitch views' "
                                             "comma-joined source_tag lists, OBJECT satellites' project group.")])),
    ("DM-T2", dict(
        title="DM-T2  |  Load Audit — Hash Key Integrity (DV2.0)",
        subtitle="Hash keys generated consistently; no null hash keys; no unexpected collisions. Pass criterion: 0 null; 0 unexpected collisions.",
        overview=[("Check ID", "DM-T2"), ("Category", "Load audit"), ("Sign-off criterion", "Hash key integrity (DV2.0)"),
                  ("Method", "(a) hash column types; (b) per table: null / wrong-length hash keys, hub key recomputed "
                             "from the stored business key, hub and link collisions"),
                  ("Evidence required", "Hash null / collision query"),
                  ("Pass criteria / tolerance", "0 null; 0 unexpected collisions")] + COMMON + [
                  ("Hash key formula", K.HASH_TXT)])),
])


def main():
    template = K.TEMPLATE_DOCX.read_bytes()
    R.parents()
    sats = A.build_sats()
    sats.sort(key=lambda s: (s.project != "MAXIMUS", s.layer != "standard", s.name))
    links = R.build_links()
    order = {"hub": 0, "link": 1, "satellite": 2}
    for pj, md in A.PROJECTS:
        tables = build_tables(pj, md, [s for s in sats if s.project == pj], [l for l in links if l.project == pj])
        tables.sort(key=lambda t: (order[t.kind], t.name))
        n = {k: sum(t.kind == k for t in tables) for k in order}
        revision = [
            f"Generated 2026-10-13 from the current {md.parent.name} models by validation/tools/gen_dm_t.py.",
            f"This file: {pj} only -- {n['hub']} hubs, {n['link']} links, {n['satellite']} satellites. The other "
            f"project is in the sibling file.",
        ]
        for cid, meta in CHECKS.items():
            if cid == "DM-T1":
                sections = [t1_summary(pj, tables)] + [t1_section(t) for t in tables]
            else:
                sections = [t2_types(pj, tables)] + [t2_section(t) for t in tables]
            pmeta = dict(meta, title=f"{meta['title']}  ({pj})", overview=meta["overview"] + [("Project in this file", pj)])
            fid = f"{cid}_{pj}"
            K.write_sql(fid, pmeta, sections, revision)
            A.write_docx(fid, pmeta, sections, revision, template)
            print(f"{fid}: {len(sections)} sections")
        for t in tables:
            if not (t.rs_values or t.rs_patterns):
                print(f"  WARNING {pj} {t.name}: no expected RECORD_SOURCE parsed")


if __name__ == "__main__":
    main()
