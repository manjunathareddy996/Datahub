-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_MOTOR_AUG_PARTY_BANKING (parent HUB_PARTY, history SCD2), fed whole from central view stitch_mxm__v09_party.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm_aug__party_banking'
src_pk: 'PARTY_HKEY'
src_cdk:
  - 'ACCOUNT_NUMBER_MASKED_CK'
src_payload:
  - 'ACCOUNT_CATEGORY_CODE'
  - 'ACCOUNT_NUMBER'
  - 'APPROVED_OR_REJECTED_BY_USER_REFERENCE'
  - 'APPROVED_OR_REJECTED_DATE'
  - 'BANK_BRANCH_CODE'
  - 'BANK_RECORD_REMARKS'
  - 'NEFT_VALIDATION_STATUS'
  - 'PAYEE_NAME_AS_PER_BANK_RECORD'
  - 'PENNY_DROP_SKIPPED_INDICATOR'
  - 'PENNY_DROP_VERIFICATION_SCORE'
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
