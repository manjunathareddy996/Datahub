-- automate_dv.stage() for SAT_FINTXN_HEADER, read off central view stitch_mxm__v07_financial_transaction.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v07_financial_transaction'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'FINANCIAL_TRANSACTION_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'APPROVAL_STATUS'
      - 'GROSS_AMOUNT'
      - 'NARRATION'
      - 'SOURCE_REFERENCE_NUMBER'
      - 'SOURCE_REFERENCE_TYPE'
      - 'TAX_AMOUNT'
      - 'TRANSACTION_DATE'
      - 'TRANSACTION_NUMBER'
      - 'TRANSACTION_STATUS'
      - 'TRANSACTION_SUB_TYPE'
      - 'TRANSACTION_TYPE'
derived_columns:
  FINANCIAL_TRANSACTION_NK: "case when coalesce(FINTXN_HEADER__APPROVAL_STATUS, FINTXN_HEADER__GROSS_AMOUNT, FINTXN_HEADER__NARRATION, FINTXN_HEADER__SOURCE_REFERENCE_NUMBER, FINTXN_HEADER__SOURCE_REFERENCE_TYPE, FINTXN_HEADER__TAX_AMOUNT, FINTXN_HEADER__TRANSACTION_DATE, FINTXN_HEADER__TRANSACTION_NUMBER, FINTXN_HEADER__TRANSACTION_STATUS, FINTXN_HEADER__TRANSACTION_SUB_TYPE, FINTXN_HEADER__TRANSACTION_TYPE) is not null then 'HUB_FINANCIAL_TRANSACTION|' || FINANCIAL_TRANSACTION_BK end"
  APPROVAL_STATUS: 'FINTXN_HEADER__APPROVAL_STATUS'
  GROSS_AMOUNT: 'FINTXN_HEADER__GROSS_AMOUNT'
  NARRATION: 'FINTXN_HEADER__NARRATION'
  SOURCE_REFERENCE_NUMBER: 'FINTXN_HEADER__SOURCE_REFERENCE_NUMBER'
  SOURCE_REFERENCE_TYPE: 'FINTXN_HEADER__SOURCE_REFERENCE_TYPE'
  TAX_AMOUNT: 'FINTXN_HEADER__TAX_AMOUNT'
  TRANSACTION_DATE: 'FINTXN_HEADER__TRANSACTION_DATE'
  TRANSACTION_NUMBER: 'FINTXN_HEADER__TRANSACTION_NUMBER'
  TRANSACTION_STATUS: 'FINTXN_HEADER__TRANSACTION_STATUS'
  TRANSACTION_SUB_TYPE: 'FINTXN_HEADER__TRANSACTION_SUB_TYPE'
  TRANSACTION_TYPE: 'FINTXN_HEADER__TRANSACTION_TYPE'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v07_financial_transaction'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
