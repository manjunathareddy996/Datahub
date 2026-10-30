#!/usr/bin/env python3
"""
Split each generated travel validation file into three equal member buckets
(M1 / M2 / M3) and tag every section heading accordingly in BOTH the .sql
and the matching .docx. Idempotent -- re-running strips previous [Mx]
tags before re-splitting.

Scope: every file under BGIL_DBT/validation/travel/DM-*/{DM-*.sql,DM-*.docx}.
Within one file, sections are numbered 1..N by the generator; this tool
assigns M1 to the first ceil(N/3), M2 to the next, M3 to the remainder.

    python3 BGIL_DBT/validation/tools/tag_travel_members.py
    python3 BGIL_DBT/validation/tools/tag_travel_members.py --check   # report only
"""
import io
import math
import re
import shutil
import sys
import zipfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
TRAVEL = HERE.parent / "travel"


# ---------------------------------------------------------------------------
# Split helper
# ---------------------------------------------------------------------------
def member_buckets(n):
    """Return a list of length n with entries 'M1'/'M2'/'M3', split as evenly
    as possible with the leftover rows going to M1 then M2."""
    base, extra = divmod(n, 3)
    sizes = [base + (1 if i < extra else 0) for i in range(3)]
    out = []
    for label, size in zip(("M1", "M2", "M3"), sizes):
        out.extend([label] * size)
    return out


# ---------------------------------------------------------------------------
# SQL tagging
# ---------------------------------------------------------------------------
# Matches `-- 12. OPUS — SAT_FOO   [Implemented]` with any trailing [Mx] already
# present stripped off. Captures prefix (through `[Implemented]`) separately
# from any trailing member tag we previously inserted.
SQL_HEAD = re.compile(
    r"^(-- \d+\. .+?\[[^\]]+\])(\s+\[M[123]\])?\s*$", re.M)


def tag_sql(path, write=True):
    text = path.read_text()
    heads = list(SQL_HEAD.finditer(text))
    if not heads:
        return 0, 0
    buckets = member_buckets(len(heads))
    out = []
    cur = 0
    counts = {"M1": 0, "M2": 0, "M3": 0}
    for m, mem in zip(heads, buckets):
        out.append(text[cur:m.start()])
        prefix = m.group(1)
        out.append(f"{prefix}  [{mem}]")
        counts[mem] += 1
        cur = m.end()
    out.append(text[cur:])
    body = "".join(out)
    # Insert / refresh the header note.
    note = (
        f"   MEMBER SPLIT: sections 1..{len(heads)} assigned "
        f"M1 x {counts['M1']}, M2 x {counts['M2']}, M3 x {counts['M3']} -- "
        f"contiguous thirds in listed order.\n")
    body = re.sub(r"^   MEMBER SPLIT:.*\n", "", body, flags=re.M)
    body = re.sub(r"^(   Check ID: )", note + r"\1", body, count=1, flags=re.M)
    if write and body != text:
        path.write_text(body)
    return len(heads), counts


# ---------------------------------------------------------------------------
# DOCX tagging. Each section is a Heading2 paragraph of the form
#   "<N>. <project> — <object>"
# or already carries a trailing "[Mx]" that we may need to strip first.
# ---------------------------------------------------------------------------
# Match an <w:p> whose pStyle is Heading2. We split the paragraph into runs
# via a simple regex and look at its concatenated text to spot section
# headings; the member tag goes into a new run at the end of the paragraph.
H2_PARA = re.compile(
    r"(<w:p\b[^>]*>\s*<w:pPr>\s*<w:pStyle w:val=\"Heading2\"\s*/>\s*</w:pPr>)"
    r"(.*?)(</w:p>)", re.S)
RUN_TEXT = re.compile(r"<w:t[^>]*>([^<]*)</w:t>", re.S)
TAIL_MEMBER_RUN = re.compile(
    r"<w:r>\s*<w:t[^>]*> \[M[123]\]</w:t>\s*</w:r>\s*(?=</w:p>$)", re.S)


def paragraph_text(inner):
    return "".join(RUN_TEXT.findall(inner))


def strip_tail_member(inner):
    return TAIL_MEMBER_RUN.sub("", inner)


def member_run(label):
    """A plain run that appends '  [Mx]' to a paragraph."""
    return (
        f'<w:r><w:t xml:space="preserve">  [{label}]</w:t></w:r>')


RESULTS_TBL = re.compile(
    r"Results summary</w:t></w:r></w:p>\s*(<w:tbl\b.*?</w:tbl>)", re.S)
TR = re.compile(r"<w:tr\b.*?</w:tr>", re.S)
TC_IN_TR = re.compile(r"<w:tc\b.*?</w:tc>", re.S)
# Last <w:t ...>...</w:t> inside a cell. We mutate the SATELLITE cell (col 3).
LAST_WT_IN_CELL = re.compile(
    r"(.*)(<w:t[^>]*>)([^<]*)(</w:t>)(?!.*<w:t)", re.S)
TAIL_MEMBER_TXT = re.compile(r"\s*\[M[123]\]\s*$")


def tag_results_table(doc_xml, buckets):
    """Append '  [Mx]' to the Satellite cell of each data row in the first
    Results summary table found. `buckets` is the member assignment used for
    headings; row N inherits buckets[N-1]. Idempotent: existing trailing
    '[Mx]' on the satellite text is stripped first."""
    m = RESULTS_TBL.search(doc_xml)
    if not m:
        return doc_xml, 0
    tbl_start, tbl_end = m.start(1), m.end(1)
    tbl = m.group(1)
    rows = list(TR.finditer(tbl))
    if len(rows) <= 1:
        return doc_xml, 0
    data_rows = rows[1:]
    new_tbl_parts = []
    cur = 0
    tagged = 0
    for i, tr in enumerate(data_rows):
        new_tbl_parts.append(tbl[cur:tr.start()])
        row_xml = tr.group(0)
        cells = list(TC_IN_TR.finditer(row_xml))
        if len(cells) < 3 or i >= len(buckets):
            new_tbl_parts.append(row_xml)
            cur = tr.end()
            continue
        sat_cell = cells[2]
        cell_xml = sat_cell.group(0)
        mem = buckets[i]
        def _append(mm):
            prefix, open_tag, text, close_tag = mm.group(1), mm.group(2), mm.group(3), mm.group(4)
            stripped = TAIL_MEMBER_TXT.sub("", text)
            return f"{prefix}{open_tag}{stripped}  [{mem}]{close_tag}"
        new_cell = LAST_WT_IN_CELL.sub(_append, cell_xml, count=1)
        if new_cell == cell_xml:
            new_tbl_parts.append(row_xml)
            cur = tr.end()
            continue
        new_row = row_xml[:sat_cell.start()] + new_cell + row_xml[sat_cell.end():]
        new_tbl_parts.append(new_row)
        cur = tr.end()
        tagged += 1
    new_tbl_parts.append(tbl[cur:])
    new_tbl = "".join(new_tbl_parts)
    return doc_xml[:tbl_start] + new_tbl + doc_xml[tbl_end:], tagged


def tag_docx_xml(doc_xml):
    """Return (new_xml, n_sections, counts). Numbering is derived from the
    heading text itself (`<N>. ...`) so we don't miscount H2 paragraphs that
    aren't section headings (e.g. appendix headings)."""
    # First pass: locate every section heading paragraph in order.
    heads = []
    for m in H2_PARA.finditer(doc_xml):
        inner = m.group(2)
        text = paragraph_text(strip_tail_member(inner)).strip()
        if re.match(r"^\d+\.\s+.+?\s+[\u2014\-]\s+.+$", text):
            heads.append(m)
    if not heads:
        return doc_xml, 0, {"M1": 0, "M2": 0, "M3": 0}
    buckets = member_buckets(len(heads))
    counts = {"M1": 0, "M2": 0, "M3": 0}
    out = []
    cur = 0
    for m, mem in zip(heads, buckets):
        out.append(doc_xml[cur:m.start()])
        inner = strip_tail_member(m.group(2))
        out.append(m.group(1) + inner + member_run(mem) + m.group(3))
        counts[mem] += 1
        cur = m.end()
    out.append(doc_xml[cur:])
    new_xml = "".join(out)
    # Second pass: tag the Results summary table rows with the SAME buckets.
    new_xml, _ = tag_results_table(new_xml, buckets)
    return new_xml, len(heads), counts


def tag_docx(path, write=True):
    with zipfile.ZipFile(path) as zin:
        doc_xml = zin.read("word/document.xml").decode()
    new_xml, n, counts = tag_docx_xml(doc_xml)
    if n == 0:
        return 0, counts
    if not write or new_xml == doc_xml:
        return n, counts
    tmp = path.with_suffix(".docx.tmp")
    with zipfile.ZipFile(path) as zin, zipfile.ZipFile(
            tmp, "w", zipfile.ZIP_DEFLATED) as zout:
        for item in zin.infolist():
            data = (new_xml.encode() if item.filename == "word/document.xml"
                    else zin.read(item.filename))
            zout.writestr(item, data)
    shutil.move(tmp, path)
    return n, counts


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main():
    check_only = "--check" in sys.argv
    sql_files = sorted(TRAVEL.glob("DM-*/*.sql"))
    docx_files = sorted(TRAVEL.glob("DM-*/*.docx"))
    width = max(
        (len(str(p.relative_to(TRAVEL))) for p in sql_files + docx_files),
        default=20)
    print(f"{'file':<{width}}  sections  M1  M2  M3")
    for p in sql_files:
        n, c = tag_sql(p, write=not check_only)
        print(f"{str(p.relative_to(TRAVEL)):<{width}}  "
              f"{n:>8}  {c['M1']:>2}  {c['M2']:>2}  {c['M3']:>2}")
    for p in docx_files:
        n, c = tag_docx(p, write=not check_only)
        print(f"{str(p.relative_to(TRAVEL)):<{width}}  "
              f"{n:>8}  {c['M1']:>2}  {c['M2']:>2}  {c['M3']:>2}")


if __name__ == "__main__":
    main()
