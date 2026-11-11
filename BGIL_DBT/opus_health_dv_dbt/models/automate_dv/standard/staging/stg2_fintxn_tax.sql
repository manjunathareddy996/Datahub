-- automate_dv.stage() for SAT_FINTXN_TAX, read off central view stitch_v26_policy.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v26_policy'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'FINANCIAL_TRANSACTION_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CGST_AMOUNT'
      - 'IGST_AMOUNT'
      - 'SERVICE_TAX_AMOUNT'
      - 'SERVICE_TAX_RATE'
      - 'SERVICE_TAX_REGISTRATION_NUMBER'
      - 'SGST_AMOUNT'
      - 'TDS_RATE'
      - 'TAX_TYPE_CK'
derived_columns:
  FINANCIAL_TRANSACTION_NK: "case when coalesce(FINTXN_TAX__CGST_AMOUNT, FINTXN_TAX__IGST_AMOUNT, FINTXN_TAX__SERVICE_TAX_AMOUNT, FINTXN_TAX__SERVICE_TAX_RATE, FINTXN_TAX__SERVICE_TAX_REGISTRATION_NUMBER, FINTXN_TAX__SGST_AMOUNT, FINTXN_TAX__TDS_RATE) is not null then 'HUB_FINANCIAL_TRANSACTION|' || FINANCIAL_TRANSACTION_BK end"
  TAX_TYPE_CK: 'FINTXN_TAX__TAX_TYPE_CK'
  CGST_AMOUNT: 'FINTXN_TAX__CGST_AMOUNT'
  IGST_AMOUNT: 'FINTXN_TAX__IGST_AMOUNT'
  SERVICE_TAX_AMOUNT: 'FINTXN_TAX__SERVICE_TAX_AMOUNT'
  SERVICE_TAX_RATE: 'FINTXN_TAX__SERVICE_TAX_RATE'
  SERVICE_TAX_REGISTRATION_NUMBER: 'FINTXN_TAX__SERVICE_TAX_REGISTRATION_NUMBER'
  SGST_AMOUNT: 'FINTXN_TAX__SGST_AMOUNT'
  TDS_RATE: 'FINTXN_TAX__TDS_RATE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v26_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
