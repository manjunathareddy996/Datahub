"""Property 13: Legacy merge tokens appear only where allowed.

For any generated file, macro parts contain none of `union all`, `__PREC`, `__RID`, `first_value`;
consumer views may contain `union all` but none of `__PREC`, `__RID`, `first_value`; only
Fallback_Stitches may contain all four. For any consumer view, every comment line of the original
header (source precedence and satellites fed) appears in it.

**Validates: Requirements 4.18, 4.19**
"""
import sys
import tempfile
from pathlib import Path

from hypothesis import given, settings, strategies as st

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
sys.path.insert(0, str(Path(__file__).resolve().parent))
import convert_stitches as c  # noqa: E402
from test_convert_classify import branch, build, fv  # noqa: E402

FILE = "stitch_v09_demo.sql"
LINK_DEFS = {"LNK_POLICY_COVERAGE": ["COVERAGE_BK", "POLICY_BK"]}
LITERALS = ["AAA", "BBB", "CCC"]
LEGACY = ("union all", "__prec", "__rid", "first_value")
HEADER_WORDS = ["precedence", "policy", "claims", "feeds", "SAT_ONE", "SAT_TWO", "table"]


@st.composite
def stitches(draw):
    """Random original stitch; returns (text, has_fallback_sat)."""
    n_head = draw(st.integers(1, 4))
    header = "-- CENTRAL VIEW v09\n" + "".join(
        f"-- {draw(st.sampled_from(HEADER_WORDS))} {i}: {draw(st.sampled_from(HEADER_WORDS))}\n"
        for i in range(n_head))
    branches, fvs, key_cols = [], [], ["POLICY_BK"]
    idx = 0
    for s in range(1, draw(st.integers(1, 3)) + 1):
        sat = f"S{s}"
        kind = draw(st.sampled_from("ABC"))
        pay = [f"{sat}__V{i}" for i in range(draw(st.integers(1, 3)))]
        ck = f"{sat}__KIND_CK"
        for j in range(draw(st.integers(1, 3))):
            items = [f"pn{idx} as POLICY_BK"]
            if kind == "B":
                items.append(f"'{draw(st.sampled_from(LITERALS))}' as {ck}")
            elif kind == "C":
                items.append(f"kind{idx} as {ck}" if j == 0 or draw(st.booleans()) else f"'GROUP' as {ck}")
            items += [f"v{idx}_{i} as {p}" for i, p in enumerate(pay)]
            branches.append(branch(idx, f"T{idx}", items, 1000 + idx))
            idx += 1
        fvs += [fv(p, "POLICY_BK" if kind == "A" else f"POLICY_BK, {ck}") for p in pay]
        if kind != "A":
            key_cols.append(ck)
    fallback = draw(st.booleans())
    if fallback:  # a window in the key expression forces a Fallback_Stitch for this satellite
        branches.append(branch(idx, f"T{idx}", ["max(a) over (partition by z) as POLICY_BK", "x as SF__V"], 1000 + idx))
        idx += 1
        fvs.append(fv("SF__V", "POLICY_BK"))
    if draw(st.booleans()):
        branches.append(branch(idx, f"T{idx}", [f"a{idx} as POLICY_BK", f"b{idx} as COVERAGE_BK",
                                                "1 as __LNK_POLICY_COVERAGE"], 1000 + idx))
        idx += 1
        key_cols += ["COVERAGE_BK", "__LNK_POLICY_COVERAGE"]
    if draw(st.booleans()):
        branches.append(branch(idx, f"T{idx}", [f"h{idx} as OTHER_BK"], 1000 + idx))
        key_cols.append("OTHER_BK")
    return header + build(branches, fvs, key_cols), fallback


@settings(max_examples=150, deadline=None)
@given(stitches())
def test_legacy_tokens_only_where_allowed(case):
    text, has_fallback = case
    with tempfile.TemporaryDirectory() as d:
        path = Path(d) / FILE
        path.write_text(text, encoding="utf-8")
        r = c.build_stitch(path, link_defs=LINK_DEFS)
    assert r.status == "ok", r.error
    assert r.parts  # at least one macro part, so the consumer view is generated, not the original
    assert (r.fallback is not None) == has_fallback

    # macro parts: none of the four tokens
    for m in r.parts:
        low = m.text.lower()
        for tok in LEGACY:
            assert tok not in low, (m.name, tok)

    # consumer view: union all allowed, the other three never
    view = r.view.lower()
    for tok in ("__prec", "__rid", "first_value"):
        assert tok not in view, tok
    if len(r.parts) + (1 if r.fallback else 0) > 1:
        assert "union all" in view

    # every original header comment line is kept in the consumer view
    assert r.parsed.header
    assert all(line in r.view for line in r.parsed.header)

    # the Fallback_Stitch is the only model that may carry the legacy tokens
    if r.fallback:
        low = r.fallback.text.lower()
        assert all(tok in low for tok in LEGACY)
        assert r.fallback.name.startswith("stitch_fb_")
    files = r.files()
    for name, content in files.items():
        if r.fallback and name == r.fallback.name + ".sql":
            continue
        low = content.lower()
        assert "__prec" not in low and "__rid" not in low and "first_value" not in low, name
        if name != FILE:
            assert "union all" not in low, name
