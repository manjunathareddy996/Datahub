{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_LNK_ROLE_TPA, table 'BJAZ_TPA_CLAIM_DETAILS_WS' (single contributing table).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_tpa_claim_details_ws'
hashed_columns:
  PARTY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'TPA_CODE'
derived_columns:
  PARENT_BK: 'customer_id'
  PARENT_NK: "'HUB_PARTY|' || (customer_id)"
  ROLE_TYPE_CK: '!TPA'
  TPA_CODE: 'tpa_id'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_TPA_CLAIM_DETAILS_WS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
