{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for SAT_PRODUCT_DEFINITION, table 'BJAZ_TRV_LOADER_DATA_MV'.

{%- set yaml_metadata -%}
source_model: 'stg_travel__bjaz_trv_loader_data_mv'
hashed_columns:
  PRODUCT_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PRODUCT_CATEGORY'
derived_columns:
  PARENT_BK: 'plan'
  PARENT_NK: "'HUB_PRODUCT|' || (plan)"
  PRODUCT_CATEGORY: 'travelplancategory'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_TRV_LOADER_DATA_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
