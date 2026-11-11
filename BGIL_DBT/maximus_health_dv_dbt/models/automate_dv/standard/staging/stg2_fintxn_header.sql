-- automate_dv.stage() for SAT_FINTXN_HEADER, read off central view stitch_v08_financial_transaction.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v08_financial_transaction'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'FINANCIAL_TRANSACTION_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'GROSS_AMOUNT'
      - 'NARRATION'
      - 'NET_AMOUNT'
      - 'POSTING_DATE'
      - 'SOURCE_REFERENCE_NUMBER'
      - 'TRANSACTION_CHANNEL'
      - 'TRANSACTION_DIRECTION'
      - 'TRANSACTION_SUB_TYPE'
      - 'TRANSACTION_TYPE'
      - 'VALUE_DATE'
derived_columns:
  FINANCIAL_TRANSACTION_NK: "case when coalesce(FINTXN_HEADER__GROSS_AMOUNT, FINTXN_HEADER__NARRATION, FINTXN_HEADER__NET_AMOUNT, FINTXN_HEADER__POSTING_DATE, FINTXN_HEADER__SOURCE_REFERENCE_NUMBER, FINTXN_HEADER__TRANSACTION_CHANNEL, FINTXN_HEADER__TRANSACTION_DIRECTION, FINTXN_HEADER__TRANSACTION_SUB_TYPE, FINTXN_HEADER__TRANSACTION_TYPE, FINTXN_HEADER__VALUE_DATE) is not null then 'HUB_FINANCIAL_TRANSACTION|' || FINANCIAL_TRANSACTION_BK end"
  GROSS_AMOUNT: 'FINTXN_HEADER__GROSS_AMOUNT'
  NARRATION: 'FINTXN_HEADER__NARRATION'
  NET_AMOUNT: 'FINTXN_HEADER__NET_AMOUNT'
  POSTING_DATE: 'FINTXN_HEADER__POSTING_DATE'
  SOURCE_REFERENCE_NUMBER: 'FINTXN_HEADER__SOURCE_REFERENCE_NUMBER'
  TRANSACTION_CHANNEL: 'FINTXN_HEADER__TRANSACTION_CHANNEL'
  TRANSACTION_DIRECTION: 'FINTXN_HEADER__TRANSACTION_DIRECTION'
  TRANSACTION_SUB_TYPE: 'FINTXN_HEADER__TRANSACTION_SUB_TYPE'
  TRANSACTION_TYPE: 'FINTXN_HEADER__TRANSACTION_TYPE'
  VALUE_DATE: 'FINTXN_HEADER__VALUE_DATE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v08_financial_transaction'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
