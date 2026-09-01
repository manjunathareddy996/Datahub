{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for SAT_PRODUCT_DEFINITION, table 'BA_TRV_DATA_POLICY_DTLS_MV'.

{%- set yaml_metadata -%}
source_model: 'stg_travel__ba_trv_data_policy_dtls_mv'
hashed_columns:
  PRODUCT_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PRODUCT_CATEGORY'
      - 'PRODUCT_NAME'
derived_columns:
  PARENT_BK: 'product_code'
  PARENT_NK: "'HUB_PRODUCT|' || (product_code)"
  PRODUCT_CATEGORY: 'travel_category_nm'
  PRODUCT_NAME: 'travel_plan_nm'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BA_TRV_DATA_POLICY_DTLS_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
