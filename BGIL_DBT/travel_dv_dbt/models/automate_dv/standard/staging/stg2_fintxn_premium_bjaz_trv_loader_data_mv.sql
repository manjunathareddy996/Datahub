{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL per-table stage() for SAT_FINTXN_PREMIUM, table 'BJAZ_TRV_LOADER_DATA_MV'.

{%- set yaml_metadata -%}
source_model: 'stg_travel__bjaz_trv_loader_data_mv'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'DISCOUNT_AMOUNT'
      - 'LOADING_AMOUNT'
      - 'COLLECTION_MODE'
      - 'BASE_PREMIUM'
      - 'GROSS_PREMIUM'
derived_columns:
  PARENT_BK: 'transactionid'
  PARENT_NK: "'HUB_FINANCIAL_TRANSACTION|' || (transactionid)"
  DISCOUNT_AMOUNT: 'discount'
  LOADING_AMOUNT: 'loading'
  COLLECTION_MODE: 'paymentmode'
  BASE_PREMIUM: 'policy_premium'
  GROSS_PREMIUM: 'totalpremium'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!BJAZ_TRV_LOADER_DATA_MV'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
