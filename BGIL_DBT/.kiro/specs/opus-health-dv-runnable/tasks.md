# Implementation Plan: opus-health-dv-runnable

## Overview

Convert the feature design into incremental, code-focused tasks that (1) add runnable
scaffolding to `opus_health_dv_dbt` adapted from `opus_partner_dv_dbt`, and (2) reshape
the 46 numbered central-view stitched models into the partner stitched form, calling the
extended `stitch_incremental_hcon` macro so the central view's inline hub business keys are
**preserved** (Option C).

Each task writes or edits files and ends wired into the project: scaffolding is built
(including the new `stitch_incremental_hcon` macro) and proven with `dbt parse` before any
model is reshaped, then the stitched layer is reshaped in numeric batches and proven with
`dbt compile`, and finally an **end-to-end** compile (stitched plus the downstream
`stage/`, `hub_feeds/`, `vault/` layers that consume hub keys) proves the hub-key
preservation closed the compile gap, and the scope-boundary facts are compiled into a
single follow-up findings document.

`generators/` is never touched (the new macro is hand-authored outside the generator's
output). Downstream layers (`stage/`, `hub_feeds/`, `vault/`) are left unmodified; under
Option C they keep compiling because the hub keys are preserved.

All paths are under `BGIL_DBT\opus_health_dv_dbt\` unless stated otherwise. The partner
template source is `BGIL_DBT\opus_partner_dv_dbt\`.

## Tasks

- [x] 1. Vendor dependencies, create standard dbt directories, add the extended macro
  - [x] 1.1 Copy `dbt_packages/` verbatim from partner
    - Copy the whole vendored tree (`dbt_utils`, `automate_dv`) from
      `opus_partner_dv_dbt\dbt_packages\` into `opus_health_dv_dbt\dbt_packages\`
    - No edits — the packages carry no project-specific values
    - _Requirements: 2.1_

  - [x] 1.2 Copy `macros/` verbatim from partner
    - Copy all eight macros into `opus_health_dv_dbt\macros\`: `stitch_incremental.sql`,
      `sat_multi_source.sql`, `ma_sat_multi_source.sql`, `hash.sql`,
      `location_address_key.sql`, `watermark.sql`, `get_run_date.sql`,
      `generate_schema_name.sql` (plus `.gitkeep` if present)
    - No edits — macros resolve relations via `this.database`/`this.schema` at run time;
      leave `stitch_incremental.sql` byte-unchanged (it is the template for the new macro)
    - _Requirements: 2.2, 2.3_

  - [x] 1.3 Author the extended `macros/stitch_incremental_hcon.sql`
    - Create `opus_health_dv_dbt\macros\stitch_incremental_hcon.sql` (macro name
      `stitch_incremental_hcon`) as a **copy of the vendored `stitch_incremental.sql`**,
      extended with a new `hub_keys` parameter and per-source `hub_key_columns` threading;
      do NOT edit the original `stitch_incremental.sql` and do NOT touch `generators/`
    - Per-source CTE: in addition to the existing `key_column`/payload/`ldts_column`
      selects, also select each `hub_key_columns[]` entry as
      `{{ hk.src_expr }} AS {{ hk.tgt }}` so every alias-local hub-key column is available
    - `final` CTE: after the payload-column COALESCE block and before `record_source`,
      emit one column per `hub_keys[]` entry as `{{ hk.expr }} AS {{ hk.name }}`
    - Terminal `SELECT`: list `unique_key`, then each `output_columns` entry, then each
      `hub_keys[].name`, then `record_source`, then `inc_job_updated_at`
    - _Requirements: 2.2, 2.3 (macros present). Supports Req 3 reshape and Req 4.2 — hub
      keys are now preserved, not dropped_

  - [x] 1.4 Create the standard empty dbt directories
    - Create `analyses/`, `seeds/`, `snapshots/`, `tests/`, `docs/`, each with a
      `.gitkeep` if the partner's equivalents carry one
    - _Requirements: 2.4_

- [x] 2. Author project configuration files
  - [x] 2.1 Author `dbt_project.yml` adapted from partner
    - Set `name: opus_health_dv_dbt` and `profile: opus_health_dbt`
    - Rename vars to `health_raw_database` / `health_raw_schema`, values from the Health
      build inputs; copy path/target/clean-target keys unchanged from partner
    - Build the `models:` map keyed to Health's own flat directory names
      (`staging`, `stitched`, `stage`, `hub_feeds`, `vault.{hubs,links,satellites}`,
      `augmented`, `assertions`) using the partner's canonical `+materialized`/`+tags`
      form (incremental layers also get `+on_schema_change: append_new_columns`)
    - Retain or drop the partner pre/post-hook run-log per the Health build inputs; record
      the choice for the findings doc
    - _Requirements: 1.1, 1.2, 1.3, 1.4_

  - [x] 2.2 Author `packages.yml`
    - Declare the two local packages `dbt_packages/dbt_utils` and `dbt_packages/automate_dv`
      matching partner
    - _Requirements: 1.5_

  - [x] 2.3 Author `profiles.yml`
    - Define profile `opus_health_dbt` with `dev` and `prod` Snowflake outputs adapted
      from partner
    - Keep `account: "_"` and `user: "_"` placeholders in the `dev` output
    - Carry partner role/warehouse/database unless the Health build inputs specify
      different Snowflake targets (record substitutions for the findings doc)
    - _Requirements: 1.6, 1.7, 4.5_

  - [x] 2.4 Author `models/staging/_health__sources.yml`
    - Harvest every `(run, RAW_TABLE)` pair by scanning each `stg_*.sql` `source('<run>','<RAW>')`
      call and its `source run :` header
    - Emit one `source` per run (`opus_health_legacy_v4`, `opus_health_v2`,
      `opus_health_delta3`); `database`/`schema` from `var('health_raw_database','RAW')` /
      `var('health_raw_schema','GG_DWHSTAGE')`
    - List every requested RAW table under its owning run; invent none, drop none
    - _Requirements: 2.5_

- [x] 3. Checkpoint — verify scaffolding parses
  - Run `dbt parse`; confirm profile `opus_health_dbt` resolves, both local packages
    resolve from the vendored tree, the macros are discoverable (the eight copied macros
    plus the new `stitch_incremental_hcon`), and every `(run, RAW_TABLE)` the staging
    models request resolves against `_health__sources.yml`
  - Ensure parse succeeds; ask the user if questions arise
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 2.1, 2.2, 2.3, 2.4, 2.5_

- [x] 4. Establish the per-file stitched reshape procedure
  - [x] 4.1 Document and apply the repeatable reshape procedure on one pilot file
    - Pick `stitch_01_policy__policy_header.sql`; capture spine hub, contributing `stg_*`
      models, the satellite fed, and the documented merge order from the header
    - Read the matching `stage_NN_*` model for the hashdiff column list (`output_columns`)
      and the satellite name (`target_sat`)
    - Derive `sources[]` (`model`, `alias t0..tN`, `key_column`, `ldts_column='inc_job_updated_at'`,
      `columns[{src,tgt}]`, `source_tag`), `coalesce_rules`, and `output_columns`
    - Capture each source's inline hub-key expressions into `sources[].hub_key_columns`
      as `[{src_expr, tgt}]`, transcribing the raw SQL verbatim from that `tN` CTE: bare
      `nullif(trim(...))`, prefix literals (`'LOANACC:'`, `'PRODUCT:'`, `'TXN:'`, ...),
      and `md5(normalise(upper(...)))` hashes; `tgt` is the alias-local hub-key column name
    - Transcribe the central view's final-SELECT hub-key columns into `hub_keys`
      `[{name, expr}]`: family 1 (merged-spine BK `COALESCE(...)` over `alias.tgt`) and
      family 2 (auxiliary `TN__HUB_*_BK__*` single `alias.tgt` references), verbatim
    - Set each `source_tag` to `OPUS_HEALTH_<RUN>_<RAWTABLE>` from the staging model's run
    - Emit the thin body: `config(materialized='view')` + four Jinja vars
      (`sources`, `output_columns`, `coalesce_rules`, `hub_keys`) + one
      `stitch_incremental_hcon(..., hub_keys=hub_keys, unique_key='parent_bk', target_sat='sat_<name>')`
      call (call `stitch_incremental_hcon`, **not** `stitch_incremental`)
    - Fix the shared invariants: `unique_key='parent_bk'`, `ldts_column='inc_job_updated_at'`,
      lower-cased `output_columns`/`target_sat`, aliases `t0..tN` preserved
    - Run the per-file validation (every output column appears in a coalesce rule; every
      coalesce alias exists in sources; every `alias.tgt` referenced by a `hub_keys[].expr`
      is declared as a `hub_key_columns[].tgt` on that alias's source; every source has a
      non-empty `<SYSTEM>_<TABLE>` tag; `target_sat` matches stage/header)
    - Run the per-file **hub-key fidelity check**: the set of `hub_keys[].name` AND each
      `hub_keys[].expr` must match the central view's final-SELECT hub-BK columns exactly
      (diff names and expressions; prefix literals, hashes, and COALESCE order identical)
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 4.2_

- [x] 5. Reshape stitched models 00–09
  - [x] 5.1 Reshape `stitch_00`, `stitch_02`–`stitch_09` (satellite-feeding)
    - Apply the Task 4.1 procedure to `stitch_00_policy__party_identity`,
      `stitch_02`–`stitch_09` (note `stitch_01` done in Task 4.1)
    - Preserve and verify each file's hub-key derivation: capture `hub_key_columns` per
      source, transcribe `hub_keys` from the final SELECT, call `stitch_incremental_hcon`,
      and run the per-file hub-key fidelity check
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 4.2_

  - [x]* 5.2 Flag `stitch_10_policy__lnk_role_nominee_beneficiary` as not reshapable
    - **PREMISE WRONG (superseded):** this stitch was assumed to feed a link. Its header
      shows `links: (none)` and it feeds `SAT_LNK_ROLE_NOMINEE_BENEFICIARY`, so it IS
      satellite-feeding (misnamed). It is reshaped in Task 12.2; the file was left
      unchanged by this task
    - Original text: feeds a link, not a satellite; the satellite-merge macro has no link
      path — do NOT force it into `target_sat`
    - Original text: record it as a follow-up finding; leave the file as-is
    - _Requirements: 4.3_

- [x] 6. Reshape stitched models 11–19
  - [x] 6.1 Reshape `stitch_11`–`stitch_19` (satellite-feeding)
    - Apply the Task 4.1 procedure to each; preserve and verify each file's hub-key
      derivation (capture `hub_key_columns`, transcribe `hub_keys`, call
      `stitch_incremental_hcon`, run the hub-key fidelity check)
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 4.2_

- [x] 7. Reshape stitched models 20–29
  - [x] 7.1 Reshape `stitch_20`–`stitch_29` one stitch per satellite (satellite-feeding)
    - These files are not yet reshaped, so reshape them directly in the per-satellite form
      (design "One stitch per satellite"); do NOT do a filename-satellite-only first pass
    - For each central view, read the `stage_NN_*` model and list every `SAT_*_HASHDIFF` it
      hashes; emit one stitch per satellite: the existing filename for the satellite it is
      named for, and `stitch_NN_<spine>__<sat_tail>.sql` for each additional satellite
    - Each per-satellite stitch has its own `target_sat`, its own `output_columns` (that
      satellite's hashdiff payload list from `stage_NN_*`, lower-cased), its own
      `coalesce_rules` restricted to that payload, the **full** `hub_keys` set (families 1
      and 2, verbatim), and only the `sources` that contribute that payload or are needed
      by a `hub_keys` expression / `key_column` (re-add a source rather than edit an
      expression)
    - Apply the Task 4.1 procedure per file: capture `hub_key_columns`, call
      `stitch_incremental_hcon`, run the per-file validation and the hub-key fidelity check;
      also flag duplicate `tgt` within one source (same-alias payload drop) and any source
      kept on its real join key (grain deviation) for the findings doc
    - Record any header / stage / filename satellite disagreement as a finding
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 4.2_

- [x] 8. Reshape stitched models 30–39
  - [x] 8.1 Reshape `stitch_30`–`stitch_39` (satellite-feeding), first pass
    - First pass (one satellite per view, filename satellite) is complete for `stitch_30`–`34`
      and `stitch_36`–`39`: capture `hub_key_columns`, transcribe `hub_keys`, call
      `stitch_incremental_hcon`, run the hub-key fidelity check
    - `stitch_35` is **LEFT UNRESHAPED** and is NOT part of this task: its central view names
      `SAT_CASE_EXTERNAL_REF`, which does not exist in the project, and `stage_35_claim`
      hashes six other satellites. Recorded as an **open follow-up** (decide the satellite
      set, then emit per-satellite stitches); leave the file in its original form
    - Per-satellite follow-up for the nine reshaped files is tracked in Task 12.4
    - First pass is complete for the other nine files; the task stays in progress only
      because of the open `stitch_35` item
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 4.2_

- [x] 9. Reshape stitched models 40–45
  - [x] 9.1 Reshape `stitch_40`–`stitch_42`, `stitch_44`, `stitch_45` (satellite-feeding)
    - Apply the Task 4.1 procedure to each (note `stitch_43` handled separately below)
    - Preserve and verify each file's hub-key derivation (capture `hub_key_columns`,
      transcribe `hub_keys`, call `stitch_incremental_hcon`, run the hub-key fidelity check)
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 4.2_

  - [x]* 9.2 Flag `stitch_43_policy__lnk_party_role_core` as not reshapable
    - **PREMISE WRONG (superseded):** this stitch was assumed to feed a link. Its header
      shows `links: (none)` and it feeds `SAT_LNK_PARTY_ROLE_CORE` and
      `SAT_PARTY_CLAIM_HISTORY`, so it IS satellite-feeding (misnamed). It is reshaped in
      Task 12.5; the file was left unchanged by this task
    - Original text: feeds a link, not a satellite; do NOT force it into `target_sat`
    - Original text: record it as a follow-up finding; leave the file as-is
    - _Requirements: 4.3_

- [x] 14. Add `inc_job_updated_at` to health staging models
  - Scope extension (user decision): health staging models lack the load timestamp that
    every reshaped stitch uses as `ldts_column='inc_job_updated_at'`. Hand-edit them; do NOT
    edit `generators/` (including `gen_hcon4_staging.py`). Task 12 depends on this task
  - [x] 14.1 Edit all 109 `models/staging/stg_*.sql`
    - Append `cast(inc_job_updated_at as timestamp_ntz) as inc_job_updated_at` as the
      LAST select item of each model (add the comma to the previous last item as needed),
      matching the health staging style (unquoted lower-case names, `cast(x as ...)`)
    - Leave every other line byte-identical; `_health__sources.yml` content is not changed
    - Assumption, NOT confirmed: the raw tables carry `INC_JOB_UPDATED_AT`; the user must
      verify this in Snowflake
    - _Requirements: 3.2, 4.2_

  - [x] 14.2 Static verification of the staging edit
    - Every `stg_*.sql` contains exactly one `inc_job_updated_at` output column
    - Every stitch source model referenced by a reshaped stitch (`sources[].model`) has it
    - Report any staging model or referenced source that fails either check
    - _Requirements: 3.2, 4.2_

- [ ] 12. Add the missing per-satellite stitches (revisit first-pass views)
  - The first pass reshaped each view for its filename satellite only. Per design "One
    stitch per satellite", revisit each already-reshaped view in batches of roughly ten:
    1. Read `stage_NN_*` and list every `SAT_*_HASHDIFF` it hashes with each payload list
    2. **Verify the existing (primary) file** carries only its own satellite's payload:
       `output_columns` and `coalesce_rules` restricted to that satellite, `target_sat`
       matching it; trim any other satellite's columns
    3. For each additional satellite, add `stitch_NN_<spine>__<sat_tail>.sql` (skip if the
       tail already matches the existing filename) with: its own `target_sat`, its own
       `output_columns` from the `stage_NN_*` hashdiff list, its own `coalesce_rules`, the
       **full** `hub_keys` set (verbatim), and only the sources that contribute that payload
       or are needed by a `hub_keys` expression / `key_column` (re-add a source rather than
       edit an expression)
    4. Run the per-file validation and the hub-key fidelity check on every file touched, and
       flag same-alias payload drops (duplicate `tgt` in one source), grain deviations
       (sources keeping their real join key), and header / stage / filename disagreements
  - Depends on Task 14 (staging models must expose `inc_job_updated_at`)
  - Only `stitch_35` is excluded from this task (open follow-up, see 8.1). `stitch_10` and
    `stitch_43` are satellite-feeding (misnamed, see 5.2 / 9.2) and are included; they have
    no first pass, so reshape them from the git HEAD original, one stitch per satellite
  - [ ] 12.1 Pilot: per-satellite stitches for `stitch_01`
    - Apply steps 1-4 to `stitch_01_policy__policy_header` (all satellites hashed by
      `stage_01_policy`), proving the procedure before the batches
    - Confirm the primary file `stitch_01_policy__policy_header.sql` carries only
      `sat_policy_header` payload and that each new file's `hub_keys` match the central view
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 4.2_

  - [~] 12.2 Batch `stitch_00`, `stitch_02`–`stitch_10`
    - Apply steps 1-4 to each view (note `stitch_01` done in 12.1)
    - `stitch_10_policy__lnk_role_nominee_beneficiary` has no first pass: reshape from the
      git HEAD original, one stitch per satellite (feeds `SAT_LNK_ROLE_NOMINEE_BENEFICIARY`)
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 4.2_

  - [~] 12.3 Batch `stitch_11`–`stitch_19`
    - Apply steps 1-4 to each view
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 4.2_

  - [~] 12.4 Batch `stitch_30`–`stitch_34`, `stitch_36`–`stitch_39`
    - Apply steps 1-4 to each view; `stitch_35` is excluded (open follow-up, see 8.1)
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 4.2_

  - [~] 12.5 Batch `stitch_40`–`stitch_45`
    - Apply steps 1-4 to each view
    - `stitch_43_policy__lnk_party_role_core` has no first pass: reshape from the git HEAD
      original, one stitch per satellite (`SAT_LNK_PARTY_ROLE_CORE` and
      `SAT_PARTY_CLAIM_HISTORY`)
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 4.2_

- [~] 13. Checkpoint — per-satellite stitch set is complete and consistent
  - Static inspection only: for every stage_NN model, confirm each hashed satellite has a
    per-satellite stitch (except `stitch_35`), no stitch carries
    another satellite's payload, and all files call `stitch_incremental_hcon`
  - Ensure inspection passes, ask the user if questions arise
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 4.2_

- [~] 10. Checkpoint — static inspection and user-run dbt checklist
  - dbt is **not installed** in the agent environment, so `dbt deps`, `dbt parse`, and
    `dbt compile` are performed by the **user**; the agent does not run or claim them
  - Agent performs static inspection of the reshaped `stitched/` models and the macro:
    `sources` / `coalesce_rules` / `output_columns` / `hub_keys` self-consistent, every
    `alias.tgt` declared, `source_tag` shapes valid, `target_sat` correct
  - Document a checklist of commands for the user (run from `opus_health_dv_dbt`):
    - `dbt deps`
    - `dbt parse`
    - `dbt compile --select stitched`
  - Do NOT claim the downstream `stage/`, `hub_feeds/`, or `vault/` models compile:
    multi-satellite `stage_NN_*` models are expected to need repointing to the
    per-satellite stitches, and `stitch_35` stays as-is
  - Ensure static inspection is complete and the checklist is documented; ask the user if
    questions arise
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 4.2, 4.3_

- [~] 11. Compile the follow-up findings document
  - Author a single findings doc (e.g. `FOLLOWUP_FINDINGS_HEALTH.md` in the project root)
    gathering, not patching. Items to record:
    - **Resolved** — hub-key derivation is **preserved** by `stitch_incremental_hcon`
      (not dropped)
    - **Open: `stage_NN_*` repointing** — multi-satellite `stage_NN_*` models read one
      `ref('stitch_NN_...')` and hash several satellites; with one stitch per satellite they
      must be repointed to the per-satellite stitches, and downstream compile is not
      claimed until then
    - **Open: `stitch_35`** — left unreshaped; `SAT_CASE_EXTERNAL_REF` does not exist and
      `stage_35_claim` hashes six other satellites
    - **Risk: same-alias payload drops** — two payload attributes mapping to one `tgt` on a
      source leave only one column; list every case flagged by the per-file check
    - **Risk: grain deviations** — sources keeping their real join key as `key_column` merge
      at a different grain than the spine; hub keys may be NULL where an alias is not picked
    - **Fix recorded: `key_column` alias resolution** — the macro fix that resolves
      `key_column` aliases in `stitch_incremental_hcon`
    - **Risk: hub-key transcription fidelity** — `hub_key_columns[].src_expr` and
      `hub_keys[].expr` are hand-transcribed; the per-file fidelity check is the mitigation
    - **Open: record-source divergence** — macro `source_tag` vs the stitch model-name
      literal the downstream expects; independent of the hub-key fix
    - **Warning: generator overwrite** — re-running the hcon4 stitched generator overwrites
      the hand reshapes and leaves `stitch_incremental_hcon.sql` unreferenced
    - **Resolved: `stitch_10` / `stitch_43` were misnamed** — headers show `links: (none)`;
      they feed satellites (`SAT_LNK_ROLE_NOMINEE_BENEFICIARY`; `SAT_LNK_PARTY_ROLE_CORE`
      and `SAT_PARTY_CLAIM_HISTORY`) and are now reshaped per satellite (Tasks 12.2, 12.5)
    - **Scope extension: health staging hand-edited for `inc_job_updated_at`** (Task 14) —
      the 109 `stg_*.sql` files were edited by hand, so re-running `gen_hcon4_staging.py`
      would overwrite them; raw tables are assumed but NOT confirmed to have
      `INC_JOB_UPDATED_AT`; the user must verify
    - **dbt not run** — dbt is not installed in the agent environment; nothing is
      parse/compile-verified, and the user runs the Task 10 checklist
    - **Unconfirmed config fallbacks** — `profiles.yml` / vars fallback values
      `BAGIC_PROD_MIRROR_DB` and `OPUS_GG_DWHSTAGE` were copied from sibling OPUS projects
      and are not confirmed for Health
    - **Pre/post-hook run-log retained** in `dbt_project.yml` (record the retain decision)
    - **`dbt_project.yml` omitted `+schema` keys** (record the omission and its effect)
    - Also record the Health config values used: profile `opus_health_dbt`, project
      `opus_health_dv_dbt`, the `health_raw_*` vars, and any other `profiles.yml`
      substitutions
    - Confirm downstream layers remain byte-unchanged; `generators/` untouched
    - Do NOT claim downstream `stage/`, `hub_feeds/`, or `vault/` compile
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_

## Notes

- Tasks marked with `*` are optional/flagged — 5.2 and 9.2 were completed on a wrong
  premise (stitch_10/43 do feed satellites) and are superseded by Tasks 12.2 / 12.5.
- Task 14 hand-edits health staging (scope extension); Task 12 depends on it.
- No property-based tests apply: this is fixed-config scaffolding plus a one-shot
  structural reshape of a fixed, enumerable set of files. Verification is
  inspection-based plus user-run dbt commands (design Testing Strategy).
- Tasks never modify `generators/` or the downstream `stage/`/`hub_feeds/`/`vault/` layers.
  The new `stitch_incremental_hcon.sql` macro (Task 1.3) is hand-authored and lives outside
  the generator's output.
- Every satellite-feeding reshape **preserves and verifies** the inline hub-key derivation
  (capture `hub_key_columns`, transcribe `hub_keys`, run the fidelity check).
- Tasks 5.1, 6.1, 8.1, 9.1 are first-pass (one satellite per view); Tasks 12.1-12.5 add the
  missing per-satellite stitches. Task 7.1 reshapes per satellite from the start.
- dbt is not installed in the agent environment; Task 10 is static inspection plus a
  command checklist the user runs. Nothing is claimed compile-verified.

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1", "1.2", "1.4"] },
    { "id": 1, "tasks": ["1.3", "2.1", "2.2", "2.3", "2.4"] },
    { "id": 2, "tasks": ["4.1"] },
    { "id": 3, "tasks": ["5.1", "5.2", "6.1", "7.1", "8.1", "9.1", "9.2"] },
    { "id": 4, "tasks": ["14.1"] },
    { "id": 5, "tasks": ["14.2"] },
    { "id": 6, "tasks": ["12.1"] },
    { "id": 7, "tasks": ["12.2", "12.3", "12.4", "12.5"] },
    { "id": 8, "tasks": ["11"] }
  ]
}
```
