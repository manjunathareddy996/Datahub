# Requirements Document

## Introduction

The `opus_health_dv_dbt` project under `BGIL_DBT` is not a runnable dbt project: it contains model `.sql` files but has no `dbt_project.yml`, `packages.yml`, `profiles.yml`, vendored `dbt_packages/`, `macros/`, or the standard empty dbt directories. Its health "central-view v4" (hcon4) stitched models are machine-generated numbered central views (`stitch_00_*` through `stitch_45_*`) that inline-join up to roughly 54 source tables and compute hub business keys inline.

This feature makes `opus_health_dv_dbt` a runnable dbt project by adding runnable scaffolding adapted from the fully runnable `opus_partner_dv_dbt` project (the structural template), and by re-shaping the health stitched models into the partner LOB's stitched form: thin attribute-merge views that call the `stitch_incremental` macro with declarative `sources` / `output_columns` / `coalesce_rules` / `target_sat` inputs, following the `dv2-automatedv-dbt-builder` skill.

Scope is deliberately bounded to two deliverables: (1) runnable scaffolding, and (2) stitched-model reshape. Downstream layers (`stage/`, `hub_feeds/`, `vault/`) are explicitly out of scope and are left unchanged; any compile mismatches they introduce are surfaced as follow-up findings rather than silently repaired. The `generators/` (hcon4 family) code is not edited.

## Glossary

- **Health_Project**: The dbt project rooted at `BGIL_DBT\opus_health_dv_dbt`, the target of this feature.
- **Partner_Project**: The fully runnable reference dbt project at `BGIL_DBT\opus_partner_dv_dbt`, used as the structural and stitched-form template.
- **Builder_Skill**: The `dv2-automatedv-dbt-builder` skill at `C:\Users\tanma\.kiro\skills\skill.md`, which defines the new-LOB build workflow (Segment 1) and the conventions, macros, defect classes, and canonical `dbt_project.yml` / `packages.yml` / `profiles.yml` templates (Segment 2).
- **Scaffolding**: The non-model files and directories a dbt project needs to be runnable: `dbt_project.yml`, `packages.yml`, `profiles.yml`, vendored `dbt_packages/`, `macros/`, and the standard empty dbt directories (`analyses/`, `seeds/`, `snapshots/`, `tests/`, `docs/`).
- **Stitched_Model**: A dbt model in `models/.../stitched/` that merges attributes from multiple staging sources at a single hub grain and feeds one satellite.
- **Partner_Stitched_Form**: The Partner_Project's stitched model shape: a `config(materialized='view')` model that defines `sources`, `output_columns`, and `coalesce_rules` as Jinja variables and emits its body by calling the `stitch_incremental` macro with a `target_sat`.
- **Health_Central_View**: The Health_Project's existing hcon4 stitched model shape: a numbered, generated view that inline-joins many source tables (FULL OUTER) and derives hub business keys inline, feeding one satellite whole.
- **Stitch_Incremental_Macro**: The `stitch_incremental` macro vendored in `Partner_Project\macros\stitch_incremental.sql`, invoked by Partner_Stitched_Form models.
- **Generators_Code**: The Python code under `Health_Project\generators` (hcon4 family) that generates Health_Project models, including the stitched central views.
- **Record_Source_Tag**: The string literal that identifies a contributing source in a stitched model; in Partner_Stitched_Form it is the per-source `source_tag` (for example `OPUS_PARTNER_<TABLE>`).
- **Downstream_Layers**: The Health_Project model layers `stage/`, `hub_feeds/`, and `vault/` (`hubs/`, `links/`, `satellites/`), which are out of scope for this feature.

## Requirements

### Requirement 1: Runnable project scaffolding

**User Story:** As a data engineer, I want runnable dbt project scaffolding added to the Health project, so that the project can be initialized and parsed by dbt.

#### Acceptance Criteria

1. THE Health_Project SHALL contain a `dbt_project.yml` file adapted from the Partner_Project with the project name `opus_health_dv_dbt`.
2. THE `dbt_project.yml` in the Health_Project SHALL declare the profile name `opus_health_dbt`.
3. THE `dbt_project.yml` in the Health_Project SHALL declare `vars` for the health raw database and raw schema sourced from the Health_Project build inputs.
4. THE `dbt_project.yml` in the Health_Project SHALL declare a `models` tag-and-materialization map covering the Health_Project model layers using the canonical map form from the Partner_Project.
5. THE Health_Project SHALL contain a `packages.yml` file that declares the `dbt_packages/dbt_utils` and `dbt_packages/automate_dv` local packages matching the Partner_Project.
6. THE Health_Project SHALL contain a `profiles.yml` file defining the profile `opus_health_dbt` with `dev` and `prod` Snowflake outputs adapted from the Partner_Project.
7. WHERE the Partner_Project `profiles.yml` uses placeholder values `"_"` for `account` and `user` in the `dev` output, THE Health_Project `profiles.yml` SHALL carry the same placeholder values in the `dev` output.

### Requirement 2: Vendored macros and supporting directories

**User Story:** As a data engineer, I want the macros and supporting directories vendored into the Health project, so that stitched models and dbt commands resolve their dependencies locally.

#### Acceptance Criteria

1. THE Health_Project SHALL contain a vendored `dbt_packages/` directory adapted from the Partner_Project.
2. THE Health_Project SHALL contain a `macros/` directory that includes the `stitch_incremental.sql` macro adapted from the Partner_Project.
3. THE Health_Project `macros/` directory SHALL include the Partner_Project supporting macros `sat_multi_source.sql`, `ma_sat_multi_source.sql`, `hash.sql`, `location_address_key.sql`, `watermark.sql`, `get_run_date.sql`, and `generate_schema_name.sql`.
4. THE Health_Project SHALL contain the standard empty dbt directories `analyses/`, `seeds/`, `snapshots/`, `tests/`, and `docs/` present in the Partner_Project.
5. THE Health_Project SHALL define dbt `sources` for the staging inputs the stitched models reference.

### Requirement 3: Stitched model reshape to partner form

**User Story:** As a data modeler, I want the health stitched models reshaped into the partner macro-based form, so that the stitched layer follows the Builder_Skill conventions and merges attributes through the shared macro.

#### Acceptance Criteria

1. THE Health_Project stitched models SHALL be reshaped from Health_Central_View form into Partner_Stitched_Form.
2. WHERE a Health_Project stitched model is reshaped, THE reshaped model SHALL set `config(materialized='view')`.
3. WHERE a Health_Project stitched model is reshaped, THE reshaped model SHALL define `sources`, `output_columns`, and `coalesce_rules` as declarative inputs.
4. WHERE a Health_Project stitched model is reshaped, THE reshaped model SHALL emit its body by calling the Stitch_Incremental_Macro with a `target_sat` argument.
5. WHERE a Health_Project stitched model is reshaped, THE reshaped model SHALL set each contributing source `Record_Source_Tag` using the health record-source convention confirmed against the existing Health_Project stage and stitch literals.
6. THE reshaped Health_Project stitched models SHALL be edited directly as `.sql` files, and the Generators_Code SHALL remain unmodified.

### Requirement 4: Scope boundary and risk capture

**User Story:** As a maintainer, I want the scope boundary and its risks recorded, so that downstream layers are left untouched and compile gaps are tracked rather than silently patched.

#### Acceptance Criteria

1. THE Downstream_Layers of the Health_Project SHALL remain unmodified by this feature.
2. WHEN reshaping a Health_Project stitched model removes inline hub-key derivation that the Health_Central_View previously provided, THE feature SHALL record the removed derivation as a follow-up finding.
3. IF the reshaped stitched layer and the unmodified Downstream_Layers produce a dbt compile mismatch, THEN THE feature SHALL surface the mismatch as a follow-up finding rather than modify the Downstream_Layers to resolve it.
4. THE feature SHALL record that re-running the Health_Project stitched generator would overwrite the hand-reshaped stitched `.sql` files.
5. THE feature SHALL record the Health_Project-specific configuration values used: profile `opus_health_dbt`, project `opus_health_dv_dbt`, and the health raw database and raw schema vars confirmed from the Health_Project build inputs.
