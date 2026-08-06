{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_POLICY_CERTIFICATE, table 'BJAZ_HAT_ID_MEM_DETLS' (union branch, no attribute-level merge needed).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hat_id_mem_detls'
hashed_columns:
  POLICY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ENROLMENT_DATE'
      - 'MEMBER_PREMIUM'
      - 'MEMBER_STATUS'
derived_columns:
  PARENT_BK: 'contract_id'
  PARENT_NK: "'HUB_POLICY|' || (contract_id)"
  CERTIFICATE_NUMBER_CK: '!'
  ENROLMENT_DATE: 'join_date'
  MEMBER_PREMIUM: 'premium'
  MEMBER_STATUS: 'status'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HAT_ID_MEM_DETLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
