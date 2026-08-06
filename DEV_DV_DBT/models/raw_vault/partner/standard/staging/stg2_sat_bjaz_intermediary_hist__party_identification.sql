{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL per-table stage() for SAT_PARTY_IDENTIFICATION, table 'BJAZ_INTERMEDIARY_HIST'.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_intermediary_hist'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'GSTREGISTRATIONSTATUS'
      - 'GSTIN'
      - 'PANNUMBER'
derived_columns:
  PARENT_BK: 'intermediary_id'
  PARENT_NK: "'HUB_PARTY|' || (intermediary_id)"
  GSTREGISTRATIONSTATUS: 'gst_status'
  GSTIN: 'gst_no'
  PANNUMBER: 'pan_number'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_INTERMEDIARY_HIST'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
