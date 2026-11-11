# Findings: opus_health_dv_dbt runnable conversion

Project: `BGIL_DBT/opus_health_dv_dbt`. Source data: `scripts/conversion_report.json`, `write_report.json`, `stg_edit_report.json`, `reference_sweep.json`, `layout_findings.json`, `verification_results.json`.

Requirements covered: 2.8, 3.8, 4.8, 4.9, 4.10, 4.14, 5.4, 6.4, 6.5, 7.5, 7.7, 8.6, 9.3, 9.4.

Status: nothing here was compiled by dbt. Items marked (unverified) rest on offline checks only.

## 1. Layout

- No SQL comment under `models/**/*.sql` quotes the path `automate_dv/`. Remaining `automate_dv.` strings are package macro calls, not paths.
- Still emitting the old `automate_dv/` layout (not edited):
  - `generators/` (`v5_emit.py`, `v5_verify.py`, `v5_status.py`: docstrings and `ALLOWED_DIRS`).
  - `build_profile.json` (`structure_reference` text).
  - `build_artifacts/`.
- These generators and artifacts also still emit the old stitch SQL. Re-running them would overwrite this work.
- The README sections were not fully rewritten.

## 2. Configuration

- All 12 configured folders exist (missing = none).
- No unresolved `local:` path. `packages.yml` is byte-equal to the Partner project.
- Packages are vendored from the Partner project (`dbt_utils` 217 files, `automate_dv` 133 files), equal to Partner. `dbt deps` was not run. 350 vendored files are not git-ignored.
- 8 macros are byte-equal to Partner.
- Profile `opus_health_dbt` was found. `profiles.yml` holds placeholders only. The schema change to `BGIL_DATA_MODEL` is not exercised against a warehouse (unverified).

## 3. Stitched conversion

Counts:
- 34 consumer views, 612 macro parts, 646 stitched files in total (all distinct).
- 220 satellite entries across the 34 stitches. 31 stitches have multi-satellite entries.
- Class A 156. Class B 17 satellites / 197 parts. Class C 47. LINK 212. HUB 0. FALLBACK 0 (no Fallback_Stitch used).
- 34/34 stitches parsed, 0 failed.
- 254 stage consumers resolved. 1943 `ref()` checked, 0 unresolved. 0 missing column uses, 0 multi-satellite stages.
- Consumer views were compared with the HEAD originals: 0 column differences.
- Names: `stitch_vNN_*` are kept as consumer views over the parts.

Per-satellite class and key template are recorded in `scripts/conversion_report.json` (`stitches`). The multi-satellite list is in `multi_satellite`.

Class B (Literal_Key_Split): split per literal into 197 parts. The full list (file, original, literal, part) is in `conversion_report.json` (`literal_splits`). Examples:
- `LNK_ROLE_PROVIDER` -> `stitch_lnk_role_provider__provider`
- `POLICY_TENURE_SCHEDULE` -> `..__1`, `..__2`, `..__3`

Class C (47): data-driven child keys, for example `PROVIDER_TARIFF__SERVICE_CODE_CK`. The list is in `class_c`.

Macro behavior changes and risks:
- Composite keys come from the unchanged `stitch_incremental` macro (no hand-written parts).
- Grain differs when a table has more than one row per key. The macro keeps one row per table per key (unverified on data).
- Rows with NULL `inc_job_updated_at` are dropped by the macro window.
- `'|'` and `'~'` collision risk in composite keys. Values containing either separator could collide.
- Four class A or literal parts have differing key arity across branches: `stitch_common_address`, `stitch_fintxn_claim_payment`, `stitch_aug_risk_person_insured`, `stitch_fintxn_tax__service_tax`. `utr_no` is not coalesced.
- LNK_PARTY_ROLE links are inferred (no marker in the source).
- The watermark never narrows. Stage `RECORD_SOURCE` literals are `'!stitch_vNN_*'` and do not match `OPUS_%`. Each run reprocesses everything.
- Link target satellite is `lnk_<x>`. If the relation is missing, the run does a full reload.
- Link parts are suffixed `stitch_lk_<link>__vNN`, which removed 46 name collisions. 0 collisions remain.

## 4. Staging column

`inc_job_updated_at` added to `stg_health__*` models:
- Changed 104, already containing the column 12, skipped 0. Total 116/116 models contain `as inc_job_updated_at`.
- Skipped models: none.
- Unverified: all 104 changed models. There is no raw-columns export (O1), so the column choice was not checked against source columns.
- Already-present list (12): `ba_ccp_sub_mater_dtls`, `bjaz_policy_bases_extn`, `bjaz_policy_summary`, `bjaz_risk_identifiers_master`, `bjaz_risk_trans_dtls`, `bjaz_starpkg_cov_prem_mst`, `bjaz_starpkg_cover_dtls`, `bjaz_starpkg_cover_mst`, `bjaz_starpkg_pol_dtls`, `bjaz_versions_extn`, `ocp_interested_parties`, `ocp_policy_covers`.
- 12 models have a varchar `inc_job_updated_at`. 99 parts read them, so the watermark types are mixed. See `varchar_watermark_parts` in `conversion_report.json`.
- A `Z` suffix in the timestamp string is a risk for the `::timestamp_ntz` cast (unverified).

## 5. Out-of-scope compile mismatch

- dbt parse and compile did not run (see Verification). No parse or compile errors were observed, so out-of-scope models were not compiled. Zero errors means unchecked, not clean.
- Stage `RECORD_SOURCE` literals `'!stitch_vNN_*'` do not match `OPUS_%`. This is covered in section 3 (watermark never narrows).

## Verification

Ran:
- Offline checker `scripts/check_health_project.py`: 16/16 pass.
- `python -m pytest scripts/tests`: 111 passed, 0 failed. Three tests that read the original stitches from the working tree now load them from git HEAD.
- Frozen-file check (`test_p15_frozen.py`, 4 passed, plus git status): pass. No changes in `generators/`, `build_artifacts/`, the Partner project, or other BGIL_DBT projects.

Blocked:
- `dbt parse --profiles-dir .`: BLOCKED. dbt is not installed.
- `dbt compile --select tag:stitch tag:stg1 ...`: BLOCKED. dbt is not installed and there are no Snowflake credentials.

Not run by design: `dbt run`, `dbt deps`, any Snowflake write.

Still to run on Snowflake after a successful run (not done): equivalence queries comparing each consumer view with the original stitch output (row counts and key sets per stitch, column values for sampled keys). Also run `dbt parse` and `dbt compile` on a machine with dbt-snowflake and Snowflake access before release.

## Recorded decisions

- Plan approved.
- Packages vendored from Partner. No `dbt deps`.
- `stitch_vNN_*` names kept as consumer views.
- Composite-key approach via the unchanged `stitch_incremental`. No hand-written parts.
- Class B split per literal (197 parts).
- Link parts suffixed `stitch_lk_<link>__vNN` to remove 46 collisions.
- O1: no raw-columns export. 104 stg models edited as unverified.
- O5: link `target_sat` = `lnk_<x>`. Full reload if the relation is missing.
