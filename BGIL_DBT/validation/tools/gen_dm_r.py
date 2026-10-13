#!/usr/bin/env python3
"""
Generate the DM-R1 / DM-R2 sign-off validation SQL + DOCX (referential integrity) for the
MAXIMUS and OPUS partner Data Vault projects.

    python3 BGIL_DBT/validation/tools/gen_dm_r.py

Outputs (overwritten), one pair per check and project:
    BGIL_DBT/validation/DM-R/DM-R{1,2}_{MAXIMUS,OPUS}.{sql,docx}

DM-R1  No orphan satellite rows: every satellite row's key exists in its parent hub / link.
       Parent = the hub or link (either project -- one shared vault) whose src_pk is the
       satellite's src_pk.
DM-R2  Relationships / links reconcile, per link:
       (a) missing links   -- every RAW relationship (all FKs present) exists as a link row
       (b) orphan links    -- every link FK exists in its hub
       (c) unexpected links -- informational: link rows of the project with no RAW relationship
       Link feeds are parsed from the models (link -> stg2 / hubfeed -> stg_ -> RAW) like DM-K.
"""
import re
import sys
from collections import OrderedDict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import gen_dm_k as K  # noqa: E402
import gen_dm_a as A  # noqa: E402

lit = A.lit
GHOST = K.GHOST_HKEY
HUB_PK = {}  # hub table -> its src_pk (filled by parents())


# ---------------------------------------------------------------------------------------
# Hubs / links of both projects (the vault is shared)
# ---------------------------------------------------------------------------------------
class Link:
    def __init__(self, project, md, path):
        self.project, self.md, self.path = project, md, path
        self.name = path.stem.upper()
        meta = K.yaml_block(K.read(path))
        srcs = meta["source_model"]
        self.sources = [srcs] if isinstance(srcs, str) else list(srcs)
        self.pk = meta["src_pk"]
        fk = meta["src_fk"]
        self.fks = [fk] if isinstance(fk, str) else list(fk)
        self.ldts = meta.get("src_ldts", "LOAD_DATETIME")
        self.feeds, self.skipped = [], []  # feeds: (label, Arm)
        self.fk_hub = OrderedDict()

    @property
    def fq(self):
        return f"{K.VAULT}.{self.name}"

    @property
    def prefix(self):
        return f"{self.project}_"


def parents():
    """src_pk -> [table names] over hubs + links of both projects."""
    out = OrderedDict()
    for _, md in A.PROJECTS:
        for kind in ("hubs", "links"):
            for path in sorted((md / "raw_vault" / "standard" / kind).glob("*.sql")):
                pk = K.yaml_block(K.read(path))["src_pk"]
                if kind == "hubs":
                    HUB_PK[path.stem.upper()] = pk.upper()
                out.setdefault(pk.upper(), [])
                if path.stem.upper() not in out[pk.upper()]:
                    out[pk.upper()].append(path.stem.upper())
    return out


def link_feed_arms(md, feed):
    """A link source model -> [(label, Arm)]. Handles stg2 directly and Maximus hubfeed unions."""
    sql = K.read(K.find_model(md, feed))
    try:
        K.yaml_block(sql)
        return [(f"{feed} <- {a.label}", a) for a in A.resolve(md, feed)]
    except ValueError:
        pass
    out = []
    body = A.strip_sql_comments(sql)
    for part in re.split(r"\bunion\s+all\b", body, flags=re.I):
        if "ref(" not in part:
            continue
        ref, rename = A.parse_wrapper(part)
        for a in A.resolve(md, ref):
            out.append((f"{feed} <- {ref}", a.wrap(rename)))
    return out


def build_links():
    links = []
    for project, md in A.PROJECTS:
        for path in sorted((md / "raw_vault" / "standard" / "links").glob("*.sql")):
            ln = Link(project, md, path)
            for src in ln.sources:
                if K.is_disabled(K.read(K.find_model(md, src))):
                    ln.skipped.append(f"{src}: disabled placeholder (enabled=false)")
                    continue
                for label, arm in link_feed_arms(md, src):
                    exprs = [arm.lookup.get(c) for c in [ln.pk] + ln.fks + [ln.ldts]]
                    if any(e is None for e in exprs):
                        ln.skipped.append(f"{label}: key column(s) not traceable to RAW")
                        continue
                    ln.feeds.append((label, arm))
                    for fk in ln.fks:
                        if fk not in ln.fk_hub:
                            m = re.search(r"'(HUB_[A-Z_]+)\|'", arm.lookup.get(fk) or "")
                            ln.fk_hub[fk] = m.group(1) if m else "HUB_" + re.sub(r"(^RELATED_)|(_HKEY$)", "", fk)
            links.append(ln)
    return links


# ---------------------------------------------------------------------------------------
# DM-R1: orphan satellite rows
# ---------------------------------------------------------------------------------------
def scope(sat):
    return f"RECORD_SOURCE = '{sat.project}'" if sat.object_cols else f"startswith(RECORD_SOURCE, '{sat.project}_')"


def r1_section(sat, pmap):
    tables = pmap.get(sat.pk.upper(), [])
    if not tables:
        return dict(project=sat.project, hub=sat.name, status="Design finding",
                    pass_criteria="FAIL until a hub / link with this key is modelled (or documented exception)",
                    note=(f"No hub or link in either project has src_pk {sat.pk}, so every row of this satellite is an "
                          f"orphan by definition. " + A.sat_note(sat)),
                    queries=[("SQL query", f"-- DM-R1 {sat.project} {sat.name}: no parent table defines {sat.pk}")])
    parent = tables[0]
    pkeys = "\n        union\n        ".join(f"select distinct {sat.pk} as k from {K.VAULT}.{t}" for t in tables)
    orphan = f"s.{sat.pk} is not null and p.k is null"
    sql = f"""with p as (  -- every key of the parent table(s), any project
        {pkeys}
)
select '{sat.project}' as project, '{sat.name}' as satellite, '{' / '.join(tables)}' as parent_table,
       s.RECORD_SOURCE,
       count(*) as sat_rows,
       count_if(s.{sat.pk} is null) as null_key_rows,
       count_if({orphan}) as orphan_rows,
       count(distinct iff({orphan}, s.{sat.pk}, null)) as orphan_keys,
       array_slice(array_agg(distinct iff({orphan}, to_varchar(s.{sat.pk}, 'HEX'), null)), 0, 3) as orphan_examples,
       iff(null_key_rows = 0 and orphan_rows = 0, 'PASS', 'FAIL') as status
  from {sat.fq} s
  left join p on p.k = s.{sat.pk}
 where {scope(sat).replace('RECORD_SOURCE', 's.RECORD_SOURCE')}
   and (s.{sat.pk} is null or s.{sat.pk} <> {GHOST})
 group by s.RECORD_SOURCE
 order by iff(status = 'FAIL', 0, 1), s.RECORD_SOURCE;"""
    kind = "link" if parent.startswith("LNK_") else "hub"
    return dict(project=sat.project, hub=sat.name, status="Implemented",
                pass_criteria="status = PASS on every row (0 orphan rows, 0 null keys)",
                note=(f"Parent {kind} {' / '.join(tables)} (src_pk {sat.pk}); checked across all rows of the parent "
                      f"(shared vault: the key may have been loaded by the other project). Satellite rows scoped to "
                      f"{sat.project}; one output row per RECORD_SOURCE. " + A.sat_note(sat)),
                queries=[("SQL query", sql)])


def r1_summary(project, sats, pmap):
    parts = []
    for s in sats:
        tables = pmap.get(s.pk.upper(), [])
        if not tables:
            continue
        pk_union = " union ".join(f"select distinct {s.pk} as k from {K.VAULT}.{t}" for t in tables)
        parts.append(f"select '{s.name}' as satellite, '{' / '.join(tables)}' as parent_table, count(*) as sat_rows,\n"
                     f"       count_if(s.{s.pk} is null or p.k is null) as orphan_or_null_rows\n"
                     f"  from {s.fq} s\n  left join ({pk_union}) p on p.k = s.{s.pk}\n"
                     f" where {scope(s).replace('RECORD_SOURCE', 's.RECORD_SOURCE')} and (s.{s.pk} is null or s.{s.pk} <> {GHOST})")
    sql = ("select '" + project + "' as project, satellite, parent_table, sat_rows, orphan_or_null_rows,\n"
           "       iff(orphan_or_null_rows = 0, 'PASS', 'FAIL') as status\n  from (\n" +
           A.ind("\nunion all\n".join(parts), 4) + "\n  )\n order by iff(status = 'FAIL', 0, 1), satellite;")
    return dict(project=project, hub=f"Summary: all {project} satellites in one query", status="Implemented",
                pass_criteria="status = PASS on every row",
                note=("One row per satellite (no RECORD_SOURCE split) -- quick evidence for the whole project. The "
                      "per-satellite sections below give the RECORD_SOURCE breakdown and orphan examples."),
                queries=[("SQL query", sql)])


# ---------------------------------------------------------------------------------------
# DM-R2: links reconcile
# ---------------------------------------------------------------------------------------
def link_src_union(ln, with_label=True):
    parts = []
    for label, arm in ln.feeds:
        lk = arm.lookup
        cols = []
        if with_label:
            cols.append(f"{lit(label)} as src_feed")
        cols.append(f"{lk.get(ln.pk)} as link_hkey")
        cols += [f"{lk.get(fk)} as {fk}" for fk in ln.fks]
        where = [f"{lk.get(fk)} is not null" for fk in ln.fks]
        if arm.where:
            where.append(f"({arm.where})")
        parts.append(f"-- via {label}\nselect " + ",\n       ".join(cols) + f"\n  from {arm.raw}\n where " +
                     "\n   and ".join(where))
    return "\nunion all\n".join(parts)


def r2_sections(ln):
    if not ln.feeds:
        reason = "; ".join(ln.skipped) or "no RAW feed"
        return [dict(project=ln.project, hub=ln.name, status="NA", pass_criteria="NA",
                     note=f"Not applicable: {reason}.", queries=[("SQL query", f"-- DM-R2 {ln.project} {ln.name}: NA -- {reason}")])]
    fk_list = ", ".join(f"{fk} -> {h}" for fk, h in ln.fk_hub.items())
    feeds = ", ".join(lbl for lbl, _ in ln.feeds)
    note_common = (f"{len(ln.feeds)} RAW feed(s): {feeds}. FKs: {fk_list}. A RAW relationship counts only when every FK "
                   f"key is present (automate_dv.link does not load a row with a NULL FK). Link hash keys are recomputed "
                   f"from RAW with the stg2 NK expressions (automate_dv 0.11.5 MD5_BINARY formula).")
    if ln.skipped:
        note_common += " Excluded: " + "; ".join(ln.skipped) + "."
    missing = f"""with src as (
{A.ind(link_src_union(ln), 4)}
)
select '{ln.project}' as project, '{ln.name}' as link,
       coalesce(src.src_feed, '== TOTAL (distinct across feeds) ==') as src_feed,
       count(distinct src.link_hkey) as source_relationships,
       count(distinct iff(l.k is not null, src.link_hkey, null)) as present_in_link,
       source_relationships - present_in_link as missing_links,
       iff(missing_links = 0, 'PASS', 'FAIL') as status
  from src
  left join (select distinct {ln.pk} as k from {ln.fq}) l on l.k = src.link_hkey
 group by grouping sets ((src.src_feed), ())
 order by grouping(src.src_feed) desc, src.src_feed;"""
    missing_detail = f"""with src as (
{A.ind(link_src_union(ln), 4)}
)
select '{ln.project}' as project, '{ln.name}' as link, src_feed, to_varchar(link_hkey, 'HEX') as missing_link_hkey,
       {', '.join(f"to_varchar({fk}, 'HEX') as {fk}" for fk in ln.fks)}
  from src
 where not exists (select 1 from {ln.fq} l where l.{ln.pk} = src.link_hkey)
 order by src_feed
 limit 100;"""
    orphan_parts = []
    for fk, hub in ln.fk_hub.items():
        hpk = HUB_PK.get(hub, hub[4:] + "_HKEY")
        o = f"l.{fk} is not null and h.k is null"
        orphan_parts.append(f"""select '{ln.project}' as project, '{ln.name}' as link, '{fk}' as fk_column, '{hub}' as hub,
       count(*) as link_rows,
       count_if(l.{fk} is null) as null_fk_rows,
       count_if({o}) as orphan_fk_rows,
       array_slice(array_agg(distinct iff({o}, to_varchar(l.{fk}, 'HEX'), null)), 0, 3) as orphan_examples,
       iff(null_fk_rows = 0 and orphan_fk_rows = 0, 'PASS', 'FAIL') as status
  from {ln.fq} l
  left join (select distinct {hpk} as k from {K.VAULT}.{hub}) h on h.k = l.{fk}
 where startswith(l.RECORD_SOURCE, '{ln.prefix}')""")
    orphan = "\nunion all\n".join(orphan_parts) + "\norder by fk_column;"
    unexpected = f"""with src as (
{A.ind(link_src_union(ln, with_label=False), 4)}
)
select '{ln.project}' as project, '{ln.name}' as link, l.RECORD_SOURCE,
       count(*) as link_rows,
       count_if(k.link_hkey is null) as unexpected_links,
       array_slice(array_agg(iff(k.link_hkey is null, to_varchar(l.{ln.pk}, 'HEX'), null)), 0, 3) as examples
  from {ln.fq} l
  left join (select distinct link_hkey from src) k on k.link_hkey = l.{ln.pk}
 where startswith(l.RECORD_SOURCE, '{ln.prefix}')
 group by l.RECORD_SOURCE
 order by l.RECORD_SOURCE;"""
    return [
        dict(project=ln.project, hub=f"{ln.name} -- (a) missing links (RAW -> link)", status="Implemented",
             pass_criteria="missing_links = 0 on the TOTAL row", note=note_common,
             queries=[("SQL query (a) -- counts per feed", missing),
                      ("SQL query (a) drill-down -- first 100 missing relationships", missing_detail)]),
        dict(project=ln.project, hub=f"{ln.name} -- (b) orphan links (link FK -> hub)", status="Implemented",
             pass_criteria="status = PASS for every FK (0 null FK, 0 orphan FK)",
             note=(f"Link rows scoped to RECORD_SOURCE '{ln.prefix}%'; every FK must exist in its hub (any project's rows "
                   f"-- shared vault). FKs: {fk_list}."),
             queries=[("SQL query (b)", orphan)]),
        dict(project=ln.project, hub=f"{ln.name} -- (c) unexpected links (link -> RAW)", status="Informational",
             pass_criteria="0 unexpected links, or each explained (e.g. a removed feed / legacy load)",
             note="Not part of the pass criterion: link rows of this project whose relationship is no longer in RAW.",
             queries=[("SQL query (c)", unexpected)]),
    ]


# ---------------------------------------------------------------------------------------
COMMON = [("Owner", "LUMIQ"), ("Vault location", K.VAULT)] + K.COMMON_OVERVIEW[2:] + [
    ("Shared vault", "Parents (hubs / links) are checked across ALL their rows: a key may have been loaded by the "
                     "other project. Child rows (satellites / links) are scoped to this project's RECORD_SOURCE."),
    ("Ghost record", f"Satellite rows keyed by the ghost hash {GHOST} are excluded from the orphan test."),
]
CHECKS = OrderedDict([
    ("DM-R1", dict(
        title="DM-R1  |  Referential Integrity — No Orphan Satellite Rows",
        subtitle="Every satellite row references a valid hub (or link) key. Pass criterion: 0 orphan satellite rows.",
        overview=[("Check ID", "DM-R1"), ("Category", "Referential integrity"), ("Sign-off criterion", "No orphan satellite rows"),
                  ("Method", "Anti-join: satellite key -> parent hub / link (the table whose src_pk is the satellite's src_pk)"),
                  ("Evidence required", "Orphan-row query result"),
                  ("Pass criteria / tolerance", "0 orphan satellite rows")] + COMMON)),
    ("DM-R2", dict(
        title="DM-R2  |  Referential Integrity — Relationships / Links Reconcile",
        subtitle="Every valid source relationship exists as a link row; no orphan links. Pass criterion: 0 missing / orphan links.",
        overview=[("Check ID", "DM-R2"), ("Category", "Referential integrity"), ("Sign-off criterion", "Relationships / links reconcile"),
                  ("Method", "(a) RAW relationships -> link (hash keys recomputed from RAW); (b) link FK -> hub; (c) informational: link -> RAW"),
                  ("Evidence required", "Link reconciliation report"),
                  ("Pass criteria / tolerance", "0 missing / orphan links")] + COMMON)),
])


def main():
    template = K.TEMPLATE_DOCX.read_bytes()
    pmap = parents()
    sats = A.build_sats()
    sats.sort(key=lambda s: (s.project != "MAXIMUS", s.layer != "standard", s.name))
    links = build_links()
    for pj, md in A.PROJECTS:
        ps = [s for s in sats if s.project == pj]
        pl = [l for l in links if l.project == pj]
        no_parent = [s.name for s in ps if s.pk.upper() not in pmap]
        revision = [
            f"Generated 2026-10-13 from the current {md.parent.name} models by validation/tools/gen_dm_r.py "
            f"(satellite lineage from gen_dm_a.py, hash formula from gen_dm_k.py).",
            f"This file: {pj} only -- {len(ps)} satellites (standard + augmented) and {len(pl)} links "
            f"({', '.join(l.name for l in pl)}). The other project is in the sibling file.",
            ("Satellites with no parent hub / link: " + ", ".join(no_parent) + ".") if no_parent else
            "Every satellite key has a parent hub / link model.",
        ]
        for cid, meta in CHECKS.items():
            if cid == "DM-R1":
                sections = [r1_summary(pj, ps, pmap)] + [r1_section(s, pmap) for s in ps]
            else:
                sections = [x for l in pl for x in r2_sections(l)]
            pmeta = dict(meta, title=f"{meta['title']}  ({pj})", overview=meta["overview"] + [("Project in this file", pj)])
            fid = f"{cid}_{pj}"
            K.write_sql(fid, pmeta, sections, revision)
            A.write_docx(fid, pmeta, sections, revision, template)
            print(f"{fid}: {len(sections)} sections, "
                  f"{sum(x['status'] == 'NA' for x in sections)} NA, {sum(x['status'] == 'Design finding' for x in sections)} findings")
    for l in links:
        print(f"  {l.project:8} {l.name:26} feeds={len(l.feeds):3} fks={dict(l.fk_hub)} skipped={len(l.skipped)}")


if __name__ == "__main__":
    main()
