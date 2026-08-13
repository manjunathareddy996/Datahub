{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_POLICY_PREMIUM_HEAD, table 'BJAZ_GRP_HLT_MATERNITY_DTLS' (union branch, no attribute-level merge needed).
-- Cross-LOB rekey (MAPPER_NOTE_MULTIACTIVE_REKEY.md): this table previously forced two
-- genuinely different premium-head concepts (PRIME_RIDER_BASE_PREM, a rider base premium,
-- and PERMIUM_CO_BUFFER, a co-buffer premium component) onto one row under a shared blank
-- PREMIUM_HEAD_CODE_CK -- exactly the "multiple Base Amount / Net Head Premium rows per
-- table" case the mapper's note flagged for a real check. Split: this branch now carries
-- only the rider base amount; the co-buffer amount moved to a second branch
-- (stg2_sat_bjaz_grp_hlt_maternity_dtls__policy_premium_head_2.sql).

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_grp_hlt_maternity_dtls'
hashed_columns:
  POLICY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'BASE_AMOUNT'
derived_columns:
  PARENT_BK: 'reg_no'
  PARENT_NK: "'HUB_POLICY|' || (reg_no)"
  PREMIUM_HEAD_CODE_CK: '!Maternity Rider'
  BASE_AMOUNT: 'prime_rider_base_prem'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_GRP_HLT_MATERNITY_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
