{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for SAT_FINTXN_PREMIUM, table
-- 'BJAZ_TRV_LOADER_LOG_TABLE_MV'. Round-2 fix: reuses the degenerate
-- HUB_FINANCIAL_TRANSACTION key (POLICYNUMBER) added in
-- stg2_hub_bjaz_trv_loader_log_table_mv__financial_transaction_degenerate.sql -- previously
-- unbuildable, no transaction key at all on this table.

{%- set yaml_metadata -%}
source_model: 'stg_travel__bjaz_trv_loader_log_table_mv'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'COLLECTION_MODE'
      - 'DISCOUNT_AMOUNT'
      - 'GROSS_PREMIUM'
      - 'LOADING_AMOUNT'
derived_columns:
  PARENT_BK: 'policynumber'
  PARENT_NK: "'HUB_FINANCIAL_TRANSACTION|' || (policynumber)"
  COLLECTION_MODE: 'paymentmode'
  DISCOUNT_AMOUNT: 'discount'
  GROSS_PREMIUM: 'grosspremium'
  LOADING_AMOUNT: 'loading'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!BJAZ_TRV_LOADER_LOG_TABLE_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
