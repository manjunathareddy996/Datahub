{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_CLAIM_NOTE, table 'BJAZ_HM_QUERY_REMARK' (union branch, no attribute-level merge needed).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hm_query_remark'
hashed_columns:
  CLAIM_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'NOTE_TEXT'
derived_columns:
  PARENT_BK: 'claim_id'
  PARENT_NK: "'HUB_CLAIM|' || (claim_id)"
  NOTE_SEQUENCE_CK: '!'
  NOTE_TEXT: 'query_remark'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HM_QUERY_REMARK'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
