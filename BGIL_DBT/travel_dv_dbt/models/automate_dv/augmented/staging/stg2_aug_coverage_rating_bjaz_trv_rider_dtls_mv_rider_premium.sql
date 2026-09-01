{{ config(materialized='view') }}

-- TRAVEL AUGMENTED per-table stage() for SAT_AUG_COVERAGE_RATING, table 'BJAZ_TRV_RIDER_DTLS_MV'.

{%- set yaml_metadata -%}
source_model: 'stg_travel__bjaz_trv_rider_dtls_mv'
hashed_columns:
  COVERAGE_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'RIDER_PREMIUM'
derived_columns:
  PARENT_BK: 'rider_no'
  PARENT_NK: "'HUB_COVERAGE|' || (rider_no)"
  RIDER_PREMIUM: 'rider_premium'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!BJAZ_TRV_RIDER_DTLS_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
