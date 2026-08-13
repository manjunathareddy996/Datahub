{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_LOCATION_PROFILE, table 'BJAZ_HM_HCM_EXTRACT' (single contributing table).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hm_hcm_extract'
hashed_columns:
  LOCATION_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'LOCATION_NAME'
derived_columns:
  PARENT_BK: 'policy_location'
  PARENT_NK: "'HUB_LOCATION|' || (policy_location)"
  LOCATION_NAME: 'policy_location'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HM_HCM_EXTRACT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
