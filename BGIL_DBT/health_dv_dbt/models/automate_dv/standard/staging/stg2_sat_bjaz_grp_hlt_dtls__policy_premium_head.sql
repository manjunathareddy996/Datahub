{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_POLICY_PREMIUM_HEAD, table 'BJAZ_GRP_HLT_DTLS' (union branch, no attribute-level merge needed).
-- Cross-LOB rekey (MAPPER_NOTE_MULTIACTIVE_REKEY.md): see BA_HCP_DT_MEM's stage file
-- header for the collision this fixes -- PREMIUM_HEAD_CODE_CK was '!' (blank) on every
-- contributing table. Given a distinct literal here.
-- data_7 sync (MAPPER_NOTE_HEALTH_DATA7_SYNC.md): literal aligned to the mapper's exact
-- child-key token ('Per-Person Basis', was 'Per Person Premium').

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_grp_hlt_dtls'
hashed_columns:
  POLICY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PREMIUM_BASIS'
derived_columns:
  PARENT_BK: 'reg_no'
  PARENT_NK: "'HUB_POLICY|' || (reg_no)"
  PREMIUM_HEAD_CODE_CK: '!Per-Person Basis'
  PREMIUM_BASIS: 'per_person_prem_type'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_GRP_HLT_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
