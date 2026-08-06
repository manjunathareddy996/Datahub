{{ config(materialized='view') }}

-- AUGMENTED (unconfirmed) per-table stage() for HUB_POLICY, table 'BJAZ_SH_MEM_DTLS_EXTN'.
-- 1 previously-unmapped column(s), bucketed by keyword/anchor
-- classification -- NOT mapper-reviewed. BJAZ_SH_MEM_DTLS_EXTN carries a verified HUB_POLICY key
-- (CONTRACT_ID), so the key itself is genuine; the ATTRIBUTE GROUPING
-- (should these columns really all live on one satellite together?) is not.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_sh_mem_dtls_extn'
hashed_columns:
  POLICY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'FIRST_POLICY_REF'
derived_columns:
  PARENT_BK: 'contract_id'
  PARENT_NK: "'HUB_POLICY|' || (contract_id)"
  FIRST_POLICY_REF: 'first_policy_ref'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_SH_MEM_DTLS_EXTN'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
