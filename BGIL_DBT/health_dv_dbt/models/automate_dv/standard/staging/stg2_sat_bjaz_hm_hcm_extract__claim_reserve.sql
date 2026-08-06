{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_CLAIM_RESERVE, table 'BJAZ_HM_HCM_EXTRACT' (single contributing table).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hm_hcm_extract'
hashed_columns:
  CLAIM_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CURRENT_RESERVE_AMOUNT'
derived_columns:
  PARENT_BK: 'clid'
  PARENT_NK: "'HUB_CLAIM|' || (clid)"
  RESERVE_HEAD_CK: '!'
  CURRENT_RESERVE_AMOUNT: 'reserve_amt'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HM_HCM_EXTRACT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
