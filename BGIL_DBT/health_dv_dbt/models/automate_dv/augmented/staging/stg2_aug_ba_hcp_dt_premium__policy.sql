{{ config(materialized='view') }}

-- AUGMENTED (unconfirmed) per-table stage() for HUB_POLICY, table 'BA_HCP_DT_PREMIUM'.
-- 16 previously-unmapped column(s), bucketed by keyword/anchor
-- classification -- NOT mapper-reviewed. BA_HCP_DT_PREMIUM carries a verified HUB_POLICY key
-- (CONTRACT_ID), so the key itself is genuine; the ATTRIBUTE GROUPING
-- (should these columns really all live on one satellite together?) is not.

{%- set yaml_metadata -%}
source_model: 'stg_health__ba_hcp_dt_premium'
hashed_columns:
  POLICY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'SERVICE_TAX_EXEMPTION_AMT'
      - 'EMI_YN'
      - 'EMI_OPTED'
      - 'INST_BASE_MONTHLY_AMT'
      - 'INST_BASE_QURTRLY_AMT'
      - 'INST_BASE_HALF_YR_AMT'
      - 'INST_BASE_YRLY_AMT'
      - 'INST_TOT_MONTHLY_AMT'
      - 'INST_TOT_QURTRLY_AMT'
      - 'INST_TOT_HALF_YR_AMT'
      - 'INST_TOT_YRLY_AMT'
      - 'EMI_PAYMNT_MAND'
      - 'INST_NET_MONTHLY_AMT'
      - 'INST_NET_QURTRLY_AMT'
      - 'INST_NET_HALF_YR_AMT'
      - 'INST_NET_YRLY_AMT'
derived_columns:
  PARENT_BK: 'contract_id'
  PARENT_NK: "'HUB_POLICY|' || (contract_id)"
  SERVICE_TAX_EXEMPTION_AMT: 'service_tax_exemption_amt'
  EMI_YN: 'emi_yn'
  EMI_OPTED: 'emi_opted'
  INST_BASE_MONTHLY_AMT: 'inst_base_monthly_amt'
  INST_BASE_QURTRLY_AMT: 'inst_base_qurtrly_amt'
  INST_BASE_HALF_YR_AMT: 'inst_base_half_yr_amt'
  INST_BASE_YRLY_AMT: 'inst_base_yrly_amt'
  INST_TOT_MONTHLY_AMT: 'inst_tot_monthly_amt'
  INST_TOT_QURTRLY_AMT: 'inst_tot_qurtrly_amt'
  INST_TOT_HALF_YR_AMT: 'inst_tot_half_yr_amt'
  INST_TOT_YRLY_AMT: 'inst_tot_yrly_amt'
  EMI_PAYMNT_MAND: 'emi_paymnt_mand'
  INST_NET_MONTHLY_AMT: 'inst_net_monthly_amt'
  INST_NET_QURTRLY_AMT: 'inst_net_qurtrly_amt'
  INST_NET_HALF_YR_AMT: 'inst_net_half_yr_amt'
  INST_NET_YRLY_AMT: 'inst_net_yrly_amt'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BA_HCP_DT_PREMIUM'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
