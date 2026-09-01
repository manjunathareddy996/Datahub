{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for SAT_POLICY_HEADER, table 'BA_TRV_DATA_POLICY_DTLS_MV'.

{%- set yaml_metadata -%}
source_model: 'stg_travel__ba_trv_data_policy_dtls_mv'
hashed_columns:
  POLICY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'MASTER_POLICY_REFERENCE'
      - 'COVER_NOTE_DATE'
      - 'COVER_NOTE_REFERENCE'
      - 'NUMBER_OF_LIVES_COVERED'
      - 'ISSUE_DATE'
      - 'POLICY_NUMBER'
      - 'RURAL_SECTOR_POLICY_INDICATOR'
      - 'RISK_EXPIRY_DATE'
      - 'RISK_INCEPTION_DATE'
derived_columns:
  PARENT_BK: 'trv_data_no'
  PARENT_NK: "'HUB_POLICY|' || (trv_data_no)"
  MASTER_POLICY_REFERENCE: 'cft_mst_policy_ref'
  COVER_NOTE_DATE: 'cover_note_date'
  COVER_NOTE_REFERENCE: 'cover_note_no'
  NUMBER_OF_LIVES_COVERED: 'no_of_family_members'
  ISSUE_DATE: 'policy_date'
  POLICY_NUMBER: 'policy_ref'
  RURAL_SECTOR_POLICY_INDICATOR: 'rural_flag'
  RISK_EXPIRY_DATE: 'term_end_date'
  RISK_INCEPTION_DATE: 'term_start_date'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!BA_TRV_DATA_POLICY_DTLS_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
