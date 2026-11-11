"""Unit tests for add_inc_job_updated_at.edit_stg (task 9.1). Requirements 7.1-7.5, 7.7."""
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
import add_inc_job_updated_at as a  # noqa: E402

BODY = [
    "-- header",
    "with source as (",
    "",
    "    select",
    "        nullif(trim(to_varchar(\"A_COL\")), '') as a_col,",
    "        nullif(trim(to_varchar(\"Z_COL\")), '') as z_col",
    "    from {{ source('health_raw', 'T1') }}",
    "",
    ")",
    "",
    "select * from source",
    "",
]
NEW = '        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at,'


def mk(nl="\n", lines=BODY):
    return nl.join(lines)


def test_inserts_before_first_greater_column():
    src = mk()
    out, r = a.edit_stg(src, None)
    assert r.status == "changed" and r.unverified
    ol = out.split("\n")
    assert ol[5] == NEW and ol[6].endswith("as z_col")
    assert "\n".join(ol[:5] + ol[6:]) == src  # pure one-line insertion


def test_anchor_is_last_when_none_sorts_after():
    lines = [ln.replace('"Z_COL"', '"B_COL"') for ln in BODY]
    out, _ = a.edit_stg(mk(lines=lines), None)
    ol = out.split("\n")
    assert ol[5] == NEW and "B_COL" in ol[6]


def test_already_ignores_comments_only():
    src = mk()
    assert a.edit_stg(src.replace("-- header", "-- x as inc_job_updated_at"), None)[1].status == "changed"
    has = src.replace("as z_col", "as z_col,\n        x as INC_JOB_UPDATED_AT")
    out, r = a.edit_stg(has, None)
    assert r.status == "already" and out == has


def test_crlf_and_bom_preserved():
    src = "\ufeff" + mk("\r\n")
    out, r = a.edit_stg(src, None)
    assert r.status == "changed" and out.startswith("\ufeff")
    assert out.count("\r\n") == src.count("\r\n") + 1 and out.count("\n") == out.count("\r\n")


def test_unparsable_cases():
    multi = mk(lines=BODY[:5] + ["        coalesce(", '"Z"), 1) as z_col'] + BODY[6:])
    assert a.edit_stg(multi, None)[1].reason == "unparsable"
    two_from = mk() + "\nfrom {{ source('h', 'T2') }}\n"
    assert a.edit_stg(two_from, None)[1].reason == "unparsable"
    assert a.edit_stg("select 1", None)[1].reason == "unparsable"


def test_raw_columns_evidence():
    ev = a.Evidence({"T1": {"A_COL"}})
    out, r = a.edit_stg(mk(), ev)
    assert r.status == "skipped" and r.reason == "no usable raw column" and out == mk()
    ev = a.Evidence({"T1": {"A_COL", "INC_JOB_UPDATED_AT"}})
    assert a.edit_stg(mk(), ev)[1].unverified is False


def test_z_prefix_table_uses_regexp_form():
    out, _ = a.edit_stg(mk(), a.Evidence(None, frozenset({"T1"})))
    assert "regexp_replace" in out


def test_cli_plan_writes_nothing(tmp_path):
    f = tmp_path / "stg_health__t1.sql"
    f.write_bytes(mk().encode())
    rep = tmp_path / "r.json"
    assert a.main(["--stg-dir", str(tmp_path), "--report", str(rep)]) == 0
    assert f.read_bytes() == mk().encode() and rep.exists()
    a.main(["--stg-dir", str(tmp_path), "--write"])
    assert b"inc_job_updated_at" in f.read_bytes()
