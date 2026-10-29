#!/usr/bin/env python3
"""
Travel LOB tagger. Mirror the bold "[Travel LOB]" markers of the .docx
sign-off documents into the matching .sql files.

The Travel LOB docs don't yet carry a "[Travel LOB]" marker, so this
tool runs as a no-op in the first round: it reports the section count of
each generated travel .sql and writes an empty tools/travel_lob_objects.json.
Add the markers in the .docx files (as the partner tagger expects) and
re-run to populate the JSON and tag the .sql files.

    python3 BGIL_DBT/validation/tools/tag_travel_lob.py            # tag (no-op today)
    python3 BGIL_DBT/validation/tools/tag_travel_lob.py --check    # report only
"""
import json
import re
import sys
import zipfile
from collections import OrderedDict
from pathlib import Path

HERE = Path(__file__).resolve().parent
VALIDATION = HERE.parent / "travel"
MARKER = "[Travel LOB]"
OBJ = r"(?:HUB|LNK|SAT)_[A-Z0-9_]+"
GROUPS = ("DM-H", "DM-T")  # tag these .sql; DM-R stays tagged only in .docx.


def tagged_names(docx):
    try:
        xml = zipfile.ZipFile(docx).read("word/document.xml").decode()
    except (zipfile.BadZipFile, KeyError):
        return set()
    names = set()
    for para in re.findall(r"<w:p[ >].*?</w:p>", xml, re.S):
        text = "".join(re.findall(r"<w:t[^>]*>([^<]*)</w:t>", para))
        if MARKER in text:
            names.update(re.findall(OBJ, text))
    return names


def tag_sql(path, names, write=True):
    text = path.read_text()
    out, tagged, total = [], 0, 0
    for line in text.split("\n"):
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
    if tagged and "TRAVEL LOB:" not in body:
        note = (f"   TRAVEL LOB: {tagged} of {total} objects below carry the {MARKER} tag -- the same objects\n"
                f"       tagged in the matching .docx. The tag is scope information only: SQL bodies,\n"
                f"       pass criteria and results are unaffected.\n")
        body = re.sub(r"^(   Check ID: )", note + r"\1", body, count=1, flags=re.M)
    if write and body != text:
        path.write_text(body)
    return tagged, total


def main():
    check_only = "--check" in sys.argv
    index, rows = OrderedDict(), []
    for docx in sorted(d for g in GROUPS for d in VALIDATION.glob(f"{g}/*.docx")):
        names = tagged_names(docx)
        sql = docx.with_suffix(".sql")
        if not sql.exists():
            print(f"  WARNING no .sql beside {docx.name}")
            continue
        tagged, total = tag_sql(sql, names, write=not check_only) if names else (0, 0)
        project = "MAXIMUS" if "MAXIMUS" in docx.stem else "OPUS"
        if names:
            index.setdefault(project, set()).update(names)
        rows.append((sql.relative_to(VALIDATION), len(names), tagged, total))

    if not rows:
        print("No travel .docx files found yet -- generators have not run or the "
              "folder is empty.")
        # Still write the placeholder JSON so downstream consumers import something.
        out = HERE / "travel_lob_objects.json"
        if not out.exists():
            out.write_text(json.dumps({"MAXIMUS": [], "OPUS": []}, indent=2) + "\n")
            print(f"Wrote empty {out.relative_to(VALIDATION.parent.parent)}")
        return

    width = max((len(str(r[0])) for r in rows), default=20)
    print(f"{'file':<{width}}  docx_objs  sql_tagged  sql_sections")
    for f, n, t, tot in rows:
        print(f"{str(f):<{width}}  {n:>9}  {t:>10}  {tot:>12}")

    if not check_only:
        out = HERE / "travel_lob_objects.json"
        payload = {k: sorted(v) for k, v in sorted(index.items())}
        # Preserve both projects as keys even if one has zero tagged objects.
        for proj in ("MAXIMUS", "OPUS"):
            payload.setdefault(proj, [])
        out.write_text(json.dumps(payload, indent=2, sort_keys=True) + "\n")
        print(f"\nname list -> {out.relative_to(VALIDATION.parent.parent)} "
              f"({', '.join(f'{k}: {len(v)}' for k, v in payload.items())})")


if __name__ == "__main__":
    main()
