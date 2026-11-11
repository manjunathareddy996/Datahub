"""Property 19: Unusable models are untouched and counts add up.

For any set of staging models and raw column evidence, every model with an unparseable
select list or with evidence that its table lacks the column is returned byte-identical
and appears in the report with a reason, and changed + already + skipped equals the
number of models.

**Validates: Requirements 7.5, 7.7**
"""
import json
import sys
import tempfile
from pathlib import Path

from hypothesis import given, settings, strategies as st

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from add_inc_job_updated_at import Evidence, edit_stg, main  # noqa: E402

col_names = st.sampled_from(["ALPHA", "BETA", "GAMMA", "ZETA", "CASE_ID", "AMOUNT"])
KINDS = ["good", "already", "no_select", "bad_item", "no_from", "two_selects"]


def build(kind, table, cols, nl):
    items = [f'        "{c}" as {c.lower()},' for c in cols]
    head = ["with src as (", "    select"]
    frm = [f"    from {{{{ source('opus', '{table}') }}}}", ")", "select * from src"]
    if kind == "already":
        items = items + ['        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at,']
    if kind == "good":
        lines = head + items + frm
    elif kind == "already":
        lines = head + items + frm
    elif kind == "no_select":
        lines = ["with src as (", "    select a, b"] + frm
    elif kind == "bad_item":
        lines = head + items + ["        upper(x),"] + frm
    elif kind == "no_from":
        lines = head + items + [")"]
    else:
        lines = head + items + ["    select"] + items + frm
    return nl.join(lines) + nl


model_spec = st.fixed_dictionaries({
    "kind": st.sampled_from(KINDS),
    "cols": st.lists(col_names, min_size=1, max_size=4, unique=True),
    "nl": st.sampled_from(["\n", "\r\n"]),
    "raw": st.sampled_from(["has", "lacks", "missing"]),
})


@settings(max_examples=100, deadline=None)
@given(specs=st.lists(model_spec, min_size=1, max_size=8), use_evidence=st.booleans())
def test_skips_untouched_and_counts_add_up(specs, use_evidence):
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        stg = root / "stg"
        stg.mkdir()
        raw_cols = {}
        originals = {}
        expect_untouched = set()
        for i, s in enumerate(specs):
            table = f"TBL{i}"
            name = f"stg_health__tbl{i}"
            text = build(s["kind"], table, s["cols"], s["nl"])
            (stg / f"{name}.sql").write_bytes(text.encode("utf-8"))
            originals[name] = text.encode("utf-8")
            if s["raw"] == "has":
                raw_cols[table] = set(s["cols"]) | {"INC_JOB_UPDATED_AT"}
            elif s["raw"] == "lacks":
                raw_cols[table] = set(s["cols"])
            unparsable = s["kind"] not in ("good", "already")
            no_raw = use_evidence and s["raw"] != "has"
            if s["kind"] == "already" or unparsable or (s["kind"] == "good" and no_raw):
                expect_untouched.add(name)

            # unit-level: edit_stg
            ev = Evidence(raw_cols if use_evidence else None)
        # edit_stg level, per model, with the final evidence
        ev = Evidence(raw_cols if use_evidence else None)
        for i, s in enumerate(specs):
            name = f"stg_health__tbl{i}"
            out, res = edit_stg(originals[name].decode("utf-8"), ev)
            if name in expect_untouched:
                assert out.encode("utf-8") == originals[name]
            if s["kind"] not in ("good", "already"):
                assert res.status == "skipped" and res.reason == "unparsable"
            elif s["kind"] == "good" and use_evidence and s["raw"] != "has":
                assert res.status == "skipped" and res.reason

        # CLI level with --write
        args = ["--write", "--stg-dir", str(stg), "--report", str(root / "report.json")]
        if use_evidence:
            csv_path = root / "raw.csv"
            rows = ["TABLE_NAME,COLUMN_NAME"] + [f"{t},{c}" for t, cs in raw_cols.items() for c in sorted(cs)]
            csv_path.write_text("\n".join(rows) + "\n", encoding="utf-8")
            args += ["--raw-columns", str(csv_path)]
        assert main(args) == 0
        report = json.loads((root / "report.json").read_text(encoding="utf-8"))

        c = report["counts"]
        assert c["changed"] + c["already"] + c["skipped"] == len(specs)
        skipped = {e["model"]: e["reason"] for e in report["skipped"]}
        for name in expect_untouched:
            assert (stg / f"{name}.sql").read_bytes() == originals[name]
        for name in skipped:
            assert skipped[name]
            assert (stg / f"{name}.sql").read_bytes() == originals[name]
        for i, s in enumerate(specs):
            name = f"stg_health__tbl{i}"
            if s["kind"] not in ("good", "already"):
                assert name in skipped
            elif s["kind"] == "good" and use_evidence and s["raw"] != "has":
                assert name in skipped
