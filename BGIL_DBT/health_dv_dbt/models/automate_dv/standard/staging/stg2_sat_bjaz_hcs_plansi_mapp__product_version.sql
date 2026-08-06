{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_PRODUCT_VERSION, table 'BJAZ_HCS_PLANSI_MAPP' (single contributing table).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hcs_plansi_mapp'
hashed_columns:
  PRODUCT_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'VERSION_EFFECTIVE_DATE'
derived_columns:
  PARENT_BK: 'product_code'
  PARENT_NK: "'HUB_PRODUCT|' || (product_code)"
  VERSION_EFFECTIVE_DATE: 'effective_dt'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HCS_PLANSI_MAPP'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
