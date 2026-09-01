{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for HUB_FINANCIAL_ACCOUNT branch 'BJAZ_TRV_LOADER_DATA_MV'.

{%- set yaml_metadata -%}
source_model: 'stg_travel__bjaz_trv_loader_data_mv'
hashed_columns:
  FINANCIAL_ACCOUNT_HKEY: 'PARENT_NK'
derived_columns:
  PARENT_BK: 'lanno'
  PARENT_NK: "'HUB_FINANCIAL_ACCOUNT|' || (lanno)"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_TRV_LOADER_DATA_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
