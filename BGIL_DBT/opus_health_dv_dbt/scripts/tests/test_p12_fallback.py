"""Property 12: Fallback_Stitch is a verbatim last resort.

For any original stitch, a Fallback_Stitch exists for a satellite if and only if the converter recorded
a finding (file name, branch number, construct) for that satellite; its text equals the original SQL
without edits; and the conversion report lists it as a last resort. A stitch with no fallback finding
has no Fallback_Stitch.

**Validates: Requirements 4.14, 4.15, 4.20**
"""
import sys
import tempfile
from pathlib import Path

from hypothesis import given, settings, strategies as st

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
sys.path.insert(0, str(Path(__file__).resolve().parent))
import convert_stitches as c  # noqa: E402
from test_convert_classify import branch, build, fv  # noqa: E402

HEADER = "-- CENTRAL VIEW vXX\n-- Tables merged:\n--   T1\n"
FILE = "stitch_v07_demo.sql"
LINK_DEFS: dict = {}


@st.composite
def stitches(draw):
    """Return (text, bad_sats): a stitch of 1..3 satellites, each good (class A) or bad (finding)."""
    n_sats = draw(st.integers(1, 3))
    branches, fvs, key_cols = [], [], []
    bad_sats: dict[str, str] = {}   # sat -> kind of defect
    idx = 0
    for s in range(1, n_sats + 1):
        sat = f"S{s}"
        defect = draw(st.sampled_from(["none", "none", "missing_part", "window"]))
        pay = [f"{sat}__V{i}" for i in range(draw(st.integers(1, 3)))]
        n_br = draw(st.integers(1, 3)) if defect == "none" else draw(st.integers(2, 3))
        for j in range(n_br):
            if defect == "none":
                items = [f"pn{idx} as {sat}_BK"]
            elif defect == "missing_part":
                items = [f"pt{idx} as {sat}A_BK"] + ([f"pn{idx} as {sat}B_BK"] if j == 0 else [])
            else:  # window / aggregate in a key expression
                items = [f"max(pn{idx}) as {sat}A_BK", f"pn{idx} as {sat}B_BK"] if j == 0 else \
                        [f"pt{idx} as {sat}A_BK", f"pn{idx} as {sat}B_BK"]
            items += [f"v{idx}_{i} as {p}" for i, p in enumerate(pay)]
            branches.append(branch(idx, f"T{idx}", items, 1000 + idx))
            idx += 1
        if defect == "none":
            fvs += [fv(p, f"{sat}_BK") for p in pay]
            key_cols.append(f"{sat}_BK")
        else:
            fvs += [fv(p, f"{sat}A_BK, {sat}B_BK") for p in pay]
            key_cols += [f"{sat}A_BK", f"{sat}B_BK"]
            bad_sats[sat] = defect
    return HEADER + build(branches, fvs, key_cols), bad_sats


@settings(max_examples=150, deadline=None)
@given(stitches())
def test_fallback_is_verbatim_and_only_after_finding(case):
    text, bad_sats = case
    with tempfile.TemporaryDirectory() as d:
        path = Path(d) / FILE
        path.write_text(text, encoding="utf-8")
        r = c.build_stitch(path, link_defs=LINK_DEFS)
        original = path.read_text(encoding="utf-8")
    assert r.status == "ok", r.error
    plan = r.plan
    fb_findings = [f for f in plan.findings if f.fallback]

    # the satellites that fell back are exactly the defective ones, each with a recorded finding
    assert {s.sat for s in plan.sats if s.fallback} == set(bad_sats)
    fell_back = [s for s in plan.sats if s.fallback]
    for s in fell_back:
        mine = [f for f in fb_findings if f.construct.startswith(f"{s.sat}:")]
        assert mine, f"fallback satellite {s.sat} has no recorded finding"
        for f in mine:   # finding carries file name, branch number and construct
            assert f.file == FILE and isinstance(f.branch, int) and f.construct

    # iff: a Fallback_Stitch exists exactly when some fallback finding was recorded
    assert (r.fallback is not None) == bool(fb_findings) == bool(bad_sats)
    fb_files = [n for n in r.files() if n.startswith("stitch_fb_")]

    report = c.build_report([r], out_dir=None, stg_dir=Path(tempfile.gettempdir()) / "_no_stg_",
                            raw_vault_dir=Path(tempfile.gettempdir()) / "_no_rv_")
    entry = report["stitches"][FILE]
    if not bad_sats:
        assert fb_files == []
        assert entry["fallback"] is None
        assert report["fallback_stitches"] == []
        assert "stitch_fb_" not in r.view
        assert plan.counts()["FALLBACK"] == 0
        return

    fb = r.fallback
    # verbatim: byte-for-byte the original SQL, under the helper name
    assert fb.kind == "FALLBACK"
    assert fb.text == text == original
    assert fb.name == "stitch_fb_v07_demo" == c.fallback_name(FILE)
    assert fb_files == [fb.name + ".sql"]
    assert r.files()[fb.name + ".sql"] == original

    # unioned into the consumer view (or the view is the original when nothing else remains)
    if r.parts:
        assert f"ref('{fb.name}')" in r.view
    else:
        assert r.view == original

    # listed in the report as a last resort with file, branch and construct
    assert entry["fallback"] == fb.name
    assert entry["counts"]["FALLBACK"] == len(fell_back)
    listed = report["fallback_stitches"]
    assert len(listed) == len(fb_findings) > 0
    for item in listed:
        assert item["file"] == FILE and isinstance(item["branch"], int) and item["construct"]
        assert item["fallback"] is True
    assert {(i["branch"], i["construct"]) for i in listed} == {(f.branch, f.construct) for f in fb_findings}
    assert report["totals"]["FALLBACK"] == len(fell_back)
