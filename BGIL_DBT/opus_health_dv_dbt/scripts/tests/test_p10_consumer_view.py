"""Property 10: Consumer views keep the column contract and the consumed semantics.

For any generated original stitch the consumer view keeps the original name, header and column list
and order, unions all parts (macro parts and link parts `stitch_lk_<link>__vNN`) through `ref`, pads
the columns a part does not own with `cast(null as ...)`, takes every payload column from its owner
part(s), takes BK, CK and link legs from the Key_Part_Columns of the owning part, and contains no
window functions, `__PREC` or `__RID`.

**Validates: Requirements 4.1, 4.9, 4.11, 4.12, 5.3**
"""
import re
import sys
import tempfile
from pathlib import Path

from hypothesis import given, settings, strategies as st

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
sys.path.insert(0, str(Path(__file__).resolve().parent))
import convert_stitches as c  # noqa: E402
from test_convert_classify import NULL, branch, build, fv  # noqa: E402

HEADER = "-- CENTRAL VIEW vXX\n-- Tables merged:\n--   T1\n"
FILE = "stitch_v07_demo.sql"
LINK_DEFS = {"LNK_POLICY_COVERAGE": ["COVERAGE_BK", "POLICY_BK"]}
LITERALS = ["AAA", "BBB", "CCC"]
_ITEM = re.compile(r"^\s+(?P<src>.+?) as (?P<col>\w+),?$")
_REF = re.compile(r"from \{\{ ref\('([^']+)'\) \}\}\s*$")


@st.composite
def stitches(draw):
    """Return (text, expected) for a random stitch of satellites (A, B, C), maybe a link and a hub-only key."""
    n_sats = draw(st.integers(1, 3))
    branches, fvs, key_cols, expected_parts, payload_by_sat = [], [], ["POLICY_BK"], {}, {}
    idx = 0
    for s in range(1, n_sats + 1):
        sat = f"S{s}"
        kind = draw(st.sampled_from("ABC"))
        n_pay = draw(st.integers(1, 3))
        pay = [f"{sat}__V{i}" for i in range(n_pay)]
        ck = f"{sat}__KIND_CK"
        n_br = draw(st.integers(1, 3))
        lits = []
        for j in range(n_br):
            items = [f"pn{idx} as POLICY_BK"]
            if kind == "B":
                lit = draw(st.sampled_from(LITERALS))
                lits.append(lit)
                items.append(f"'{lit}' as {ck}")
            elif kind == "C":
                if j == 0 or draw(st.booleans()):
                    items.append(f"kind{idx} as {ck}")
                else:
                    items.append(f"'GROUP' as {ck}")
            items += [f"v{idx}_{i} as {p}" for i, p in enumerate(pay)]
            branches.append(branch(idx, f"T{idx}", items, 1000 + idx))
            idx += 1
        part = "POLICY_BK" if kind == "A" else f"POLICY_BK, {ck}"
        fvs += [fv(p, part) for p in pay]
        if kind != "A":
            key_cols.append(ck)
        payload_by_sat[sat] = pay
        base = f"stitch_{sat.lower()}"
        if kind == "B":
            names = [f"{base}__{l.lower()}" for l in dict.fromkeys(lits)]
        else:
            names = [base]
        cks = [ck.lower()] if kind != "A" else []
        for n in names:
            expected_parts[n] = {"kind": kind, "cols": {"POLICY_BK": "policy_bk", **{ck: ck.lower() for _ in cks},
                                                        **{p: p.lower() for p in pay}}}
    expected_order = list(expected_parts)
    if draw(st.booleans()):
        branches.append(branch(idx, f"T{idx}", [f"a{idx} as POLICY_BK", f"b{idx} as COVERAGE_BK",
                                                "1 as __LNK_POLICY_COVERAGE"], 1000 + idx))
        idx += 1
        key_cols += ["COVERAGE_BK", "__LNK_POLICY_COVERAGE"]
        name = "stitch_lk_policy_coverage__v07"
        expected_parts[name] = {"kind": "LINK", "cols": {"POLICY_BK": "policy_bk", "COVERAGE_BK": "coverage_bk"},
                                "const": {"__LNK_POLICY_COVERAGE": "1"}}
    if draw(st.booleans()):
        branches.append(branch(idx, f"T{idx}", [f"h{idx} as OTHER_BK"], 1000 + idx))
        idx += 1
        key_cols.append("OTHER_BK")
        expected_parts["stitch_hk_other"] = {"kind": "HUB", "cols": {"OTHER_BK": "other_bk"}}
    text = HEADER + build(branches, fvs, key_cols)
    columns = key_cols + [p for ps in payload_by_sat.values() for p in ps]
    return text, {"columns": columns, "parts": expected_parts, "payload": payload_by_sat}


def split_view(view: str):
    """Return [(ref_name, [(col, src)])] of every select block of the consumer view."""
    body = view.split("-- Consumer view over parts:", 1)[1].split("\n", 1)[1]
    blocks = []
    for blk in body.split("\n\nunion all\n\n"):
        items, ref = [], None
        for line in blk.strip().splitlines():
            m = _REF.search(line)
            if m:
                ref = m.group(1)
                continue
            m = _ITEM.match(line)
            if m:
                items.append((m.group("col"), m.group("src")))
        blocks.append((ref, items))
    return blocks


@settings(max_examples=150, deadline=None)
@given(stitches())
def test_consumer_view_contract(case):
    text, exp = case
    with tempfile.TemporaryDirectory() as d:
        path = Path(d) / FILE
        path.write_text(text, encoding="utf-8")
        r = c.build_stitch(path, link_defs=LINK_DEFS)
    assert r.status == "ok", r.error
    assert not r.plan.findings

    # (a) original file name kept; parts live in their own files
    files = r.files()
    assert files[FILE] == r.view
    assert set(files) == {FILE} | {n + ".sql" for n in exp["parts"]}

    # no windows, __PREC or __RID in the consumer view; header comments kept
    low = r.view.lower()
    for tok in ("first_value", "__prec", "__rid", "ignore nulls", "over (", "over("):
        assert tok not in low
    assert all(line in r.view for line in r.parsed.header)

    blocks = split_view(r.view)
    # union all of the parts, one block per part, each referenced through ref
    assert r.view.count("union all") == len(blocks) - 1 == len(exp["parts"]) - 1
    assert [b[0] for b in blocks] == r.part_names()
    assert set(b[0] for b in blocks) == set(exp["parts"])
    assert all(f"ref('{n}')" in r.view for n in exp["parts"])

    parts = {m.name: m for m in r.parts}
    owners: dict[str, list[str]] = {}
    for ref, items in blocks:
        # (b) original column list and order in every block
        assert [col for col, _ in items] == exp["columns"] == list(r.parsed.columns)
        want = exp["parts"][ref]
        m = parts[ref]
        for col, src in items:
            if col in want["cols"]:
                # owned columns come from the part's own Key_Part_Column / payload column
                assert src == want["cols"][col]
                # (class A/B/hub: the hub key is the macro's unique_key column)
                assert src in m.output_columns or src == m.unique_key
                owners.setdefault(col, []).append(ref)
            elif col in want.get("const", {}):
                assert src == want["const"][col]
            elif col.startswith("__LNK_"):
                assert src == "cast(null as int)"
            else:
                assert src == NULL
        assert not any(w in src for _, src in items for w in ("first_value", "__PREC", "__RID"))

    # (c) each payload column is supplied by its owner part(s) only: the satellite's parts
    for sat, pay in exp["payload"].items():
        sat_parts = [n for n in exp["parts"] if n.startswith(f"stitch_{sat.lower()}")]
        for p in pay:
            assert sorted(owners[p]) == sorted(sat_parts)
    # (d) key columns come from the Key_Part_Columns of the owning parts
    for key in ("POLICY_BK", "COVERAGE_BK", "OTHER_BK"):
        if key in exp["columns"]:
            want_parts = [n for n, w in exp["parts"].items() if key in w["cols"]]
            assert sorted(owners[key]) == sorted(want_parts)
