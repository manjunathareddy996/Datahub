{{ config(materialized='view') }}

-- TRAVEL AUGMENTED per-table stage() for SAT_AUG_COVERAGE_DEFINITION, table 'BJAZ_TRV_PLAN_MV'.

{%- set yaml_metadata -%}
source_model: 'stg_travel__bjaz_trv_plan_mv'
hashed_columns:
  COVERAGE_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'COVERAGE_SEQUENCE'
derived_columns:
  PARENT_BK: 'cover_code'
  PARENT_NK: "'HUB_COVERAGE|' || (cover_code)"
  COVERAGE_SEQUENCE: 'sequence_covers'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_TRV_PLAN_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
