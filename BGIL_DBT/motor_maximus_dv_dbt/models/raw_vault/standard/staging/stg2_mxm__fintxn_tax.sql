-- automate_dv.stage() for SAT_FINTXN_TAX, read off central view stitch_mxm__v07_financial_transaction.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v07_financial_transaction'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'FINANCIAL_TRANSACTION_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CGST_AMOUNT'
      - 'IGST_AMOUNT'
      - 'SGST_AMOUNT'
      - 'SGST_RATE'
      - 'TAXABLE_VALUE'
      - 'TAX_APPLICABLE_INDICATOR'
      - 'TAX_INVOICE_DATE'
      - 'TAX_INVOICE_NUMBER'
      - 'TAX_RATE'
      - 'TDS_AMOUNT'
      - 'TDS_RATE'
      - 'TAX_TYPE_CK'
derived_columns:
  FINANCIAL_TRANSACTION_NK: "case when coalesce(FINTXN_TAX__CGST_AMOUNT, FINTXN_TAX__IGST_AMOUNT, FINTXN_TAX__SGST_AMOUNT, FINTXN_TAX__SGST_RATE, FINTXN_TAX__TAXABLE_VALUE, FINTXN_TAX__TAX_APPLICABLE_INDICATOR, FINTXN_TAX__TAX_INVOICE_DATE, FINTXN_TAX__TAX_INVOICE_NUMBER, FINTXN_TAX__TAX_RATE, FINTXN_TAX__TDS_AMOUNT, FINTXN_TAX__TDS_RATE) is not null then 'HUB_FINANCIAL_TRANSACTION|' || FINANCIAL_TRANSACTION_BK end"
  TAX_TYPE_CK: 'FINTXN_TAX__TAX_TYPE_CK'
  CGST_AMOUNT: 'FINTXN_TAX__CGST_AMOUNT'
  IGST_AMOUNT: 'FINTXN_TAX__IGST_AMOUNT'
  SGST_AMOUNT: 'FINTXN_TAX__SGST_AMOUNT'
  SGST_RATE: 'FINTXN_TAX__SGST_RATE'
  TAXABLE_VALUE: 'FINTXN_TAX__TAXABLE_VALUE'
  TAX_APPLICABLE_INDICATOR: 'FINTXN_TAX__TAX_APPLICABLE_INDICATOR'
  TAX_INVOICE_DATE: 'FINTXN_TAX__TAX_INVOICE_DATE'
  TAX_INVOICE_NUMBER: 'FINTXN_TAX__TAX_INVOICE_NUMBER'
  TAX_RATE: 'FINTXN_TAX__TAX_RATE'
  TDS_AMOUNT: 'FINTXN_TAX__TDS_AMOUNT'
  TDS_RATE: 'FINTXN_TAX__TDS_RATE'
  LOAD_DATETIME: 'FINANCIAL_TRANSACTION_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!stitch_mxm__v07_financial_transaction'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
