-- automate_dv.stage() for SAT_FIN_RECEIPT, read off central view stitch_v31_product.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v31_product'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'FINANCIAL_TRANSACTION_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'BANK_REFERENCE'
      - 'CHEQUE_TYPE'
      - 'RECEIPT_NUMBER'
derived_columns:
  FINANCIAL_TRANSACTION_NK: "case when coalesce(FIN_RECEIPT__BANK_REFERENCE, FIN_RECEIPT__CHEQUE_TYPE, FIN_RECEIPT__RECEIPT_NUMBER) is not null then 'HUB_FINANCIAL_TRANSACTION|' || FINANCIAL_TRANSACTION_BK end"
  BANK_REFERENCE: 'FIN_RECEIPT__BANK_REFERENCE'
  CHEQUE_TYPE: 'FIN_RECEIPT__CHEQUE_TYPE'
  RECEIPT_NUMBER: 'FIN_RECEIPT__RECEIPT_NUMBER'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v31_product'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
