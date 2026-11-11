-- automate_dv.stage() for SAT_FINTXN_CLAIM_PAYMENT, read off central view stitch_v11_claim.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v11_claim'
hashed_columns:
  FINANCIAL_TRANSACTION_HKEY: 'FINANCIAL_TRANSACTION_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CHEQUE_DATE'
      - 'CHEQUE_DISPATCH_DATE'
      - 'CHEQUE_RECEIVED_DATE'
      - 'NET_PAID_AMOUNT'
      - 'PAYMENT_DATE'
      - 'PAYMENT_MODE'
      - 'PAYMENT_STATUS'
      - 'TDS_ON_CLAIM_AMOUNT'
      - 'UTR_NUMBER'
derived_columns:
  FINANCIAL_TRANSACTION_NK: "case when coalesce(FINTXN_CLAIM_PAYMENT__CHEQUE_DATE, FINTXN_CLAIM_PAYMENT__CHEQUE_DISPATCH_DATE, FINTXN_CLAIM_PAYMENT__CHEQUE_RECEIVED_DATE, FINTXN_CLAIM_PAYMENT__NET_PAID_AMOUNT, FINTXN_CLAIM_PAYMENT__PAYMENT_DATE, FINTXN_CLAIM_PAYMENT__PAYMENT_MODE, FINTXN_CLAIM_PAYMENT__PAYMENT_STATUS, FINTXN_CLAIM_PAYMENT__TDS_ON_CLAIM_AMOUNT, FINTXN_CLAIM_PAYMENT__UTR_NUMBER) is not null then 'HUB_FINANCIAL_TRANSACTION|' || FINANCIAL_TRANSACTION_BK end"
  CHEQUE_DATE: 'FINTXN_CLAIM_PAYMENT__CHEQUE_DATE'
  CHEQUE_DISPATCH_DATE: 'FINTXN_CLAIM_PAYMENT__CHEQUE_DISPATCH_DATE'
  CHEQUE_RECEIVED_DATE: 'FINTXN_CLAIM_PAYMENT__CHEQUE_RECEIVED_DATE'
  NET_PAID_AMOUNT: 'FINTXN_CLAIM_PAYMENT__NET_PAID_AMOUNT'
  PAYMENT_DATE: 'FINTXN_CLAIM_PAYMENT__PAYMENT_DATE'
  PAYMENT_MODE: 'FINTXN_CLAIM_PAYMENT__PAYMENT_MODE'
  PAYMENT_STATUS: 'FINTXN_CLAIM_PAYMENT__PAYMENT_STATUS'
  TDS_ON_CLAIM_AMOUNT: 'FINTXN_CLAIM_PAYMENT__TDS_ON_CLAIM_AMOUNT'
  UTR_NUMBER: 'FINTXN_CLAIM_PAYMENT__UTR_NUMBER'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v11_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
