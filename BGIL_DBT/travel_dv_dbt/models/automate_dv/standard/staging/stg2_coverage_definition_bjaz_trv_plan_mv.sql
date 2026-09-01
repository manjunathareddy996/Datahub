{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for SAT_COVERAGE_DEFINITION, table 'BJAZ_TRV_PLAN_MV'.

{%- set yaml_metadata -%}
source_model: 'stg_travel__bjaz_trv_plan_mv'
hashed_columns:
  COVERAGE_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'COVERAGE_DESCRIPTION'
      - 'PERIL_COVERED'
derived_columns:
  PARENT_BK: 'cover_code'
  PARENT_NK: "'HUB_COVERAGE|' || (cover_code)"
  COVERAGE_DESCRIPTION: 'cover_desc'
  PERIL_COVERED: 'type_of_claim'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!BJAZ_TRV_PLAN_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
