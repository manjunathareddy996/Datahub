{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for HUB_COVERAGE branch 'BJAZ_TRV_RIDER_DTLS'.

{%- set yaml_metadata -%}
source_model: 'stg_travel__bjaz_trv_rider_dtls'
hashed_columns:
  COVERAGE_HKEY: 'PARENT_NK'
derived_columns:
  PARENT_BK: 'rider_no'
  PARENT_NK: "'HUB_COVERAGE|' || (rider_no)"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_BJAZ_TRV_RIDER_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
