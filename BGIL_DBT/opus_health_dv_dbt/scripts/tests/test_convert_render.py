"""Unit tests for the renderers (task 7.3): macro parts, consumer view, Fallback_Stitch.

Requirements 4.2-4.7, 4.9-4.13, 4.15, 4.16.
"""
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
sys.path.insert(0, str(Path(__file__).resolve().parent))
import convert_stitches as c  # noqa: E402
from test_convert_classify import NULL, branch, build, fv  # noqa: E402

HEADER = "-- CENTRAL VIEW vXX\n-- Tables merged:\n--   T1\n"


def prep(branches, fvs, keys, defs=None):
    t = build(branches, fvs, keys)
    t = HEADER + t
    p = c.parse(t, "stitch_v99_demo.sql")
    plan = c.classify(p, link_defs=defs or {})
    return t, p, plan


def test_class_a_part_shape_and_precedence():
    t, p, plan = prep(
        [branch(0, "T1", ["pn as POLICY_BK", "x as S__V"], 1001),
         branch(1, "T2", ["pm as POLICY_BK", "y as S__V"], 1000),
         branch(2, "T3", ["po as POLICY_BK", "z as S__V"], 1000)],
        [fv("S__V", "POLICY_BK")], ["POLICY_BK"])
    (m,) = c.render_parts(p, plan)
    assert m.name == "stitch_s" and m.kind == "A"
    s = m.text
    assert s.startswith("{{ config(materialized='view') }}\n")
    assert "-- CENTRAL VIEW vXX" in s                       # header preserved
    assert "-- depends_on: {{ ref('stg_health__t1') }}" in s
    assert "'key_column': 'pn'" in s                        # verbatim
    assert "'ldts_column': 'inc_job_updated_at'" in s
    assert "'source_tag': 'OPUS_T1'" in s
    assert "{'src': 'x', 'tgt': 's__v'}" in s
    assert "'s__v': ['t1', 't2', 't0']" in s                # __PREC then branch number
    assert "unique_key='policy_bk'" in s and "target_sat='s'" in s.replace("sat_s", "s")
    assert "target_sat='sat_s'" in s
    # Skill whitespace: last set closes with plain %}, call ends with }}, no wrapping WITH
    assert "} %}\n\n{{ stitch_incremental(" in s
    assert s.rstrip().endswith(") }}")
    assert "with merged" not in s.lower() and s.count("stitch_incremental(") == 1
    assert m.provides == {"POLICY_BK": "policy_bk", "S__V": "s__v"}


def test_class_b_one_part_per_literal():
    t, p, plan = prep(
        [branch(0, "T1", ["pn as POLICY_BK", "'A' as S__KIND_CK", "x as S__V"]),
         branch(1, "T2", ["pn as POLICY_BK", "'B' as S__KIND_CK", "y as S__V"])],
        [fv("S__V", "POLICY_BK, S__KIND_CK")], ["POLICY_BK", "S__KIND_CK"])
    parts = c.render_parts(p, plan)
    assert [m.name for m in parts] == ["stitch_s__a", "stitch_s__b"]
    assert "{'src': \"'A'\", 'tgt': 's__kind_ck'}" in parts[0].text
    assert "OPUS_T2" not in parts[0].text and "OPUS_T2" in parts[1].text
    assert parts[0].provides["S__KIND_CK"] == "s__kind_ck"


def test_class_c_mixed_literal_and_data_driven():
    t, p, plan = prep(
        [branch(0, "T1", ["pn as POLICY_BK", "ck1 as S__KIND_CK", "x as S__V"], 1001),
         branch(1, "T2", ["pn as POLICY_BK", "'LIT' as S__KIND_CK", "y as S__V"], 1000)],
        [fv("S__V", "POLICY_BK, S__KIND_CK")], ["POLICY_BK", "S__KIND_CK"])
    (m,) = c.render_parts(p, plan)
    assert m.kind == "C" and m.name == "stitch_s"
    assert "unique_key='s_pk'" in m.text
    assert "\"pn || '|' || coalesce(ck1, '~')\"" in m.text
    assert "\"pn || '|' || 'LIT'\"" in m.text
    assert "{'src': 'ck1', 'tgt': 's__kind_ck'}" in m.text     # raw, not coalesced
    assert "{'src': \"'LIT'\", 'tgt': 's__kind_ck'}" in m.text
    assert m.output_columns == ["policy_bk", "s__kind_ck", "s__v"]
    assert "'s__v': ['t1', 't0']" in m.text
    assert m.provides["POLICY_BK"] == "policy_bk"


def test_link_part_and_view_padding_and_marker():
    t, p, plan = prep(
        [branch(0, "T1", ["a as POLICY_BK", "b as COVERAGE_BK", "1 as __LNK_POLICY_COVERAGE", "x as S__V"]),
         branch(1, "T2", ["a as POLICY_BK", f"{NULL} as COVERAGE_BK", "1 as __LNK_POLICY_COVERAGE"], 1001)],
        [fv("S__V", "POLICY_BK")], ["POLICY_BK", "COVERAGE_BK", "__LNK_POLICY_COVERAGE"],
        {"LNK_POLICY_COVERAGE": ["COVERAGE_BK", "POLICY_BK"]})
    parts = c.render_parts(p, plan)
    lk = next(m for m in parts if m.kind == "LINK")
    assert lk.name == "stitch_lk_policy_coverage__v99"
    assert "unique_key='policy_coverage_lk'" in lk.text
    assert "target_sat='lnk_policy_coverage'" in lk.text
    assert "\"coalesce(b, '~') || '|' || a\"" in lk.text      # optional leg coalesced, required plain
    assert "{'src': 'b', 'tgt': 'coverage_bk'}" in lk.text
    v = c.render_view(p, parts)
    assert v.count("union all") == len(parts) - 1
    assert "cast(null as varchar) as S__V" in v               # link block pads the payload
    assert "1 as __LNK_POLICY_COVERAGE" in v and "cast(null as int) as __LNK_POLICY_COVERAGE" in v
    assert "from {{ ref('stitch_lk_policy_coverage__v99') }}" in v
    assert "-- CENTRAL VIEW vXX" in v


def test_view_column_order_matches_original():
    t, p, plan = prep(
        [branch(0, "T1", ["pn as POLICY_BK", "x as S__V"])], [fv("S__V", "POLICY_BK")], ["POLICY_BK"])
    v = c.render_view(p, c.render_parts(p, plan))
    cols = [l.strip().rsplit(" as ", 1)[1].rstrip(",") for l in v.splitlines() if " as " in l]
    assert cols == p.columns


def test_fallback_is_verbatim_and_unioned():
    t, p, plan = prep(
        [branch(0, "T1", ["pn as POLICY_BK", "x as S__V"])], [fv("S__V", "POLICY_BK")], ["POLICY_BK"])
    fb = c.fallback_stitch(t, "stitch_v99_demo.sql")
    assert fb.name == "stitch_fb_v99_demo" and fb.text == t and fb.kind == "FALLBACK"
    v = c.render_view(p, [], fb, ["S__V"], t)
    assert v == t                                           # every satellite fell back
    parts = c.render_parts(p, plan)
    v2 = c.render_view(p, parts, fb, ["S__V"], t)
    assert "ref('stitch_fb_v99_demo')" in v2 and "union all" in v2


def test_pystr_quoting():
    assert c._pystr("a") == "'a'"
    assert c._pystr("a || '|'") == '"a || \'|\'"'
    assert c._pystr("a\nb") == "'a b'"


from git_originals import ORIGINALS  # noqa: E402

REAL_NAME = "stitch_v22_policy.sql"


@pytest.mark.skipif(REAL_NAME not in ORIGINALS, reason="original stitch not available from git HEAD")
def test_real_stitch_in_memory():
    t = ORIGINALS[REAL_NAME]
    p = c.parse(t, REAL_NAME)
    plan = c.classify(p)
    parts = c.render_parts(p, plan)
    pc = next(m for m in parts if m.name == "stitch_policy_classification")
    assert pc.kind == "C" and "unique_key='policy_classification_pk'" in pc.text
    assert pc.text.count("'ldts_column': 'inc_job_updated_at'") == pc.text.count("'source_tag': 'OPUS_")
    v = c.render_view(p, parts)
    assert [l.strip().rsplit(" as ", 1)[1].rstrip(",") for l in v.split("union all")[0].splitlines()
            if " as " in l] == p.columns
    assert "__PREC" not in v and "first_value" not in v
