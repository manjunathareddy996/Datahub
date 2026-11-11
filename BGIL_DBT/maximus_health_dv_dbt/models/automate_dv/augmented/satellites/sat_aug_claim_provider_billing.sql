-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_AUG_CLAIM_PROVIDER_BILLING (parent HUB_CLAIM, history SCD2), fed whole from central view stitch_v02_claim.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_claim_provider_billing'
src_pk: 'CLAIM_HKEY'
src_cdk:
  - 'BILL_NUMBER_CK'
src_payload:
  - 'ADDITIONAL_BILL_DISCOUNT_AMOUNT'
  - 'APPROVED_QUANTITY'
  - 'BILLED_QUANTITY'
  - 'BILL_DISCOUNT_AMOUNT'
  - 'BILL_GST_AMOUNT'
  - 'HOSPITAL_GST_AMOUNT'
  - 'HOSPITAL_ITEM_CODE'
  - 'HOSPITAL_ITEM_DESCRIPTION'
  - 'INVOICE_RAISED_AGAINST_INSURER_INDICATOR'
  - 'MANUAL_REJECTION_INDICATOR'
  - 'NON_MEDICAL_EXPENSE_AMOUNT'
  - 'NON_MEDICAL_ITEMS'
  - 'NUMBER_OF_SITTINGS'
  - 'OVERRIDE_REMARKS'
  - 'PAYMENT_RECEIVED_INDICATOR'
  - 'PER_SITTING_CHARGE_AMOUNT'
  - 'PHARMACY_RETURN_AMOUNT'
  - 'PHARMACY_RETURN_DEDUCTED_AMOUNT'
  - 'REASONABLE_AND_CUSTOMARY_CHARGE_AMOUNT'
  - 'REASONABLE_AND_CUSTOMARY_DEDUCTION_REMARKS'
  - 'SERVICE_RENDERED_DATE'
  - 'TARIFF_INDICATOR_TYPE'
  - 'UNIT_OF_MEASURE'
  - 'UNIT_TYPE'
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
