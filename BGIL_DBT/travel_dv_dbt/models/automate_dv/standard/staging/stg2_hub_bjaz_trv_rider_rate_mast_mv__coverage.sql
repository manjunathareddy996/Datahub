{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for HUB_COVERAGE branch 'BJAZ_TRV_RIDER_RATE_MAST_MV'.

{%- set yaml_metadata -%}
source_model: 'stg_travel__bjaz_trv_rider_rate_mast_mv'
hashed_columns:
  COVERAGE_HKEY: 'PARENT_NK'
derived_columns:
  PARENT_BK: 'rider_seq_no'
  PARENT_NK: "'HUB_COVERAGE|' || (rider_seq_no)"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_TRV_RIDER_RATE_MAST_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
