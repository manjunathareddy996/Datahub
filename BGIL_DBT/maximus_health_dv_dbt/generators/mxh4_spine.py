# -*- coding: utf-8 -*-
"""Render the map's executable key expressions as SQL inside one central-view branch.

The branch reads its own table as alias t0. A spine span becomes joins:

  spine[PARENT_KEY_HASH -> A -> B].COL      climb: one LEFT JOIN per REAL level of the shred
                                            graph from t0 up to B (named hops are waypoints and
                                            must lie on that path in order), then <B>.COL
  spine[FOREIGN_KEY -> A].COL               the same climb, entered on t0.FOREIGN_KEY
  spine[... -> X] >> Y.COL                  climb to X, then DESCEND to Y (a descendant of X in
                                            another branch) through a subquery grouped by X's
                                            KEY_HASH; the value is used only when exactly one
                                            distinct value exists, so a 1:N descend gives NULL
  KEY_HASH >> Y.COL                         descend from t0 itself

Every other column is qualified t0.<col> and must be on t0's table. Function calls must be on
the map's ratified allowlist. Anything else raises Unresolvable -- the caller refuses the row.
Direction is read from the graph, never from the arrow token.
"""
import collections
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import mxh4_common as C  # noqa: E402

RATIFIED = {"md5", "normalise", "coalesce", "nullif", "upper", "lower", "trim", "to_char"}
SQL_WORDS = {"case", "when", "then", "else", "end", "is", "not", "null", "and", "or", "in", "as",
             "varchar", "true", "false"}
RE_STR = re.compile(r"'(?:[^']|'')*'")
RE_SPAN = re.compile(r"spine\[\s*([A-Z_]+)\s*((?:->\s*[A-Z0-9_]+\s*)*)\]\s*"
                     r"(?:>>\s*([A-Z0-9_]+)\.([A-Z0-9_]+)|\.\s*([A-Z0-9_]+))")
RE_BARE = re.compile(r"\b(KEY_HASH)\s*>>\s*([A-Z0-9_]+)\.([A-Z0-9_]+)")
RE_IDENT = re.compile(r"[A-Za-z_][A-Za-z0-9_]*")


class Unresolvable(Exception):
    pass


def ref(table):
    return "{{ ref('%s') }}" % C.staging_model(table)


def cols_of(table):
    return {c.upper() for c in C.tables()[table]["columns"]}


def spans_in(text):
    """(dest_table, dest_col, span_text) for every executable span in a key text."""
    out = []
    for m in RE_SPAN.finditer(text or ""):
        hops = [h.strip() for h in m.group(2).split("->") if h.strip()]
        if m.group(3):
            out.append((m.group(3), m.group(4), m.group(0)))
        elif hops:
            out.append((hops[-1], m.group(5), m.group(0)))
    for m in RE_BARE.finditer(text or ""):
        out.append((m.group(2), m.group(3), m.group(0)))
    return out


class Renderer(object):
    """One per branch: renders expressions against table t0 and accumulates the joins."""

    def __init__(self, table, policy):
        self.table = table
        self.policy = policy
        self.joins = collections.OrderedDict()     # key -> (alias, sql)
        self.tables = {table}                      # every staging model the branch reads
        self.walk_tables = set()

    # ---------------------------------------------------------------- joins
    def _alias(self, key, prefix, sql_fn):
        if key not in self.joins:
            alias = "%s%d" % (prefix, 1 + sum(1 for a, _ in self.joins.values() if a.startswith(prefix)))
            self.joins[key] = (alias, sql_fn(alias))
        return self.joins[key][0]

    def climb(self, start, hops):
        T = self.table
        if start == "KEY_HASH" and not hops:
            return "t0", T
        if start not in ("PARENT_KEY_HASH", "FOREIGN_KEY") or not hops:
            raise Unresolvable("span start %r with %d hop(s) is not a climb this build can run"
                               % (start, len(hops)))
        if start not in cols_of(T):
            raise Unresolvable("%s has no %s column" % (T, start))
        anc = C.ancestors(T)
        idx = []
        for h in hops:
            if h not in anc:
                raise Unresolvable("named hop %s is not an ancestor of %s in the shred graph"
                                   % (h, T))
            idx.append(anc.index(h))
        if idx != sorted(idx) or len(set(idx)) != len(idx):
            raise Unresolvable("named hops are not in ancestor order for %s" % T)
        path = anc[:idx[-1] + 1]
        prev = "t0"
        for i, tab in enumerate(path):
            if "KEY_HASH" not in cols_of(tab):
                raise Unresolvable("%s has no KEY_HASH" % tab)
            if i > 0 and "PARENT_KEY_HASH" not in cols_of(path[i - 1]):
                raise Unresolvable("%s has no PARENT_KEY_HASH" % path[i - 1])
            on = ("t0.%s" % start) if i == 0 else ("%s.PARENT_KEY_HASH" % prev)
            key = ("climb", start, tuple(path[:i + 1]))
            prev = self._alias(key, "j", lambda a, tab=tab, on=on:
                               "left join %s %s on %s.KEY_HASH = %s" % (ref(tab), a, a, on))
            self.tables.add(tab)
            self.walk_tables.add(tab)
        return prev, path[-1]

    def descend(self, x_alias, x_table, y_table, col):
        anc = C.ancestors(y_table)
        if x_table not in anc:
            raise Unresolvable("%s is not a descendant of %s in the shred graph" % (y_table, x_table))
        if col not in cols_of(y_table):
            raise Unresolvable("%s has no column %s" % (y_table, col))
        chain = [y_table] + anc[:anc.index(x_table)]          # y, its parent, ..., child of X
        chain = list(reversed(chain))                          # child of X first ... y last
        for t in chain:
            self.tables.add(t)
            self.walk_tables.add(t)
            if "PARENT_KEY_HASH" not in cols_of(t) or "KEY_HASH" not in cols_of(t):
                raise Unresolvable("%s lacks KEY_HASH/PARENT_KEY_HASH" % t)
        frm = ["from %s d0" % ref(chain[0])]
        for i in range(1, len(chain)):
            frm.append("join %s d%d on d%d.PARENT_KEY_HASH = d%d.KEY_HASH" % (ref(chain[i]), i, i, i - 1))
        last = "d%d" % (len(chain) - 1)
        ca = C.source_alias(col)
        sub = ("(\n            select d0.PARENT_KEY_HASH as _K, max(%s.%s) as _V, count(distinct %s.%s) as _N\n"
               "            %s\n            group by d0.PARENT_KEY_HASH\n        )") % (
                   last, ca, last, ca, "\n            ".join(frm))
        key = ("descend", x_alias, y_table, col)
        a = self._alias(key, "x", lambda a: "left join %s %s on %s._K = %s.KEY_HASH" % (sub, a, a, x_alias))
        return "(case when %s._N = 1 then %s._V end)" % (a, a)

    # ---------------------------------------------------------------- expressions
    def render(self, expr):
        if expr is None or not str(expr).strip():
            raise Unresolvable("empty expression")
        if "spine:" in expr:
            raise Unresolvable("display-only 'spine:' form is not executable")
        if "normalise(" in expr and self.policy != "emit":
            raise Unresolvable("calls normalise() and normalise_policy is %r" % self.policy)
        lits = []

        def keep_lit(m):
            lits.append(m.group(0))
            return "\x00L%d\x00" % (len(lits) - 1)
        s = RE_STR.sub(keep_lit, expr)
        if any(ch in s for ch in ('"', "\\", "{", "}", ";")):
            raise Unresolvable("contains a quote, backslash, brace or semicolon outside a literal")
        subs = []

        def keep_span(sql):
            subs.append(sql)
            return "\x00S%d\x00" % (len(subs) - 1)

        def span(m):
            start = m.group(1)
            hops = [h.strip() for h in m.group(2).split("->") if h.strip()]
            xa, xt = self.climb(start, hops)
            if m.group(3):
                return keep_span(self.descend(xa, xt, m.group(3), m.group(4)))
            col = m.group(5)
            if col not in cols_of(xt):
                raise Unresolvable("%s has no column %s" % (xt, col))
            return keep_span("%s.%s" % (xa, C.source_alias(col)))
        s = RE_SPAN.sub(span, s)

        def bare(m):
            return keep_span(self.descend("t0", self.table, m.group(2), m.group(3)))
        s = RE_BARE.sub(bare, s)
        if "spine" in s or ">>" in s or "->" in s:
            raise Unresolvable("spine notation left after resolving every span")
        t_cols = cols_of(self.table)

        def qualify(seg):
            # `seg` is a stretch of the expression between placeholders; a token is a call when
            # the next non-blank character IN THIS SEGMENT is '('.
            def ident(m):
                tok = m.group(0)
                if seg[m.end():].lstrip().startswith("("):
                    if tok.lower() not in RATIFIED:
                        raise Unresolvable("function %s() is not on the ratified allowlist" % tok)
                    return tok.lower()
                if tok.lower() in SQL_WORDS:
                    return tok
                if tok.upper() not in t_cols:
                    raise Unresolvable("%s has no column %s" % (self.table, tok))
                return "t0." + C.source_alias(tok)
            return RE_IDENT.sub(ident, seg)
        out = []
        pos = 0
        for m in re.finditer(r"\x00[LS]\d+\x00", s):
            out.append(qualify(s[pos:m.start()]))
            out.append(m.group(0))
            pos = m.end()
        out.append(qualify(s[pos:]))
        s = "".join(out)
        s = re.sub(r"\x00S(\d+)\x00", lambda m: subs[int(m.group(1))], s)
        s = re.sub(r"\x00L(\d+)\x00", lambda m: lits[int(m.group(1))], s)
        return re.sub(r"\s+", " ", s).strip()

    def column(self, col):
        if col.upper() not in cols_of(self.table):
            raise Unresolvable("%s has no column %s" % (self.table, col))
        return "t0." + C.source_alias(col)


def parse_lnk(e):
    e = (e or "").strip()
    if not e.startswith("LNK(") or not e.endswith(")"):
        return None
    legs = {}
    for part in split_top(e[4:-1], ","):
        m = re.match(r"^(HUB_[A-Z0-9_]+)\s*=\s*(.+)$", part, re.S)
        if not m:
            return None
        legs[m.group(1)] = m.group(2).strip()
    return legs or None


def split_top(s, sep, opens="([{", closes=")]}"):
    parts, d, q, cur = [], 0, False, []
    i = 0
    while i < len(s):
        ch = s[i]
        if ch == "'":
            q = not q
        elif not q and ch in opens:
            d += 1
        elif not q and ch in closes:
            d -= 1
        if not q and d == 0 and s.startswith(sep, i):
            parts.append("".join(cur))
            cur = []
            i += len(sep)
            continue
        cur.append(ch)
        i += 1
    parts.append("".join(cur))
    return [p.strip() for p in parts if p.strip()]


def sql_lit(v):
    return "'" + str(v).replace("'", "''") + "'"


def bk_sql(rendered, verdict, degenerate):
    """The business-key column: NULL when empty or equal to its own degenerate value; a pure
    literal (constant_on_blank_row) is accepted as it is."""
    if verdict == "constant_on_blank_row":
        return rendered
    s = "nullif(%s, '')" % rendered
    if degenerate not in (None, ""):
        s = "nullif(%s, %s)" % (s, sql_lit(degenerate))
    return s


def render_ck_value(value, backing, rd, key_text):
    """One child-key leg value -> SQL. `key_text` is the row's resolved_key text, the only place a
    'spine:' display operand may be resolved from."""
    if backing == "surrogate":
        raise Unresolvable("shred surrogate child key (quarantined by directive)")
    if value is None or backing in ("unresolved", "source_gap"):
        raise Unresolvable("leg has no value (%s)" % backing)
    if backing == "literal":
        if "{" in value or "}" in value:
            raise Unresolvable("literal leg carries a brace")
        return sql_lit(value)
    parts, buf, i = [], [], 0
    while i < len(value):
        ch = value[i]
        if ch == "{":
            if buf:
                parts.append(("text", "".join(buf)))
                buf = []
            d, j = 0, i
            while j < len(value):
                if value[j] == "{":
                    d += 1
                elif value[j] == "}":
                    d -= 1
                    if d == 0:
                        break
                j += 1
            if d != 0:
                raise Unresolvable("unbalanced braces in %r" % value)
            parts.append(("group", value[i + 1:j]))
            i = j + 1
            continue
        if ch in "#@":
            if buf:
                parts.append(("text", "".join(buf)))
                buf = []
            parts.append(("sep", ch))
        else:
            buf.append(ch)
        i += 1
    if buf:
        parts.append(("text", "".join(buf)))
    out = []
    for kind, v in parts:
        if kind in ("text", "sep"):
            out.append(sql_lit(v))
            continue
        ops = []
        ladder = split_top(v, "|", "(", ")")
        for oi, op in enumerate(ladder):
            # A ladder is a cross-view business template. A FALLBACK operand (not the first) on a
            # column this view does not carry can never fire on this view, so evaluating the
            # ladder here is the coalesce of the operands it does carry. The FIRST operand is
            # never dropped: it has precedence, and losing it would change the value.
            if oi > 0 and "spine:" not in op:
                named = [i for i in re.findall(r"[A-Za-z_][A-Za-z0-9_]*", re.sub(r"'(?:[^']|'')*'", "", op))
                         if i.lower() not in ("nullif", "trim", "coalesce", "upper", "lower")]
                if named and all(n.upper() not in cols_of(rd.table) for n in named):
                    continue
            if "spine:" in op:
                m = re.search(r"spine:([A-Z0-9_]+)\.([A-Z0-9_]+)", op)
                if not m:
                    raise Unresolvable("display operand %r names no column" % op)
                hits = {sp for t, c, sp in spans_in(key_text)
                        if c == m.group(2) and (t == m.group(1) or t.endswith("_" + m.group(1)))}
                if len(hits) != 1:
                    raise Unresolvable("display operand %s.%s has %d matching walk(s) in the row's "
                                       "resolved_key" % (m.group(1), m.group(2), len(hits)))
                op = op.replace(m.group(0), next(iter(hits)))
            if re.match(r"^[A-Za-z_][A-Za-z0-9_]*$", op.strip()):
                ops.append(rd.column(op.strip()))
            else:
                ops.append(rd.render(op))
        out.append(ops[0] if len(ops) == 1 else "coalesce(%s)" % ", ".join(ops))
    return out[0] if len(out) == 1 else " || ".join(out)
