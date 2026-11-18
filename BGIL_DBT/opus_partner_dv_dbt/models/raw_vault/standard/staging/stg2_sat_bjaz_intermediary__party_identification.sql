{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL per-table stage() for SAT_PARTY_IDENTIFICATION, table 'BJAZ_INTERMEDIARY'.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_intermediary'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'GST_REGISTRATION_STATUS'
      - 'GSTIN'
      - 'PAN_NUMBER'
derived_columns:
  PARENT_BK: 'intermediary_id'
  PARENT_NK: "'HUB_PARTY|' || (intermediary_id)"
  GST_REGISTRATION_STATUS: 'gst_status'
  GSTIN: 'gst_no'
  PAN_NUMBER: 'pan_number'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_PARTNER_BJAZ_INTERMEDIARY'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
