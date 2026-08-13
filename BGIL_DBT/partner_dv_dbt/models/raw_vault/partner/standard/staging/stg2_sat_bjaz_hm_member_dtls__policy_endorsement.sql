{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL per-table stage() for SAT_POLICY_ENDORSEMENT, table 'BJAZ_HM_MEMBER_DTLS'.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_hm_member_dtls'
hashed_columns:
  POLICY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ENDORSEMENTNUMBER'
derived_columns:
  PARENT_BK: 'contract_id'
  PARENT_NK: "'HUB_POLICY|' || (contract_id)"
  ENDORSEMENTNUMBER: 'endorsement_no'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HM_MEMBER_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
