#!/usr/bin/env python3
"""
Generate the DM-A1 / DM-A2 sign-off validation SQL + DOCX (satellite attribute checks) for the
MAXIMUS and OPUS partner Data Vault projects.

Every satellite payload column is traced through the dbt models it is loaded by
(sat -> stg2 stage / wrapper / unpivot / stitch -> layer-1 stg_ -> RAW column) and rewritten
as an expression over the RAW (SF Mirror) table, so the checks compare the vault against
what the models are DESIGNED to load from source -- never a hand-typed mapping.
Re-run after any model change:

    python3 BGIL_DBT/validation/tools/gen_dm_a.py

Outputs (overwritten): BGIL_DBT/validation/DM-A1.sql, DM-A1.docx, DM-A2.sql, DM-A2.docx
Shares parsing helpers and the .docx writer with gen_dm_k.py.
"""
import re
import sys
from collections import OrderedDict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import gen_dm_k as K  # noqa: E402

VAULT = K.VAULT
VAULT_DB, VAULT_SCHEMA = VAULT.split(".")
SAMPLE_SIZE = 100            # agreed DM-A2 sample: (hash key, record source) units per satellite
SAMPLE_SEED = "DM-A"         # deterministic sample -- same units on every re-run
PROJECTS = OrderedDict([("MAXIMUS", K.MAXI), ("OPUS", K.OPUS)])

# ---------------------------------------------------------------------------------------
# Expression rewriting
# ---------------------------------------------------------------------------------------
_TOKEN = re.compile(r"'(?:[^']|'')*'|\"[^\"]*\"|\b[A-Za-z_][A-Za-z0-9_]*\b")
KEYWORDS = {
    "case", "when", "then", "else", "end", "and", "or", "not", "is", "null", "like", "ilike", "as",
    "in", "between", "varchar", "number", "string", "text", "date", "timestamp_ntz", "boolean",
    "true", "false", "distinct", "over", "partition", "by", "order", "asc", "desc", "nulls",
    "first", "last", "from", "select", "where",
}


def simple(expr):
    return bool(re.fullmatch(r"\s*(\"[^\"]*\"|[A-Za-z_][A-Za-z0-9_]*|'(?:[^']|'')*'|[A-Za-z_][A-Za-z0-9_]*\(.*\))\s*",
                             expr, re.S)) and expr.count("(") == expr.count(")")


def subst(expr, cols):
    """Replace every bare identifier that is a column of the parent relation by its expression."""
    out, i = [], 0
    for m in _TOKEN.finditer(expr):
        out.append(expr[i:m.start()])
        tok = m.group(0)
        nxt = expr[m.end():].lstrip()[:1]
        low = tok.lower()
        if tok[0] in "'\"" or nxt == "(" or low in KEYWORDS or low not in cols:
            out.append(tok)
        else:
            e = cols[low]
            out.append(e if simple(e) else f"({e})")
        i = m.end()
    out.append(expr[i:])
    return "".join(out)


def split_top(text, sep=","):
    """Split on a separator at paren depth 0, ignoring quoted text."""
    parts, depth, cur, i = [], 0, [], 0
    while i < len(text):
        c = text[i]
        if c in "'\"":
            j = text.index(c, i + 1)
            while c == "'" and text[j + 1: j + 2] == "'":
                j = text.index(c, j + 2)
            cur.append(text[i:j + 1])
            i = j + 1
            continue
        if c == "(":
            depth += 1
        elif c == ")":
            depth -= 1
        if c == sep and depth == 0:
            parts.append("".join(cur))
            cur = []
        else:
            cur.append(c)
        i += 1
    parts.append("".join(cur))
    return [p.strip() for p in parts if p.strip()]


def select_items(text):
    """'expr as name, ...' -> OrderedDict(name -> expr) (lower-case names)."""
    items = OrderedDict()
    for it in split_top(text):
        it = re.sub(r"--[^\n]*", "", it).strip()
        m = re.match(r"^(.*?)\s+as\s+\"?([A-Za-z0-9_]+)\"?$", it, re.S | re.I)
        if m:
            items[m.group(2).lower()] = m.group(1).strip()
        elif re.fullmatch(r"[A-Za-z_][A-Za-z0-9_.]*", it):
            items[it.split(".")[-1].lower()] = it.split(".")[-1]
        else:
            raise ValueError(f"cannot parse select item: {it!r}")
    return items


def raw_columns(expr):
    """Quoted RAW column names referenced by a fully rewritten expression."""
    return list(OrderedDict.fromkeys(re.findall(r"\"([^\"]+)\"", re.sub(r"'(?:[^']|'')*'", "", expr))))


# ---------------------------------------------------------------------------------------
# Lineage resolution: model -> list of Src (one per RAW row set)
# ---------------------------------------------------------------------------------------
class Stitch:
    """An Opus stitch_* view, reproduced from RAW (no watermark window)."""

    def __init__(self, name, sources, output_columns, coalesce_rules, unique_key):
        self.name, self.sources, self.output_columns = name, sources, output_columns
        self.coalesce_rules, self.unique_key = coalesce_rules, unique_key


class Src:
    def __init__(self, raw, cols, where=None, via=None, stitch=None):
        self.raw = raw              # fully-qualified RAW table (None for a stitch)
        self.cols = cols            # lower-case column -> expression over RAW / stitch output
        self.where = list(where or [])
        self.via = list(via or [])
        self.stitch = stitch

    def derive(self, cols, where=(), via=None):
        return Src(self.raw, cols, self.where + list(where), ([via] if via else []) + self.via, self.stitch)

    @property
    def table(self):
        return self.raw.split(".")[-1] if self.raw else f"stitch {self.stitch.name}"


_resolved = {}


def resolve(models_dir, name):
    key = (models_dir, name)
    if key in _resolved:
        return _resolved[key]
    sql = K.read(K.find_model(models_dir, name))
    if K.is_disabled(sql):
        res = []
    elif name.startswith(("stg_maximus__", "stg_partner__")):
        raw, cols = K.parse_stg(models_dir, name)
        res = [Src(raw, {k: v for k, v in cols.items()}, via=[name])]
    elif name.startswith("stitch_"):
        res = [resolve_stitch(models_dir, name, sql)]
    elif "yaml_metadata" in sql and "automate_dv.stage" in sql:
        res = resolve_stage(models_dir, name, sql)
    elif name.startswith("unpivot"):
        res = resolve_select(models_dir, name, sql, union=True)
    else:
        res = resolve_select(models_dir, name, sql, union=False)
    _resolved[key] = res
    return res


def resolve_stage(models_dir, name, sql):
    meta = K.yaml_block(sql)
    isc = re.search(r"include_source_columns\s*=\s*(\w+)", sql)
    include_src = (isc.group(1).lower() == "true") if isc else True
    out = []
    for parent in resolve(models_dir, meta["source_model"]):
        pc = parent.cols
        cols = OrderedDict(pc) if include_src else OrderedDict()
        derived = OrderedDict()
        for c, v in (meta.get("derived_columns") or {}).items():
            if not isinstance(v, str):
                raise SystemExit(f"{name}: derived column {c} is not a string expression")
            derived[c.lower()] = f"'{v[1:]}'" if v.startswith("!") else subst(v, pc)
        cols.update(derived)
        both = OrderedDict(pc)
        both.update(derived)
        for c, v in (meta.get("hashed_columns") or {}).items():
            if isinstance(v, dict):
                continue  # hashdiff -- not needed, payload is compared column by column
            if not isinstance(v, str):
                raise SystemExit(f"{name}: composite hashed column {c} not supported")
            cols[c.lower()] = K.hkey_sql(subst(v, both))
        out.append(parent.derive(cols, via=name))
    return out


def resolve_select(models_dir, name, sql, union):
    body = re.sub(r"\{\{\s*config\(.*?\)\s*\}\}", "", sql, flags=re.S)
    body = re.sub(r"--[^\n]*", "", body)
    arms = re.split(r"\bunion\s+all\b", body, flags=re.I) if union else [body]
    out = []
    for arm in arms:
        m = re.search(r"\bselect\b(.*?)\bfrom\s*\{\{\s*ref\('([^']+)'\)\s*\}\}(.*)$", arm, re.S | re.I)
        if not m:
            raise SystemExit(f"{name}: cannot parse select arm")
        items, parent_name, tail = select_items(m.group(1)), m.group(2), m.group(3)
        w = re.search(r"\bwhere\b(.*)$", tail, re.S | re.I)
        if not w and tail.strip():
            raise SystemExit(f"{name}: unexpected trailing SQL {tail.strip()[:60]!r}")
        for parent in resolve(models_dir, parent_name):
            cols = OrderedDict((k, subst(v, parent.cols)) for k, v in items.items())
            where = [subst(w.group(1).strip(), parent.cols)] if w else []
            out.append(parent.derive(cols, where, via=name))
    return out


def resolve_stitch(models_dir, name, sql):
    src_txt = re.search(r"set sources\s*=\s*(\[.*?\])\s*-?%\}", sql, re.S).group(1)
    sources = eval(src_txt, {"__builtins__": {}}, {"none": None, "None": None})  # literal list of dicts
    outc = eval(re.search(r"set output_columns\s*=\s*(\[.*?\])\s*-?%\}", sql, re.S).group(1), {"__builtins__": {}})
    rules = eval(re.search(r"set coalesce_rules\s*=\s*(\{.*?\})\s*%\}", sql, re.S).group(1), {"__builtins__": {}})
    uk = re.search(r"unique_key\s*=\s*'([^']+)'", sql)
    uk = uk.group(1) if uk else "parent_bk"
    resolved = []
    for s in sources:
        parents = resolve(models_dir, s["model"])
        if len(parents) != 1 or parents[0].where:
            raise SystemExit(f"{name}: stitch source {s['model']} is not a single unfiltered RAW table")
        pc = parents[0].cols
        resolved.append(dict(
            alias=s["alias"], raw=parents[0].raw, tag=s["source_tag"], model=s["model"],
            key=subst(s["key_column"], pc), ldts=subst(s["ldts_column"], pc),
            columns=OrderedDict((c["tgt"].lower(), f"nullif(trim(to_varchar({subst(c['src'], pc)})), '')")
                                for c in s["columns"]),
            raw_columns=OrderedDict((c["tgt"].lower(), subst(c["src"], pc)) for c in s["columns"]),
        ))
    st = Stitch(name, resolved, [c.lower() for c in outc], {k.lower(): v for k, v in rules.items()}, uk.lower())
    cols = OrderedDict((c, f'"{c.upper()}"')
                       for c in [st.unique_key] + st.output_columns + ["record_source", "inc_job_updated_at"])
    return Src(None, cols, via=[name], stitch=st)


# ---------------------------------------------------------------------------------------
# Satellite specs
# ---------------------------------------------------------------------------------------
class Branch:
    """One RAW row set feeding a satellite, with every sat column as an expression over RAW."""

    def __init__(self, src, stage, pk, rs, ldts, payload, cdk):
        self.src, self.stage = src, stage
        self.pk, self.rs, self.ldts = pk, rs, ldts
        self.payload = payload      # OrderedDict sat column -> expr (None = loaded as NULL)
        self.cdk = cdk              # OrderedDict cdk column -> expr

    @property
    def stitch(self):
        return self.src.stitch

    @property
    def rs_const(self):
        m = re.fullmatch(r"'([^']*)'", self.rs.strip())
        return m.group(1) if m else None

    @property
    def label(self):
        return self.src.table + (" (filtered)" if self.src.where else "")

    @property
    def via(self):
        return " <- ".join(self.src.via)


class Sat:
    def __init__(self, project, model, macro, pk, payload, cdk, branches, objects, notes, warnings):
        self.project, self.model, self.macro = project, model, macro
        self.name = model.upper()
        self.pk, self.payload, self.cdk = pk, payload, cdk
        self.branches, self.objects = branches, objects
        self.notes, self.warnings = notes, warnings

    @property
    def multi_active(self):
        return bool(self.cdk)

    @property
    def prefix(self):
        return f"{self.project}"

    @property
    def mode(self):
        if self.objects:
            return "object"
        return "multi-active" if self.multi_active else "single-active"

    @property
    def columns(self):
        return list(self.cdk) + list(self.payload)


def parse_list_arg(sql, arg):
    m = re.search(arg + r"\s*=\s*\[([^\]]*)\]", sql)
    return re.findall(r"'([^']+)'", m.group(1)) if m else []


def parse_column_map(sql):
    m = re.search(r"src_column_map\s*=\s*\{", sql)
    if not m:
        return None
    depth, i = 1, m.end()
    while depth:
        depth += {"{": 1, "}": -1}.get(sql[i], 0)
        i += 1
    block = sql[m.end(): i - 1]
    return {k: re.findall(r"'([^']+)'", v) for k, v in re.findall(r"'([^']+)'\s*:\s*\[([^\]]*)\]", block)}


def build_sat(project, models_dir, path):
    sql = K.read(path)
    meta = K.yaml_block(sql)
    macro = re.search(r"\b(automate_dv\.ma_sat|automate_dv\.sat|ma_sat_multi_source|sat_multi_source)\s*\(", sql).group(1)
    srcs = meta["source_model"]
    srcs = [srcs] if isinstance(srcs, str) else list(srcs)
    payload = list(meta["src_payload"])
    cdk = meta.get("src_cdk") or []
    cdk = [cdk] if isinstance(cdk, str) else list(cdk)
    pk, ldts = meta["src_pk"], meta["src_ldts"]
    multi = macro in ("sat_multi_source", "ma_sat_multi_source") and len(srcs) > 1
    colmap = parse_column_map(sql) if multi else None
    objects = parse_list_arg(sql, "src_object_columns") if multi else []
    branches, notes, warnings = [], [], []
    for m in srcs:
        resolved = resolve(models_dir, m)
        if not resolved:
            notes.append(f"{m}: disabled placeholder (enabled=false) -> loads nothing")
            continue
        for s in resolved:
            if any(re.fullmatch(r"nullif\(trim\(to_varchar\(cast\(null as \w+\)\)\), ''\) is not null", w.strip(), re.I)
                   for w in s.where):
                notes.append(f"{' <- '.join(s.via[:2])}: unpivot arm filters on a column that is cast(null) in "
                             f"staging -> contributes no rows")
                continue
            c = s.cols
            pay = OrderedDict()
            for col in payload:
                have = c.get(col.lower())
                if multi:
                    allowed = (col in colmap.get(m, [])) if colmap is not None else (have is not None)
                    if not allowed and have is not None and not re.fullmatch(r"cast\(null as \w+\)", have.strip(), re.I):
                        warnings.append(f"{col}: mapped in {m} but excluded by src_column_map -> loaded as NULL from that source")
                    pay[col] = have if allowed else None
                else:
                    if have is None:
                        raise SystemExit(f"{path.stem}: payload {col} not produced by {m}")
                    pay[col] = have
                if pay[col] is not None and re.fullmatch(r"cast\(null as \w+\)", pay[col].strip(), re.I):
                    pay[col] = None
            ck = OrderedDict((col, c[col.lower()]) for col in cdk)
            branches.append(Branch(s, m, c[pk.lower()], c["record_source"], c[ldts.lower()], pay, ck))
    return Sat(project, path.stem, macro, pk, payload, cdk, branches, objects,
               list(OrderedDict.fromkeys(notes)), list(OrderedDict.fromkeys(warnings)))


def build_all():
    sats = []
    for project, models_dir in PROJECTS.items():
        for path in sorted((models_dir / "raw_vault").rglob("sat_*.sql")):
            if "satellites" in path.parts:
                sats.append(build_sat(project, models_dir, path))
    return sats




# ---------------------------------------------------------------------------------------
# Static transform flags (what the models do to a value between RAW and the sat)
# ---------------------------------------------------------------------------------------
def _calls(expr, fn):
    """Argument strings of every call to fn(...) in expr."""
    out = []
    for m in re.finditer(r"\b" + fn + r"\s*\(", expr, re.I):
        depth, i = 1, m.end()
        while depth and i < len(expr):
            depth += {"(": 1, ")": -1}.get(expr[i], 0)
            i += 1
        out.append(expr[m.end(): i - 1])
    return out


def transform_flags(expr, n_raw, varchar_sat):
    e = re.sub(r"'(?:[^']|'')*'", "''", expr)
    flags = []
    if re.search(r"\btrim\s*\(", e, re.I):
        flags.append("TRIM")
    if re.search(r"\bnullif\s*\(", e, re.I):
        flags.append("BLANK->NULL")
    if re.search(r"\bupper\s*\(", e, re.I):
        flags.append("UPPER")
    scale0 = any(len(split_top(a)) == 1 for f in ("try_to_number", "to_number", "try_to_decimal", "to_decimal")
                 for a in _calls(e, f))
    scale0 |= bool(re.search(r"::\s*(number|int|integer|decimal|numeric)\b(?!\s*\()", e, re.I))
    scale0 |= bool(re.search(r"\bas\s+(number|int|integer|decimal|numeric)\s*\)", e, re.I))
    if scale0:
        flags.append("SCALE0")
    if re.search(r"::\s*timestamp|\bto_timestamp|\btry_to_timestamp", e, re.I):
        flags.append("TO_TIMESTAMP")
    if re.search(r"::\s*date\b|\bto_date\s*\(|\btry_to_date\s*\(", e, re.I):
        flags.append("TO_DATE")
    if re.search(r"\bcoalesce\s*\(", e, re.I) and n_raw > 1:
        flags.append("COALESCE")
    if re.search(r"\bcase\b", e, re.I):
        flags.append("CASE")
    if varchar_sat:
        flags.append("SAT_VARCHAR")
    return ", ".join(flags)


def short(expr, n=180):
    e = re.sub(r"\s+", " ", expr).strip()
    return e if len(e) <= n else e[: n - 3] + "..."


def q(s):
    return s.replace("'", "''")


# ---------------------------------------------------------------------------------------
# Lineage rows (DM-A1 a) and direct 1:1 columns (DM-A1 b)
# ---------------------------------------------------------------------------------------
def stitch_cols_in(expr, st):
    return [c for c in st.output_columns if f'"{c.upper()}"' in expr]


def lineage(sat):
    """[(sat_col, raw_fq_table, raw_col, flags, transform)] -- distinct."""
    rows, seen = [], set()
    varchar_sat = sat.macro in ("sat_multi_source", "ma_sat_multi_source") and len(
        {b.stage for b in sat.branches}) > 1

    def add(col, raw, expr):
        rc = raw_columns(expr)
        top = re.fullmatch(r"\s*\(?\s*coalesce\s*\((.*)\)\s*\)?\s*", expr, re.S | re.I)
        args = split_top(top.group(1)) if top and len(rc) > 1 else []
        for r in rc:
            key = (col, raw, r)
            if key not in seen:
                seen.add(key)
                part = next((a for a in args if f'"{r}"' in a), None)
                flags = transform_flags(part, 1, varchar_sat) if part else transform_flags(expr, len(rc), varchar_sat)
                if part:
                    flags = ", ".join(["COALESCE"] + [f for f in flags.split(", ") if f])
                rows.append((col, raw, r, flags, short(part or expr)))

    for b in sat.branches:
        for col, expr in list(b.cdk.items()) + list(b.payload.items()):
            if expr is None:
                continue
            if b.stitch:
                for sc in stitch_cols_in(expr, b.stitch):
                    for s in b.stitch.sources:
                        if sc in s["raw_columns"] and s["alias"] in b.stitch.coalesce_rules.get(sc, []):
                            add(col, s["raw"], s["columns"][sc])
            else:
                add(col, b.src.raw, expr)
    return rows


def direct_sources(sat, cols):
    """Per RAW row set: (hkey expr, rs_key expr, from, where list, {sat_col: raw column expr}) for 1:1 columns."""
    out = []
    for b in sat.branches:
        if b.stitch:
            for s in b.stitch.sources:
                m = OrderedDict()
                for col in cols:
                    expr = b.payload.get(col) or b.cdk.get(col)
                    if expr is None or not re.fullmatch(r'\s*"[A-Z0-9_]+"\s*', expr):
                        continue
                    sc = expr.strip()[1:-1].lower()
                    if sc in s["raw_columns"] and s["alias"] in b.stitch.coalesce_rules.get(sc, []):
                        rc = raw_columns(s["raw_columns"][sc])
                        if len(rc) == 1 and "coalesce" not in s["raw_columns"][sc].lower():
                            m[col] = f'"{rc[0]}"'
                if m:
                    hk = b.pk.replace(f'"{b.stitch.unique_key.upper()}"', f"({s['key']})")
                    out.append(dict(hkey=hk, rs_key="'STITCH'", frm=s["raw"], where=[], cols=m,
                                    label=f"{s['raw'].split('.')[-1]} (stitch {b.stitch.name} {s['alias']})"))
            continue
        m = OrderedDict()
        for col in cols:
            expr = b.payload.get(col) if col in b.payload else b.cdk.get(col)
            if expr is None:
                continue
            rc = raw_columns(expr)
            if len(rc) == 1 and not re.search(r"\b(coalesce|case)\b", expr, re.I):
                m[col] = f'"{rc[0]}"'
        if m:
            out.append(dict(hkey=b.pk, rs_key=rs_key_src(sat, b), frm=b.src.raw, where=b.src.where, cols=m,
                            label=b.label))
    return out


# ---------------------------------------------------------------------------------------
# SQL fragments shared by DM-A1 (b) and DM-A2
# ---------------------------------------------------------------------------------------
def group_of(sat):
    return sat.project


def rs_key_src(sat, b):
    if sat.objects:
        return f"'{group_of(sat)}'"
    return "'STITCH'" if b.stitch else b.rs


def rs_key_sat(sat):
    if sat.objects or not any(b.stitch for b in sat.branches):
        return "RECORD_SOURCE"
    consts = sorted({b.rs_const for b in sat.branches if not b.stitch})
    if not consts:
        return "'STITCH'"
    return "iff(RECORD_SOURCE in (" + ", ".join(f"'{c}'" for c in consts) + "), RECORD_SOURCE, 'STITCH')"


def obj(pairs, indent):
    """object_construct_keep_null over (key, expr) pairs, one per line."""
    if not pairs:
        return "object_construct_keep_null()"
    body = (",\n" + indent + "    ").join(f"'{k}', {v}" for k, v in pairs)
    return f"object_construct_keep_null(\n{indent}    {body}\n{indent})"


def sample_ctes(sat, cols):
    """sat_rows -> current_rows -> sample_units -> sample_keys -> sat_sample (+ sat_cols)."""
    ind = " " * 11
    o = obj([(c, f'to_varchar(s."{c}")') for c in cols], ind)
    return f"""sat_rows as (
    -- this project's rows of the satellite
    select s.{sat.pk} as hkey, s.RECORD_SOURCE as rs, {rs_key_sat(sat).replace('RECORD_SOURCE', 's.RECORD_SOURCE')} as rs_key,
           s.LOAD_DATETIME as ldts,
           {o} as obj
      from {VAULT}.{sat.name} s
     where startswith(s.RECORD_SOURCE, '{sat.prefix}')
),
current_rows as (
    -- current state per (hash key, record source) = rows at the latest LOAD_DATETIME
    select * from sat_rows
    qualify rank() over (partition by hkey, rs order by ldts desc) = 1
),
sample_units as (
    -- agreed sample: {SAMPLE_SIZE} (hash key, record source) units, deterministic (same units every re-run)
    select hkey, rs, rs_key
      from (select distinct hkey, rs, rs_key from current_rows)
    qualify row_number() over (order by md5(to_varchar(hkey) || '|' || rs || '|{SAMPLE_SEED}')) <= {SAMPLE_SIZE}
),
sample_keys as (
    select distinct hkey from sample_units
),
sat_sample as (
    select c.*, row_number() over (order by c.hkey, c.rs, c.ldts) as sat_row_id
      from current_rows c
      join sample_units u on u.hkey = c.hkey and u.rs = c.rs
),
sat_cols as (
    select c.sat_row_id, c.hkey, c.rs, c.rs_key, f.key as col, as_varchar(f.value) as val
      from sat_sample c, lateral flatten(input => c.obj) f
)"""


def stitch_ctes(sat):
    """Reproduce each stitch view from RAW for the sampled keys, keeping EVERY row combination."""
    parts, names = [], {}
    for b in sat.branches:
        st = b.stitch
        if not st or st.name in names:
            continue
        n = f"st{len(names) + 1}"
        names[st.name] = n
        uk = st.unique_key.upper()
        hk = lambda key: b.pk.replace(f'"{uk}"', f"({key})")  # noqa: E731
        ak = "\n    union\n".join(
            f"    select {s['key']} as \"{uk}\"\n      from {s['raw']}\n"
            f"     where {s['key']} is not null\n       and {hk(s['key'])} in (select hkey from sample_keys)"
            for s in st.sources)
        parts.append(f"{n}_ak as (\n    -- {st.name}: every key of every contributing table (no watermark window)\n{ak}\n)")
        for s in st.sources:
            cols = ",\n           ".join(f'{e} as "{c.upper()}"' for c, e in s["columns"].items())
            parts.append(f"""{n}_{s['alias']} as (
    -- {s['tag']}
    select distinct {s['key']} as "{uk}",
           {cols},
           {s['ldts']} as "LDTS"
      from {s['raw']}
     where {s['key']} is not null
       and {hk(s['key'])} in (select hkey from sample_keys)
)""")
        outs = []
        for c in st.output_columns:
            als = st.coalesce_rules[c]
            refs = [f'{n}_{a}."{c.upper()}"' for a in als]
            outs.append((refs[0] if len(refs) == 1 else "coalesce(" + ", ".join(refs) + ")") + f' as "{c.upper()}"')
        tags = ",\n               ".join(
            f"case when {n}_{s['alias']}.\"{uk}\" is not null then '{s['tag']}' end" for s in st.sources)
        ldts = ", ".join(f'{n}_{s["alias"]}."LDTS"' for s in st.sources)
        joins = "\n".join(f'      left join {n}_{s["alias"]} on {n}_{s["alias"]}."{uk}" = ak."{uk}"' for s in st.sources)
        outs_sql = ",\n           ".join(outs)
        parts.append(f"""{n} as (
    -- every row combination per key (the stitch keeps one of them; the vault row must equal one)
    select ak."{uk}",
           {outs_sql},
           array_to_string(array_construct_compact(
               {tags}
           ), ', ') as "RECORD_SOURCE",
           greatest_ignore_nulls({ldts}) as "INC_JOB_UPDATED_AT"
      from {n}_ak ak
{joins}
)""")
    return parts, names


def src_from(b, names):
    return names[b.stitch.name] if b.stitch else b.src.raw


def where_lines(b, extra):
    w = [f"{b.pk} in (select hkey from sample_keys)"] + [f"({x})" for x in b.src.where] + list(extra)
    return "     where " + "\n       and ".join(w)


def eq(a, b):
    return (f"(equal_null({a}, {b}) or ({a} like '____-__-__%' and {b} like '____-__-__%' "
            f"and try_to_timestamp_ntz({a}) = try_to_timestamp_ntz({b})))")


# ---------------------------------------------------------------------------------------
# DM-A2 -- record-level attribute reconciliation on the agreed sample
# ---------------------------------------------------------------------------------------
def a2_src(sat, names):
    cols = sat.columns
    ind = " " * 11
    arms = []
    if sat.objects:
        plain = [c for c in cols if c not in sat.objects]
        for i, b in enumerate(sat.branches, 1):
            sel = ",\n           ".join(
                [f"{b.pk} as hkey", f"{b.rs} as rs", f"{b.ldts} as ldts"]
                + [f"to_varchar({b.payload[c] if b.payload[c] is not None else 'null'}) as \"{c}\"" for c in cols])
            w = [f"({x})" for x in b.src.where]
            arms.append(f"    -- {i}. {b.label}  via {b.via}\n    select * from (\n    select {sel}\n"
                        f"      from {src_from(b, names)}" + ("\n     where " + "\n       and ".join(w) if w else "")
                        + "\n    ) where hkey in (select hkey from sample_keys)")
        grp = group_of(sat)
        maxes = ",\n           ".join(f'max("{c}") as "{c}"' for c in cols)
        o = obj([(c, f'to_varchar(object_agg(source_table, to_variant("{c}")))') for c in sat.objects]
                + [(c, f'max("{c}")') for c in plain], ind)
        union = "\n    union all\n".join(arms)
        return f"""src_rows as (
{union}
),
src_tbl as (
    -- sat_multi_source OBJECT branch: one value per (key, source table), then one row per key
    select hkey, regexp_replace(rs, '^{grp}_', '') as source_table, max(ldts) as ldts,
           {maxes}
      from src_rows
     group by hkey, source_table
),
src as (
    select hkey, '{grp}' as rs_key, max(ldts) as ldts,
           {o} as obj
      from src_tbl
     group by hkey
)"""
    groups = OrderedDict()
    for b in sat.branches:
        groups.setdefault((src_from(b, names), b.pk, rs_key_src(sat, b), b.ldts), []).append(b)
    for i, ((frm, pk, rsk, ldts), bs) in enumerate(groups.items(), 1):
        def pairs(b):
            return [(c, f"to_varchar({b.cdk[c]})") for c in sat.cdk] + \
                   [(c, f"to_varchar({b.payload[c]})" if b.payload[c] is not None else "to_varchar(null)")
                    for c in sat.payload]

        def cond(b):
            return [f"({x})" for x in b.src.where] + [f"{b.cdk[c]} is not null" for c in sat.cdk]
        b0 = bs[0]
        head = f"    -- {i}. {b0.label}  via {b0.via}" + (f"  ({len(bs)} unpivot arms, one scan)" if len(bs) > 1 else "")
        if len(bs) == 1:
            sel, frm_sql, w = obj(pairs(b0), ind), frm, cond(b0)
        else:
            ind2 = ind + " " * 8
            elems = ",\n".join(f"{ind}    iff({' and '.join(cond(b)) or 'true'},\n{ind2}{obj(pairs(b), ind2)}, null)"
                               for b in bs)
            sel = "a.value::object"
            frm_sql = f"{frm},\n           lateral flatten(input => array_construct_compact(\n{elems}\n{ind})) a"
            w = []
        arms.append(f"{head}\n    select * from (\n"
                    f"    select {pk} as hkey,\n           {rsk} as rs_key,\n"
                    f"           {ldts} as ldts,\n           {sel} as obj\n"
                    f"      from {frm_sql}"
                    + ("\n     where " + "\n       and ".join(w) if w else "")
                    + "\n    ) where hkey in (select hkey from sample_keys)")
    return "src as (\n" + "\n    union all\n".join(arms) + "\n)"


def a2_sql(sat):
    st_parts, names = stitch_ctes(sat)
    ma = sat.multi_active
    nv = "any_value(coalesce(x.n, 0)) = 0" if ma else "true"
    ctes = [sample_ctes(sat, sat.columns)] + st_parts + [a2_src(sat, names)]
    ctes.append("""src_n as (
    select s.*, row_number() over (order by s.hkey, s.ldts) as src_row_id from src s
),
src_cols as (
    select s.src_row_id, s.hkey, s.rs_key, f.key as col, as_varchar(f.value) as val
      from src_n s, lateral flatten(input => s.obj) f
),
pairs as (
    -- every (vault row, source row) pair of a sampled unit, with the number of differing columns
    select a.sat_row_id, b.src_row_id, a.hkey, a.rs,
           count_if(not equal_null(a.val, b.val)) as n_diff_exact,
           count_if(not """ + eq("a.val", "b.val") + """) as n_diff
      from sat_cols a
      join src_cols b on b.hkey = a.hkey and b.rs_key = a.rs_key and b.col = a.col
     group by a.sat_row_id, b.src_row_id, a.hkey, a.rs
),
sat_match as (
    select c.sat_row_id, c.hkey, c.rs, c.rs_key, c.ldts,
           coalesce(min(p.n_diff_exact) = 0, false) as exact_match,
           coalesce(min(p.n_diff) = 0, false) as value_match
      from sat_sample c
      left join pairs p on p.sat_row_id = c.sat_row_id
     group by c.sat_row_id, c.hkey, c.rs, c.rs_key, c.ldts
),
src_stats as (
    select hkey, rs_key, count(*) as src_rows, max(ldts) as src_max_ldts from src_n group by hkey, rs_key
),""" + ("""
src_not_in_vault as (
    -- multi-active: every source row of the latest source set must be in the vault's current set
    select u.hkey, u.rs, count(*) as n
      from (select * from src_n qualify rank() over (partition by hkey, rs_key order by ldts desc) = 1) s
      join sample_units u on u.hkey = s.hkey and u.rs_key = s.rs_key
     where not exists (select 1 from pairs p where p.src_row_id = s.src_row_id and p.hkey = u.hkey
                                               and p.rs = u.rs and p.n_diff = 0)
     group by u.hkey, u.rs
),""" if ma else "") + """
classified as (
    select m.hkey, m.rs,
           boolean_and_agg(m.exact_match) as all_exact,
           boolean_and_agg(m.value_match) as all_value,
           max(m.ldts) as sat_ldts,
           any_value(st.src_rows) as src_rows,
           any_value(st.src_max_ldts) as src_max_ldts,""" + ("""
           any_value(coalesce(x.n, 0)) as src_rows_not_in_vault,""" if ma else """
           0 as src_rows_not_in_vault,""") + """
           case when coalesce(any_value(st.src_rows), 0) = 0 then 'NOT_IN_SOURCE'
                when boolean_and_agg(m.exact_match) and """ + nv + """ then 'MATCH'
                when boolean_and_agg(m.value_match) and """ + nv + """ then 'MATCH_DATE_FORMAT'
                when any_value(st.src_max_ldts) > max(m.ldts) then 'SOURCE_CHANGED_AFTER_LOAD'
                else 'MISMATCH' end as unit_status
      from sat_match m
      left join src_stats st on st.hkey = m.hkey and st.rs_key = m.rs_key""" + ("""
      left join src_not_in_vault x on x.hkey = m.hkey and x.rs = m.rs""" if ma else "") + """
     group by m.hkey, m.rs
),
best_pair as (
    select p.*
      from pairs p
      join classified k on k.hkey = p.hkey and k.rs = p.rs and k.unit_status = 'MISMATCH'
    qualify row_number() over (partition by p.hkey, p.rs order by p.n_diff, p.sat_row_id, p.src_row_id) = 1
),
examples as (
    -- closest source row of each mismatched unit: the columns that differ
    select hex_encode(a.hkey) || ' [' || a.rs || '] ' || a.col || ': vault=' || coalesce(a.val, 'NULL')
           || ' | source=' || coalesce(b.val, 'NULL') as example
      from best_pair bp
      join sat_cols a on a.sat_row_id = bp.sat_row_id
      join src_cols b on b.src_row_id = bp.src_row_id and b.col = a.col
     where not """ + eq("a.val", "b.val") + """
    qualify row_number() over (order by a.hkey, a.rs, a.col) <= 20
)""")
    final = f"""select '{sat.project}' as project, '{sat.name}' as satellite,
       count(*)                                                as sampled_units,
       count_if(unit_status = 'MATCH')                         as matched,
       count_if(unit_status = 'MATCH_DATE_FORMAT')             as matched_date_format_only,
       count_if(unit_status = 'MISMATCH')                      as mismatched,
       count_if(unit_status = 'SOURCE_CHANGED_AFTER_LOAD')     as source_changed_after_load,
       count_if(unit_status = 'NOT_IN_SOURCE')                 as not_in_source,
       case when count(*) = 0 then 'NO DATA'
            when count_if(unit_status = 'MISMATCH') = 0 then 'PASS'
            else 'FAIL' end                                    as status,
       (select listagg(example, ' ;; ') within group (order by example) from examples) as mismatch_examples
  from classified;"""
    return "with " + ",\n".join(ctes) + "\n" + final


# ---------------------------------------------------------------------------------------
# DM-A1 (a) -- column type comparison, RAW vs satellite (INFORMATION_SCHEMA)
# ---------------------------------------------------------------------------------------
TYPE_DESC = ("case when {t}.data_type = 'TEXT' then 'TEXT(' || {t}.char_len || ')' "
             "when {t}.data_type = 'NUMBER' then 'NUMBER(' || {t}.num_prec || ',' || {t}.num_scale || ')' "
             "when {t}.data_type like 'TIMESTAMP%' then {t}.data_type || '(' || {t}.dt_prec || ')' "
             "else {t}.data_type end")
INFO_COLS = ("column_name, data_type, character_maximum_length as char_len, numeric_precision as num_prec,\n"
             "           numeric_scale as num_scale, datetime_precision as dt_prec")


def a1a_sql(sat, rows):
    by_db = OrderedDict()
    for _, raw, _, _, _ in rows:
        db, sch, tbl = raw.split(".")
        by_db.setdefault((db, sch), []).append(tbl)
    vals = ",\n        ".join(
        f"('{c}', '{raw.split('.')[0]}', '{raw.split('.')[1]}', '{raw.split('.')[2]}', '{q(r)}', '{flags}', '{q(t)}')"
        for c, raw, r, flags, t in rows)
    raw_union = "\n    union all\n".join(
        f"    select table_catalog, table_schema, table_name, {INFO_COLS}\n"
        f"      from {db}.INFORMATION_SCHEMA.COLUMNS\n"
        f"     where table_schema = '{sch}'\n"
        f"       and table_name in ({', '.join(repr(t) for t in sorted(set(tbls)))})"
        for (db, sch), tbls in by_db.items())
    return f"""with lineage (sat_column, raw_db, raw_schema, raw_table, raw_column, transform_flags, transform) as (
    -- generated from the dbt models: every RAW column that feeds a satellite column
    select * from values
        {vals}
),
raw_cols as (
{raw_union}
),
sat_cols as (
    select {INFO_COLS}
      from {VAULT_DB}.INFORMATION_SCHEMA.COLUMNS
     where table_schema = '{VAULT_SCHEMA}'
       and table_name = '{sat.name}'
)
select '{sat.project}' as project, '{sat.name}' as satellite,
       l.sat_column, {TYPE_DESC.format(t='s')} as sat_type,
       l.raw_table, l.raw_column, {TYPE_DESC.format(t='r')} as raw_type,
       l.transform_flags,
       case
         when r.data_type is null then 'FAIL - RAW COLUMN NOT FOUND'
         when s.data_type is null then 'FAIL - SAT COLUMN NOT FOUND'
         when r.data_type = 'NUMBER' and r.num_scale > 0 and l.transform_flags like '%SCALE0%'
              then 'FAIL - DECIMALS LOST (cast to integer NUMBER on load)'
         when r.data_type = 'NUMBER' and s.data_type = 'NUMBER' and s.num_scale < r.num_scale then 'FAIL - DECIMALS LOST'
         when r.data_type = 'NUMBER' and s.data_type = 'NUMBER'
              and s.num_prec - s.num_scale < r.num_prec - r.num_scale then 'FAIL - PRECISION RISK'
         when r.data_type = 'TEXT' and s.data_type = 'TEXT' and s.char_len < r.char_len then 'FAIL - TRUNCATION RISK (length)'
         when r.data_type like 'TIMESTAMP%' and s.data_type like 'TIMESTAMP%' and s.dt_prec < r.dt_prec
              then 'FAIL - FRACTIONAL SECONDS TRUNCATED'
         when r.data_type = 'DATE' and s.data_type like 'TIMESTAMP%' then 'REVIEW - DATE LOADED AS TIMESTAMP'
         when r.data_type <> 'TEXT' and s.data_type = 'TEXT' then 'REVIEW - STORED AS TEXT (see query b)'
         when r.data_type = 'TEXT' and s.data_type <> 'TEXT' then 'REVIEW - TEXT CONVERTED TO ' || s.data_type
         when r.data_type <> s.data_type and not (r.data_type like 'TIMESTAMP%' and s.data_type like 'TIMESTAMP%')
              then 'REVIEW - TYPE CHANGED'
         when l.transform_flags like '%TRIM%' then 'PASS (whitespace trimmed by design)'
         else 'PASS'
       end as type_verdict,
       l.transform
  from lineage l
  left join raw_cols r
         on r.table_catalog = l.raw_db and r.table_schema = l.raw_schema
        and r.table_name = l.raw_table and r.column_name = l.raw_column
  left join sat_cols s on s.column_name = l.sat_column
 order by l.sat_column, l.raw_table, l.raw_column;"""


# ---------------------------------------------------------------------------------------
# DM-A1 (b) -- value format check on the sample (1:1 mapped columns)
# ---------------------------------------------------------------------------------------
SESSION = """alter session set TIMESTAMP_NTZ_OUTPUT_FORMAT = 'YYYY-MM-DD HH24:MI:SS.FF9',
                  TIMESTAMP_LTZ_OUTPUT_FORMAT = 'YYYY-MM-DD HH24:MI:SS.FF9 TZHTZM',
                  TIMESTAMP_TZ_OUTPUT_FORMAT  = 'YYYY-MM-DD HH24:MI:SS.FF9 TZHTZM',
                  DATE_OUTPUT_FORMAT          = 'YYYY-MM-DD';"""


def a1b_sql(sat, direct):
    cols = list(OrderedDict.fromkeys(c for d in direct for c in d["cols"]))
    ind = " " * 33
    arms = []
    groups = OrderedDict()
    for d in direct:
        groups.setdefault((d["frm"], d["hkey"], d["rs_key"]), []).append(d)
    for i, ((frm, hk, rsk), ds) in enumerate(groups.items(), 1):
        def o(d, i_):
            return obj([(c, f"array_construct(to_varchar({e}), typeof(to_variant({e})))") for c, e in d["cols"].items()], i_)
        head = f"    -- {i}. {ds[0]['label']}" + (f"  ({len(ds)} unpivot arms, one scan)" if len(ds) > 1 else "")
        if len(ds) == 1:
            fl = f"lateral flatten(input => {o(ds[0], ind)}) f"
            w = [f"({x})" for x in ds[0]["where"]]
        else:
            ind2 = ind + " " * 8
            elems = ",\n".join(f"{ind}    iff({' and '.join(f'({x})' for x in d['where']) or 'true'},\n{ind2}{o(d, ind2)}, null)"
                               for d in ds)
            fl = (f"lateral flatten(input => array_construct_compact(\n{elems}\n{ind})) a,\n"
                  f"           lateral flatten(input => a.value) f")
            w = []
        arms.append(f"""{head}
    select * from (
    select {hk} as hkey,
           {rsk} as rs_key,
           f.key as col, as_varchar(f.value[0]) as raw_value, as_varchar(f.value[1]) as raw_type
      from {frm},
           {fl}""" + ("\n     where " + "\n       and ".join(w) if w else "") +
                    "\n    ) where hkey in (select hkey from sample_keys)")
    a, r = "v.val", "r.raw_value"
    return SESSION + "\n\nwith " + sample_ctes(sat, cols) + ",\nraw_vals as (\n" + "\n    union all\n".join(arms) + f"""
),
classified as (
    select v.hkey, v.rs, v.col,
           case
             when equal_null({a}, {r}) then 0                                                  -- EXACT
             when {a} is null and nullif(trim({r}), '') is null then 1                         -- BLANK -> NULL (by design)
             when {a} = trim({r}) then 1                                                       -- WHITESPACE TRIMMED (by design)
             when r.raw_type <> 'VARCHAR' and {a} like '____-__-__%' and {r} like '____-__-__%'
                  and try_to_timestamp_ntz({a}) = try_to_timestamp_ntz({r}) then 2             -- TYPED VALUE KEPT, TEXT FORM DIFFERS
             when r.raw_type <> 'VARCHAR' and try_to_decimal({a}, 38, 12) = try_to_decimal({r}, 38, 12) then 2
             when {a} like '____-__-__%' and {r} like '____-__-__%'
                  and try_to_timestamp_ntz({a}) = try_to_timestamp_ntz({r}) then 3             -- DATE/TIME RE-FORMATTED
             when try_to_decimal({a}, 38, 12) = try_to_decimal({r}, 38, 12) then 3             -- NUMBER RE-FORMATTED
             when try_to_decimal({r}, 38, 12) <> round(try_to_decimal({r}, 38, 12), 0)
                  and try_to_decimal({a}, 38, 12) = round(try_to_decimal({r}, 38, 12), 0) then 4  -- DECIMALS LOST
             when startswith({r}, {a}) then 5                                                  -- TRUNCATED
             else 6                                                                            -- DIFFERENT VALUE
           end as cls
      from sat_cols v
      join raw_vals r on r.hkey = v.hkey and r.rs_key = v.rs_key and r.col = v.col
),
best as (
    -- a key can have several RAW rows: keep the closest one per (unit, column)
    select hkey, rs, col, min(cls) as cls from classified group by hkey, rs, col
)
select '{sat.project}' as project, '{sat.name}' as satellite, col as sat_column,
       count(*)              as compared,
       count_if(cls = 0)     as exact,
       count_if(cls = 1)     as trimmed_or_blank_to_null,
       count_if(cls = 2)     as typed_value_kept_text_differs,
       count_if(cls = 3)     as reformatted,
       count_if(cls = 4)     as decimals_lost,
       count_if(cls = 5)     as truncated,
       count_if(cls = 6)     as different_value,
       case when count_if(cls in (3, 4, 5)) > 0 then 'FAIL'
            when count_if(cls = 6) > 0 then 'REVIEW (value differs - see DM-A2)'
            when count_if(cls = 1) > 0 then 'PASS (whitespace / blank->null by design)'
            else 'PASS' end  as format_status
  from best
 group by col
 order by col;"""


# ---------------------------------------------------------------------------------------
# Sections
# ---------------------------------------------------------------------------------------
MODE_TXT = {
    "single-active": "single-active: every current vault row must equal one source row of its (hash key, record source)",
    "multi-active": "multi-active: the current vault set and the latest source set of each (hash key, record source) "
                    "must contain the same rows",
    "object": "sat_multi_source OBJECT branch: one row per hash key; object columns hold one value per source "
              "table, plain columns the MAX across source rows -- reproduced from RAW the same way",
}


def branch_note(sat):
    labels = list(OrderedDict.fromkeys(b.label for b in sat.branches))
    txt = f"{len(sat.branches)} RAW branch(es): " + ", ".join(labels) + "."
    sts = list(OrderedDict.fromkeys(b.stitch.name for b in sat.branches if b.stitch))
    for sn in sts:
        st = next(b.stitch for b in sat.branches if b.stitch and b.stitch.name == sn)
        txt += (f" {sn} reproduced from {len(st.sources)} RAW tables with no watermark window; every row "
                f"combination per key is kept because the stitch keeps one of them arbitrarily.")
    return txt


def flag_summary(rows):
    by = OrderedDict()
    for c, raw, r, flags, _ in rows:
        for f in ("SCALE0", "TO_TIMESTAMP", "TO_DATE"):
            if f in flags.split(", "):
                by.setdefault(f, []).append(f"{c}<-{r}")
    txt = {"SCALE0": "integer cast on load (decimals lost if the RAW column has a scale)",
           "TO_TIMESTAMP": "converted to TIMESTAMP_NTZ on load", "TO_DATE": "converted to DATE on load"}
    out = []
    for f, items in by.items():
        items = list(OrderedDict.fromkeys(items))
        shown = ", ".join(items[:12]) + (f" (+{len(items) - 12} more)" if len(items) > 12 else "")
        out.append(f"{txt[f]}: {shown}.")
    return " ".join(out)


def null_cols(sat):
    return [c for c in sat.payload if all(b.payload.get(c) is None for b in sat.branches)]


def common_note(sat):
    parts = [branch_note(sat)]
    nc = null_cols(sat)
    if nc:
        parts.append(f"Not mapped by this project (always NULL): {', '.join(nc)}.")
    parts += sat.notes
    parts += [f"Lineage warning: {w}." for w in sat.warnings]
    return " ".join(parts)


def a1_section(sat):
    rows = lineage(sat)
    direct = direct_sources(sat, sat.columns)
    if not sat.branches:
        return na(sat, "DM-A1")
    queries = []
    if rows:
        queries.append(("SQL query (a) -- column type / length / precision / scale: RAW vs satellite", a1a_sql(sat, rows)))
    if direct:
        queries.append(("SQL query (b) -- value format on the sample (1:1 mapped columns; run the ALTER SESSION first)",
                        a1b_sql(sat, direct)))
    if not queries:
        return na(sat, "DM-A1", "no payload column is mapped to a RAW column")
    fs = flag_summary(rows)
    note = (f"{len({r[0] for r in rows})} mapped column(s), {len(rows)} RAW column lineage row(s); "
            f"{len(OrderedDict.fromkeys(c for d in direct for c in d['cols']))} column(s) are 1:1 and value-checked in (b). "
            + (f"Static transform flags -- {fs} " if fs else "") + common_note(sat))
    return dict(project=sat.project, hub=sat.name, status="Implemented",
                pass_criteria="(a) no FAIL type_verdict, every REVIEW row explained; (b) no FAIL format_status",
                note=note, queries=queries,
                extra_rows=[("FAIL rows (a) / (b)", ""), ("REVIEW rows accepted as documented exceptions", "")])


def a2_section(sat):
    if not sat.branches:
        return na(sat, "DM-A2")
    return dict(project=sat.project, hub=sat.name, status="Implemented",
                pass_criteria="status = PASS (mismatched = 0 on the sample)",
                note=f"Mode -- {MODE_TXT[sat.mode]}. {len(sat.columns)} column(s) compared. " + common_note(sat),
                queries=[("SQL query", a2_sql(sat))],
                extra_rows=[("Sampled / matched / mismatched", "")])


def na(sat, check, reason=None):
    reason = reason or ("; ".join(sat.notes) or "no RAW source")
    return dict(project=sat.project, hub=sat.name, status="NA", pass_criteria="NA",
                note=f"Not applicable: {reason}.",
                queries=[("SQL query", f"-- {check} {sat.project} {sat.name}: NA -- {reason}")])


# ---------------------------------------------------------------------------------------
# Check metadata
# ---------------------------------------------------------------------------------------
COMMON_OVERVIEW = [
    ("Owner", "LUMIQ"),
    ("Vault location", VAULT),
    ("Maximus RAW", K.RAW_SCHEMA["maximus_partner"]),
    ("Opus RAW (test)", K.RAW_SCHEMA["partner_test_raw"] + "  (prod: BAGIC_PROD_MIRROR_DB.OPUS_GG_DWHSTAGE)"),
    ("Scope", "Every satellite model of maximus_partner_dv_dbt and opus_partner_dv_dbt (standard + augmented). "
              "Satellite tables are shared; rows are scoped by RECORD_SOURCE prefix (MAXIMUS / OPUS)."),
]
SAMPLE_TXT = (f"{SAMPLE_SIZE} (hash key, RECORD_SOURCE) units per satellite, chosen deterministically by "
              f"md5(hash key | record source | '{SAMPLE_SEED}') so every re-run reads the same units. Change "
              f"SAMPLE_SIZE in the generator to agree a different sample.")

CHECKS = OrderedDict([
    ("DM-A1", dict(
        title="DM-A1  |  Attribute Checks — Data Type & Format Preserved",
        subtitle="Dates, decimals and trailing spaces not truncated or altered on load. Pass criterion: types & formats "
                 "match source (no FAIL rows; REVIEW rows explained as documented exceptions).",
        overview=[("Check ID", "DM-A1"), ("Category", "Attribute checks"),
                  ("Sign-off criterion", "Data type & format preserved"),
                  ("Method", "(a) column type compare: every RAW column feeding a satellite column (lineage generated "
                             "from the models) vs the satellite column, from INFORMATION_SCHEMA -- type, length, "
                             "precision, scale, fractional seconds; (b) sample trace: for 1:1 mapped columns, the "
                             "vault value vs the RAW value on the agreed sample, classified as exact / trimmed / "
                             "re-formatted / decimals lost / truncated / different"),
                  ("Pass criteria / tolerance", "Types & formats match source")] + COMMON_OVERVIEW + [
                  ("Sample (query b)", SAMPLE_TXT),
                  ("Session settings (query b)", "Run the ALTER SESSION first: timestamps rendered with 9 fractional "
                   "digits so a value stored as text with fewer digits shows as truncated."),
                  ("transform_flags", "TRIM / BLANK->NULL / UPPER: text cleaned on load; SCALE0: integer cast "
                   "(try_to_number / ::number without scale); TO_TIMESTAMP / TO_DATE: type conversion; COALESCE / "
                   "CASE: derived from several RAW columns; SAT_VARCHAR: sat_multi_source stores the payload as VARCHAR"),
                  ("Known design exceptions", "Layer-1 staging trims every text column and turns blanks into NULL "
                   "(nullif(trim(...), '')), so trailing spaces are NOT preserved by design. Opus staging casts "
                   "DATE / TIMESTAMP to TIMESTAMP_NTZ. These show as 'PASS (... by design)' / REVIEW and must be "
                   "accepted by BGIL as documented exceptions or fixed."),
                  ("Output columns", "(a) sat_column, sat_type, raw_table, raw_column, raw_type, transform_flags, "
                   "type_verdict, transform; (b) sat_column, compared, exact, trimmed_or_blank_to_null, "
                   "typed_value_kept_text_differs, reformatted, decimals_lost, truncated, different_value, format_status")],
        builder=a1_section)),
    ("DM-A2", dict(
        title="DM-A2  |  Attribute Checks — Record-level Attribute Reconciliation (Sample)",
        subtitle="For the agreed sample of business keys, every satellite attribute equals the SF Mirror source value. "
                 "Pass criterion: 100% match on the agreed sample (status = PASS).",
        overview=[("Check ID", "DM-A2"), ("Category", "Attribute checks"),
                  ("Sign-off criterion", "Record-level attribute reconciliation (sample)"),
                  ("Method", "For each sampled (hash key, record source) unit, the current satellite row(s) are "
                             "compared column by column with the source row(s) rebuilt from RAW using the model's "
                             "own expressions (staging casts, derivations, unpivots, stitches, column maps)"),
                  ("Pass criteria / tolerance", "100% match on agreed sample")] + COMMON_OVERVIEW + [
                  ("Sample", SAMPLE_TXT),
                  ("Unit status", "MATCH = exact; MATCH_DATE_FORMAT = equal once date/time text is normalised (type "
                   "difference -- see DM-A1); SOURCE_CHANGED_AFTER_LOAD = source row newer than the last load (re-run "
                   "after the next load, not a failure); NOT_IN_SOURCE = key no longer in RAW (see DM-K2, not a "
                   "failure here); MISMATCH = fails"),
                  ("Output columns", "project, satellite, sampled_units, matched, matched_date_format_only, mismatched, "
                   "source_changed_after_load, not_in_source, status, mismatch_examples (up to 20: "
                   "hash key [record source] column: vault=... | source=...)")],
        builder=a2_section)),
])


def main():
    template = (K.VALIDATION / "DM-K4.docx").read_bytes()
    sats = build_all()
    order = {"MAXIMUS": 0, "OPUS": 1}
    sats.sort(key=lambda s: (order[s.project], s.name.startswith("SAT_AUG_"), s.name))
    n = {p: sum(1 for s in sats if s.project == p) for p in order}
    n_st = sum(1 for s in sats if any(b.stitch for b in s.branches))
    modes = OrderedDict((m, sum(1 for s in sats if s.mode == m)) for m in MODE_TXT)
    scale0 = sorted({(s.project, s.name, r[0]) for s in sats for r in lineage(s) if "SCALE0" in r[3]})
    warn = sum(len(s.warnings) for s in sats)
    revision = [
        "Generated 2026-10-12 from the current opus_partner_dv_dbt and maximus_partner_dv_dbt models by "
        "validation/tools/gen_dm_a.py; results are blank and must be filled in after running the queries.",
        f"Scope: {n['MAXIMUS']} MAXIMUS + {n['OPUS']} OPUS satellite models = {len(sats)} sections "
        f"({modes['single-active']} single-active, {modes['multi-active']} multi-active, {modes['object']} "
        f"object-column sats; {n_st} fed by an Opus stitch view).",
        "Lineage is parsed, not typed: sat -> stg2 stage / wrapper / unpivot / stitch -> layer-1 stg_ -> RAW column. "
        "Hash keys reproduced as automate_dv 0.11.5 does: MD5_BINARY(NULLIF(UPPER(TRIM(CAST(<NK> AS VARCHAR))), '')).",
        f"Static finding: {len(scale0)} satellite column(s) are loaded through an integer cast (try_to_number / ::number "
        "without scale); query (a) of DM-A1 reports DECIMALS LOST where the RAW column has a scale.",
        f"Lineage warnings (stage column excluded by src_column_map): {warn}.",
    ]
    for cid, meta in CHECKS.items():
        sections = [meta["builder"](s) for s in sats]
        K.write_sql(cid, meta, sections, revision, generator="gen_dm_a.py")
        K.write_docx(cid, meta, sections, revision, template, obj_col="Satellite", obj_label="Satellite table",
                     rows_col="Fail / mismatch")
        print(f"{cid}: {len(sections)} sections written")


if __name__ == "__main__":
    if "--lineage" in sys.argv:
        for s in build_all():
            print(f"{s.project:8} {s.name:50} {s.mode:13} branches={len(s.branches):3} cols={len(s.columns):3}")
    else:
        main()
