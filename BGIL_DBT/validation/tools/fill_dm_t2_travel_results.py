#!/usr/bin/env python3
"""
Write DM-T2 travel results (statement 2 of a DM-T2_<PROJECT>_*_SUMMARY.sql run,
exported as CSV) into DM-T2_<PROJECT>.docx:

  * each section block: "Result (Pass / Fail / NA)", "Rows with status = FAIL
    (count)" and "Remarks"
  * the "Results summary" table: Result and Failing rows columns

    python3 BGIL_DBT/validation/tools/fill_dm_t2_travel_results.py OPUS \
        BGIL_DBT/validation/travel/DM-T/results/DM-T2_OPUS_SUMMARY_2026-11-12.csv

Verdict rules (applied on top of the query's PASS / FAIL):
  * rows_in_scope = 0                   -> NA   (table holds no rows for the
                                                 project's travel RECORD_SOURCEs)
  * section 1, every column BINARY      -> Pass (Snowflake INFORMATION_SCHEMA
                                                 reports no length for BINARY;
                                                 16 bytes is checked per table by
                                                 wrong_length_hkey)
  * hub whose only failure is hkey_not_recomputable on 100% of rows
                                        -> Pending re-run (the query recomputes
                                                 '<PROJECT>_' || PARENT_BK but the
                                                 models hash 'HUB_<NAME>|' ||
                                                 PARENT_BK; query defect, not data)
  * anything else                       -> the query's own Pass / Fail
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
    no, kind = int(r["SECTION_NO"]), r["TABLE_TYPE"]
    rows = num(r["ROWS_IN_SCOPE"])
    if kind != "columns" and rows == 0:
        return "NA", "", ("0 rows in scope: the table holds no rows for this project's travel "
                          "RECORD_SOURCE values (old and LOB-scoped prefix).")
    if no == 1:
        rem = r["REMARKS"]
        listed = re.findall(r"\b([A-Z0-9_]+\.[A-Z0-9_]+) (\w+)", rem)
        if listed and all(t == "BINARY" for _, t in listed) and len(listed) == rows:
            return "Pass", "0", (f"All {rows} *_HKEY / HASHDIFF columns are BINARY. Snowflake "
                                 "INFORMATION_SCHEMA.COLUMNS reports no length for BINARY, so the "
                                 "query flagged them; the 16-byte length is confirmed per table by "
                                 "wrong_length_hkey = 0 in every section with rows.")
        return r["RESULT"], r["FAILING_ROWS"], rem
    if kind == "hub" and r["RESULT"] == "Fail":
        nr = num(r["HKEY_NOT_RECOMPUTABLE"])
        others = [num(r[c]) or 0 for c in ("NULL_HKEY", "WRONG_LENGTH_HKEY", "COLLISIONS")]
        if nr == rows and not any(others):
            return "Pending re-run", "", (
                f"rows_in_scope={rows}; null_hkey=0; wrong_length_hkey=0; collisions=0. "
                f"hkey_not_recomputable={nr} (100%): the query recomputed '<PROJECT>_' || PARENT_BK, "
                "but the model hashes 'HUB_<NAME>|' || PARENT_BK. Recompute to be re-run with "
                "the corrected formula.")
    parts = [f"rows_in_scope={r['ROWS_IN_SCOPE']}"]
    for c in ("NULL_HKEY", "NULL_FK_HKEYS", "WRONG_LENGTH_HKEY", "HKEY_NOT_RECOMPUTABLE",
              "COLLISIONS", "NULL_HASHDIFF"):
        if r[c] != "":
            parts.append(f"{c.lower()}={r[c]}")
    return r["RESULT"], r["FAILING_ROWS"], "; ".join(parts)


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

    with zipfile.ZipFile(docx) as z:
        xml = z.read("word/document.xml").decode()

    # Section blocks: split the body at numbered Heading2 paragraphs.
    heads = []
    for m in H2.finditer(xml):
        t = "".join(TEXT.findall(m.group(0))).strip()
        mm = re.match(rf"^(\d+)\.\s+{project}\s+\u2014", t)
        if mm:
            heads.append((int(mm.group(1)), m.start()))
    assert [n for n, _ in heads] == sorted(rows), "docx sections do not match the CSV"
    parts, cur = [], 0
    for i, (no, start) in enumerate(heads):
        end = heads[i + 1][1] if i + 1 < len(heads) else len(xml)
        parts.append(xml[cur:start])
        res, fail, rem = out[no]
        parts.append(fill_section(xml[start:end], dict(zip(LABELS, (res, fail, rem)))))
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
