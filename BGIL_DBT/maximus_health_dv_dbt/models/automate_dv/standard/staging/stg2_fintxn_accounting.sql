-- automate_dv.stage() for SAT_FINTXN_ACCOUNTING, read off central view stitch_v08_financial_transaction.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v08_financial_transaction'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'FINANCIAL_TRANSACTION_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CREDIT_ACCOUNT_REFERENCE'
      - 'DEBIT_ACCOUNT_REFERENCE'
      - 'VOUCHER_NUMBER'
derived_columns:
  FINANCIAL_TRANSACTION_NK: "case when coalesce(FINTXN_ACCOUNTING__CREDIT_ACCOUNT_REFERENCE, FINTXN_ACCOUNTING__DEBIT_ACCOUNT_REFERENCE, FINTXN_ACCOUNTING__VOUCHER_NUMBER) is not null then 'HUB_FINANCIAL_TRANSACTION|' || FINANCIAL_TRANSACTION_BK end"
  CREDIT_ACCOUNT_REFERENCE: 'FINTXN_ACCOUNTING__CREDIT_ACCOUNT_REFERENCE'
  DEBIT_ACCOUNT_REFERENCE: 'FINTXN_ACCOUNTING__DEBIT_ACCOUNT_REFERENCE'
  VOUCHER_NUMBER: 'FINTXN_ACCOUNTING__VOUCHER_NUMBER'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v08_financial_transaction'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
