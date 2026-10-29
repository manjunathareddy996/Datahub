{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for SAT_PRODUCT_RATING_STRUCTURE, table 'BJAZ_TRV_RATE_MASTER'.

{%- set yaml_metadata -%}
source_model: 'stg_travel__bjaz_trv_rate_master'
hashed_columns:
  PRODUCT_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PRICING_EFFECTIVE_DATE'
derived_columns:
  PARENT_BK: 'plan'
  PARENT_NK: "'HUB_PRODUCT|' || (plan)"
  PRICING_EFFECTIVE_DATE: 'effective_date'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_BJAZ_TRV_RATE_MASTER'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
