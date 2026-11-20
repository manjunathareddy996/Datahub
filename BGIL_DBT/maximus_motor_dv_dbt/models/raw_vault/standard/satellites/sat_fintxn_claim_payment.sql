-- Standard sat() for SAT_FINTXN_CLAIM_PAYMENT (parent HUB_FINANCIAL_TRANSACTION, history SCD2), fed whole from central view stitch_mxm__v03_claim.
-- WRITERS MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW | SAT_FINTXN_CLAIM_PAYMENT | Payment Type | claim-payment: emits PAYMENT_TYPE; withheld TYPE_OF_PAYMENT
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm__fintxn_claim_payment'
src_pk:
  - 'FINANCIAL_TRANSACTION_HKEY'
  - 'SOURCE_SYSTEM'
src_payload:
  - 'CHEQUE_DATE'
  - 'CHEQUE_NUMBER'
  - 'HOLD_INDICATOR'
  - 'HOLD_REASON'
  - 'NET_PAID_AMOUNT'
  - 'PAYMENT_DATE'
  - 'PAYMENT_MODE'
  - 'PAYMENT_STATUS'
  - 'PAYMENT_TYPE'
  - 'UTR_NUMBER'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.sat(src_pk=metadata_dict['src_pk'],
                   src_payload=metadata_dict['src_payload'],
                   src_hashdiff=metadata_dict['src_hashdiff'],
                   src_ldts=metadata_dict['src_ldts'],
                   src_source=metadata_dict['src_source'],
                   source_model=metadata_dict['source_model']) }}
