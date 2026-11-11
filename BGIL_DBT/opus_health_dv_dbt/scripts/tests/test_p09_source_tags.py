"""Feature: opus-health-dv-dbt-runnable, Property 9: Source tags follow the system-prefix form.

For any generated source entry, `source_tag` equals `OPUS_` followed by the upper-case table name
from the original branch comment, matches `^OPUS_[A-Z0-9_]+$`, and all tags in one part share the
prefix `OPUS`.

**Validates: Requirements 4.7**
"""
import ast
import re
import sys
from pathlib import Path

from hypothesis import HealthCheck, given, settings, strategies as st

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
sys.path.insert(0, str(Path(__file__).resolve().parent))
import convert_stitches as c  # noqa: E402
from test_convert_classify import NULL, branch, build, fv  # noqa: E402

HEADER = "-- CENTRAL VIEW v99\n-- Tables merged:\n--   T0\n"
TAG_RE = re.compile(r"^OPUS_[A-Z0-9_]+$")
CK = "S__KIND_CK"

settings.register_profile("p09", max_examples=150, deadline=None,
                          suppress_health_check=list(HealthCheck))

# Table names: mixed case words joined by single underscores (as in the branch comments).
word = st.text(alphabet="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789", min_size=1, max_size=8)
table_name = st.lists(word, min_size=1, max_size=4).map("_".join).filter(lambda s: s[0].isalpha())
tables = st.lists(table_name, min_size=1, max_size=5, unique_by=str.lower)


def parse_sources(text: str) -> list[dict]:
    body = text.split("{%- set sources = ", 1)[1].split("\n] -%}", 1)[0] + "\n]"
    return ast.literal_eval(body)


def check_parts(p, plan, tabs):
    parts = [m for m in c.render_parts(p, plan) if "{%- set sources = " in m.text]
    assert parts
    expected = {f"stg_health__{t.lower()}": f"OPUS_{t.upper()}" for t in tabs}
    for m in parts:
        srcs = parse_sources(m.text)
        assert srcs
        prefixes = set()
        for s in srcs:
            tag = s["source_tag"]
            assert tag == expected[s["model"]], (tag, s["model"])
            assert TAG_RE.match(tag), tag
            prefixes.add(tag.split("_", 1)[0])
        assert prefixes == {"OPUS"}


@settings(settings.get_profile("p09"))
@given(st.sampled_from(["A", "B", "C"]), tables)
def test_satellite_source_tags(mode, tabs):
    """Feature: opus-health-dv-dbt-runnable, Property 9: Source tags follow the system-prefix form."""
    branches = []
    for i, t in enumerate(tabs):
        items = ["pn as POLICY_BK"]
        if mode == "B":
            items.append("'AAA' as " + CK)
        elif mode == "C":
            items.append("kind as " + CK)
        items.append("x as S__V")
        branches.append(branch(i, t.upper(), items, 1000 + i))
    part = "POLICY_BK" if mode == "A" else f"POLICY_BK, {CK}"
    keys = ["POLICY_BK"] + ([] if mode == "A" else [CK])
    p = c.parse(HEADER + build(branches, [fv("S__V", part)], keys), "stitch_v99_demo.sql")
    plan = c.classify(p)
    assert plan.sats and plan.sats[0].klass == mode
    check_parts(p, plan, tabs)


@settings(settings.get_profile("p09"))
@given(tables)
def test_link_source_tags(tabs):
    """Feature: opus-health-dv-dbt-runnable, Property 9 (link parts)."""
    branches = [branch(i, t.upper(), ["a as POLICY_BK", "b as COVERAGE_BK",
                                      "1 as __LNK_POLICY_COVERAGE", "x as S__V"], 1000 + i)
                for i, t in enumerate(tabs)]
    keys = ["POLICY_BK", "COVERAGE_BK", "__LNK_POLICY_COVERAGE"]
    p = c.parse(HEADER + build(branches, [fv("S__V", "POLICY_BK")], keys), "stitch_v99_demo.sql")
    plan = c.classify(p, link_defs={"LNK_POLICY_COVERAGE": ["COVERAGE_BK", "POLICY_BK"]})
    assert plan.links
    check_parts(p, plan, tabs)
