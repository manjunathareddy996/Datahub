#!/usr/bin/env python3
"""
Travel LOB equivalent of gen_dm_a.py.

Points at opus_travel_dv_dbt + maximus_travel_v2_dv_dbt and writes under
BGIL_DBT/validation/travel/DM-A/. Reuses the partner gen_dm_a helpers and
hooks a few resolvers to cope with travel-specific shapes:

- OPUS travel: stg_travel__ staging and the plain-join
  stitch_risk_person_travel_trip_attrs. Non-macro stitches cannot be
  parsed as a `sources = [...]` jinja literal, so their payload columns
  that come from the joined-in parent are reported as skipped (first-cut).
- MAXIMUS travel v2: each satellite's source_model is a satfeed_mtv2_
  view that unions many stg2_mtv2__ views. The satfeed renames
  HASHDIFF_<SAT> back to the bare HASHDIFF the ma_sat / sat macro expects.
  stg2s often read from a resolved_mtv2__ view (base stg_mtv2__ + walk
  columns). For the first pass, walk columns are reported as unresolved
  on a per-column basis (the branch's base RAW table is still used).

    python3 BGIL_DBT/validation/tools/gen_dm_a_travel.py
"""
import re
import sys
from collections import OrderedDict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import gen_dm_k_travel as K  # noqa: E402  -- also patches gen_dm_k module
import gen_dm_a as A  # noqa: E402
import gen_dm_k as PK  # noqa: E402

VALIDATION = K.VALIDATION
VAULT = K.VAULT
SAMPLE_N = A.SAMPLE_N

# Point A's module-level state at travel.
PROJECTS = [("MAXIMUS", K.MAXI), ("OPUS", K.OPUS)]
A.PROJECTS = PROJECTS
A.VALIDATION = VALIDATION
A.VAULT = VAULT
A.RAW_INFO = {
    "MAXIMUS": K.RAW_SCHEMA["maximus_travel_v2_raw"].split("."),
    "OPUS": K.RAW_SCHEMA["travel_raw"].split("."),
}
A.VAULT_DB, A.VAULT_SCHEMA = VAULT.split(".")
MD = dict(PROJECTS)


# ---------------------------------------------------------------------------
# Resolver patch: handle satfeed / hubfeed / lnkfeed (no yaml_metadata,
# union-all over wrappers with a trailing where), stg2s whose source is a
# resolved_mtv2__ view, and non-macro OPUS stitches (plain joins).
# ---------------------------------------------------------------------------
_ORIG_RESOLVE = A.resolve


def _parse_feed_branch_wrapper(part_sql):
    """Parse one union-all branch of a satfeed/hubfeed/lnkfeed view.

    Returns (ref_name, rename_map, where_or_None). rename_map maps every
    output column name (lowercased) to the stg2 column it reads from.
    The trailing `where <col> is not null` is captured but ignored here
    (the stg2 inner lookup already handles nullability of its own cols).
    """
    body = A.strip_sql_comments(part_sql)
    ref_m = re.search(r"ref\('([^']+)'\)", body)
    if not ref_m:
        return None
    sel_start = re.search(r"\bselect\b", body, re.I).end()
    frm = re.search(r"\bfrom\s*\{\{", body, re.I)
    rename = {}
    for item in A.split_top(body[sel_start:frm.start()]):
        item = item.strip()
        m = re.match(r"(?s)^(.+?)\s+as\s+([A-Za-z0-9_]+)$", item, re.I)
        if m:
            src, out = m.group(1).strip(), m.group(2)
        else:
            src = out = item
        rename[out.lower()] = src.lower()
    w = re.search(r"\}\}\s*where\b(.*)$", body, re.S | re.I)
    where = w.group(1).strip() if w else None
    return ref_m.group(1), rename, where


def _resolved_source(md, name):
    """Return (raw_fq_table, {col: raw_expr}, walks) for a stg_ or
    resolved_mtv2__ view. walks only populated for resolved views."""
    if name.startswith("resolved_mtv2__"):
        base_stg, walks = K.parse_resolved(md, name)
        raw, cols = PK.parse_stg(md, base_stg)
        # Walk columns are not resolvable from the base RAW table; mark
        # them with a sentinel so Lookup.get() returns None for them
        # (they'll appear in unresolved).
        return raw, dict(cols), walks
    raw, cols = PK.parse_stg(md, name)
    return raw, dict(cols), {}


def _resolve_stg2(md, name):
    """Resolve a stg2 (yaml-backed wide stage) to a list of A.Arm."""
    try:
        sql = PK.read(PK.find_model(md, name))
    except SystemExit as e:
        raise RuntimeError(f"missing model {name}: {e}")
    meta = PK.yaml_block(sql)
    dc = meta.get("derived_columns") or {}
    hc = meta.get("hashed_columns") or {}
    src = meta["source_model"]
    if isinstance(src, list):
        src = src[0]
    # stitch (OPUS macro-driven) still works via partner path.
    if src.startswith("stitch_"):
        try:
            # partner's parse_stitch expects jinja `sources` literal.
            return _ORIG_RESOLVE(md, name)
        except Exception:
            # non-macro plain join stitch (travel): fall back to its
            # first ref'd stg_ as the base.
            return _resolve_plain_stitch_stg2(md, name, dc, hc, src)
    if src.startswith("unpivot") or src.startswith("up_mtv2__"):
        arms = []
        for i, a in enumerate(A.parse_unpivot_arms(md, src)):
            try:
                raw, cols, walks = _resolved_source(md, a["ref"])
            except Exception:
                continue
            base = {k: A.subst(A.lower_idents(v), cols) for k, v in a["cols"].items()}
            where = A.subst(A.lower_idents(a["where"]), cols) if a["where"] else None
            arms.append(A.Arm("unpivot", A.Lookup(dc, hc, base), raw=raw,
                              where=where, label=f"{src}#{i + 1}"))
        return arms
    # Plain stg_ or resolved_mtv2__ as source.
    try:
        raw, cols, walks = _resolved_source(md, src)
    except (SystemExit, Exception) as e:
        raise RuntimeError(f"{name}: cannot resolve source_model {src} ({e})")
    return [A.Arm("stg", A.Lookup(dc, hc, cols), raw=raw, label=src)]


def _resolve_plain_stitch_stg2(md, name, dc, hc, stitch_name):
    """Fallback for a stg2 whose source_model is a plain-join stitch
    (non-macro). Treat the stitch as a thin wrapper over its first ref'd
    stg_, with all other joined-in columns reported as unresolved. The
    sat note documents the limitation.
    """
    stitch_sql = A.strip_sql_comments(PK.read(PK.find_model(md, stitch_name)))
    refs = re.findall(r"ref\('([^']+)'\)", stitch_sql)
    if not refs:
        raise SystemExit(f"{stitch_name}: no refs")
    base_stg = refs[0]
    raw, cols = PK.parse_stg(md, base_stg)
    # Any column of the stitch that comes from the joined-in parent will
    # not be in `cols`; Lookup.get() will return None for it and the
    # calling code marks it as unresolved.
    return [A.Arm("stg", A.Lookup(dc, hc, dict(cols)), raw=raw,
                  label=f"{stitch_name} (plain-join; joined columns unresolved)")]


def _resolve_feed(md, name):
    """Resolve a satfeed/hubfeed/lnkfeed view: union-all over stg2 wrappers.
    Returns a flat list of A.Arm objects, each wrapped with the branch's
    rename map so the outer caller sees the sat's column names.
    """
    try:
        sql = PK.read(PK.find_model(md, name))
    except SystemExit as e:
        raise RuntimeError(f"missing feed model {name}: {e}")
    body = A.strip_sql_comments(sql)
    parts = re.split(r"\bunion\s+all\b", body, flags=re.I)
    out = []
    for part in parts:
        if "ref(" not in part:
            continue
        parsed = _parse_feed_branch_wrapper(part)
        if not parsed:
            continue
        ref, rename, _where = parsed
        try:
            arms = _resolve_stg2(md, ref)
        except (RuntimeError, SystemExit, Exception):
            continue  # one bad feeder branch does not sink the whole feed
        for a in arms:
            out.append(a.wrap(rename))
    return out


def resolve_travel(md, name):
    """Travel-aware A.resolve. Handles satfeed/hubfeed/lnkfeed first, then
    stg2 (yaml-backed), falling back to partner's logic for everything else.
    """
    if name.startswith(("satfeed_mtv2_", "hubfeed_mtv2_", "lnkfeed_mtv2_")):
        return _resolve_feed(md, name)
    try:
        PK.yaml_block(PK.read(PK.find_model(md, name)))
    except (ValueError, SystemExit):
        # Thin wrapper over a stg2.
        try:
            return _ORIG_RESOLVE(md, name)
        except Exception as e:
            raise SystemExit(f"{name}: cannot resolve non-yaml wrapper ({e})")
    return _resolve_stg2(md, name)


A.resolve = resolve_travel


# ---------------------------------------------------------------------------
# build_sats: identical shape to partner's, re-using patched A.resolve.
# Catches per-model errors so the generator reports them as skipped and
# keeps going rather than aborting.
# ---------------------------------------------------------------------------
def build_sats_travel():
    sats = []
    for project, md in PROJECTS:
        for path in sorted(md.glob("raw_vault/*/satellites/*.sql")):
            try:
                s = A.Sat(project, path)
            except Exception as e:
                print(f"  SKIP sat {path.name}: {e}")
                continue
            for src in s.sources:
                try:
                    ssql = PK.read(PK.find_model(md, src))
                except SystemExit as e:
                    s.skipped.append(f"{src}: {e}")
                    continue
                if PK.is_disabled(ssql):
                    s.skipped.append(f"{src}: disabled placeholder (enabled=false)")
                    continue
                try:
                    arms = resolve_travel(md, src)
                except (RuntimeError, SystemExit, Exception) as e:
                    s.skipped.append(f"{src}: resolver error ({e})")
                    continue
                if not arms:
                    s.skipped.append(f"{src}: resolver returned 0 arms")
                    continue
                mapped = [c.upper() for c in (
                    s.col_map.get(src, s.payload) if s.col_map else s.payload)]
                lk = arms[0].lookup
                # Grouping key: for satfeed-backed MAXIMUS sats each arm already
                # carries its own stg2 record_source via the inner lookup -- treat
                # each arm as its own RECORD_SOURCE group so SQL sections match the
                # stg2 the row came from (as partner does for unpivot arms).
                if any(a.kind == "stitch" for a in arms):
                    # Keep partner's stitch grouping intact.
                    st = next(a.stitch for a in arms if a.kind == "stitch")
                    tags = sorted({x["source_tag"] for x in st["sources"]})
                    alt = "|".join(re.escape(t) for t in tags)
                    key = "STITCH:" + st["name"]
                    g = s.groups.setdefault(
                        key, A.Group(f"{st['name']} ({len(tags)} tables)",
                                      f"regexp_like(RECORD_SOURCE, '^({alt})(, ({alt}))*$')"))
                    g.feeds.append(src)
                    for a in arms:
                        g.arms.append(a)
                    for c in mapped:
                        if c in g.cols:
                            continue
                        exprs = [a.lookup.get(c) for a in arms]
                        if all(e is None or A.is_null_expr(e) for e in exprs):
                            continue
                        if any(e is None for e in exprs):
                            s.unresolved.setdefault(src, []).append(c)
                            continue
                        g.cols.append(c)
                    continue
                # Multi-arm feed (satfeed) or single-arm (OPUS). For each arm,
                # read its RECORD_SOURCE literal and group separately.
                for a in arms:
                    rs = a.lookup.get("record_source")
                    if not (rs and re.fullmatch(r"'[^']*'", rs)):
                        s.skipped.append(
                            f"{src}: RECORD_SOURCE not a constant on an arm "
                            f"({rs}) -- not traced")
                        continue
                    rsv = rs.strip("'")
                    g = s.groups.setdefault(
                        rsv, A.Group(rsv, f"RECORD_SOURCE = '{rsv}'", rsv))
                    if src not in g.feeds:
                        g.feeds.append(src)
                    g.arms.append(a)
                    for c in mapped:
                        if c in g.cols:
                            e = a.lookup.get(c)
                            continue  # already in this group
                        e = a.lookup.get(c)
                        if e is None or A.is_null_expr(e):
                            continue
                        g.cols.append(c)
                    # Second pass: unresolved columns on this group (anything that
                    # the arm maps but another arm doesn't, which drives per-group
                    # column coverage in A2).
                    for c in mapped:
                        if c in g.cols:
                            continue
                        e = a.lookup.get(c)
                        if e is None:
                            s.unresolved.setdefault(src, []).append(c)
            for src, cols in s.unresolved.items():
                uniq = sorted(set(cols))
                s.notes.append(
                    f"{src}: column(s) {', '.join(uniq)} could not be traced to RAW "
                    f"on at least one arm -- excluded (first-cut: walk columns from "
                    f"resolved_mtv2__ views or joined-in stitch columns are not yet "
                    f"inlined into the sampled queries).")
            s.notes = list(OrderedDict.fromkeys(s.notes))
            sats.append(s)
    return sats


# ---------------------------------------------------------------------------
# Writers
# ---------------------------------------------------------------------------
COMMON = [
    ("Owner", "LUMIQ"),
    ("Vault location", VAULT),
    ("Maximus Travel V2 RAW", K.RAW_SCHEMA["maximus_travel_v2_raw"]),
    ("Opus Travel RAW (prod)", K.RAW_SCHEMA["travel_raw"]),
    ("Opus Travel RAW (test)", K.RAW_SCHEMA["travel_test_raw"]),
    ("Scope", "Every standard + augmented satellite of opus_travel_dv_dbt and "
              "maximus_travel_v2_dv_dbt, one section per project-satellite. "
              "Satellite rows are scoped by the RECORD_SOURCE each feed writes."),
    ("Sample", f"Deterministic: the first {SAMPLE_N} keys per RECORD_SOURCE "
               f"ordered by hash key."),
    ("Shared vault note",
     "Travel satellites write the SAME physical tables as the partner build. "
     "DM-A row scopes use the RECORD_SOURCE string values the travel feeds "
     "actually write; a MAXIMUS_ / OPUS_ prefix would overlap with the partner build."),
]

CHECKS = OrderedDict([
    ("DM-A1", dict(
        title="DM-A1  |  Attribute Checks \u2014 Data Type & Format Preserved (Travel LOB)",
        subtitle="Dates, decimals and trailing spaces not truncated or altered on load. Pass criterion: types & formats match source.",
        overview=[("Check ID", "DM-A1"), ("Category", "Attribute checks"),
                  ("Sign-off criterion", "Data type & format preserved"),
                  ("Method", "(a) per project: RAW column type / length / scale vs "
                             "satellite column (INFORMATION_SCHEMA); "
                             "(b) per satellite: sampled satellite values vs the "
                             "UNTRANSFORMED RAW value, each difference classified"),
                  ("Pass criteria / tolerance", "Types & formats match source")] + COMMON)),
    ("DM-A2", dict(
        title="DM-A2  |  Attribute Checks \u2014 Record-level Reconciliation (Sample, Travel LOB)",
        subtitle="For an agreed sample of business keys, every satellite attribute equals the SF Mirror source value.",
        overview=[("Check ID", "DM-A2"), ("Category", "Attribute checks"),
                  ("Sign-off criterion", "Record-level attribute reconciliation (sample)"),
                  ("Method", "Latest satellite row per sampled key vs the model's own "
                             "column expression recomputed from RAW, compared with "
                             "EQUAL_NULL on VARCHAR"),
                  ("Pass criteria / tolerance", "100% match on the sample")] + COMMON)),
])


def main():
    template = K.TEMPLATE_DOCX.read_bytes() if K.TEMPLATE_DOCX else None
    (VALIDATION / "DM-A").mkdir(parents=True, exist_ok=True)
    sats = build_sats_travel()
    sats.sort(key=lambda s: (s.project != "MAXIMUS", s.layer != "standard", s.name))
    for pj, md in PROJECTS:
        psats = [s for s in sats if s.project == pj]
        n_app = sum(1 for s in psats if s.applicable)
        n_grp = sum(len(s.groups) for s in psats)
        n_cols = sum(len(g.cols) for s in psats for g in s.groups.values())
        revision = [
            f"Travel LOB generated 2026-10-13 from the current {md.parent.name} "
            f"models by validation/tools/gen_dm_a_travel.py (reuses the gen_dm_k_travel "
            f"staging parser and hash formula).",
            f"This file: {pj} only ({len(psats)} satellites, standard + augmented); "
            f"{n_app} have mapped payload, {n_grp} RECORD_SOURCE groups, {n_cols} "
            f"mapped (group, column) pairs.",
            "Lineage handled: stg_ direct, Maximus Travel V2 stg2 over "
            "resolved_mtv2__ (base stg_mtv2__ + walk columns -- walk columns are "
            "reported as unresolved in the first cut), Maximus Travel V2 satfeed "
            "unions (bare HASHDIFF rename), unpivot arms, OPUS plain-join stitches "
            "(joined-in columns reported as unresolved in the first cut).",
            "Sections marked NA load only hard-coded NULL padding, a disabled "
            "placeholder, or every arm resolved to zero columns.",
        ]
        for cid, meta in CHECKS.items():
            if cid == "DM-A1":
                sections = [A.a1_meta_section(pj, psats)] + [A.a1_section(s) for s in psats]
            else:
                sections = [A.a2_section(s) for s in psats]
            pmeta = dict(meta, title=f"{meta['title']}  ({pj})",
                         overview=[(k, v) for k, v in meta["overview"]] +
                                  [("Project in this file", pj)])
            fid = f"{cid}_{pj}"
            PK.write_sql(fid, pmeta, sections, revision)
            if template is not None:
                A.write_docx(fid, pmeta, sections, revision, template)
            print(f"{fid}: {len(sections)} sections, "
                  f"{sum(x['status'] == 'NA' for x in sections)} NA")


if __name__ == "__main__":
    main()
