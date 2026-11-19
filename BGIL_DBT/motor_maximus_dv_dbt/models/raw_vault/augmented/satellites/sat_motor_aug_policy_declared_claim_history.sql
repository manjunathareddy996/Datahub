-- AUGMENTED track (not mapper-ratified) sat() for SAT_MOTOR_AUG_POLICY_DECLARED_CLAIM_HISTORY (parent HUB_POLICY, history SCD2), fed whole from central view stitch_mxm__v12_policy.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm_aug__policy_declared_claim_history'
src_pk: 'POLICY_HKEY'
src_payload:
  - 'ACCIDENT_DATE'
  - 'ACCIDENT_LOCATION_DESCRIPTION'
  - 'CASE_FILED_BEFORE_FORUM'
  - 'CLAIM_AREA_CODE'
  - 'CLAIM_HANDLING_LOCATION_CODE'
  - 'CLAIM_INTIMATION_DATE'
  - 'CLAIM_INTIMATION_TIME'
  - 'CLAIM_INTIMATION_TYPE'
  - 'CLAIM_INTIMATOR_MOBILE_NUMBER'
  - 'CLAIM_INTIMATOR_NAME'
  - 'CLAIM_LOCATION_DESCRIPTION'
  - 'CLAIM_REGISTRATION_LOCATION_CODE'
  - 'CLAIM_REQUIREMENT_STATUS'
  - 'CLAIM_SUB_STATUS'
  - 'CLAIM_TYPE'
  - 'CLAIM_TYPES_LIST'
  - 'COURT_LOCATION_AS_PER_INTIMATION'
  - 'COURT_NAME_AS_PER_INTIMATION'
  - 'COURT_TYPE'
  - 'DECLARED_CLAIM_AMOUNT'
  - 'DECLARED_CLAIM_DATE'
  - 'EXPENSE_FEE_HEAD_CODE'
  - 'EXPENSE_PAYMENT_AMOUNT'
  - 'EXPENSE_PAYMENT_APPROVED_BY'
  - 'EXPENSE_PAYMENT_DATE'
  - 'EXPENSE_PAYMENT_REFERENCE_NUMBER'
  - 'EXPENSE_PAYMENT_TYPE'
  - 'EXPENSE_PORTAL_PAYMENT_REFERENCE_NUMBER'
  - 'EXPENSE_REFERENCE_TEXT'
  - 'LOSS_CAUSE'
  - 'LOSS_DATE'
  - 'LOSS_DESCRIPTION'
  - 'LOSS_INFORMATION_DESCRIPTION'
  - 'PERSONAL_ACCIDENT_LOSS_CAUSE'
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
