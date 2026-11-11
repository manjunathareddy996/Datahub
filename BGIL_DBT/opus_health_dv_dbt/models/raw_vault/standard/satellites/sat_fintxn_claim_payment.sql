-- Standard sat() for SAT_FINTXN_CLAIM_PAYMENT (parent HUB_FINANCIAL_TRANSACTION, history SCD2), fed whole from central view stitch_v11_claim.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_fintxn_claim_payment'
src_pk: 'FINANCIAL_TRANSACTION_HKEY'
src_payload:
  - 'CHEQUE_DATE'
  - 'CHEQUE_DISPATCH_DATE'
  - 'CHEQUE_RECEIVED_DATE'
  - 'NET_PAID_AMOUNT'
  - 'PAYMENT_DATE'
  - 'PAYMENT_MODE'
  - 'PAYMENT_STATUS'
  - 'TDS_ON_CLAIM_AMOUNT'
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
