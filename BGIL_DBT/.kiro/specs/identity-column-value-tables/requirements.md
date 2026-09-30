# Requirements Document

## Introduction

The PRIMARY AIM of this feature is to reduce the record count in the satellite layer for high-value identity references by storing each party's identity references EXACTLY ONCE (one row per party), instead of once per source. Today the shared wide multi-source satellite `sat_party_identification` (grain `PARTY_HKEY` + `HASHDIFF` + `RECORD_SOURCE`) stores the raw identity values (PAN, Passport, GSTIN, Aadhaar) inline as payload columns, so the same value is duplicated across one row per source and intermixed with unrelated attributes. This feature moves the multi-source identity detail into dedicated value tables and introduces a new slim per-party satellite that holds only the identity hash references, one row per party.

The feature introduces THREE model types:

1. **Value tables** (one per in-scope Identity_Column: PAN, Passport, GSTIN, Aadhaar). Grain is one row per party per source, i.e. `Column_Hash` (= `PARTY_HKEY`) + `RECORD_SOURCE`. Each value table stores the single raw Identity value column plus `Column_Hash`, `RECORD_SOURCE`, `LOAD_DATETIME` (and the project's run-timestamp convention). Populated from ALL contributing source tables for that column. This is where the multi-source detail lives.

2. **A NEW identity-hash satellite** (a NEW model). Grain is one row per `PARTY_HKEY` (NOT per source). It holds ONLY the identity hash reference columns: `PAN_CARD_HASH`, `PASSPORT_HASH`, `GSTIN_HASH`, `AADHAAR_CARD_HASH` — each equal to `PARTY_HKEY`. Its purpose is to have FEWER records than the existing per-source satellite. Consumers join `<COLUMN>_HASH` to the corresponding value table's `<COLUMN>_HASH` to get all source rows and values. Because every `<COLUMN>_HASH` equals `PARTY_HKEY`, this reference is deterministic per party. If a party has no non-empty value for a given column across all sources, that column's `<COLUMN>_HASH` is `NULL` (so the reference is dangling-free); otherwise it carries `PARTY_HKEY`.

3. **The EXISTING satellite `sat_party_identification`** (unchanged grain `PARTY_HKEY` + `HASHDIFF` + `RECORD_SOURCE`, still per-source). The four in-scope raw identity columns (`PANNUMBER`, `PASSPORTNUMBER`, `GSTIN`, `AADHAARNUMBER`) are REMOVED from it — they now live in the value tables. All remaining non-identity columns stay unchanged and per-source: `GSTTAXPAYERTYPE`, `GSTREGISTRATIONSTATUS`, `AGEPROOFTYPE`, `EIANUMBER`, `IDENTIFICATIONNUMBER`, `TANNUMBER`, `VATREGISTRATIONNUMBER`. Its hashdiff basis drops the removed raw identity columns. The in-scope raw identity columns are NOT replaced by `<COLUMN>_HASH` columns inside this existing per-source satellite; the `<COLUMN>_HASH` references live in the NEW per-party identity-hash satellite instead.

The `<COLUMN>_HASH` reference is not a new value-derived hash: it reuses the existing party hub primary-key hash `PARTY_HKEY`, which is already computed in the party hub, in the satellite, and in every `stg2_sat_<source>__<subject>` staging model via the automate_dv `hashed_columns: PARTY_HKEY: 'PARENT_NK'` configuration. The value of each `<COLUMN>_HASH` column IS the `PARTY_HKEY` value for the owning party. Because the key is the party hash rather than a value-derived hash, there is no value-level dedup across parties: identical identity values belonging to different parties keep distinct `<COLUMN>_HASH` keys. Within a value table, the same identity value for the same party observed across N sources produces N rows sharing that party's `<COLUMN>_HASH`, distinguished by `RECORD_SOURCE`.

Columns in scope for this pass are PAN Card, Passport, GSTIN, and Aadhaar Card, because they already exist in the satellite. Voter ID, CKYC Number, and Mobile Number are explicitly out of scope for this pass because they are not yet available as attributes. The implementation must reuse the project's existing conventions: the `sat_multi_source()` macro, the `stg2_sat_<source>__<subject>` staging model naming, automate_dv hashing (including the existing `PARTY_HKEY` hash), incremental merge configuration, and the YAML-in-Jinja metadata pattern.

## Assumptions and Future Considerations

The user has confirmed that the `sat_party_identification` Satellite's `incremental_strategy` is expected to change from `merge` to `append` in the future. This change is not part of the current pass's implementation, but the design of this feature must not depend on merge-only semantics such as upsert or dedup-by-`unique_key` behavior. The Value_Table, the Identity_Hash_Satellite, and the existing Satellite must remain correct and idempotent under an `append` strategy as well, so the design must avoid patterns that silently break when duplicate keys can accumulate under `append`.

## Glossary

- **Satellite**: The existing Data Vault 2.0 satellite model `sat_party_identification` that stores descriptive party attributes at grain `PARTY_HKEY` + `HASHDIFF` + `RECORD_SOURCE`. After this feature, it no longer stores the in-scope raw identity columns.
- **Identity_Hash_Satellite**: The NEW slim satellite model, at grain one row per `PARTY_HKEY`, that stores ONLY the identity hash reference columns (`PAN_CARD_HASH`, `PASSPORT_HASH`, `GSTIN_HASH`, `AADHAAR_CARD_HASH`), each equal to `PARTY_HKEY`. Its purpose is to store the identity references once per party rather than once per source, reducing record count.
- **Identity_Column**: A high-value personal or organizational identifier stored as a payload attribute. In-scope identity columns are `PANNUMBER`, `PASSPORTNUMBER`, `GSTIN`, and `AADHAARNUMBER`.
- **Value_Table**: A dedicated single-column Data Vault table that stores exactly one Identity_Column's raw value, keyed by the Column_Hash reference, at grain one row per party per source.
- **Party_Hash**: The existing party hub primary-key hash `PARTY_HKEY`, computed via the automate_dv configuration `hashed_columns: PARTY_HKEY: 'PARENT_NK'` in the party hub, in the Satellite, and in every Stg2_Model. This hash already exists in the project and is not newly introduced by this feature.
- **Column_Hash**: The identity hash reference column, named with the `<column_name>_hash` pattern (for example `PAN_CARD_HASH`, `PASSPORT_HASH`, `GSTIN_HASH`, `AADHAAR_CARD_HASH`). The value held in a Column_Hash column IS the Party_Hash (`PARTY_HKEY`) value for the owning party. The same Column_Hash column is used in the Identity_Hash_Satellite and in the corresponding Value_Table, and both hold the Party_Hash value. The Column_Hash does NOT appear in the existing per-source Satellite.
- **Stg2_Model**: A per-table staging model following the `stg2_sat_<source>__<subject>` naming convention that prepares hashed and derived columns for a downstream Data Vault model via `automate_dv.stage()`.
- **Sat_Multi_Source_Macro**: The existing custom macro `sat_multi_source()` that unions multiple staging models with per-source column maps, NULL-fills missing columns, and applies hashdiff-based change detection with incremental support.
- **Source_Table**: A staging source that feeds one or more Identity_Columns (for example `stg2_sat_bjaz_clm_supp_extn__party_identification`).
- **Record_Source**: A metadata column identifying the originating system or table for a record.
- **Load_Datetime**: The `LOAD_DATETIME` timestamp column indicating when a record was loaded into the Data Vault.
- **Null_Or_Empty_Value**: An Identity_Column value that is SQL `NULL`, an empty string, or a string containing only whitespace after trimming.
- **Round_Trip**: The property that a value written into a Value_Table can be recovered unchanged by joining the Column_Hash stored in the Identity_Hash_Satellite back to the Value_Table.

## Requirements

### Requirement 1: Create Dedicated Value Tables Per In-Scope Identity Column

**User Story:** As a data engineer, I want each in-scope identity column to have its own dedicated single-column value table, so that identity values are isolated from unrelated attributes and referenced by a party hash key.

#### Acceptance Criteria

1. THE Feature SHALL create one Value_Table for each in-scope Identity_Column: PAN (`PANNUMBER`), Passport (`PASSPORTNUMBER`), GSTIN (`GSTIN`), and Aadhaar (`AADHAARNUMBER`).
2. THE Feature SHALL define each Value_Table to store exactly one Identity_Column value column plus system columns (Column_Hash, Load_Datetime, Record_Source).
3. THE Feature SHALL name each Value_Table and its Column_Hash consistently with the existing raw vault naming conventions used in the `partner_dv_dbt` project, using the `<column_name>_hash` pattern for the Column_Hash (for example `PAN_CARD_HASH`, `PASSPORT_HASH`, `GSTIN_HASH`, `AADHAAR_CARD_HASH`).
4. WHERE an Identity_Column is out of scope for this pass (Voter ID, CKYC Number, Mobile Number), THE Feature SHALL NOT create a Value_Table for that column.
5. THE Feature SHALL place each Value_Table model in the raw vault directory structure consistent with the location of existing satellite models in the `partner_dv_dbt` project.

### Requirement 2: Reuse the Party Hash as the Column Hash Reference

**User Story:** As a data engineer, I want each value table's key and each identity-hash-satellite reference to reuse the existing party hub hash `PARTY_HKEY`, so that no new hashing algorithm is introduced and the reference always resolves to the owning party.

#### Acceptance Criteria

1. THE Feature SHALL set each Column_Hash value equal to the existing Party_Hash (`PARTY_HKEY`) value produced by the automate_dv `hashed_columns: PARTY_HKEY: 'PARENT_NK'` configuration, and SHALL NOT introduce a new hash derived from the Identity_Column value.
2. WHEN the same Identity_Column value for the same party is observed across two or more Source_Tables, THE Feature SHALL produce an identical Column_Hash for that party in every Source_Table, because the Party_Hash is identical for that party.
3. WHEN two Identity_Column values belong to two different parties, THE Feature SHALL produce different Column_Hash values for those two rows, because their Party_Hash values differ; identical values belonging to different parties SHALL NOT collapse to a single Column_Hash.
4. THE Feature SHALL apply a single, documented normalization rule (for example trimming surrounding whitespace and applying a consistent letter case) to the Identity_Column value that is stored in the Value_Table, and SHALL apply that same rule identically wherever the raw value is materialized.

### Requirement 3: Value Table Grain Is One Row Per Party Per Source

**User Story:** As a data engineer, I want each value table to keep one row per party per source, keyed by the party hash, so that I retain source lineage without duplicating the value across unrelated attributes.

#### Acceptance Criteria

1. THE Value_Table SHALL store one row per distinct combination of Column_Hash (= Party_Hash) and Record_Source.
2. WHEN a single Identity_Column value for the same party is observed in three distinct Source_Tables, THE Value_Table SHALL contain three rows for that party, and all three rows SHALL share the same Column_Hash.
3. WHEN identical Identity_Column values belong to two different parties, THE Value_Table SHALL store separate rows keyed by each party's distinct Column_Hash, and SHALL NOT merge them into one key.
4. THE Value_Table SHALL include the Record_Source column to distinguish the source of each row.
5. THE Value_Table SHALL process all Source_Tables that feed each in-scope Identity_Column, not only `BJAZ_CLM_SUPP_EXTN`.
6. WHEN the same value for the same party from the same Source_Table is loaded again with unchanged content, THE Value_Table SHALL NOT create a duplicate row for that unchanged content (idempotent load).

### Requirement 4: Populate Value Tables From All Contributing Sources

**User Story:** As a data engineer, I want each value table to be populated from every staging source that provides its identity column, so that no source's values are lost.

#### Acceptance Criteria

1. THE Feature SHALL populate the PAN Value_Table from every Source_Table that provides `PANNUMBER`, including `stg2_sat_bjaz_clm_supp_extn__party_identification`, `stg2_sat_bjaz_ctngy_pa_mem_dtls__party_identification`, and `stg2_sat_bjaz_intermediary__party_identification`.
2. THE Feature SHALL populate the Passport Value_Table from every Source_Table that provides `PASSPORTNUMBER`, including `stg2_sat_bjaz_ctngy_ff_dtls_extn__party_identification`, `stg2_sat_bjaz_ctngy_pa_mem_dtls__party_identification`, and `stg2_sat_bjaz_starpkg_ff_dtls__party_identification`.
3. THE Feature SHALL populate the GSTIN Value_Table from every Source_Table that provides `GSTIN`, including `stg2_sat_bjaz_intermediary__party_identification`.
4. THE Feature SHALL populate the Aadhaar Value_Table from every Source_Table that provides `AADHAARNUMBER`, including `stg2_sat_bjaz_ctngy_pa_mem_dtls__party_identification`.
5. WHERE a Source_Table does not provide a given in-scope Identity_Column, THE Feature SHALL exclude that Source_Table from that column's Value_Table.
6. WHEN a new Source_Table that provides an in-scope Identity_Column is added later, THE Feature SHALL allow that Source_Table to be added to the relevant Value_Table by following the existing staging and metadata conventions without altering the Value_Table's grain.

### Requirement 5: Remove the Raw Identity Columns From the Existing Satellite

**User Story:** As a data engineer, I want the existing per-source satellite to stop storing the raw identity values, so that those values live only in the dedicated value tables and the satellite carries only its remaining non-identity attributes.

#### Acceptance Criteria

1. THE Satellite SHALL remove the four in-scope raw Identity_Columns (`PANNUMBER`, `PASSPORTNUMBER`, `GSTIN`, `AADHAARNUMBER`) as payload columns.
2. THE Satellite SHALL NOT gain any Column_Hash (`<COLUMN>_HASH`) columns for the in-scope Identity_Columns; those reference columns live in the Identity_Hash_Satellite instead.
3. THE Satellite SHALL retain all remaining non-identity payload columns unchanged and per-source, including `GSTTAXPAYERTYPE`, `GSTREGISTRATIONSTATUS`, `AGEPROOFTYPE`, `EIANUMBER`, `IDENTIFICATIONNUMBER`, `TANNUMBER`, and `VATREGISTRATIONNUMBER`.
4. THE Satellite SHALL retain its existing grain of `PARTY_HKEY` + `HASHDIFF` + `RECORD_SOURCE`.
5. WHEN an in-scope Identity_Column contributes to the Satellite hashdiff today, THE Feature SHALL update the hashdiff basis to drop that raw identity column so it no longer participates in change detection.
6. THE Feature SHALL leave the Satellite's `RECORD_SOURCE` and Load_Datetime handling for the retained columns unchanged.

### Requirement 6: Create the New Per-Party Identity-Hash Satellite

**User Story:** As a data engineer, I want a new slim satellite that stores each party's identity references exactly once, so that the satellite layer holds far fewer records than the old per-source storage while still resolving to the value tables.

#### Acceptance Criteria

1. THE Feature SHALL create a NEW Identity_Hash_Satellite model whose grain is one row per `PARTY_HKEY` (one row per party), with `unique_key` = `PARTY_HKEY`.
2. THE Identity_Hash_Satellite SHALL store ONLY the identity hash reference columns `PAN_CARD_HASH`, `PASSPORT_HASH`, `GSTIN_HASH`, and `AADHAAR_CARD_HASH`, alongside `PARTY_HKEY` and standard load metadata.
3. THE Identity_Hash_Satellite SHALL set each `<COLUMN>_HASH` value equal to the party's `PARTY_HKEY` value when that party has at least one non-empty value for the corresponding Identity_Column across all Source_Tables.
4. IF a party has no non-empty value for a given Identity_Column across all Source_Tables, THEN THE Identity_Hash_Satellite SHALL set that party's `<COLUMN>_HASH` to `NULL`, so that the reference is dangling-free.
5. THE Identity_Hash_Satellite SHALL contain strictly fewer records than the count of per-source rows previously used to store the in-scope identity columns for parties observed in more than one Source_Table (one row per party, not per source).
6. THE Identity_Hash_Satellite SHALL populate each `<COLUMN>_HASH` from the same Party_Hash (`PARTY_HKEY`) value used by the corresponding Value_Table, so that the Identity_Hash_Satellite's `<COLUMN>_HASH` matches the Value_Table's `<COLUMN>_HASH` for the same party.

### Requirement 7: Provide the Join and Backfill Path

**User Story:** As a data consumer, I want to recover an identity value by joining the identity-hash satellite's party hash to the dedicated value table, so that I can retrieve the value and its source rows on demand.

#### Acceptance Criteria

1. WHEN a consumer joins `Identity_Hash_Satellite.<COLUMN>_HASH` to `Value_Table.<COLUMN>_HASH` for an in-scope Identity_Column, THE Feature SHALL return the raw value(s) for that party.
2. WHEN a single `<COLUMN>_HASH` corresponds to values observed for that party in multiple Source_Tables, THE join SHALL return one row per Source_Table for that `<COLUMN>_HASH`.
3. FOR ALL non-null, non-empty in-scope Identity_Column values loaded into a Value_Table, joining the Identity_Hash_Satellite's stored `<COLUMN>_HASH` back to the Value_Table SHALL recover a value equal to the normalized original value for that party (Round_Trip property).
4. THE Feature SHALL document the join key column name and relationship for each in-scope Identity_Column so consumers can construct the backfill query.

### Requirement 8: Populate Load Metadata

**User Story:** As a data engineer, I want each value table and the identity-hash satellite to carry standard load metadata, so that rows are auditable and consistent with the rest of the raw vault.

#### Acceptance Criteria

1. THE Value_Table SHALL include a `LOAD_DATETIME` column populated from the contributing Stg2_Model's Load_Datetime, consistent with existing raw vault models.
2. THE Value_Table SHALL include a `RECORD_SOURCE` column populated using the same Record_Source mapping convention used by the Satellite's `src_record_source_map`.
3. THE Value_Table SHALL populate Load_Datetime and Record_Source for every row it stores.
4. WHERE the existing project convention stamps a run timestamp column (for example `DBT_RUN_TS`), THE Feature SHALL apply the same stamping convention to the Value_Table and to the Identity_Hash_Satellite.
5. THE Identity_Hash_Satellite SHALL include a `LOAD_DATETIME` column populated consistent with existing raw vault models.

### Requirement 9: Handle Null and Empty Values

**User Story:** As a data engineer, I want null and empty identity values to be handled explicitly, so that they do not create meaningless rows or dangling references.

#### Acceptance Criteria

1. IF an Identity_Column value is a Null_Or_Empty_Value, THEN THE Value_Table SHALL exclude that value and SHALL NOT create a row for it.
2. IF a party has no non-empty value for an Identity_Column across all Source_Tables, THEN THE Identity_Hash_Satellite SHALL store a Null `<COLUMN>_HASH` for that column for that party rather than referencing a nonexistent Value_Table row.
3. WHEN an Identity_Column value is present in one Source_Table and a Null_Or_Empty_Value in another Source_Table for the same party, THE Feature SHALL create a Value_Table row only for the Source_Table that provided the non-empty value, and THE Identity_Hash_Satellite SHALL set that party's `<COLUMN>_HASH` to `PARTY_HKEY` (because at least one non-empty value exists).
4. THE Feature SHALL apply the Null_Or_Empty_Value determination consistently in both the Value_Table and the Identity_Hash_Satellite reference, using the normalization rule from Requirement 2.

### Requirement 10: Follow Existing Project Conventions

**User Story:** As a data engineer, I want the new models to follow existing project conventions, so that they are consistent, maintainable, and buildable within the current dbt project.

#### Acceptance Criteria

1. THE Feature SHALL create per-source staging models following the `stg2_sat_<source>__<subject>` naming convention, materialized as views using `automate_dv.stage()` with `hashed_columns` (including the existing `PARTY_HKEY: 'PARENT_NK'` hash) and `derived_columns` metadata blocks, consistent with existing `stg2` models.
2. THE Feature SHALL build each Value_Table using the existing `sat_multi_source()` macro with a `source_model` list, `src_column_map`, and `src_record_source_map`, consistent with the Satellite's current invocation.
3. THE Feature SHALL configure each Value_Table with `materialized='incremental'`, `incremental_strategy='merge'`, `on_schema_change='append_new_columns'`, and a `unique_key` consistent with the Value_Table grain defined in Requirement 3.
4. THE Feature SHALL configure the Identity_Hash_Satellite with `materialized='incremental'`, `incremental_strategy='merge'`, `on_schema_change='append_new_columns'`, and `unique_key` = `PARTY_HKEY` consistent with the per-party grain defined in Requirement 6.
5. THE Feature SHALL define contributing source models and metadata using the same YAML-in-Jinja pattern (`{%- set yaml_metadata -%}` parsed via `fromyaml()`) used by existing models.
6. THE Feature SHALL produce models that compile within the existing `partner_dv_dbt` dbt project without requiring new package dependencies.
7. WHERE the Satellite adopts `incremental_strategy='append'` in a future pass, THE Feature SHALL preserve the Round_Trip and no-dangling-reference correctness of the Value_Table and Identity_Hash_Satellite without depending on merge-specific upsert or dedup-by-`unique_key` behavior.
