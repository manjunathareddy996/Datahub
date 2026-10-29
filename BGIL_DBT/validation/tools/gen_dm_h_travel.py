#!/usr/bin/env python3
"""
Travel LOB equivalent of gen_dm_h.py.

No member plan yet for travel -- covers every satellite in this round
(SELECTION / H3_SELECTION are empty); trim once a DM-H_MEMBER_PLAN.md is
agreed. Row scopes use the RECORD_SOURCE value set parsed per satellite
(the partner build shares the vault under the same prefix).

HASHDIFF integrity (h1a) for Maximus Travel crosses the satfeed layer:
each satfeed branch's `HASHDIFF_<SAT>` column is parsed back to the
originating stg2's hashed_columns entry; the payload column list stored
there is used to recompute the hashdiff on the sat row.

    python3 BGIL_DBT/validation/tools/gen_dm_h_travel.py
"""
import re
import sys
from collections import OrderedDict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import gen_dm_k_travel as K  # noqa: E402
import gen_dm_a_travel as AT  # noqa: E402
import gen_dm_a as A  # noqa: E402
import gen_dm_h as H  # noqa: E402
import gen_dm_k as PK  # noqa: E402

VALIDATION = K.VALIDATION
PROJECTS = AT.PROJECTS
H.MD = dict(PROJECTS)

# No member plan yet.
H.SELECTION = {}
H.H3_SELECTION = {}


def selected_sats_all(ps, project):
    """Travel first-cut: no member plan -- every sat of the project."""
    out = list(ps)
    out.sort(key=lambda s: (s.layer != "standard", s.name))
    return out


H.selected_sats = selected_sats_all
H.selected_sats_h3 = selected_sats_all
H.plan_tag = lambda sat: ""
H.h3_tag = lambda sat: ""


# ---------------------------------------------------------------------------
# feed_hashdiff_cols for travel: a satfeed_mt_<sat> branch renames
# HASHDIFF_<SAT> -> HASHDIFF; the stg2 whose hashed_columns define
# HASHDIFF_<SAT> carries the real payload column list. Partner's helper
# already follows a thin wrapper rename back to a wide stage; the same
# logic applies to a satfeed branch, so we re-dispatch each branch
# through A.parse_wrapper + the underlying stg2.
# ---------------------------------------------------------------------------
_ORIG_FEED_HASHDIFF_COLS = H.feed_hashdiff_cols


def feed_hashdiff_cols_travel(md, feed, hd):
    sql = PK.read(PK.find_model(md, feed))
    if feed.startswith(("satfeed_mt_", "hubfeed_mt_", "lnkfeed_mt_")):
        # Union-all over per-branch renames; every branch is expected to
        # map the same payload list (the macros can't tolerate a mismatch),
        # so we read the first branch's mapping and use that.
        body = A.strip_sql_comments(sql)
        for part in re.split(r"\bunion\s+all\b", body, flags=re.I):
            if "ref(" not in part:
                continue
            parsed = AT._parse_feed_branch_wrapper(part)
            if not parsed:
                continue
            ref, rename, _ = parsed
            inner_hd = rename.get(hd.lower(), hd.lower())
            try:
                return _ORIG_FEED_HASHDIFF_COLS(md, ref, inner_hd)
            except Exception:
                continue
        return None
    return _ORIG_FEED_HASHDIFF_COLS(md, feed, hd)


H.feed_hashdiff_cols = feed_hashdiff_cols_travel


# ---------------------------------------------------------------------------
# project_scope override: travel sats are scoped by RECORD_SOURCE value
# set, not just the prefix. We derive the set from the satellite's groups.
# ---------------------------------------------------------------------------
def _project_scope_travel(sat):
    if sat.object_cols:
        return f"RECORD_SOURCE = '{sat.project}'"
    rs = sorted({g.rs_value for g in sat.groups.values() if g.rs_value})
    if rs:
        lits = ", ".join("'" + v.replace("'", "''") + "'" for v in rs)
        return f"RECORD_SOURCE in ({lits})"
    return f"startswith(RECORD_SOURCE, '{sat.project}_')"


H.project_scope = _project_scope_travel


# ---------------------------------------------------------------------------
# Metadata
# ---------------------------------------------------------------------------
COMMON = [
    ("Owner", "LUMIQ"),
    ("Vault location", K.VAULT),
    ("Maximus Travel RAW", K.RAW_SCHEMA["maximus_travel_raw"]),
    ("Opus Travel RAW (prod)", K.RAW_SCHEMA["travel_raw"]),
    ("Opus Travel RAW (test)", K.RAW_SCHEMA["travel_test_raw"]),
    ("Scope", "Every standard + augmented satellite of the project; rows scoped by the "
              "project's TRAVEL RECORD_SOURCE value set (shared vault with partner)."),
    ("Snapshot schema (b)", f"{H.VALIDATION_SCHEMA} -- tables "
                            f"DM_H_CDC_SNAPSHOT / DM_H_RELOAD_SNAPSHOT (transient)."),
    ("Member plan",
     "No DM-H member plan for travel yet; this file covers every satellite in the "
     "project. Trim once a plan is agreed (see partner DM-H_MEMBER_PLAN.md for the "
     "shape)."),
]

CHECKS = OrderedDict([
    ("DM-H1", dict(
        title="DM-H1  |  History \u2014 Change Creates a New Satellite Row (Travel LOB)",
        subtitle="A record changed in source creates a new satellite row.",
        overview=[("Check ID", "DM-H1"), ("Category", "History checks"),
                  ("Sign-off criterion", "Change creates a new satellite row"),
                  ("Method", "(a) HASHDIFF integrity on every row; (b) before / after "
                             "CDC capture of sampled keys around a dbt load"),
                  ("Pass criteria / tolerance", "New sat row on change")] + COMMON)),
    ("DM-H2", dict(
        title="DM-H2  |  History \u2014 No Change Creates No New Row (Travel LOB)",
        subtitle="An unchanged record creates no new satellite row.",
        overview=[("Check ID", "DM-H2"), ("Category", "History checks"),
                  ("Sign-off criterion", "No change creates no new row"),
                  ("Method", "(a) no consecutive versions with the same HASHDIFF; "
                             "(b) unchanged keys of the DM-H1 CDC capture got 0 new rows"),
                  ("Pass criteria / tolerance", "No new row when unchanged")] + COMMON)),
    ("DM-H3", dict(
        title="DM-H3  |  History \u2014 Idempotent Re-load (Travel LOB)",
        subtitle="Re-running the same load does not create duplicate satellite rows.",
        overview=[("Check ID", "DM-H3"), ("Category", "History checks"),
                  ("Sign-off criterion", "Idempotent re-load"),
                  ("Method", "(a) duplicate-version query per satellite; (b) re-run "
                             "an already-loaded window and compare row counts"),
                  ("Pass criteria / tolerance", "No duplicate rows on re-run")] + COMMON)),
    ("DM-H4", dict(
        title="DM-H4  |  History \u2014 Current-view Correctness (Travel LOB)",
        subtitle="Latest satellite row per key matches the latest source record.",
        overview=[("Check ID", "DM-H4"), ("Category", "History checks"),
                  ("Sign-off criterion", "Current-view correctness"),
                  ("Method", "Latest sat row vs latest RAW record, most recently loaded keys"),
                  ("Pass criteria / tolerance", "Latest sat row = latest source")] + COMMON)),
])


def main():
    template = K.TEMPLATE_DOCX.read_bytes() if K.TEMPLATE_DOCX else None
    (VALIDATION / "DM-H").mkdir(parents=True, exist_ok=True)
    sats = AT.build_sats_travel()
    sats.sort(key=lambda s: (s.project != "MAXIMUS", s.layer != "standard", s.name))
    for pj, md in PROJECTS:
        ps = [s for s in sats if s.project == pj]
        live = [s for s in ps if s.applicable]
        revision = [
            f"Travel LOB generated 2026-10-13 from the current {md.parent.name} "
            f"models by validation/tools/gen_dm_h_travel.py (satellite lineage from "
            f"gen_dm_a_travel.py).",
            f"NO member plan yet -- covers every satellite in {pj} ({len(ps)}; "
            f"{len(live)} with mapped payload). Trim once a DM-H plan is agreed.",
            "Static queries (a) run on data already loaded; (b) procedures need a dbt "
            "load between BEFORE and AFTER captures.",
            "Sections marked NA load only hard-coded NULL padding or a disabled "
            "placeholder.",
        ]
        for cid, meta in CHECKS.items():
            if cid == "DM-H1":
                sections = [H.cdc_setup(), H.cdc_procedure(pj)]
                for s in ps:
                    sec = H.h1a(s)
                    sections.append(sec)
                sections.append(H.cdc_result(pj, cid))
            elif cid == "DM-H2":
                sections = []
                for s in ps:
                    sections.append(H.h2a(s))
                sections.append(H.cdc_result(pj, cid))
            elif cid == "DM-H3":
                sections = []
                for s in ps:
                    sections.append(H.h3a(s))
                sections += H.h3_reload(pj, ps)
            else:
                sections = []
                for s in ps:
                    sections.append(H.h4(s))
            pmeta = dict(meta, title=f"{meta['title']}  ({pj})",
                         overview=meta["overview"] + [("Project in this file", pj)])
            fid = f"{cid}_{pj}"
            PK.write_sql(fid, pmeta, sections, revision)
            if template is not None:
                A.write_docx(fid, pmeta, sections, revision, template)
            print(f"{fid}: {len(sections)} sections, "
                  f"{sum(x['status'] == 'NA' for x in sections)} NA")


if __name__ == "__main__":
    main()
