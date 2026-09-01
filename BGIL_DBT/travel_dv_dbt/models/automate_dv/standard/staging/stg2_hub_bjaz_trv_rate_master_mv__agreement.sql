{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for HUB_AGREEMENT branch 'BJAZ_TRV_RATE_MASTER_MV'.

{%- set yaml_metadata -%}
source_model: 'stg_travel__bjaz_trv_rate_master_mv'
hashed_columns:
  AGREEMENT_HKEY: 'PARENT_NK'
derived_columns:
  PARENT_BK: 'cft_mst_contract_id'
  PARENT_NK: "'HUB_AGREEMENT|' || (cft_mst_contract_id)"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_TRV_RATE_MASTER_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
