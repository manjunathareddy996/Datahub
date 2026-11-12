#!/usr/bin/env python3
"""
Build one summary Snowflake query PER PROJECT for travel DM-T2 (hash key
integrity) from the generated per-section files:

    travel/DM-T/DM-T2_OPUS.sql      (60 sections)
    travel/DM-T/DM-T2_MAXIMUS.sql   (229 sections)

Output: travel/DM-T/DM-T2_OPUS_SUMMARY.sql, travel/DM-T/DM-T2_MAXIMUS_SUMMARY.sql

Each output file holds three statements, run top to bottom:
  1. Preflight  -- lists any in-scope table missing from BGIL_DATA_MODEL
                   (a missing table would make statement 2 fail).
  2. Main       -- every section as one UNION ALL; one row per section with
                   section_no / member / object / result / failing_rows /
                   remarks, in the same order as the .docx Results summary.
  3. Rollup     -- pass / fail counts per member, read from
                   statement 2 via RESULT_SCAN (no re-scan of the vault).

The section queries are copied verbatim; the only rewrite is inlining the
hub/link `with c as (...)` CTE into the collisions sub-select so every
section can sit inside a UNION ALL.

    python3 BGIL_DBT/validation/tools/build_dm_t2_travel_consolidated.py
"""
import re
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))
from tag_travel_members import member_buckets  # noqa: E402

DMT = HERE.parent / "travel" / "DM-T"
SOURCES = [("OPUS", DMT / "DM-T2_OPUS.sql"), ("MAXIMUS", DMT / "DM-T2_MAXIMUS.sql")]

DASH = "-" * 88
HEAD = re.compile(
    r"^-- (\d+)\. (OPUS|MAXIMUS) \u2014 (.+?)\s+\[Implemented\](?:\s+\[M[123]\])?\s*$",
    re.M)
CTE = re.compile(r"^with c as \(\n(.*?)\n\)\n(select\b.*)$", re.S)

# Metric columns each table type must expose; the rest are NULL in the union.
METRICS = ["rows_in_scope", "null_hkey", "null_fk_hkeys", "wrong_length_hkey",
           "hkey_not_recomputable", "collisions", "null_hashdiff"]
EXPECTED = {
    "hub": {"rows_in_scope", "null_hkey", "wrong_length_hkey",
            "hkey_not_recomputable", "collisions"},
    "link": {"rows_in_scope", "null_hkey", "null_fk_hkeys",
             "wrong_length_hkey", "collisions"},
    "satellite": {"rows_in_scope", "null_hkey", "wrong_length_hkey",
                  "null_hashdiff"},
}


def sections(path):
    """Yield (section_no, object_label, sql) in file order."""
    text = path.read_text()
    heads = list(HEAD.finditer(text))
    for i, m in enumerate(heads):
        end = heads[i + 1].start() if i + 1 < len(heads) else len(text)
        chunk = text[m.end():end]
        # Body starts after the dashed line that closes the header comment.
        body = chunk.split(DASH, 1)[1]
        # Body ends at the dashed line that opens the next header (if any).
        body = body.split(DASH, 1)[0]
        body = body.strip()
        assert body.endswith(";"), f"{path.name} §{m.group(1)}: no terminating ;"
        yield int(m.group(1)), m.group(3).strip(), body[:-1].rstrip()


def indent(sql, n=8):
    pad = " " * n
    return "\n".join(pad + ln if ln.strip() else ln for ln in sql.splitlines())


def lit(s):
    return "'" + s.replace("'", "''") + "'"


def type_check_branch(project, no, member, label, sql):
    """Section 1: many rows (one per hash column) -> one summary row."""
    sql = re.sub(r"\n\s*order by .*$", "", sql, flags=re.S)
    tables = re.search(r"table_name in \(([^)]*)\)", sql).group(1)
    names = re.findall(r"'([A-Z0-9_]+)'", tables)
    return names, f"""select {no} as section_no, '{project}' as project, '{member}' as member,
       'columns' as table_type, {lit(label)} as section_object,
       count(*) as rows_in_scope,
       null::number as null_hkey, null::number as null_fk_hkeys,
       null::number as wrong_length_hkey, null::number as hkey_not_recomputable,
       null::number as collisions, null::number as null_hashdiff,
       count_if(status = 'FAIL') as failing_rows,
       iff(count_if(status = 'FAIL') = 0, 'PASS', 'FAIL') as status,
       'columns checked=' || count(*)
         || iff(count_if(status = 'FAIL') > 0,
                '; non BINARY(16): ' || listagg(iff(status = 'FAIL', table_name || '.' || column_name || ' ' || data_type || coalesce('(' || byte_length || ')', ''), null), ', ') within group (order by table_name, column_name),
                '') as remarks
  from (
{indent(sql)}
  )"""


def table_branch(project, no, member, label, sql):
    ttype = re.search(r"'(hub|link|satellite)' as table_type", sql).group(1)
    m = CTE.match(sql)
    if m:
        cte, main = m.group(1), m.group(2)
        assert "(select count(*) from c)" in main, f"{project} §{no}: CTE use"
        sql = main.replace("(select count(*) from c)",
                           "(select count(*) from (\n" + cte + "\n       ))")
    have = set(re.findall(r"\bas (\w+)\s*,?\s*$", sql, re.M)) & set(METRICS)
    want = EXPECTED[ttype]
    assert want <= have, f"{project} §{no} {label}: missing {want - have}"
    cols = ",\n       ".join(
        f"{c}" if c in want else f"null::number as {c}" for c in METRICS)
    remarks = ", ".join(
        f"iff({c} > 0, '{c}=' || {c}, null)"
        for c in METRICS if c in want and c != "rows_in_scope")
    return f"""select {no} as section_no, '{project}' as project, '{member}' as member,
       table_type, {lit(label)} as section_object,
       {cols},
       iff(status = 'FAIL', 1, 0) as failing_rows,
       status,
       nullif(array_to_string(array_construct_compact(
           iff(rows_in_scope = 0, '0 rows in scope', null),
           {remarks}), '; '), '') as remarks
  from (
{indent(sql)}
  )"""


def main():
    for project, path in SOURCES:
        branches, tables = [], set()
        secs = list(sections(path))
        nums = [s[0] for s in secs]
        assert nums == list(range(1, len(secs) + 1)), f"{path.name}: gaps"
        for (no, label, sql), mem in zip(secs, member_buckets(len(secs))):
            if no == 1:
                names, b = type_check_branch(project, no, mem, label, sql)
                tables.update(names)
            else:
                b = table_branch(project, no, mem, label, sql)
            branches.append(b)
        out = DMT / f"DM-T2_{project}_SUMMARY.sql"
        out.write_text(render(project, len(secs), tables, branches))
        print(f"wrote {out.relative_to(HERE.parent)}: {len(secs)} sections, "
              f"{len(tables)} tables, {out.stat().st_size:,} bytes")


def render(project, total, tables, branches):
    values = ",\n".join(f"    ({lit(t)})" for t in sorted(tables))
    union = "\n\nunion all\n\n".join(branches)
    header = f"""/* =====================================================================================
   DM-T2  |  Load Audit - Hash Key Integrity (DV2.0, Travel LOB)  -- {project} SUMMARY RUN
   One query for all {total} sections of DM-T2_{project}.sql.

   GENERATED by validation/tools/build_dm_t2_travel_consolidated.py from
   DM-T2_{project}.sql -- regenerate, do not edit by hand.
   Section queries are verbatim; hub/link `with c` CTEs are inlined only.

   Run order (Snowflake worksheet, one statement at a time):
     1. Preflight -- must return 0 rows. Any row = table missing, statement 2 will fail.
     2. Main      -- one row per section, same numbering as the .docx Results summary.
                     Doc mapping: result -> "Result (Pass / Fail / NA)",
                     failing_rows -> "Rows with status = FAIL (count)", remarks -> "Remarks".
     3. Rollup    -- PASS / FAIL counts per member (RESULT_SCAN of statement 2;
                     run it immediately after statement 2).
   ===================================================================================== */


-- 1. Preflight: in-scope tables missing from BGIL_DATA_MODEL ---------------------------
select t.column1 as missing_table
  from (values
{values}
  ) t
 where t.column1 not in (
       select table_name
         from BAGIC_PREPROD_CURATED_DB.INFORMATION_SCHEMA.TABLES
        where table_schema = 'BGIL_DATA_MODEL')
 order by 1;


-- 2. Main: all sections ------------------------------------------------------------------
with r as (

"""
    footer = """

)
select section_no, project, member, table_type, section_object,
       initcap(status) as result, failing_rows, remarks,
       rows_in_scope, null_hkey, null_fk_hkeys, wrong_length_hkey,
       hkey_not_recomputable, collisions, null_hashdiff
  from r
 order by section_no;


-- 3. Rollup (run right after statement 2) -------------------------------------------------
select "MEMBER" as member,
       count(*) as sections,
       count_if("RESULT" = 'Pass') as pass,
       count_if("RESULT" = 'Fail') as fail,
       count_if("ROWS_IN_SCOPE" = 0) as zero_row_sections
  from table(result_scan(last_query_id()))
 group by rollup ("MEMBER")
 order by "MEMBER" nulls last;
"""
    return header + union + footer


if __name__ == "__main__":
    main()
