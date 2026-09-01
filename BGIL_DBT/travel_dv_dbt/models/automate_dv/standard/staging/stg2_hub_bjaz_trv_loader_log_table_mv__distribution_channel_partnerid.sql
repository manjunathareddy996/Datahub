{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for HUB_DISTRIBUTION_CHANNEL branch 'BJAZ_TRV_LOADER_LOG_TABLE_MV'.

{%- set yaml_metadata -%}
source_model: 'stg_travel__bjaz_trv_loader_log_table_mv'
hashed_columns:
  DISTRIBUTION_CHANNEL_HKEY: 'PARENT_NK'
derived_columns:
  PARENT_BK: 'partnerid'
  PARENT_NK: "'HUB_DISTRIBUTION_CHANNEL|' || (partnerid)"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_TRV_LOADER_LOG_TABLE_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
