{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for SAT_PRODUCT_TERMS, table 'BA_TRV_PLAN_MST_MV'.

{%- set yaml_metadata -%}
source_model: 'stg_travel__ba_trv_plan_mst_mv'
hashed_columns:
  PRODUCT_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'GEOGRAPHY_RESTRICTION'
      - 'FAMILY_DEFINITION'
      - 'MAXIMUM_ENTRY_AGE'
      - 'MAXIMUM_POLICY_TERM'
      - 'MINIMUM_ENTRY_AGE'
      - 'MINIMUM_POLICY_TERM'
derived_columns:
  PARENT_BK: 'plan_no'
  PARENT_NK: "'HUB_PRODUCT|' || (plan_no)"
  GEOGRAPHY_RESTRICTION: 'area_code_nos'
  FAMILY_DEFINITION: 'family_plan_yn'
  MAXIMUM_ENTRY_AGE: 'plan_max_age_to'
  MAXIMUM_POLICY_TERM: 'plan_max_days'
  MINIMUM_ENTRY_AGE: 'plan_min_age_from'
  MINIMUM_POLICY_TERM: 'plan_min_days'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BA_TRV_PLAN_MST_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
