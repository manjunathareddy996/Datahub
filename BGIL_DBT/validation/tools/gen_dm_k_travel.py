#!/usr/bin/env python3
"""
Travel LOB equivalent of gen_dm_k.py.

Points at opus_travel_dv_dbt + maximus_travel_dv_dbt and writes under
BGIL_DBT/validation/travel/DM-K/. Reuses every helper from gen_dm_k.py
(hash formula, DOCX writer, SQL writer, Branch / Hub classes). Only the
Opus / Maximus hub walkers are travel-specific:

- OPUS travel staging prefix is stg_travel__ (not stg_partner__).
- MAXIMUS travel hubs point at hubfeed_mt_* (single string). Each
  hubfeed branch references a stg2_mt__ which reads from either a
  stg_mt__ (direct), a resolved_mt__ view (base stg_mt__ + walk
  columns), or a stg2_mt_up__ wrapper over an up_mt__ unpivot.

Scoping (DM-K2 / DM-R / DM-T): travel reuses the MAXIMUS_ / OPUS_
RECORD_SOURCE prefixes with partner, so a bare startswith('<prefix>_')
is NOT safe. For each hub we also parse the set of RECORD_SOURCE string
values the travel feeds actually write, and surface it as
``hub.record_sources`` -- downstream generators scope hub rows by
``RECORD_SOURCE in (<parsed set>)`` instead of a prefix.

    python3 BGIL_DBT/validation/tools/gen_dm_k_travel.py
"""
import re
import sys
from collections import OrderedDict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import gen_dm_k as PK  # noqa: E402

HERE = Path(__file__).resolve().parent
VALIDATION_ROOT = HERE.parent         # BGIL_DBT/validation
ROOT = VALIDATION_ROOT.parent         # BGIL_DBT
VALIDATION = VALIDATION_ROOT / "travel"
OPUS = ROOT / "opus_travel_dv_dbt" / "models"
MAXI = ROOT / "maximus_travel_dv_dbt" / "models"

# Expose for downstream travel generators (gen_dm_a_travel etc).
VAULT = PK.VAULT
GHOST_HKEY = PK.GHOST_HKEY
HASH_TXT = PK.HASH_TXT

# Extend partner's RAW_SCHEMA map with travel source names (keys match
# the first argument of source('<name>', '<TABLE>') in travel stg_ files).
RAW_SCHEMA = dict(PK.RAW_SCHEMA)
RAW_SCHEMA.update({
    # Opus travel prod (from dbt_project.yml var defaults).
    "travel_raw": "BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE",
    # Opus travel dev / test (overridden by profile).
    "travel_test_raw": "BAGIC_PREPROD_CURATED_DB.UTILS",
    # Maximus Travel.
    "maximus_travel_raw": "RAW.MAXIMUS_TRAVEL",
})

# Redirect helpers (parse_stg, write_sql / write_docx, out_dir, hub_meta)
# to the travel locations. gen_dm_k.py keeps its own module-level constants
# untouched if someone later runs the partner generator in the same process.
PK.RAW_SCHEMA = RAW_SCHEMA
PK.VALIDATION = VALIDATION
PK.OPUS = OPUS
PK.MAXI = MAXI

# Pick a docx styles template. The partner suite ships several -- any of
# them has the styles we need. Prefer DM-K4 if a sibling has it, else fall
# back to the first partner docx we find.
_tpl_candidates = list(VALIDATION_ROOT.glob("partner/DM-*/*.docx"))
TEMPLATE_DOCX = _tpl_candidates[0] if _tpl_candidates else None
if TEMPLATE_DOCX is not None:
    PK.TEMPLATE_DOCX = TEMPLATE_DOCX


# ---------------------------------------------------------------------------
# Resolved-view parser: resolved_mt__X = stg_mt__X + walk columns.
# ---------------------------------------------------------------------------
_resolved_cache = {}


def parse_resolved(models_dir, name):
    """(base_stg_name, {walk_col: {'parent_stg': ..., 'parent_col': ...}})."""
    key = (models_dir, name)
    if key in _resolved_cache:
        return _resolved_cache[key]
    sql = PK.read(PK.find_model(models_dir, name))
    base = re.search(r"from\s*\{\{\s*ref\('([^']+)'\)\s*\}\}\s+b\b", sql)
    if not base:
        raise ValueError(f"{name}: no 'from {{{{ ref(..) }}}} b' found")
    walks = {}
    # left join {{ ref('stg_mt__X') }} <alias> on <alias>.<pcol> = b.<bcol>
    join_re = re.compile(
        r"left\s+join\s*\{\{\s*ref\('([^']+)'\)\s*\}\}\s+([A-Za-z0-9_]+)\s+on\s+"
        r"\2\.[A-Za-z0-9_]+\s*=\s*b\.[A-Za-z0-9_]+", re.I)
    joins = {m.group(2): m.group(1) for m in join_re.finditer(sql)}
    # select b.*, <alias>.<pcol> as <walk_name>
    walk_re = re.compile(r"([A-Za-z0-9_]+)\.([A-Za-z0-9_]+)\s+as\s+([A-Za-z0-9_]+)", re.I)
    for alias, pcol, walk_name in walk_re.findall(sql):
        if alias in joins:
            walks[walk_name.lower()] = {"parent_stg": joins[alias], "parent_col": pcol.lower()}
    _resolved_cache[key] = (base.group(1), walks)
    return _resolved_cache[key]


def parse_stg_or_resolved(models_dir, name, skipped=None, via=None):
    """Return (raw_fq_table, {col: raw_expr}, walk_cols_dict).

    For a plain stg_, walk_cols_dict is empty. For a resolver, columns from
    the base stg_ resolve to RAW directly; walk columns resolve to the
    parent stg_'s RAW column name as an identifier (we cannot inline them
    into a single-table query, so to_raw() will see them as unknown tokens
    and leave them unchanged -- callers detect this and mark the branch as
    unresolved).
    """
    if name.startswith("resolved_mt__"):
        base_stg, walks = parse_resolved(models_dir, name)
        raw, cols = PK.parse_stg(models_dir, base_stg)
        return raw, dict(cols), walks
    raw, cols = PK.parse_stg(models_dir, name)
    return raw, dict(cols), {}


# ---------------------------------------------------------------------------
# Unpivot parser (travel): mirrors partner.parse_unpivot but reads an alias
# <HUB>_BK rather than hard-coded parent_bk, and the ref may be a resolved
# view rather than a stg_.
# ---------------------------------------------------------------------------
def parse_unpivot_travel(models_dir, name, bk_alias):
    """[(ref_name, bk_literal_expr, where_or_None)] for an up_mt__ model.

    bk_alias is the derived-column name the wrapper picks the BK up as
    (e.g. 'CLAIM_BK'). Every arm must select something aliased to that
    exact name.
    """
    sql = PK.read(PK.find_model(models_dir, name))
    sql = re.sub(r"\{\{\s*config\(.*?\)\s*\}\}", "", sql, flags=re.S)
    parts = re.split(r"\bunion\s+all\b", sql, flags=re.I)
    arms = []
    bk_re = re.compile(
        r"(?is)select\s+(.+?)\s+as\s+" + re.escape(bk_alias) + r"\s*,", re.I)
    ref_re = re.compile(r"ref\('([^']+)'\)")
    where_re = re.compile(r"\bwhere\b(.*)$", re.S | re.I)
    for p in parts:
        bk_m = bk_re.search(p)
        ref_m = ref_re.search(p)
        if not (bk_m and ref_m):
            continue
        w = where_re.search(p[p.rfind("}}"):] if "}}" in p else p)
        arms.append((ref_m.group(1), bk_m.group(1).strip(),
                     w.group(1).strip() if w else None))
    return arms


# ---------------------------------------------------------------------------
# Travel Hub class extends partner's Hub with a parsed RECORD_SOURCE set.
# ---------------------------------------------------------------------------
class THub(PK.Hub):
    def __init__(self, project, name, pk, nk_col, branches, notes, skipped,
                 record_sources):
        super().__init__(project, name, pk, nk_col, branches, notes, skipped)
        # Deterministic ordering so emitted SQL is stable.
        self.record_sources = sorted(record_sources)

    def scope_pred(self, alias=""):
        """RECORD_SOURCE filter used by DM-K2 / DM-R / DM-T to pin to this
        project's travel rows (not partner's) inside the shared vault."""
        a = f"{alias}." if alias else ""
        if self.record_sources:
            lits = ", ".join("'" + v.replace("'", "''") + "'" for v in self.record_sources)
            return f"{a}RECORD_SOURCE in ({lits})"
        return f"startswith({a}RECORD_SOURCE, '{self.prefix}')"


# ---------------------------------------------------------------------------
# OPUS travel builder: stg_travel__ staging; stitched/ stitches.
# ---------------------------------------------------------------------------
def build_opus_travel():
    hubs = []
    hub_dir = OPUS / "raw_vault" / "standard" / "hubs"
    for path in sorted(hub_dir.glob("hub_*.sql")):
        name = path.stem.upper()
        srcs, pk, nk_col = PK.hub_meta(path)
        branches, skipped, notes = [], [], []
        rsrcs = set()
        for s in srcs:
            try:
                sp = PK.find_model(OPUS, s)
            except SystemExit as e:
                skipped.append(f"{s}: {e}")
                continue
            ssql = PK.read(sp)
            if PK.is_disabled(ssql):
                skipped.append(f"{s}: disabled placeholder (enabled=false) -> loads nothing")
                continue
            try:
                meta = PK.yaml_block(ssql)
            except Exception as e:
                skipped.append(f"{s}: no yaml_metadata ({e})")
                continue
            dc = meta.get("derived_columns", {}) or {}
            nk_name = (meta.get("hashed_columns") or {}).get(pk)
            if nk_name is None or not isinstance(nk_name, str):
                skipped.append(f"{s}: hashed_columns[{pk}] missing")
                continue
            nk_expr = dc.get(nk_name)
            if nk_expr is None:
                skipped.append(f"{s}: derived_columns[{nk_name}] missing")
                continue
            # Capture RECORD_SOURCE literal if present.
            rs = dc.get("RECORD_SOURCE")
            if isinstance(rs, str) and rs.startswith("!"):
                rsrcs.add(rs[1:])
            src_model = meta["source_model"]
            try:
                if src_model.startswith("stg_travel__"):
                    b = PK.make_branch(OPUS, src_model, dc.get("PARENT_BK", ""),
                                       nk_expr, via=s, skipped=skipped)
                    if b:
                        branches.append(b)
                elif src_model.startswith("stitch_"):
                    for stg, key_col in PK.parse_stitch(OPUS, src_model):
                        nk = nk_expr.replace("PARENT_BK", f"({key_col})")
                        b = PK.make_branch(OPUS, stg, key_col, nk,
                                           via=f"{s} <- {src_model}", skipped=skipped)
                        if b:
                            branches.append(b)
                    notes.append(
                        f"{src_model} is a stitch view; row-level load windowing applies "
                        f"-- RAW rows with a NULL inc_job_updated_at never reach the hub.")
                else:
                    skipped.append(f"{s}: unknown source_model shape {src_model}")
            except Exception as e:
                skipped.append(f"{s}: parse error ({e})")
                continue
        hubs.append(THub("OPUS", name, pk, nk_col, PK.collapse(branches),
                         list(OrderedDict.fromkeys(notes)), skipped, rsrcs))
    return hubs


# ---------------------------------------------------------------------------
# MAXIMUS travel builder: hubfeed_mt_* -> stg2_mt__* (one hub key
# column per branch) -> resolved_mt__ | stg_mt__ | up_mt__.
# ---------------------------------------------------------------------------
def _bk_name_from_nk(nk_name):
    """CLAIM_NK -> CLAIM_BK; CLAIM_NK__V2 -> CLAIM_BK__V2."""
    return nk_name.replace("_NK", "_BK", 1)


def _hubfeed_branches(models_dir, feed):
    """Yield (stg2_name, hk_alias, bk_alias) for every union-all arm.

    hk_alias is the first all-caps identifier after SELECT in the arm;
    bk_alias is its matching derived column name (<HUB>_BK[...]suffix).
    """
    fsql = PK.read(PK.find_model(models_dir, feed))
    for part in re.split(r"\bunion\s+all\b", fsql, flags=re.I):
        ref_m = re.search(r"ref\('([^']+)'\)", part)
        if not ref_m:
            continue
        hk_m = re.search(r"\bselect\s+([A-Za-z0-9_]+)\s+as\s+[A-Za-z0-9_]+", part, re.I)
        if not hk_m:
            continue
        yield ref_m.group(1), hk_m.group(1)


def _resolve_mt_stg_source(models_dir, src_model, skipped=None, via=None):
    """Resolve a stg2's source_model to (base_raw, base_cols, walks).

    Supports stg_mt__, resolved_mt__. Returns None if we cannot trace.
    """
    try:
        if src_model.startswith("stg_mt__"):
            raw, cols = PK.parse_stg(models_dir, src_model)
            return raw, dict(cols), {}
        if src_model.startswith("resolved_mt__"):
            return parse_stg_or_resolved(models_dir, src_model)
    except Exception as e:
        if skipped is not None:
            skipped.append(f"{via}: cannot resolve {src_model} ({e})")
        return None
    if skipped is not None:
        skipped.append(f"{via}: unknown stg2 source_model shape {src_model}")
    return None


def _make_mt_branch(models_dir, src_model, bk_expr, nk_expr, hk_alias,
                      via=None, skipped=None, extra_notes=None):
    """Branch from a stg2 whose source is a stg_mt__ or resolved_mt__."""
    resolved = _resolve_mt_stg_source(models_dir, src_model, skipped, via)
    if resolved is None:
        return None
    raw, cols, walks = resolved
    # Lower every walk-column name so to_raw() recognises them; we expose
    # them as their RAW parent-table column name but qualify with the
    # parent raw table in a comment -- which keeps the SELECT syntactically
    # valid against just `raw`. If BK/NK references walks, flag it in a
    # branch-level note so the output marks it as limited.
    nk_lower = (nk_expr or "").lower()
    uses_walks = [w for w in walks if re.search(r"\b" + re.escape(w) + r"\b", nk_lower)]
    if uses_walks:
        if skipped is not None:
            skipped.append(
                f"{via}: key uses walk column(s) {', '.join(sorted(uses_walks))} "
                f"from parent view(s) -- not resolvable to a single RAW table in the "
                f"first-cut, skipped.")
        return None
    nulls = PK.unmapped_cols(nk_expr, cols)
    if nulls:
        if skipped is not None:
            skipped.append(
                f"{via}: key column(s) {', '.join(nulls)} are cast(null) in staging "
                f"-- contributes no keys")
        return None
    bk_raw = PK.to_raw(bk_expr, cols) if bk_expr else PK.to_raw(nk_expr, cols)
    nk_raw = PK.to_raw(nk_expr, cols)
    # Branch label: show the stg2 source + which hub-key alias we picked.
    key_cols = list(OrderedDict.fromkeys(
        t for t in re.findall(r"\b[a-z_][a-z0-9_]*\b",
                              re.sub(r"'(?:[^']|'')*'", "", bk_expr))
        if t in cols and t not in PK.SQL_WORDS))
    tbl = raw.split(".")[-1]
    label = f"{tbl}.{key_cols[0].upper()}" if len(key_cols) == 1 else \
        f"{tbl}.[{'+'.join(c.upper() for c in key_cols)}]"
    label += f" ({hk_alias})"
    return PK.Branch(label=label, raw=raw, bk=bk_raw, nk=nk_raw, where=None, via=via)


def _make_mt_unpivot_branches(models_dir, up_name, bk_alias, nk_expr,
                                hk_alias, via, skipped):
    """Branches for each arm of an up_mt__ unpivot view.

    nk_expr is the stg2 wrapper's NK derived-column expression; it was built
    assuming <bk_alias> is a top-level column, so we substitute each arm's
    BK literal in place of the bk_alias token.
    """
    try:
        arms = parse_unpivot_travel(models_dir, up_name, bk_alias.upper())
        if not arms:
            # Try lowercase too (some unpivots alias in lowercase).
            arms = parse_unpivot_travel(models_dir, up_name, bk_alias.lower())
    except Exception as e:
        skipped.append(f"{via}: cannot parse unpivot {up_name} ({e})")
        return []
    out = []
    for ref, arm_bk, where in arms:
        resolved = _resolve_mt_stg_source(models_dir, ref, skipped,
                                            via=f"{via} <- {up_name}")
        if resolved is None:
            continue
        raw, cols, walks = resolved
        # Replace bk_alias with the arm's BK literal in both bk and nk.
        pat = re.compile(r"\b" + re.escape(bk_alias) + r"\b", re.I)
        arm_bk_safe = arm_bk if re.fullmatch(r"[a-z0-9_]+", arm_bk, re.I) \
            else f"({arm_bk})"
        bk_sub = pat.sub(arm_bk_safe, arm_bk)
        nk_sub = pat.sub(arm_bk_safe, nk_expr)
        uses_walks = [w for w in walks if re.search(r"\b" + re.escape(w) + r"\b",
                                                     (nk_sub or "").lower())]
        if uses_walks:
            skipped.append(f"{via} <- {up_name}: arm uses walk column(s), skipped.")
            continue
        nulls = PK.unmapped_cols(nk_sub, cols)
        if nulls:
            skipped.append(f"{via} <- {up_name}: NK references cast(null) column(s) "
                           f"{', '.join(nulls)} -- skipped.")
            continue
        try:
            bk_raw = PK.to_raw(bk_sub, cols)
            nk_raw = PK.to_raw(nk_sub, cols)
            where_raw = PK.to_raw(where, cols) if where else None
        except Exception as e:
            skipped.append(f"{via} <- {up_name}: cannot resolve arm ({e})")
            continue
        tbl = raw.split(".")[-1]
        key_cols = list(OrderedDict.fromkeys(
            t for t in re.findall(r"\b[a-z_][a-z0-9_]*\b",
                                  re.sub(r"'(?:[^']|'')*'", "", bk_sub))
            if t in cols and t not in PK.SQL_WORDS))
        if key_cols:
            label = (f"{tbl}.{key_cols[0].upper()}" if len(key_cols) == 1
                     else f"{tbl}.[{'+'.join(c.upper() for c in key_cols)}]")
        else:
            label = f"{tbl} (literal arm)"
        label += f" ({hk_alias} / {up_name.split('__')[-1]})"
        out.append(PK.Branch(label=label, raw=raw, bk=bk_raw, nk=nk_raw,
                             where=where_raw, via=f"{via} <- {up_name}"))
    return out


def build_maxi_travel():
    hubs = []
    hub_dir = MAXI / "raw_vault" / "standard" / "hubs"
    for path in sorted(hub_dir.glob("hub_*.sql")):
        name = path.stem.upper()
        srcs, pk, nk_col = PK.hub_meta(path)
        branches, skipped, notes = [], [], []
        rsrcs = set()
        for feed in srcs:
            try:
                feed_path = PK.find_model(MAXI, feed)
            except SystemExit as e:
                skipped.append(f"{feed}: {e}")
                continue
            if PK.is_disabled(PK.read(feed_path)):
                skipped.append(f"{feed}: disabled placeholder (enabled=false)")
                continue
            for stg2, hk_alias in _hubfeed_branches(MAXI, feed):
                try:
                    stg2_path = PK.find_model(MAXI, stg2)
                except SystemExit as e:
                    skipped.append(f"{feed} <- {stg2}: {e}")
                    continue
                stg2_sql = PK.read(stg2_path)
                try:
                    meta = PK.yaml_block(stg2_sql)
                except Exception as e:
                    skipped.append(f"{feed} <- {stg2}: no yaml_metadata ({e})")
                    continue
                dc = (meta.get("derived_columns") or {})
                hc = (meta.get("hashed_columns") or {})
                nk_name = hc.get(hk_alias)
                if not isinstance(nk_name, str):
                    skipped.append(f"{feed} <- {stg2}: hashed_columns[{hk_alias}] "
                                   f"is not a plain NK alias")
                    continue
                nk_expr = dc.get(nk_name)
                bk_name = _bk_name_from_nk(nk_name)
                bk_expr = dc.get(bk_name) or dc.get("PARENT_BK")
                if not nk_expr:
                    skipped.append(f"{feed} <- {stg2}: derived_columns[{nk_name}] "
                                   f"missing")
                    continue
                rs = dc.get("RECORD_SOURCE")
                if isinstance(rs, str) and rs.startswith("!"):
                    rsrcs.add(rs[1:])
                src_model = meta.get("source_model")
                if not isinstance(src_model, str):
                    skipped.append(f"{stg2}: unexpected source_model {src_model}")
                    continue
                via = f"{feed} <- {stg2}"
                try:
                    if src_model.startswith("stg_mt__") or \
                            src_model.startswith("resolved_mt__"):
                        b = _make_mt_branch(MAXI, src_model, bk_expr, nk_expr,
                                              hk_alias, via=via, skipped=skipped)
                        if b:
                            branches.append(b)
                    elif src_model.startswith("up_mt__"):
                        # stg2 is actually a stg2_mt_up__ wrapper over an
                        # up_mt__ unpivot: bk_alias name here must match the
                        # unpivot output column.
                        for b in _make_mt_unpivot_branches(
                                MAXI, src_model, bk_name, nk_expr, hk_alias,
                                via=via, skipped=skipped):
                            branches.append(b)
                    else:
                        skipped.append(f"{stg2}: unknown source_model shape "
                                       f"{src_model}")
                except Exception as e:
                    skipped.append(f"{via}: parse error ({e})")
                    continue
        before = len(branches)
        branches = PK.collapse(branches)
        if before != len(branches):
            notes.append(
                f"{before} feed branches collapse to {len(branches)} RAW key(s).")
        hubs.append(THub("MAXIMUS", name, pk, nk_col, branches,
                         list(OrderedDict.fromkeys(notes)), skipped, rsrcs))
    return hubs


# ---------------------------------------------------------------------------
# Overrides of DM-K check builders so DM-K2 scopes by RECORD_SOURCE value set
# (not by prefix -- the prefix is shared with the partner build).
# ---------------------------------------------------------------------------
def common_note(hub):
    parts = [f"{len(hub.branches)} RAW key branch(es): "
             + ", ".join(b.label for b in hub.branches) + "."]
    parts += list(hub.notes)
    if hub.record_sources:
        rs = ", ".join(hub.record_sources[:6])
        if len(hub.record_sources) > 6:
            rs += f" (+{len(hub.record_sources) - 6} more)"
        parts.append(f"Travel RECORD_SOURCE value(s) parsed from feeds: {rs}.")
    else:
        parts.append(
            f"No RECORD_SOURCE literal parsed from the project's feeds -- "
            f"falling back to startswith('{hub.prefix}') for the row filter; "
            f"this will overlap with the partner build.")
    parts += [f"Excluded: {s}." for s in hub.skipped]
    return " ".join(parts)


def k1(hub):
    if not hub.applicable:
        return PK.na_section(hub, "DM-K1")
    sql = f"""with src as (
{PK.src_union(hub)}
)
select {PK.proj_tag(hub)},
       s.hkey as missing_hkey,
       min(s.bk) as missing_bk,
       listagg(distinct s.src_branch, ', ') within group (order by s.src_branch) as src_branches
  from src s
 where s.hkey is not null
   and not exists (select 1 from {PK.fq(hub)} h where h.{hub.pk} = s.hkey)
 group by s.hkey
 order by missing_bk;"""
    return dict(project=hub.project, hub=hub.name, status="Implemented",
                pass_criteria="0 rows returned", note=common_note(hub),
                queries=[("SQL query", sql)])


def k2(hub):
    if not hub.applicable:
        return PK.na_section(hub, "DM-K2")
    scope = hub.scope_pred("h")
    sql = f"""with src as (
{PK.src_union(hub, with_bk=False, with_branch=False)}
)
select {PK.proj_tag(hub)},
       h.{hub.nk_col} as unexpected_bk, h.{hub.pk} as unexpected_hkey, h.RECORD_SOURCE, h.LOAD_DATETIME
  from {PK.fq(hub)} h
 where {scope}
   and not exists (select 1 from src s where s.hkey = h.{hub.pk})
 order by h.RECORD_SOURCE, unexpected_bk;"""
    note = (f"Hub rows scoped by RECORD_SOURCE value set (travel feeds only) to avoid "
            f"colliding with the partner build in the shared vault. ") + common_note(hub)
    return dict(project=hub.project, hub=hub.name, status="Implemented",
                pass_criteria="0 rows returned", note=note,
                queries=[("SQL query", sql)])


def k3(hub):
    sec = PK.k3(hub)
    # Rewrite the (a) scope so it uses the travel RECORD_SOURCE value set
    # rather than startswith('MAXIMUS_'|'OPUS_').
    if hub.applicable and hub.record_sources:
        bk, pk_c = hub.nk_col, hub.pk
        scope = hub.scope_pred()
        degen = (f"count_if({scope} and regexp_like(trim({bk}), "
                 f"'^[:#|].*|.*[:#|]$'))" if hub.name not in PK.DEGENERATE_EXEMPT
                 else "0")
        sql_a = f"""select {PK.proj_tag(hub)},
       count_if({scope})                                              as rows_in_scope,
       count_if({scope} and {pk_c} is null)                         as null_hkey,
       count_if({scope} and nullif(trim({bk}), '') is null)        as null_or_blank_bk,
       {degen} as degenerate_bk,
       count_if({scope} and upper(trim({bk})) in ('NULL', 'NONE', 'NA', 'N/A', 'UNKNOWN', '0')) as placeholder_bk_info,
       count_if({pk_c} = {GHOST_HKEY} or trim({bk}) in ('-1', '-2'))   as ghost_rows,
       iff(null_hkey = 0 and null_or_blank_bk = 0 and degenerate_bk = 0, 'PASS', 'FAIL') as null_key_status,
       iff(ghost_rows > 0, 'PASS', 'FAIL')                            as ghost_record_status
  from {PK.fq(hub)};"""
        queries = [("SQL query (a) -- hub null / blank keys + ghost record", sql_a)]
        if sec.get("queries") and len(sec["queries"]) > 1:
            queries.append(sec["queries"][1])
        sec = dict(sec, queries=queries, note=common_note(hub))
    return sec


def k5(hub):
    return PK.k5(hub)


# ---------------------------------------------------------------------------
# CHECKS: use travel builders for K1/K2/K3; K4 is shared across projects
# (same physical table). K2 ownership sweep is skipped because the travel
# generators don't own the whole hub (partner also writes it).
# ---------------------------------------------------------------------------
COMMON_OVERVIEW_TRAVEL = [
    ("Owner", "LUMIQ"),
    ("Vault location", VAULT),
    ("Maximus Travel RAW", RAW_SCHEMA["maximus_travel_raw"]),
    ("Opus Travel RAW (prod)", RAW_SCHEMA["travel_raw"]),
    ("Opus Travel RAW (test)", RAW_SCHEMA["travel_test_raw"]),
]

CHECKS = OrderedDict([
    ("DM-K1", dict(
        title="DM-K1  |  Key Checks \u2014 No Missing Keys (Travel LOB)",
        subtitle="Hub key reconciliation (RAW source \u2192 hub). Pass criterion: 0 rows returned (0 missing business keys, or documented exceptions).",
        overview=[("Check ID", "DM-K1"), ("Category", "Key checks"),
                  ("Sign-off criterion", "No missing keys"),
                  ("Method", "Anti-join: every RAW source branch of the hub \u2192 HUB, joined on the hash key alone"),
                  ("Pass criteria / tolerance", "0 missing keys")] + COMMON_OVERVIEW_TRAVEL + [
                  ("Hash key formula", HASH_TXT),
                  ("Scope", "Shared vault with partner. Row filters here only "
                            "constrain hub-side RECORD_SOURCE for DM-K2; "
                            "DM-K1 is HKEY-based.")],
        builder=k1)),
    ("DM-K2", dict(
        title="DM-K2  |  Key Checks \u2014 No Extra / Unexpected Keys (Travel LOB)",
        subtitle="Hub key reconciliation (hub \u2192 RAW source). Pass criterion: 0 rows returned.",
        overview=[("Check ID", "DM-K2"), ("Category", "Key checks"),
                  ("Sign-off criterion", "No extra / unexpected keys"),
                  ("Method", "Anti-join: HUB rows for travel RECORD_SOURCE values \u2192 union of every RAW source branch"),
                  ("Pass criteria / tolerance", "0 unexpected keys")] + COMMON_OVERVIEW_TRAVEL + [
                  ("Hash key formula", HASH_TXT),
                  ("Scope", "Hub rows filtered by RECORD_SOURCE value set parsed "
                            "from this project's feeds (MAXIMUS_ and OPUS_ prefixes "
                            "are shared with the partner build so a prefix filter is unsafe).")],
        builder=k2)),
    ("DM-K3", dict(
        title="DM-K3  |  Key Checks \u2014 No Null / Blank Business Keys (Travel LOB)",
        subtitle="Hub key integrity. Pass criterion: 0 null / blank keys loaded without a default, ghost record present.",
        overview=[("Check ID", "DM-K3"), ("Category", "Key checks"),
                  ("Sign-off criterion", "No null / blank business keys"),
                  ("Method", "Per hub rows of this project's RECORD_SOURCE values"),
                  ("Pass criteria / tolerance", "0 nulls loaded without default")] + COMMON_OVERVIEW_TRAVEL + [
                  ("Ghost record definition",
                   f"hash key = {GHOST_HKEY} OR business key in ('-1','-2')")],
        builder=k3)),
    ("DM-K4", dict(
        title="DM-K4  |  Key Checks \u2014 Business Key Uniqueness (Travel LOB)",
        subtitle="Hub grain integrity: no duplicate business keys. Pass criterion: 0 rows returned.",
        overview=[("Check ID", "DM-K4"), ("Category", "Key checks"),
                  ("Sign-off criterion", "Business key uniqueness"),
                  ("Method", "Group hub by hash key; count(*) > 1 is a grain violation"),
                  ("Pass criteria / tolerance", "Hub row count = distinct business keys"),
                  ("Owner", "LUMIQ"), ("Vault location", VAULT),
                  ("Scope", "Runs on the shared hub tables; each hub is checked once "
                            "across both projects (partner + travel).")],
        builder=PK.k4)),
    ("DM-K5", dict(
        title="DM-K5  |  Completeness \u2014 Row-count Completeness (Travel LOB)",
        subtitle="Source record count reconciles to hub load counts. Pass criterion: diff = 0 on TOTAL.",
        overview=[("Check ID", "DM-K5"), ("Category", "Completeness"),
                  ("Sign-off criterion", "Row-count completeness"),
                  ("Method", "Distinct RAW source keys vs those present in the hub"),
                  ("Pass criteria / tolerance", "diff = 0 on the TOTAL row")] + COMMON_OVERVIEW_TRAVEL + [
                  ("Hash key formula", HASH_TXT)],
        builder=k5)),
])


def main():
    template = TEMPLATE_DOCX.read_bytes() if TEMPLATE_DOCX else None
    if template is None:
        print("WARNING: no docx template found under validation/partner -- writing .sql only")
    (VALIDATION / "DM-K").mkdir(parents=True, exist_ok=True)
    order = ["HUB_PARTY", "HUB_POLICY", "HUB_PRODUCT", "HUB_COVERAGE",
             "HUB_LOCATION", "HUB_ORG_UNIT", "HUB_DISTRIBUTION_CHANNEL",
             "HUB_FINANCIAL_ACCOUNT", "HUB_FINANCIAL_TRANSACTION",
             "HUB_AGREEMENT", "HUB_ASSESSMENT", "HUB_PROPOSAL", "HUB_QUOTE",
             "HUB_RISK_OBJECT", "HUB_CLAIM", "HUB_DOCUMENT", "HUB_LOSS_EVENT",
             "HUB_PAYMENT_INSTRUMENT"]
    rank = lambda h: (order.index(h.name) if h.name in order else len(order),
                      h.name)
    maxi = sorted(build_maxi_travel(), key=rank)
    opus = sorted(build_opus_travel(), key=rank)
    project_hubs = maxi + opus

    shared = OrderedDict()
    for h in project_hubs:
        if h.name not in shared:
            shared[h.name] = h
            h.loaders = h.project
        else:
            shared[h.name].loaders += f", {h.project}"

    revision = [
        f"Travel LOB generated 2026-10-13 from the current opus_travel_dv_dbt "
        f"and maximus_travel_dv_dbt models by gen_dm_k_travel.py.",
        f"Scope: {len(maxi)} MAXIMUS hubs + {len(opus)} OPUS hubs = "
        f"{len(project_hubs)} project-hub sections "
        f"({len(shared)} physical hub tables, shared with the partner build).",
        "Row filters for DM-K2 / K3 use the RECORD_SOURCE value set parsed from each "
        "project's own feeds (not a prefix), because the MAXIMUS_ / OPUS_ prefixes "
        "are shared with the partner build in the same vault schema.",
        "First-cut limitations: MAXIMUS stg2 keys that reference resolver walk columns "
        "are skipped (not resolvable to a single RAW table in this pass).",
        "Hash reproduced exactly as automate_dv 0.11.5: "
        "MD5_BINARY(NULLIF(UPPER(TRIM(CAST(<NK> AS VARCHAR))), '')).",
    ]

    for cid, meta in CHECKS.items():
        if cid == "DM-K4":
            sections = [PK.k4(h) for h in shared.values()] + \
                [PK.k4_bk_multi_hkey(list(shared.values()))]
        else:
            sections = [meta["builder"](h) for h in project_hubs]
            if cid == "DM-K3":
                sections.append(PK.k3_detail(project_hubs))
        PK.write_sql(cid, meta, sections, revision)
        if template is not None:
            PK.write_docx(cid, meta, sections, revision, template)
        print(f"{cid}: {len(sections)} sections written")

    for h in project_hubs:
        print(f"  {h.project:8} {h.name:30} branches={len(h.branches):3} "
              f"skipped={len(h.skipped):3} rsrcs={len(h.record_sources)}")


if __name__ == "__main__":
    main()
