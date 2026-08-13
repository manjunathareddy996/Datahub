{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_PARTY_GROUP_CENSUS, table 'BJAZ_HAT_ID_MEM_DETLS' (union branch, no attribute-level merge needed).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hat_id_mem_detls'
hashed_columns:
  PARTY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'EMPLOYEE_ID'
derived_columns:
  PARENT_BK: 'member_no'
  PARENT_NK: "'HUB_PARTY|' || (member_no)"
  MEMBER_REFERENCE_CK: '!'
  EMPLOYEE_ID: 'emp_no'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HAT_ID_MEM_DETLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
