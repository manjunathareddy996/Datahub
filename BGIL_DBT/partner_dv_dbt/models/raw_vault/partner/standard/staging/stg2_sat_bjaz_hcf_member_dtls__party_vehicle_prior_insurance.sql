{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL per-table stage() for SAT_PARTY_VEHICLE_PRIOR_INSURANCE, table 'BJAZ_HCF_MEMBER_DTLS'.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_hcf_member_dtls'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CONTINUITYINDICATOR'
      - 'PREVIOUSPOLICYNUMBER'
      - 'PREVIOUSSUMINSURED'
derived_columns:
  PARENT_BK: 'partner_id'
  PARENT_NK: "'HUB_PARTY|' || (partner_id)"
  CONTINUITYINDICATOR: 'prev_policy_since'
  PREVIOUSPOLICYNUMBER: 'concurrent_policy_details'
  PREVIOUSSUMINSURED: 'previous_si'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HCF_MEMBER_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
