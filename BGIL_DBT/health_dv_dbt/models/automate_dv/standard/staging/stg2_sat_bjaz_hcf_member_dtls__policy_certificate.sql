{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_POLICY_CERTIFICATE, table 'BJAZ_HCF_MEMBER_DTLS' (union branch, no attribute-level merge needed).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hcf_member_dtls'
hashed_columns:
  POLICY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'COVERAGE_END_DATE'
      - 'COVERAGE_START_DATE'
      - 'MEMBER_PREMIUM'
derived_columns:
  PARENT_BK: 'contract_id'
  PARENT_NK: "'HUB_POLICY|' || (contract_id)"
  CERTIFICATE_NUMBER_CK: '!'
  COVERAGE_END_DATE: 'to_date'
  COVERAGE_START_DATE: 'from_date'
  MEMBER_PREMIUM: 'premium'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HCF_MEMBER_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
