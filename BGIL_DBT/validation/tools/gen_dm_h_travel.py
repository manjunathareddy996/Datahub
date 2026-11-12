#!/usr/bin/env python3
"""
Travel LOB equivalent of gen_dm_h.py.

Travel DM-H is TRIMMED the same way as partner: only 4 satellites per
macro path are emitted (SELECTION below); DM-H3 keeps ONE per macro
(H3_SELECTION). A project with no SELECTION entry (OPUS travel, for now)
still emits every satellite. Row scopes use the RECORD_SOURCE value set parsed
per satellite (the partner build shares the vault under the same prefix).
DM-H1 follows the partner per-sat STEP 1..7 sequence (H.h1_section).

HASHDIFF integrity (h1a) for Maximus Travel crosses the satfeed layer:
each satfeed branch's `HASHDIFF_<SAT>` column is parsed back to the
originating stg2's hashed_columns entry; the payload column list stored
there is used to recompute the hashdiff on the sat row.

    python3 BGIL_DBT/validation/tools/gen_dm_h_travel.py [MAXIMUS|OPUS]
"""
import re
import sys
from datetime import date
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

# ---------------------------------------------------------------------------
# Travel selection: 4 satellites per macro path (MAXIMUS travel has two paths:
# automate_dv.sat and automate_dv.ma_sat). Mix of standard + augmented, single-
# and multi-RECORD_SOURCE sats. Confirm row counts with DM-H_ROWCOUNT_CHECK.sql
# and swap a 0-row sat for a same-path alternate (listed in that file).
# (SAT_NAME, PROJECT) -> macro path.
# ---------------------------------------------------------------------------
SELECTION_PATHS = {
    # automate_dv.sat
    ("SAT_POLICY_HEADER", "MAXIMUS"): "automate_dv.sat",
    ("SAT_CLAIM_HEADER", "MAXIMUS"): "automate_dv.sat",
    ("SAT_POLICY_TERMS", "MAXIMUS"): "automate_dv.sat",
    ("SAT_AUG_POLICY_TRAVEL_TERMS", "MAXIMUS"): "automate_dv.sat",
    ("SAT_COVERAGE_CONDITIONS", "MAXIMUS"): "automate_dv.sat",  # added on request
    # automate_dv.ma_sat
    ("SAT_CLAIM_BENEFIT_HEAD", "MAXIMUS"): "automate_dv.ma_sat",
    ("SAT_POLICY_DISCOUNT_LOADING_APPLIED", "MAXIMUS"): "automate_dv.ma_sat",
    ("SAT_CLAIM_PAYMENT_TRANCHE", "MAXIMUS"): "automate_dv.ma_sat",
    ("SAT_AUG_POLICY_PREMIUM_HEAD", "MAXIMUS"): "automate_dv.ma_sat",
}
# DM-H3 (idempotent re-load): ONE representative sat per (project, macro).
H3_PATHS = {
    ("SAT_POLICY_HEADER", "MAXIMUS"): "automate_dv.sat",
    ("SAT_CLAIM_BENEFIT_HEAD", "MAXIMUS"): "automate_dv.ma_sat",
}
TRIMMED_PROJECTS = {pj for (_, pj) in SELECTION_PATHS}

# gen_dm_h's own SELECTION / H3_SELECTION are partner-specific; travel replaces the
# selector functions and tags below.
H.SELECTION = {}
H.H3_SELECTION = {}


# RCA results (validation/rca/test): a sat marked fail/na there is never selected or
# offered as an alternate. Swap any selected sat that later fails by editing SELECTION_PATHS.
RCA_FILE = Path(__file__).resolve().parent.parent / "rca" / "test"


def rca_failed():
    if not RCA_FILE.exists():
        return set()
    lines = [l.strip() for l in RCA_FILE.read_text().splitlines() if l.strip()]
    if "Failing rows" not in lines:
        return set()
    rows, cur = [], None
    for l in lines[lines.index("Failing rows") + 1:]:
        if re.fullmatch(r"\d+", l):
            cur = []
            rows.append(cur)
        elif cur is not None:
            cur.append(l)
    return {r[1] for r in rows if len(r) > 3 and r[3].lower() in ("fail", "na")}


def _order(s, table):
    return (table[(s.name, s.project)], s.layer != "standard", s.name)


def selected_sats_travel(ps, project):
    """Trimmed projects: only SELECTION_PATHS sats, ordered (macro path, layer, name).
    Untrimmed project: every sat, standard first."""
    if project in TRIMMED_PROJECTS:
        out = [s for s in ps if (s.name, project) in SELECTION_PATHS]
        out.sort(key=lambda s: _order(s, SELECTION_PATHS))
        return out
    out = list(ps)
    out.sort(key=lambda s: (s.layer != "standard", s.name))
    return out


def selected_sats_h3_travel(ps, project):
    if project in TRIMMED_PROJECTS:
        out = [s for s in ps if (s.name, project) in H3_PATHS]
        out.sort(key=lambda s: _order(s, H3_PATHS))
        return out
    return selected_sats_travel(ps, project)


def plan_tag_travel(sat):
    p = SELECTION_PATHS.get((sat.name, sat.project))
    return f"[{p}] " if p else ""


def h3_tag_travel(sat):
    p = H3_PATHS.get((sat.name, sat.project))
    return f"[{p}] " if p else ""


H.selected_sats = selected_sats_travel
H.selected_sats_h3 = selected_sats_h3_travel
H.plan_tag = plan_tag_travel
H.h3_tag = h3_tag_travel


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
    return f"startswith(RECORD_SOURCE, '{sat.project}_{K.LOB}_')"


H.project_scope = _project_scope_travel


# ---------------------------------------------------------------------------
# STEP 3 (bk map) for travel. Maximus travel stg2s read from resolved_mt__ views, so a
# hkey expression carries walk tokens (w0_policy_number ...) that only exist after the
# parent RAW tables are joined. The partner/base bk_map_query selects the bare RAW view
# and leaves those tokens in place -> invalid column. This version aliases the RAW row
# as `b`, left-joins the same parent chain STEP 2 uses (AT._walk_join_sql) and shows the
# RAW row's own key columns (what STEP 4 filters on) plus each walked parent column.
# ---------------------------------------------------------------------------
_ORIG_BK_MAP = H.bk_map_query


def _bk_map_arm_walk(sat, g, a):
    md = a._md
    joins, alias_map, _unres = AT._walk_join_sql(md, a.walks)
    if not joins:
        return None
    lk = a.lookup
    hk_raw = lk.get(sat.pk)
    if not hk_raw:
        return None
    hk = AT._rewrite_arm_expr(hk_raw, alias_map)
    ldts = AT._rewrite_arm_expr(lk.get(sat.ldts) or "null", alias_map)
    b_cols = A.raw_cols_of(hk_raw)
    walk_toks = [t for t in dict.fromkeys(AT._WALK_TOKEN_RE.findall(hk_raw)) if t in alias_map]
    parts = [f'coalesce(to_varchar(b."{c}"), \'^^\')' for c in b_cols]
    parts += [f"coalesce(to_varchar({alias_map[t]}), '^^')" for t in walk_toks]
    bk_sel = " || '|' || ".join(parts) if parts else "null"
    join_sql = "\n".join(f"       {jl}" for jl in joins)
    return (f"-- via {a.label} ({a.raw})  [RAW key columns: "
            f"{', '.join(b_cols) or 'none'}; parent columns: "
            f"{', '.join(walk_toks) or 'none'}]\n"
            f"select {H.lit(sat.name)} as satellite, {H.lit(g.label)} as record_source,\n"
            f"       {hk} as hkey, {bk_sel} as business_key, {ldts} as inc_job_updated_at,\n"
            f"       {H.lit(a.raw)} as raw_table\n"
            f"  from {a.raw} b\n{join_sql}\n"
            f" where {hk} in (select hkey from s_bk)"
            + (f" and {AT._rewrite_arm_expr(a.where, alias_map)}" if a.where else ""))


def bk_map_query_travel(sat):
    if not any(getattr(a, "walks", None) and getattr(a, "_md", None) is not None
               for g in sat.groups.values() for a in g.arms):
        return _ORIG_BK_MAP(sat)
    arms_sql = []
    for g in sat.groups.values():
        if not g.cols:
            continue
        for a in g.arms:
            if a.kind == "stitch":
                continue
            if getattr(a, "walks", None) and getattr(a, "_md", None) is not None:
                q = _bk_map_arm_walk(sat, g, a)
            else:
                lk = a.lookup
                hk = lk.get(sat.pk)
                if not hk:
                    continue
                bk_cols = A.raw_cols_of(hk)
                bk_sel = (" || '|' || ".join(f'coalesce(to_varchar("{c}"), \'^^\')' for c in bk_cols)
                          if bk_cols else "null")
                where = f" and {a.where}" if a.where else ""
                q = (f"-- via {a.label} ({a.raw})\n"
                     f"select {H.lit(sat.name)} as satellite, {H.lit(g.label)} as record_source,\n"
                     f"       {hk} as hkey, {bk_sel} as business_key, {lk.get(sat.ldts) or 'null'} as inc_job_updated_at,\n"
                     f"       {H.lit(a.raw)} as raw_table\n"
                     f"  from {a.raw}\n where {hk} in (select hkey from s_bk){where}")
            if q:
                arms_sql.append(q)
    if not arms_sql:
        return None
    sampled = (f"s_bk as (  -- sampled BEFORE hkeys for this satellite\n"
               f"    select distinct hkey from {H.SNAP}\n"
               f"     where run_id = $DM_H_RUN and phase = 'BEFORE' and satellite = '{sat.name}'\n)")
    return f"with {sampled}\n" + "\nunion all\n".join(arms_sql) + "\nlimit 20;"


H.bk_map_query = bk_map_query_travel


# ---------------------------------------------------------------------------
# Metadata
# ---------------------------------------------------------------------------
COMMON = [
    ("Owner", "LUMIQ"),
    ("Vault location", K.VAULT),
    ("Maximus Travel RAW", K.RAW_SCHEMA["maximus_travel_raw"]),
    ("Opus Travel RAW (prod)", K.RAW_SCHEMA["travel_raw"]),
    ("Opus Travel RAW (test)", K.RAW_SCHEMA["travel_test_raw"]),
    ("Scope", "The standard + augmented satellites listed in this file (see Test plan); rows "
              "scoped by the project's TRAVEL RECORD_SOURCE value set (shared vault with partner)."),
    ("Snapshot schema (b)", f"{H.VALIDATION_SCHEMA} -- tables "
                            f"DM_H_CDC_SNAPSHOT / DM_H_RELOAD_SNAPSHOT (transient)."),
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


# Only these checks are (re)generated for travel. DM-H2 / DM-H3 are intentionally left
# untouched (not trimmed yet) -- add them here when they should follow the H1/H4 plan.
ACTIVE_CHECKS = {"DM-H1", "DM-H4"}


def test_plan(pj, cid, n):
    if pj not in TRIMMED_PROJECTS:
        return f"No trim plan for {pj} travel yet: every satellite of the project is listed ({n})."
    if cid == "DM-H3":
        return (f"Trimmed to ONE satellite per macro path ({n} here); idempotency behaves the "
                f"same for every sat built by a macro. Alternates: DM-H_ROWCOUNT_CHECK.sql.")
    return (f"Trimmed to 4 satellites per macro path ({n} here: automate_dv.sat, "
            f"automate_dv.ma_sat). Alternates: DM-H_ROWCOUNT_CHECK.sql.")


def _fully_testable(s):
    """Alternate candidates: static check Implemented and a STEP 2/3/4 can be generated."""
    try:
        return (s.applicable and H.h1a(s)["status"] == "Implemented"
                and H.cdc_capture(s) and H.bk_map_query(s) and H.force_change_query(s))
    except Exception:
        return False


def write_rowcount_check(pj, allp, ps):
    """DM-H_ROWCOUNT_CHECK.sql: row count of every selected sat + same-macro alternates."""
    sel = {s.name for s in ps}
    lines = []
    for macro in sorted({SELECTION_PATHS[(s.name, pj)] for s in ps}):
        lines.append(f"-- {macro}: selected")
        for s in ps:
            if SELECTION_PATHS[(s.name, pj)] == macro:
                lines.append(f"select '{macro}' as path, 'SELECTED' as role, '{s.name}' as satellite, "
                             f"count(*) as {pj.lower()}_rows from {s.fq} where {H.project_scope(s)}")
        bad = rca_failed()
        alts = [s for s in allp if s.macro == macro and s.name not in sel and s.name not in bad
                and _fully_testable(s)]
        alts.sort(key=lambda s: (s.layer != "standard", s.name))
        lines.append(f"-- {macro}: alternates (swap in if a selected sat has 0 rows)")
        for s in alts[:6]:
            lines.append(f"select '{macro}' as path, 'ALTERNATE' as role, '{s.name}' as satellite, "
                         f"count(*) as {pj.lower()}_rows from {s.fq} where {H.project_scope(s)}")
    body, first = [], True
    for ln in lines:
        if ln.startswith("--"):
            body.append(ln)
            continue
        body.append(("" if first else "union all ") + ln)
        first = False
    text = f"""/* =====================================================================================
   DM-H (Travel, {pj})  |  Row-count pre-check for the trimmed satellite selection
   Run this BEFORE DM-H1..DM-H4. A satellite with 0 rows cannot produce DM-H evidence:
   swap it for an ALTERNATE of the SAME macro path (set SELECTION_PATHS in
   validation/tools/gen_dm_h_travel.py and regenerate) and note the swap (old -> new).
   Vault: {K.VAULT}
   GENERATED by validation/tools/gen_dm_h_travel.py -- edit the generator, not this file.
   ===================================================================================== */
""" + "\n".join(body) + "\n;\n"
    out = VALIDATION / "DM-H" / "DM-H_ROWCOUNT_CHECK.sql"
    out.write_text(text)
    print(f"{out.name}: {sum(1 for l in lines if not l.startswith('--'))} sats")


def main():
    only = {a.upper() for a in sys.argv[1:]}
    template = K.TEMPLATE_DOCX.read_bytes() if K.TEMPLATE_DOCX else None
    (VALIDATION / "DM-H").mkdir(parents=True, exist_ok=True)
    sats = AT.build_sats_travel()
    sats.sort(key=lambda s: (s.project != "MAXIMUS", s.layer != "standard", s.name))
    for pj, md in PROJECTS:
        if only and pj not in only:
            continue
        allp = [s for s in sats if s.project == pj]
        ps = selected_sats_travel(allp, pj)
        ps3 = selected_sats_h3_travel(allp, pj)
        live = [s for s in ps if s.applicable]
        if pj in TRIMMED_PROJECTS:
            trim_note = (f"TRIMMED to 4 satellites per macro path: {pj} has {len(ps)} satellites in "
                         f"this file ({len(live)} with mapped payload); each is prefixed with its "
                         f"[macro-path]. If an assigned sat has 0 rows, swap it for a same-path "
                         f"alternate listed in DM-H_ROWCOUNT_CHECK.sql (run it first to confirm row counts).")
        else:
            trim_note = (f"NOT trimmed yet -- covers every satellite in {pj} ({len(ps)}; "
                         f"{len(live)} with mapped payload).")
        revision = [
            f"Travel LOB generated {date.today().isoformat()} from the current {md.parent.name} "
            f"models by validation/tools/gen_dm_h_travel.py (satellite lineage from "
            f"gen_dm_a_travel.py).",
            trim_note,
            "Static queries (a) run on data already loaded; (b) procedures need a dbt "
            "load between BEFORE and AFTER captures.",
            "Sections marked NA load only hard-coded NULL padding or a disabled "
            "placeholder.",
        ]
        if pj in TRIMMED_PROJECTS:
            write_rowcount_check(pj, allp, ps)
        for cid, meta in CHECKS.items():
            if cid not in ACTIVE_CHECKS:
                continue
            rev = revision
            if cid == "DM-H1":
                sections = [H.cdc_setup(), H.cdc_procedure(pj)]
                for s in ps:
                    sections.append(H.h1_section(s))
                res = H.cdc_result(pj, cid)
                res["hub"] = "STEP 7 -- " + res["hub"]
                sections.append(res)
            elif cid == "DM-H2":
                sections = []
                for s in ps:
                    sec = H.h2a(s)
                    sec["hub"] = H.plan_tag(s) + sec["hub"]
                    sections.append(sec)
                sections.append(H.cdc_result(pj, cid))
            elif cid == "DM-H3":
                sections = []
                for s in ps3:
                    sec = H.h3a(s)
                    sec["hub"] = H.h3_tag(s) + sec["hub"]
                    sections.append(sec)
                sections += H.h3_reload(pj, ps3)
                if pj in TRIMMED_PROJECTS:
                    rev = [revision[0],
                           f"DM-H3 (idempotent re-load) is trimmed to ONE satellite per macro path for "
                           f"{pj} ({len(ps3)} satellites here). Each sat is prefixed with its [macro-path].",
                           revision[2], revision[3]]
            else:
                sections = []
                for s in ps:
                    sec = H.h4(s)
                    sec["hub"] = H.plan_tag(s) + sec["hub"]
                    sections.append(sec)
            n = len(ps3) if cid == "DM-H3" else len(ps)
            pmeta = dict(meta, title=f"{meta['title']}  ({pj})",
                         overview=meta["overview"] + [("Test plan", test_plan(pj, cid, n)),
                                                      ("Project in this file", pj)])
            fid = f"{cid}_{pj}"
            PK.write_sql(fid, pmeta, sections, rev)
            if template is not None:
                A.write_docx(fid, pmeta, sections, rev, template,
                             preface=H.before_part_b(pj, cid) if cid != "DM-H4" else None)
            print(f"{fid}: {len(sections)} sections, "
                  f"{sum(x['status'] == 'NA' for x in sections)} NA")


if __name__ == "__main__":
    main()
