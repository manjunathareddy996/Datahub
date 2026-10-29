#!/usr/bin/env python3
"""
Travel LOB equivalent of gen_dm_t.py.

Points at opus_travel_dv_dbt + maximus_travel_dv_dbt and writes under
BGIL_DBT/validation/travel/DM-T/. Each hub / link / satellite row is
scoped by the RECORD_SOURCE value set parsed from the project's own feeds
(the shared vault also holds partner rows under the same prefix).

    python3 BGIL_DBT/validation/tools/gen_dm_t_travel.py
"""
import re
import sys
from collections import OrderedDict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import gen_dm_k_travel as K  # noqa: E402
import gen_dm_a_travel as AT  # noqa: E402
import gen_dm_r_travel as RT  # noqa: E402
import gen_dm_a as A  # noqa: E402
import gen_dm_r as R  # noqa: E402
import gen_dm_t as T  # noqa: E402
import gen_dm_k as PK  # noqa: E402

VALIDATION = K.VALIDATION
PROJECTS = AT.PROJECTS
T.VAULT_DB, T.VAULT_SCHEMA = K.VAULT.split(".")


# ---------------------------------------------------------------------------
# Point R.link_feed_arms + A.resolve at the travel ones (RT already did,
# but importing gen_dm_t re-imports gen_dm_r which... keeps that patch
# intact at module level). We overwrite R.build_links too so gen_dm_t's
# default parent-FK mapping follows the lnkfeed shape.
# ---------------------------------------------------------------------------
R.link_feed_arms = RT.link_feed_arms_travel
R.build_links = RT.build_links_travel


# Override T.build_tables to use the travel hub / sat builders (gen_dm_t's
# default calls K.build_maxi() / K.build_opus() which are partner).
def build_tables_travel(project, md, sats, links):
    tables = []
    if project == "MAXIMUS":
        hubs = {h.name: h for h in K.build_maxi_travel()}
    else:
        hubs = {h.name: h for h in K.build_opus_travel()}
    hub_dir = md / "raw_vault" / "standard" / "hubs"
    for path in sorted(hub_dir.glob("hub_*.sql")):
        name = path.stem.upper()
        srcs, pk, nk = PK.hub_meta(path)
        h = hubs.get(name)
        pre = ({re.match(r"\s*'([^']*)'", b.nk).group(1) for b in h.branches}
               if h and h.branches else set())
        t = T.Table(project, "hub", name, pk, bk=nk,
                    prefix=pre.pop() if len(pre) == 1 else None)
        for s in srcs:
            try:
                if PK.is_disabled(PK.read(PK.find_model(md, s))):
                    continue
            except SystemExit:
                continue
            try:
                for _, arm in RT.link_feed_arms_travel(md, s):
                    t.add_arm(arm)
            except Exception as e:
                t.notes.append(f"{s}: {e}")
        # Also carry the travel hub's RECORD_SOURCE value set as the
        # scope for row filtering (replaces the prefix-only default).
        if h is not None and h.record_sources:
            t.rs_values = list(h.record_sources)
            t.hash_prefix = h.record_sources[0].split("_", 1)[0] + "_"  # cosmetic
        tables.append(t)
    for ln in links:
        t = T.Table(project, "link", ln.name, ln.pk, ln.ldts, fks=ln.fks)
        for _, arm in ln.feeds:
            t.add_arm(arm)
        tables.append(t)
    for s in sats:
        sql = PK.read(s.path)
        meta = PK.yaml_block(sql)
        extra = meta.get("src_extra_columns") or []
        extra = [extra] if isinstance(extra, str) else extra
        run_ts = "multi_source" in s.macro or "DBT_RUN_TS" in [e.upper() for e in extra]
        t = T.Table(project, "satellite", s.name, s.pk, s.ldts, run_ts=run_ts)
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


# Patch T.Table.scope to always use rs_values if we parsed any (travel
# cannot rely on prefix in the shared vault).
_orig_scope = T.Table.scope


def table_scope(self, alias=""):
    a = f"{alias}." if alias else ""
    if getattr(self, "object_group", None):
        return f"{a}RECORD_SOURCE = '{self.object_group}'"
    rs = list(dict.fromkeys(self.rs_values))
    if rs:
        lits = ", ".join("'" + v.replace("'", "''") + "'" for v in rs)
        return f"{a}RECORD_SOURCE in ({lits})"
    return f"startswith({a}RECORD_SOURCE, '{self.project}_')"


T.Table.scope = table_scope


# ---------------------------------------------------------------------------
# Metadata
# ---------------------------------------------------------------------------
COMMON = [
    ("Owner", "LUMIQ"),
    ("Vault location", K.VAULT),
    ("Maximus Travel RAW", K.RAW_SCHEMA["maximus_travel_raw"]),
    ("Opus Travel RAW (prod)", K.RAW_SCHEMA["travel_raw"]),
    ("Opus Travel RAW (test)", K.RAW_SCHEMA["travel_test_raw"]),
    ("Scope", "Every hub, link and satellite the project's travel models load. Rows "
              "scoped by the RECORD_SOURCE value set parsed from the project's feeds "
              "(the partner build writes to the same vault under the same prefix)."),
]

CHECKS = OrderedDict([
    ("DM-T1", dict(
        title="DM-T1  |  Load Audit \u2014 Load Metadata Populated (Travel LOB)",
        subtitle="Load date/timestamp and record source populated and correct. Pass criterion: 0 rows with missing metadata.",
        overview=[("Check ID", "DM-T1"), ("Category", "Load audit"),
                  ("Sign-off criterion", "Load metadata populated"),
                  ("Method", "Per table: null / placeholder / future LOAD_DATETIME, "
                             "null RECORD_SOURCE, RECORD_SOURCE outside the values the "
                             "models write"),
                  ("Pass criteria / tolerance", "0 rows with missing metadata")] + COMMON + [
                  ("Placeholder date", "LOAD_DATETIME earlier than 1990-01-01"),
                  ("Expected RECORD_SOURCE", "Parsed from every stg2 '!<constant>' "
                                             "value in the feeds this project writes.")])),
    ("DM-T2", dict(
        title="DM-T2  |  Load Audit \u2014 Hash Key Integrity (DV2.0, Travel LOB)",
        subtitle="Hash keys generated consistently; no null; no unexpected collisions.",
        overview=[("Check ID", "DM-T2"), ("Category", "Load audit"),
                  ("Sign-off criterion", "Hash key integrity (DV2.0)"),
                  ("Method", "(a) hash column types; (b) per table: null / wrong-length "
                             "hash keys, hub recompute, hub and link collisions"),
                  ("Pass criteria / tolerance", "0 null; 0 unexpected collisions")] + COMMON + [
                  ("Hash key formula", K.HASH_TXT)])),
])


def main():
    template = K.TEMPLATE_DOCX.read_bytes() if K.TEMPLATE_DOCX else None
    (VALIDATION / "DM-T").mkdir(parents=True, exist_ok=True)
    _ = RT._parents_travel()  # populates R.HUB_PK
    sats = AT.build_sats_travel()
    sats.sort(key=lambda s: (s.project != "MAXIMUS", s.layer != "standard", s.name))
    links = RT.build_links_travel()
    order = {"hub": 0, "link": 1, "satellite": 2}
    for pj, md in PROJECTS:
        tables = build_tables_travel(
            pj, md, [s for s in sats if s.project == pj],
            [l for l in links if l.project == pj])
        tables.sort(key=lambda t: (order[t.kind], t.name))
        n = {k: sum(t.kind == k for t in tables) for k in order}
        revision = [
            f"Travel LOB generated 2026-10-13 from the current {md.parent.name} "
            f"models by validation/tools/gen_dm_t_travel.py.",
            f"This file: {pj} only -- {n['hub']} hubs, {n['link']} links, "
            f"{n['satellite']} satellites.",
            "Row scopes use the RECORD_SOURCE value set parsed from the project's own "
            "feeds; the shared MAXIMUS_ / OPUS_ prefix would include partner rows too.",
        ]
        for cid, meta in CHECKS.items():
            if cid == "DM-T1":
                sections = [T.t1_summary(pj, tables)] + \
                    [T.t1_section(t) for t in tables]
            else:
                sections = [T.t2_types(pj, tables)] + \
                    [T.t2_section(t) for t in tables]
            pmeta = dict(meta, title=f"{meta['title']}  ({pj})",
                         overview=meta["overview"] + [("Project in this file", pj)])
            fid = f"{cid}_{pj}"
            PK.write_sql(fid, pmeta, sections, revision)
            if template is not None:
                A.write_docx(fid, pmeta, sections, revision, template)
            print(f"{fid}: {len(sections)} sections")
        for t in tables:
            if not (t.rs_values or t.rs_patterns):
                print(f"  WARNING {pj} {t.name}: no expected RECORD_SOURCE parsed")


if __name__ == "__main__":
    main()
