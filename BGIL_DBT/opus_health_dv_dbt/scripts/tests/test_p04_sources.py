"""Feature: opus-health-dv-dbt-runnable, Property 4: Sources reproduce the original branches.

For any satellite and its macro part, parsing the part's `sources` back yields, for each
contributing branch, the same `ref` model and the same `{src, tgt}` payload column pairs as the
original branch, plus the Key_Part_Columns; the `key_column` of a class A or B source equals the
original key expression; and class B parts contain only branches with their literal.

**Validates: Requirements 4.3**
"""
import ast
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

KEY_EXPRS = ["pn", "pm", "po", "trim(x)", "nullif(a, '')", "upper(k)"]
SRC_EXPRS = ["c1", "c2", "upper(z)", "nvl(q, 'N')", "to_date(d)", "w"]

settings.register_profile("p04", max_examples=150, deadline=None,
                          suppress_health_check=list(HealthCheck))


def parse_sources(text: str) -> list[dict]:
    """Read the `sources` list back from a rendered part (Jinja list syntax == Python literal)."""
    body = text.split("{%- set sources = ", 1)[1].split("\n] -%}", 1)[0] + "\n]"
    return ast.literal_eval(body)


@st.composite
def branch_specs(draw, mode):
    n = draw(st.integers(1, 5))
    specs = []
    for i in range(n):
        filled = draw(st.lists(st.sampled_from(PAYLOAD), min_size=1, unique=True))
        spec = {
            "i": i,
            "table": f"T{i}",
            "key": draw(st.sampled_from(KEY_EXPRS)),
            "pay": {col: draw(st.sampled_from(SRC_EXPRS)) for col in filled},
            "prec": draw(st.integers(1000, 1003)),
            "ck": None,
        }
        if mode == "B":
            spec["ck"] = "'" + draw(st.sampled_from(["AAA", "BBB", "CCC"])) + "'"
        elif mode == "C":
            spec["ck"] = draw(st.sampled_from(["kind", "kd2", "'GRP'", "'XYZ'"]))
        specs.append(spec)
    if mode == "C" and all(s["ck"].startswith("'") for s in specs):
        specs[0]["ck"] = "kind"          # at least one data-driven branch
    return specs


def build_text(specs, mode):
    branches = []
    for s in specs:
        items = [f"{s['key']} as POLICY_BK"]
        if mode != "A":
            items.append(f"{s['ck']} as {CK}")
        items += [f"{s['pay'][col]} as {col}" if col in s["pay"] else f"{NULL} as {col}" for col in PAYLOAD]
        branches.append(branch(s["i"], s["table"], items, s["prec"]))
    part = "POLICY_BK" if mode == "A" else f"POLICY_BK, {CK}"
    fvs = [fv(col, part) for col in PAYLOAD]
    keys = ["POLICY_BK"] + ([] if mode == "A" else [CK])
    return HEADER + build(branches, fvs, keys)


def model_of(spec):
    return f"stg_health__{spec['table'].lower()}"


def expected_pairs(sat, spec, klass, lit=None):
    pay = [{"src": spec["pay"][col], "tgt": col.lower()} for col in sat.payload if col in spec["pay"]]
    if klass == "A":
        return pay
    if klass == "B":
        return pay + [{"src": spec["ck"], "tgt": CK.lower()}]
    return [{"src": spec["key"], "tgt": "policy_bk"}, {"src": spec["ck"], "tgt": CK.lower()}] + pay


def check_sat(p, plan, specs):
    parts = c.render_parts(p, plan)
    by_model = {model_of(s): s for s in specs}
    for sat in plan.sats:
        assert not sat.fallback
        sat_parts = [m for m in parts if m.owner == sat.sat]
        assert sat_parts, sat.sat
        for m in sat_parts:
            srcs = parse_sources(m.text)
            assert srcs
            seen = []
            for src in srcs:
                spec = by_model[src["model"]]            # same ref model as an original branch
                seen.append(src["model"])
                # payload pairs + Key_Part_Columns (class B: the literal child key column)
                assert src["columns"] == expected_pairs(sat, spec, sat.klass), (sat.klass, src)
                if sat.klass in ("A", "B"):
                    assert src["key_column"] == spec["key"]              # verbatim original key
                else:
                    k = spec["key"] if spec["key"].isidentifier() else f"trim(to_varchar({spec['key']}))"
                    assert src["key_column"] == f"{k} || '|' || " + (
                        f"coalesce({spec['ck']}, '~')" if not spec["ck"].startswith("'") else spec["ck"])
            assert len(seen) == len(set(seen))
            expected_models = [model_of(s) for s in specs
                               if (sat.klass != "B" or m.name == "stitch_" + sat.sat.lower() + "__"
                                   + c._slug(s["ck"][1:-1]))]
            assert sorted(seen) == sorted(expected_models), (m.name, seen, expected_models)
        if sat.klass == "B":
            lits = {s["ck"][1:-1] for s in specs}
            assert len(sat_parts) == len(lits)
        else:
            assert len(sat_parts) == 1


@settings(settings.get_profile("p04"))
@given(st.sampled_from(["A", "B", "C"]).flatmap(lambda m: st.tuples(st.just(m), branch_specs(m))))
def test_sat_sources_reproduce_original_branches(case):
    """Feature: opus-health-dv-dbt-runnable, Property 4: Sources reproduce the original branches."""
    mode, specs = case
    p = c.parse(build_text(specs, mode), "stitch_v99_demo.sql")
    plan = c.classify(p)
    assert all(s.klass == mode or (mode == "B" and s.klass == "B") or (mode == "C" and s.klass == "C")
               for s in plan.sats)
    check_sat(p, plan, specs)


@settings(settings.get_profile("p04"))
@given(st.lists(st.tuples(st.sampled_from(KEY_EXPRS), st.sampled_from(["cv", "nvl(cv, 'z')", None]),
                          st.sampled_from(SRC_EXPRS)), min_size=2, max_size=5),
       st.booleans())
def test_link_sources_reproduce_original_branches(rows, with_null_leg):
    """Feature: opus-health-dv-dbt-runnable, Property 4 (link parts): legs reproduce original branches."""
    branches = []
    for i, (pk, cov, val) in enumerate(rows):
        cov_expr = cov if cov is not None else NULL
        items = [f"{pk} as POLICY_BK", f"{cov_expr} as COVERAGE_BK", "1 as __LNK_POLICY_COVERAGE",
                 f"{val} as S__V"]
        branches.append(branch(i, f"T{i}", items))
    if with_null_leg:
        branches.append(branch(len(rows), f"T{len(rows)}",
                               ["pk2 as POLICY_BK", f"{NULL} as COVERAGE_BK", "1 as __LNK_POLICY_COVERAGE"]))
    keys = ["POLICY_BK", "COVERAGE_BK", "__LNK_POLICY_COVERAGE"]
    text = HEADER + build(branches, [fv("S__V", "POLICY_BK")], keys)
    p = c.parse(text, "stitch_v99_demo.sql")
    plan = c.classify(p, link_defs={"LNK_POLICY_COVERAGE": ["COVERAGE_BK", "POLICY_BK"]})
    parts = c.render_parts(p, plan)
    (lk_part,) = [m for m in parts if m.kind == "LINK"]
    assert lk_part.name == "stitch_lk_policy_coverage__v99"
    (lk,) = plan.links
    srcs = parse_sources(lk_part.text)
    models = [s["model"] for s in srcs]
    assert models == [f"stg_health__t{b.index}" for b in lk.branches if any(x in b.keys for x in lk.legs)]
    by_idx = {b.model: b for b in lk.branches}
    for s in srcs:
        b = by_idx[s["model"]]
        assert s["key_column"] == c.link_key_column(lk, b)
        assert s["columns"] == c.key_part_columns(c.link_branch_parts(lk, b))
        # every leg the original branch fills is reproduced with its original expression
        for leg in lk.legs:
            col = next(x for x in s["columns"] if x["tgt"] == leg.lower())
            assert col["src"] == b.keys.get(leg, "cast(null as varchar)")
