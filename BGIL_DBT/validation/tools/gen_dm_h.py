#!/usr/bin/env python3
"""
Generate the DM-H1..DM-H4 sign-off validation SQL + DOCX (satellite history / CDC checks)
for the MAXIMUS and OPUS partner Data Vault projects.

    python3 BGIL_DBT/validation/tools/gen_dm_h.py

Outputs (overwritten), one pair per check and project:
    BGIL_DBT/validation/DM-H/DM-H{1..4}_{MAXIMUS,OPUS}.{sql,docx}

Satellite lineage (sat -> stg2 -> stg_ / unpivot / stitch -> RAW) comes from gen_dm_a.py.

DM-H1  Change creates a new satellite row
       (a) HASHDIFF integrity: every row's stored HASHDIFF = hash recomputed from its payload
       (b) before / after CDC test: sampled keys whose RAW payload changed got >= 1 new row
DM-H2  No change creates no new row
       (a) no two consecutive versions of a key carry the same HASHDIFF (unchanged re-insert)
       (b) same CDC test: sampled keys whose RAW payload did NOT change got 0 new rows
DM-H3  Idempotent re-load
       (a) no duplicate rows (key, child key, RECORD_SOURCE, LOAD_DATETIME, HASHDIFF)
       (b) re-run the same load window twice: satellite row counts unchanged
DM-H4  Current-view correctness
       latest satellite row = latest RAW record, on the most recently loaded keys
"""
import re
import sys
from collections import OrderedDict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import gen_dm_k as K  # noqa: E402
import gen_dm_a as A  # noqa: E402

# Scratch schema for the before / after snapshots (needs CREATE TABLE / INSERT rights).
VALIDATION_SCHEMA = "BAGIC_PREPROD_CURATED_DB.UTILS"
SNAP = f"{VALIDATION_SCHEMA}.DM_H_CDC_SNAPSHOT"
COUNT_SNAP = f"{VALIDATION_SCHEMA}.DM_H_RELOAD_SNAPSHOT"
MD = dict(A.PROJECTS)
lit = A.lit

# ---------------------------------------------------------------------------------------
# Member test-plan selection (see validation/DM-H/DM-H_MEMBER_PLAN.md).
# Only these satellites are emitted into DM-H1..H4. Each entry: (SAT_NAME, PROJECT) ->
# (member, path). A sat may be assigned in both projects (listed twice). Keep this in
# sync with DM-H_MEMBER_PLAN.md / DM-H_ROWCOUNT_CHECK.sql.
# ---------------------------------------------------------------------------------------
SELECTION = {
    # Path 1: automate_dv.sat
    ("SAT_COMMON_ADMIN_GEOGRAPHY", "MAXIMUS"): ("M1", "automate_dv.sat"),
    ("SAT_PARTY_FINANCIAL_PROFILE", "MAXIMUS"): ("M1", "automate_dv.sat"),
    ("SAT_COMMON_CONSENT", "MAXIMUS"): ("M2", "automate_dv.sat"),
    ("SAT_PARTY_FRAUD_PROFILE", "MAXIMUS"): ("M2", "automate_dv.sat"),
    ("SAT_COMMON_CLASSIFICATION", "MAXIMUS"): ("M3", "automate_dv.sat"),
    ("SAT_PARTY_RELATIONSHIP_PROFILE", "MAXIMUS"): ("M3", "automate_dv.sat"),
    # Path 2: sat_multi_source plain
    ("SAT_COMMON_ADDRESS", "MAXIMUS"): ("M1", "sat_multi_source"),
    ("SAT_PARTY_BANKING", "MAXIMUS"): ("M1", "sat_multi_source"),
    ("SAT_PARTY_IDENTITY", "MAXIMUS"): ("M1", "sat_multi_source"),
    ("SAT_LOCATION_PROFILE", "MAXIMUS"): ("M1", "sat_multi_source"),
    ("SAT_PARTY_VEHICLE_PRIOR_INSURANCE", "OPUS"): ("M1", "sat_multi_source"),
    ("SAT_POLICY_CERTIFICATE", "OPUS"): ("M1", "sat_multi_source"),
    ("SAT_AUG_PARTY", "OPUS"): ("M1", "sat_multi_source"),
    ("SAT_COMMON_GEO", "MAXIMUS"): ("M2", "sat_multi_source"),
    ("SAT_PARTY_ORGANISATION_PROFILE", "MAXIMUS"): ("M2", "sat_multi_source"),
    ("SAT_PARTY_INDIVIDUAL_DEMOGRAPHICS", "MAXIMUS"): ("M2", "sat_multi_source"),
    ("SAT_PARTY_CONSENT_MANDATE", "MAXIMUS"): ("M2", "sat_multi_source"),
    ("SAT_PARTY_BANKING", "OPUS"): ("M2", "sat_multi_source"),
    ("SAT_PARTY_KYC", "OPUS"): ("M2", "sat_multi_source"),
    ("SAT_AUG_KYC_DOCUMENT", "OPUS"): ("M2", "sat_multi_source"),
    ("SAT_PARTY_HIERARCHY", "MAXIMUS"): ("M3", "sat_multi_source"),
    ("SAT_PARTY_AGENT_LICENCE_LINE", "MAXIMUS"): ("M3", "sat_multi_source"),
    ("SAT_PARTY_PAYOUT_PROFILE", "MAXIMUS"): ("M3", "sat_multi_source"),
    ("SAT_AUG_PARTY_IDENTIFICATION", "MAXIMUS"): ("M3", "sat_multi_source"),
    ("SAT_PARTY_KYC_REFERENCE", "OPUS"): ("M3", "sat_multi_source"),
    ("SAT_POLICY_PREMIUM_SUMMARY", "OPUS"): ("M3", "sat_multi_source"),
    ("SAT_AUG_LOCATION", "OPUS"): ("M3", "sat_multi_source"),
    # Path 3: sat_multi_source OBJECT
    ("SAT_COMMON_CONTACT", "MAXIMUS"): ("M1", "sat_multi_source(OBJECT)"),
    ("SAT_PARTY_IDENTIFICATION", "MAXIMUS"): ("M1", "sat_multi_source(OBJECT)"),
    ("SAT_PARTY_IDENTIFICATION", "OPUS"): ("M1", "sat_multi_source(OBJECT)"),
    ("SAT_COMMON_CONTACT", "OPUS"): ("M3", "sat_multi_source(OBJECT)"),
    # Path 4: ma_sat_multi_source
    ("SAT_LNK_PARTY_ROLE_CORE", "MAXIMUS"): ("M1", "ma_sat_multi_source"),
    ("SAT_PARTY_DIGITAL_IDENTITY", "MAXIMUS"): ("M1", "ma_sat_multi_source"),
    ("SAT_PARTY_CONTACT_ADDRESS_LINK", "OPUS"): ("M2", "ma_sat_multi_source"),
    ("SAT_AUG_POLICY", "OPUS"): ("M2", "ma_sat_multi_source"),
    ("SAT_POLICY_CLASSIFICATION", "OPUS"): ("M3", "ma_sat_multi_source"),
    # Path 5: automate_dv.ma_sat
    ("SAT_PARTY_ORG_DIRECTORS", "MAXIMUS"): ("M1", "automate_dv.ma_sat"),
    ("SAT_LNK_CLAIM_PARTY_ROLE", "OPUS"): ("M1", "automate_dv.ma_sat"),
    ("SAT_PARTY_CONTACT_ADDRESS_LINK", "MAXIMUS"): ("M1", "automate_dv.ma_sat"),
    ("SAT_PARTY_PROVIDER_CAPABILITY", "MAXIMUS"): ("M2", "automate_dv.ma_sat"),
    ("SAT_LNK_POLICY_PARTY_ROLE", "OPUS"): ("M2", "automate_dv.ma_sat"),
    ("SAT_AUG_PARTY_LEGAL_PANEL_ROLE_LINE", "MAXIMUS"): ("M3", "automate_dv.ma_sat"),
    ("SAT_LNK_PARTY_ROLE_CORE", "OPUS"): ("M3", "automate_dv.ma_sat"),
    # Path 6: stitch_incremental (all OPUS)
    ("SAT_COMMON_ADDRESS", "OPUS"): ("M1", "stitch_incremental"),
    ("SAT_POLICY_HEADER", "OPUS"): ("M1", "stitch_incremental"),
    ("SAT_PARTY_IDENTITY", "OPUS"): ("M1", "stitch_incremental"),
    ("SAT_COMMON_ADMIN_GEOGRAPHY", "OPUS"): ("M1", "stitch_incremental"),
    ("SAT_PARTY_INDIVIDUAL_DEMOGRAPHICS", "OPUS"): ("M1", "stitch_incremental"),
    ("SAT_COMMON_GEO", "OPUS"): ("M2", "stitch_incremental"),
    ("SAT_PARTY_HEALTH_PROFILE", "OPUS"): ("M2", "stitch_incremental"),
    ("SAT_PRODUCT_DEFINITION", "OPUS"): ("M2", "stitch_incremental"),
    ("SAT_COMMON_COMMUNICATION_PREFERENCE", "OPUS"): ("M2", "stitch_incremental"),
    ("SAT_PARTY_EMPLOYMENT", "OPUS"): ("M2", "stitch_incremental"),
    ("SAT_COMMON_CLASSIFICATION", "OPUS"): ("M3", "stitch_incremental"),
    ("SAT_PROVIDER_BANKING", "OPUS"): ("M3", "stitch_incremental"),
    ("SAT_POLICY_BONUS_TRACKING", "OPUS"): ("M3", "stitch_incremental"),
    ("SAT_PARTY_CLAIM_HISTORY", "OPUS"): ("M3", "stitch_incremental"),
    ("SAT_PARTY_ORGANISATION_PROFILE", "OPUS"): ("M3", "stitch_incremental"),
}


def selected_sats(ps, project):
    """Filter the project's sats to those in the member plan, in (member, path, name) order."""
    out = []
    for s in ps:
        key = (s.name, project)
        if key in SELECTION:
            out.append(s)
    out.sort(key=lambda s: (SELECTION[(s.name, project)][0], SELECTION[(s.name, project)][1], s.name))
    return out


def plan_tag(sat):
    """'[M1 | automate_dv.sat]' prefix for a sat in the plan, else ''."""
    key = (sat.name, sat.project)
    if key in SELECTION:
        m, p = SELECTION[key]
        return f"[{m} | {p}] "
    return ""


# ---------------------------------------------------------------------------------------
# DM-H3 (Idempotent re-load) is trimmed further: ONE representative satellite per
# (project, macro path). The idempotency check behaves the same for every sat built by a
# given macro, so one per macro per project is enough. Keyed (SAT_NAME, PROJECT) -> path.
# ---------------------------------------------------------------------------------------
H3_SELECTION = {
    # MAXIMUS
    ("SAT_COMMON_ADMIN_GEOGRAPHY", "MAXIMUS"): "automate_dv.sat",
    ("SAT_PARTY_BANKING", "MAXIMUS"): "sat_multi_source",
    ("SAT_COMMON_CONTACT", "MAXIMUS"): "sat_multi_source(OBJECT)",
    ("SAT_LNK_PARTY_ROLE_CORE", "MAXIMUS"): "ma_sat_multi_source",
    ("SAT_PARTY_ORG_DIRECTORS", "MAXIMUS"): "automate_dv.ma_sat",
    # OPUS
    ("SAT_PARTY_BANKING", "OPUS"): "sat_multi_source",
    ("SAT_COMMON_CONTACT", "OPUS"): "sat_multi_source(OBJECT)",
    ("SAT_POLICY_CLASSIFICATION", "OPUS"): "ma_sat_multi_source",
    ("SAT_LNK_PARTY_ROLE_CORE", "OPUS"): "automate_dv.ma_sat",
    ("SAT_COMMON_ADDRESS", "OPUS"): "stitch_incremental",
}


def selected_sats_h3(ps, project):
    """DM-H3 subset: one sat per (project, macro), from H3_SELECTION."""
    out = [s for s in ps if (s.name, project) in H3_SELECTION]
    out.sort(key=lambda s: (H3_SELECTION[(s.name, project)], s.name))
    return out


def h3_tag(sat):
    key = (sat.name, sat.project)
    return f"[{H3_SELECTION[key]}] " if key in H3_SELECTION else ""


# ---------------------------------------------------------------------------------------
# HASHDIFF metadata
# ---------------------------------------------------------------------------------------
def sat_hashdiff(sat):
    """(column name the stg2 exposes, physical column in the satellite)."""
    sql = K.read(sat.path)
    src = K.yaml_block(sql)["src_hashdiff"]
    al = re.search(r"src_hashdiff_alias\s*=\s*'([^']+)'", sql)
    return src, (al.group(1) if al else src)


def feed_hashdiff_cols(md, feed, hd):
    sql = K.read(K.find_model(md, feed))
    try:
        meta = K.yaml_block(sql)
    except ValueError:
        meta = None
    if meta is None:  # thin wrapper: follow the rename back to the wide stage
        ref, rename = A.parse_wrapper(sql)
        return feed_hashdiff_cols(md, ref, rename.get(hd.lower(), hd.lower()))
    for k, v in (meta.get("hashed_columns") or {}).items():
        if k.lower() == hd.lower() and isinstance(v, dict) and v.get("is_hashdiff"):
            return [c.upper() for c in v["columns"]]
    return None


def std(col):
    return f"IFNULL(NULLIF(UPPER(TRIM(CAST({col} AS VARCHAR))), ''), '^^')"


def hashdiff_expr(cols):
    """automate_dv 0.11.5 hashdiff (alpha-sorted, '^^' null placeholder, '||' separator)."""
    cols = sorted(cols)
    inner = std(cols[0]) if len(cols) == 1 else "CONCAT_WS('||', " + ", ".join(std(c) for c in cols) + ")"
    return f"CAST(MD5_BINARY({inner}) AS BINARY(16))"


def object_hashdiff_expr(sat):
    """OBJECT branch of sat_multi_source: object cols (TO_JSON) then plain cols, no casing."""
    sql = K.read(sat.path)
    meta = K.yaml_block(sql)
    extra = meta.get("src_extra_columns") or []
    extra = [extra] if isinstance(extra, str) else extra
    superset = sorted(set(sat.payload) | {e for e in extra if e.upper() != "DBT_RUN_TS"})
    plain = [c for c in superset if c.upper() not in sat.object_cols]
    parts = []
    for c in sat.object_cols:
        parts += [f"IFNULL(TO_JSON({c}), '^^')", "'||'"]
    for i, c in enumerate(plain):
        parts.append(f"IFNULL(CAST({c} AS VARCHAR), '^^')")
        if i < len(plain) - 1:
            parts.append("'||'")
    return f"CAST(MD5_BINARY(CONCAT({', '.join(parts)})) AS BINARY(16))"


def project_scope(sat):
    return f"RECORD_SOURCE = '{sat.project}'" if sat.object_cols else f"startswith(RECORD_SOURCE, '{sat.project}_')"


def part_cols(sat):
    return ", ".join([sat.pk] + list(sat.cdk) + ["RECORD_SOURCE"])


# ---------------------------------------------------------------------------------------
# DM-H1 (a): HASHDIFF integrity
# ---------------------------------------------------------------------------------------
def h1a(sat):
    _, hd_phys = sat_hashdiff(sat)
    hd_src, _ = sat_hashdiff(sat)
    payload = set(sat.payload)
    findings = []
    if sat.object_cols:
        branches = [(f"all {sat.project} rows (OBJECT hashdiff)", project_scope(sat), object_hashdiff_expr(sat))]
    else:
        lists = OrderedDict()
        for g in sat.groups.values():
            cols = None
            for f in g.feeds:
                c = feed_hashdiff_cols(MD[sat.project], f, hd_src)
                if c is not None:
                    cols = c
                    break
            if cols:
                lists.setdefault(tuple(sorted(cols)), []).append(g)
        branches = []
        for cols, gs in lists.items():
            missing = [c for c in cols if c not in payload]
            if missing:
                findings.append(
                    f"HASHDIFF of {', '.join(g.label for g in gs)} ({', '.join(gs[0].feeds)}) also hashes "
                    f"{', '.join(missing)}, which this satellite does not store (a shared stage feeding several "
                    f"satellites). A change in only those columns gives a new HASHDIFF and so a NEW ROW WITH AN "
                    f"UNCHANGED PAYLOAD here -- breaks DM-H2; see DM-H2 (a) unchanged_payload_reinserts. The "
                    f"HASHDIFF cannot be recomputed from the satellite row.")
                continue
            flt = " or ".join(f"({g.rs_filter})" for g in gs)
            label = gs[0].label if len(gs) == 1 else f"{len(gs)} RECORD_SOURCEs sharing one HASHDIFF column list"
            branches.append((label, flt, hashdiff_expr(list(cols))))
    if not branches and findings:
        return dict(project=sat.project, hub=sat.name, status="Design finding",
                    pass_criteria="FAIL until the stage hashes only this satellite's payload (or documented exception)",
                    note=" ".join(findings) + " " + A.sat_note(sat),
                    queries=[("SQL query (a)", f"-- DM-H1 (a) {sat.project} {sat.name}: HASHDIFF not recomputable -- see note")])
    if not branches:
        return A.na(sat, "DM-H1")
    parts = []
    for label, flt, expr in branches:
        parts.append(f"""select '{sat.project}' as project, '{sat.name}' as satellite, {lit(label)} as scope,
       count(*) as rows_checked,
       count_if({hd_phys} is null) as null_hashdiff,
       count_if({hd_phys} <> {expr}) as hashdiff_mismatch,
       array_slice(array_agg(iff({hd_phys} <> {expr}, to_varchar({sat.pk}, 'HEX'), null)) within group (order by {sat.pk}), 0, 3) as mismatch_examples,
       iff(null_hashdiff = 0 and hashdiff_mismatch = 0, 'PASS', 'FAIL') as status
  from {sat.fq}
 where {flt}""")
    sql = "\nunion all\n".join(parts) + ";"
    return dict(project=sat.project, hub=sat.name, status="Implemented",
                pass_criteria="status = PASS (0 null and 0 mismatched HASHDIFF)",
                note=" ".join(findings) + (" " if findings else "") + (f"HASHDIFF column {hd_phys}. Recomputed exactly as automate_dv 0.11.5 / sat_multi_source "
                      f"computes it, from the payload stored on the same row. A match proves every payload change "
                      f"changes the HASHDIFF, which is what drives a new row. ") + A.sat_note(sat),
                queries=[("SQL query (a) -- HASHDIFF integrity (all rows of this project)", sql)])


# ---------------------------------------------------------------------------------------
# DM-H1 / H2 (b): before / after CDC capture
# ---------------------------------------------------------------------------------------
def cdc_sample(sat, gi, g):
    return (f"s{gi} as (  -- BEFORE: first {A.SAMPLE_N} keys by hash; AFTER: exactly the keys captured BEFORE\n"
            f"    select hkey from (\n"
            f"        select distinct {sat.pk} as hkey from {sat.fq} where {g.rs_filter} order by hkey limit {A.SAMPLE_N}\n"
            f"    ) where $DM_H_PHASE = 'BEFORE'\n"
            f"    union\n"
            f"    select distinct hkey from {SNAP}\n"
            f"     where $DM_H_PHASE = 'AFTER' and run_id = $DM_H_RUN and phase = 'BEFORE'\n"
            f"       and satellite = '{sat.name}' and record_source = {lit(g.label)}\n)")


def raw_hash(cols):
    return "md5(concat_ws('||', " + ", ".join(std(f"e.{c}") for c in cols) + "))" if len(cols) > 1 \
        else f"md5({std('e.' + cols[0])})"


def cdc_capture(sat):
    groups = [(gi, g, A.a2_cols(sat, g)) for gi, g in enumerate(sat.groups.values(), 1)]
    groups = [(gi, g, [c for c in cols if c != "RECORD_SOURCE"]) for gi, g, cols in groups]
    groups = [x for x in groups if x[2]]
    if not groups:
        return None
    stmts = []
    for gi, g, cols in groups:
        ctes = [cdc_sample(sat, gi, g)]
        if any(a.kind == "stitch" for a in g.arms):
            ctes += A.stitch_ctes(sat, gi, next(a for a in g.arms if a.kind == "stitch"))
        ctes.append(A.expected_cte(sat, gi, g, cols, A.a2_value, aggregate=bool(sat.object_cols)))
        cdk_sat = " || '|' || ".join(f"coalesce(to_varchar({c}), '^^')" for c in sat.cdk) or "''"
        cdk_e = " || '|' || ".join(f"coalesce(e.{A.cdk_alias(i)}, '^^')" for i in range(len(sat.cdk))) or "''"
        ctes.append(f"n{gi} as (  -- satellite history per sampled key\n"
                    f"    select {sat.pk} as hkey, {cdk_sat} as cdk, count(*) as sat_rows, max({sat.ldts}) as sat_max_ldts\n"
                    f"      from {sat.fq}\n     where {g.rs_filter} and {sat.pk} in (select hkey from s{gi})\n"
                    f"     group by 1, 2\n)")
        ctes.append(f"x{gi} as (  -- normalised RAW payload hash (UPPER / TRIM / '^^' like the HASHDIFF)\n"
                    f"    select e.hkey, {cdk_e} as cdk, min({raw_hash(cols)}) as raw_hash\n"
                    f"      from e{gi} e group by 1, 2\n)")
        stmts.append(
            f"insert into {SNAP} (run_id, phase, project, satellite, record_source, hkey, cdk, sat_rows, sat_max_ldts, raw_hash, captured_at)\n"
            f"with " + ",\n".join(ctes) + "\n"
            f"select $DM_H_RUN, $DM_H_PHASE, '{sat.project}', '{sat.name}', {lit(g.label)},\n"
            f"       coalesce(n.hkey, x.hkey), coalesce(n.cdk, x.cdk), coalesce(n.sat_rows, 0), n.sat_max_ldts, x.raw_hash, current_timestamp()\n"
            f"  from n{gi} n full outer join x{gi} x on x.hkey = n.hkey and x.cdk = n.cdk;")
    return "\n\n".join(stmts)


def bk_map_query(sat):
    """Per-model helper: for the sampled BEFORE hkeys, show the RAW business-key columns
    (and ldts) so a tester knows exactly which RAW row to edit for the DM-H1 (b) change.
    Reuses each arm's hkey expression; the BK columns are the RAW columns inside it."""
    groups = [(gi, g) for gi, g in enumerate(sat.groups.values(), 1)]
    groups = [(gi, g) for gi, g in groups if g.cols]
    if not groups:
        return None
    arms_sql = []
    for gi, g in groups:
        for a in g.arms:
            if a.kind == "stitch":
                # stitch: BK is the stitch unique key per source; show the key column + ldts
                st = a.stitch
                uk = st["unique_key"]
                for s in st["sources"]:
                    cols = s["_cols"]
                    key = A.subst(A.lower_idents(s["key_column"]), cols)
                    ldts = A.subst(A.lower_idents(s["ldts_column"]), cols)
                    hk = A.Lookup(st["_dc"], st["_hc"], {uk: f"({key})"}).get(sat.pk)
                    if not hk:
                        continue
                    arms_sql.append(
                        f"-- via {s['source_tag']} ({s['_raw']})\n"
                        f"select {lit(sat.name)} as satellite, {lit(g.label)} as record_source,\n"
                        f"       {hk} as hkey, {key} as business_key, {ldts} as inc_job_updated_at,\n"
                        f"       {lit(s['_raw'])} as raw_table\n"
                        f"  from {s['_raw']}\n"
                        f" where {key} is not null and {hk} in (select hkey from s_bk)")
                continue
            lk = a.lookup
            hk = lk.get(sat.pk)
            if not hk:
                continue
            bk_cols = A.raw_cols_of(hk)
            bk_sel = (" || '|' || ".join(f'coalesce(to_varchar("{c}"), \'^^\')' for c in bk_cols)
                      if bk_cols else "null")
            ldts = lk.get(sat.ldts) or "null"
            where = f" and {a.where}" if a.where else ""
            arms_sql.append(
                f"-- via {a.label} ({a.raw})\n"
                f"select {lit(sat.name)} as satellite, {lit(g.label)} as record_source,\n"
                f"       {hk} as hkey, {bk_sel} as business_key, {ldts} as inc_job_updated_at,\n"
                f"       {lit(a.raw)} as raw_table\n"
                f"  from {a.raw}\n"
                f" where {hk} in (select hkey from s_bk){where}")
    if not arms_sql:
        return None
    sampled = (f"s_bk as (  -- sampled BEFORE hkeys for this satellite\n"
               f"    select distinct hkey from {SNAP}\n"
               f"     where run_id = $DM_H_RUN and phase = 'BEFORE' and satellite = '{sat.name}'\n)")
    body = "\nunion all\n".join(arms_sql)
    return f"with {sampled}\n{body}\nlimit 20;"


def force_change_query(sat):
    """Per-model ready-to-run UPDATE template(s): bump a payload column + the LDTS of ONE
    sampled key in the UTILS RAW source so the dbt reload produces a new satellite row.
    Fill in the <...> business-key value from the (b-map) result before running."""
    groups = [(gi, g) for gi, g in enumerate(sat.groups.values(), 1)]
    groups = [(gi, g) for gi, g in groups if g.cols]
    if not groups:
        return None
    stmts = []
    for gi, g in groups:
        for a in g.arms:
            if a.kind == "stitch":
                st = a.stitch
                for s in st["sources"]:
                    cols = s["_cols"]
                    key_raw = A.raw_cols_of(A.subst(A.lower_idents(s["key_column"]), cols))
                    # a payload RAW column to touch
                    touch = None
                    for c in s["columns"]:
                        rc = A.raw_cols_of(A.subst(A.lower_idents(c["src"]), cols))
                        if rc:
                            touch = rc[0]
                            break
                    ldts_raw = A.raw_cols_of(A.subst(A.lower_idents(s["ldts_column"]), cols))
                    if not (key_raw and touch and ldts_raw):
                        continue
                    where = " and ".join(f'"{k}" = \'<{k}>\'' for k in key_raw)
                    stmts.append(
                        f"-- {s['source_tag']} source ({s['_raw']}): change ONE sampled key\n"
                        f"update {s['_raw']}\n"
                        f'   set "{touch}" = coalesce(to_varchar("{touch}"), \'\') || \'_T\',\n'
                        f'       "{ldts_raw[0]}" = current_timestamp()\n'
                        f" where {where};")
                continue
            lk = a.lookup
            hk = lk.get(sat.pk)
            bk_cols = A.raw_cols_of(hk) if hk else []
            # find a payload RAW column to touch (first payload col that maps to a single RAW col
            # and is NOT part of the business key)
            touch = None
            for c in g.cols:
                e = lk.get(c)
                if not e or A.is_null_expr(e):
                    continue
                rc = A.raw_cols_of(e)
                if len(rc) == 1 and rc[0] not in bk_cols:
                    touch = rc[0]
                    break
            if touch is None:  # fall back to any single-col payload (even if it is a cdk)
                for c in g.cols:
                    e = lk.get(c)
                    rc = A.raw_cols_of(e) if e else []
                    if len(rc) == 1:
                        touch = rc[0]
                        break
            ldts_raw = A.raw_cols_of(lk.get(sat.ldts) or "")
            if not (bk_cols and touch and ldts_raw):
                continue
            where = " and ".join(f'"{k}" = \'<{k}>\'' for k in bk_cols)
            stmts.append(
                f"-- {g.label} ({a.raw}): change ONE sampled key (fill <..> from the b-map result)\n"
                f"update {a.raw}\n"
                f'   set "{touch}" = coalesce(to_varchar("{touch}"), \'\') || \'_T\',\n'
                f'       "{ldts_raw[0]}" = current_timestamp()\n'
                f" where {where};")
            break  # one representative update per group is enough
    return "\n\n".join(stmts) if stmts else None


def cdc_result_for_sat(sat):
    """STEP 7 scoped to ONE satellite: BEFORE vs AFTER of the same run id, PASS/FAIL for
    just this sat. Same logic as the file-level cdc_result but filtered by satellite."""
    return f"""with b as (
    select * from {SNAP}
     where run_id = $DM_H_RUN and phase = 'BEFORE' and satellite = '{sat.name}'
),
a as (
    select * from {SNAP}
     where run_id = $DM_H_RUN and phase = 'AFTER'  and satellite = '{sat.name}'
),
k as (
    select b.satellite, b.record_source, b.hkey, b.cdk,
           not equal_null(b.raw_hash, a.raw_hash) as raw_changed,
           a.sat_rows - b.sat_rows as new_rows
      from b join a
        on a.satellite = b.satellite and a.record_source = b.record_source
       and a.hkey = b.hkey and equal_null(a.cdk, b.cdk)
)
select '{sat.project}' as project, satellite, record_source,
       count(*) as changed_keys,
       count_if(new_rows >= 1) as changed_with_new_row,
       count_if(new_rows < 1)  as changed_without_new_row,
       iff(changed_keys = 0, 'NOT TESTED (no source change in sample)',
           iff(changed_without_new_row = 0, 'PASS', 'FAIL')) as status
  from k
 where raw_changed
 group by satellite, record_source
 order by iff(status = 'FAIL', 0, 1), record_source;"""


def cdc_setup():
    return dict(project="SETUP", hub="CDC test set-up (run once)", status="Procedure",
                pass_criteria="n/a",
                note=("Creates the snapshot tables used by DM-H1 (b), DM-H2 (b) and DM-H3 (b). Needs CREATE SCHEMA / "
                      "TABLE rights on the scratch schema; change VALIDATION_SCHEMA in gen_dm_h.py to use another one."),
                queries=[("SQL", f"""create schema if not exists {VALIDATION_SCHEMA};

create transient table if not exists {SNAP} (
    run_id varchar, phase varchar, project varchar, satellite varchar, record_source varchar,
    hkey binary(16), cdk varchar, sat_rows number, sat_max_ldts timestamp_ntz, raw_hash varchar,
    captured_at timestamp_ltz
);

create transient table if not exists {COUNT_SNAP} (
    run_id varchar, phase varchar, project varchar, satellite varchar, row_count number,
    captured_at timestamp_ltz
);""")])


def cdc_procedure(project):
    test_raw = "BAGIC_PREPROD_CURATED_DB.UTILS" if project == "OPUS" else None
    force = (f"Optional (test RAW {test_raw} only): UPDATE one payload column of a few sampled keys so H1 has "
             f"changed keys to prove -- e.g. pick hkeys from the BEFORE rows of {SNAP}." if test_raw else
             "MAXIMUS RAW is the production mirror -- do NOT modify it. Let one normal load cycle land source "
             "changes between BEFORE and AFTER; a satellite whose sample saw no change reports NOT TESTED.")
    steps = f"""-- Step 1 (BEFORE): set the run id once and capture every satellite
-- PARALLEL RUNS: replace <M#> with your member tag (M1 / M2 / M3) so the three testers
-- get distinct run_ids and never mix snapshots in the shared UTILS.DM_H_CDC_SNAPSHOT.
set DM_H_RUN = 'CDC_{project}_<M#>_' || to_char(current_timestamp(), 'YYYYMMDD_HH24MI');
set DM_H_PHASE = 'BEFORE';
-- now run every "(b) CDC capture" statement of YOUR assigned satellites

-- Step 2: source changes land ({'forced or natural' if test_raw else 'natural only'}), then run the dbt load:
--   dbt run --select <your assigned satellites only>
--   PARALLEL RUNS: do NOT dbt-run a satellite another member is running at the same time,
--   and do NOT edit a UTILS source table another member is editing. Serialize the dbt
--   load step if two members share a sat or source table (see DM-H_MEMBER_PLAN.md).

-- Step 3 (AFTER): same run id, capture again
set DM_H_PHASE = 'AFTER';
-- run every "(b) CDC capture" statement of your assigned satellites again

-- Step 4: run the "CDC result" section at the end of DM-H1 (changed keys) and DM-H2 (unchanged keys)"""
    return dict(project=project, hub="CDC before / after test procedure", status="Procedure",
                pass_criteria="see CDC result section", note=force, queries=[("Steps", steps)])


def cdc_result(project, check):
    if check == "DM-H1":
        cond, cols = "raw_changed", """count(*) as changed_keys,
       count_if(new_rows >= 1) as changed_with_new_row,
       count_if(new_rows < 1) as changed_without_new_row,
       iff(changed_keys = 0, 'NOT TESTED (no source change in sample)', iff(changed_without_new_row = 0, 'PASS', 'FAIL')) as status"""
        pc = "status = PASS for every satellite with changed keys (NOT TESTED = no change reached the sample)"
    else:
        cond, cols = "not raw_changed", """count(*) as unchanged_keys,
       count_if(new_rows = 0) as unchanged_no_new_row,
       count_if(new_rows <> 0) as unchanged_with_new_row,
       iff(unchanged_with_new_row = 0, 'PASS', 'FAIL') as status"""
        pc = "status = PASS for every satellite (0 new rows on unchanged keys)"
    sql = f"""with b as (select * from {SNAP} where run_id = $DM_H_RUN and phase = 'BEFORE' and project = '{project}'),
     a as (select * from {SNAP} where run_id = $DM_H_RUN and phase = 'AFTER'  and project = '{project}'),
     k as (
    select b.satellite, b.record_source, b.hkey, b.cdk,
           not equal_null(b.raw_hash, a.raw_hash) as raw_changed,
           a.sat_rows - b.sat_rows as new_rows
      from b join a
        on a.satellite = b.satellite and a.record_source = b.record_source
       and a.hkey = b.hkey and equal_null(a.cdk, b.cdk)
)
select '{project}' as project, satellite, record_source,
       {cols}
  from k
 where {cond}
 group by satellite, record_source
 order by iff(status = 'FAIL', 0, 1), satellite, record_source;"""
    return dict(project=project, hub="CDC result (all satellites)", status="Implemented", pass_criteria=pc,
                note=("Joins the BEFORE and AFTER captures of the same run id. raw_changed compares the normalised RAW "
                      "payload hash (same UPPER/TRIM/NULL rules as the HASHDIFF, so a case-only RAW edit is not a "
                      "change); new_rows = satellite rows added for the key between the captures."),
                queries=[("SQL query", sql)])


# ---------------------------------------------------------------------------------------
# DM-H2 (a): unchanged consecutive versions
# ---------------------------------------------------------------------------------------
def h2a(sat):
    _, hd = sat_hashdiff(sat)
    if sat.multi_active:
        sql = f"""with grp as (  -- one signature per loaded group (key, RECORD_SOURCE, LOAD_DATETIME)
    select {sat.pk}, RECORD_SOURCE, {sat.ldts},
           listagg({' || '.join(f"to_varchar({c})" for c in sat.cdk)} || ':' || to_varchar({hd}, 'HEX'), ',')
               within group (order by {', '.join(sat.cdk)}, {hd}) as sig
      from {sat.fq}
     where {project_scope(sat)}
     group by {sat.pk}, RECORD_SOURCE, {sat.ldts}
),
seq as (
    select *, lag(sig) over (partition by {sat.pk}, RECORD_SOURCE order by {sat.ldts}) as prev_sig from grp
)
select '{sat.project}' as project, '{sat.name}' as satellite,
       count(*) as versions, count_if(sig = prev_sig) as unchanged_reinserts,
       array_slice(array_agg(iff(sig = prev_sig, to_varchar({sat.pk}, 'HEX'), null)) within group (order by {sat.pk}), 0, 3) as examples,
       iff(unchanged_reinserts = 0, 'PASS', 'FAIL') as status
  from seq;"""
        how = "Multi-active: a version is the whole member set loaded at one LOAD_DATETIME; two consecutive identical sets = an unchanged group was re-inserted."
    else:
        psig = (f"md5(to_json(object_construct_keep_null({', '.join(f'{lit(c)}, {c}' for c in sorted(sat.payload))})))"
                if sat.object_cols else f"md5({' || '.join(f'coalesce(to_varchar({c}), {lit(chr(94) * 2)}) || {lit(chr(124) * 2)}' for c in sorted(sat.payload))})")
        sql = f"""with base as (
    select {sat.pk}, RECORD_SOURCE, {sat.ldts}, {hd},
           {psig} as payload_sig
      from {sat.fq}
     where {project_scope(sat)}
),
seq as (
    select *,
           lag({hd}) over (partition by {sat.pk}, RECORD_SOURCE order by {sat.ldts}) as prev_hashdiff,
           lag(payload_sig) over (partition by {sat.pk}, RECORD_SOURCE order by {sat.ldts}) as prev_payload_sig
      from base
)
select '{sat.project}' as project, '{sat.name}' as satellite,
       count(*) as versions,
       count_if({hd} = prev_hashdiff) as unchanged_reinserts,
       count_if(payload_sig = prev_payload_sig) as unchanged_payload_reinserts,
       array_slice(array_agg(iff({hd} = prev_hashdiff or payload_sig = prev_payload_sig, to_varchar({sat.pk}, 'HEX'), null))
                   within group (order by {sat.pk}), 0, 3) as examples,
       iff(unchanged_reinserts = 0 and unchanged_payload_reinserts = 0, 'PASS', 'FAIL') as status
  from seq;"""
        how = ("Consecutive versions of a key (per RECORD_SOURCE, by LOAD_DATETIME) must differ in HASHDIFF "
               "(unchanged_reinserts) AND in the stored payload itself (unchanged_payload_reinserts -- catches a "
               "HASHDIFF that hashes columns this satellite does not store, e.g. a shared stage).")
    return dict(project=sat.project, hub=sat.name, status="Implemented",
                pass_criteria="status = PASS", note=how + " " + A.sat_note(sat),
                queries=[("SQL query (a) -- unchanged consecutive versions (all rows of this project)", sql)])


# ---------------------------------------------------------------------------------------
# DM-H3: idempotent re-load
# ---------------------------------------------------------------------------------------
def h3a(sat):
    _, hd = sat_hashdiff(sat)
    grain = ", ".join([sat.pk] + list(sat.cdk) + ["RECORD_SOURCE", sat.ldts])
    sql = f"""with d as (
    select {grain}, count(*) as n, count(distinct {hd}) as hashdiffs
      from {sat.fq}
     where {project_scope(sat)}
     group by {grain}
    having count(*) > 1
)
select '{sat.project}' as project, '{sat.name}' as satellite,
       count_if(hashdiffs = 1)            as duplicate_row_groups,
       coalesce(sum(iff(hashdiffs = 1, n - 1, 0)), 0) as surplus_rows,
       count_if(hashdiffs > 1)            as same_ldts_different_payload_info,
       array_slice(array_agg(iff(hashdiffs = 1, to_varchar({sat.pk}, 'HEX'), null)) within group (order by {sat.pk}), 0, 3) as examples,
       iff(duplicate_row_groups = 0, 'PASS', 'FAIL') as status
  from d;"""
    return dict(project=sat.project, hub=sat.name, status="Implemented", pass_criteria="duplicate_row_groups = 0",
                note=(f"Grain ({grain}). duplicate_row_groups = the same version stored twice (what a non-idempotent "
                      f"re-run produces). same_ldts_different_payload_info = two different payloads at one "
                      f"LOAD_DATETIME (a source grain conflict, not a re-load duplicate) -- informational. ") + A.sat_note(sat),
                queries=[("SQL query (a) -- duplicate satellite rows (all rows of this project)", sql)])


def h3_reload(project, sats):
    union = "\n    union all ".join(
        f"select '{s.name}' as satellite, count(*) as row_count from {s.fq} where {project_scope(s)}" for s in sats)
    names = " ".join(s.path.stem for s in sats)
    capture = f"""-- Step 1: fix a load window that has ALREADY been loaded, e.g. yesterday
--   from_date = '<YYYY-MM-DD HH:MI:SS>'   to_date = '<YYYY-MM-DD HH:MI:SS>'
-- PARALLEL RUNS: replace <M#> with your member tag (M1 / M2 / M3) so the three testers
-- get distinct run_ids in the shared UTILS.DM_H_RELOAD_SNAPSHOT.
set DM_H_RUN = 'RELOAD_{project}_<M#>_' || to_char(current_timestamp(), 'YYYYMMDD_HH24MI');
set DM_H_PHASE = 'BEFORE';

insert into {COUNT_SNAP} (run_id, phase, project, satellite, row_count, captured_at)
select $DM_H_RUN, $DM_H_PHASE, '{project}', satellite, row_count, current_timestamp()
  from (
    {union}
  );

-- Step 2: re-run the SAME window (no new source data):
--   dbt run --select {names} --vars '{{from_date: "<from>", to_date: "<to>"}}'

-- Step 3: capture again
set DM_H_PHASE = 'AFTER';
-- re-run the INSERT above"""
    result = f"""select b.project, b.satellite, b.row_count as rows_before, a.row_count as rows_after,
       a.row_count - b.row_count as rows_added,
       iff(rows_added = 0, 'PASS', 'FAIL') as status
  from {COUNT_SNAP} b
  join {COUNT_SNAP} a
    on a.run_id = b.run_id and a.satellite = b.satellite and a.phase = 'AFTER'
 where b.run_id = $DM_H_RUN and b.phase = 'BEFORE' and b.project = '{project}'
 order by iff(status = 'FAIL', 0, 1), b.satellite;"""
    return [
        dict(project=project, hub="Re-load test: capture row counts", status="Procedure", pass_criteria="n/a",
             note=("Re-runs a window that is already loaded: the from_date / to_date vars pin sat_multi_source / "
                   "stitch_incremental to the same rows, so an idempotent load inserts nothing. Run the DM-H1 "
                   "set-up section first (creates the snapshot table)."),
             queries=[("Steps + SQL", capture)]),
        dict(project=project, hub="Re-load test: result", status="Implemented", pass_criteria="rows_added = 0 for every satellite",
             note="Compares the BEFORE / AFTER row counts of the same run id.", queries=[("SQL query", result)]),
    ]


# ---------------------------------------------------------------------------------------
# DM-H4: current view on the most recently loaded keys
# ---------------------------------------------------------------------------------------
def recent_sample(sat, gi, g):
    return (f"s{gi} as (  -- the {A.SAMPLE_N} most recently loaded keys of this RECORD_SOURCE (latest changes)\n"
            f"    select {sat.pk} as hkey from {sat.fq}\n"
            f"     where {g.rs_filter}\n"
            f"     group by {sat.pk}\n"
            f"     order by max({sat.ldts}) desc, hkey\n"
            f"     limit {A.SAMPLE_N}\n)")


def h4(sat):
    return A.a2_section(sat, sample=recent_sample, check="DM-H4",
                        extra_note=("Same comparison as DM-A2 (latest satellite row vs the latest RAW record, model "
                                    "logic recomputed from RAW) but the sample is the most recently loaded keys, i.e. "
                                    "the keys that just changed -- where a stale current row would show. "))


# ---------------------------------------------------------------------------------------
COMMON = [("Owner", "LUMIQ"), ("Vault location", K.VAULT)] + K.COMMON_OVERVIEW[2:] + [
    ("Scope", "Every standard + augmented satellite of the project; rows scoped by the project's RECORD_SOURCE prefix."),
    ("Snapshot schema (b)", f"{VALIDATION_SCHEMA} -- tables DM_H_CDC_SNAPSHOT / DM_H_RELOAD_SNAPSHOT (transient)."),
]
CHECKS = OrderedDict([
    ("DM-H1", dict(
        title="DM-H1  |  History Checks — Change Creates a New Satellite Row",
        subtitle="A record changed in the SF Mirror source creates a new satellite row. Pass criterion: new sat row on change.",
        overview=[("Check ID", "DM-H1"), ("Category", "History checks"), ("Sign-off criterion", "Change creates a new satellite row"),
                  ("Method", "(a) HASHDIFF integrity on every row; (b) before / after CDC capture of sampled keys around a dbt load"),
                  ("Evidence required", "Before/after CDC test evidence"),
                  ("Pass criteria / tolerance", "New sat row on change")] + COMMON)),
    ("DM-H2", dict(
        title="DM-H2  |  History Checks — No Change Creates No New Row",
        subtitle="An unchanged record creates no new satellite row. Pass criterion: no new row when unchanged.",
        overview=[("Check ID", "DM-H2"), ("Category", "History checks"), ("Sign-off criterion", "No change creates no new row"),
                  ("Method", "(a) no consecutive versions with the same HASHDIFF; (b) unchanged keys of the DM-H1 CDC capture got 0 new rows"),
                  ("Evidence required", "Re-load CDC test evidence"),
                  ("Pass criteria / tolerance", "No new row when unchanged")] + COMMON)),
    ("DM-H3", dict(
        title="DM-H3  |  History Checks — Idempotent Re-load",
        subtitle="Re-running the same load does not create duplicate satellite rows. Pass criterion: no duplicate rows on re-run.",
        overview=[("Check ID", "DM-H3"), ("Category", "History checks"), ("Sign-off criterion", "Idempotent re-load"),
                  ("Method", "(a) duplicate-version query on every satellite; (b) re-run an already-loaded window and compare row counts"),
                  ("Evidence required", "Repeat-run comparison evidence"),
                  ("Pass criteria / tolerance", "No duplicate rows on re-run")] + COMMON)),
    ("DM-H4", dict(
        title="DM-H4  |  History Checks — Current-view Correctness",
        subtitle="The latest (current) satellite row per key matches the latest source record. Pass criterion: latest sat row = latest source.",
        overview=[("Check ID", "DM-H4"), ("Category", "History checks"), ("Sign-off criterion", "Current-view correctness"),
                  ("Method", "Latest satellite row vs latest RAW record (model logic recomputed from RAW) for the most recently loaded keys"),
                  ("Evidence required", "Current-record comparison sample"),
                  ("Pass criteria / tolerance", "Latest sat row = latest source")] + COMMON)),
])


def before_part_b(project, check):
    """Remarks shown at the top of the DM-H1..H3 documents (the checks that have a part (b))."""
    if project == "MAXIMUS":
        raw = ("MAXIMUS RAW (BAGIC_PROD_MIRROR_DB.MAXI_RAW) is the production mirror -- do NOT edit it. Let one "
               "normal load cycle bring source changes in between the BEFORE and AFTER captures. A satellite whose "
               "sample received no change reports 'NOT TESTED' in DM-H1 (b) rather than PASS.")
    else:
        raw = ("OPUS test RAW (BAGIC_PREPROD_CURATED_DB.UTILS) may be edited to force a change: between BEFORE and "
               "AFTER, UPDATE a payload column of a few keys captured in the BEFORE snapshot, then run the load. "
               "Without a change in the sample, DM-H1 (b) reports 'NOT TESTED' rather than PASS.")
    items = [
        ("Scratch schema", f"Part (b) writes snapshots to {VALIDATION_SCHEMA} (tables DM_H_CDC_SNAPSHOT and "
                           f"DM_H_RELOAD_SNAPSHOT). The running role needs CREATE SCHEMA / CREATE TABLE / INSERT on "
                           f"it. The name is a placeholder: change VALIDATION_SCHEMA in validation/tools/gen_dm_h.py and "
                           f"regenerate to use another schema."),
        ("Source changes", raw),
        ("Unconfirmed Snowflake syntax", "The capture statements use INSERT INTO ... WITH ... SELECT and session "
                                         "variables ($DM_H_RUN, $DM_H_PHASE). Both are expected to work in Snowflake "
                                         "but were not executed when this document was generated; report any error "
                                         "so the generator can be fixed."),
        ("Order of work", "Run the set-up section once, then the BEFORE capture, then the dbt load, then the AFTER "
                          "capture, then the result section. Keep the same session (or re-SET $DM_H_RUN to the same "
                          "value) so BEFORE and AFTER share one run id."),
    ]
    if check == "DM-H3":
        items[1] = ("Re-load window", "DM-H3 (b) re-runs a window that is ALREADY loaded (from_date / to_date vars) "
                                      "with no new source data; no RAW edit is needed or wanted.")
    return [("Before running part (b)", items)]


def main():
    # Styles template for the generated .docx. Prefer the canonical DM-K4 template; if it
    # is absent, fall back to any existing generated .docx (same base styling).
    tpl_path = K.TEMPLATE_DOCX
    if not tpl_path.exists():
        from pathlib import Path as _P
        fallbacks = sorted(_P(K.VALIDATION).glob("DM-*/DM-*.docx"))
        tpl_path = fallbacks[0] if fallbacks else None
    template = tpl_path.read_bytes() if tpl_path is not None else None
    if template is None:
        print("WARNING: no docx template found -- writing .sql only, skipping .docx")
    else:
        print(f"docx template: {tpl_path}")
    sats = A.build_sats()
    sats.sort(key=lambda s: (s.project != "MAXIMUS", s.layer != "standard", s.name))
    for pj, md in A.PROJECTS:
        ps = selected_sats([s for s in sats if s.project == pj], pj)
        live = [s for s in ps if s.applicable]
        revision = [
            f"Generated 2026-10-13 from the current {md.parent.name} models by validation/tools/gen_dm_h.py "
            f"(satellite lineage from gen_dm_a.py).",
            f"TRIMMED to the DM-H member test plan (see validation/DM-H/DM-H_MEMBER_PLAN.md): {pj} has "
            f"{len(ps)} assigned satellites in this file ({len(live)} with mapped payload). Each sat is "
            f"prefixed with its [member | macro-path]. If an assigned sat has 0 rows, swap it for a same-path "
            f"sat from DM-H_REMAINING.md (confirm counts with DM-H_ROWCOUNT_CHECK.sql).",
            "Static queries (a) run on the data already loaded; the (b) procedures need a dbt load between a "
            "BEFORE and an AFTER capture and write to the snapshot schema.",
            "Sections marked NA load only hard-coded NULL padding or a disabled placeholder.",
        ]
        for cid, meta in CHECKS.items():
            if cid == "DM-H1":
                sections = [cdc_setup(), cdc_procedure(pj)]
                for s in ps:
                    sec = h1a(s)
                    sec["hub"] = plan_tag(s) + sec["hub"]
                    # Relabel the static (a) query as STEP 1 for a clear per-model sequence.
                    if sec["queries"]:
                        a_label, a_sql = sec["queries"][0]
                        sec["queries"][0] = (
                            "STEP 1 (static, run anytime) -- HASHDIFF integrity. PASS here = the change-detection "
                            "fingerprint is sound. " + a_label, a_sql)
                    cap = cdc_capture(s) if s.applicable else None
                    if cap and sec["status"] != "NA":
                        sec["queries"].append(
                            ("STEP 2 (BEFORE) -- set $DM_H_RUN (with your <M#>) and $DM_H_PHASE='BEFORE', then run "
                             "this CDC capture. Re-run it again in STEP 6 after setting phase to AFTER.", cap))
                        bkq = bk_map_query(s)
                        if bkq:
                            sec["queries"].append(
                                ("STEP 3 (pick a key) -- map a sampled BEFORE hkey to its RAW business key. Copy one "
                                 "business_key value to use in STEP 4.", bkq))
                        fcq = force_change_query(s)
                        if fcq:
                            sec["queries"].append(
                                ("STEP 4 (force the change) -- fill <BK> from STEP 3, run this UPDATE in UTILS. "
                                 "STEP 5: dbt run --select this sat. STEP 6: set phase='AFTER' and re-run STEP 2.", fcq))
                        sec["queries"].append(
                            ("STEP 7 (result for THIS sat) -- after AFTER capture, run this. PASS = every changed "
                             "key got >= 1 new row; NOT TESTED = no change reached the sample.",
                             cdc_result_for_sat(s)))
                    sections.append(sec)
                res = cdc_result(pj, cid)
                res["hub"] = "STEP 7 -- " + res["hub"]
                sections.append(res)
            elif cid == "DM-H2":
                sections = []
                for s in ps:
                    sec = h2a(s); sec["hub"] = plan_tag(s) + sec["hub"]; sections.append(sec)
                sections.append(cdc_result(pj, cid))
            elif cid == "DM-H3":
                ps3 = selected_sats_h3([s for s in sats if s.project == pj], pj)
                sections = []
                for s in ps3:
                    sec = h3a(s); sec["hub"] = h3_tag(s) + sec["hub"]; sections.append(sec)
                sections += h3_reload(pj, ps3)
            else:
                sections = []
                for s in ps:
                    sec = h4(s); sec["hub"] = plan_tag(s) + sec["hub"]; sections.append(sec)
            pmeta = dict(meta, title=f"{meta['title']}  ({pj})", overview=meta["overview"] + [("Project in this file", pj)])
            fid = f"{cid}_{pj}"
            rev = revision
            if cid == "DM-H3":
                n3 = len(selected_sats_h3([s for s in sats if s.project == pj], pj))
                rev = [revision[0],
                       f"DM-H3 (idempotent re-load) is trimmed to ONE satellite per macro path for {pj} "
                       f"({n3} satellites here). Idempotency behaves identically for every sat built by a "
                       f"given macro, so one representative per macro is sufficient. Each sat is prefixed "
                       f"with its [macro-path].",
                       revision[2], revision[3]]
            K.write_sql(fid, pmeta, sections, rev)
            if template is not None:
                A.write_docx(fid, pmeta, sections, rev, template,
                             preface=before_part_b(pj, cid) if cid != "DM-H4" else None)
            print(f"{fid}: {len(sections)} sections, {sum(x['status'] == 'NA' for x in sections)} NA")


if __name__ == "__main__":
    main()
