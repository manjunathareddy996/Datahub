{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_PROPOSAL_QUESTIONNAIRE, table 'BJAZ_HG_POL_DTLS' (single contributing table).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hg_pol_dtls'
hashed_columns:
  PROPOSAL_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'RESPONSE_VALUE'
derived_columns:
  PARENT_BK: 'quote_ref_no'
  PARENT_NK: "'HUB_PROPOSAL|' || (quote_ref_no)"
  QUESTION_CODE_CK: '!'
  RESPONSE_VALUE: 'prev_disease_covered_yn'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HG_POL_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
