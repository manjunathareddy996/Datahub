{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_POLICY_DISCOUNT_LOADING_APPLIED, table 'BJAZ_HEALTH_WEBSERVICE_INFO' (union branch, no attribute-level merge needed).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_health_webservice_info'
hashed_columns:
  POLICY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'AMOUNT_APPLIED'
      - 'PERCENTAGE_APPLIED'
derived_columns:
  PARENT_BK: 'policy_ref'
  PARENT_NK: "'HUB_POLICY|' || (policy_ref)"
  ITEM_CODE_CK: '!'
  AMOUNT_APPLIED: 'other_discount'
  PERCENTAGE_APPLIED: 'commercial_discount_per'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HEALTH_WEBSERVICE_INFO'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
