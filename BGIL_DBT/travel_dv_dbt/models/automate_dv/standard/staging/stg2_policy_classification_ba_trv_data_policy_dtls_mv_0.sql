{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for SAT_POLICY_CLASSIFICATION, table 'BA_TRV_DATA_POLICY_DTLS_MV', column 'CFT_FLAG' -> Classification Value [{'CLASSIFICATION_TYPE': 'cft'}].

{%- set yaml_metadata -%}
source_model: 'stg_travel__ba_trv_data_policy_dtls_mv'
hashed_columns:
  POLICY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CLASSIFICATION_VALUE'
      - 'CLASSIFICATION_TYPE'
derived_columns:
  PARENT_BK: 'trv_data_no'
  PARENT_NK: "'HUB_POLICY|' || (trv_data_no)"
  CLASSIFICATION_TYPE: '!cft'
  CLASSIFICATION_VALUE: 'cft_flag'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!BA_TRV_DATA_POLICY_DTLS_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
