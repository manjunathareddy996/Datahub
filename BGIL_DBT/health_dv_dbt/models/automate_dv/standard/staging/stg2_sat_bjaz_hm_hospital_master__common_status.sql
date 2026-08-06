{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_COMMON_STATUS, table 'BJAZ_HM_HOSPITAL_MASTER' (single contributing table).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hm_hospital_master'
hashed_columns:
  PARTY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'STATUS_CODE'
derived_columns:
  PARENT_BK: 'hosid'
  PARENT_NK: "'HUB_PARTY|' || (hosid)"
  STATUS_CODE: 'hos_status'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HM_HOSPITAL_MASTER'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
