#!/usr/bin/env python3
"""
Validate Snowflake SQL files to ensure they do not hard-code disallowed
database or schema references and rely on the environment-provided context.
"""

from __future__ import annotations

import argparse
import os
import pathlib
import re
import sys
from typing import Iterable, List, Optional, Sequence, Set


def _normalize(identifier: str) -> str:
    identifier = identifier.strip()
    if identifier.startswith('"') and identifier.endswith('"'):
        identifier = identifier[1:-1]
    return identifier.upper()


def load_changed_files(path: pathlib.Path) -> List[pathlib.Path]:
    if not path.exists():
        return []
    with path.open() as handle:
        return [pathlib.Path(line.strip()) for line in handle if line.strip()]


def scan_sql_file(
    file_path: pathlib.Path,
    target_database: Optional[str],
    target_schema: Optional[str],
    blocked_tokens: Set[str],
) -> List[str]:
    violations: List[str] = []
    try:
        content = file_path.read_text()
    except (UnicodeDecodeError, FileNotFoundError):
        return violations  # ignore binary or missing files

    database_upper = target_database.upper() if target_database else None
    schema_upper = target_schema.upper() if target_schema else None

    # Matches: USE DATABASE <identifier>
    use_db_pattern = re.compile(r'(?is)\bUSE\s+DATABASE\s+([A-Z0-9_"]+)')
    # Matches: USE SCHEMA <identifier> (optionally DB.SCHEMA)
    use_schema_pattern = re.compile(r'(?is)\bUSE\s+SCHEMA\s+([A-Z0-9_."\$]+)')
    # Matches fully qualified object: <db>.<schema>.<object>
    fully_qualified_pattern = re.compile(
        r'\b([A-Z0-9_"]+)\.([A-Z0-9_"]+)\.([A-Z0-9_"]+)\b', re.IGNORECASE
    )

    def line_number(pos: int) -> int:
        return content.count("\n", 0, pos) + 1

    if database_upper:
        for match in use_db_pattern.finditer(content):
            target = _normalize(match.group(1))
            if target != database_upper:
                violations.append(
                    f"{file_path}:{line_number(match.start())} uses database '{target}' "
                    f"(expected {database_upper})"
                )

    if database_upper and schema_upper:
        for match in use_schema_pattern.finditer(content):
            target_full = match.group(1)
            parts = [_normalize(part) for part in target_full.split(".")]
            if len(parts) == 2:
                db_part, schema_part = parts
            else:
                db_part, schema_part = database_upper, parts[0]
            if db_part != database_upper or schema_part != schema_upper:
                violations.append(
                    f"{file_path}:{line_number(match.start())} uses schema '{target_full}' "
                    f"(expected {database_upper}.{schema_upper})"
                )

    if database_upper:
        for idx, line in enumerate(content.splitlines(), start=1):
            for match in fully_qualified_pattern.finditer(line):
                db_ref = _normalize(match.group(1))
                if db_ref != database_upper:
                    violations.append(
                        f"{file_path}:{idx} references database '{db_ref}' "
                        f"in object '{match.group(0)}'"
                    )

    upper_content = content.upper()
    for token in blocked_tokens:
        if token in upper_content:
            for idx, line in enumerate(content.splitlines(), start=1):
                if token in line.upper():
                    violations.append(
                        f"{file_path}:{idx} contains blocked token '{token}'"
                    )
                    break

    return violations


def parse_args(argv: Sequence[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Validate Snowflake SQL files against hard-coded DB/schema references."
    )
    parser.add_argument(
        "--changed-files",
        default="changed_files.txt",
        help="Path to the file listing SQL files to validate (default: %(default)s).",
    )
    parser.add_argument(
        "--database",
        help="Target Snowflake database (defaults to SNOWFLAKE_DATABASE env var).",
    )
    parser.add_argument(
        "--schema",
        help="Target Snowflake schema (defaults to SNOWFLAKE_SCHEMA env var).",
    )
    parser.add_argument(
        "--blocked",
        default=os.environ.get("SNOWFLAKE_BLOCKED_DATABASES", "DEV_DB,UAT_DB,PROD_DB"),
        help="Comma-separated list of blocked database tokens (default: %(default)s).",
    )
    return parser.parse_args(argv)


def main(argv: Sequence[str] | None = None) -> int:
    args = parse_args(argv or sys.argv[1:])

    database = (args.database or os.environ.get("SNOWFLAKE_DATABASE") or "").strip() or None
    schema = (args.schema or os.environ.get("SNOWFLAKE_SCHEMA") or "").strip() or None
    if database is None or schema is None:
        print(
            "⚠️  SNOWFLAKE_DATABASE/SNOWFLAKE_SCHEMA not provided; "
            "skipping explicit USE/database mismatch checks and scanning for blocked tokens only."
        )

    changed_files = load_changed_files(pathlib.Path(args.changed_files))
    if not changed_files:
        print("No SQL files to validate; skipping.")
        return 0

    blocked_tokens = {_normalize(token) for token in args.blocked.split(",") if token}
    violations: List[str] = []

    for file_path in changed_files:
        if file_path.suffix.lower() != ".sql":
            continue
        violations.extend(
            scan_sql_file(file_path, database, schema, blocked_tokens)
        )

    if violations:
        print("❌ Hard-coded database/schema references detected:")
        for violation in violations:
            print(f" - {violation}")
        print(
            "\nUpdate the SQL to rely on the pipeline-provided database/schema "
            "or get approval to extend the allow-list.",
            file=sys.stderr,
        )
        return 1

    print("✅ SQL files passed environment reference validation.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
 
