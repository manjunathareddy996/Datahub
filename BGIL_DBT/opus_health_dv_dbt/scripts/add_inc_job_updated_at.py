"""Add ``inc_job_updated_at`` to Health staging models (design D8, requirements 7.1-7.7).

Default mode is --plan: nothing is written. --write edits the files. Files are read and
written as bytes so BOM and newline style are preserved. Each edit is a pure one-line
insertion before an anchor select item.
"""
from __future__ import annotations

import argparse
import csv
import json
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path

JOB_COL = "INC_JOB_UPDATED_AT"
PLAIN_EXPR = '"INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at,'
Z_EXPR = ("to_timestamp_ntz(regexp_replace(\"INC_JOB_UPDATED_AT\"::varchar, '^Z[ ]*', '')) "
          "as inc_job_updated_at,")

ALREADY_RE = re.compile(r"\bas\s+inc_job_updated_at\b", re.IGNORECASE)
SELECT_RE = re.compile(r"^\s*select\s*$", re.IGNORECASE)
FROM_RE = re.compile(r"from\s*\{\{\s*source\(", re.IGNORECASE)
ITEM_RE = re.compile(r"^(\s*)(\S.*?)\s+as\s+([A-Za-z_]\w*)\s*,?\s*$", re.IGNORECASE)
QUOTED_RE = re.compile(r'"([^"]+)"')
TABLE_RE = re.compile(r"source\(\s*'[^']*'\s*,\s*'([^']+)'\s*\)", re.IGNORECASE)
LINE_RE = re.compile(r"[^\n]*\n|[^\n]+")

STATUS_CHANGED = "changed"
STATUS_ALREADY = "already"
STATUS_SKIPPED = "skipped"
REASON_UNPARSABLE = "unparsable"
REASON_NO_RAW = "no usable raw column"


@dataclass(frozen=True)
class Evidence:
    """raw_columns maps UPPER table name -> set of UPPER column names; None means no export."""
    raw_columns: dict[str, set[str]] | None = None
    z_prefix_tables: frozenset[str] = field(default_factory=frozenset)


@dataclass(frozen=True)
class StgEdit:
    status: str
    reason: str = ""
    unverified: bool = False
    table: str = ""
    anchor_line: int = -1  # 0-based index of the line the new line was inserted before


def _strip_comments(text: str) -> str:
    return "\n".join(line.split("--", 1)[0] for line in text.split("\n"))


def edit_stg(text: str, evidence: Evidence | None = None) -> tuple[str, StgEdit]:
    evidence = evidence or Evidence()
    if ALREADY_RE.search(_strip_comments(text)):
        return text, StgEdit(STATUS_ALREADY)

    lines = LINE_RE.findall(text)
    bare = [ln.rstrip("\r\n") for ln in lines]
    skip = StgEdit(STATUS_SKIPPED, REASON_UNPARSABLE)

    sel = [i for i, ln in enumerate(bare) if SELECT_RE.match(ln.lstrip("\ufeff"))]
    frm = [i for i, ln in enumerate(bare) if FROM_RE.search(ln)]
    if len(sel) != 1 or len(frm) != 1 or not sel[0] < frm[0]:
        return text, skip

    items = []  # (line index, indent, raw column)
    for i in range(sel[0] + 1, frm[0]):
        m = ITEM_RE.match(bare[i])
        q = QUOTED_RE.search(bare[i]) if m else None
        if not m or not q:
            return text, skip
        items.append((i, m.group(1), q.group(1).upper()))
    if not items:
        return text, skip

    tm = TABLE_RE.search(bare[frm[0]])
    table = tm.group(1).upper() if tm else ""

    if evidence.raw_columns is not None:
        cols = evidence.raw_columns.get(table)
        if cols is None or JOB_COL not in cols:
            return text, StgEdit(STATUS_SKIPPED, REASON_NO_RAW, False, table)

    anchor = next((it for it in items if it[2] > JOB_COL), items[-1])
    nl = "\r\n" if "\r\n" in text else "\n"
    expr = Z_EXPR if table in evidence.z_prefix_tables else PLAIN_EXPR
    new_line = anchor[1] + expr + nl
    out = "".join(lines[:anchor[0]]) + new_line + "".join(lines[anchor[0]:])
    return out, StgEdit(STATUS_CHANGED, "", evidence.raw_columns is None, table, anchor[0])


def load_raw_columns(path: Path) -> dict[str, set[str]]:
    result: dict[str, set[str]] = {}
    with open(path, newline="", encoding="utf-8-sig") as fh:
        for row in csv.DictReader(fh):
            row = {k.strip().upper(): (v or "").strip() for k, v in row.items() if k}
            t, c = row.get("TABLE_NAME", "").upper(), row.get("COLUMN_NAME", "").upper()
            if t and c:
                result.setdefault(t, set()).add(c)
    return result


def run(stg_dir: Path, evidence: Evidence, write: bool) -> dict:
    report = {"changed": [], "already": [], "skipped": [], "unverified": []}
    for path in sorted(stg_dir.glob("stg_health__*.sql")):
        data = path.read_bytes()
        new_text, res = edit_stg(data.decode("utf-8"), evidence)
        name = path.stem
        if res.status == STATUS_ALREADY:
            report["already"].append(name)
        elif res.status == STATUS_SKIPPED:
            report["skipped"].append({"model": name, "reason": res.reason})
        else:
            report["changed"].append(name)
            if res.unverified:
                report["unverified"].append(name)
            if write:
                path.write_bytes(new_text.encode("utf-8"))
    report["counts"] = {"changed": len(report["changed"]), "already": len(report["already"]),
                        "skipped": len(report["skipped"])}
    report["mode"] = "write" if write else "plan"
    report["raw_columns_evidence"] = evidence.raw_columns is not None
    return report


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    g = ap.add_mutually_exclusive_group()
    g.add_argument("--plan", action="store_true", help="show what would change (default)")
    g.add_argument("--write", action="store_true", help="edit the stg files")
    ap.add_argument("--raw-columns", type=Path, help="CSV: TABLE_NAME,COLUMN_NAME[,DATA_TYPE]")
    ap.add_argument("--z-prefix-tables", default="", help="comma-separated table names")
    ap.add_argument("--report", type=Path, help="write the JSON report here")
    ap.add_argument("--stg-dir", type=Path,
                    default=Path(__file__).resolve().parent.parent / "models" / "staging" / "health")
    args = ap.parse_args(argv)

    ev = Evidence(load_raw_columns(args.raw_columns) if args.raw_columns else None,
                  frozenset(t.strip().upper() for t in args.z_prefix_tables.split(",") if t.strip()))
    report = run(args.stg_dir, ev, args.write)
    if args.report:
        args.report.parent.mkdir(parents=True, exist_ok=True)
        args.report.write_text(json.dumps(report, indent=2), encoding="utf-8")
    c = report["counts"]
    print(f"mode={report['mode']} changed={c['changed']} already={c['already']} skipped={c['skipped']} "
          f"unverified={len(report['unverified'])}")
    for s in report["skipped"]:
        print(f"  skipped: {s['model']}: {s['reason']}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
