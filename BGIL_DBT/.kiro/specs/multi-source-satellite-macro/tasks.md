# Implementation Plan: Multi-Source Satellite Macro

## Overview

Implement the `sat_multi_source` dbt macro as a single Jinja SQL file in the `macros/` directory. The macro extends automate_dv's `sat` macro to accept a list of source models with non-identical payload columns, generating a unioned `source_data` CTE with NULL-filling while preserving hashdiff-based change-detection logic and supporting Snowflake incremental materialization.

## Tasks

- [x] 1. Implement the core `sat_multi_source` macro
  - [x] 1.1 Create `macros/sat_multi_source.sql` with macro signature, input validation, and single-string delegation
    - Create the file `macros/sat_multi_source.sql`
    - Define the macro signature: `sat_multi_source(src_pk, src_hashdiff, src_payload, src_extra_columns=none, src_eff=none, src_ldts, src_source, source_model, src_column_map=none)`
    - Implement required parameter validation using `exceptions.raise_compiler_error()` for missing `src_pk`, `src_hashdiff`, `src_payload`, `src_ldts`, `src_source`, `source_model`
    - Implement type checking: raise error if `source_model` is neither a string nor a list
    - Implement single-string delegation: when `source_model` is a string, call `{{ automate_dv.sat(src_pk=src_pk, src_hashdiff=src_hashdiff, src_payload=src_payload, src_extra_columns=src_extra_columns, src_eff=src_eff, src_ldts=src_ldts, src_source=src_source, source_model=source_model) }}`
    - Implement list validation: raise error for empty list, raise error for non-string entries with position info
    - _Requirements: 1.2, 1.3, 1.4, 1.5, 6.1, 6.5, 6.6, 7.5_

  - [x] 1.2 Implement column resolution logic (explicit `src_column_map` and adapter introspection)
    - When `src_column_map` is provided, use it to populate per-source column lists
    - When `src_column_map` is not provided, call `adapter.get_columns_in_relation(ref(model_name))` for each source model
    - Log a warning via `log()` when `src_column_map` contains model names not in the `source_model` list
    - Validate each model resolves to a valid relation; raise compile-time error with model name if it doesn't
    - Handle the case where `src_column_map` maps a model to an empty list (treat as zero payload columns)
    - _Requirements: 2.1, 2.2, 7.1, 7.3, 7.6_

  - [x] 1.3 Implement superset column computation and NULL-fill SELECT generation
    - Compute superset as case-insensitive distinct union of all payload columns, excluding system columns (`src_pk`, `src_hashdiff`, `src_ldts`, `src_source`, `src_eff`)
    - When `src_payload` is provided, use it as the authoritative superset
    - Include `src_extra_columns` in the superset and apply NULL-filling if absent from a source
    - Sort payload columns alphabetically for deterministic output
    - Raise error if no payload columns are found across all sources
    - Generate per-source SELECT statements: select column directly if present, `CAST(NULL AS VARCHAR) AS <col>` if absent
    - Apply `WHERE <src_pk> IS NOT NULL` filter on each source SELECT
    - Combine with `UNION ALL` and wrap in `source_data` CTE
    - Output column order: src_pk, src_hashdiff, sorted payload columns, src_eff (if provided), src_ldts, src_source
    - _Requirements: 2.3, 2.4, 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 7.2, 7.4, 8.3_

  - [x] 1.4 Implement change-detection CTEs and incremental logic
    - Use `automate_dv.is_any_incremental()` to conditionally include incremental-mode logic
    - Generate `latest_records` CTE: join `{{ this }}` to distinct `src_pk` from `source_data`, qualify with `ROW_NUMBER() OVER (PARTITION BY src_pk ORDER BY src_ldts DESC) = 1`
    - Generate `unique_source_records` CTE: SELECT all columns from `source_data`, LEFT JOIN `latest_records` in incremental mode
    - Apply `QUALIFY src_hashdiff != LAG(src_hashdiff, 1, COALESCE(lr.src_hashdiff, CAST('FFFFFFFF' AS BINARY(4)))) OVER (PARTITION BY src_pk ORDER BY src_ldts ASC)` in incremental mode
    - Apply `QUALIFY src_hashdiff != LAG(src_hashdiff, 1, CAST('FFFFFFFF' AS BINARY(4))) OVER (PARTITION BY src_pk ORDER BY src_ldts ASC)` in full-refresh mode
    - When `src_eff` is provided, include it in the LAG window ORDER BY clause
    - Generate `records_to_insert` CTE and final `SELECT * FROM records_to_insert`
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 5.1, 5.2, 5.3, 5.4, 8.1, 8.2_

- [x] 2. Checkpoint - Verify macro compiles
  - Ensure the macro file has no Jinja syntax errors by running `dbt compile` on a test model, ask the user if questions arise.

- [x] 3. Create test satellite model using the macro
  - [x] 3.1 Create a test satellite model file that invokes `sat_multi_source` with multiple sources
    - Create a model file (e.g., `models/raw_vault/partner/augmented/satellites/sat_agreement_multi_test.sql`) that uses `sat_multi_source` with a YAML metadata block
    - Define `source_model` as a list of two or more existing staging models
    - Provide `src_column_map` with the known payload columns per source
    - Set materialization to `incremental` with appropriate config
    - Verify it compiles successfully with `dbt compile --select sat_agreement_multi_test`
    - _Requirements: 5.5, 6.3, 6.4_

  - [x] 3.2 Write dbt singular tests for error conditions
    - Create test SQL files in `tests/` that validate compile-time error messages
    - Test empty list error: `source_model = []`
    - Test invalid type error: `source_model = 123`
    - Test missing required parameter errors
    - Test non-existent model reference error
    - _Requirements: 1.3, 1.4, 1.5, 6.6, 7.1, 7.2_

- [x] 4. Create integration validation model for single-string backward compatibility
  - [x] 4.1 Create a validation model that uses `sat_multi_source` with a single string source_model
    - Create a model file that uses `sat_multi_source` with `source_model` as a single string (not a list)
    - Compile both the `sat_multi_source` version and an equivalent `automate_dv.sat()` version
    - Verify the compiled SQL output is identical (single-string delegation)
    - _Requirements: 1.2, 6.5_

  - [x] 4.2 Write a dbt test comparing outputs of both approaches
    - Create a test that runs both macros with identical parameters on the same source model
    - Assert the generated SQL or query results are equivalent
    - _Requirements: 1.2, 6.5_

- [x] 5. Checkpoint - Verify end-to-end functionality
  - Run `dbt compile` and `dbt run` on the test models to verify correct SQL generation and data loading, ask the user if questions arise.

- [x] 6. Wire macro into existing satellite models
  - [x] 6.1 Migrate an existing multi-source satellite to use `sat_multi_source`
    - Identify an existing satellite that currently uses a manual union view (e.g., `stg2_aug_sat_agreement_union.sql`)
    - Replace the union view + `automate_dv.sat()` pattern with a direct `sat_multi_source()` call with source_model as a list
    - Update the YAML metadata block with `src_column_map` if needed
    - Verify the compiled SQL output matches expected structure
    - _Requirements: 1.1, 6.3, 6.4_

  - [x] 6.2 Write integration test comparing old and new approaches
    - Run the satellite with both approaches and verify row-level data equivalence
    - Ensure incremental loads produce the same results
    - _Requirements: 4.1, 5.1, 5.5_

- [x] 7. Final checkpoint - Full validation
  - Run `dbt compile` and `dbt run` on all affected models, ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- The macro is implemented as a single file (`macros/sat_multi_source.sql`) following the project's existing macro style (simple, self-contained files like `hash.sql`)
- All SQL targets Snowflake dialect (QUALIFY, 3-argument LAG, ROW_NUMBER)
- The design does NOT include a Correctness Properties section suitable for automated property-based testing in this context — the "properties" in the design describe expected macro behavior that is best validated through compilation and integration tests rather than a PBT library
- `src_column_map` is recommended for production use to avoid runtime adapter introspection overhead

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1"] },
    { "id": 1, "tasks": ["1.2"] },
    { "id": 2, "tasks": ["1.3"] },
    { "id": 3, "tasks": ["1.4"] },
    { "id": 4, "tasks": ["3.1", "4.1"] },
    { "id": 5, "tasks": ["3.2", "4.2"] },
    { "id": 6, "tasks": ["6.1"] },
    { "id": 7, "tasks": ["6.2"] }
  ]
}
```
