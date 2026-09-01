{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for SAT_POLICY_HEADER, table 'BJAZ_TRV_RIDER_DTLS_MV'.

{%- set yaml_metadata -%}
source_model: 'stg_travel__bjaz_trv_rider_dtls_mv'
hashed_columns:
  POLICY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'NUMBER_OF_LIVES_COVERED'
      - 'POLICY_TYPE'
derived_columns:
  PARENT_BK: 'trv_data_no'
  PARENT_NK: "'HUB_POLICY|' || (trv_data_no)"
  NUMBER_OF_LIVES_COVERED: 'no_members'
  POLICY_TYPE: 'p_policy_type'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!BJAZ_TRV_RIDER_DTLS_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
