-- automate_dv.stage() for SAT_COMMON_MONETARY_CONTEXT, read off central view stitch_v09_financial_transaction.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v09_financial_transaction'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'FINANCIAL_TRANSACTION_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'BASE_CURRENCY_CODE'
      - 'CURRENCY_CODE'
      - 'EXCHANGE_RATE'
derived_columns:
  FINANCIAL_TRANSACTION_NK: "case when coalesce(COMMON_MONETARY_CONTEXT__BASE_CURRENCY_CODE, COMMON_MONETARY_CONTEXT__CURRENCY_CODE, COMMON_MONETARY_CONTEXT__EXCHANGE_RATE) is not null then 'HUB_FINANCIAL_TRANSACTION|' || FINANCIAL_TRANSACTION_BK end"
  BASE_CURRENCY_CODE: 'COMMON_MONETARY_CONTEXT__BASE_CURRENCY_CODE'
  CURRENCY_CODE: 'COMMON_MONETARY_CONTEXT__CURRENCY_CODE'
  EXCHANGE_RATE: 'COMMON_MONETARY_CONTEXT__EXCHANGE_RATE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v09_financial_transaction'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
