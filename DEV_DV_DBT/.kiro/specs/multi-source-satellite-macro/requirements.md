# Requirements Document

## Introduction

This document defines the requirements for a custom dbt macro (`sat_multi_source`) that extends the automate_dv `sat` macro to support multiple source models with non-identical payload columns. The existing automate_dv `sat` macro fails when `source_model` is passed as a list because `ref()` requires a string argument. Additionally, a simple UNION ALL approach is insufficient because contributing staging models have different column sets. The macro must dynamically generate a unioned CTE with NULL-filling for missing columns while preserving satellite change-detection logic (hashdiff-based deduplication via LAG window functions) and supporting incremental materialization on Snowflake.

## Glossary

- **Macro**: A custom dbt Jinja macro (`.sql` file in the `macros/` directory) that generates SQL at compile time
- **Satellite**: A Data Vault 2.0 table that stores descriptive attributes (payload columns) for a hub entity, tracking changes over time
- **Source_Model**: A dbt model name (string) passed to `ref()` to resolve a staging table/view as input to the satellite
- **Payload_Column**: A descriptive attribute column stored in a satellite, excluding system columns (hash key, hashdiff, load datetime, record source)
- **Hashdiff**: A hash value computed over all payload columns for a given source row, used to detect whether attribute values have changed
- **Hash_Key**: A hash of the business key(s) identifying the hub entity the satellite tracks (e.g., `ASSESSMENT_HK`)
- **Load_Datetime**: The timestamp indicating when a record was loaded into the Data Vault
- **Record_Source**: A metadata column identifying the originating system or table for a record
- **NULL_Fill**: The technique of selecting `NULL AS <column_name>` for payload columns that do not exist in a particular source model
- **Superset_Columns**: The complete union of all distinct payload columns across all contributing source models
- **Change_Detection**: The process of comparing a new row's hashdiff against the previous hashdiff (via LAG window function) to determine if the record represents a genuine change
- **Incremental_Load**: A materialization strategy where only new or changed records are inserted into the target table on subsequent runs
- **Source_Column_Map**: A dictionary mapping each source model name to its list of available payload columns, enabling the macro to determine which columns to NULL-fill per source

## Requirements

### Requirement 1: Accept Multiple Source Models

**User Story:** As a data engineer, I want the macro to accept a list of source model names, so that I can feed multiple staging tables into a single satellite without manually creating union views.

#### Acceptance Criteria

1. WHEN `source_model` is provided as a list of strings containing between 1 and 50 entries, THE Macro SHALL iterate over each string and resolve it individually via `ref()`.
2. WHEN `source_model` is provided as a single string, THE Macro SHALL delegate to the existing automate_dv `sat` macro by passing the string directly to `ref()` and producing identical SQL output to a direct `sat` macro invocation with the same parameters.
3. IF `source_model` is an empty list, THEN THE Macro SHALL raise a compile-time error with the message "source_model list must contain at least one model name".
4. IF `source_model` is neither a string nor a list, THEN THE Macro SHALL raise a compile-time error indicating the expected types (string or list of strings).
5. IF any entry in the `source_model` list is not a non-empty string, THEN THE Macro SHALL raise a compile-time error identifying the invalid entry position and stating that each entry must be a non-empty string.

### Requirement 2: Determine Payload Columns Per Source

**User Story:** As a data engineer, I want the macro to know which payload columns each source model contributes, so that it can correctly NULL-fill missing columns.

#### Acceptance Criteria

1. WHEN a `src_column_map` parameter is provided (a dictionary mapping source model names to their payload column lists), THE Macro SHALL use it to determine which columns each source contributes.
2. WHEN `src_column_map` is not provided and `source_model` is a list, THE Macro SHALL derive each source's available columns by inspecting the compiled relation using `adapter.get_columns_in_relation(ref(model_name))`.
3. THE Macro SHALL compute the superset of payload columns as the distinct union of all columns reported by all sources, excluding system columns (Hash_Key, Hashdiff, Load_Datetime, Record_Source), comparing column names case-insensitively.
4. WHEN `src_payload` is explicitly provided alongside a multi-source `source_model`, THE Macro SHALL treat `src_payload` as the authoritative superset and only NULL-fill columns that are missing from a given source but present in the `src_payload` list.

### Requirement 3: Generate Unioned Source CTE with NULL-Filling

**User Story:** As a data engineer, I want the macro to generate a single unioned CTE from all source models with NULL values for missing columns, so that all rows have a consistent schema.

#### Acceptance Criteria

1. FOR EACH source model in the list, THE Macro SHALL generate a SELECT statement containing all system columns (Hash_Key, Hashdiff, Load_Datetime, Record_Source) and all superset payload columns.
2. WHEN a payload column exists in the source model, THE Macro SHALL select it by its column name.
3. WHEN a payload column does NOT exist in the source model, THE Macro SHALL select `CAST(NULL AS VARCHAR) AS <column_name>` for that column.
4. THE Macro SHALL combine all per-source SELECT statements using `UNION ALL`.
5. THE Macro SHALL apply the `IS NOT NULL` filter on the Hash_Key column for each source's SELECT statement to exclude null-key rows.
6. THE Macro SHALL wrap the combined UNION ALL in a CTE named `source_data` so downstream CTEs can reference it by a stable alias.
7. THE Macro SHALL output columns in a deterministic order: Hash_Key first, then Hashdiff, then payload columns in alphabetical order, then Load_Datetime, then Record_Source.

### Requirement 4: Preserve Satellite Change Detection Logic

**User Story:** As a data engineer, I want the macro to preserve hashdiff-based deduplication, so that only genuinely changed records are inserted into the satellite.

#### Acceptance Criteria

1. THE Macro SHALL apply a `LAG()` window function on the Hashdiff column, partitioned by Hash_Key and ordered by Load_Datetime ascending, using a binary sentinel default value (cast of `0xFFFFFFFF`) as the third argument so that the first record per Hash_Key is always treated as changed.
2. THE Macro SHALL exclude rows where the current Hashdiff equals the value returned by the LAG function, using a Snowflake `QUALIFY` clause with a not-equal (`!=`) comparison.
3. WHILE the model is running in incremental mode, THE Macro SHALL generate a `latest_records` CTE that LEFT OUTER JOINs distinct Hash_Keys from the new source data against the target table, selecting the row with the maximum Load_Datetime per Hash_Key (via `ROW_NUMBER() OVER (PARTITION BY Hash_Key ORDER BY Load_Datetime DESC) = 1`).
4. WHILE the model is running in incremental mode, THE Macro SHALL use the Hashdiff from the `latest_records` CTE (wrapped in `COALESCE` with the binary sentinel default) as the LAG default value, so that a new source record whose Hashdiff matches the most recent target record for the same Hash_Key is excluded.
5. WHEN a Hash_Key appears in the source data that does not exist in the target table, THE Macro SHALL insert its first record unconditionally because the LAG default resolves to the binary sentinel which differs from any computed Hashdiff.

### Requirement 5: Support Incremental Materialization

**User Story:** As a data engineer, I want the macro to support incremental materialization on Snowflake, so that satellite loads are efficient and only process new data.

#### Acceptance Criteria

1. WHEN the model is materialized as `incremental`, THE Macro SHALL generate a `latest_records` CTE that joins the existing target table to the distinct Hash_Key values from the incoming source data and selects the most recent Hashdiff per Hash_Key, determined by `ROW_NUMBER() OVER (PARTITION BY Hash_Key ORDER BY Load_Datetime DESC) = 1` using `QUALIFY`.
2. THE Macro SHALL use `automate_dv.is_any_incremental()` to conditionally wrap all target-table-referencing logic (the `latest_records` CTE and the LEFT JOIN to it in the deduplication step) so that it is only included when the model is running incrementally.
3. WHEN the model is running for the first time or with `--full-refresh`, THE Macro SHALL process all source rows without referencing the target table and SHALL use a sentinel binary value as the LAG default instead of a latest-record lookup.
4. THE Macro SHALL generate SQL compatible with Snowflake's SQL dialect, including support for `QUALIFY`, 3-argument `LAG()`, and `ROW_NUMBER()` window functions.
5. THE Macro SHALL configure the incremental model with an append-only insert strategy (no merge or delete+insert), so that new records are appended to the target table without updating or removing existing rows.

### Requirement 6: Maintain Compatibility with Existing YAML Metadata Pattern

**User Story:** As a data engineer, I want to invoke the macro using the same YAML metadata structure already used in the project, so that satellite model files remain consistent and familiar.

#### Acceptance Criteria

1. THE Macro SHALL accept the same parameters as the automate_dv `sat` macro: `src_pk`, `src_hashdiff`, `src_payload`, `src_extra_columns`, `src_eff`, `src_ldts`, `src_source`, and `source_model`, where `src_extra_columns` and `src_eff` are optional and default to `none` when not provided.
2. THE Macro SHALL accept an additional optional parameter `src_column_map` (a dictionary mapping source model names to their payload column lists) that defaults to `none` when not provided.
3. WHEN invoked from a model file, THE Macro SHALL be callable as `{{ sat_multi_source(...) }}` using named keyword arguments whose values are parsed from a `{%- set yaml_metadata -%}` block via `fromyaml()`, following the same pattern used for the existing `automate_dv.sat()` invocations in the project.
4. THE Macro SHALL be defined as a single `.sql` file in the project's `macros/` directory so that dbt automatically resolves it for all models without requiring additional `packages.yml` entries or path configuration.
5. WHEN `source_model` is provided as a single string (not a list), THE Macro SHALL produce SQL output identical to calling `automate_dv.sat()` with the same parameters, ensuring existing single-source satellite models can migrate to `sat_multi_source` without behavioral changes.
6. IF a required parameter (`src_pk`, `src_hashdiff`, `src_payload`, `src_ldts`, `src_source`, or `source_model`) is not provided or is `none`, THEN THE Macro SHALL raise a compile-time error indicating which required parameter is missing.

### Requirement 7: Handle Edge Cases and Error Conditions

**User Story:** As a data engineer, I want the macro to handle edge cases gracefully, so that unexpected inputs produce clear error messages rather than cryptic SQL failures.

#### Acceptance Criteria

1. IF a source model name in the list does not resolve to a valid relation (i.e., `adapter.get_relation(ref(model_name))` returns `None`), THEN THE Macro SHALL raise a compile-time error via `exceptions.raise_compiler_error()` with a message that includes the failing model name.
2. IF no payload columns can be determined for any source model (all sources have only system columns), THEN THE Macro SHALL raise a compile-time error with the message "No payload columns found across source models".
3. IF `src_column_map` is provided but contains a model name not present in the `source_model` list, THEN THE Macro SHALL ignore that entry and log a warning via `log()` that includes the unrecognized model name and the valid model names from the `source_model` list.
4. IF duplicate column names exist across sources (same column contributed by multiple sources), THEN THE Macro SHALL compare column names case-insensitively and include the column once in the superset without duplication.
5. IF `source_model` is provided as a value that is neither a string nor a list, THEN THE Macro SHALL raise a compile-time error via `exceptions.raise_compiler_error()` with a message indicating that `source_model` must be a string or a list of strings.
6. IF `src_column_map` maps a source model name to an empty list, THEN THE Macro SHALL treat that source as contributing zero payload columns and apply NULL-filling for all superset columns in that source's SELECT statement.

### Requirement 8: Support Optional Effectivity Satellite Columns

**User Story:** As a data engineer, I want the macro to optionally support effectivity date columns, so that it can be used for effectivity satellites as well as standard satellites.

#### Acceptance Criteria

1. WHEN `src_eff` parameter is provided, THE Macro SHALL include it in the selected columns and in the LAG window function ordering (after Load_Datetime).
2. WHEN `src_eff` parameter is not provided, THE Macro SHALL generate the satellite without effectivity date ordering, using only Load_Datetime for the LAG window ORDER BY clause.
3. WHEN `src_extra_columns` parameter is provided as a list or single string, THE Macro SHALL include those columns in the output SELECT alongside payload columns, and include them in the NULL-filling logic if they are absent from a source model.
