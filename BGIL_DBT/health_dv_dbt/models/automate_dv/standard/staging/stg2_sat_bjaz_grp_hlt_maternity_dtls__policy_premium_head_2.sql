{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_POLICY_PREMIUM_HEAD, table 'BJAZ_GRP_HLT_MATERNITY_DTLS' (union branch, no attribute-level merge needed).
-- Cross-LOB rekey (MAPPER_NOTE_MULTIACTIVE_REKEY.md): second branch off this table --
-- see stg2_sat_bjaz_grp_hlt_maternity_dtls__policy_premium_head.sql's header for why this
-- table was split into two premium-head branches (PERMIUM_CO_BUFFER is a distinct
-- premium concept from PRIME_RIDER_BASE_PREM, not the same head).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_grp_hlt_maternity_dtls'
hashed_columns:
  POLICY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'NET_HEAD_PREMIUM'
derived_columns:
  PARENT_BK: 'reg_no'
  PARENT_NK: "'HUB_POLICY|' || (reg_no)"
  PREMIUM_HEAD_CODE_CK: '!Maternity Co-Buffer'
  NET_HEAD_PREMIUM: 'permium_co_buffer'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_GRP_HLT_MATERNITY_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
