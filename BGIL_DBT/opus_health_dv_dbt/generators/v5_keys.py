# -*- coding: utf-8 -*-
"""Business-key expressions: where they come from, and whether one can be emitted.

Two sources, never one (reading one source reported hubs as keyed nowhere in an earlier build):

  v2 and delta 3  target.resolved_key in the map -- an executable expression per row.
  legacy          no resolved_key on any row. The expressions exist only in health_dv_dbt's
                  emitted automate_dv stage models ('HUB_X|' || <expr> derived columns) and in
                  the per-table CTEs of its stitched views (<expr> as parent_bk). They are read
                  from that project, read-only; its hashes are never reproduced, only its
                  business-key expressions, which this build hashes with automate_dv.stage().

The map's own hub_key rows are a third, narrower statement for the legacy half: (table, column,
hub). They are used only where the emitted SQL has no form for that (table, hub).
"""
import collections
import glob
import io
import os
import re

import v5_common as C

G1 = os.path.join(C.WORKSPACE, "health_dv_dbt", "models", "automate_dv")

RE_SRC = re.compile(r"^source_model:\s*'([^']+)'", re.M)
RE_DER = re.compile(r"^  ([A-Z0-9_]+):\s*(\"(?:[^\"\\]|\\.)*\"|'(?:[^'\\]|\\.)*')\s*$", re.M)
RE_NS = re.compile(r"^'((?:HUB|LNK)_[A-Z0-9_]+)\|'\s*\|\|\s*(.+)$", re.S)
RE_CTE = re.compile(
    r"select distinct\s+(.+?)\s+as parent_bk,.*?from \{\{ ref\('stg_health__([a-z0-9_]+)'\) \}\}",
    re.S)

SQL_WORDS = set("""nullif trim ltrim rtrim coalesce upper lower md5 cast as varchar to_varchar
to_char to_date case when then else end and or not null is in concat substr substring replace
regexp_replace lpad rpad iff nvl decode number int integer string text date timestamp_ntz
boolean try_cast split_part right left length len abs round floor ceil hash sha2 normalise
distinct""".split())


def norm(e):
    """One spelling per expression: whitespace collapsed, outer parentheses stripped, and
    everything OUTSIDE string literals lower-cased -- unquoted Snowflake identifiers and function
    names are case-insensitive, so 'ALLOTED_TO' and 'alloted_to' are one key, not two. Literal
    text is left exactly as written, because inside quotes case is data."""
    e = re.sub(r"\s+", " ", (e or "").strip())
    e = "".join(p if i % 2 else p.lower() for i, p in enumerate(re.split(r"('(?:[^']|'')*')", e)))
    while e.startswith("(") and e.endswith(")") and _balanced(e[1:-1]):
        e = e[1:-1].strip()
    return e


def _balanced(s):
    d = 0
    q = False
    for ch in s:
        if ch == "'":
            q = not q
        elif not q:
            if ch == "(":
                d += 1
            elif ch == ")":
                d -= 1
                if d < 0:
                    return False
    return d == 0 and not q


def identifiers(e):
    """Column identifiers in an expression: tokens outside string literals that are neither
    function names, SQL words nor numbers."""
    s = re.sub(r"'(?:[^']|'')*'", "''", e)
    out = []
    for m in re.finditer(r"[A-Za-z_][A-Za-z0-9_$]*", s):
        tok = m.group(0)
        rest = s[m.end():].lstrip()
        if rest.startswith("("):
            continue
        if tok.lower() in SQL_WORDS:
            continue
        out.append(tok)
    return out


def check_expr(e, table_cols):
    """None if the expression can be emitted against this table's staging columns, else why not.
    table_cols: set of lower-case staging aliases."""
    if not e or not e.strip():
        return "empty expression"
    if "normalise(" in e.lower():
        return ("calls normalise(), which is defined nowhere in this project, in either original "
                "or in the bundle; a tidied key is a different key, so it is not rewritten")
    if any(ch in e for ch in ('"', "\\", "{", "}")):
        return "contains a quote, backslash or brace that cannot be carried into stage YAML safely"
    ids = identifiers(e)
    if not ids:
        return "names no source column: a constant key keys every row to one hub row"
    missing = sorted({i for i in ids if i.lower() not in table_cols})
    if missing:
        return "references column(s) not on the table: %s" % ", ".join(missing)
    return None


def split_top(s, sep=","):
    parts, d, q, cur = [], 0, False, []
    for ch in s:
        if ch == "'":
            q = not q
        elif not q and ch == "(":
            d += 1
        elif not q and ch == ")":
            d -= 1
        if ch == sep and d == 0 and not q:
            parts.append("".join(cur))
            cur = []
        else:
            cur.append(ch)
    parts.append("".join(cur))
    return [p.strip() for p in parts if p.strip()]


def parse_lnk(e):
    """'LNK(HUB_A = expr, HUB_B = expr)' -> {HUB_A: expr, ...}; None if not that shape."""
    e = (e or "").strip()
    if not e.startswith("LNK(") or not e.endswith(")"):
        return None
    legs = {}
    for part in split_top(e[4:-1]):
        m = re.match(r"^(HUB_[A-Z0-9_]+)\s*=\s*(.+)$", part, re.S)
        if not m:
            return None
        legs[m.group(1)] = m.group(2).strip()
    return legs or None


# --------------------------------------------------------------- legacy key forms (gen 1 SQL)

def _derived(text):
    return {k: v[1:-1] for k, v in RE_DER.findall(text)}


def _best_code(rest, codes, prefix):
    """Longest model code whose lower-case short name is `rest` or a '_'-delimited prefix of it."""
    best = None
    for c in codes:
        s = C.short(c).lower()
        if rest == s or rest.startswith(s + "_"):
            if best is None or len(s) > len(C.short(best)):
                best = c
    if best is None:
        return None, None
    tag = rest[len(C.short(best)):].strip("_")
    return best, tag


RE_STG_COL = re.compile(r'"([A-Za-z_][A-Za-z0-9_$]*)"')


def legacy_staged_columns():
    """Source columns health_dv_dbt's staging casts read, per legacy table. The map does not
    enumerate every source column, and a recovered key expression may name one it omits; the
    staging cast that the expression was written against is the evidence the column exists."""
    out = {}
    for f in sorted(glob.glob(os.path.join(C.WORKSPACE, "health_dv_dbt", "models", "staging",
                                           "health", "stg_health__*.sql"))):
        table = os.path.basename(f)[len("stg_health__"):-4].upper()
        out[table] = set(RE_STG_COL.findall(io.open(f, encoding="utf-8").read()))
    return out


def legacy_forms():
    """Recover the legacy half's key expressions from health_dv_dbt. Read-only."""
    d7 = C.model()
    sats = [s["code"] for s in d7["sats"]]
    links = [l["code"] for l in d7["links"]]
    stitch_ctes = {}
    for f in sorted(glob.glob(os.path.join(G1, "standard", "stitched", "*.sql"))):
        t = io.open(f, encoding="utf-8").read()
        stitch_ctes[os.path.basename(f)[:-4]] = [(tb.upper(), norm(e)) for e, tb in RE_CTE.findall(t)]

    ts = collections.defaultdict(set)     # (TABLE, SAT) -> {(hub, expr, tag)}
    th = collections.defaultdict(set)     # (TABLE, HUB) -> {expr}
    tl = collections.defaultdict(dict)    # (TABLE, LNK) -> {hub: expr}
    files = 0
    for f in sorted(glob.glob(os.path.join(G1, "*", "staging", "*.sql"))):
        name = os.path.basename(f)[:-4]
        text = io.open(f, encoding="utf-8").read()
        m = RE_SRC.search(text)
        if not m:
            continue
        files += 1
        src = m.group(1)
        hubs = {}
        for k, v in _derived(text).items():
            mm = RE_NS.match(v)
            if mm and mm.group(1).startswith("HUB_"):
                hubs.setdefault(mm.group(1), set()).add(norm(mm.group(2)))
        if src.startswith("stg_health__"):
            table = src[len("stg_health__"):].upper()
            for h, es in hubs.items():
                th[(table, h)] |= es
            if name.startswith("stg2_sat_") and "__" in name:
                sat, tag = _best_code(name.split("__", 1)[1], sats, "SAT_")
                if sat:
                    for h, es in hubs.items():
                        for e in es:
                            ts[(table, sat)].add((h, e, tag))
            elif name.startswith("stg2_link_") and "__" in name:
                lnk, _tag = _best_code(name.split("__", 1)[1], links, "LNK_")
                if lnk and all(len(es) == 1 for es in hubs.values()):
                    tl[(table, lnk)] = {h: next(iter(es)) for h, es in hubs.items()}
            else:
                sat = "SAT_" + name[len("stg2_"):].upper()
                if sat in sats:
                    for h, es in hubs.items():
                        for e in es:
                            ts[(table, sat)].add((h, e, ""))
        elif src.startswith("stitch_"):
            sat = "SAT_" + src[len("stitch_"):].upper()
            for h, es in hubs.items():
                if es != {"parent_bk"}:
                    continue
                for table, e in stitch_ctes.get(src, []):
                    th[(table, h)].add(e)
                    if sat in sats:
                        ts[(table, sat)].add((h, e, ""))
    return {"ts": ts, "th": th, "tl": tl, "files_read": files}
