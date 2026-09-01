{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for SAT_PRODUCT_DEFINITION, table 'BA_TRV_PLAN_MST_MV'.

{%- set yaml_metadata -%}
source_model: 'stg_travel__ba_trv_plan_mst_mv'
hashed_columns:
  PRODUCT_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PRODUCT_STATUS'
      - 'PRODUCT_CATEGORY'
      - 'PRODUCT_DISPLAY_NAME'
      - 'PRODUCT_NAME'
      - 'PRODUCT_CODE'
derived_columns:
  PARENT_BK: 'plan_no'
  PARENT_NK: "'HUB_PRODUCT|' || (plan_no)"
  PRODUCT_STATUS: 'active_status'
  PRODUCT_CATEGORY: 'plan_category_name'
  PRODUCT_DISPLAY_NAME: 'plan_disp_name'
  PRODUCT_NAME: 'plan_name'
  PRODUCT_CODE: 'product_4digit_code'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!BA_TRV_PLAN_MST_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
