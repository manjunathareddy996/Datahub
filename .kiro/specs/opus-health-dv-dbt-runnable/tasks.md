# Implementation Plan: opus-health-dv-dbt-runnable

## Overview

This plan makes `BGIL_DBT/opus_health_dv_dbt` a runnable dbt project that mirrors `BGIL_DBT/opus_partner_dv_dbt`. Paths are relative to `BGIL_DBT/opus_health_dv_dbt` unless stated. Scripts and tests are written in Python (Hypothesis for property tests), as named in the design.

Every satellite and every link is built by the unchanged `stitch_incremental` macro. Where the identity is more than one column (data-driven child key, composite business key, link with several legs), `unique_key` is a Surrogate_Key and each source `key_column` is a Composite_Key_Expression or Link_Key_Expression. The key parts come back as Key_Part_Columns. Parts are named `stitch_<sat>`, `stitch_<sat>__<ck_slug>` (class B), `stitch_lk_<link>` and `stitch_hk_<hub>`. Each `stitch_vNN_*` keeps its name and becomes a thin consumer view that `union all`s the parts. A Fallback_Stitch (`stitch_fb_vNN_<topic>`, verbatim original SQL) exists only as a last resort after a recorded finding. No stitched model is renamed and no stage model is repointed. Packages are vendored from the Partner_Project and `dbt deps` is not run.

Order of work:

1. Plan approval.
2. Baseline snapshot.
3. `git mv` layout move, then `dbt_project.yml`.
4. Scaffolding: macros, profiles, partner `packages.yml` plus vendored `dbt_packages`, folders, `.gitignore`.
5. Offline checker.
6. Converter script with `--plan`.
7. Review checkpoint: O1 (raw-columns export), O3 (class B volume), O5 (composite-key equivalence).
8. Staging `inc_job_updated_at` edit with its own count check.
9. Stitched rewrites.
10. Reference updates.
11. Verification.
12. Findings report, last.

No file in the Health_Project changes until task 1 is approved. `generators/`, `build_artifacts/` and out-of-scope models are never edited. The only change to any `stg_health__*` model is the one-line `inc_job_updated_at` insertion in task 9.

## Tasks

- [x] 1. Checkpoint - Plan approval gate
  - Present this plan to the user and get explicit approval before any change to the Health_Project.
  - Make no file change in the Health_Project until the user approves.
  - Record the approval in the notes for the Findings_Report.
  - _Requirements: 8.1, 8.2_

- [x] 2. Baseline snapshot
  - [x] 2.1 Create and run the pre-move baseline snapshot script
    - Add `scripts/snapshot_manifest.py` that writes a JSON manifest (path to SHA-256) of `models/`, `generators/`, `build_artifacts/` and `docs/`
    - Run it once before the move and store the output at `scripts/baseline_manifest.json`
    - Check: manifest entry count equals the file count under `models/`, `generators/`, `build_artifacts/` and `docs/`; manifest lists the 116 `stg_health__*` models and the 34 `stitch_v*` models
    - _Requirements: 1.2, 5.5, 6.1, 6.2, 8.3_

- [x] 3. Layout move and project configuration
  - [x] 3.1 Move `models/automate_dv` to `models/raw_vault` with `git mv`
    - Run `git mv models/automate_dv models/raw_vault` so file history is kept
    - Recreate `models/raw_vault/standard/references/.gitkeep` so the `references` config key resolves
    - Check: `models/automate_dv` does not exist, and every baseline path maps to the new prefix
    - _Requirements: 1.1, 1.2, 1.3, 1.5, 2.8, 8.3_

  - [x] 3.2 Rewrite `dbt_project.yml` from the Skill and Partner block
    - Set `name: 'opus_health_dv_dbt'` and `profile: 'opus_health_dbt'`; drop `config-version`
    - Add the path keys, `clean-targets` and the run-log pre/post hooks with Partner values
    - Add the `staging` config (`view`, tag `stg1`, schema `BGIL_DATA_MODEL`)
    - Key `models:` by the project name and `raw_vault`, with the folder, materialization, tag and `on_schema_change` map from Partner for `standard` (`stitched`, `staging`, `hubs`, `links`, `satellites`, `references`) and `augmented` (`staging`, `satellites`)
    - Keep `health_raw_database` and `health_raw_schema` vars; drop the per-layer schemas
    - Check: YAML loads, no `automate_dv/` path remains, and the file equals Partner after name substitution apart from the Health vars
    - _Requirements: 1.4, 2.1, 2.2, 2.3, 2.4, 2.5, 2.6, 2.7, 8.3, 8.4_

  - [x]* 3.3 Write property test for the layout move
    - Add `scripts/tests/test_p01_layout.py` using the baseline manifest
    - **Property 1: Layout move preserves every model**
    - **Validates: Requirements 1.2, 1.3**

- [x] 4. Scaffolding: macros, profiles, packages, folders
  - [x] 4.1 Copy Partner macros
    - Copy all eight macros from `opus_partner_dv_dbt/macros/` into `macros/` byte for byte, including `stitch_incremental.sql` and `generate_schema_name.sql`
    - Check: SHA-256 of each copy equals the Partner file
    - _Requirements: 3.1, 3.2, 8.3_

  - [x] 4.2 Create `profiles.yml`
    - Profile key `opus_health_dbt` with `dev` and `prod` outputs following the Partner structure, placeholder credentials as in Partner
    - Check: YAML loads and the profile key equals `profile:` in `dbt_project.yml`
    - _Requirements: 3.3, 8.3_

  - [x] 4.3 Copy Partner `packages.yml` and vendor `dbt_packages`
    - Replace `packages.yml` with a byte copy of the Partner file (`local:` entries)
    - Copy `dbt_packages/dbt_utils` and `dbt_packages/automate_dv` from Partner with identical content
    - Do not run `dbt deps`
    - Check: both `local:` paths exist, contain `dbt_project.yml`, and every file is byte-equal to Partner
    - _Requirements: 3.5, 3.6, 3.7, 3.8, 8.3_

  - [x] 4.4 Create empty folders and ignore file
    - Add `analyses/`, `seeds/`, `snapshots/` and `tests/` each with `.gitkeep`
    - Add `.gitignore` with the Partner entries (`target`, `logs` and the others in Partner `gitignore.txt`); append if one exists; make sure no entry matches `dbt_packages`
    - Check: folders exist, ignore entries match Partner, and `git check-ignore` reports vendored sample files as not ignored
    - _Requirements: 3.4, 3.9, 3.10, 8.3_

- [x] 5. Offline checker
  - [x] 5.1 Write the offline checker, scaffolding checks
    - Add `scripts/check_health_project.py` (non-zero exit on failure)
    - Checks: YAML validity of `dbt_project.yml`, `profiles.yml` and `packages.yml`; profile name present; configured folders exist under `models`; macro and vendored package byte equality with Partner; `.gitignore` entries; `git check-ignore` on vendored samples
    - Output the missing configured folders as a list for the Findings_Report
    - _Requirements: 2.8, 3.1, 3.2, 3.3, 3.7, 3.8, 3.9, 3.10, 9.3_

  - [x]* 5.2 Write property test for missing configured folders
    - Add `scripts/tests/test_p20_folders.py`
    - **Property 20: Missing configured folders are recorded**
    - **Validates: Requirements 2.8**

  - [x]* 5.3 Write unit tests for scaffolding
    - Add `scripts/tests/test_scaffolding.py`: macro byte equality, `packages.yml` and vendored package equality, profile name match, `dbt_project.yml` vs Partner after substitution, ignore entries
    - _Requirements: 2.1, 2.2, 2.3, 3.2, 3.3, 3.5, 3.6, 3.9_

- [x] 6. Checkpoint - Scaffolding complete
  - Run the offline checker and `scripts/tests`. Ensure all tests pass, ask the user if questions arise.

- [x] 7. Converter script with plan mode
  - [x] 7.1 Implement data models and the stitch parser
    - Add `scripts/convert_stitches.py` with the `KeyPart`, `KeySpec`, `Branch`, `SatSpec` and `Finding` dataclasses and `parse(text)`
    - Parse `-- branch N: <TABLE>` comments, key expressions, column aliases, `__PREC` values, fed-satellite list, final-select partition clauses, literal and data-driven child keys, link-leg branches (two or more key columns in one row) and header comments
    - On an unparsable stitch, write a report entry, skip it, write no partial output, and return non-zero at the end
    - Do not edit or import `generators/`
    - _Requirements: 4.3, 4.4, 4.5, 4.12, 6.1_

  - [x] 7.2 Implement satellite classification and composite key rendering
    - Add `classify(spec)` returning class A, B, C, LINK or HUB per the design table; a satellite with any data-driven child key branch or a composite business key is class C as a whole, and its literal branches join the same call
    - Add the single function `render_key_column(parts, sep)` used for every branch of a satellite: fixed part order, separator `'|'`, `coalesce(<expr>, '~')` for nullable child keys, quoted unwrapped literals, `trim(to_varchar(x))` for non-stg1 expressions, required legs concatenated plain and optional legs coalesced
    - Add the Key_Part_Column builder that returns raw (non-coalesced) key parts as `{src, tgt}` columns
    - Add a value-profile hook for `'|'` and `'~'` collisions that switches a satellite's separator for all branches at once and records it
    - Record a Finding (file, branch, construct) when no consistent Composite_Key_Expression can be produced
    - _Requirements: 4.9, 4.10, 4.11, 4.12, 4.14_

  - [x] 7.3 Implement the renderers
    - `render_part(spec)`: macro part with `config(materialized='view')`, `depends_on` comment lines, `sources`, `output_columns` (payload then Key_Part_Columns), `coalesce_rules` ordered by `__PREC` then branch number, and one `stitch_incremental(...)` call; `source_tag = OPUS_<TABLE>`, `ldts_column = 'inc_job_updated_at'`, `unique_key` as the hub key (class A, B) or Surrogate_Key (`<sat>_pk`, `<link>_lk`, `<hub>` key for hub-only), `target_sat` as the satellite, link or hub name in lower case; Skill whitespace rules (`%}` on the last `set`, no wrapping `WITH`)
    - Part names: `stitch_<sat>`, `stitch_<sat>__<ck_slug>` (class B, literal as a `{src, tgt}` source column), `stitch_lk_<link>`, `stitch_hk_<hub>`
    - `render_view(stitch, parts)`: consumer view with the original name, original header comments, original column list and order, `cast(null as varchar)` padding, BK, CK and link legs taken from Key_Part_Columns, payload from its single owner part, and a `union all` of the parts
    - `fallback_stitch(text, finding)`: verbatim original SQL as `stitch_fb_vNN_<topic>`, produced only for a satellite with a recorded finding and unioned into the consumer view for that satellite's columns
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 4.9, 4.10, 4.11, 4.12, 4.13, 4.15, 4.17, 4.19_

  - [x] 7.4 Implement CLI modes and the conversion report
    - Add `--plan` (counts only, no model files written), `--write` (never overwrites existing output without `--force`) and `--report <path>`
    - `--plan` prints per stitch: satellites fed, class A, B, C, link and hub-only counts, parts to create, Fallback_Stitch count (expected zero), and the total file count; it also prints the class B total used for O3
    - Report JSON holds: multi-satellite entries, class of each satellite, key template per satellite, optional legs per link, Literal_Key_Split entries (original name, part names, literal), Fallback_Stitch list (file, branch, construct), consumer map (stage model, `source_model`, columns used, columns provided, single-satellite flag), watermark precheck table, and the list of parts that read the 12 varchar `inc_job_updated_at` models
    - _Requirements: 4.8, 4.14, 4.16, 4.20, 5.3, 5.4, 8.1_

  - [x]* 7.5 Write property test for macro part structure
    - Add `scripts/tests/test_p02_structure.py` with Hypothesis generators for synthetic original stitches
    - **Property 2: Macro parts have the required structure**
    - **Validates: Requirements 4.2**

  - [x]* 7.6 Write property test for satellite and link coverage
    - Add `scripts/tests/test_p03_coverage.py`
    - **Property 3: Every satellite and link is covered exactly once**
    - **Validates: Requirements 4.1, 4.6, 4.11, 4.16, 4.17**

  - [x]* 7.7 Write property test for source reproduction
    - Add `scripts/tests/test_p04_sources.py`
    - **Property 4: Sources reproduce the original branches**
    - **Validates: Requirements 4.3**

  - [x]* 7.8 Write property test for composite key format
    - Add `scripts/tests/test_p05_key_format.py` covering mixed literal and data-driven branches, NULL child keys and link keys
    - **Property 5: Composite keys use one normalised format in every branch**
    - **Validates: Requirements 4.9, 4.10, 4.11, 4.12**

  - [x]* 7.9 Write property test for key part round trip
    - Add `scripts/tests/test_p06_key_parts.py` with a reference evaluator of the composite key
    - **Property 6: Key parts survive the composite key**
    - **Validates: Requirements 4.9, 4.12**

  - [x]* 7.10 Write property test for output columns
    - Add `scripts/tests/test_p07_output_columns.py`
    - **Property 7: Output columns equal the satellite payload plus key parts**
    - **Validates: Requirements 4.4, 4.9**

  - [x]* 7.11 Write property test for coalesce order
    - Add `scripts/tests/test_p08_coalesce.py`
    - **Property 8: Coalesce order follows source precedence**
    - **Validates: Requirements 4.5**

  - [x]* 7.12 Write property test for source tags
    - Add `scripts/tests/test_p09_source_tags.py`
    - **Property 9: Source tags follow the system-prefix form**
    - **Validates: Requirements 4.7**

  - [x]* 7.13 Write property test for consumer views
    - Add `scripts/tests/test_p10_consumer_view.py` with a reference evaluator of the original window semantics and the macro semantics
    - **Property 10: Consumer views keep the column contract and the consumed semantics**
    - **Validates: Requirements 4.1, 4.9, 4.11, 4.12, 5.3**

  - [x]* 7.14 Write property test for grain difference
    - Add `scripts/tests/test_p11_grain.py`
    - **Property 11: Grain difference is confined to multi-row keys**
    - **Validates: Requirements 4.3, 4.9**

  - [x]* 7.15 Write property test for Fallback_Stitch
    - Add `scripts/tests/test_p12_fallback.py`
    - **Property 12: Fallback_Stitch is a verbatim last resort**
    - **Validates: Requirements 4.14, 4.15, 4.20**

  - [x]* 7.16 Write property test for legacy merge tokens
    - Add `scripts/tests/test_p13_legacy_tokens.py`
    - **Property 13: Legacy merge tokens appear only where allowed**
    - **Validates: Requirements 4.18, 4.19**

  - [x]* 7.17 Write property test for findings completeness
    - Add `scripts/tests/test_p14_findings.py`
    - **Property 14: Findings are complete**
    - **Validates: Requirements 4.8, 4.14, 4.16, 4.20, 5.4**

- [x] 8. Checkpoint - Plan-mode review (O1, O3, O5)
  - Run `python scripts/convert_stitches.py --plan --report <path>` and show the user the output. No model files are written in this step.
  - O1: ask the user to supply the raw-columns export (`select table_name, column_name, data_type from RAW.INFORMATION_SCHEMA.COLUMNS where table_schema = 'HEALTH'`) for `--raw-columns`, or to accept the Skill default (add the column to every model that lacks it and mark each as unverified).
  - O3: show the exact class B part count and ask whether to convert class B per literal or merge class B into class C (one composite-key call per satellite).
  - O5: ask the user to confirm how composite-key equivalence is judged (per satellite and key, `(bk, ck, payload tuple)` against the original; distinct surrogate count against distinct `(bk, ck)` count), the accepted differences (one row per table per key, NULL watermark rows, `'~'` and `'|'` collisions), and whether a link or hub-only part may use a non-satellite `target_sat`.
  - Record the three decisions. Do not start task 9 until all three are answered.
  - _Requirements: 4.9, 4.10, 4.12, 7.5, 8.1, 8.2_

- [x] 9. Staging column edit
  - [x] 9.1 Implement `scripts/add_inc_job_updated_at.py`
    - Add pure `edit_stg(text, evidence) -> (text', StgEdit)`: skip with `already` if `as inc_job_updated_at` exists outside comments; skip with `unparsable` unless the select list is one `select` line, single-line `<expr> as <alias>` items and one `from {{ source(` line
    - Insert one line before the anchor (first item whose raw column sorts after `INC_JOB_UPDATED_AT`, else the last item): `"INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at,` with the anchor's indentation and the file's newline style
    - Read and write bytes so BOM and newline style are preserved; leave a model unchanged and record it when `--raw-columns` shows its table lacks the column
    - CLI: `--plan` (default, writes nothing), `--write`, `--raw-columns <csv>`, `--z-prefix-tables a,b` (regexp form), `--report <path>`
    - Report lists `changed`, `already`, `skipped` (reason) and `unverified` models and the three counts
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.7_

  - [x] 9.2 Run the staging edit and check the counts
    - Run `--plan`, review the report, then `--write` with the O1 outcome applied
    - Check (file level): count of `stg_health__*` models containing `as inc_job_updated_at` equals `changed + already`; skipped models are byte-identical to the baseline; for every changed model, removing the inserted line restores the baseline bytes
    - Store the report for the Findings_Report staging column category with the changed, already and skipped counts
    - _Requirements: 6.3, 7.1, 7.2, 7.3, 7.5, 7.6, 7.7, 8.3, 8.5_

  - [x]* 9.3 Write property test for the minimal insertion
    - Add `scripts/tests/test_p17_stg_insert.py` with LF and CRLF, varied indentation and alias shapes
    - **Property 17: Staging edit is a minimal one-line insertion**
    - **Validates: Requirements 6.3, 7.1, 7.3, 7.4**

  - [x]* 9.4 Write property test for idempotence
    - Add `scripts/tests/test_p18_stg_idempotent.py`
    - **Property 18: Staging edit is idempotent and respects existing columns**
    - **Validates: Requirements 7.2, 7.6**

  - [x]* 9.5 Write property test for skip safety and counts
    - Add `scripts/tests/test_p19_stg_skips.py`
    - **Property 19: Unusable models are untouched and counts add up**
    - **Validates: Requirements 7.5, 7.7**

- [x] 10. Stitched rewrites
  - [x] 10.1 Write parts and consumer views
    - Run `convert_stitches.py --write --force --report <path>` with the O3 decision applied; output goes into `models/raw_vault/standard/stitched/`
    - Each `stitch_vNN_*` file keeps its name and becomes a consumer view; macro parts and any Fallback_Stitch are new files in the same folder
    - Check: file count equals the approved plan count; every macro part has one `stitch_incremental(` call; all 34 `stitch_vNN_*` names exist; no `stitch_vNN_*` is renamed or removed
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7, 4.9, 4.10, 4.11, 4.12, 4.17, 4.19, 8.3_

  - [x] 10.2 Check key format, legacy tokens and findings
    - Check: `union all` appears only in consumer views and Fallback_Stitches; `__PREC`, `__RID` and `first_value` appear only in Fallback_Stitches; the stitch_incremental macro file is still byte-equal to Partner
    - Check: every `key_column` of one satellite normalises to one template; every Key_Part_Column named in a consumer view exists in `output_columns` of its part
    - Check: each multi-satellite stitch, Literal_Key_Split and Fallback_Stitch (file, branch, construct) has an entry in the conversion report
    - _Requirements: 4.8, 4.10, 4.13, 4.14, 4.16, 4.18, 4.20, 8.3_

  - [x]* 10.3 Write unit tests for sample converted models
    - Add `scripts/tests/test_converted_samples.py` comparing one class A part, one class B part, one class C part with mixed literal and data-driven branches, one link part and one consumer view against hand-checked expected text
    - _Requirements: 4.2, 4.3, 4.5, 4.7, 4.9, 4.11, 4.12_

- [x] 11. Reference updates
  - [x] 11.1 Update README and documentation paths
    - Replace `models/automate_dv` with `models/raw_vault` in `README.md`
    - Scan `docs/BUILDER_ASKS_*.md` for path hits and update them
    - Do not edit SQL comments in moved models; list them for the Findings_Report (layout)
    - Do not touch `generators/` or `build_artifacts/`
    - Check: no `automate_dv/` path remains in `dbt_project.yml`, README or docs
    - _Requirements: 1.4, 5.2, 5.5, 8.3_

  - [x] 11.2 Run the reference sweep
    - Extend the offline checker to resolve every `ref()` target in `models/` and every stage `source_model` string
    - Use the consumer map to write unresolved names and missing or multi-satellite column uses (stage model, name or column, stitched model) to the report
    - Leave stage SQL unchanged
    - _Requirements: 5.1, 5.3, 5.4, 6.2, 8.3_

  - [x]* 11.3 Write property test for reference resolution
    - Add `scripts/tests/test_p16_refs.py`
    - **Property 16: References resolve**
    - **Validates: Requirements 5.1, 5.3**

  - [x]* 11.4 Write property test for unchanged files
    - Add `scripts/tests/test_p15_frozen.py` comparing current hashes to `baseline_manifest.json` (moved files at the new path) and `macros/stitch_incremental.sql` to the Partner copy
    - **Property 15: Unchanged files stay byte-identical**
    - **Validates: Requirements 3.2, 4.13, 5.3, 5.5, 6.1, 6.2**

- [x] 12. Verification
  - [x] 12.1 Extend the offline checker for converted and staging models
    - Add checks: one `stitch_incremental(` call with `sources`, `output_columns`, `coalesce_rules`, `unique_key` and `target_sat`; balanced Jinja delimiters; `source_tag` regex `^OPUS_[A-Z0-9_]+$`; legacy tokens only where allowed; key-format template per satellite; each consumer view has the original column list; stg model count containing `inc_job_updated_at`; watermark precheck table
    - _Requirements: 4.2, 4.7, 4.10, 4.18, 7.6, 8.3, 8.5, 9.3_

  - [x] 12.2 Run offline checks and dbt checks
    - Run `python scripts/check_health_project.py` and the tests under `scripts/tests`
    - Run `dbt parse` and `dbt compile --select tag:stitch tag:stg1` in the Health_Project when dbt and Snowflake credentials are available; use `--vars` with `from_date` to skip the watermark query where possible
    - Split errors into scaffolding, stitched and staging files (must be zero) and out-of-scope files (record model name, message, suggested cause; leave the model unchanged)
    - If a dbt check cannot run, record it as blocked with the reason and rely on the offline results
    - _Requirements: 6.4, 9.1, 9.2, 9.3, 9.4_

  - [x] 12.3 Confirm unchanged files
    - Run the baseline comparison for `generators/`, `build_artifacts/` and out-of-scope layer models
    - _Requirements: 5.5, 6.1, 6.2_

- [x] 13. Checkpoint - Verification complete
  - Ensure all tests pass, ask the user if questions arise.

- [x] 14. Findings report (last)
  - [x] 14.1 Write `findings.md` in the spec folder after the final Compile_Check
    - Use five headings in this order: layout, configuration, stitched conversion, staging column, out-of-scope compile mismatch
    - Layout: SQL comments quoting `automate_dv/`; `generators/` and `build_artifacts/` still emitting the old layout
    - Configuration: missing configured folders, any unresolved `local:` path, schema change to `BGIL_DATA_MODEL`
    - Stitched conversion: multi-satellite entries, class of each satellite, key template per satellite, Literal_Key_Split entries (original, parts, literal), Fallback_Stitch list as last resort (file, branch, construct), macro behavior changes (one row per table per key, NULL watermark rows, trim, `'~'` and `'|'` collisions, watermark never narrowing), stage columns missing or spread over several satellites
    - Staging column: counts changed, already containing the column, and skipped; skipped models with cause; unverified models; the 12 varchar `inc_job_updated_at` models read by parts; any `Z ` prefix risk
    - Out-of-scope: parse and compile errors, stage `RECORD_SOURCE` literals not matching `OPUS_%`
    - Add a verification section stating which checks ran, which were blocked and the result of each, and the post-run equivalence queries still to run on Snowflake
    - Include the recorded O1, O3 and O5 decisions
    - _Requirements: 2.8, 3.8, 4.8, 4.14, 4.15, 4.16, 4.20, 5.4, 6.4, 6.5, 7.5, 7.7, 8.6, 9.3, 9.4_

## Notes

- Tasks marked with `*` are optional and can be skipped for a faster MVP.
- Checkpoint 1 gates every change to the Health_Project; checkpoint 8 gates the staging edit and the stitched rewrites (no staging or model file is written before it).
- Task 2.1 must run before task 3.1 so the baseline reflects the pre-move state.
- Task 9 (staging edit) runs before task 10 because macro parts read `inc_job_updated_at` and the converter watermark precheck reads the final stg files.
- The Findings_Report is produced after the final Compile_Check.
- Property numbers follow the design: P1 layout, P2 to P9 macro parts and keys, P10 and P11 consumer views and grain, P12 Fallback_Stitch, P13 legacy tokens, P14 findings, P15 frozen files, P16 references, P17 to P19 staging, P20 folders.
- This workflow only produces planning artifacts. Implementation starts when the user asks for it.

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["2.1"] },
    { "id": 1, "tasks": ["3.1"] },
    { "id": 2, "tasks": ["3.2"] },
    { "id": 3, "tasks": ["4.1", "4.2", "4.3", "4.4"] },
    { "id": 4, "tasks": ["3.3", "5.1"] },
    { "id": 5, "tasks": ["5.2", "5.3", "7.1"] },
    { "id": 6, "tasks": ["7.2"] },
    { "id": 7, "tasks": ["7.3"] },
    { "id": 8, "tasks": ["7.4"] },
    { "id": 9, "tasks": ["7.5", "7.6", "7.7", "7.8", "7.9", "7.10", "7.11", "7.12", "7.13", "7.14", "7.15", "7.16", "7.17", "9.1"] },
    { "id": 10, "tasks": ["9.2", "9.3", "9.4", "9.5"] },
    { "id": 11, "tasks": ["10.1"] },
    { "id": 12, "tasks": ["10.2", "10.3"] },
    { "id": 13, "tasks": ["11.1"] },
    { "id": 14, "tasks": ["11.2"] },
    { "id": 15, "tasks": ["11.3", "11.4", "12.1"] },
    { "id": 16, "tasks": ["12.2"] },
    { "id": 17, "tasks": ["12.3"] },
    { "id": 18, "tasks": ["14.1"] }
  ]
}
```
