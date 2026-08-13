{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_POLICY_PREMIUM_HEAD, table 'BJAZ_HCF_MEMBER_DTLS' (union branch, no attribute-level merge needed).
-- data_7 sync (MAPPER_NOTE_HEALTH_DATA7_SYNC.md): second branch off this table --
-- FLOAT_PREMIUM (-> Net Head Premium, child key 'Floater') was previously unbuilt even
-- though this table's own staging model already exposes the column. Genuinely distinct
-- from ADON_PREMIUM's 'Add-On' branch, per the mapper's own child-key split.

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
  PREMIUM_HEAD_CODE_CK: '!Floater'
  NET_HEAD_PREMIUM: 'float_premium'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HCF_MEMBER_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
