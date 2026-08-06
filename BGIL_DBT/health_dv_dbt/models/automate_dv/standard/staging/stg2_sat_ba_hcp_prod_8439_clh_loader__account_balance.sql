{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for SAT_ACCOUNT_BALANCE, table 'BA_HCP_PROD_8439_CLH_LOADER' (single contributing table).

{%- set yaml_metadata -%}
source_model: 'stg_health__ba_hcp_prod_8439_clh_loader'
hashed_columns:
  FINANCIAL_ACCOUNT_HK: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'OPENING_BALANCE'
derived_columns:
  PARENT_BK: 'plc_loan_acc_no'
  PARENT_NK: "'HUB_FINANCIAL_ACCOUNT|' || (plc_loan_acc_no)"
  OPENING_BALANCE: 'plc_sactioned_loan_amt'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BA_HCP_PROD_8439_CLH_LOADER'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
