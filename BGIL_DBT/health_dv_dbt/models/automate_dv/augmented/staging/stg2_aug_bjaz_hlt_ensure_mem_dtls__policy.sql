{{ config(materialized='view') }}

-- AUGMENTED (unconfirmed) per-table stage() for HUB_POLICY, table 'BJAZ_HLT_ENSURE_MEM_DTLS'.
-- 4 previously-unmapped column(s), bucketed by keyword/anchor
-- classification -- NOT mapper-reviewed. BJAZ_HLT_ENSURE_MEM_DTLS carries a verified HUB_POLICY key
-- (CONTRACT_ID), so the key itself is genuine; the ATTRIBUTE GROUPING
-- (should these columns really all live on one satellite together?) is not.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hlt_ensure_mem_dtls'
hashed_columns:
  POLICY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PREVIOUS_FROM_DATE'
      - 'PREVIOUS_TO_DATE'
      - 'FIRST_POLICY_NUMBER'
      - 'FIRST_POL_INCEPTION_DATE'
derived_columns:
  PARENT_BK: 'contract_id'
  PARENT_NK: "'HUB_POLICY|' || (contract_id)"
  PREVIOUS_FROM_DATE: 'previous_from_date'
  PREVIOUS_TO_DATE: 'previous_to_date'
  FIRST_POLICY_NUMBER: 'first_policy_number'
  FIRST_POL_INCEPTION_DATE: 'first_pol_inception_date'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HLT_ENSURE_MEM_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
