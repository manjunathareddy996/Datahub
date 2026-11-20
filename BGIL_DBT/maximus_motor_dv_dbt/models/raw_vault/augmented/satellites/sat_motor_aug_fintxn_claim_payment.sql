-- AUGMENTED track (not mapper-ratified) sat() for SAT_MOTOR_AUG_FINTXN_CLAIM_PAYMENT (parent HUB_FINANCIAL_TRANSACTION, history SCD2), fed whole from central view stitch_mxm__v07_financial_transaction.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm_aug__fintxn_claim_payment'
src_pk:
  - 'FINANCIAL_TRANSACTION_HKEY'
  - 'SOURCE_SYSTEM'
src_payload:
  - 'AOL_MODE'
  - 'CLAIM_EXPENSE_PAYMENT_MODE'
  - 'INSTRUMENT_PAYABLE_AT_LOCATION'
  - 'INSTRUMENT_PRINT_LOCATION_CODE'
  - 'INTEREST_AMOUNT'
  - 'INTERIM_OR_FINAL_PAYMENT_INDICATOR'
  - 'NCB_RECOVERY_AMOUNT'
  - 'NEFT_STATUS'
  - 'OWN_DAMAGE_PAYMENT_MODE'
  - 'PAID_AGAINST_RESERVE_TYPE'
  - 'PAYMENT_APPROVED_BY_USER_REFERENCE'
  - 'PAYMENT_AUTHORISATION_DATE'
  - 'PAYMENT_DETAIL_TEXT'
  - 'PAYMENT_GROUP_CODE'
  - 'PAYMENT_MODE_OTHER_REMARKS'
  - 'PAYMENT_MODE_REMARKS'
  - 'PAYMENT_PURPOSE'
  - 'PAYMENT_RELEASED_INDICATOR'
  - 'POLICY_SECTION_CODE'
  - 'PORTAL_PAYMENT_REFERENCE_NUMBER'
  - 'SUPPORTING_INVOICE_MODE'
  - 'SUPPORTING_INVOICE_NUMBER'
  - 'UTR_DATE'
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
