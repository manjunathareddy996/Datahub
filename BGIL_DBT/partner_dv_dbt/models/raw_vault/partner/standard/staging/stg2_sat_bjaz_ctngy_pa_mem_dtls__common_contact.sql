{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL per-table stage() for SAT_COMMON_CONTACT, table 'BJAZ_CTNGY_PA_MEM_DTLS'.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_ctngy_pa_mem_dtls'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'EMAILADDRESS'
      - 'FAXNUMBER'
      - 'LANDLINENUMBER'
      - 'MOBILENUMBER'
derived_columns:
  PARENT_BK: 'partner_id'
  PARENT_NK: "'HUB_PARTY|' || (partner_id)"
  EMAILADDRESS: 'email_id'
  FAXNUMBER: 'fax'
  LANDLINENUMBER: 'telephone_no'
  MOBILENUMBER: 'mobile_no'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_CTNGY_PA_MEM_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
