{{ config(materialized='view') }}

-- AUGMENTED (unconfirmed) per-table stage() for HUB_PARTY, table 'BA_HCP_PROD_8428_GPG_LOADER'.
-- 2 previously-unmapped column(s), bucketed by keyword/anchor
-- classification -- NOT mapper-reviewed. BA_HCP_PROD_8428_GPG_LOADER carries a verified HUB_PARTY key
-- (PD_PREMIUM_PAYER_ID), so the key itself is genuine; the ATTRIBUTE GROUPING
-- (should these columns really all live on one satellite together?) is not.

{%- set yaml_metadata -%}
source_model: 'stg_health__ba_hcp_prod_8428_gpg_loader'
hashed_columns:
  PARTY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'MLAC_EMI_PC_LOAN_PERIOD'
      - 'MLAC_HOSP_CASH_NO_OF_DAYS'
derived_columns:
  PARENT_BK: 'pd_premium_payer_id'
  PARENT_NK: "'HUB_PARTY|' || (pd_premium_payer_id)"
  MLAC_EMI_PC_LOAN_PERIOD: 'mlac_emi_pc_loan_period'
  MLAC_HOSP_CASH_NO_OF_DAYS: 'mlac_hosp_cash_no_of_days'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BA_HCP_PROD_8428_GPG_LOADER'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
