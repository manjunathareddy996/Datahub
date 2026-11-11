# Requirements Document

## Introduction

This feature makes the dbt project at `BGIL_DBT/opus_health_dv_dbt` a runnable dbt project, following the skill `dv2-automatedv-dbt-builder` and using `BGIL_DBT/opus_partner_dv_dbt` as the structural reference. The scope covers project scaffolding, the reshape of the Health stitched models, and one minimal edit to the `stg_health__*` staging models: adding the column `inc_job_updated_at` where it is missing. Stage (stg2), hub_feeds and vault models stay unchanged. Any compile mismatch in those layers is reported as a finding and not fixed. The `generators/` directory is not edited.

The work aligns with the existing, currently empty spec folder `BGIL_DBT/opus_health_dv_dbt/.kiro/specs/opus-health-dv-runnable`. This spec supersedes that folder's intent and carries the same feature goal.

User decisions applied to this spec:

- Packages come from the vendored `dbt_packages` copied from the Partner_Project, with the Partner_Project `packages.yml` (`local:` entries). `dbt deps` is not run.
- Stitched model file names keep the form `stitch_vNN_*` and are not renamed.
- Satellites with data-driven child keys or composite business keys, and link rows that carry several keys, are not hand-written. They are built with the existing, unchanged Stitch_Macro by folding the child key or extra keys into `unique_key` through a Composite_Key_Expression. Original SQL is kept only as a last-resort Fallback_Stitch recorded in the Findings_Report.
- `union all` is allowed only in the thin consumer views (`stitch_vNN_*`).
- Splitting an Original_Stitch that uses literal child keys is approved.
- Stitched model names stay consistent so stage (stg2) models can still reference them through `source_model`. Stage SQL is not repointed.
- The only change allowed in `stg_health__*` staging models is the addition of `inc_job_updated_at`, cast as `timestamp_ntz` per the partner stg1 convention in the Skill.

Key facts about the current state, taken from the workspace:

- Health models sit under `models/automate_dv/{standard,augmented}`. Partner uses `models/raw_vault/{standard,augmented}`.
- Health has 34 stitched models (`stitch_v01_agreement` to `stitch_v34_risk_object`). They are multi-satellite, `UNION ALL` merge views that use `ref()` to `stg_health__*` models, `first_value ... ignore nulls` and literal child keys. Partner stitched models are single-satellite calls to the `stitch_incremental` macro.
- Health has 116 `stg_health__*` staging models. 104 of them lack `inc_job_updated_at` (12 already select it), as counted by script; the script output is authoritative.
- Health `macros/` is empty. Partner `macros/` holds `generate_schema_name`, `get_run_date`, `hash`, `location_address_key`, `ma_sat_multi_source`, `sat_multi_source`, `stitch_incremental` and `watermark`.
- Health `dbt_project.yml` uses project and profile name `health_consolidated_v5_dv` and has no hooks or tags. Partner uses `opus_partner_dv_dbt`, profile `opus_partner_dbt`, and `raw_vault` paths with tags and run-log hooks.

## Glossary

- **Health_Project**: The dbt project in `BGIL_DBT/opus_health_dv_dbt`.
- **Partner_Project**: The reference dbt project in `BGIL_DBT/opus_partner_dv_dbt`.
- **Skill**: The `dv2-automatedv-dbt-builder` skill that defines the runnable-project conventions.
- **Raw_Vault_Directory**: The directory `models/raw_vault` in the Health_Project, which replaces `models/automate_dv`.
- **Stitched_Model**: A model in `models/raw_vault/standard/stitched` of the Health_Project whose name starts with `stitch_v` followed by a two-digit number.
- **Stitch_Macro**: The dbt macro `stitch_incremental` that Partner_Project defines in `macros/stitch_incremental.sql`.
- **Stitch_Spec**: The set of `sources`, `output_columns`, `coalesce_rules` and `target_sat` values passed to the Stitch_Macro by one Stitched_Model.
- **Original_Stitch**: The Stitched_Model SQL as it exists before this feature.
- **Literal_Key_Split**: The division of one Original_Stitch that uses literal child keys into several Stitched_Models, each of which the Stitch_Macro can express.
- **Surrogate_Key**: A single column (for example `policy_classification_pk`) that is the `unique_key` of a Stitch_Macro call and stands for a composite of business key and child keys.
- **Composite_Key_Expression**: The `key_column` expression of one source, in the form `<bk expr> || '|' || <child key expr>`, where a NULL child key is replaced by `coalesce(<child key expr>, '~')`. All branches of one satellite use the same normalised format.
- **Key_Part_Column**: A payload column (for example `policy_bk` or `..._ck`) that returns one part of a Composite_Key_Expression, so that the consumer view still exposes the part.
- **Link_Key_Expression**: The concatenated key of a link row that has several legs, built in the same way as a Composite_Key_Expression, with each leg returned as a column.
- **Consumer_View**: A thin `stitch_vNN_*` view that exposes the Stitch_Macro outputs of one or more satellites, and the only model type allowed to use `union all`.
- **Fallback_Stitch**: A Stitched_Model that keeps its Original_Stitch SQL because no consistent Composite_Key_Expression can be produced for its satellite.
- **Staging_Model**: A `stg_health__*` model under `models/staging` of the Health_Project (stg1).
- **Job_Updated_Column**: The column `inc_job_updated_at`.
- **Stage_Model**: A stg2 model in a `staging` folder under the Raw_Vault_Directory that references a Stitched_Model through `source_model`.
- **Vendored_Packages**: The `dbt_packages` directory copied from the Partner_Project into the Health_Project.
- **Findings_Report**: A document in the spec folder that lists compile mismatches and stitch conversion gaps found by this feature.
- **Out_Of_Scope_Layers**: The Stage_Models, hub_feeds, hubs, links, satellites and references under the Raw_Vault_Directory. Staging_Models are not part of this set for the Job_Updated_Column edit only.
- **Generators_Directory**: The directory `BGIL_DBT/opus_health_dv_dbt/generators`.
- **Parse_Check**: The command `dbt parse` run against the Health_Project.
- **Compile_Check**: The command `dbt compile` run against the Health_Project.

## Requirements

### Requirement 1: Raw vault directory layout

**User Story:** As a data engineer, I want the Health_Project to use the same model directory layout as the Partner_Project, so that both projects can be maintained and deployed the same way.

#### Acceptance Criteria

1. THE Health_Project SHALL contain the Raw_Vault_Directory with the subfolders `standard` and `augmented` in place of `models/automate_dv`.
2. WHEN the move is complete, THE Health_Project SHALL contain every model file that existed under `models/automate_dv` at the matching relative path under the Raw_Vault_Directory.
3. WHEN the move is complete, THE Health_Project SHALL contain no directory `models/automate_dv`.
4. WHEN the move is complete, THE Health_Project SHALL contain no reference to the path `automate_dv/` in `dbt_project.yml`, project documentation or `ref()` or `source()` calls outside the Generators_Directory.
5. THE Health_Project SHALL preserve the file history of moved models by performing the move with git-aware file moves.

### Requirement 2: Project configuration

**User Story:** As a data engineer, I want `dbt_project.yml` to match the Partner_Project structure, so that the project resolves its folders, tags, schemas and materializations.

#### Acceptance Criteria

1. THE Health_Project SHALL declare in `dbt_project.yml` the keys `model-paths`, `analysis-paths`, `test-paths`, `seed-paths`, `macro-paths`, `snapshot-paths`, `target-path` and `clean-targets` with the same values as the Partner_Project.
2. THE Health_Project SHALL key its model configuration in `dbt_project.yml` by the project `name` value and by the `raw_vault` folder path in place of `automate_dv`.
3. THE Health_Project SHALL configure the folders `stitched`, `staging`, `hubs`, `links`, `satellites` and `references` under `raw_vault.standard`, and `staging` and `satellites` under `raw_vault.augmented`, with the same materializations, tags and `on_schema_change` settings as the Partner_Project.
4. THE Health_Project SHALL configure the `staging` folder under `models` with materialization `view` and the tag `stg1`.
5. THE Health_Project SHALL keep the existing `health_raw_database` and `health_raw_schema` variables in `dbt_project.yml`.
6. WHERE the Skill specifies a project name or profile name for Health, THE Health_Project SHALL use the names the Skill specifies.
7. IF the Skill does not specify a project name or profile name, THEN THE Health_Project SHALL use the names `opus_health_dv_dbt` and `opus_health_dbt`, mirroring the Partner_Project naming pattern.
8. IF a folder named in `dbt_project.yml` model configuration does not exist under `models`, THEN THE Health_Project SHALL record that folder in the Findings_Report.

### Requirement 3: Macros, profile and packages

**User Story:** As a data engineer, I want the Health_Project to contain the macros, profile and vendored packages the Partner_Project has, so that `dbt parse` and `dbt compile` can run without network package installation.

#### Acceptance Criteria

1. THE Health_Project SHALL contain in `macros/` a copy of each Partner_Project macro that the Health_Project models or the Stitch_Macro call, including `stitch_incremental.sql`.
2. THE Health_Project SHALL contain the Stitch_Macro with SQL content identical to the Partner_Project copy.
3. THE Health_Project SHALL contain a `profiles.yml` with `dev` and `prod` outputs that follow the structure of the Partner_Project `profiles.yml` and use the profile name from `dbt_project.yml`.
4. THE Health_Project SHALL contain the folders `analyses`, `seeds`, `snapshots` and `tests` that the Partner_Project contains.
5. THE Health_Project SHALL contain a `packages.yml` whose content is identical to the Partner_Project `packages.yml`, including its `local:` package entries.
6. THE Health_Project SHALL contain the Vendored_Packages as a copy of the Partner_Project `dbt_packages` directory, with file content identical to the Partner_Project copy.
7. WHEN the Parse_Check or the Compile_Check runs in the Health_Project, THE Health_Project SHALL resolve every package named in `packages.yml` from the Vendored_Packages without running `dbt deps`.
8. IF a `local:` path in `packages.yml` does not resolve from the Health_Project directory, THEN THE Health_Project SHALL record the path and the cause in the Findings_Report.
9. THE Health_Project SHALL exclude `target` and `logs` from version control by providing the ignore entries the Partner_Project provides.
10. THE Health_Project SHALL track the Vendored_Packages in version control in the same way the Partner_Project tracks its `dbt_packages` directory.

### Requirement 4: Stitched model reshape

**User Story:** As a data engineer, I want each Health stitched model that the Stitch_Macro can express rewritten as a call to the Stitch_Macro, so that those stitched views follow the Partner_Project pattern.

#### Acceptance Criteria

1. THE Health_Project SHALL keep the file name `stitch_vNN_*` of every Original_Stitch unchanged.
2. WHEN a Stitched_Model is rewritten, THE Stitched_Model SHALL consist of a `config(materialized='view')` call, descriptive SQL comments, a `sources` list, an `output_columns` list, a `coalesce_rules` map and one call to the Stitch_Macro, in the style of `stitched/stitch_policy_header.sql` in the Partner_Project.
3. WHEN a Stitched_Model is rewritten, THE Stitched_Model SHALL derive the `sources` entries from the `ref()` targets, key expressions and column expressions of the Original_Stitch branches.
4. WHEN a Stitched_Model is rewritten, THE Stitched_Model SHALL derive `output_columns` from the payload columns of the Original_Stitch that feed the target satellite.
5. WHEN a Stitched_Model is rewritten, THE Stitched_Model SHALL derive `coalesce_rules` from the source precedence of the Original_Stitch, listing aliases in the order of the `__PREC` values of the Original_Stitch.
6. WHEN a Stitched_Model is rewritten, THE Stitched_Model SHALL pass a `target_sat` value that names the satellite in the Health_Project the Stitched_Model feeds.
7. THE Health_Project SHALL set each `source_tag` value to the form `<SYSTEM>_<TABLE>` with the source system prefix `OPUS` and the upper-case source table name.
8. IF an Original_Stitch feeds more than one satellite, THEN THE Health_Project SHALL record in the Findings_Report the satellites fed, the chosen conversion approach and any satellite whose columns cannot be expressed through a single Stitch_Macro call.
9. WHEN an Original_Stitch feeds a satellite with data-driven child keys or composite business keys, THE Health_Project SHALL build that satellite with the unchanged Stitch_Macro, set `unique_key` to a Surrogate_Key, set each source `key_column` to a Composite_Key_Expression, and return the key parts as Key_Part_Columns in `output_columns`.
10. THE Health_Project SHALL use the same normalised Composite_Key_Expression format, including `coalesce(<child key expr>, '~')` for a NULL child key, in every source branch of one satellite.
11. WHEN an Original_Stitch mixes literal child key branches and data-driven child key branches for one satellite, THE Health_Project SHALL build them in one Stitch_Macro call.
12. WHEN a link row carries several keys, THE Health_Project SHALL build the link key as a Link_Key_Expression and return each leg as a column.
13. THE Health_Project SHALL leave the Stitch_Macro SQL unchanged when it builds satellites with Composite_Key_Expressions.
14. IF no consistent Composite_Key_Expression can be produced for a satellite, THEN THE Health_Project SHALL record a finding with the file name, branch number and construct in the Findings_Report.
15. WHERE a finding under criterion 14 exists and no other conversion is possible, THE Health_Project SHALL keep the Original_Stitch SQL for that satellite as a Fallback_Stitch and record it in the Findings_Report as a last resort.
16. IF an Original_Stitch uses literal child keys and the Stitch_Macro can express each resulting part, THEN THE Health_Project SHALL apply a Literal_Key_Split and record the original file name, the resulting model names and the literal key value of each part in the Findings_Report.
17. WHEN a Literal_Key_Split is applied, THE Health_Project SHALL keep a model with the original `stitch_vNN_*` name so that every `source_model` reference to that name resolves.
18. WHEN all rewrites are complete, THE Health_Project SHALL contain `union all` only in Consumer_Views (`stitch_vNN_*`), and no other model SHALL use the `union all` merge pattern, `__PREC` or `__RID` columns, other than Fallback_Stitches.
19. THE Health_Project SHALL preserve the original model comments about source precedence and satellites fed within each rewritten Stitched_Model.
20. THE Health_Project SHALL list every Fallback_Stitch in the Findings_Report.

### Requirement 5: Reference updates

**User Story:** As a data engineer, I want every file reference that pointed at the old layout updated and stage references kept valid, so that the project has no dangling paths or refs.

#### Acceptance Criteria

1. WHEN the layout move is complete, THE Health_Project SHALL resolve every `ref()` call in the Raw_Vault_Directory to an existing model.
2. WHEN the layout move is complete, THE Health_Project SHALL list in `README.md` the new `models/raw_vault` paths in place of `models/automate_dv` paths.
3. THE Health_Project SHALL keep every Stitched_Model name that a Stage_Model references through `source_model`, and SHALL leave the Stage_Model SQL unchanged.
4. IF a `ref()` call or `source_model` reference in an Out_Of_Scope_Layer targets a Stitched_Model name or column that the rewrite no longer provides, THEN THE Health_Project SHALL record the referencing model name, the missing name or column, and the Stitched_Model in the Findings_Report.
5. THE Health_Project SHALL leave `build_artifacts/` content unchanged, because the Generators_Directory produces that content.

### Requirement 6: Scope boundaries

**User Story:** As a data engineer, I want the scope kept to scaffolding, stitched models and one staging column, so that no other model is changed by accident.

#### Acceptance Criteria

1. THE Health_Project SHALL leave the content of the Generators_Directory unchanged.
2. THE Health_Project SHALL leave the SQL content of every Out_Of_Scope_Layers model unchanged, other than the file move described in Requirement 1.
3. THE Health_Project SHALL change the SQL of a Staging_Model only by adding the Job_Updated_Column as described in Requirement 7.
4. IF the Compile_Check reports an error in an Out_Of_Scope_Layers model, THEN THE Health_Project SHALL record the model name, the error message and a suggested cause in the Findings_Report and leave the model unchanged.
5. THE Findings_Report SHALL group its entries by category: layout, configuration, stitched conversion, staging column, and out-of-scope compile mismatch.

### Requirement 7: Staging job-updated column

**User Story:** As a data engineer, I want every Staging_Model to expose `inc_job_updated_at` in the partner stg1 form, so that downstream stitched and stage models can rely on a consistent watermark column.

#### Acceptance Criteria

1. WHEN a Staging_Model does not select the Job_Updated_Column, THE Health_Project SHALL add the Job_Updated_Column to that Staging_Model as a cast to `timestamp_ntz`, following the partner stg1 convention in the Skill.
2. WHEN a Staging_Model already selects the Job_Updated_Column, THE Health_Project SHALL leave that Staging_Model unchanged.
3. WHEN the Job_Updated_Column is added, THE Health_Project SHALL leave every other column, expression, filter, join and comment of the Staging_Model unchanged.
4. WHEN the Job_Updated_Column is added, THE Health_Project SHALL source its value from the same raw column or expression that the Partner_Project stg1 models use for `inc_job_updated_at`, as the Skill specifies.
5. IF the raw source table of a Staging_Model has no column that can supply the Job_Updated_Column, THEN THE Health_Project SHALL leave that Staging_Model unchanged and record the model name and the cause in the Findings_Report under the category staging column.
6. WHEN the staging edit is complete, THE Health_Project SHALL contain the Job_Updated_Column in each Staging_Model not recorded under criterion 5.
7. THE Findings_Report SHALL state the count of Staging_Models changed, the count already containing the Job_Updated_Column and the count recorded under criterion 5.

### Requirement 8: Step-by-step plan gate

**User Story:** As a data engineer, I want an ordered plan with checkpoints before any file changes, so that I can review the approach and approve it.

#### Acceptance Criteria

1. THE spec SHALL provide an ordered, step-by-step implementation plan that lists each step, the files it changes and the check that confirms the step.
2. WHILE the user has not approved the plan, THE implementing agent SHALL make no change to the Health_Project.
3. WHEN a plan step completes, THE implementing agent SHALL run the Parse_Check or an explicit file-level check named in that step.
4. THE plan SHALL place the layout move and `dbt_project.yml` update before the stitched rewrites.
5. THE plan SHALL place the staging column edit as a separate step with its own file-level check that counts Staging_Models containing the Job_Updated_Column.
6. THE plan SHALL place the Findings_Report update after the final Compile_Check.

### Requirement 9: Runnable verification

**User Story:** As a data engineer, I want to confirm the project is runnable, so that I know the scaffolding is correct before any further model work.

#### Acceptance Criteria

1. WHEN the scaffolding, stitched rewrites and staging column edits are complete, THE Health_Project SHALL pass the Parse_Check with zero errors in the scaffolding, Stitched_Model and Staging_Model files.
2. WHEN the Compile_Check runs, THE Health_Project SHALL compile every Stitched_Model and every Staging_Model without a Jinja or macro error.
3. IF the Parse_Check or Compile_Check cannot run because Snowflake credentials or network access are unavailable, THEN THE implementing agent SHALL record the blocked check in the Findings_Report and run an offline check of YAML validity, macro presence and package presence in the Vendored_Packages.
4. WHEN verification finishes, THE Findings_Report SHALL state which checks ran, which checks were blocked and the result of each.
