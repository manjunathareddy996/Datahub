"""Feature: opus-health-dv-dbt-runnable, Property 8: Coalesce order follows source precedence.

For any satellite and any output column, the aliases in `coalesce_rules[column]` are ordered by
nondecreasing original `__PREC` of their branches, with ties ordered by branch number, and contain
only aliases whose branch fills that column.

**Validates: Requirements 4.5**
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
CK = "S__KIND_CK"
PAYLOAD = ["S__V1", "S__V2", "S__V3"]
SRC_EXPRS = ["c1", "c2", "upper(z)", "nvl(q, 'N')", "w"]

settings.register_profile("p08", max_examples=150, deadline=None,
                          suppress_health_check=list(HealthCheck))


def section(text: str, name: str, closer: str) -> str:
    return text.split("{%- set " + name + " = ", 1)[1].split(closer, 1)[0]


def parse_sources(text: str) -> list[dict]:
    return ast.literal_eval(section(text, "sources", "\n] -%}") + "\n]")


def parse_rules(text: str) -> dict[str, list[str]]:
    body = section(text, "coalesce_rules", "\n} %}")
    return ast.literal_eval(body + "\n}")


@st.composite
def branch_specs(draw, mode):
    n = draw(st.integers(1, 6))
    specs = []
    for i in range(n):
        filled = draw(st.lists(st.sampled_from(PAYLOAD), min_size=1, unique=True))
        specs.append({
            "i": i,
            "table": f"T{i}",
            "key": draw(st.sampled_from(["pn", "pm", "po"])),
            "pay": {col: draw(st.sampled_from(SRC_EXPRS)) for col in filled},
            "prec": draw(st.integers(1000, 1003)),      # narrow range forces ties
            "ck": "kind" if mode == "C" else None,
        })
    return specs


def build_text(specs, mode):
    branches = []
    for s in specs:
        items = [f"{s['key']} as POLICY_BK"]
        if mode == "C":
            items.append(f"{s['ck']} as {CK}")
        items += [f"{s['pay'][col]} as {col}" if col in s["pay"] else f"{NULL} as {col}" for col in PAYLOAD]
        branches.append(branch(s["i"], s["table"], items, s["prec"]))
    part = "POLICY_BK" if mode == "A" else f"POLICY_BK, {CK}"
    keys = ["POLICY_BK"] + ([CK] if mode == "C" else [])
    return HEADER + build(branches, [fv(col, part) for col in PAYLOAD], keys)


@settings(settings.get_profile("p08"))
@given(st.sampled_from(["A", "C"]).flatmap(lambda m: st.tuples(st.just(m), branch_specs(m))))
def test_coalesce_rules_follow_precedence(case):
    """Feature: opus-health-dv-dbt-runnable, Property 8: Coalesce order follows source precedence."""
    mode, specs = case
    p = c.parse(build_text(specs, mode), "stitch_v99_demo.sql")
    plan = c.classify(p)
    parts = c.render_parts(p, plan)
    assert parts
    by_model = {f"stg_health__{s['table'].lower()}": s for s in specs}
    for m in parts:
        srcs = parse_sources(m.text)
        rules = parse_rules(m.text)
        alias_spec = {s["alias"]: by_model[s["model"]] for s in srcs}
        alias_cols = {s["alias"]: {x["tgt"] for x in s["columns"]} for s in srcs}
        for col, aliases in rules.items():
            # only aliases whose branch fills the column, and every such alias is present
            assert set(aliases) == {a for a, cols in alias_cols.items() if col in cols}, (col, aliases)
            assert len(aliases) == len(set(aliases))
            # nondecreasing __PREC, ties by branch number
            keys = [(alias_spec[a]["prec"], alias_spec[a]["i"]) for a in aliases]
            assert keys == sorted(keys), (col, aliases, keys)
            # payload columns are filled only by branches that carry them in the original
            if col.upper() in PAYLOAD:
                assert all(col.upper() in alias_spec[a]["pay"] for a in aliases)
