{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_CASE_HEADER, table 'BJAZ_HM_INWARD_AUTOALLOCATION' (single contributing table).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hm_inward_autoallocation'
hashed_columns:
  CASE_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ASSIGNED_TO_REFERENCE'
      - 'CASE_STATUS'
derived_columns:
  PARENT_BK: 'allocate_id'
  PARENT_NK: "'HUB_CASE|' || (allocate_id)"
  ASSIGNED_TO_REFERENCE: 'allocate_to'
  CASE_STATUS: 'bucket_status'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HM_INWARD_AUTOALLOCATION'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
