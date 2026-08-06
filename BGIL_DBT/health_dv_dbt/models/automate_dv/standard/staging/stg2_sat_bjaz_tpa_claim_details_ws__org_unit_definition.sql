{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_ORG_UNIT_DEFINITION, table 'BJAZ_TPA_CLAIM_DETAILS_WS' (single contributing table).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_tpa_claim_details_ws'
hashed_columns:
  ORG_UNIT_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ORG_UNIT_CODE'
      - 'ORG_UNIT_NAME'
derived_columns:
  PARENT_BK: 'operating_office'
  PARENT_NK: "'HUB_ORG_UNIT|' || (operating_office)"
  ORG_UNIT_CODE: 'operating_code'
  ORG_UNIT_NAME: 'operating_office'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_TPA_CLAIM_DETAILS_WS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
