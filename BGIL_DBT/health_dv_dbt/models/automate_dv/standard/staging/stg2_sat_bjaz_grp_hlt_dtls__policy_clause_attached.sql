{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_POLICY_CLAUSE_ATTACHED, table 'BJAZ_GRP_HLT_DTLS' (single contributing table).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_grp_hlt_dtls'
hashed_columns:
  POLICY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CLAUSE_TITLE'
derived_columns:
  PARENT_BK: 'reg_no'
  PARENT_NK: "'HUB_POLICY|' || (reg_no)"
  CLAUSE_CODE_CK: '!'
  CLAUSE_TITLE: 'hpr_disclaimer1'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_GRP_HLT_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
