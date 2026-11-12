#!/usr/bin/env python3
"""
Build one summary Snowflake query PER PROJECT for travel DM-T2 (hash key
integrity) from the generated per-section files:

    travel/DM-T/DM-T2_OPUS.sql      (60 sections)
    travel/DM-T/DM-T2_MAXIMUS.sql   (229 sections)

Output per project: travel/DM-T/DM-T2_<PROJECT>_SATS_SUMMARY.sql and
        travel/DM-T/DM-T2_<PROJECT>_HUBS_LINKS_SUMMARY.sql

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


FQ = re.compile(r"BAGIC_PREPROD_CURATED_DB\.BGIL_DATA_MODEL\.([A-Z0-9_]+)")
NOT_COLUMNS = {"MD5_BINARY", "NULLIF", "UPPER", "TRIM", "CAST", "AS", "VARCHAR"}


def columns_used(sql):
    """(table, column) pairs a hub/link/satellite section reads."""
    table = FQ.search(sql).group(1)
    body = re.sub(r"'(?:[^']|'')*'", "''", FQ.sub(" ", sql))
    cols = set(re.findall(r"\b[A-Z][A-Z0-9_]*\b", body)) - NOT_COLUMNS
    return {(table, c) for c in cols}


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


# Each project is written as two runnable files so one bad table cannot block
# the other half: satellites only, and hubs + links (+ section 1, column types).
PARTS = [("SATS", {"satellite"}), ("HUBS_LINKS", {"columns", "hub", "link"})]

# Sections left out of the runnable query because the vault table does not
# have a column the section reads (compile error). Record them separately.
SKIP = {
    "MAXIMUS": {
        62: "SAT_AUG_LNK_ROLE_PROVIDER has no PARTY_ROLE_HKEY in the vault (keyed on PARTY_HKEY by the partner build)",
        174: "SAT_LNK_ROLE_AGENT has no PARTY_ROLE_HKEY in the vault (keyed on PARTY_HKEY by the health/partner builds)",
        175: "SAT_LNK_ROLE_CUSTOMER has no PARTY_ROLE_HKEY in the vault (keyed on PARTY_HKEY by the health/partner builds)",
        176: "SAT_LNK_ROLE_EMPLOYEE has no PARTY_ROLE_HKEY in the vault (keyed on PARTY_HKEY by the health/partner builds)",
    },
}


def main():
    for project, path in SOURCES:
        secs = list(sections(path))
        nums = [s[0] for s in secs]
        assert nums == list(range(1, len(secs) + 1)), f"{path.name}: gaps"
        built = []  # (kind, branch_sql, columns_used)
        skip = SKIP.get(project, {})
        for (no, label, sql), mem in zip(secs, member_buckets(len(secs))):
            if no in skip:
                continue
            if no == 1:
                _, b = type_check_branch(project, no, mem, label, sql)
                built.append(("columns", b, {}))
            else:
                kind = re.search(r"'(hub|link|satellite)' as table_type", sql).group(1)
                built.append((kind, table_branch(project, no, mem, label, sql),
                              {tc: no for tc in columns_used(sql)}))
        for part, kinds in PARTS:
            sel = [x for x in built if x[0] in kinds]
            cols = {}
            for _, _, c in sel:
                for tc, no in c.items():
                    cols.setdefault(tc, no)
            out = DMT / f"DM-T2_{project}_{part}_SUMMARY.sql"
            text = render(project, part, len(sel), cols, [b for _, b, _ in sel])
            skipped = [(no, why) for no, why in sorted(skip.items())
                       if (secs[no - 1][1].split()[0].lower() in kinds)
                       or (no == 1 and "columns" in kinds)]
            if skipped:
                note = "   NOT IN THIS QUERY (vault table lacks a column the section reads):\n" + "".join(
                    f"     section {no}: {why}\n" for no, why in skipped)
                text = text.replace("\n   Run order", "\n" + note + "\n   Run order", 1)
            out.write_text(text)
            print(f"wrote {out.relative_to(HERE.parent)}: {len(sel)} sections, "
                  f"{len({t for t, _ in cols})} tables, {out.stat().st_size:,} bytes")


def render(project, part, total, cols, branches):
    values = ",\n".join(f"    ({no}, {lit(t)}, {lit(c)})" for (t, c), no in sorted(cols.items(), key=lambda x: (x[1], x[0])))
    union = "\n\nunion all\n\n".join(branches)
    header = f"""/* =====================================================================================
   DM-T2  |  Load Audit - Hash Key Integrity (DV2.0, Travel LOB)  -- {project} {part} SUMMARY RUN
   One query for the {total} {part.replace("_", " + ").lower()} sections of DM-T2_{project}.sql
   (section_no matches the .docx).

   GENERATED by validation/tools/build_dm_t2_travel_consolidated.py from
   DM-T2_{project}.sql -- regenerate, do not edit by hand.
   Section queries are verbatim; hub/link `with c` CTEs are inlined only.

   Run order (Snowflake worksheet, one statement at a time):
     1. Preflight -- must return 0 rows. Any row = table/column missing, statement 2 will fail.
     2. Main      -- one row per section, same numbering as the .docx Results summary.
                     Doc mapping: result -> "Result (Pass / Fail / NA)",
                     failing_rows -> "Rows with status = FAIL (count)", remarks -> "Remarks".
     3. Rollup    -- PASS / FAIL counts per member (RESULT_SCAN of statement 2;
                     run it immediately after statement 2).
   ===================================================================================== */


-- 1. Preflight: tables / columns the sections read that are missing in BGIL_DATA_MODEL --
-- Must return 0 rows. Each row names the first section that would fail to compile.
select v.column1 as section_no, v.column2 as table_name, v.column3 as column_name,
       iff(t.table_name is null, 'TABLE MISSING', 'COLUMN MISSING') as problem
  from (values
{values}
  ) v
  left join (select distinct table_name
               from BAGIC_PREPROD_CURATED_DB.INFORMATION_SCHEMA.TABLES
              where table_schema = 'BGIL_DATA_MODEL') t
    on t.table_name = v.column2
  left join BAGIC_PREPROD_CURATED_DB.INFORMATION_SCHEMA.COLUMNS c
    on c.table_schema = 'BGIL_DATA_MODEL' and c.table_name = v.column2 and c.column_name = v.column3
 where c.column_name is null
 order by 1, 2, 3;


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
