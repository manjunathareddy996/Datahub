"""Property 2: Macro parts have the required structure.

For any generated macro part, the text contains exactly one `config(materialized='view')`, one
`sources` list, one `output_columns` list, one `coalesce_rules` map, and exactly one
`stitch_incremental(` call whose arguments are `sources`, `output_columns`, `coalesce_rules`,
`unique_key` and `target_sat`.

**Validates: Requirements 4.2**
"""
import re
import sys
from pathlib import Path

from hypothesis import given, settings, strategies as st

sys.path.insert(0, str(Path(__file__).resolve().parent))
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
import convert_stitches as c  # noqa: E402
from test_convert_classify import NULL, build, branch, fv  # noqa: E402

LINK_DEFS = {"LNK_POLICY_COVERAGE": ["COVERAGE_BK", "POLICY_BK"]}
EXPECTED_ARGS = ["sources", "output_columns", "coalesce_rules", "unique_key", "target_sat"]


@st.composite
def stitches(draw):
    """A synthetic original stitch: 1-3 satellites (kinds A/B/C), 1-4 branches, optional link."""
    n_branch = draw(st.integers(1, 4))
    kinds = draw(st.lists(st.sampled_from("ABC"), min_size=1, max_size=3))
    with_link = draw(st.booleans())
    sat_names = [f"S{i}" for i in range(len(kinds))]
    items = [[] for _ in range(n_branch)]
    fvs, key_cols = [], ["POLICY_BK"]
    for i in range(n_branch):
        items[i].append(f"pn{i} as POLICY_BK")
    for name, kind in zip(sat_names, kinds):
        payload = f"{name}__V"
        ck = f"{name}__KIND_CK"
        for i in range(n_branch):
            items[i].append(f"x{i} as {payload}")
            if kind == "B":
                items[i].append(f"'{draw(st.sampled_from(['AAA', 'BBB']))}' as {ck}")
            elif kind == "C":
                if i == 0:
                    items[i].append(f"kind{i} as {ck}")
                else:
                    items[i].append(draw(st.sampled_from([f"kind{i}", "'GROUP'"])) + f" as {ck}")
        part = "POLICY_BK" if kind == "A" else f"POLICY_BK, {ck}"
        fvs.append(fv(payload, part))
        if kind != "A":
            key_cols.append(ck)
    if with_link:
        key_cols += ["COVERAGE_BK", "__LNK_POLICY_COVERAGE"]
        for i in range(n_branch):
            items[i].append(f"cv{i} as COVERAGE_BK" if i == 0 else f"{NULL} as COVERAGE_BK")
            items[i].append("1 as __LNK_POLICY_COVERAGE")
    branches = [branch(i, f"T{i}", items[i], 1000 + i) for i in range(n_branch)]
    return build(branches, fvs, key_cols)


def _args(text: str) -> list[str]:
    m = re.search(r"stitch_incremental\(\s*(.*?)\n\) \}\}", text, re.S)
    assert m, text
    return [a.split("=")[0].strip() for a in m.group(1).split(",\n")]


@settings(max_examples=150, deadline=None)
@given(stitches())
def test_macro_part_structure(sql):
    p = c.parse(sql, "stitch_v01_x.sql")
    plan = c.classify(p, link_defs=LINK_DEFS)
    parts = c.render_parts(p, plan)
    assert parts, "generator must yield at least one part"
    for part in parts:
        t = part.text
        assert len(re.findall(r"config\(materialized='view'\)", t)) == 1, t
        assert len(re.findall(r"\{%-?\s*set sources\s*=\s*\[", t)) == 1, t
        assert len(re.findall(r"\{%-?\s*set output_columns\s*=\s*\[", t)) == 1, t
        assert len(re.findall(r"\{%-?\s*set coalesce_rules\s*=\s*\{", t)) == 1, t
        assert t.count("stitch_incremental(") == 1, t
        assert _args(t) == EXPECTED_ARGS, t
