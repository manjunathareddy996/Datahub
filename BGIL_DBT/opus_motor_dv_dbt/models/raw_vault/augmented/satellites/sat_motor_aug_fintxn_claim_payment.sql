-- AUGMENTED track (not mapper-ratified) sat() for SAT_MOTOR_AUG_FINTXN_CLAIM_PAYMENT (parent HUB_FINANCIAL_TRANSACTION, history SCD2), fed whole from central view stitch_motor__v03_claim.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor_aug__fintxn_claim_payment'
src_pk:
  - 'FINANCIAL_TRANSACTION_HKEY'
  - 'SOURCE_SYSTEM'
src_payload:
  - 'CHEQUE_ISSUE_REASON'
  - 'EXCHANGE_GAIN_LOSS_AMOUNT'
  - 'FOREIGN_CURRENCY_INDICATOR'
  - 'LOCAL_PAYMENT_INDICATOR'
  - 'NCB_RECOVERY_AMOUNT'
  - 'PAYEE_BANK_BRANCH_CODE'
  - 'PAYEE_BANK_CODE'
  - 'PAYMENT_REQUEST_REFERENCE'
  - 'SUPPORTING_INVOICE_DATE'
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
