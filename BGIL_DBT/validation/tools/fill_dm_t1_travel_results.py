#!/usr/bin/env python3
"""
Write DM-T1 travel results (statement 2 of the DM-T1_<PROJECT>*_SUMMARY.sql
runs, exported as CSV) into DM-T1_<PROJECT>.docx:

  * each section block: "Result (Pass / Fail / NA)", "Rows with status = FAIL
    (count)" and "Remarks"
  * the "Results summary" table: Result and Failing rows columns

    python3 BGIL_DBT/validation/tools/fill_dm_t1_travel_results.py OPUS  <csv>
    python3 BGIL_DBT/validation/tools/fill_dm_t1_travel_results.py MAXIMUS <csv> <csv> <csv>

Rules
  * Result and failing rows are copied exactly as the query returned them.
  * Sections left out of the summary query (build_dm_t1_travel_summary.SKIP)
    are recorded as Fail, "Not run: <reason>".
  * Section 1 (summary): taken from the CSV if present (OPUS file computes
    it); otherwise derived from all other sections -- Fail if any failed,
    failing rows = number of failed tables.
  * Remarks: failed satellites get the remark recorded for that satellite in
    DM-R1 / DM-A1 / DM-A2 (no label; distinct remarks joined with "; ").
    Everything else gets its non-zero counts, or "0 rows in scope ...".
Idempotent: re-running overwrites the same cells.
"""
import csv
import re
import shutil
import sys
import zipfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
TRAVEL = HERE.parent / "travel"
sys.path.insert(0, str(HERE))
from fill_dm_t2_travel_results import H2, TEXT, TR, TC, LABELS, set_cell, fill_section  # noqa: E402
from build_dm_t1_travel_summary import SKIP  # noqa: E402

METRICS = ["NULL_LOAD_DATETIME", "NULL_RECORD_SOURCE", "NULL_DBT_RUN_TS",
           "PLACEHOLDER_LOAD_DATETIME", "FUTURE_LOAD_DATETIME", "LOAD_AFTER_RUN_TS",
           "UNEXPECTED_RECORD_SOURCE"]
SAT = re.compile(r"\b(SAT_[A-Z0-9_]+)")
REVIEWS = [("DM-R", "DM-R1"), ("DM-A", "DM-A1"), ("DM-A", "DM-A2")]


def text(xml):
    return re.sub(r"\s+", " ", "".join(TEXT.findall(xml))).strip()


def split_sections(xml, project=None):
    heads = []
    for m in H2.finditer(xml):
        t = text(m.group(0))
        mm = re.match(r"^(\d+)\.\s+(\w+)\s+\u2014", t)
        if mm and (project is None or mm.group(2) == project):
            heads.append((int(mm.group(1)), m.start(), t))
    return [(n, s, heads[i + 1][1] if i + 1 < len(heads) else len(xml), t)
            for i, (n, s, t) in enumerate(heads)]


def kv(chunk):
    out = {}
    for tr in TR.findall(chunk):
        cells = TC.findall(tr)
        if len(cells) == 2:
            out[text(cells[0])] = text(cells[1])
    return out


def review_remarks(project):
    """{SAT_NAME: 'remark; remark'} from DM-R1 / DM-A1 / DM-A2."""
    found = {}
    for folder, label in REVIEWS:
        path = TRAVEL / folder / f"{label}_{project}.docx"
        if not path.exists():
            continue
        xml = zipfile.ZipFile(path).read("word/document.xml").decode()
        for _, s, e, head in split_sections(xml):
            m = SAT.search(head)
            rem = kv(xml[s:e]).get("Remarks", "")
            if m and rem:
                found.setdefault(m.group(1), []).append(rem.rstrip())
    out = {}
    for sat, rems in found.items():
        seen, keep = set(), []
        for r in rems:
            k = r.rstrip(". ").lower()
            if k not in seen:
                seen.add(k)
                keep.append(r)
        out[sat] = "; ".join(keep)
    return out


def counts_remark(r):
    if r["ROWS_IN_SCOPE"] == "0":
        return ("0 rows in scope for this project's travel RECORD_SOURCE values "
                "(old and LOB-scoped prefix); nothing to check.")
    parts = [f"rows_in_scope={r['ROWS_IN_SCOPE']}"]
    parts += [f"{c.lower()}={r[c]}" for c in METRICS if r[c] != ""]
    return "; ".join(parts)


def main():
    project, csvs = sys.argv[1].upper(), [Path(p) for p in sys.argv[2:]]
    docx = TRAVEL / "DM-T" / f"DM-T1_{project}.docx"
    rows = {}
    for p in csvs:
        for r in csv.DictReader(open(p, newline="")):
            n = int(r["SECTION_NO"])
            assert n not in rows, f"section {n} appears twice"
            rows[n] = r
    reasons = review_remarks(project)

    out = {}  # section -> (result, failing, remarks)
    for n, r in rows.items():
        if r["TABLE_TYPE"] == "summary":
            continue
        sat = SAT.search(r["SECTION_OBJECT"])
        rem = counts_remark(r)
        if r["RESULT"] == "Fail" and sat and sat.group(1) in reasons:
            rem = reasons[sat.group(1)]
        out[n] = (r["RESULT"], r["FAILING_ROWS"], rem)
    for n, why in SKIP.get(project, {}).items():
        if n not in out:
            obj = SAT.search(why)
            rem = reasons.get(obj.group(1)) if obj else None
            out[n] = ("Fail", "", rem or f"Not run: {why}.")
    if 1 in rows:
        s = rows[1]
        out[1] = (s["RESULT"], s["FAILING_ROWS"], s["REMARKS"])
    else:
        failed = sum(1 for v in out.values() if v[0] == "Fail")
        out[1] = ("Fail" if failed else "Pass", str(failed),
                  f"tables checked={len(out)}; failed={failed}")

    with zipfile.ZipFile(docx) as z:
        xml = z.read("word/document.xml").decode()
    secs = split_sections(xml, project)
    nums = [n for n, *_ in secs]
    assert nums == list(range(1, len(nums) + 1)), "docx numbering has gaps"
    assert set(out) == set(nums), (f"sections without a result: {sorted(set(nums) - set(out))}; "
                                   f"results for unknown sections: {sorted(set(out) - set(nums))}")
    parts, cur = [], 0
    for n, s, e, _ in secs:
        parts.append(xml[cur:s])
        parts.append(fill_section(xml[s:e], dict(zip(LABELS, out[n]))))
        cur = e
    parts.append(xml[cur:])
    xml = "".join(parts)

    m = re.search(r"Results summary</w:t></w:r></w:p>\s*(<w:tbl\b.*?</w:tbl>)", xml, re.S)
    tbl = m.group(1)
    hdr = [text(c) for c in TC.findall(TR.findall(tbl)[0])]
    assert hdr[4:6] == ["Result", "Failing rows"], f"unexpected summary header {hdr}"

    def fix(rm):
        row = rm.group(0)
        first = text(TC.findall(row)[0])
        if not first.isdigit() or int(first) not in out:
            return row
        res, fail, _ = out[int(first)]
        for idx, val in ((5, fail), (4, res)):
            c = list(TC.finditer(row))[idx]
            row = row[:c.start()] + set_cell(c.group(0), val) + row[c.end():]
        return row
    xml = xml[:m.start(1)] + TR.sub(fix, tbl) + xml[m.end(1):]

    tmp = docx.with_suffix(".docx.tmp")
    with zipfile.ZipFile(docx) as zin, zipfile.ZipFile(tmp, "w", zipfile.ZIP_DEFLATED) as zout:
        for item in zin.infolist():
            data = xml.encode() if item.filename == "word/document.xml" else zin.read(item.filename)
            zout.writestr(item, data)
    shutil.move(tmp, docx)
    tally = {}
    for res, _, _ in out.values():
        tally[res] = tally.get(res, 0) + 1
    with_reason = sum(1 for n, (res, _, rem) in out.items()
                      if res == "Fail" and not rem.startswith(("0 rows", "Not run", "tables")))
    print(f"{docx.name}: {len(out)} sections -> {tally}; failed sections with a DM-R/DM-A remark: {with_reason}")


if __name__ == "__main__":
    main()
