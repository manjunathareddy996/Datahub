{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL per-table stage() for SAT_PARTY_IDENTIFICATION, table 'BJAZ_CTNGY_PA_MEM_DTLS'.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_ctngy_pa_mem_dtls'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'AADHAAR_NUMBER'
      - 'IDENTIFICATION_NUMBER'
      - 'PAN_NUMBER'
      - 'PASSPORT_NUMBER'
      - 'EIA_NUMBER'
derived_columns:
  PARENT_BK: 'partner_id'
  PARENT_NK: "'HUB_PARTY|' || (partner_id)"
  AADHAAR_NUMBER: 'aadhar_card_no'
  IDENTIFICATION_NUMBER: 'member_ref_number'
  PAN_NUMBER: 'pan_card_no'
  PASSPORT_NUMBER: 'passport_number'
  EIA_NUMBER: 'eia_no'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_PARTNER_BJAZ_CTNGY_PA_MEM_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
