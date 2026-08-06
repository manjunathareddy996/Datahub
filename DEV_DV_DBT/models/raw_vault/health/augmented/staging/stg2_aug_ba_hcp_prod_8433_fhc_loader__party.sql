{{ config(materialized='view') }}

-- AUGMENTED (unconfirmed) per-table stage() for HUB_PARTY, table 'BA_HCP_PROD_8433_FHC_LOADER'.
-- 1 previously-unmapped column(s), bucketed by keyword/anchor
-- classification -- NOT mapper-reviewed. BA_HCP_PROD_8433_FHC_LOADER carries a verified HUB_PARTY key
-- (PD_PREMIUM_PAYER_ID), so the key itself is genuine; the ATTRIBUTE GROUPING
-- (should these columns really all live on one satellite together?) is not.

{%- set yaml_metadata -%}
source_model: 'stg_health__ba_hcp_prod_8433_fhc_loader'
hashed_columns:
  PARTY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PD_BANK_REF_NO2_BANK_CUST_ID'
derived_columns:
  PARENT_BK: 'pd_premium_payer_id'
  PARENT_NK: "'HUB_PARTY|' || (pd_premium_payer_id)"
  PD_BANK_REF_NO2_BANK_CUST_ID: 'pd_bank_ref_no2_bank_cust_id'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BA_HCP_PROD_8433_FHC_LOADER'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
