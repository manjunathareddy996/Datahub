#!/usr/bin/env python3
"""
Generate the DM-K1..DM-K5 sign-off validation SQL + DOCX for the MAXIMUS and OPUS
partner Data Vault projects.

Every hub business-key expression is PARSED from the dbt models (hub -> stage / hubfeed
-> stitch / unpivot -> layer-1 stg_ -> RAW source), never hand-typed, so the checks
always mirror what the models actually load. Re-run after any model change:

    python3 BGIL_DBT/validation/tools/gen_dm_k.py

Outputs (overwritten): BGIL_DBT/validation/DM-K{1..5}.sql and DM-K{1..5}.docx
The .docx is built by swapping word/document.xml inside a template package (the
existing DM-K4.docx styles), so no python-docx dependency is needed.
"""
import html
import re
import shutil
import sys
import zipfile
from collections import OrderedDict
from pathlib import Path

import yaml

HERE = Path(__file__).resolve().parent
VALIDATION = HERE.parent
ROOT = VALIDATION.parent  # BGIL_DBT
OPUS = ROOT / "opus_partner_dv_dbt" / "models"
MAXI = ROOT / "maximus_partner_dv_dbt" / "models"

VAULT = "BAGIC_PREPROD_CURATED_DB.BGIL_DATA_MODEL"
RAW_SCHEMA = {
    "partner_test_raw": "BAGIC_PREPROD_CURATED_DB.UTILS",
    "maximus_partner": "BAGIC_PROD_MIRROR_DB.MAXI_RAW",
}
GHOST_HKEY = "TO_BINARY(REPEAT('0', 32), 'HEX')"

# ---------------------------------------------------------------------------------------
# Parsing helpers
# ---------------------------------------------------------------------------------------
_model_index = {}


def find_model(models_dir: Path, name: str) -> Path:
    key = (models_dir, name)
    if key not in _model_index:
        hits = [p for p in models_dir.rglob(f"{name}.sql")]
        if len(hits) != 1:
            raise SystemExit(f"model {name}: expected 1 file under {models_dir}, found {hits}")
        _model_index[key] = hits[0]
    return _model_index[key]


def read(p: Path) -> str:
    return p.read_text()


def yaml_block(sql: str) -> dict:
    m = re.search(r"\{%-?\s*set yaml_metadata\s*-?%\}(.*?)\{%-?\s*endset\s*-?%\}", sql, re.S)
    if not m:
        raise ValueError("no yaml_metadata block")
    return yaml.safe_load(m.group(1))


def is_disabled(sql: str) -> bool:
    return bool(re.search(r"config\([^)]*enabled\s*=\s*false", sql))


_stg_cache = {}


def parse_stg(models_dir: Path, name: str):
    """Layer-1 stg_ model -> (raw fully-qualified table, {column: raw expression})."""
    key = (models_dir, name)
    if key in _stg_cache:
        return _stg_cache[key]
    sql = read(find_model(models_dir, name))
    src = re.search(r"source\('([^']+)',\s*'([^']+)'\)", sql)
    raw = f"{RAW_SCHEMA[src.group(1)]}.{src.group(2)}"
    body = sql[sql.index("select"): src.start()]
    cols = {}
    for line in body.splitlines():
        line = re.sub(r"--.*$", "", line).rstrip().rstrip(",").strip()
        m = re.match(r"^(?P<expr>.+?)\s+as\s+(?P<name>[a-z0-9_]+)$", line, re.I)
        if m:
            cols[m.group("name").lower()] = m.group("expr").strip()
    if re.search(r"\bwhere\b|\bqualify\b", sql[src.end():], re.I):
        raise SystemExit(f"{name}: stg model filters rows -- generator does not handle that")
    _stg_cache[key] = (raw, cols)
    return _stg_cache[key]


SQL_WORDS = {
    "case", "when", "then", "else", "end", "and", "or", "not", "is", "null", "like", "as",
    "in", "varchar", "number", "upper", "lower", "trim", "coalesce", "nullif", "to_varchar",
    "md5", "concat_ws", "cast",
}


def to_raw(expr: str, cols: dict) -> str:
    """Rewrite an expression over stg_ column names into one over RAW columns."""
    out, i = [], 0
    for m in re.finditer(r"'(?:[^']|'')*'|\b[a-z_][a-z0-9_]*\b", expr):
        out.append(expr[i:m.start()])
        tok = m.group(0)
        nxt = expr[m.end():].lstrip()[:1]
        if tok.startswith("'") or tok in SQL_WORDS or nxt == "(" or tok not in cols:
            out.append(tok)
        else:
            e = cols[tok]
            out.append(e if re.fullmatch(r"[a-z_]+\(.*\)", e, re.S) else f"({e})")
        i = m.end()
    out.append(expr[i:])
    return "".join(out)


def unmapped_cols(expr: str, cols: dict):
    """stg columns referenced by expr that are hard-coded cast(null) in staging."""
    toks = set(re.findall(r"\b[a-z_][a-z0-9_]*\b", re.sub(r"'(?:[^']|'')*'", "", expr)))
    return sorted(t for t in toks if t in cols and re.fullmatch(r"cast\(null as \w+\)", cols[t], re.I))


# ---------------------------------------------------------------------------------------
# Branch model: one row-producing source of a hub key
# ---------------------------------------------------------------------------------------
class Branch:
    def __init__(self, label, raw, bk, nk, where=None, via=None):
        self.label, self.raw, self.bk, self.nk = label, raw, bk, nk
        self.where = where      # optional raw-level filter
        self.via = via          # dbt model path the key comes through

    @property
    def table(self):
        return self.raw.split(".")[-1]


def make_branch(models_dir, stg_name, bk_stg, nk_stg, where_stg=None, via=None, skipped=None):
    raw, cols = parse_stg(models_dir, stg_name)
    nulls = unmapped_cols(nk_stg, cols)
    if nulls:
        if skipped is not None:
            skipped.append(f"{via}: key column(s) {', '.join(nulls)} hard-coded cast(null) in {stg_name} -> contributes no keys")
        return None
    key_cols = list(OrderedDict.fromkeys(
        t for t in re.findall(r"\b[a-z_][a-z0-9_]*\b", re.sub(r"'(?:[^']|'')*'", "", bk_stg))
        if t in cols and t not in SQL_WORDS))
    label = f"{raw.split('.')[-1]}.{key_cols[0].upper()}" if len(key_cols) == 1 else \
        f"{raw.split('.')[-1]}.[{'+'.join(c.upper() for c in key_cols)}]"
    if where_stg:
        label += " (filtered)"
    return Branch(
        label=label,
        raw=raw,
        bk=to_raw(bk_stg, cols),
        nk=to_raw(nk_stg, cols),
        where=to_raw(where_stg, cols) if where_stg else None,
        via=via,
    )


def collapse(branches):
    """Same raw table + same key expression: unfiltered branch supersedes filtered ones."""
    grouped = OrderedDict()
    for b in branches:
        grouped.setdefault((b.raw, re.sub(r"\s+", " ", b.nk).strip()), []).append(b)
    out = []
    for (_, _), bs in grouped.items():
        base = bs[0]
        if any(b.where is None for b in bs):
            base.where = None
            base.label = base.label.replace(" (filtered)", "")
        else:
            base.where = " or ".join(f"({b.where})" for b in bs)
        vias = list(OrderedDict.fromkeys(b.via for b in bs))
        extra = len(vias) - 1
        base.via = vias[0] + (f"  (+{extra} more feed(s) on the same RAW table + key)" if extra else "")
        out.append(base)
    return out


def parse_stitch(models_dir, stitch_name):
    sql = read(find_model(models_dir, stitch_name))
    pat = re.compile(r"'model':\s*'([^']+)'.*?'key_column':\s*(\"(?:[^\"\\]|\\.)*\"|'[^']*')", re.S)
    return [(m.group(1), m.group(2)[1:-1]) for m in pat.finditer(sql)]


def parse_unpivot(models_dir, name):
    sql = read(find_model(models_dir, name))
    sql = re.sub(r"\{\{\s*config\(.*?\)\s*\}\}", "", sql, flags=re.S)
    parts = re.split(r"\bunion all\b", sql, flags=re.I)
    res = []
    for p in parts:
        bk = re.search(r"select\s+(.+?)\s+as\s+parent_bk\s*,", p, re.S | re.I).group(1).strip()
        ref = re.search(r"ref\('([^']+)'\)", p).group(1)
        w = re.search(r"\bwhere\b(.*)$", p, re.S | re.I)
        res.append((ref, bk, w.group(1).strip() if w else None))
    return res


# ---------------------------------------------------------------------------------------
# Hub spec builders
# ---------------------------------------------------------------------------------------
class Hub:
    def __init__(self, project, name, pk, nk_col, branches, notes, skipped):
        self.project, self.name, self.pk, self.nk_col = project, name, pk, nk_col
        self.branches, self.notes, self.skipped = branches, notes, skipped

    @property
    def prefix(self):
        return "MAXIMUS_" if self.project == "MAXIMUS" else "OPUS_"

    @property
    def applicable(self):
        return bool(self.branches)


def hub_meta(path):
    meta = yaml_block(read(path))
    srcs = meta["source_model"]
    return ([srcs] if isinstance(srcs, str) else srcs), meta["src_pk"], meta["src_nk"]


def build_opus():
    hubs = []
    for path in sorted((OPUS / "raw_vault" / "standard" / "hubs").glob("hub_*.sql")):
        name = path.stem.upper()
        srcs, pk, nk_col = hub_meta(path)
        branches, skipped, notes = [], [], []
        for s in srcs:
            sp = find_model(OPUS, s)
            ssql = read(sp)
            if is_disabled(ssql):
                skipped.append(f"{s}: disabled placeholder (enabled=false) -> loads nothing")
                continue
            meta = yaml_block(ssql)
            dc = meta.get("derived_columns", {})
            nk_name = meta["hashed_columns"][pk]
            nk_expr = dc[nk_name]
            src_model = meta["source_model"]
            if src_model.startswith("stg_partner__"):
                b = make_branch(OPUS, src_model, dc["PARENT_BK"], nk_expr, via=s, skipped=skipped)
                if b:
                    branches.append(b)
            elif src_model.startswith("stitch_"):
                for stg, key_col in parse_stitch(OPUS, src_model):
                    nk = nk_expr.replace("PARENT_BK", f"({key_col})")
                    b = make_branch(OPUS, stg, key_col, nk, via=f"{s} <- {src_model}", skipped=skipped)
                    if b:
                        branches.append(b)
                notes.append(f"{src_model} is watermark-windowed (inc_job_updated_at); RAW rows with a NULL "
                             f"inc_job_updated_at never reach the hub and will surface as DM-K1 gaps.")
            else:
                raise SystemExit(f"{s}: unknown source_model {src_model}")
        hubs.append(Hub("OPUS", name, pk, nk_col, collapse(branches), list(OrderedDict.fromkeys(notes)), skipped))
    return hubs


def build_maxi():
    hubs = []
    for path in sorted((MAXI / "raw_vault" / "standard" / "hubs").glob("hub_*.sql")):
        name = path.stem.upper()
        srcs, pk, nk_col = hub_meta(path)
        branches, skipped, notes = [], [], []
        for feed in srcs:
            fsql = read(find_model(MAXI, feed))
            for part in re.split(r"\bunion all\b", fsql, flags=re.I):
                ref = re.search(r"ref\('([^']+)'\)", part)
                if not ref:
                    continue
                stg2 = ref.group(1)
                hk_col = re.search(r"select\s+([A-Z_]+)", part).group(1)
                meta = yaml_block(read(find_model(MAXI, stg2)))
                dc = meta["derived_columns"]
                nk_name = meta["hashed_columns"][hk_col]
                bk_name = nk_name[:-3] + "_BK"
                nk_expr, bk_expr = dc[nk_name], dc[bk_name]
                src_model = meta["source_model"]
                if src_model.startswith("stg_maximus__"):
                    b = make_branch(MAXI, src_model, bk_expr, nk_expr, via=f"{feed} <- {stg2}", skipped=skipped)
                    if b:
                        branches.append(b)
                elif src_model.startswith("unpivot_"):
                    for stg, pbk, where in parse_unpivot(MAXI, src_model):
                        sub = pbk if re.fullmatch(r"[a-z0-9_]+", pbk) else f"({pbk})"
                        b = make_branch(MAXI, stg, re.sub(r"\bparent_bk\b", sub, bk_expr),
                                        re.sub(r"\bparent_bk\b", sub, nk_expr), where,
                                        via=f"{feed} <- {stg2} <- {src_model}", skipped=skipped)
                        if b:
                            branches.append(b)
                else:
                    raise SystemExit(f"{stg2}: unknown source_model {src_model}")
        before = len(branches)
        branches = collapse(branches)
        if before != len(branches):
            notes.append(f"{before} feed branches (incl. every unpivot arm) collapse to {len(branches)} RAW key(s): every unpivot branch is a "
                         f"filtered subset of its base stage on the same RAW table and key column.")
        hubs.append(Hub("MAXIMUS", name, pk, nk_col, branches, notes, skipped))
    return hubs


# ---------------------------------------------------------------------------------------
# SQL fragments
# ---------------------------------------------------------------------------------------
def hkey_sql(nk):
    return f"MD5_BINARY(NULLIF(UPPER(TRIM(CAST({nk} AS VARCHAR))), ''))"


def src_union(hub, with_bk=True, with_branch=True, indent="    "):
    """UNION ALL of every RAW branch -> (src_branch, bk, hkey)."""
    lines = []
    for i, b in enumerate(hub.branches):
        cols = []
        if with_branch:
            cols.append(f"'{b.label}' as src_branch")
        if with_bk:
            cols.append(f"{b.bk} as bk")
        cols.append(f"{hkey_sql(b.nk)} as hkey")
        if i:
            lines.append(f"{indent}union all")
        lines.append(f"{indent}-- via {b.via}")
        lines.append(f"{indent}select " + (",\n" + indent + "       ").join(cols))
        lines.append(f"{indent}  from {b.raw}")
        if b.where:
            lines.append(f"{indent} where {b.where}")
    return "\n".join(lines)


def proj_tag(hub):
    return f"'{hub.project}' as project, '{hub.name}' as hub"


def fq(hub):
    return f"{VAULT}.{hub.name}"


# ---------------------------------------------------------------------------------------
# Check definitions. Each returns list of sections: dict(title, project, hub, status,
# pass_criteria, note, queries=[(label, sql)])
# ---------------------------------------------------------------------------------------
def na_section(hub, check):
    reason = "; ".join(hub.skipped) or "no RAW key source"
    return dict(project=hub.project, hub=hub.name, status="NA", pass_criteria="NA",
                note=f"Not applicable: {reason}. Re-generate once the key is mapped.",
                queries=[("SQL query", f"-- {check} {hub.project} {hub.name}: NA -- {reason}")])


def common_note(hub):
    parts = []
    parts.append(f"{len(hub.branches)} RAW key branch(es): " + ", ".join(b.label for b in hub.branches) + ".")
    parts += hub.notes
    parts += [f"Excluded: {s}." for s in hub.skipped]
    return " ".join(parts)


def k1(hub):
    if not hub.applicable:
        return na_section(hub, "DM-K1")
    sql = f"""with src as (
{src_union(hub)}
)
select {proj_tag(hub)},
       s.hkey as missing_hkey,
       min(s.bk) as missing_bk,
       listagg(distinct s.src_branch, ', ') within group (order by s.src_branch) as src_branches
  from src s
 where s.hkey is not null
   and not exists (select 1 from {fq(hub)} h where h.{hub.pk} = s.hkey)
 group by s.hkey
 order by missing_bk;"""
    return dict(project=hub.project, hub=hub.name, status="Implemented", pass_criteria="0 rows returned",
                note=common_note(hub), queries=[("SQL query", sql)])


def k2(hub):
    if not hub.applicable:
        return na_section(hub, "DM-K2")
    sql = f"""with src as (
{src_union(hub, with_bk=False, with_branch=False)}
)
select {proj_tag(hub)},
       h.{hub.nk_col} as unexpected_bk, h.{hub.pk} as unexpected_hkey, h.RECORD_SOURCE, h.LOAD_DATETIME
  from {fq(hub)} h
 where startswith(h.RECORD_SOURCE, '{hub.prefix}')
   and not exists (select 1 from src s where s.hkey = h.{hub.pk})
 order by h.RECORD_SOURCE, unexpected_bk;"""
    note = (f"Hub rows scoped to RECORD_SOURCE '{hub.prefix}%'. A hit grouped under one RECORD_SOURCE that no "
            f"longer feeds the hub is a legacy load from a removed feed (classify, do not ignore). ") + common_note(hub)
    return dict(project=hub.project, hub=hub.name, status="Implemented", pass_criteria="0 rows returned",
                note=note, queries=[("SQL query", sql)])


DEGENERATE_EXEMPT = {"HUB_LOCATION"}  # composite address keys legitimately carry blank '|' parts


def k3(hub):
    bk, pk, pre = hub.nk_col, hub.pk, hub.prefix
    scope = f"startswith(RECORD_SOURCE, '{pre}')"
    degen = (f"count_if({scope} and regexp_like(trim({bk}), '^[:#|].*|.*[:#|]$'))"
             if hub.name not in DEGENERATE_EXEMPT else "0")
    sql_a = f"""select {proj_tag(hub)},
       count_if({scope})                                              as rows_in_scope,
       count_if({scope} and {pk} is null)                         as null_hkey,
       count_if({scope} and nullif(trim({bk}), '') is null)        as null_or_blank_bk,
       {degen} as degenerate_bk,
       count_if({scope} and upper(trim({bk})) in ('NULL', 'NONE', 'NA', 'N/A', 'UNKNOWN', '0')) as placeholder_bk_info,
       count_if({pk} = {GHOST_HKEY} or trim({bk}) in ('-1', '-2'))   as ghost_rows,
       iff(null_hkey = 0 and null_or_blank_bk = 0 and degenerate_bk = 0, 'PASS', 'FAIL') as null_key_status,
       iff(ghost_rows > 0, 'PASS', 'FAIL')                            as ghost_record_status
  from {fq(hub)};"""
    queries = [("SQL query (a) -- hub null / blank keys + ghost record", sql_a)]
    if hub.applicable:
        sql_b = f"""with src as (
{src_union(hub, with_bk=False)}
)
select {proj_tag(hub)}, src_branch,
       count(*)                as source_rows,
       count_if(hkey is null)  as null_key_rows_not_loaded
  from src
 group by src_branch
 order by src_branch;"""
        queries.append(("SQL query (b) -- informational: RAW rows dropped for a NULL key (no default applied)", sql_b))
    note = ("degenerate_bk = composite key with an empty component (e.g. 'PAN:' or ':' -- leading/trailing ':' '#' '|'); "
            "it is a blank key in effect and fails null_key_status. "
            if hub.name not in DEGENERATE_EXEMPT else
            "degenerate_bk not evaluated: composite address keys legitimately carry blank '|' parts. ")
    if hub.nk_col != "PARENT_BK":
        note += f"Business key column is {hub.nk_col} (not PARENT_BK). "
    if not hub.applicable:
        note += "No live RAW key source in this project, so rows_in_scope = 0 is expected. " + "; ".join(hub.skipped) + "."
    else:
        note += common_note(hub)
    return dict(project=hub.project, hub=hub.name, status="Implemented",
                pass_criteria="null_key_status = PASS and ghost_record_status = PASS", note=note, queries=queries,
                extra_rows=[("Null / blank keys (count)", ""), ("Ghost record present (Y/N)", "")])


def k4(hub):
    sql = f"""select '{hub.name}' as hub, {hub.pk} as hash_key,
       count(*) as row_count, count(distinct {hub.nk_col}) as distinct_bk,
       min({hub.nk_col}) as sample_bk, listagg(distinct RECORD_SOURCE, ', ') as record_sources
  from {fq(hub)}
 group by {hub.pk}
having count(*) > 1
 order by row_count desc;"""
    return dict(project="SHARED", hub=hub.name, status="Implemented", pass_criteria="0 rows returned",
                note=f"(hash key {hub.pk}, business key {hub.nk_col}). Loaded by: {hub.loaders}.",
                queries=[("SQL query", sql)])


def k5(hub):
    if not hub.applicable:
        return na_section(hub, "DM-K5")
    sql = f"""with src as (
{src_union(hub, with_bk=False)}
),
keys as (
    select distinct src_branch, hkey from src where hkey is not null
)
select {proj_tag(hub)},
       coalesce(k.src_branch, '== TOTAL (distinct across branches) ==') as src_branch,
       count(distinct k.hkey)                          as source_distinct_keys,
       count(distinct h.{hub.pk})                as hub_present_keys,
       count(distinct k.hkey) - count(distinct h.{hub.pk}) as diff
  from keys k
  left join {fq(hub)} h
         on h.{hub.pk} = k.hkey
 group by grouping sets ((k.src_branch), ())
 order by grouping(k.src_branch) desc, k.src_branch;"""
    return dict(project=hub.project, hub=hub.name, status="Implemented",
                pass_criteria="diff = 0 on the TOTAL row", note=common_note(hub), queries=[("SQL query", sql)])


# ---------------------------------------------------------------------------------------
# Extra (cross-hub) sections
# ---------------------------------------------------------------------------------------
def k2_ownership(all_hub_names):
    unions = "\n        union all ".join(
        f"select '{h}' as hub, RECORD_SOURCE from {VAULT}.{h}" for h in all_hub_names)
    sql = f"""select hub, RECORD_SOURCE, count(*) as rows_not_covered
  from (
        {unions}
       )
 where not startswith(RECORD_SOURCE, 'MAXIMUS_')
   and not startswith(RECORD_SOURCE, 'OPUS_')
 group by hub, RECORD_SOURCE
 order by hub, RECORD_SOURCE;"""
    return dict(project="MAXIMUS + OPUS", hub="Ownership sweep (all hubs)", status="Informational",
                pass_criteria="0 rows, or only record sources of other known projects",
                note="Not part of the pass criterion. Rows whose RECORD_SOURCE is neither MAXIMUS_ nor OPUS_ are "
                     "not covered by the per-hub sections.", queries=[("SQL query", sql)])


def k3_detail(hubs):
    parts = []
    for h in hubs:
        parts.append(f"select {proj_tag(h)}, {h.pk} as hkey, {h.nk_col} as bk, RECORD_SOURCE, LOAD_DATETIME\n"
                     f"  from {fq(h)}\n"
                     f" where startswith(RECORD_SOURCE, '{h.prefix}') and ({h.pk} is null or nullif(trim({h.nk_col}), '') is null"
                     + (f" or regexp_like(trim({h.nk_col}), '^[:#|].*|.*[:#|]$')" if h.name not in DEGENERATE_EXEMPT else "")
                     + ")")
    sql = "\nunion all\n".join(parts) + "\norder by project, hub;"
    return dict(project="MAXIMUS + OPUS", hub="Null / blank / degenerate key detail (all hubs)", status="Drill-down",
                pass_criteria="0 rows when every null_key_status is PASS",
                note="Drill-down evidence behind any null_key_status = FAIL; not a separate criterion.",
                queries=[("SQL query", sql)])


def k4_bk_multi_hkey(shared):
    parts = [f"select '{h.name}' as hub, {h.nk_col} as bk, {h.pk} as hkey, RECORD_SOURCE from {fq(h)}"
             for h in shared]
    sql = ("with all_rows as (\n    " + "\n    union all\n    ".join(parts) + "\n)\n"
           "select hub, bk, count(distinct hkey) as distinct_hkeys,\n"
           "       listagg(distinct RECORD_SOURCE, ', ') as record_sources\n"
           "  from all_rows\n"
           " where bk is not null\n"
           " group by hub, bk\n"
           "having count(distinct hkey) > 1\n"
           " order by distinct_hkeys desc, hub, bk;")
    return dict(project="SHARED", hub="Same business key under more than one hash key", status="Informational",
                pass_criteria="0 rows",
                note="Not part of the K4 pass criterion. The hash is UPPER(TRIM(<NK>)), so case variants already "
                     "collapse; a hit means two loaders hash the SAME business key with a different NK prefix "
                     "(e.g. a double-prefixed NK), which splits one entity across hub rows in the shared vault.",
                queries=[("SQL query", sql)])


# ---------------------------------------------------------------------------------------
# Check metadata
# ---------------------------------------------------------------------------------------
HASH_TXT = "MD5_BINARY(NULLIF(UPPER(TRIM(CAST(<NK> AS VARCHAR))), '')) -- BINARY(16), automate_dv 0.11.5 default"
COMMON_OVERVIEW = [
    ("Owner", "LUMIQ"),
    ("Vault location", VAULT),
    ("Maximus RAW", RAW_SCHEMA["maximus_partner"]),
    ("Opus RAW (test)", RAW_SCHEMA["partner_test_raw"] + "  (prod: BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE)"),
]

CHECKS = OrderedDict([
    ("DM-K1", dict(
        title="DM-K1  |  Key Checks — No Missing Keys",
        subtitle="Hub key reconciliation (RAW source → hub). Pass criterion: 0 rows returned (0 missing business keys, or documented exceptions).",
        overview=[("Check ID", "DM-K1"), ("Category", "Key checks"), ("Sign-off criterion", "No missing keys"),
                  ("Method", "Anti-join: every RAW source branch of the hub → HUB, joined on the hash key alone"),
                  ("Pass criteria / tolerance", "0 missing keys (or documented exceptions)")] + COMMON_OVERVIEW + [
                  ("Hash key formula", HASH_TXT),
                  ("Scope (shared vault)", "Not scoped by RECORD_SOURCE: the hub is HKEY-deduplicated across projects, so a key is stored once under whichever project loaded it first."),
                  ("Output columns", "project, hub, missing_hkey, missing_bk, src_branches (one row per distinct missing key)")],
        builder=k1)),
    ("DM-K2", dict(
        title="DM-K2  |  Key Checks — No Extra / Unexpected Keys",
        subtitle="Hub key reconciliation (hub → RAW source). Pass criterion: 0 rows returned (0 unexpected business keys).",
        overview=[("Check ID", "DM-K2"), ("Category", "Key checks"), ("Sign-off criterion", "No extra / unexpected keys"),
                  ("Method", "Anti-join: HUB rows of the project → union of every RAW source branch of that hub"),
                  ("Pass criteria / tolerance", "0 unexpected keys")] + COMMON_OVERVIEW + [
                  ("Hash key formula", HASH_TXT),
                  ("Scope (shared vault)", "Hub rows filtered by RECORD_SOURCE prefix: MAXIMUS_ rows against Maximus RAW, OPUS_ rows against Opus RAW. The last section lists rows owned by neither."),
                  ("Output columns", "project, hub, unexpected_bk, unexpected_hkey, RECORD_SOURCE, LOAD_DATETIME")],
        builder=k2)),
    ("DM-K3", dict(
        title="DM-K3  |  Key Checks — No Null / Blank Business Keys",
        subtitle="Hub key integrity. Pass criterion: 0 null / blank keys loaded without a default, and a ghost / -1 record present per hub.",
        overview=[("Check ID", "DM-K3"), ("Category", "Key checks"), ("Sign-off criterion", "No null / blank business keys"),
                  ("Method", "(a) per hub, rows of the project's RECORD_SOURCE with a NULL hash key, NULL/blank business key or degenerate composite key, plus ghost-record check; (b) informational count of RAW rows dropped for a NULL key"),
                  ("Pass criteria / tolerance", "0 nulls loaded without default; ghost record exists")] + COMMON_OVERVIEW + [
                  ("Ghost record definition", f"hash key = {GHOST_HKEY} (automate_dv binary ghost) OR business key in ('-1', '-2')"),
                  ("placeholder_bk_info", "Informational only: business keys equal to ('NULL', 'NONE', 'NA', 'N/A', 'UNKNOWN', '0'). Not part of the status."),
                  ("Known design gap", "Neither project configures hub ghost records or null-key defaults. RAW rows with a NULL key are dropped (query b), not defaulted, so ghost_record_status is expected to FAIL until a ghost record is added or the gap is accepted as a documented exception.")],
        builder=k3)),
    ("DM-K4", dict(
        title="DM-K4  |  Key Checks — Business Key Uniqueness",
        subtitle="Hub grain integrity: no duplicate business keys within a hub. Pass criterion: 0 rows returned (hub row count = distinct business keys).",
        overview=[("Check ID", "DM-K4"), ("Category", "Key checks"), ("Sign-off criterion", "Business key uniqueness"),
                  ("Method", "Group hub by hash key; any hash key with count(*) > 1 is a grain violation"),
                  ("Pass criteria / tolerance", "Hub row count = distinct business keys (0 duplicate rows)"),
                  ("Owner", "LUMIQ"), ("Vault location", VAULT),
                  ("Scope", "Runs on the hub tables only. Hubs are shared between projects; each hub is checked once."),
                  ("Interpreting a hit", "row_count > 1 & distinct_bk = 1 = duplicate load; distinct_bk > 1 = hash collision")],
        builder=k4)),
    ("DM-K5", dict(
        title="DM-K5  |  Completeness — Row-count Completeness",
        subtitle="Source record count reconciles to hub load counts for the agreed data cut. Pass criterion: diff = 0 on the TOTAL row (match within agreed tolerance).",
        overview=[("Check ID", "DM-K5"), ("Category", "Completeness"), ("Sign-off criterion", "Row-count completeness"),
                  ("Method", "Distinct RAW source keys vs those present in the hub, per source branch and in total (GROUPING SETS)"),
                  ("Pass criteria / tolerance", "diff = 0 on the TOTAL row (match within agreed tolerance)")] + COMMON_OVERVIEW + [
                  ("Hash key formula", HASH_TXT),
                  ("Coverage", "Hub load counts. Satellite load-count reconciliation is not covered by these queries."),
                  ("Output columns", "project, hub, src_branch, source_distinct_keys, hub_present_keys, diff")],
        builder=k5)),
])


# ---------------------------------------------------------------------------------------
# Writers
# ---------------------------------------------------------------------------------------
def wrap(text, width=86, prefix="-- ", cont=None):
    cont = prefix if cont is None else cont
    words, lines, cur = text.split(), [], ""
    for w in words:
        if cur and len(cur) + 1 + len(w) > width:
            lines.append((cont if lines else prefix) + cur)
            cur = w
        else:
            cur = f"{cur} {w}" if cur else w
    if cur:
        lines.append((cont if lines else prefix) + cur)
    return "\n".join(lines)


def write_sql(check_id, meta, sections, revision, generator="gen_dm_k.py"):
    bar = "=" * 85
    out = [f"/* {bar}", f"   {meta['title'].replace('—', '-')}", f"   {meta['subtitle'].replace('→', '->')}", ""]
    for k, v in meta["overview"]:
        out.append(wrap(f"{k}: {v}".replace("→", "->").replace("—", "-"), 84, "   ", "       "))
    out += ["", f"   GENERATED by validation/tools/{generator} from the current dbt models -- edit the generator,",
            "   not this file. The queries are IDENTICAL to those in the matching .docx.", ""]
    out += ["   Revision notes:"] + [wrap(r, 84, "   - ", "     ") for r in revision]
    out.append(f"   {bar} */")
    for i, s in enumerate(sections, 1):
        out += ["", "", "-" * 88, f"-- {i}. {s['project']} — {s['hub']}   [{s['status']}]"]
        if s.get("note"):
            out.append(wrap(s["note"]))
        out.append("-" * 88)
        for label, q in s["queries"]:
            if len(s["queries"]) > 1:
                out.append(f"-- {label}")
            out.append(q)
            out.append("")
    (VALIDATION / f"{check_id}.sql").write_text("\n".join(out).rstrip() + "\n")


def x(t):
    return html.escape(t, quote=False)


def p(text="", style=None, bold=False, italic=False):
    ppr = f'<w:pPr><w:pStyle w:val="{style}"/></w:pPr>' if style else ""
    rpr = "".join(["<w:b/>" if bold else "", "<w:i/>" if italic else ""])
    rpr = f"<w:rPr>{rpr}</w:rPr>" if rpr else ""
    if not text:
        return f"<w:p>{ppr}</w:p>"
    return f'<w:p>{ppr}<w:r>{rpr}<w:t xml:space="preserve">{x(text)}</w:t></w:r></w:p>'


def p_note(label, text):
    return (f'<w:p><w:r><w:rPr><w:b/></w:rPr><w:t xml:space="preserve">{x(label)} </w:t></w:r>'
            f'<w:r><w:t xml:space="preserve">{x(text)}</w:t></w:r></w:p>')


TBL_LOOK = '<w:tblLook w:firstColumn="1" w:firstRow="1" w:lastColumn="0" w:lastRow="0" w:noHBand="0" w:noVBand="1" w:val="04A0"/>'


def cell(content_xml, w):
    return f'<w:tc><w:tcPr><w:tcW w:type="dxa" w:w="{w}"/></w:tcPr>{content_xml}</w:tc>'


def kv_table(rows):
    trs = []
    for k, v in rows:
        trs.append("<w:tr>" + cell(p(k, bold=True), 3000) + cell(p(v) if v else "<w:p><w:r/></w:p>", 5640) + "</w:tr>")
    return (f'<w:tbl><w:tblPr><w:tblStyle w:val="LightList-Accent1"/><w:tblW w:type="auto" w:w="0"/>{TBL_LOOK}</w:tblPr>'
            f'<w:tblGrid><w:gridCol w:w="3000"/><w:gridCol w:w="5640"/></w:tblGrid>{"".join(trs)}</w:tbl>')


def grid_table(header, rows, widths):
    def tr(vals, bold=False):
        return "<w:tr>" + "".join(cell(p(v, bold=bold) if v else "<w:p><w:r/></w:p>", w) for v, w in zip(vals, widths)) + "</w:tr>"
    grid = "".join(f'<w:gridCol w:w="{w}"/>' for w in widths)
    return (f'<w:tbl><w:tblPr><w:tblStyle w:val="LightList-Accent1"/><w:tblW w:type="auto" w:w="0"/>{TBL_LOOK}</w:tblPr>'
            f'<w:tblGrid>{grid}</w:tblGrid>{tr(header, True)}{"".join(tr(r) for r in rows)}</w:tbl>')


def box(inner):
    return (f'<w:tbl><w:tblPr><w:tblStyle w:val="TableGrid"/><w:tblW w:type="auto" w:w="0"/>{TBL_LOOK}</w:tblPr>'
            f'<w:tblGrid><w:gridCol w:w="8640"/></w:tblGrid>{inner}</w:tbl>')


def code_box(sql):
    runs = "<w:br/>".join(f'<w:t xml:space="preserve">{x(l)}</w:t>' for l in sql.split("\n"))
    para = f'<w:p><w:r><w:rPr><w:rFonts w:ascii="Consolas" w:hAnsi="Consolas"/><w:sz w:val="17"/></w:rPr>{runs}</w:r></w:p>'
    return box("<w:tr>" + cell(para, 8640) + "</w:tr>")


def output_box():
    return box("<w:tr>" + cell(p("Output:", italic=True), 8640) + "</w:tr>"
               "<w:tr>" + cell("<w:p><w:r><w:br/><w:br/><w:br/></w:r></w:p>", 8640) + "</w:tr>")


def write_docx(check_id, meta, sections, revision, template_bytes,
               obj_col="Hub", obj_label="Hub table", rows_col="Rows / diff"):
    body = [p(meta["title"], "Title"), p(meta["subtitle"], italic=True), p("Check Overview", "Heading1"),
            kv_table(meta["overview"]), p(), p("Revision notes", "Heading1")]
    body += [p("• " + r) for r in revision]
    body += [p("Results summary", "Heading1"),
             grid_table(["#", "Project", obj_col, "Status", "Result", rows_col],
                        [[str(i), s["project"], s["hub"], s["status"], "", ""] for i, s in enumerate(sections, 1)],
                        [500, 1500, 3140, 1300, 1100, 1100]),
             p(), p("Validation Queries", "Heading1")]
    for i, s in enumerate(sections, 1):
        rows = [("Project", s["project"]), (obj_label, s["hub"]), ("Status", s["status"]),
                ("Pass criteria", s["pass_criteria"]), ("Result (Pass / Fail / NA)", "NA" if s["status"] == "NA" else ""),
                ("Rows returned (count)", "")] + s.get("extra_rows", []) + [("Remarks", "")]
        body += [p(f"{i}. {s['project']} — {s['hub']}", "Heading2"), kv_table(rows), p()]
        if s.get("note"):
            body.append(p_note("Note:", s["note"]))
        for label, q in s["queries"]:
            body += [p(label, bold=True), code_box(q)]
        body += [p("Query output (attach / paste below)", bold=True), output_box(), p()]
    with zipfile.ZipFile(__import__("io").BytesIO(template_bytes)) as zt:
        doc_xml = zt.read("word/document.xml").decode()
        head = doc_xml[: doc_xml.index("<w:body>") + len("<w:body>")]
        sect = re.search(r"<w:sectPr.*?</w:sectPr>", doc_xml, re.S).group(0)
        new_doc = head + "".join(body) + sect + "</w:body></w:document>"
        out_path = VALIDATION / f"{check_id}.docx"
        tmp = out_path.with_suffix(".docx.tmp")
        with zipfile.ZipFile(tmp, "w", zipfile.ZIP_DEFLATED) as zo:
            for item in zt.infolist():
                if item.filename == "docProps/thumbnail.jpeg":
                    continue
                data = new_doc.encode() if item.filename == "word/document.xml" else zt.read(item.filename)
                if item.filename == "_rels/.rels":
                    data = re.sub(rb'<Relationship[^>]*thumbnail[^>]*/>', b"", data)
                if item.filename == "[Content_Types].xml":
                    data = re.sub(rb'<Default Extension="jpeg"[^>]*/>', b"", data)
                if item.filename == "docProps/core.xml":
                    data = re.sub(rb"<dc:title/>|<dc:title>.*?</dc:title>",
                                  f"<dc:title>{x(meta['title'])}</dc:title>".encode(), data)
                    data = re.sub(rb"<dcterms:modified([^>]*)>[^<]*</dcterms:modified>",
                                  rb"<dcterms:modified\1>2026-10-09T00:00:00Z</dcterms:modified>", data)
                zo.writestr(item, data)
        shutil.move(tmp, out_path)


# ---------------------------------------------------------------------------------------
def main():
    template = (VALIDATION / "DM-K4.docx").read_bytes() if len(sys.argv) < 2 else Path(sys.argv[1]).read_bytes()
    order = ["HUB_PARTY", "HUB_STAKE_CODE", "HUB_AGENT", "HUB_AGREEMENT", "HUB_CLAIM", "HUB_LOCATION",
             "HUB_PAYMENT_INSTRUMENT", "HUB_PRODUCT", "HUB_FINANCIAL_ACCOUNT", "HUB_DOCUMENT", "HUB_POLICY",
             "HUB_DISTRIBUTION_CHANNEL", "HUB_ORG_UNIT", "HUB_RISK_OBJECT"]
    rank = lambda h: order.index(h.name) if h.name in order else len(order)
    maxi, opus = sorted(build_maxi(), key=rank), sorted(build_opus(), key=rank)
    project_hubs = maxi + opus

    # shared hubs (K4): one entry per physical table, listing its loaders
    shared = OrderedDict()
    for h in project_hubs:
        if h.name not in shared:
            shared[h.name] = h
            h.loaders = h.project
        else:
            shared[h.name].loaders += f", {h.project}"

    o = {h.name: h for h in opus}
    m = {h.name: h for h in maxi}
    kyc_party = sum(1 for b in o["HUB_PARTY"].branches if "KYC" in b.table)
    revision = [
        "Regenerated 2026-10-09 from the current opus_partner_dv_dbt and maximus_partner_dv_dbt models; "
        "previous results (rows, screenshots, Pass/Fail) are cleared and must be re-run.",
        f"Scope: {len(maxi)} MAXIMUS hubs + {len(opus)} OPUS hubs = {len(project_hubs)} project-hub sections "
        f"({len(shared)} physical hub tables).",
        f"OPUS new hubs: HUB_DOCUMENT ({len(o['HUB_DOCUMENT'].branches)} KYC branches) and HUB_ORG_UNIT "
        f"({len(o['HUB_ORG_UNIT'].branches)} KYC branches).",
        f"OPUS HUB_PARTY: CP_PARTNERS plus {kyc_party} KYC key branches (PAN:/GSTIN:/LICENCE:/PASSPORT:/VOTER:/"
        f"CKYC:/CATEGORY:INPUT key forms).",
        f"OPUS HUB_POLICY ({len(o['HUB_POLICY'].branches)} RAW branches incl. KYC POLICY% field_value and the "
        f"stitch_policy_header / stitch_policy_bonus_tracking keys), HUB_LOCATION ({len(o['HUB_LOCATION'].branches)} "
        f"branches incl. stitch_common_address and the KYC composite address keys) and HUB_PRODUCT "
        f"(stitch_product_definition) are now fully implemented -- no TODO branches remain.",
        "MAXIMUS: RAW table ..._SIMPLE_PROPERTY_PIVOT_VW (no _2_1 suffix) after the RECORD_SOURCE fix; HUB_PARTY "
        f"hubfeed branches resolve to {len(m['HUB_PARTY'].branches)} RAW keys; HUB_FINANCIAL_ACCOUNT remains NA "
        "(account_code not mapped).",
        "Hash reproduced exactly as automate_dv 0.11.5 does: MD5_BINARY(NULLIF(UPPER(TRIM(CAST(<NK> AS VARCHAR))), '')).",
        "Excluded (loads nothing): disabled placeholder stg2_hub_bjaz_t_kyc_details__party__kyc_subject; MAXIMUS "
        "branch_code (ORG_UNIT) and account_code (FINANCIAL_ACCOUNT) are cast(null) in staging.",
    ]

    for cid, meta in CHECKS.items():
        if cid == "DM-K4":
            sections = [k4(h) for h in shared.values()] + [k4_bk_multi_hkey(list(shared.values()))]
        else:
            sections = [meta["builder"](h) for h in project_hubs]
            if cid == "DM-K2":
                sections.append(k2_ownership(list(shared.keys())))
            if cid == "DM-K3":
                sections.append(k3_detail(project_hubs))
        write_sql(cid, meta, sections, revision)
        write_docx(cid, meta, sections, revision, template)
        print(f"{cid}: {len(sections)} sections written")

    for h in project_hubs:
        print(f"  {h.project:8} {h.name:26} branches={len(h.branches):3} skipped={len(h.skipped)}")


if __name__ == "__main__":
    main()
