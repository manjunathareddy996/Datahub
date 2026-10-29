{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for SAT_PARTY_IDENTITY, table 'BA_TRV_DATA_POLICY_DTLS' (agent anchor).

{%- set yaml_metadata -%}
source_model: 'stg_travel__ba_trv_data_policy_dtls'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PARTY_FULL_NAME'
derived_columns:
  PARENT_BK: 'intermediary_code'
  PARENT_NK: "'HUB_PARTY|' || (intermediary_code)"
  PARTY_FULL_NAME: 'travel_agent_name'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_BA_TRV_DATA_POLICY_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
