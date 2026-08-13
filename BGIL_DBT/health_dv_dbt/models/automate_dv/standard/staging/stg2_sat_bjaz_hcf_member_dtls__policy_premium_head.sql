{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_POLICY_PREMIUM_HEAD, table 'BJAZ_HCF_MEMBER_DTLS' (union branch, no attribute-level merge needed).
-- Cross-LOB rekey (MAPPER_NOTE_MULTIACTIVE_REKEY.md): see BA_HCP_DT_MEM's stage file
-- header for the collision this fixes -- PREMIUM_HEAD_CODE_CK was '!' (blank) on every
-- contributing table. Given a distinct literal here.
-- data_7 sync (MAPPER_NOTE_HEALTH_DATA7_SYNC.md): literal aligned to the mapper's exact
-- child-key token ('Add-On', was 'Add-On Premium'). This table also carries a second,
-- previously-unbuilt premium column (FLOAT_PREMIUM) -- see
-- stg2_sat_bjaz_hcf_member_dtls__policy_premium_head_2.sql.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hcf_member_dtls'
hashed_columns:
  POLICY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'NET_HEAD_PREMIUM'
derived_columns:
  PARENT_BK: 'contract_id'
  PARENT_NK: "'HUB_POLICY|' || (contract_id)"
  PREMIUM_HEAD_CODE_CK: '!Add-On'
  NET_HEAD_PREMIUM: 'adon_premium'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HCF_MEMBER_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
