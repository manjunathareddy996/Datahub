-- automate_dv.stage() for SAT_FIN_RECEIPT, read off central view stitch_motor__v18_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v18_policy'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'FINANCIAL_TRANSACTION_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'AMOUNT_RECEIVED'
      - 'AUTHORISATION_CODE'
      - 'BANK_REFERENCE'
      - 'INSTRUMENT_TYPE'
      - 'MERCHANT_REFERENCE'
      - 'PAYMENT_GATEWAY_REFERENCE'
      - 'REALISATION_DATE'
      - 'REALISATION_STATUS'
      - 'RECEIPT_DATE'
      - 'RECEIPT_NUMBER'
derived_columns:
  FINANCIAL_TRANSACTION_NK: "case when coalesce(FIN_RECEIPT__AMOUNT_RECEIVED, FIN_RECEIPT__AUTHORISATION_CODE, FIN_RECEIPT__BANK_REFERENCE, FIN_RECEIPT__INSTRUMENT_TYPE, FIN_RECEIPT__MERCHANT_REFERENCE, FIN_RECEIPT__PAYMENT_GATEWAY_REFERENCE, FIN_RECEIPT__REALISATION_DATE, FIN_RECEIPT__REALISATION_STATUS, FIN_RECEIPT__RECEIPT_DATE, FIN_RECEIPT__RECEIPT_NUMBER) is not null then 'HUB_FINANCIAL_TRANSACTION|' || FINANCIAL_TRANSACTION_BK end"
  AMOUNT_RECEIVED: 'FIN_RECEIPT__AMOUNT_RECEIVED'
  AUTHORISATION_CODE: 'FIN_RECEIPT__AUTHORISATION_CODE'
  BANK_REFERENCE: 'FIN_RECEIPT__BANK_REFERENCE'
  INSTRUMENT_TYPE: 'FIN_RECEIPT__INSTRUMENT_TYPE'
  MERCHANT_REFERENCE: 'FIN_RECEIPT__MERCHANT_REFERENCE'
  PAYMENT_GATEWAY_REFERENCE: 'FIN_RECEIPT__PAYMENT_GATEWAY_REFERENCE'
  REALISATION_DATE: 'FIN_RECEIPT__REALISATION_DATE'
  REALISATION_STATUS: 'FIN_RECEIPT__REALISATION_STATUS'
  RECEIPT_DATE: 'FIN_RECEIPT__RECEIPT_DATE'
  RECEIPT_NUMBER: 'FIN_RECEIPT__RECEIPT_NUMBER'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_stitch_motor__v18_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
