-- automate_dv.stage() for SAT_FIN_RECEIPT, read off central view stitch_mxm__v09_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v09_party'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'FINANCIAL_TRANSACTION_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'AMOUNT_RECEIVED'
      - 'REALISATION_DATE'
      - 'RECEIPT_DATE'
      - 'RECEIPT_NUMBER'
      - 'RECEIPT_TYPE'
derived_columns:
  FINANCIAL_TRANSACTION_NK: "case when coalesce(FIN_RECEIPT__AMOUNT_RECEIVED, FIN_RECEIPT__REALISATION_DATE, FIN_RECEIPT__RECEIPT_DATE, FIN_RECEIPT__RECEIPT_NUMBER, FIN_RECEIPT__RECEIPT_TYPE) is not null then 'HUB_FINANCIAL_TRANSACTION|' || FINANCIAL_TRANSACTION_BK end"
  AMOUNT_RECEIVED: 'FIN_RECEIPT__AMOUNT_RECEIVED'
  REALISATION_DATE: 'FIN_RECEIPT__REALISATION_DATE'
  RECEIPT_DATE: 'FIN_RECEIPT__RECEIPT_DATE'
  RECEIPT_NUMBER: 'FIN_RECEIPT__RECEIPT_NUMBER'
  RECEIPT_TYPE: 'FIN_RECEIPT__RECEIPT_TYPE'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v09_party'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
