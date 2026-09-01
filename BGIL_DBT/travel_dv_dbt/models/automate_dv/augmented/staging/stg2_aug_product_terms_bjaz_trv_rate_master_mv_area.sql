{{ config(materialized='view') }}

-- TRAVEL AUGMENTED per-table stage() for SAT_AUG_PRODUCT_TERMS, table 'BJAZ_TRV_RATE_MASTER_MV'.

{%- set yaml_metadata -%}
source_model: 'stg_travel__bjaz_trv_rate_master_mv'
hashed_columns:
  PRODUCT_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PLAN_GEOGRAPHICAL_ZONE'
derived_columns:
  PARENT_BK: 'plan'
  PARENT_NK: "'HUB_PRODUCT|' || (plan)"
  PLAN_GEOGRAPHICAL_ZONE: 'area'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!BJAZ_TRV_RATE_MASTER_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
