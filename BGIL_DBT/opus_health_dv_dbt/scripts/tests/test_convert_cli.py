"""Unit tests for the CLI modes and the conversion report (task 7.4).

Requirements 4.1, 4.8, 4.9, 4.10, 4.14, 4.17, 5.3, 5.4, 8.1.
"""
import json
import pathlib
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
sys.path.insert(0, str(Path(__file__).resolve().parent))
import convert_stitches as c  # noqa: E402
from test_convert_classify import CK, branch, build, fv  # noqa: E402

HEADER = "-- CENTRAL VIEW\n"


def class_a(table="T1"):
    return HEADER + build(
        [branch(0, table, ["pn as POLICY_BK", "x as S__V"])], [fv("S__V", "POLICY_BK")], ["POLICY_BK"])


def class_b():
    return HEADER + build(
        [branch(0, "T1", ["pn as POLICY_BK", "'AAA' as K__KIND_CK", "x as K__V"]),
         branch(1, "T2", ["pn as POLICY_BK", "'BBB' as K__KIND_CK", "y as K__V"], 1001)],
        [fv("K__V", "POLICY_BK, K__KIND_CK")], ["POLICY_BK", "K__KIND_CK"])


def make_dir(tmp_path, files):
    d = tmp_path / "stitched"
    d.mkdir()
    for name, text in files.items():
        (d / name).write_text(text, encoding="utf-8")
    return d


def snapshot(d):
    return {p.name: p.read_bytes() for p in sorted(Path(d).iterdir())}


def run(d, report, *flags):
    return c.main(["--stitches-dir", str(d), "--report", str(report), *flags])


# ----------------------------------------------------------------------------- --plan
def test_plan_writes_no_model_files_and_prints_counts(tmp_path, capsys):
    d = make_dir(tmp_path, {"stitch_v01_a.sql": class_a(), "stitch_v02_b.sql": class_b()})
    before = snapshot(d)
    report = tmp_path / "r.json"
    assert run(d, report, "--plan") == 0
    assert snapshot(d) == before                      # no model file written, none changed
    out = capsys.readouterr().out
    assert "stitch_v01_a.sql" in out and "TOTAL" in out
    assert "class B per-literal parts: 2" in out
    assert "class B volume (O3): 1 satellites -> 2 per-literal parts" in out
    assert "fallback stitches: 0" in out
    data = json.loads(report.read_text(encoding="utf-8"))
    assert data["mode"] == "plan"
    t = data["totals"]
    assert (t["A"], t["B"], t["B_parts"], t["C"], t["FALLBACK"]) == (1, 1, 2, 0, 0)
    assert t["parts"] == 3 and t["files_total"] == 5   # 1 + 2 parts, 2 consumer views


def test_plan_is_default_mode(tmp_path):
    d = make_dir(tmp_path, {"stitch_v01_a.sql": class_a()})
    before = snapshot(d)
    assert run(d, tmp_path / "r.json") == 0
    assert snapshot(d) == before


def test_force_requires_write(tmp_path):
    d = make_dir(tmp_path, {"stitch_v01_a.sql": class_a()})
    with pytest.raises(SystemExit):
        run(d, tmp_path / "r.json", "--plan", "--force")


# ----------------------------------------------------------------------------- --write
def test_write_without_force_never_overwrites(tmp_path):
    d = make_dir(tmp_path, {"stitch_v01_a.sql": class_a()})
    before = snapshot(d)
    assert run(d, tmp_path / "r.json", "--write") == 1     # the consumer view would overwrite the original
    assert snapshot(d) == before                           # and no part was written either
    data = json.loads((tmp_path / "r.json").read_text(encoding="utf-8"))
    assert data["write_results"][0]["status"] == "not_written"


def test_write_does_not_overwrite_an_existing_part_without_force(tmp_path):
    d = make_dir(tmp_path, {"stitch_v01_a.sql": class_a()})
    (d / "stitch_s.sql").write_text("keep me", encoding="utf-8")
    assert run(d, tmp_path / "r.json", "--write") == 1
    assert (d / "stitch_s.sql").read_text(encoding="utf-8") == "keep me"


def test_write_force_writes_parts_and_consumer_views(tmp_path):
    d = make_dir(tmp_path, {"stitch_v01_a.sql": class_a(), "stitch_v02_b.sql": class_b()})
    assert run(d, tmp_path / "r.json", "--write", "--force") == 0
    names = {p.name for p in d.iterdir()}
    assert {"stitch_s.sql", "stitch_k__aaa.sql", "stitch_k__bbb.sql"} <= names
    assert "stitch_incremental(" in (d / "stitch_s.sql").read_text(encoding="utf-8")
    view = (d / "stitch_v01_a.sql").read_text(encoding="utf-8")
    assert "-- Consumer view over parts: stitch_s" in view and "{{ ref('stitch_s') }}" in view
    assert not list(d.glob("*.tmp"))


def test_failing_stitch_writes_nothing_and_exit_is_nonzero(tmp_path):
    d = make_dir(tmp_path, {"stitch_v01_bad.sql": "select 1", "stitch_v02_b.sql": class_b()})
    assert run(d, tmp_path / "r.json", "--write", "--force") == 1
    names = {p.name for p in d.iterdir()}
    assert (d / "stitch_v01_bad.sql").read_text(encoding="utf-8") == "select 1"
    assert "stitch_k__aaa.sql" in names                      # the good stitch is still converted
    data = json.loads((tmp_path / "r.json").read_text(encoding="utf-8"))
    assert data["findings"][0]["file"] == "stitch_v01_bad.sql"


def test_render_error_leaves_no_partial_output(tmp_path, monkeypatch):
    d = make_dir(tmp_path, {"stitch_v01_a.sql": class_a(), "stitch_v02_b.sql": class_b()})
    real = c.render_parts

    def boom(p, plan):
        if p.file == "stitch_v02_b.sql":
            raise ValueError("boom")
        return real(p, plan)

    monkeypatch.setattr(c, "render_parts", boom)
    assert run(d, tmp_path / "r.json", "--write", "--force") == 1
    names = {p.name for p in d.iterdir()}
    assert "stitch_s.sql" in names
    assert not {"stitch_k__aaa.sql", "stitch_k__bbb.sql"} & names
    assert "with merged as" in (d / "stitch_v02_b.sql").read_text(encoding="utf-8")   # original intact


def test_io_error_rolls_the_stitch_back(tmp_path, monkeypatch):
    d = make_dir(tmp_path, {"stitch_v01_a.sql": class_a()})
    original = (d / "stitch_v01_a.sql").read_bytes()
    real = pathlib.Path.replace

    def flaky(self, target):
        if self.name.startswith("stitch_v01_a"):
            raise OSError("disk full")
        return real(self, target)

    monkeypatch.setattr(pathlib.Path, "replace", flaky)
    assert run(d, tmp_path / "r.json", "--write", "--force") == 1
    assert not (d / "stitch_s.sql").exists()                 # part written first, then rolled back
    assert (d / "stitch_v01_a.sql").read_bytes() == original


def test_already_converted_stitch_is_skipped_not_rewritten(tmp_path):
    d = make_dir(tmp_path, {"stitch_v01_a.sql": class_a()})
    assert run(d, tmp_path / "r.json", "--write", "--force") == 0
    converted = snapshot(d)
    assert run(d, tmp_path / "r.json", "--write", "--force") == 0
    assert snapshot(d) == converted


# ----------------------------------------------------------------------------- report
def test_report_sections(tmp_path):
    d = make_dir(tmp_path, {"stitch_v01_a.sql": class_a(), "stitch_v02_b.sql": class_b()})
    results = c.build_all(d, link_defs={})
    rep = c.build_report(results, d, stg_dir=tmp_path / "none", raw_vault_dir=tmp_path / "none")
    for key in ("multi_satellite", "class_c", "fallback_stitches", "literal_splits", "consumer_map",
                "watermark_precheck", "varchar_watermark_parts", "part_name_collisions", "findings", "stitches"):
        assert key in rep
    assert rep["literal_splits"] == [
        {"file": "stitch_v02_b.sql", "original": "K", "literal": ["AAA"], "part": "stitch_k__aaa"},
        {"file": "stitch_v02_b.sql", "original": "K", "literal": ["BBB"], "part": "stitch_k__bbb"},
    ]
    assert rep["stitches"]["stitch_v01_a.sql"]["satellites"][0]["class"] == "A"


def test_class_c_entry_has_file_branch_construct(tmp_path):
    text = HEADER + build(
        [branch(0, "T1", ["pn as POLICY_BK", "kind as S__KIND_CK", "x as S__V"])],
        [fv("S__V", f"POLICY_BK, {CK}")], ["POLICY_BK", CK])
    d = make_dir(tmp_path, {"stitch_v01_c.sql": text})
    rep = c.build_report(c.build_all(d, link_defs={}), d, stg_dir=tmp_path, raw_vault_dir=tmp_path)
    (e,) = rep["class_c"]
    assert e["file"] == "stitch_v01_c.sql" and e["branch"] == 0 and "data-driven child key" in e["construct"]
    sat = rep["stitches"]["stitch_v01_c.sql"]["satellites"][0]
    assert sat["key_template"] == "policy_bk || '|' || coalesce(s__kind_ck, '~')"


def test_multi_satellite_entry(tmp_path):
    text = HEADER + build(
        [branch(0, "T1", ["pn as POLICY_BK", "x as S__V", "y as R__V"])],
        [fv("S__V", "POLICY_BK"), fv("R__V", "POLICY_BK")], ["POLICY_BK"])
    d = make_dir(tmp_path, {"stitch_v01_m.sql": text})
    rep = c.build_report(c.build_all(d, link_defs={}), d, stg_dir=tmp_path, raw_vault_dir=tmp_path)
    assert rep["multi_satellite"] == [{"file": "stitch_v01_m.sql", "satellites": ["S", "R"]}]


def test_watermark_precheck_reads_final_stg_files(tmp_path):
    d = make_dir(tmp_path, {"stitch_v01_a.sql": class_a("T1"), "stitch_v02_b.sql": class_b()})
    stg = tmp_path / "stg"
    stg.mkdir()
    (stg / "stg_health__t1.sql").write_text(
        "select nullif(trim(to_varchar(\"INC_JOB_UPDATED_AT\")), '') as inc_job_updated_at from x", encoding="utf-8")
    (stg / "stg_health__t2.sql").write_text(
        "select \"INC_JOB_UPDATED_AT\"::timestamp_ntz as inc_job_updated_at from x", encoding="utf-8")
    # T3 is not present at all; a commented mention must not count
    (stg / "stg_health__t4.sql").write_text("-- as inc_job_updated_at\nselect 1 as a", encoding="utf-8")
    rep = c.build_report(c.build_all(d, link_defs={}), d, stg_dir=stg, raw_vault_dir=tmp_path)
    by_part = {x["part"]: x for x in rep["watermark_precheck"]}
    t1 = by_part["stitch_s"]["sources"][0]
    assert (t1["model"], t1["selects"], t1["type"]) == ("stg_health__t1", True, "varchar")
    t2 = by_part["stitch_k__bbb"]["sources"][0]
    assert (t2["selects"], t2["type"]) == (True, "timestamp_ntz")
    assert by_part["stitch_s"]["all_select_watermark"] is True
    assert [x["part"] for x in rep["varchar_watermark_parts"]] == ["stitch_s", "stitch_k__aaa"]   # both read T1
    assert c.stg_info("stg_health__t4", stg)["selects"] is False
    assert c.stg_info("stg_health__nope", stg)["file_found"] is False


def test_consumer_map(tmp_path):
    d = make_dir(tmp_path, {"stitch_v01_a.sql": class_a()})
    rv = tmp_path / "rv" / "standard" / "staging"
    rv.mkdir(parents=True)
    ok = ("{%- set yaml_metadata -%}\nsource_model: 'stitch_v01_a'\nderived_columns:\n"
          "  NK: \"case when S__V is not null then 'HUB|' || POLICY_BK end\"\n{%- endset -%}\n")
    bad = ok.replace("S__V is not null", "S__V is not null and S__MISSING is not null")
    other = "source_model: 'stitch_v01_a'\nderived_columns:\n  X: 'S__V'\n  Y: 'R__V'\n"
    gone = "source_model: 'stitch_v77_none'\n"
    (rv / "stg2_ok.sql").write_text(ok, encoding="utf-8")
    (rv / "stg2_bad.sql").write_text(bad, encoding="utf-8")
    (rv / "stg2_gone.sql").write_text(gone, encoding="utf-8")
    (rv / "stg2_note.sql").write_text("-- source_model: 'stitch_v01_a'\nselect 1", encoding="utf-8")
    cm = c.consumer_map(c.build_all(d, link_defs={}), tmp_path / "rv")
    by = {e["stage"]: e for e in cm}
    assert by["stg2_ok.sql"]["columns_used"] == ["S__V", "POLICY_BK"]
    assert by["stg2_ok.sql"]["columns_provided"] == ["POLICY_BK", "S__V"]
    assert by["stg2_ok.sql"]["missing"] == [] and by["stg2_ok.sql"]["single_satellite"] is True
    assert by["stg2_gone.sql"]["resolved"] is False
    assert "stg2_note.sql" not in by or by["stg2_note.sql"]["source_model"] == "stitch_v01_a"


def test_consumer_map_flags_multi_satellite_and_missing_columns(tmp_path):
    text = HEADER + build(
        [branch(0, "T1", ["pn as POLICY_BK", "x as S__V", "y as R__V"])],
        [fv("S__V", "POLICY_BK"), fv("R__V", "POLICY_BK")], ["POLICY_BK"])
    d = make_dir(tmp_path, {"stitch_v01_m.sql": text})
    rv = tmp_path / "rv" / "staging"
    rv.mkdir(parents=True)
    (rv / "stg2_multi.sql").write_text(
        "source_model: 'stitch_v01_m'\nderived_columns:\n  X: 'S__V'\n  Y: 'R__V'\n", encoding="utf-8")
    results = c.build_all(d, link_defs={})
    (e,) = c.consumer_map(results, tmp_path / "rv")
    assert e["single_satellite"] is False and e["satellite_prefixes"] == ["R", "S"]
    rep = c.build_report(results, d, stg_dir=tmp_path, raw_vault_dir=tmp_path / "rv")
    assert any("several satellites" in f["construct"] for f in rep["findings"])


def test_part_name_collisions_across_stitches(tmp_path):
    # two stitches feeding the same satellite name produce the same part name
    d = make_dir(tmp_path, {"stitch_v01_a.sql": class_a("T1"), "stitch_v02_a.sql": class_a("T2")})
    results = c.build_all(d, link_defs={})
    (col,) = c.collisions(results, d)
    assert col["part"] == "stitch_s" and col["stitches"] == ["stitch_v01_a.sql", "stitch_v02_a.sql"]
    assert col["identical_content"] is False
    # write: the second stitch conflicts and is not written, exit non-zero
    assert run(d, tmp_path / "r.json", "--write", "--force") == 1
    assert "-- Consumer view over parts" in (d / "stitch_v01_a.sql").read_text(encoding="utf-8")
    assert "with merged as" in (d / "stitch_v02_a.sql").read_text(encoding="utf-8")


def test_no_collisions_for_distinct_parts(tmp_path):
    d = make_dir(tmp_path, {"stitch_v01_a.sql": class_a(), "stitch_v02_b.sql": class_b()})
    assert c.collisions(c.build_all(d, link_defs={}), d) == []
