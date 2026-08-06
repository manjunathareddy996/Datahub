{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL per-table stage() for SAT_COMMON_CONTACT, table 'AZBJ_PARTNER_EXTN'.

{%- set yaml_metadata -%}
source_model: 'stg_partner__azbj_partner_extn'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ALTERNATEEMAILADDRESS'
      - 'ALTERNATEMOBILENUMBER'
      - 'LANDLINENUMBER'
      - 'PREFERREDCONTACTTIME'
derived_columns:
  PARENT_BK: 'part_id'
  PARENT_NK: "'HUB_PARTY|' || (part_id)"
  ALTERNATEEMAILADDRESS: 'email_2'
  ALTERNATEMOBILENUMBER: 'alt_mobile_no'
  LANDLINENUMBER: 'telephone3'
  PREFERREDCONTACTTIME: 'preferred_contact_opt'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!AZBJ_PARTNER_EXTN'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
