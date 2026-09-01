{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for SAT_POLICY_HEADER, table 'BJAZ_TRV_LOADER_LOG_TABLE_MV'.

{%- set yaml_metadata -%}
source_model: 'stg_travel__bjaz_trv_loader_log_table_mv'
hashed_columns:
  POLICY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'COVER_NOTE_DATE'
      - 'COVER_NOTE_REFERENCE'
      - 'MASTER_POLICY_REFERENCE'
      - 'ISSUE_DATE'
      - 'RURAL_SECTOR_POLICY_INDICATOR'
      - 'RISK_INCEPTION_DATE'
      - 'SUM_INSURED_TOTAL'
      - 'RISK_EXPIRY_DATE'
derived_columns:
  PARENT_BK: 'policynumber'
  PARENT_NK: "'HUB_POLICY|' || (policynumber)"
  COVER_NOTE_DATE: 'covernotedate'
  COVER_NOTE_REFERENCE: 'covernoteno'
  MASTER_POLICY_REFERENCE: 'pmasterpolicynumber'
  ISSUE_DATE: 'policyissuedate'
  RURAL_SECTOR_POLICY_INDICATOR: 'ruralflag'
  RISK_INCEPTION_DATE: 'startdate'
  SUM_INSURED_TOTAL: 'suminsured'
  RISK_EXPIRY_DATE: 'todate'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_TRV_LOADER_LOG_TABLE_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
