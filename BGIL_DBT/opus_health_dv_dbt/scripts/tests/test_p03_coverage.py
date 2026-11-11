"""Property 3: Every satellite and link is covered exactly once.

Feature: opus-health-dv-dbt-runnable, Property 3.
**Validates: Requirements 4.1, 4.6, 4.11, 4.16, 4.17**
"""
import re
import sys
from pathlib import Path

from hypothesis import HealthCheck, given, settings, strategies as st

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
sys.path.insert(0, str(Path(__file__).resolve().parent))
import convert_stitches as c  # noqa: E402
from test_convert_classify import NULL, branch, build, fv  # noqa: E402

FILE = "stitch_v07_demo.sql"
HEADER = "-- CENTRAL VIEW v07\n-- Tables merged:\n--   T1\n"
LINK = "LNK_POLICY_COVERAGE"


@st.composite
def stitches(draw):
    """A stitch with 1-4 satellites of class A / B / C and an optional link."""
    n = draw(st.integers(1, 4))
    kinds = [draw(st.sampled_from(["A", "B", "C", "CMIX"])) for _ in range(n)]
    with_link = draw(st.booleans())
    branches, fvs, keys, expect = [], [], ["POLICY_BK"], {}
    idx, prec = 0, 1000

    def add(items):
        nonlocal idx, prec
        branches.append(branch(idx, f"T{idx}", items, prec))
        idx += 1
        prec += 1

    for i, kind in enumerate(kinds):
        s, v, ck = f"SAT{i}", f"SAT{i}__V", f"SAT{i}__KIND_CK"
        if kind == "A":
            for _ in range(draw(st.integers(1, 3))):
                add([f"pn{idx} as POLICY_BK", f"x{idx} as {v}"])
            fvs.append(fv(v, "POLICY_BK"))
            expect[s] = 1
        elif kind == "B":
            lits = draw(st.lists(st.sampled_from(["AAA", "BBB", "CCC", "DDD"]), min_size=1, max_size=5))
            for lit in lits:
                add([f"pn{idx} as POLICY_BK", f"'{lit}' as {ck}", f"x{idx} as {v}"])
            fvs.append(fv(v, f"POLICY_BK, {ck}"))
            keys.append(ck)
            expect[s] = len(set(lits))
        else:
            for _ in range(draw(st.integers(1, 3))):
                add([f"pn{idx} as POLICY_BK", f"k{idx} as {ck}", f"x{idx} as {v}"])
            if kind == "CMIX":
                add([f"pn{idx} as POLICY_BK", f"'LIT' as {ck}", f"x{idx} as {v}"])
            fvs.append(fv(v, f"POLICY_BK, {ck}"))
            keys.append(ck)
            expect[s] = 1
    if with_link:
        m = f"__{LINK}"
        add(["a as POLICY_BK", "b as COVERAGE_BK", f"1 as {m}"])
        add(["a as POLICY_BK", f"{NULL} as COVERAGE_BK", f"1 as {m}"])
        keys += ["COVERAGE_BK", m]
    return HEADER + build(branches, fvs, keys), expect, with_link


@settings(max_examples=200, deadline=None, suppress_health_check=[HealthCheck.too_slow])
@given(stitches())
def test_every_satellite_and_link_covered_exactly_once(case):
    text, expect, with_link = case
    p = c.parse(text, FILE)
    defs = {LINK: ["COVERAGE_BK", "POLICY_BK"]} if with_link else {}
    plan = c.classify(p, link_defs=defs)
    assert not [f for f in plan.findings if f.fallback]
    parts = c.render_parts(p, plan)
    macro = [m for m in parts if m.kind != "HUB"]

    # target_sat values equal the satellites and links fed; none foreign
    fed = {f"sat_{s.lower()}" for s in expect} | ({LINK.lower()} if with_link else set())
    assert {m.target_sat for m in macro} == fed
    assert {m.target_sat for m in macro} <= fed

    # exactly one part for class A / C / link; one per distinct literal for class B
    for s, n in expect.items():
        mine = [m for m in macro if m.target_sat == f"sat_{s.lower()}"]
        assert len(mine) == n, (s, [m.name for m in mine])
        assert len({m.name for m in mine}) == n
    if with_link:
        lks = [m for m in macro if m.kind == "LINK"]
        assert len(lks) == 1
        assert re.fullmatch(r"stitch_lk_policy_coverage__v07", lks[0].name)
        assert lks[0].target_sat == LINK.lower()
    else:
        assert not [m for m in macro if m.kind == "LINK"]

    # a mixed literal / data-driven satellite is built in one call
    for s in plan.sats:
        if s.klass == "C":
            assert len([m for m in macro if m.target_sat == f"sat_{s.sat.lower()}"]) == 1

    # consumer view keeps the original file name (one view per original, parts never reuse it)
    assert Path(FILE).stem not in {m.name for m in parts}
    view = c.render_view(p, parts)
    assert view.count("union all") == len(parts) - 1
