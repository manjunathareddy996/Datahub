{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_POLICY_REFUND_DETAIL, table 'BJAZ_HM_MEMBER_DTLS' (single contributing table).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hm_member_dtls'
hashed_columns:
  POLICY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'NET_REFUND_AMOUNT'
derived_columns:
  PARENT_BK: 'contract_id'
  PARENT_NK: "'HUB_POLICY|' || (contract_id)"
  NET_REFUND_AMOUNT: 'refund_premium'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HM_MEMBER_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
