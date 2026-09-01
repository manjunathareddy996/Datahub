{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for SAT_COVERAGE_DEFINITION, benefit
-- branch 'ACCHOSPEXP' on 'BJAZ_TRV_LOADER_DATA_MV'. Reuses the exact COVERAGE_HKEY
-- formula from stg2_hub_bjaz_trv_loader_data_mv__coverage_acchospexp.sql.

-- Cover Code: TRV_ACC_HOSP_EXP (Accidental Hospitalization Expense) -- from the mapper's Benefit Catalog sheet (round 3).

{%- set yaml_metadata -%}
source_model: 'stg_travel__bjaz_trv_loader_data_mv'
hashed_columns:
  COVERAGE_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'FREE_COVER_LIMIT'
derived_columns:
  PARENT_BK: "policy_ref || '|' || 'TRV_ACC_HOSP_EXP'"
  PARENT_NK: "'HUB_COVERAGE|' || (policy_ref || '|' || 'TRV_ACC_HOSP_EXP')"
  FREE_COVER_LIMIT: 'acchospexp'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!BJAZ_TRV_LOADER_DATA_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
