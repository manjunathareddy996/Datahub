{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_PARTY_IDENTIFICATION, table 'BJAZ_TPA_CLAIM_DETAILS_WS' (union branch, no attribute-level merge needed).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_tpa_claim_details_ws'
hashed_columns:
  PARTY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PAN_NUMBER'
derived_columns:
  PARENT_BK: 'customer_id'
  PARENT_NK: "'HUB_PARTY|' || (customer_id)"
  IDENTIFICATION_TYPE_CODE_CK: '!'
  PAN_NUMBER: 'pan_no'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_TPA_CLAIM_DETAILS_WS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
