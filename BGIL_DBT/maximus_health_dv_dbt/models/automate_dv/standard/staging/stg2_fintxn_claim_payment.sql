-- automate_dv.stage() for SAT_FINTXN_CLAIM_PAYMENT, read off central view stitch_v10_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v10_party'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'FINANCIAL_TRANSACTION_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CHEQUE_DISPATCH_DATE'
      - 'NET_PAID_AMOUNT'
      - 'PAYMENT_DATE'
      - 'PAYMENT_MODE'
      - 'PAYMENT_STATUS'
      - 'PAYMENT_TYPE'
      - 'TDS_ON_CLAIM_AMOUNT'
      - 'UTR_NUMBER'
derived_columns:
  FINANCIAL_TRANSACTION_NK: "case when coalesce(FINTXN_CLAIM_PAYMENT__CHEQUE_DISPATCH_DATE, FINTXN_CLAIM_PAYMENT__NET_PAID_AMOUNT, FINTXN_CLAIM_PAYMENT__PAYMENT_DATE, FINTXN_CLAIM_PAYMENT__PAYMENT_MODE, FINTXN_CLAIM_PAYMENT__PAYMENT_STATUS, FINTXN_CLAIM_PAYMENT__PAYMENT_TYPE, FINTXN_CLAIM_PAYMENT__TDS_ON_CLAIM_AMOUNT, FINTXN_CLAIM_PAYMENT__UTR_NUMBER) is not null then 'HUB_FINANCIAL_TRANSACTION|' || FINANCIAL_TRANSACTION_BK end"
  CHEQUE_DISPATCH_DATE: 'FINTXN_CLAIM_PAYMENT__CHEQUE_DISPATCH_DATE'
  NET_PAID_AMOUNT: 'FINTXN_CLAIM_PAYMENT__NET_PAID_AMOUNT'
  PAYMENT_DATE: 'FINTXN_CLAIM_PAYMENT__PAYMENT_DATE'
  PAYMENT_MODE: 'FINTXN_CLAIM_PAYMENT__PAYMENT_MODE'
  PAYMENT_STATUS: 'FINTXN_CLAIM_PAYMENT__PAYMENT_STATUS'
  PAYMENT_TYPE: 'FINTXN_CLAIM_PAYMENT__PAYMENT_TYPE'
  TDS_ON_CLAIM_AMOUNT: 'FINTXN_CLAIM_PAYMENT__TDS_ON_CLAIM_AMOUNT'
  UTR_NUMBER: 'FINTXN_CLAIM_PAYMENT__UTR_NUMBER'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v10_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
