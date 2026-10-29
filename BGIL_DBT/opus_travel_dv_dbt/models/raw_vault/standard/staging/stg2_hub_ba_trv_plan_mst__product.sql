{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for HUB_PRODUCT branch 'BA_TRV_PLAN_MST'.

{%- set yaml_metadata -%}
source_model: 'stg_travel__ba_trv_plan_mst'
hashed_columns:
  PRODUCT_HKEY: 'PARENT_NK'
derived_columns:
  PARENT_BK: 'plan_no'
  PARENT_NK: "'HUB_PRODUCT|' || (plan_no)"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_BA_TRV_PLAN_MST'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
