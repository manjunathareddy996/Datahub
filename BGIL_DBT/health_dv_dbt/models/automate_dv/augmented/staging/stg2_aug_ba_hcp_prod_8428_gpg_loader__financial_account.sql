{{ config(materialized='view') }}

-- AUGMENTED (unconfirmed) per-table stage() for HUB_FINANCIAL_ACCOUNT, table 'BA_HCP_PROD_8428_GPG_LOADER'.
-- 1 previously-unmapped column(s), bucketed by keyword/anchor
-- classification -- NOT mapper-reviewed. BA_HCP_PROD_8428_GPG_LOADER carries a verified HUB_FINANCIAL_ACCOUNT key
-- (MLAC_EMI_PC_LOAN_ACCOUNT_NO), so the key itself is genuine; the ATTRIBUTE GROUPING
-- (should these columns really all live on one satellite together?) is not.

{%- set yaml_metadata -%}
source_model: 'stg_health__ba_hcp_prod_8428_gpg_loader'
hashed_columns:
  FINANCIAL_ACCOUNT_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'MLAC_EMI_PC_EMI_RS'
derived_columns:
  PARENT_BK: 'mlac_emi_pc_loan_account_no'
  PARENT_NK: "'HUB_FINANCIAL_ACCOUNT|' || (mlac_emi_pc_loan_account_no)"
  MLAC_EMI_PC_EMI_RS: 'mlac_emi_pc_emi_rs'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BA_HCP_PROD_8428_GPG_LOADER'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
