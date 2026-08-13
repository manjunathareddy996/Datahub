{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_COMMON_GEO, table 'BJAZ_HM_INWARD_DTLS' (single contributing table).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hm_inward_dtls'
hashed_columns:
  LOCATION_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'REGION_NAME'
derived_columns:
  PARENT_BK: 'location_code'
  PARENT_NK: "'HUB_LOCATION|' || (location_code)"
  REGION_NAME: 'geo_area'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HM_INWARD_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
