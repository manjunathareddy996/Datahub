"""Property 14: Findings are complete.

Feature: opus-health-dv-dbt-runnable, Property 14.
**Validates: Requirements 4.14, 4.15, 4.20, 5.4**
"""
import sys
import tempfile
from pathlib import Path

from hypothesis import HealthCheck, given, settings, strategies as st

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
sys.path.insert(0, str(Path(__file__).resolve().parent))
import convert_stitches as c  # noqa: E402
from test_convert_classify import branch, build, fv  # noqa: E402

HEADER = "-- CENTRAL VIEW\n-- Tables merged:\n--   T1\n"


@st.composite
def one_stitch(draw):
    """(text, kinds, literals per class B satellite)."""
    n = draw(st.integers(1, 4))
    kinds = [draw(st.sampled_from(["A", "B", "C", "FB"])) for _ in range(n)]
    branches, fvs, keys = [], [], ["POLICY_BK"]
    lits_by_sat, idx = {}, 0

    def add(items):
        nonlocal idx
        branches.append(branch(idx, f"T{idx}", items, 1000 + idx))
        idx += 1

    for i, kind in enumerate(kinds):
        v, ck = f"SAT{i}__V", f"SAT{i}__KIND_CK"
        if kind == "A":
            for _ in range(draw(st.integers(1, 2))):
                add([f"pn{idx} as POLICY_BK", f"x{idx} as {v}"])
            fvs.append(fv(v, "POLICY_BK"))
        elif kind == "B":
            lits = draw(st.lists(st.sampled_from(["AAA", "BBB", "CCC", "DDD"]), min_size=1, max_size=4))
            for lit in lits:
                add([f"pn{idx} as POLICY_BK", f"'{lit}' as {ck}", f"x{idx} as {v}"])
            fvs.append(fv(v, f"POLICY_BK, {ck}"))
            keys.append(ck)
            lits_by_sat[f"SAT{i}"] = set(lits)
        elif kind == "C":
            for _ in range(draw(st.integers(1, 2))):
                add([f"pn{idx} as POLICY_BK", f"k{idx} as {ck}", f"x{idx} as {v}"])
            fvs.append(fv(v, f"POLICY_BK, {ck}"))
            keys.append(ck)
        else:  # FB: composite business key, one branch lacks PARTY_BK -> no consistent key
            add([f"pn{idx} as POLICY_BK", f"pt{idx} as PARTY_BK", f"x{idx} as {v}"])
            add([f"pn{idx} as POLICY_BK", f"x{idx} as {v}"])
            fvs.append(fv(v, "POLICY_BK, PARTY_BK"))
            if "PARTY_BK" not in keys:
                keys.append("PARTY_BK")
    return HEADER + build(branches, fvs, keys), kinds, lits_by_sat


@st.composite
def cases(draw):
    stitches = draw(st.lists(one_stitch(), min_size=1, max_size=3))
    consumers = draw(st.lists(st.sampled_from(["one", "two", "unknown"]), max_size=3))
    return stitches, consumers


@settings(max_examples=120, deadline=None, suppress_health_check=[HealthCheck.too_slow])
@given(cases())
def test_findings_are_complete(case):
    stitches, consumers = case
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        sdir, rv = root / "stitched", root / "raw_vault"
        sdir.mkdir()
        (rv / "x" / "staging").mkdir(parents=True)
        expected = {}
        for n, (text, kinds, lits) in enumerate(stitches, 1):
            name = f"stitch_v{n:02d}_demo.sql"
            (sdir / name).write_text(text, encoding="utf-8", newline="\n")
            expected[name] = (kinds, lits)
        for j, kind in enumerate(consumers):
            src = "stitch_v99_missing" if kind == "unknown" else "stitch_v01_demo"
            cols = "SAT0__V" + (", SAT1__V" if kind == "two" else "")
            (rv / "x" / "staging" / f"stg_c{j}.sql").write_text(
                f"{{%- set yaml_metadata -%}}\nsource_model: '{src}'\nderived_columns:\n"
                f"  A: '{cols}'\n{{%- endset -%}}\n", encoding="utf-8")

        results = c.build_all(sdir, link_defs={})
        report = c.build_report(results, sdir, root / "stg", rv)

        for r in results:
            assert r.status == "ok", (r.file, r.error)
        for name, (kinds, lits) in expected.items():
            # multi-satellite entry iff the stitch feeds more than one satellite
            multi = [m for m in report["multi_satellite"] if m["file"] == name]
            assert bool(multi) == (len(kinds) > 1)
            if multi:
                assert len(multi) == 1
                assert multi[0]["satellites"] == [f"SAT{i}" for i in range(len(kinds))]

            # class C: one entry per class C satellite with file, branch and construct
            want_c = {f"SAT{i}" for i, k in enumerate(kinds) if k in ("C", "FB")}
            got_c = [e for e in report["class_c"] if e["file"] == name]
            assert {e["satellite"] for e in got_c} == want_c
            assert len(got_c) == len(want_c)
            for e in got_c:
                assert isinstance(e["branch"], int) and e["construct"]

            # literal splits: original name, part name and each literal
            got = [e for e in report["literal_splits"] if e["file"] == name]
            assert {e["original"] for e in got} == set(lits)
            for s, ls in lits.items():
                mine = [e for e in got if e["original"] == s]
                assert {tuple(e["literal"]) for e in mine} == {(x,) for x in ls}
                assert len({e["part"] for e in mine}) == len(ls)
                assert all(e["part"].startswith(f"stitch_{s.lower()}__") for e in mine)

            # fallback: one entry (file, branch, construct) per satellite without a consistent key
            fb = [e for e in report["fallback_stitches"] if e["file"] == name]
            assert len(fb) == sum(1 for k in kinds if k == "FB")
            for e in fb:
                assert isinstance(e["branch"], int) and e["construct"] and e["fallback"]
                assert e in report["findings"]
            assert (report["stitches"][name]["fallback"] is not None) == bool(fb)

        # consumer map issues become findings
        cm = report["consumer_map"]
        assert len(cm) == len(consumers)
        n_v01 = len(expected["stitch_v01_demo.sql"][0])
        for e in cm:
            kind = consumers[int(e["stage"][len("stg_c"):-len(".sql")])]
            assert e["resolved"] == (kind != "unknown")
            if e["resolved"]:
                assert e["single_satellite"] == (kind == "one" or n_v01 == 1)
        found = {(f["file"], f["construct"]) for f in report["findings"]}
        for e in cm:
            if not e["resolved"]:
                assert (e["path"], f"source_model {e['source_model']} has no consumer view") in found
                continue
            for col in e["missing"]:
                assert (e["path"], f"column {col} used but not provided by {e['source_model']}") in found
            multi_used = not e["single_satellite"]
            has = any(f == e["path"] and "several satellites" in t for f, t in found)
            assert has == multi_used
