"""Unit tests for satellite classification and composite key rendering (task 7.2).

Requirements 4.8, 4.9, 4.10, 4.11, 4.12, 4.14, 4.15, 4.16.
"""
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
import convert_stitches as c  # noqa: E402

WIN = "rows between unbounded preceding and unbounded following"


def stitch(branches: str, windows: str, cols: str, header: str = "") -> str:
    return f"""{header}{{{{ config(materialized='view') }}}}

with merged as (
{branches}
)

select
{cols}
{windows}
from merged
"""


def branch(i, table, items, prec=1000, where=""):
    sel = ",\n        ".join(items + [f"{prec} as __PREC", "hash(*) as __RID"])
    return (f"    -- branch {i}: {table}\n    select\n        {sel}\n"
            f"    from {{{{ ref('stg_health__{table.lower()}') }}}}{where}\n")


def fv(col, part):
    return (f"    first_value({col}) ignore nulls over (partition by {part} order by __PREC, __RID {WIN}) as {col}")


def build(branch_list, fv_list, key_cols):
    return stitch("\n    union all\n\n".join(branch_list), ",\n".join(fv_list), ",\n".join("    " + k for k in key_cols) + ",")


NULL = "cast(null as varchar)"
CK = "S__KIND_CK"


def test_class_a():
    t = build(
        [branch(0, "T1", ["pn as POLICY_BK", "x as S__V"])],
        [fv("S__V", "POLICY_BK")], ["POLICY_BK"])
    p = c.parse(t, "a.sql")
    plan = c.classify(p)
    s = p.sats[0]
    assert (s.klass, s.key.unique_key) == ("A", "policy_bk")
    assert c.branch_key_column(s, s.branches[0]) == "pn"          # verbatim
    assert plan.counts()["A"] == 1 and not plan.findings


def test_class_b_literal_split_and_verbatim_key():
    t = build(
        [branch(0, "T1", ["pn as POLICY_BK", "'AAA' as S__KIND_CK", "x as S__V"]),
         branch(1, "T2", ["pn as POLICY_BK", "'BBB' as S__KIND_CK", "y as S__V"], 1001),
         branch(2, "T3", ["pn as POLICY_BK", "'AAA' as S__KIND_CK", "z as S__V"], 1002)],
        [fv("S__V", f"POLICY_BK, {CK}")], ["POLICY_BK", CK])
    p = c.parse(t, "b.sql")
    plan = c.classify(p)
    s = p.sats[0]
    assert s.klass == "B" and s.key.unique_key == "policy_bk"
    assert c.literal_tuples(s) == [("AAA",), ("BBB",)]
    assert plan.counts()["B_parts"] == 2


def test_class_c_mixed_literal_and_data_driven_same_format():
    t = build(
        [branch(0, "T1", ["pn as POLICY_BK", "kind as S__KIND_CK", "x as S__V"]),
         branch(1, "T2", ["pn as POLICY_BK", "'GROUP' as S__KIND_CK", "y as S__V"], 1001)],
        [fv("S__V", f"POLICY_BK, {CK}")], ["POLICY_BK", CK])
    p = c.parse(t, "c.sql")
    c.classify(p)
    s = p.sats[0]
    assert s.klass == "C" and s.key.unique_key == "s_pk"
    k0, k1 = (c.branch_key_column(s, b) for b in s.branches)
    assert k0 == "pn || '|' || coalesce(kind, '~')"
    assert k1 == "pn || '|' || 'GROUP'"
    # same template: identical part order, separator and part targets
    shapes = {c.key_shape(c.branch_key_parts(s, b)) for b in s.branches}
    assert len(shapes) == 1


def test_class_c_composite_business_key():
    t = build(
        [branch(0, "T1", ["a as PARTY_BK", "b as POLICY_BK", "x as S__V"])],
        [fv("S__V", "PARTY_BK, POLICY_BK")], ["PARTY_BK", "POLICY_BK"])
    p = c.parse(t, "c2.sql")
    c.classify(p)
    s = p.sats[0]
    assert s.klass == "C"
    assert c.branch_key_column(s, s.branches[0]) == "a || '|' || b"


def test_render_key_column_rules():
    parts = [
        c.KeyPart("nullif(trim(x),'')", "policy_bk", False),
        c.KeyPart("kind", "s__kind_ck", True),
    ]
    assert c.render_key_column(parts) == "trim(to_varchar(nullif(trim(x),''))) || '|' || coalesce(kind, '~')"
    lit = [c.KeyPart("pn", "policy_bk", False), c.KeyPart("'it''s'", "s__kind_ck", True, literal="it's")]
    assert c.render_key_column(lit) == "pn || '|' || 'it''s'"
    assert c.render_key_column(parts[:1] , "^").startswith("trim(")
    with pytest.raises(ValueError):
        c.render_key_column(parts, "'")


def test_key_part_columns_are_raw_not_coalesced():
    parts = [c.KeyPart("pn", "policy_bk", False), c.KeyPart("kind", "s__kind_ck", True),
             c.KeyPart("'GROUP'", "s__x_ck", True, literal="GROUP")]
    assert c.key_part_columns(parts) == [
        {"src": "pn", "tgt": "policy_bk"},
        {"src": "kind", "tgt": "s__kind_ck"},
        {"src": "'GROUP'", "tgt": "s__x_ck"},
    ]


def test_link_key_required_plain_optional_coalesced():
    t = build(
        [branch(0, "T1", ["a as POLICY_BK", "b as COVERAGE_BK", "1 as __LNK_POLICY_COVERAGE", "x as S__V"]),
         branch(1, "T2", ["a as POLICY_BK", f"{NULL} as COVERAGE_BK", "1 as __LNK_POLICY_COVERAGE"], 1001)],
        [fv("S__V", "POLICY_BK")], ["POLICY_BK", "COVERAGE_BK", "__LNK_POLICY_COVERAGE"])
    p = c.parse(t, "l.sql")
    plan = c.classify(p, link_defs={"LNK_POLICY_COVERAGE": ["COVERAGE_BK", "POLICY_BK"]})
    (lk,) = plan.links
    assert lk.klass == "LINK" and lk.key.unique_key == "policy_coverage_lk"
    assert lk.legs == ["COVERAGE_BK", "POLICY_BK"] and lk.optional == ["COVERAGE_BK"]
    assert c.link_key_column(lk, lk.branches[0]) == "coalesce(b, '~') || '|' || a"
    assert c.link_key_column(lk, lk.branches[1]) == f"coalesce({c._norm(NULL)}, '~') || '|' || a"


def test_hub_only_key():
    t = build(
        [branch(0, "T1", ["a as POLICY_BK", f"{NULL} as PARTY_BK", "x as S__V"]),
         branch(1, "T2", [f"{NULL} as POLICY_BK", "p as PARTY_BK", f"{NULL} as S__V"], 1001)],
        [fv("S__V", "POLICY_BK")], ["POLICY_BK", "PARTY_BK"])
    plan = c.classify(c.parse(t, "h.sql"))
    assert [h.key_column for h in plan.hubs] == ["PARTY_BK"]
    assert plan.counts()["HUB"] == 1


def test_fallback_when_composite_business_key_part_missing():
    t = build(
        [branch(0, "T1", ["a as PARTY_BK", "b as POLICY_BK", "x as S__V"]),
         branch(1, "T2", ["a as PARTY_BK", f"{NULL} as POLICY_BK", "y as S__V"], 1001)],
        [fv("S__V", "PARTY_BK, POLICY_BK")], ["PARTY_BK", "POLICY_BK"])
    plan = c.classify(c.parse(t, "f.sql"))
    assert plan.sats[0].fallback and plan.counts()["FALLBACK"] == 1
    (f,) = plan.findings
    assert f.fallback and f.file == "f.sql" and f.branch == 1


def test_fallback_when_key_uses_window():
    t = build(
        [branch(0, "T1", ["max(a) over (partition by z) as POLICY_BK", "x as S__V"])],
        [fv("S__V", "POLICY_BK")], ["POLICY_BK"])
    plan = c.classify(c.parse(t, "w.sql"))
    assert plan.sats[0].fallback and plan.findings[0].fallback


def test_separator_profile_switches_for_whole_satellite():
    t = build(
        [branch(0, "T1", ["pn as POLICY_BK", "kind as S__KIND_CK", "x as S__V"]),
         branch(1, "T2", ["pn as POLICY_BK", "'G' as S__KIND_CK", "y as S__V"], 1001)],
        [fv("S__V", f"POLICY_BK, {CK}")], ["POLICY_BK", CK])
    p = c.parse(t, "p.sql")
    plan = c.classify(p, profile={"S": ["a|b", "c"]})
    s = p.sats[0]
    assert plan.separators == {"S": "^"}
    for b in s.branches:
        assert " || '^' || " in c.branch_key_column(s, b)
    # no usable separator -> fallback with a finding
    p2 = c.parse(t, "p.sql")
    plan2 = c.classify(p2, profile={"S": ["".join(c.SEPARATOR_CANDIDATES)]})
    assert plan2.sats[0].fallback and plan2.findings[0].fallback


# ---- all 34 originals
sys.path.insert(0, str(Path(__file__).resolve().parent))
from git_originals import ORIGINALS  # noqa: E402

ORIG = sorted(ORIGINALS.items())


@pytest.mark.skipif(len(ORIG) != 34, reason="34 original stitches not present")
def test_all_originals_classify_with_consistent_keys():
    total = {}
    for fname, text in ORIG:
        p = c.parse(text, fname)
        plan = c.classify(p)
        assert not [x for x in plan.findings if x.fallback], fname
        for k, v in plan.counts().items():
            total[k] = total.get(k, 0) + v
        for s in plan.sats:
            assert s.klass in ("A", "B", "C") and s.key.unique_key
            if s.klass == "C":
                shapes = {c.key_shape(c.branch_key_parts(s, b)) for b in s.branches
                          if c.branch_key_parts(s, b) is not None}
                assert len(shapes) <= 1, (fname, s.sat)
                keys = [c.branch_key_column(s, b) for b in s.branches]
                assert all(k is not None for k in keys), (fname, s.sat)
        for lk in plan.links:
            assert len({c.key_shape(c.link_branch_parts(lk, b)) for b in lk.branches}) == 1
    assert total["FALLBACK"] == 0
    assert total["A"] + total["B"] + total["C"] == sum(
        len(c.parse(text).sats) for _, text in ORIG)
