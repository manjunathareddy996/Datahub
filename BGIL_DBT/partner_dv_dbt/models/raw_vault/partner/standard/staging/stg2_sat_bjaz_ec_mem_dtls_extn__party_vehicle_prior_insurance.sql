{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL per-table stage() for SAT_PARTY_VEHICLE_PRIOR_INSURANCE, table 'BJAZ_EC_MEM_DTLS_EXTN'.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_ec_mem_dtls_extn'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PREVIOUSEXPIRYDATE'
      - 'PREVIOUSINSURERNAME'
      - 'PREVIOUSPOLICYNUMBER'
      - 'PREVIOUSSUMINSURED'
derived_columns:
  PARENT_BK: 'partner_id'
  PARENT_NK: "'HUB_PARTY|' || (partner_id)"
  PREVIOUSEXPIRYDATE: 'perv_pol_exp_date'
  PREVIOUSINSURERNAME: 'prev_company_name'
  PREVIOUSPOLICYNUMBER: 'prev_policy_dtls'
  PREVIOUSSUMINSURED: 'prev_sum_insured'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_EC_MEM_DTLS_EXTN'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
