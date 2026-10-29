{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for HUB_ASSESSMENT branch 'BA_TRV_DATA_POLICY_DTLS'.

{%- set yaml_metadata -%}
source_model: 'stg_travel__ba_trv_data_policy_dtls'
hashed_columns:
  ASSESSMENT_HKEY: 'PARENT_NK'
derived_columns:
  PARENT_BK: 'scrutiny_no'
  PARENT_NK: "'HUB_ASSESSMENT|' || (scrutiny_no)"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_BA_TRV_DATA_POLICY_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
