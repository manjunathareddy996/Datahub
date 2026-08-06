{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_PARTY_IDENTIFICATION, table 'BA_HCP_PROD_8439_CLH_LOADER' (union branch, no attribute-level merge needed).

{%- set yaml_metadata -%}
source_model: 'stg_health__ba_hcp_prod_8439_clh_loader'
hashed_columns:
  PARTY_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'AADHAAR_NUMBER'
      - 'EIA_NUMBER'
      - 'GSTIN'
      - 'PAN_NUMBER'
derived_columns:
  PARENT_BK: 'pd_premium_payer_id'
  PARENT_NK: "'HUB_PARTY|' || (pd_premium_payer_id)"
  IDENTIFICATION_TYPE_CODE_CK: '!'
  AADHAAR_NUMBER: 'pd_a_card_no'
  EIA_NUMBER: 'pd_electronic_insur_account_no'
  GSTIN: 'gstin_uin'
  PAN_NUMBER: 'pd_pan_no'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BA_HCP_PROD_8439_CLH_LOADER'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
