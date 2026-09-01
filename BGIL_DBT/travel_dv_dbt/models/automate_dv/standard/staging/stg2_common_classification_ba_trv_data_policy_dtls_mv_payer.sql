{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for SAT_COMMON_CLASSIFICATION, table 'BA_TRV_DATA_POLICY_DTLS_MV' (payer anchor).

{%- set yaml_metadata -%}
source_model: 'stg_travel__ba_trv_data_policy_dtls_mv'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CATEGORY_CODE'
derived_columns:
  PARENT_BK: 'payer_part_id'
  PARENT_NK: "'HUB_PARTY|' || (payer_part_id)"
  CATEGORY_CODE: 'user_type'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BA_TRV_DATA_POLICY_DTLS_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
