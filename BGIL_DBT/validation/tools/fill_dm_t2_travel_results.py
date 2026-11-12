#!/usr/bin/env python3
"""
Write DM-T2 travel results (statement 2 of a DM-T2_<PROJECT>_*_SUMMARY.sql run,
exported as CSV) into DM-T2_<PROJECT>.docx:

  * each section block: "Result (Pass / Fail / NA)", "Rows with status = FAIL
    (count)" and "Remarks"
  * the "Results summary" table: Result and Failing rows columns

    python3 BGIL_DBT/validation/tools/fill_dm_t2_travel_results.py OPUS \
        BGIL_DBT/validation/travel/DM-T/results/DM-T2_OPUS_SUMMARY_2026-11-12.csv

Result and failing rows are written exactly as the query returned them
(Pass / Fail). Remarks carry the counts, plus the known reason for these
Fail patterns: section 1 (BINARY reported without length), 0 rows in scope,
and hubs whose recompute fails on 100% of rows (query formula mismatch).
Idempotent: re-running overwrites the same cells.
"""
import csv
import re
import shutil
import sys
import zipfile
from pathlib import Path
from xml.sax.saxutils import escape

HERE = Path(__file__).resolve().parent
DMT = HERE.parent / "travel" / "DM-T"

LABELS = ("Result (Pass / Fail / NA)", "Rows with status = FAIL (count)", "Remarks")
H2 = re.compile(r'<w:p\b[^>]*>\s*<w:pPr>\s*<w:pStyle w:val="Heading2"\s*/>.*?</w:p>', re.S)
TEXT = re.compile(r"<w:t[^>]*>([^<]*)</w:t>")
TR = re.compile(r"<w:tr\b.*?</w:tr>", re.S)
TC = re.compile(r"<w:tc\b.*?</w:tc>", re.S)
PARA = re.compile(r"<w:p\b.*?</w:p>|<w:p/>", re.S)


def num(v):
    return int(v) if v not in (None, "") else None


def verdict(r):
    """Result and failing rows are copied from the query as-is (Pass / Fail).
    Remarks give the counts and, for known causes, the reason for a Fail."""
    no, kind = int(r["SECTION_NO"]), r["TABLE_TYPE"]
    rows = num(r["ROWS_IN_SCOPE"])
    result, failing = r["RESULT"], r["FAILING_ROWS"]
    if no == 1:
        listed = re.findall(r"\b([A-Z0-9_]+\.[A-Z0-9_]+) (\w+)", r["REMARKS"])
        all_binary = (listed and all(t == "BINARY" for _, t in listed)) or \
            "reported as data_type BINARY" in r["REMARKS"]  # condensed export
        if all_binary:
            flagged = len(listed) if listed else failing
            return result, failing, (
                f"columns checked={rows}; flagged={flagged}. Every flagged column is BINARY: "
                "Snowflake INFORMATION_SCHEMA.COLUMNS reports no length for BINARY, so the "
                "16-byte test cannot pass here. Byte length is checked per table by "
                "wrong_length_hkey.")
        return result, failing, r["REMARKS"]
    if kind != "columns" and rows == 0:
        return result, failing, ("0 rows in scope for this project's travel RECORD_SOURCE "
                                 "values (old and LOB-scoped prefix); nothing to check.")
    parts = [f"rows_in_scope={r['ROWS_IN_SCOPE']}"]
    for c in ("NULL_HKEY", "NULL_FK_HKEYS", "WRONG_LENGTH_HKEY", "HKEY_NOT_RECOMPUTABLE",
              "COLLISIONS", "NULL_HASHDIFF"):
        if r[c] != "":
            parts.append(f"{c.lower()}={r[c]}")
    rem = "; ".join(parts)
    if kind == "hub" and result == "Fail" and num(r["HKEY_NOT_RECOMPUTABLE"]) == rows and not any(
            num(r[c]) or 0 for c in ("NULL_HKEY", "WRONG_LENGTH_HKEY", "COLLISIONS")):
        rem += (". Recompute fails on 100% of rows: the query recomputes '<PROJECT>_' || "
                "PARENT_BK, but the model hashes 'HUB_<NAME>|' || PARENT_BK.")
    return result, failing, rem


def para_with(old_para, text):
    """Replace the runs of a paragraph with one run holding `text`; keep <w:pPr>."""
    ppr = re.search(r"<w:pPr>.*?</w:pPr>", old_para, re.S)
    open_tag = re.match(r"<w:p\b[^>]*?/?>", old_para).group(0).replace("/>", ">")
    run = f'<w:r><w:t xml:space="preserve">{escape(text)}</w:t></w:r>' if text else "<w:r/>"
    return f"{open_tag}{ppr.group(0) if ppr else ''}{run}</w:p>"


def set_cell(tc_xml, text):
    p = PARA.search(tc_xml)
    return tc_xml[:p.start()] + para_with(p.group(0), text) + tc_xml[p.end():]


def fill_section(chunk, values):
    """Fill the label/value rows inside one section's XML chunk."""
    def fix_row(m):
        row = m.group(0)
        cells = list(TC.finditer(row))
        if len(cells) != 2:
            return row
        label = "".join(TEXT.findall(cells[0].group(0))).strip()
        if label not in values:
            return row
        new = set_cell(cells[1].group(0), values[label])
        return row[:cells[1].start()] + new + row[cells[1].end():]
    return TR.sub(fix_row, chunk)


def main():
    project, csv_path = sys.argv[1].upper(), Path(sys.argv[2])
    docx = DMT / f"DM-T2_{project}.docx"
    rows = {int(r["SECTION_NO"]): r for r in csv.DictReader(open(csv_path, newline=""))}
    out = {no: verdict(r) for no, r in rows.items()}
    # Sections the summary query left out because the vault table lacks a
    # column they read: they could not run, so they are recorded as Fail.
    sys.path.insert(0, str(HERE))
    from build_dm_t2_travel_consolidated import SKIP  # noqa: E402
    lo, hi = min(rows), max(rows)
    for no, why in SKIP.get(project, {}).items():
        if lo <= no <= hi and no not in out:
            out[no] = ("Fail", "", f"Not run: {why}.")

    with zipfile.ZipFile(docx) as z:
        xml = z.read("word/document.xml").decode()

    # Section blocks: split the body at numbered Heading2 paragraphs.
    heads = []
    for m in H2.finditer(xml):
        t = "".join(TEXT.findall(m.group(0))).strip()
        mm = re.match(rf"^(\d+)\.\s+{project}\s+\u2014", t)
        if mm:
            heads.append((int(mm.group(1)), m.start()))
    nums = [n for n, _ in heads]
    assert nums == list(range(1, len(nums) + 1)), "docx section numbering has gaps"
    assert set(out) <= set(nums), f"results for sections not in the docx: {sorted(set(out) - set(nums))}"
    parts, cur = [], 0
    for i, (no, start) in enumerate(heads):
        end = heads[i + 1][1] if i + 1 < len(heads) else len(xml)
        parts.append(xml[cur:start])
        if no in out:  # sections without a result (e.g. hubs not run yet) stay as they are
            res, fail, rem = out[no]
            parts.append(fill_section(xml[start:end], dict(zip(LABELS, (res, fail, rem)))))
        else:
            parts.append(xml[start:end])
        cur = end
    parts.append(xml[cur:])
    xml = "".join(parts)

    # Results summary table: columns # | Project | Satellite | Status | Result | Failing rows
    m = re.search(r"Results summary</w:t></w:r></w:p>\s*(<w:tbl\b.*?</w:tbl>)", xml, re.S)
    tbl = m.group(1)

    def fix_summary_row(rm):
        row = rm.group(0)
        cells = list(TC.finditer(row))
        first = "".join(TEXT.findall(cells[0].group(0))).strip()
        if len(cells) < 6 or not first.isdigit() or int(first) not in out:
            return row
        res, fail, _ = out[int(first)]
        for idx, val in ((5, fail), (4, res)):  # right to left keeps offsets valid
            c = list(TC.finditer(row))[idx]
            row = row[:c.start()] + set_cell(c.group(0), val) + row[c.end():]
        return row
    xml = xml[:m.start(1)] + TR.sub(fix_summary_row, tbl) + xml[m.end(1):]

    tmp = docx.with_suffix(".docx.tmp")
    with zipfile.ZipFile(docx) as zin, zipfile.ZipFile(tmp, "w", zipfile.ZIP_DEFLATED) as zout:
        for item in zin.infolist():
            data = xml.encode() if item.filename == "word/document.xml" else zin.read(item.filename)
            zout.writestr(item, data)
    shutil.move(tmp, docx)

    tally = {}
    for res, _, _ in out.values():
        tally[res] = tally.get(res, 0) + 1
    print(f"{docx.name}: {len(out)} sections filled -> {tally}")


if __name__ == "__main__":
    main()
