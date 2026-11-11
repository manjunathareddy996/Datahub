"""Property 11: Grain difference is confined to multi-row keys.

A Python reference evaluator of the original window semantics
(first_value(col) ignore nulls over (partition by key order by __PREC, __RID)) is compared with
a reference evaluator of the macro semantics (stitch_incremental.sql: one DISTINCT row set per
source, left joins on the key, QUALIFY ROW_NUMBER() ordered by every source column NULLS LAST,
then COALESCE across sources in source order). Branch order and key class come from
convert_stitches.parse/classify.

**Validates: Requirements 4.3, 4.9**
"""
import itertools
import sys
from pathlib import Path

from hypothesis import given, settings, strategies as st

sys.path.insert(0, str(Path(__file__).resolve().parent))
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
import convert_stitches as c  # noqa: E402
from test_convert_classify import branch, build, fv  # noqa: E402

SETTINGS = settings(max_examples=300, deadline=None)
COLS = ["S__A", "S__B"]
VAL = st.one_of(st.none(), st.sampled_from(["p", "q", "r", "s"]))
KEYS = st.sampled_from(["k1", "k2", "k3"])
CKS = st.sampled_from(["g1", "g2", None])


def make_stitch(n_tables: int, klass: str) -> str:
    items_tpl = ["pn as POLICY_BK", "a as S__A", "b as S__B"]
    part, key_cols = "POLICY_BK", ["POLICY_BK"]
    if klass == "C":
        items_tpl = items_tpl + ["kind as S__KIND_CK"]
        part, key_cols = "POLICY_BK, S__KIND_CK", ["POLICY_BK", "S__KIND_CK"]
    branches = [branch(i, f"T{i + 1}", list(items_tpl), 1000 + i) for i in range(n_tables)]
    fvs = [fv(col, part) for col in COLS]
    return build(branches, fvs, key_cols)


# ---- reference evaluators ------------------------------------------------------------------
def original_eval(tables, order):
    """tables: {branch index: [(key, a, b), ...]}; order: branch indexes by (__PREC, branch)."""
    out: dict = {}
    keys = {r[0] for rows in tables.values() for r in rows}
    for key in keys:
        rows = [r for t in order for r in tables[t] if r[0] == key]  # __RID = row order
        out[key] = tuple(next((r[i] for r in rows if r[i] is not None), None) for i in (1, 2))
    return out


def macro_eval(tables, order):
    out: dict = {}
    keys = {r[0] for rows in tables.values() for r in rows}
    for key in keys:
        per_src = []
        for t in order:
            distinct = list(dict.fromkeys((r[1], r[2]) for r in tables[t] if r[0] == key))
            per_src.append(distinct or [(None, None)])  # LEFT JOIN miss -> all NULL
        combos = itertools.product(*per_src)

        def sort_key(combo):  # ORDER BY alias.col NULLS LAST for each source, each column
            return [(v is None, v or "") for row in combo for v in row]

        best = min(combos, key=sort_key)  # ties are identical on the order terms -> same values
        out[key] = tuple(next((row[i] for row in best if row[i] is not None), None) for i in (0, 1))
    return out


def multi_row_keys(tables):
    return {k for rows in tables.values() for k in {r[0] for r in rows}
            if sum(1 for r in rows if r[0] == k) > 1}


@st.composite
def datasets(draw):
    klass = draw(st.sampled_from(["A", "C"]))
    n = draw(st.integers(1, 4))
    tables = {}
    for i in range(n):
        rows = draw(st.lists(st.tuples(KEYS, VAL, VAL), max_size=3))
        if klass == "C":
            cks = draw(st.lists(CKS, min_size=len(rows), max_size=len(rows)))
            # key tuple (bk, ck) is 1:1 with the macro's bk|coalesce(ck,'~') string
            rows = [((k, ck), a, b) for (k, a, b), ck in zip(rows, cks)]
        tables[i] = rows
    return klass, n, tables


@SETTINGS
@given(datasets())
def test_differences_only_on_multi_row_keys(data):
    klass, n, tables = data
    p = c.parse(make_stitch(n, klass), "g.sql")
    plan = c.classify(p)
    sat = p.sats[0]
    assert sat.klass == klass and not plan.findings
    order = [b.index for b in sorted(sat.branches, key=lambda b: (b.prec, b.index))]
    assert order == list(range(n))

    orig = original_eval(tables, order)
    mac = macro_eval(tables, order)
    assert orig.keys() == mac.keys()
    multi = multi_row_keys(tables)
    for key in orig:
        if orig[key] != mac[key]:
            assert key in multi, (key, orig[key], mac[key], tables)


def test_difference_exists_for_multi_row_key():
    tables = {0: [("k1", "r", None), ("k1", "p", None)], 1: [("k1", "q", None)]}
    assert original_eval(tables, [0, 1])["k1"] != macro_eval(tables, [0, 1])["k1"]
    assert multi_row_keys(tables) == {"k1"}


def test_single_row_keys_agree():
    tables = {0: [("k1", None, "q")], 1: [("k1", "p", "r"), ("k2", "s", None)]}
    assert original_eval(tables, [0, 1]) == macro_eval(tables, [0, 1])
