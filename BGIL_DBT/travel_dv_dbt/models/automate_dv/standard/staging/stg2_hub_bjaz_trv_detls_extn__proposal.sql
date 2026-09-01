{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for HUB_PROPOSAL branch 'BJAZ_TRV_DETLS_EXTN'.

{%- set yaml_metadata -%}
source_model: 'stg_travel__bjaz_trv_detls_extn'
hashed_columns:
  PROPOSAL_HKEY: 'PARENT_NK'
derived_columns:
  PARENT_BK: 'travel_req_no'
  PARENT_NK: "'HUB_PROPOSAL|' || (travel_req_no)"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_TRV_DETLS_EXTN'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
