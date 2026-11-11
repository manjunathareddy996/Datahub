"""Feature: opus-health-dv-dbt-runnable, Property 7: Output columns equal the satellite payload plus key parts.

For any macro part, `output_columns` equals the payload columns the original branches fill for that
satellite (for class B parts, including the child key column), together with the Key_Part_Columns of
its key, with no extras or omissions; the keys of `coalesce_rules` equal `output_columns`; and
`unique_key` is not among the output columns.

**Validates: Requirements 4.4, 4.9**
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

CK = "S__KIND_CK"
PAYLOAD = ["S__V1", "S__V2", "S__V3"]
SRC_EXPRS = ["c1", "c2", "upper(z)", "nvl(q, 'N')"]
KEY_EXPRS = ["pn", "pm", "trim(x)"]

settings.register_profile("p07", max_examples=150, deadline=None,
                          suppress_health_check=list(HealthCheck))


def read_list(text: str, name: str) -> list[str]:
    body = text.split("{%- set " + name + " = [", 1)[1].split("\n] -%}", 1)[0]
    return ast.literal_eval("[" + body + "\n]")


def read_rules(text: str) -> dict:
    body = text.split("{%- set coalesce_rules = {", 1)[1].split("\n} %}", 1)[0]
    return ast.literal_eval("{" + body + "\n}")


def read_unique_key(text: str) -> str:
    return re.search(r"unique_key='([^']*)'|unique_key=\"([^\"]*)\"", text).group(0).split("=", 1)[1].strip("'\"")


def check_part(m):
    out = read_list(m.text, "output_columns")
    assert out == m.output_columns
    assert len(out) == len(set(out)), out                    # no duplicates
    assert list(read_rules(m.text)) == out, m.text           # coalesce keys == output columns
    assert read_unique_key(m.text) == m.unique_key
    assert m.unique_key not in out, (m.unique_key, out)
    return out


@st.composite
def sat_specs(draw):
    mode = draw(st.sampled_from("ABC"))
    n = draw(st.integers(1, 5))
    specs = []
    for i in range(n):
        filled = draw(st.lists(st.sampled_from(PAYLOAD), min_size=1, unique=True))
        spec = {"i": i, "key": draw(st.sampled_from(KEY_EXPRS)),
                "pay": {col: draw(st.sampled_from(SRC_EXPRS)) for col in filled}, "ck": None}
        if mode == "B":
            spec["ck"] = "'" + draw(st.sampled_from(["AAA", "BBB", "CCC"])) + "'"
        elif mode == "C":
            spec["ck"] = draw(st.sampled_from(["kind", "kd2", "'GRP'"]))
        specs.append(spec)
    if mode == "C" and all(s["ck"].startswith("'") for s in specs):
        specs[0]["ck"] = "kind"
    return mode, specs


@settings(settings.get_profile("p07"))
@given(sat_specs())
def test_sat_output_columns_are_payload_plus_key_parts(case):
    """Feature: opus-health-dv-dbt-runnable, Property 7: Output columns equal the satellite payload plus key parts."""
    mode, specs = case
    branches = []
    for s in specs:
        items = [f"{s['key']} as POLICY_BK"]
        if mode != "A":
            items.append(f"{s['ck']} as {CK}")
        items += [f"{s['pay'][col]} as {col}" if col in s["pay"] else f"{NULL} as {col}" for col in PAYLOAD]
        branches.append(branch(s["i"], f"T{s['i']}", items, 1000 + s["i"]))
    part = "POLICY_BK" if mode == "A" else f"POLICY_BK, {CK}"
    keys = ["POLICY_BK"] + ([] if mode == "A" else [CK])
    p = c.parse(build(branches, [fv(col, part) for col in PAYLOAD], keys), "stitch_v99_demo.sql")
    plan = c.classify(p)
    parts = [m for m in c.render_parts(p, plan) if m.kind in "ABC"]
    assert parts
    for m in parts:
        out = check_part(m)
        if mode == "B":
            lit = m.name.rsplit("__", 1)[1]
            contributing = [s for s in specs if c._slug(s["ck"][1:-1]) == lit]
            expected = {col.lower() for s in contributing for col in s["pay"]} | {CK.lower()}
        elif mode == "C":
            expected = {col.lower() for s in specs for col in s["pay"]} | {"policy_bk", CK.lower()}
        else:
            expected = {col.lower() for s in specs for col in s["pay"]}
        assert set(out) == expected, (mode, out, expected)


@settings(settings.get_profile("p07"))
@given(st.lists(st.tuples(st.sampled_from(KEY_EXPRS), st.sampled_from(["cv", "nvl(cv, 'z')", None]),
                          st.sampled_from(SRC_EXPRS)), min_size=2, max_size=5))
def test_link_output_columns_are_key_parts(rows):
    """Feature: opus-health-dv-dbt-runnable, Property 7 (link parts): output columns are the legs."""
    rows = [(rows[0][0], "cv", rows[0][2])] + rows[1:]          # first branch always fills both legs
    branches = []
    for i, (pk, cov, val) in enumerate(rows):
        cov_expr = cov if cov is not None else NULL
        items = [f"{pk} as POLICY_BK", f"{cov_expr} as COVERAGE_BK", "1 as __LNK_POLICY_COVERAGE", f"{val} as S__V"]
        branches.append(branch(i, f"T{i}", items))
    keys = ["POLICY_BK", "COVERAGE_BK", "__LNK_POLICY_COVERAGE"]
    p = c.parse(build(branches, [fv("S__V", "POLICY_BK")], keys), "stitch_v99_demo.sql")
    plan = c.classify(p, link_defs={"LNK_POLICY_COVERAGE": ["COVERAGE_BK", "POLICY_BK"]})
    parts = c.render_parts(p, plan)
    (lk,) = [m for m in parts if m.kind == "LINK"]
    out = check_part(lk)
    assert set(out) == {"policy_bk", "coverage_bk"}
    for m in parts:
        if m.kind in "ABC":
            out = check_part(m)
            assert set(out) == {"s__v"}
