#!/usr/bin/env python3
"""
Generate the DM-A1 / DM-A2 sign-off validation SQL + DOCX (satellite attribute checks) for
the MAXIMUS and OPUS partner Data Vault projects.

Like gen_dm_k.py, every satellite payload expression is PARSED from the dbt models
(sat -> stg2 / wrapper -> stg_ | unpivot | stitch -> RAW), never hand-typed:

    python3 BGIL_DBT/validation/tools/gen_dm_a.py

Outputs (overwritten), one pair per check and project:
    BGIL_DBT/validation/DM-A/DM-A{1,2}_MAXIMUS.{sql,docx} and DM-A{1,2}_OPUS.{sql,docx}

DM-A1  Data type & format preserved
       (a) RAW column type/length/scale vs satellite column type (INFORMATION_SCHEMA)
       (b) sample probe: satellite value vs the UNTRANSFORMED RAW value, every difference
           classified (TRIMMED / BLANK_TO_NULL / CASE_CHANGED / DATE_FORMAT_CHANGED /
           NUMBER_FORMAT_CHANGED / TRUNCATED / VALUE_DIFFERS)
DM-A2  Record-level attribute reconciliation (sample)
       latest satellite row per key vs the model's own expression recomputed from RAW
"""
import ast
import re
import sys
from collections import OrderedDict
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import gen_dm_k as K  # noqa: E402

VALIDATION = K.VALIDATION
VAULT = K.VAULT
SAMPLE_N = 100
PROJECTS = [("MAXIMUS", K.MAXI), ("OPUS", K.OPUS)]
RAW_INFO = {  # project -> (database, schema) of its RAW tables
    "MAXIMUS": K.RAW_SCHEMA["maximus_partner"].split("."),
    "OPUS": K.RAW_SCHEMA["partner_test_raw"].split("."),
}
VAULT_DB, VAULT_SCHEMA = VAULT.split(".")

# ---------------------------------------------------------------------------------------
# Expression helpers
# ---------------------------------------------------------------------------------------
TOK = re.compile(r"'(?:[^']|'')*'|\"[^\"]*\"|\b[A-Za-z_][A-Za-z0-9_$]*\b")
SQLW = set(K.SQL_WORDS) | {
    "true", "false", "varchar", "number", "date", "timestamp", "timestamp_ntz", "timestamp_ltz",
    "boolean", "integer", "int", "float", "double", "between", "distinct", "from", "over", "string",
    "text", "decimal", "numeric", "char", "ilike", "rlike", "regexp", "escape", "current_date",
    "current_timestamp", "sysdate", "interval", "variant", "binary", "time", "bigint",
}
SIMPLE = re.compile(r"[A-Za-z_][\w$.]*|\"[^\"]*\"|'(?:[^']|'')*'")


def lower_idents(expr):
    """Lower-case identifiers outside string literals / quoted identifiers."""
    return TOK.sub(lambda m: m.group(0) if m.group(0)[0] in "'\"" else m.group(0).lower(), expr)


def subst(expr, mapping, unresolved=None):
    """Replace column tokens of expr with mapping[token] (parenthesised)."""
    out, i = [], 0
    for m in TOK.finditer(expr):
        out.append(expr[i:m.start()])
        tok, i = m.group(0), m.end()
        if tok[0] in "'\"":
            out.append(tok)
            continue
        low = tok.lower()
        nxt = expr[m.end():].lstrip()[:1]
        prev = expr[:m.start()].rstrip()
        structural = nxt == "(" or prev.endswith("::") or prev.endswith(".") or low in SQLW
        if structural or low not in mapping:
            if not structural and unresolved is not None:
                unresolved.add(low)
            out.append(tok)
            continue
        e = mapping[low]
        out.append(e if SIMPLE.fullmatch(e) else f"({e})")
    out.append(expr[i:])
    return "".join(out)


def is_null_expr(e):
    return bool(re.fullmatch(r"\s*\(?\s*(cast\(\s*null\s+as\s+\w+\s*\)|null)\s*\)?\s*", e or "", re.I))


def split_top(s):
    """Split on top-level commas (outside parentheses / quotes)."""
    parts, depth, cur, q = [], 0, [], None
    for ch in s:
        if q:
            cur.append(ch)
            if ch == q:
                q = None
            continue
        if ch in "'\"":
            q = ch
        elif ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
        elif ch == "," and depth == 0:
            parts.append("".join(cur))
            cur = []
            continue
        cur.append(ch)
    if "".join(cur).strip():
        parts.append("".join(cur))
    return parts


def strip_sql_comments(sql):
    sql = re.sub(r"\{#.*?#\}", "", sql, flags=re.S)
    sql = re.sub(r"\{\{\s*config\(.*?\)\s*\}\}", "", sql, flags=re.S)
    return "\n".join(re.sub(r"--.*$", "", l) for l in sql.splitlines())


def raw_cols_of(expr):
    """Quoted RAW column identifiers referenced by a RAW-level expression."""
    return list(OrderedDict.fromkeys(re.findall(r"\"([A-Za-z0-9_$#]+)\"", re.sub(r"'(?:[^']|'')*'", "", expr))))


def rule_flags(expr):
    e = (expr or "").lower()
    return dict(
        trim="trim(" in e,
        nullif="nullif(" in e,
        case=("upper(" in e or "lower(" in e or "initcap(" in e),
        conv=bool(re.search(r"try_to_|to_date\(|to_timestamp|to_number|to_decimal|::number|::date|::timestamp|"
                            r"regexp_replace\(|cast\(.+ as (number|date|timestamp|decimal)", e)),
    )


def lit(s):
    return "'" + s.replace("'", "''") + "'"


# ---------------------------------------------------------------------------------------
# Lower-layer parsers (unpivot arms, wrappers, stitches)
# ---------------------------------------------------------------------------------------
def parse_unpivot_arms(models_dir, name):
    sql = strip_sql_comments(K.read(K.find_model(models_dir, name)))
    arms = []
    for part in re.split(r"\bunion\s+all\b", sql, flags=re.I):
        ref = re.search(r"ref\('([^']+)'\)", part)
        if not ref:
            continue
        sel_start = re.search(r"\bselect\b", part, re.I).end()
        frm = re.search(r"\bfrom\s*\{\{", part, re.I)
        cols = OrderedDict()
        for item in split_top(part[sel_start:frm.start()]):
            m = re.match(r"(?s)^\s*(.+?)\s+as\s+([A-Za-z0-9_]+)\s*$", item)
            if m:
                cols[m.group(2).lower()] = m.group(1).strip()
        w = re.search(r"\}\}\s*where\b(.*)$", part, re.S | re.I)
        arms.append(dict(ref=ref.group(1), cols=cols, where=w.group(1).strip() if w else None))
    return arms


def parse_wrapper(sql):
    """Thin select-only wrapper over a stg2 view -> (ref, {out_col: in_col})."""
    body = strip_sql_comments(sql)
    ref = re.search(r"ref\('([^']+)'\)", body).group(1)
    if re.search(r"\}\}\s*(where|qualify|join)\b", body, re.I):
        raise SystemExit(f"wrapper over {ref} filters/joins -- generator does not handle that")
    sel_start = re.search(r"\bselect\b", body, re.I).end()
    frm = re.search(r"\bfrom\s*\{\{", body, re.I)
    rename = {}
    for item in split_top(body[sel_start:frm.start()]):
        item = item.strip()
        m = re.match(r"(?s)^(.+?)\s+as\s+([A-Za-z0-9_]+)$", item, re.I)
        src, out = (m.group(1).strip(), m.group(2)) if m else (item, item)
        rename[out.lower()] = src.lower()
    return ref, rename


def jinja_literal(sql, name):
    m = re.search(r"\{%-?\s*set\s+" + name + r"\s*=\s*(.*?)\s*-?%\}", sql, re.S)
    if not m:
        return None
    txt = re.sub(r"\btrue\b", "True", re.sub(r"\bfalse\b", "False", m.group(1)))
    return ast.literal_eval(txt)


def parse_stitch(models_dir, name):
    sql = K.read(K.find_model(models_dir, name))
    sources = jinja_literal(sql, "sources")
    out_cols = jinja_literal(sql, "output_columns")
    rules = jinja_literal(sql, "coalesce_rules")
    uk = re.search(r"unique_key\s*=\s*'([^']+)'", sql)
    return dict(sources=sources, output_columns=out_cols, rules=rules,
                unique_key=uk.group(1) if uk else "parent_bk")


# ---------------------------------------------------------------------------------------
# stg2 resolution: any stg2-level column name -> RAW-level SQL expression
# ---------------------------------------------------------------------------------------
class Lookup:
    """Resolves stg2 column names: derived_columns -> hashed_columns -> base (lower layer)."""

    def __init__(self, dc, hc, base, inner=None, rename=None):
        self.dc = {k.lower(): v for k, v in (dc or {}).items()}
        self.hc = {k.lower(): v for k, v in (hc or {}).items()}
        self.base = base or {}
        self.inner, self.rename = inner, rename or {}
        self._busy = set()
        self.unresolved = set()

    def __contains__(self, col):
        return self.get(col) is not None

    def __getitem__(self, col):
        return self.get(col)

    def get(self, col):
        col = col.lower()
        if self.inner is not None:  # thin wrapper
            return self.inner.get(self.rename.get(col, col)) if (col in self.rename or not self.rename) else None
        if col in self._busy:
            return self.base.get(col)
        self._busy.add(col)
        try:
            if col in self.hc and isinstance(self.hc[col], str):
                nk = self.get(self.hc[col])
                return K.hkey_sql(nk) if nk else None
            if col in self.dc:
                v = self.dc[col]
                if not isinstance(v, str):
                    return None
                if v.startswith("!"):
                    return lit(v[1:])
                return subst(lower_idents(v), self, self.unresolved)
            return self.base.get(col)
        finally:
            self._busy.discard(col)


class Arm:
    """One row-producing RAW path of a stg2 model."""

    def __init__(self, kind, lookup, raw=None, where=None, stitch=None, label=""):
        self.kind, self.lookup, self.raw, self.where = kind, lookup, raw, where
        self.stitch, self.label = stitch, label  # stitch: dict (parsed stitch + per-source raw info)

    def wrap(self, rename):
        return Arm(self.kind, Lookup(None, None, None, inner=self.lookup, rename=rename), self.raw,
                   self.where, self.stitch, self.label)


def resolve(md, name):
    sql = K.read(K.find_model(md, name))
    try:
        meta = K.yaml_block(sql)
    except ValueError:
        meta = None
    if meta is None:
        ref, rename = parse_wrapper(sql)
        return [a.wrap(rename) for a in resolve(md, ref)]
    dc, hc, src = meta.get("derived_columns") or {}, meta.get("hashed_columns") or {}, meta["source_model"]
    if src.startswith("stitch_"):
        st = parse_stitch(md, src)
        for s in st["sources"]:
            raw, cols = K.parse_stg(md, s["model"])
            s["_raw"], s["_cols"] = raw, cols
        base = {c.lower(): f"st.{c.lower()}" for c in st["output_columns"]}
        base.update({st["unique_key"]: f"st.{st['unique_key']}", "record_source": "st.record_source",
                     "inc_job_updated_at": "st.inc_job_updated_at"})
        st["_dc"], st["_hc"], st["name"] = dc, hc, src
        return [Arm("stitch", Lookup(dc, hc, base), stitch=st, label=src)]
    if src.startswith("unpivot"):
        arms = []
        for i, a in enumerate(parse_unpivot_arms(md, src)):
            raw, cols = K.parse_stg(md, a["ref"])
            base = {k: subst(lower_idents(v), cols) for k, v in a["cols"].items()}
            where = subst(lower_idents(a["where"]), cols) if a["where"] else None
            arms.append(Arm("unpivot", Lookup(dc, hc, base), raw=raw, where=where, label=f"{src}#{i + 1}"))
        return arms
    raw, cols = K.parse_stg(md, src)
    return [Arm("stg", Lookup(dc, hc, cols), raw=raw, label=src)]


# ---------------------------------------------------------------------------------------
# Satellite specs
# ---------------------------------------------------------------------------------------
class Group:
    """Satellite rows of one RECORD_SOURCE (or one stitch) + every RAW arm that feeds them."""

    def __init__(self, label, rs_filter, rs_value=None):
        self.label, self.rs_filter, self.rs_value = label, rs_filter, rs_value
        self.arms, self.cols, self.feeds = [], [], []


class Sat:
    def __init__(self, project, path):
        self.project, self.path = project, path
        self.name = path.stem.upper()
        self.layer = path.parent.parent.name  # standard / augmented
        sql = K.read(path)
        meta = K.yaml_block(sql)
        self.pk = meta["src_pk"]
        cdk = meta.get("src_cdk") or []
        self.cdk = [cdk] if isinstance(cdk, str) else list(cdk)
        self.payload = list(meta["src_payload"])
        self.ldts = meta.get("src_ldts", "LOAD_DATETIME")
        srcs = meta["source_model"]
        self.sources = [srcs] if isinstance(srcs, str) else list(srcs)
        self.multi_active = bool(self.cdk)
        om = re.search(r"src_object_columns\s*=\s*\[(.*?)\]", sql, re.S)
        self.object_cols = [c.upper() for c in ast.literal_eval("[" + om.group(1) + "]")] if om else []
        cm = re.search(r"src_column_map\s*=\s*(\{.*?\})\s*\)\s*\}\}", sql, re.S)
        self.col_map = {k: [c.upper() for c in v] for k, v in ast.literal_eval(cm.group(1)).items()} if cm else None
        self.groups, self.skipped, self.notes = OrderedDict(), [], []
        self.unresolved = OrderedDict()
        self.macro = ("ma_sat_multi_source" if "ma_sat_multi_source(" in sql else
                      "sat_multi_source" if "sat_multi_source(" in sql else
                      "automate_dv.ma_sat" if "automate_dv.ma_sat(" in sql else "automate_dv.sat")

    @property
    def fq(self):
        return f"{VAULT}.{self.name}"

    @property
    def applicable(self):
        return any(g.cols for g in self.groups.values())


def build_sats():
    sats = []
    for project, md in PROJECTS:
        for path in sorted(md.glob("raw_vault/*/satellites/*.sql")):
            s = Sat(project, path)
            for src in s.sources:
                ssql = K.read(K.find_model(md, src))
                if K.is_disabled(ssql):
                    s.skipped.append(f"{src}: disabled placeholder (enabled=false)")
                    continue
                arms = resolve(md, src)
                mapped = [c.upper() for c in (s.col_map.get(src, s.payload) if s.col_map else s.payload)]
                lk = arms[0].lookup
                if arms[0].kind == "stitch":
                    st = arms[0].stitch
                    tags = sorted({x["source_tag"] for x in st["sources"]})
                    alt = "|".join(re.escape(t) for t in tags)
                    key = "STITCH:" + st["name"]
                    g = s.groups.setdefault(key, Group(f"{st['name']} ({len(tags)} tables)",
                                                       f"regexp_like(RECORD_SOURCE, '^({alt})(, ({alt}))*$')"))
                elif s.object_cols:
                    rs = lk.get("record_source")
                    rsv = rs.strip("'") if rs and rs.startswith("'") else None
                    grp = s.project
                    key = rsv or src
                    g = s.groups.setdefault(key, Group(rsv or src, f"RECORD_SOURCE = '{grp}'", rsv))
                else:
                    rs = lk.get("record_source")
                    if not (rs and re.fullmatch(r"'[^']*'", rs)):
                        s.skipped.append(f"{src}: RECORD_SOURCE is not a constant ({rs}) -- not traced")
                        continue
                    rsv = rs.strip("'")
                    g = s.groups.setdefault(rsv, Group(rsv, f"RECORD_SOURCE = '{rsv}'", rsv))
                g.feeds.append(src)
                for a in arms:
                    g.arms.append(a)
                for c in mapped:
                    if c in g.cols:
                        continue
                    exprs = [a.lookup.get(c) for a in arms]
                    if all(e is None or is_null_expr(e) for e in exprs):
                        continue  # hard-coded NULL padding: nothing to reconcile
                    if any(e is None for e in exprs):
                        s.unresolved.setdefault(src, []).append(c)
                        continue
                    g.cols.append(c)
                if len(g.feeds) > 1 and not s.object_cols and not key.startswith("STITCH:"):
                    s.notes.append(f"RECORD_SOURCE {g.label} is written by {len(g.feeds)} stg2 models "
                                   f"({', '.join(g.feeds)}); their RAW rows are compared as one set.")
            for src, cols in s.unresolved.items():
                s.notes.append(f"{src}: column(s) {', '.join(cols)} could not be traced to RAW -- excluded.")
            s.notes = list(OrderedDict.fromkeys(s.notes))
            sats.append(s)
    return sats


# ---------------------------------------------------------------------------------------
# SQL building blocks
# ---------------------------------------------------------------------------------------
NULLV = "cast(null as varchar)"


def ind(sql, n=4):
    pad = " " * n
    return "\n".join(pad + l if l.strip() else l for l in sql.split("\n"))


def cdk_alias(i):
    return f"cdk_{i + 1}"


def sample_cte(sat, gi, g):
    extra = ""
    if sat.object_cols and g.rs_value and "_" in g.rs_value:
        table = g.rs_value.split("_", 1)[1]
        oc = [c for c in g.cols if c in sat.object_cols]
        if oc:
            extra = "\n       and (" + " or ".join(f'{c}:"{table}" is not null' for c in oc) + ")"
    return (f"s{gi} as (  -- deterministic sample: first {SAMPLE_N} keys of this RECORD_SOURCE by hash key\n"
            f"    select distinct {sat.pk} as hkey from {sat.fq}\n"
            f"     where {g.rs_filter}{extra}\n"
            f"     order by hkey\n"
            f"     limit {SAMPLE_N}\n)")


def current_cte(sat, gi, g, cols):
    """Latest satellite row(s) per sampled key (rank: ties / multi-active members kept)."""
    sel = [f"{sat.pk} as hkey"] + [f"to_varchar({c}) as {cdk_alias(i)}" for i, c in enumerate(sat.cdk)]
    table = g.rs_value.split("_", 1)[1] if (sat.object_cols and g.rs_value and "_" in g.rs_value) else None
    for c in cols:
        if c == "RECORD_SOURCE":
            sel.append("RECORD_SOURCE as RECORD_SOURCE")
        elif table and c in sat.object_cols:
            sel.append(f'{c}:"{table}"::varchar as {c}')
        else:
            sel.append(f"to_varchar({c}) as {c}")
    part = ", ".join([sat.pk] + list(sat.cdk))
    return (f"c{gi} as (  -- latest satellite row per sampled key\n"
            f"    select " + ",\n           ".join(sel) + "\n"
            f"      from {sat.fq}\n"
            f"     where {g.rs_filter}\n"
            f"       and {sat.pk} in (select hkey from s{gi})\n"
            f"    qualify rank() over (partition by {part} order by {sat.ldts} desc) = 1\n)")


def stitch_ctes(sat, gi, arm):
    st = arm.stitch
    uk = st["unique_key"]
    ctes, aliases = [], {}
    for s in st["sources"]:
        a = f"g{gi}_{s['alias']}"
        aliases[s["alias"]] = a
        cols = s["_cols"]
        key = subst(lower_idents(s["key_column"]), cols)
        ldts = subst(lower_idents(s["ldts_column"]), cols)
        hk = Lookup(st["_dc"], st["_hc"], {uk: f"({key})"}).get(sat.pk)
        sel = [f"{key} as {uk}"]
        sel += [f"nullif(trim(to_varchar({subst(lower_idents(c['src']), cols)})), '') as {c['tgt']}" for c in s["columns"]]
        sel.append(f"{ldts} as {s['ldts_column'].lower()}")
        where = f"{key} is not null" + (f"\n       and {hk} in (select hkey from s{gi})" if hk else "")
        ctes.append(f"{a} as (  -- stitch source {s['source_tag']}\n    select distinct " +
                    ",\n           ".join(sel) + f"\n      from {s['_raw']}\n     where {where}\n)")
    keys = "\n    union\n".join(f"    select {uk} from {aliases[s['alias']]}" for s in st["sources"])
    ctes.append(f"k{gi} as (\n{keys}\n)")
    out = []
    for col in st["output_columns"]:
        refs = [f"{aliases[al]}.{col}" for al in st["rules"][col]]
        out.append((refs[0] if len(refs) == 1 else f"coalesce({', '.join(refs)})") + f" as {col}")
    rs = ",\n               ".join(f"case when {aliases[s['alias']]}.{uk} is not null then '{s['source_tag']}' end"
                                   for s in st["sources"])
    gl = ", ".join(f"{aliases[s['alias']]}.{s['ldts_column'].lower()}" for s in st["sources"])
    joins = "\n".join(f"      left join {aliases[s['alias']]} on {aliases[s['alias']]}.{uk} = ak.{uk}" for s in st["sources"])
    order = ", ".join(f"{aliases[s['alias']]}.{c['tgt']} nulls last" for s in st["sources"] for c in s["columns"])
    ctes.append(f"st{gi} as (  -- {st['name']} recomputed from RAW (same coalesce / priority as the stitch macro)\n"
                f"    select ak.{uk},\n           " + ",\n           ".join(out) + ",\n"
                f"           array_to_string(array_construct_compact(\n               {rs}\n           ), ', ') as record_source,\n"
                f"           greatest_ignore_nulls({gl}) as inc_job_updated_at\n"
                f"      from k{gi} ak\n{joins}\n"
                f"    qualify row_number() over (partition by ak.{uk} order by {order}) = 1\n)")
    return ctes


def arm_select(sat, arm, cols, gi, value_of):
    """One UNION ALL arm of the expected-rows CTE."""
    lk = arm.lookup
    sel = [f"{lk.get(sat.pk)} as hkey"]
    sel += [f"to_varchar({lk.get(c) or 'null'}) as {cdk_alias(i)}" for i, c in enumerate(sat.cdk)]
    sel.append(f"{lk.get(sat.ldts) or 'null'} as ldts")
    for c in cols:
        sel.append(f"{value_of(arm, c)} as {c}")
    if arm.kind == "stitch":
        frm, where = f"st{gi} st", None
    else:
        frm, where = arm.raw, arm.where
    s = "select " + ",\n       ".join(sel) + f"\n  from {frm}"
    if where:
        s += f"\n where {where}"
    return f"-- via {arm.label}\n" + s


def expected_cte(sat, gi, g, cols, value_of, aggregate=False):
    arms = "\nunion all\n".join(arm_select(sat, a, cols, gi, value_of) for a in g.arms)
    part = ", ".join(["hkey"] + [cdk_alias(i) for i in range(len(sat.cdk))])
    if aggregate:  # object satellites: MAX per (key, source table) -- as the OBJECT branch of sat_multi_source
        body = (f"select hkey, " + ", ".join(f"max({c}) as {c}" for c in cols) +
                f"\n  from (\n{ind(arms)}\n  )\n where hkey in (select hkey from s{gi}) and ldts is not null\n group by hkey")
    else:
        body = (f"select *\n  from (\n{ind(arms)}\n  )\n where hkey in (select hkey from s{gi}) and ldts is not null\n"
                f"qualify rank() over (partition by {part} order by ldts desc) = 1")
    return f"e{gi} as (  -- expected value(s) at the latest RAW load timestamp per key\n{ind(body)}\n)"


def join_on(sat):
    on = ["e.hkey = c.hkey"] + [f"equal_null(e.{cdk_alias(i)}, c.{cdk_alias(i)})" for i in range(len(sat.cdk))]
    return " and ".join(on)


def group_by_keys(sat):
    return ", ".join(["c.hkey"] + [f"c.{cdk_alias(i)}" for i in range(len(sat.cdk))])


# ---------------------------------------------------------------------------------------
# DM-A2: record-level attribute reconciliation (sample)
# ---------------------------------------------------------------------------------------
def a2_value(arm, c):
    if c == "RECORD_SOURCE":
        return "st.record_source"
    e = arm.lookup.get(c)
    return f"to_varchar({e})" if e and not is_null_expr(e) else NULLV


def a2_cols(sat, g):
    cols = [c for c in g.cols if (c in sat.object_cols) or not sat.object_cols]
    if any(a.kind == "stitch" for a in g.arms):
        cols = cols + ["RECORD_SOURCE"]
    return cols


def a2_section(sat):
    groups = [(gi, g, a2_cols(sat, g)) for gi, g in enumerate(sat.groups.values(), 1)]
    groups = [x for x in groups if x[2]]
    if not groups:
        return na(sat, "DM-A2")
    ctes, finals = [], []
    for gi, g, cols in groups:
        ctes.append(sample_cte(sat, gi, g))
        ctes.append(current_cte(sat, gi, g, cols))
        if any(a.kind == "stitch" for a in g.arms):
            ctes += stitch_ctes(sat, gi, next(a for a in g.arms if a.kind == "stitch"))
        ctes.append(expected_cte(sat, gi, g, cols, a2_value, aggregate=bool(sat.object_cols)))
        cmp = "\n    union all\n".join(
            f"    select '{c}' as column_name, c.hkey, c.{c} as sat_value,\n"
            f"           max(iff(equal_null(c.{c}, e.{c}), 1, 0)) as matched, count(e.hkey) as src_rows, min(e.{c}) as src_value\n"
            f"      from c{gi} c left join e{gi} e on {join_on(sat)}\n"
            f"     group by {group_by_keys(sat)}, c.{c}" for c in cols)
        ctes.append(f"r{gi} as (\n{cmp}\n)")
        finals.append(f"select '{sat.project}' as project, '{sat.name}' as satellite, {lit(g.label)} as record_source, column_name,\n"
                      f"       count(*) as keys_compared,\n"
                      f"       count_if(src_rows > 0 and matched = 1) as matched,\n"
                      f"       count_if(src_rows > 0 and matched = 0) as mismatched,\n"
                      f"       count_if(src_rows = 0) as no_source_row,\n"
                      f"       array_slice(array_agg(iff(src_rows > 0 and matched = 0, object_construct('hkey', to_varchar(hkey, 'HEX'), 'sat', sat_value, 'src', src_value), null))\n"
                      f"                   within group (order by hkey), 0, 3) as mismatch_examples,\n"
                      f"       iff(mismatched = 0 and no_source_row = 0, 'PASS', 'FAIL') as status\n"
                      f"  from r{gi}\n group by column_name")
    sql = "with " + ",\n".join(ctes) + "\n" + "\nunion all\n".join(finals) + "\norder by record_source, column_name;"
    return dict(project=sat.project, hub=sat.name, status="Implemented",
                pass_criteria="status = PASS on every row (mismatched = 0 and no_source_row = 0)",
                note=sat_note(sat, a2=True), queries=[("SQL query", sql)])


# ---------------------------------------------------------------------------------------
# DM-A1: data type & format preserved
# ---------------------------------------------------------------------------------------
def direct_map(sat, g, c):
    """(raw_table, raw_column, flags) per arm when every arm maps c from exactly one RAW column."""
    out = []
    for a in g.arms:
        if a.kind == "stitch":
            return None
        e = a.lookup.get(c)
        if not e or is_null_expr(e):
            continue
        rc = raw_cols_of(e)
        if len(rc) != 1:
            return None
        out.append((a.raw, rc[0], rule_flags(e), e))
    return out or None


def a1_meta_rows(sat):
    rows = OrderedDict()
    for g in sat.groups.values():
        for c in g.cols:
            for a in g.arms:
                if a.kind == "stitch":
                    st = a.stitch
                    tgt = c.lower()
                    for s in st["sources"]:
                        for col in s["columns"]:
                            if col["tgt"] == tgt and s["alias"] in st["rules"].get(tgt, []):
                                e = subst(lower_idents(col["src"]), s["_cols"])
                                for rc in raw_cols_of(e)[:1]:
                                    f = rule_flags(e)
                                    rows[(c, s["_raw"], rc)] = (rule_text(f, stitch=True), True)
                    continue
                e = a.lookup.get(c)
                if not e or is_null_expr(e):
                    continue
                rc = raw_cols_of(e)
                if len(rc) == 1:
                    f = rule_flags(e)
                    if c in sat.object_cols:  # stored as OBJECT {source_table: value}
                        rows[(c, a.raw, rc[0])] = ("object(per-table)+" + rule_text(f), True)
                    else:
                        rows[(c, a.raw, rc[0])] = (rule_text(f), f["conv"])
    return rows


def rule_text(f, stitch=False):
    parts = [k for k in ("trim", "nullif", "case", "conv") if f[k]]
    if stitch:
        parts = sorted(set(parts) | {"trim", "nullif"})
    return "+".join(parts) or "none"


def a1_meta_section(project, sats):
    rows = []
    for s in sats:
        for (c, raw, rc), (rule, conv) in a1_meta_rows(s).items():
            rows.append(f"({lit(s.name)}, {lit(c)}, {lit(raw.split('.')[-1])}, {lit(rc)}, {lit(rule)}, {'true' if conv else 'false'})")
    db, sch = RAW_INFO[project]
    sql = f"""with m (satellite, sat_column, raw_table, raw_column, model_rule, model_converts) as (
    select * from values
        {(","+chr(10)+"        ").join(rows)}
),
v as (
    select table_name, column_name, data_type, character_maximum_length, numeric_precision, numeric_scale
      from {VAULT_DB}.INFORMATION_SCHEMA.COLUMNS where table_schema = '{VAULT_SCHEMA}'
),
r as (
    select table_name, column_name, data_type, character_maximum_length, numeric_precision, numeric_scale
      from {db}.INFORMATION_SCHEMA.COLUMNS where table_schema = '{sch}'
),
x as (
    select '{project}' as project, m.*,
           r.data_type as raw_type, r.character_maximum_length as raw_length, r.numeric_precision as raw_precision, r.numeric_scale as raw_scale,
           v.data_type as sat_type, v.character_maximum_length as sat_length, v.numeric_precision as sat_precision, v.numeric_scale as sat_scale,
           case when r.data_type is null then 'RAW_COLUMN_NOT_FOUND'
                when v.data_type is null then 'SAT_COLUMN_NOT_FOUND'
                when v.data_type = 'TEXT' and r.data_type = 'TEXT' and v.character_maximum_length < r.character_maximum_length then 'LENGTH_TRUNCATION_RISK'
                when v.data_type = 'NUMBER' and r.data_type = 'NUMBER'
                     and (v.numeric_scale < r.numeric_scale or v.numeric_precision - v.numeric_scale < r.numeric_precision - r.numeric_scale) then 'NUMERIC_PRECISION_LOSS'
                when v.data_type = r.data_type then 'SAME_TYPE'
                when v.data_type = 'TEXT' then 'STORED_AS_TEXT'
                when m.model_converts then 'CONVERTED_BY_MODEL'
                else 'TYPE_CHANGED' end as classification,
           case when classification in ('SAME_TYPE', 'CONVERTED_BY_MODEL') then 'PASS'
                when classification = 'STORED_AS_TEXT' then 'PASS (value format verified in DM-A1 (b))'
                else 'FAIL' end as status
      from m
      left join r on r.table_name = m.raw_table and r.column_name = m.raw_column
      left join v on v.table_name = m.satellite and v.column_name = m.sat_column
)
select * from x
 order by iff(status = 'FAIL', 0, 1), satellite, sat_column, raw_table;"""
    return dict(project=project, hub=f"Type / length / scale comparison (all {project} satellites)", status="Implemented",
                pass_criteria="0 rows with status = FAIL",
                note=(f"{len(rows)} (satellite column <- RAW column) pairs: every payload column that the model maps from "
                      f"exactly one RAW column (stitch columns: every coalesce source). STORED_AS_TEXT is by design: "
                      f"sat_multi_source / ma_sat_multi_source CAST every payload column to VARCHAR so all UNION ALL "
                      f"branches agree; the value-level probe (b) proves no date / decimal / space was altered."),
                queries=[("SQL query (a) -- column type / length / scale", sql)])


CLASSES = ["EXACT", "BLANK_TO_NULL", "TRIMMED", "CASE_CHANGED", "NUMBER_FORMAT_CHANGED", "DATE_FORMAT_CHANGED",
           "TRUNCATED", "VALUE_DIFFERS"]


def a1_section(sat):
    groups = []
    for gi, g in enumerate(sat.groups.values(), 1):
        if sat.object_cols or any(a.kind == "stitch" for a in g.arms):
            continue
        dm = OrderedDict((c, direct_map(sat, g, c)) for c in g.cols)
        dm = OrderedDict((c, v) for c, v in dm.items() if v)
        if dm:
            groups.append((gi, g, dm))
    if not groups:
        return na(sat, "DM-A1", reason=("object / stitch-backed satellite: values are coalesced or aggregated "
                                        "across RAW tables, so there is no single untransformed RAW value per key; "
                                        "covered by DM-A1 (a) and DM-A2") if sat.applicable else None)
    ctes, finals = [], []
    for gi, g, dm in groups:
        cols = list(dm)
        ctes.append(sample_cte(sat, gi, g))
        ctes.append(current_cte(sat, gi, g, cols))

        def raw_value(arm, c, dm=dm):
            for raw, rc, _, _ in dm[c]:
                if raw == arm.raw and (arm.lookup.get(c) or "").find(f'"{rc}"') >= 0:
                    return f'to_varchar("{rc}")'
            return NULLV
        ctes.append(expected_cte(sat, gi, g, cols, raw_value))
        cmp = []
        for c in cols:
            fl = {k: any(x[2][k] for x in dm[c]) for k in ("trim", "nullif", "case", "conv")}
            rcols = ", ".join(sorted({x[1] for x in dm[c]}))
            sv, rv = f"c.{c}", f"e.{c}"
            cls = (f"case when equal_null({sv}, {rv}) then 0\n"
                   f"                when {sv} is null and nullif(trim({rv}), '') is null then 1\n"
                   f"                when {sv} = trim({rv}) then 2\n"
                   f"                when upper({sv}) = upper(trim({rv})) then 3\n"
                   f"                when try_to_decimal({sv}, 38, 10) = try_to_decimal(trim({rv}), 38, 10) then 4\n"
                   f"                when try_to_timestamp_ntz({sv}) = try_to_timestamp_ntz(trim({rv})) then 5\n"
                   f"                when length({sv}) < length({rv}) and startswith({rv}, {sv}) then 6\n"
                   f"                else 7 end")
            cmp.append(f"    select '{c}' as column_name, {lit(rcols)} as raw_column, "
                       f"{lit(rule_text(fl))} as model_rule,\n"
                       f"           {str(fl['trim']).lower()} as r_trim, {str(fl['nullif']).lower()} as r_nullif, "
                       f"{str(fl['case']).lower()} as r_case, {str(fl['conv']).lower()} as r_conv,\n"
                       f"           c.hkey, count(e.hkey) as src_rows,\n"
                       f"           min({cls}) as cls\n"
                       f"      from c{gi} c left join e{gi} e on {join_on(sat)}\n"
                       f"     group by {group_by_keys(sat)}, c.{c}")
        ctes.append(f"r{gi} as (\n" + "\n    union all\n".join(cmp) + "\n)")
        counts = ",\n       ".join(f"count_if(src_rows > 0 and cls = {i}) as {n.lower()}" for i, n in enumerate(CLASSES))
        finals.append(
            f"select '{sat.project}' as project, '{sat.name}' as satellite, {lit(g.label)} as record_source,\n"
            f"       column_name, raw_column, model_rule, count(*) as keys_compared,\n       {counts},\n"
            f"       count_if(src_rows = 0) as no_source_row,\n"
            f"       iff(truncated = 0\n"
            f"           and (value_differs = 0 or any_value(r_conv))\n"
            f"           and (trimmed = 0 or any_value(r_trim))\n"
            f"           and (blank_to_null = 0 or any_value(r_nullif))\n"
            f"           and (case_changed = 0 or any_value(r_case))\n"
            f"           and (number_format_changed + date_format_changed = 0 or any_value(r_conv)), 'PASS', 'FAIL') as status\n"
            f"  from r{gi}\n group by column_name, raw_column, model_rule")
    sql = "with " + ",\n".join(ctes) + "\n" + "\nunion all\n".join(finals) + "\norder by record_source, column_name;"
    skipped = [g.label for g in sat.groups.values() if any(a.kind == "stitch" for a in g.arms)]
    note = sat_note(sat) + (" TRIMMED / BLANK_TO_NULL on trim / nullif columns = documented exception "
                            "(staging trim rule retained by design), not a failure.")
    if skipped:
        note += f" Stitch-backed group(s) {', '.join(skipped)} are covered by DM-A1 (a) and DM-A2 only."
    return dict(project=sat.project, hub=sat.name, status="Implemented",
                pass_criteria="status = PASS on every row (no TRUNCATED; every other non-EXACT class is explained by the column's model_rule)",
                note=note, queries=[("SQL query (b) -- value format probe on the sample", sql)])


# ---------------------------------------------------------------------------------------
def na(sat, check, reason=None):
    reason = reason or "; ".join(sat.skipped + [f"{s}: {', '.join(c)} not traced" for s, c in sat.unresolved.items()]) \
        or "every payload column is hard-coded NULL padding in staging (nothing loaded to reconcile)"
    return dict(project=sat.project, hub=sat.name, status="NA", pass_criteria="NA",
                note=f"Not applicable: {reason}.",
                queries=[("SQL query", f"-- {check} {sat.project} {sat.name}: NA -- {reason}")])


def sat_note(sat, a2=False):
    parts = [f"{sat.layer} satellite, {sat.macro}; PK {sat.pk}" + (f", child key {', '.join(sat.cdk)}" if sat.cdk else "") +
             f"; {len(sat.groups)} RECORD_SOURCE group(s): " + ", ".join(
                 f"{g.label} [{len(g.cols)} col(s)]" for g in sat.groups.values()) + "."]
    if sat.object_cols:
        parts.append(f"OBJECT satellite: {', '.join(sat.object_cols)} hold one entry per source table "
                     f"(sat value = col:\"<TABLE>\"; expected = MAX over that table's RAW rows, as the macro does). "
                     f"Plain columns are MAX across all tables and are not compared per table. A table absent from the "
                     f"latest incremental window is absent from the latest row -- compare after a full load.")
    if sat.multi_active:
        parts.append("Multi-active: compared per (key, child key); latest = max LOAD_DATETIME per member.")
    if a2 and any(a.kind == "stitch" for g in sat.groups.values() for a in g.arms):
        parts.append("Stitch groups: expected values are the stitch view recomputed from RAW (same coalesce priority "
                     "and tie-break), and RECORD_SOURCE (contributing tables) is compared too.")
    parts += sat.notes + [f"Excluded: {s}." for s in sat.skipped]
    return " ".join(parts)


# ---------------------------------------------------------------------------------------
# Check metadata + writers
# ---------------------------------------------------------------------------------------
COMMON = [("Owner", "LUMIQ"), ("Vault location", VAULT)] + K.COMMON_OVERVIEW[2:] + [
    ("Scope", "Every standard + augmented satellite of maximus_partner_dv_dbt and opus_partner_dv_dbt, one section per "
              "project-satellite. Satellite rows are scoped by the RECORD_SOURCE each feed writes."),
    ("Sample", f"Deterministic: the first {SAMPLE_N} keys per RECORD_SOURCE ordered by hash key (re-runnable, same keys "
               f"every time). Change SAMPLE_N in gen_dm_a.py to the agreed sample size and regenerate."),
    ("Latest row rule", "Satellite: max LOAD_DATETIME per key (per key + child key for multi-active). RAW: rows at the "
                        "max load timestamp per key; ties are kept and a value matches if it equals any tied RAW row."),
]

CHECKS = OrderedDict([
    ("DM-A1", dict(
        title="DM-A1  |  Attribute Checks — Data Type & Format Preserved",
        subtitle="Dates, decimals and trailing spaces not truncated or altered on load. Pass criterion: types & formats match source (status = PASS on every row).",
        overview=[("Check ID", "DM-A1"), ("Category", "Attribute checks"), ("Sign-off criterion", "Data type & format preserved"),
                  ("Method", "(a) per project: RAW column type / length / scale vs satellite column (INFORMATION_SCHEMA); "
                             "(b) per satellite: sampled satellite values vs the UNTRANSFORMED RAW value, each difference classified"),
                  ("Pass criteria / tolerance", "Types & formats match source; only differences explained by a documented model rule")] + COMMON + [
                  ("Classes (b)", "EXACT, BLANK_TO_NULL, TRIMMED, CASE_CHANGED, NUMBER_FORMAT_CHANGED, DATE_FORMAT_CHANGED, TRUNCATED, VALUE_DIFFERS"),
                  ("model_rule", "What the dbt expression does to the RAW column: trim / nullif (blank->NULL) / case (upper/lower) / conv (type conversion, regexp). "
                                 "A class is accepted only when the rule explains it; TRUNCATED always fails."),
                  ("Documented exception", "Leading / trailing space removal and blank -> NULL are an accepted, documented "
                                           "exception to 'trailing spaces not altered': the stg_ models apply "
                                           "nullif(trim(col::varchar), '') by design and this rule is NOT to be changed. "
                                           "TRIMMED / BLANK_TO_NULL counts on columns whose model_rule contains trim / nullif "
                                           "therefore PASS and are reported as evidence of the exception only.")])),
    ("DM-A2", dict(
        title="DM-A2  |  Attribute Checks — Record-level Attribute Reconciliation (Sample)",
        subtitle="For an agreed sample of business keys, every satellite attribute equals the SF Mirror source value. Pass criterion: 100% match on the sample.",
        overview=[("Check ID", "DM-A2"), ("Category", "Attribute checks"), ("Sign-off criterion", "Record-level attribute reconciliation (sample)"),
                  ("Method", "Latest satellite row per sampled key vs the model's own column expression recomputed from RAW "
                             "(stg_ -> stg2 / unpivot / stitch logic parsed from dbt), compared with EQUAL_NULL on VARCHAR"),
                  ("Pass criteria / tolerance", "100% match on agreed sample (mismatched = 0, no_source_row = 0)")] + COMMON + [
                  ("Columns compared", "Every payload column the feed actually maps (src_column_map); hard-coded NULL padding is skipped."),
                  ("Output columns", "project, satellite, record_source, column_name, keys_compared, matched, mismatched, no_source_row, mismatch_examples (first 3: hkey / sat / src), status")])),
])


def write_docx(check_id, meta, sections, revision, template_bytes):
    import io, shutil, zipfile
    p, kv, grid = K.p, K.kv_table, K.grid_table
    body = [p(meta["title"], "Title"), p(meta["subtitle"], italic=True), p("Check Overview", "Heading1"),
            kv(meta["overview"]), p(), p("Revision notes", "Heading1")]
    body += [p("• " + r) for r in revision]
    body += [p("Results summary", "Heading1"),
             grid(["#", "Project", "Satellite", "Status", "Result", "Failing rows"],
                  [[str(i), s["project"], s["hub"], s["status"], "NA" if s["status"] == "NA" else "", ""]
                   for i, s in enumerate(sections, 1)], [500, 1300, 3540, 1200, 1000, 1100]),
             p(), p("Validation Queries", "Heading1")]
    for i, s in enumerate(sections, 1):
        rows = [("Project", s["project"]), ("Satellite", s["hub"]), ("Status", s["status"]),
                ("Pass criteria", s["pass_criteria"]), ("Result (Pass / Fail / NA)", "NA" if s["status"] == "NA" else ""),
                ("Rows with status = FAIL (count)", ""), ("Remarks", "")]
        body += [p(f"{i}. {s['project']} — {s['hub']}", "Heading2"), kv(rows), p()]
        if s.get("note"):
            body.append(K.p_note("Note:", s["note"]))
        for label, q in s["queries"]:
            body += [p(label, bold=True), K.code_box(q)]
        body += [p("Query output (attach / paste below)", bold=True), K.output_box(), p()]
    with zipfile.ZipFile(io.BytesIO(template_bytes)) as zt:
        doc_xml = zt.read("word/document.xml").decode()
        head = doc_xml[: doc_xml.index("<w:body>") + len("<w:body>")]
        sect = re.search(r"<w:sectPr.*?</w:sectPr>", doc_xml, re.S).group(0)
        new_doc = head + "".join(body) + sect + "</w:body></w:document>"
        out_path = K.out_dir(check_id) / f"{check_id}.docx"
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
                                  f"<dc:title>{K.x(meta['title'])}</dc:title>".encode(), data)
                zo.writestr(item, data)
        shutil.move(tmp, out_path)


def main():
    template = K.TEMPLATE_DOCX.read_bytes()
    sats = build_sats()
    sats.sort(key=lambda s: (s.project != "MAXIMUS", s.layer != "standard", s.name))
    # One file pair per check AND project (DM-A1_MAXIMUS, DM-A1_OPUS, ...) -- the combined files
    # were too heavy to open.
    for pj, md in PROJECTS:
        psats = [s for s in sats if s.project == pj]
        n_app = sum(1 for s in psats if s.applicable)
        n_grp = sum(len(s.groups) for s in psats)
        n_cols = sum(len(g.cols) for s in psats for g in s.groups.values())
        revision = [
            f"Generated 2026-10-13 from the current {md.parent.name} models by validation/tools/gen_dm_a.py "
            f"(reuses the gen_dm_k.py staging parser and hash formula).",
            f"This file: {pj} only ({len(psats)} satellites, standard + augmented); {n_app} have mapped payload, "
            f"{n_grp} RECORD_SOURCE groups, {n_cols} mapped (group, column) pairs. The other project is in the "
            f"sibling file ({'OPUS' if pj == 'MAXIMUS' else 'MAXIMUS'}).",
            "Lineage handled: stg_ direct, Maximus thin wrappers, Maximus unpivot arms (each arm's filter kept), "
            "Opus stitch views (recomputed from RAW with the stitch macro's coalesce priority and tie-break), "
            "OBJECT satellites (per-source-table entries), multi-active satellites (per child key).",
            "Sections marked NA load only hard-coded NULL padding or a disabled placeholder.",
            "DM-A1: trailing / leading space trimming and blank -> NULL in staging are a documented exception "
            "(agreed 2026-10-13); the staging trim rule stays unchanged.",
        ]
        for cid, meta in CHECKS.items():
            if cid == "DM-A1":
                sections = [a1_meta_section(pj, psats)] + [a1_section(s) for s in psats]
            else:
                sections = [a2_section(s) for s in psats]
            pmeta = dict(meta, title=f"{meta['title']}  ({pj})",
                         overview=[(k, v) for k, v in meta["overview"]] + [("Project in this file", pj)])
            fid = f"{cid}_{pj}"
            K.write_sql(fid, pmeta, sections, revision)
            write_docx(fid, pmeta, sections, revision, template)
            print(f"{fid}: {len(sections)} sections, {sum(x['status'] == 'NA' for x in sections)} NA")


if __name__ == "__main__":
    main()
