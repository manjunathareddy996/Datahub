-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_MOTOR_AUG_CLAIM_RECOVERY_EXPENSE_LINE (parent HUB_CLAIM, history SCD2), fed whole from central view stitch_mxm__v09_party.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm_aug__claim_recovery_expense_line'
src_pk: 'CLAIM_HKEY'
src_cdk:
  - 'EXPENSE_HEAD_CODE_CK'
src_payload:
  - 'CONVEYANCE_AMOUNT'
  - 'EXPENSE_AMOUNT'
  - 'EXPENSE_CURRENCY_CODE'
  - 'EXPENSE_HEAD_CODE'
  - 'EXPENSE_HEAD_NAME'
  - 'EXPENSE_PAYMENT_AMOUNT'
  - 'EXPENSE_PAYMENT_APPROVED_BY_USER_REFERENCE'
  - 'EXPENSE_PAYMENT_DATE'
  - 'EXPENSE_PAYMENT_REFERENCE_NUMBER'
  - 'EXPENSE_PAYMENT_TYPE'
  - 'EXPENSE_PORTAL_PAYMENT_REFERENCE_NUMBER'
  - 'EXPENSE_QUANTITY'
  - 'EXPENSE_RATE'
  - 'EXPENSE_REFERENCE_TEXT'
  - 'FLAT_RATE_AMOUNT'
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
