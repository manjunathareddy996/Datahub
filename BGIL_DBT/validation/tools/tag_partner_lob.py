#!/usr/bin/env python3
"""
Mirror the bold "[Partner LOB]" markers of the .docx sign-off documents into the matching
.sql files, so a reader of the SQL sees the same Partner-LOB scope as the document.

    python3 BGIL_DBT/validation/tools/tag_partner_lob.py            # tag the .sql files
    python3 BGIL_DBT/validation/tools/tag_partner_lob.py --check    # report only, no writes

The tagged object names are READ FROM THE .docx (the documents are the source of truth --
they were tagged from the partner Source-To-Model mapping: a hub / link / satellite is
flagged when it appears in Model Target on a row whose Domains include "Customer / Party",
and SAT_AUG_X inherits the flag of its standard twin SAT_X).

The names are also written to tools/partner_lob_objects.json so the generators can re-apply
the tag after a regeneration.

Scope: DM-H and DM-T only (see GROUPS). DM-R carries the tag in its .docx only, by request.

Only section headings are touched: the marker is added after the object name, exactly as in
the .docx headings. SQL statement bodies are never modified. Re-running is a no-op.
"""
import json
import re
import sys
import zipfile
from collections import OrderedDict
from pathlib import Path

VALIDATION = Path(__file__).resolve().parent.parent
MARKER = "[Partner LOB]"
OBJ = r"(?:HUB|LNK|SAT)_[A-Z0-9_]+"

# Check groups whose .sql files carry the tag. DM-R is deliberately excluded (tagged in its
# .docx only); add a group here if that changes.
GROUPS = ("DM-H", "DM-T")


def tagged_names(docx):
    """Object names carrying the marker in a .docx."""
    xml = zipfile.ZipFile(docx).read("word/document.xml").decode()
    names = set()
    for para in re.findall(r"<w:p[ >].*?</w:p>", xml, re.S):
        text = "".join(re.findall(r"<w:t[^>]*>([^<]*)</w:t>", para))
        if MARKER in text:
            names.update(re.findall(OBJ, text))
    return names


def tag_sql(path, names, write=True):
    """Add the marker to each section heading whose object is flagged. Returns (tagged, total)."""
    text = path.read_text()
    out, tagged, total = [], 0, 0
    for line in text.split("\n"):
        # section heading, e.g. "-- 36. MAXIMUS - SAT_PARTY_IDENTITY   [Implemented]"
        m = re.match(r"^-- \d+\. \S+ . (.+?)(\s{2,}\[[^\]]+\])\s*$", line)
        if m and re.search(OBJ, m.group(1)):
            total += 1
            obj = re.search(OBJ, m.group(1)).group(0)
            if obj in names and MARKER not in line:
                line = line[: m.start(1)] + f"{m.group(1)} {MARKER}" + m.group(2)
                tagged += 1
            elif obj in names:
                tagged += 1
        out.append(line)
    body = "\n".join(out)

    # one-line scope note in the file header, before the first overview row
    if tagged and "PARTNER LOB:" not in body:
        note = (f"   PARTNER LOB: {tagged} of {total} objects below carry the {MARKER} tag -- the same objects\n"
                f"       tagged in the matching .docx (Customer / Party domain rows of the partner\n"
                f"       Source-To-Model mapping). The tag is scope information only: SQL bodies, pass\n"
                f"       criteria and results are unaffected.\n")
        body = re.sub(r"^(   Check ID: )", note + r"\1", body, count=1, flags=re.M)

    if write and body != text:
        path.write_text(body)
    return tagged, total


def main():
    check_only = "--check" in sys.argv
    index, rows = OrderedDict(), []
    for docx in sorted(d for g in GROUPS for d in VALIDATION.glob(f"{g}/*.docx")):
        names = tagged_names(docx)
        if not names:
            continue
        sql = docx.with_suffix(".sql")
        if not sql.exists():
            print(f"  WARNING no .sql beside {docx.name}")
            continue
        tagged, total = tag_sql(sql, names, write=not check_only)
        project = "MAXIMUS" if "MAXIMUS" in docx.stem else "OPUS"
        index.setdefault(project, set()).update(names)
        rows.append((sql.relative_to(VALIDATION), len(names), tagged, total))

    width = max(len(str(r[0])) for r in rows)
    print(f"{'file':<{width}}  docx_objs  sql_tagged  sql_sections")
    for f, n, t, tot in rows:
        print(f"{str(f):<{width}}  {n:>9}  {t:>10}  {tot:>12}")

    if not check_only:
        out = VALIDATION / "tools" / "partner_lob_objects.json"
        out.write_text(json.dumps({k: sorted(v) for k, v in sorted(index.items())}, indent=2) + "\n")
        print(f"\nname list -> {out.relative_to(VALIDATION.parent)} "
              f"({', '.join(f'{k}: {len(v)}' for k, v in index.items())})")


if __name__ == "__main__":
    main()
