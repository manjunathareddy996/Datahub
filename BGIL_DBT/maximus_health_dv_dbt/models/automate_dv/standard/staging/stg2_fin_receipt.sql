-- automate_dv.stage() for SAT_FIN_RECEIPT, read off central view stitch_v09_financial_transaction.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v09_financial_transaction'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'FINANCIAL_TRANSACTION_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'AMOUNT_RECEIVED'
      - 'INSTRUMENT_DATE'
      - 'INSTRUMENT_REFERENCE'
      - 'INSTRUMENT_TYPE'
      - 'PAYER_NAME'
      - 'REALISATION_STATUS'
      - 'RECEIPT_DATE'
      - 'RECEIPT_NUMBER'
derived_columns:
  FINANCIAL_TRANSACTION_NK: "case when coalesce(FIN_RECEIPT__AMOUNT_RECEIVED, FIN_RECEIPT__INSTRUMENT_DATE, FIN_RECEIPT__INSTRUMENT_REFERENCE, FIN_RECEIPT__INSTRUMENT_TYPE, FIN_RECEIPT__PAYER_NAME, FIN_RECEIPT__REALISATION_STATUS, FIN_RECEIPT__RECEIPT_DATE, FIN_RECEIPT__RECEIPT_NUMBER) is not null then 'HUB_FINANCIAL_TRANSACTION|' || FINANCIAL_TRANSACTION_BK end"
  AMOUNT_RECEIVED: 'FIN_RECEIPT__AMOUNT_RECEIVED'
  INSTRUMENT_DATE: 'FIN_RECEIPT__INSTRUMENT_DATE'
  INSTRUMENT_REFERENCE: 'FIN_RECEIPT__INSTRUMENT_REFERENCE'
  INSTRUMENT_TYPE: 'FIN_RECEIPT__INSTRUMENT_TYPE'
  PAYER_NAME: 'FIN_RECEIPT__PAYER_NAME'
  REALISATION_STATUS: 'FIN_RECEIPT__REALISATION_STATUS'
  RECEIPT_DATE: 'FIN_RECEIPT__RECEIPT_DATE'
  RECEIPT_NUMBER: 'FIN_RECEIPT__RECEIPT_NUMBER'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v09_financial_transaction'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
