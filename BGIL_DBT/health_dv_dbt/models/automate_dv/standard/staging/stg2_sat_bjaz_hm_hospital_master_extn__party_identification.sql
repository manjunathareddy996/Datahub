{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_PARTY_IDENTIFICATION, table 'BJAZ_HM_HOSPITAL_MASTER_EXTN' (union branch, no attribute-level merge needed).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hm_hospital_master_extn'
hashed_columns:
  PARTY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'IDENTIFICATION_NUMBER'
      - 'TAN_NUMBER'
derived_columns:
  PARENT_BK: 'hosid'
  PARENT_NK: "'HUB_PARTY|' || (hosid)"
  IDENTIFICATION_TYPE_CODE_CK: '!'
  IDENTIFICATION_NUMBER: 'irda_unique_id'
  TAN_NUMBER: 'tan_no'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HM_HOSPITAL_MASTER_EXTN'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
