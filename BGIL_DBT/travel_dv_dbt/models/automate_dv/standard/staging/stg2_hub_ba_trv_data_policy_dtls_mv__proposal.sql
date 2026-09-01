{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for HUB_PROPOSAL branch 'BA_TRV_DATA_POLICY_DTLS_MV'.

{%- set yaml_metadata -%}
source_model: 'stg_travel__ba_trv_data_policy_dtls_mv'
hashed_columns:
  PROPOSAL_HKEY: 'PARENT_NK'
derived_columns:
  PARENT_BK: 'travel_req_no'
  PARENT_NK: "'HUB_PROPOSAL|' || (travel_req_no)"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BA_TRV_DATA_POLICY_DTLS_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
