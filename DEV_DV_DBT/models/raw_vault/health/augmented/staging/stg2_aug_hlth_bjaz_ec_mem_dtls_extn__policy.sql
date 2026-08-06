{{ config(materialized='view') }}

-- AUGMENTED (unconfirmed) per-table stage() for HUB_POLICY, table 'BJAZ_EC_MEM_DTLS_EXTN'.
-- 5 previously-unmapped column(s), bucketed by keyword/anchor
-- classification -- NOT mapper-reviewed. BJAZ_EC_MEM_DTLS_EXTN carries a verified HUB_POLICY key
-- (CONTRACT_ID), so the key itself is genuine; the ATTRIBUTE GROUPING
-- (should these columns really all live on one satellite together?) is not.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_ec_mem_dtls_extn'
hashed_columns:
  POLICY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PERV_POL_EXP_DATE'
      - 'CON_COMPANY'
      - 'CON_EXP_DATE'
      - 'CON_DEDUCTABLE'
      - 'FIRST_POLICY_REF'
derived_columns:
  PARENT_BK: 'contract_id'
  PARENT_NK: "'HUB_POLICY|' || (contract_id)"
  PERV_POL_EXP_DATE: 'perv_pol_exp_date'
  CON_COMPANY: 'con_company'
  CON_EXP_DATE: 'con_exp_date'
  CON_DEDUCTABLE: 'con_deductable'
  FIRST_POLICY_REF: 'first_policy_ref'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_EC_MEM_DTLS_EXTN'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
