{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for SAT_POLICY_TERMS, table 'BJAZ_TRV_LOADER_LOG_TABLE_MV'.

{%- set yaml_metadata -%}
source_model: 'stg_travel__bjaz_trv_loader_log_table_mv'
hashed_columns:
  POLICY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'SPECIAL_CONDITIONS'
derived_columns:
  PARENT_BK: 'policynumber'
  PARENT_NK: "'HUB_POLICY|' || (policynumber)"
  SPECIAL_CONDITIONS: 'spcondition'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_TRV_LOADER_LOG_TABLE_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
