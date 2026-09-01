{{ config(materialized='view') }}

-- TRAVEL AUGMENTED per-table stage() for SAT_AUG_PRODUCT_TERMS, table 'BA_TRV_PLAN_MST_MV'.

{%- set yaml_metadata -%}
source_model: 'stg_travel__ba_trv_plan_mst_mv'
hashed_columns:
  PRODUCT_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'MULTI_YEAR_INDICATOR'
derived_columns:
  PARENT_BK: 'plan_no'
  PARENT_NK: "'HUB_PRODUCT|' || (plan_no)"
  MULTI_YEAR_INDICATOR: 'multi_year_yn'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BA_TRV_PLAN_MST_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
