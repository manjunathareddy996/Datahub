-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_MOTOR_AUG_CLAIM_PROVIDER_BILLING (parent HUB_CLAIM, history SCD2), fed whole from central view stitch_mxm__v03_claim.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm_aug__claim_provider_billing'
src_pk:
  - 'CLAIM_HKEY'
  - 'SOURCE_SYSTEM'
src_cdk:
  - 'BILL_NUMBER_CK'
src_payload:
  - 'ACTUAL_BILL_AMOUNT'
  - 'APPROVAL_OR_REJECTION_DECISION'
  - 'APPROVER_REMARKS'
  - 'BILL_ADJUDICATED_BY_USER'
  - 'BILL_BREAKUP_DETAIL'
  - 'BILL_BREAKUP_TEXT'
  - 'BILL_CURRENCY_CODE'
  - 'BILL_DISCOUNT_AMOUNT'
  - 'BILL_RAISED_BY_NAME'
  - 'BILL_RAISED_TO_NAME'
  - 'BILL_RAISING_PARTY_GSTIN'
  - 'BILL_TIME'
  - 'BILL_TO_PARTY_GSTIN'
  - 'BILL_TO_PLACE_OF_SUPPLY_STATE_CODE'
  - 'CGST_AMOUNT'
  - 'CGST_RATE'
  - 'DISALLOWANCE_BREAKUP_DETAIL'
  - 'DISALLOWED_AMOUNT_BREAKUP_TEXT'
  - 'E_INVOICE_IRN'
  - 'GST_APPLICABLE_INDICATOR'
  - 'IGST_AMOUNT'
  - 'IGST_RATE'
  - 'INVOICE_AMOUNT'
  - 'INVOICE_DATE'
  - 'INVOICE_NUMBER'
  - 'INVOICE_PATTERN'
  - 'INVOICE_PATTERN_CODE'
  - 'INVOICE_RECEIVED_DATE'
  - 'INVOICE_RECEIVED_TIME'
  - 'INVOICE_TIME'
  - 'INVOICE_TYPE'
  - 'PLACE_OF_SUPPLY_STATE'
  - 'PROFORMA_INVOICE_AMOUNT'
  - 'PROFORMA_INVOICE_DATE'
  - 'PROFORMA_INVOICE_TIME'
  - 'TAXABLE_AMOUNT'
  - 'TAX_AMOUNT'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.ma_sat(src_pk=metadata_dict['src_pk'],
                      src_cdk=metadata_dict['src_cdk'],
                      src_payload=metadata_dict['src_payload'],
                      src_hashdiff=metadata_dict['src_hashdiff'],
                      src_ldts=metadata_dict['src_ldts'],
                      src_source=metadata_dict['src_source'],
                      source_model=metadata_dict['source_model']) }}
