{{ config(materialized='view') }}

-- PARTNER AUGMENTED (unconfirmed) per-table stage() for HUB_POLICY, table 'BJAZ_HLT_ENSURE_MEM_DTLS'.
-- 1 previously-unmapped column(s), per the modeler's own
-- Augmentation sheet -- NOT yet formally added to data_5a.js. BJAZ_HLT_ENSURE_MEM_DTLS carries a
-- verified HUB_POLICY key, so the key itself is genuine; the attribute proposal is not
-- yet mapper-confirmed as a model change.
-- MULTI-ACTIVE FIX (mapper feedback round 2): a policy can have multiple members, each with
-- their own bonus/cumulative values -- MEMBER_SEQUENCE (this table's MEMBER_NO) is the
-- multi-active child key so per-member history isn't collapsed into one row per policy.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_hlt_ensure_mem_dtls'
hashed_columns:
  POLICY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PREVIOUS_CUM_AMOUNT'
derived_columns:
  PARENT_BK: 'contract_id'
  PARENT_NK: "'HUB_POLICY|' || (contract_id)"
  MEMBER_SEQUENCE: 'member_no'
  PREVIOUS_CUM_AMOUNT: 'previous_cum_amount'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HLT_ENSURE_MEM_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
