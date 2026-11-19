-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_MOTOR_AUG_CLAIM_FOLLOW_UP_CHASE (parent HUB_CLAIM, history SCD2), fed whole from central view stitch_mxm__v04_claim.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm_aug__claim_follow_up_chase'
src_pk: 'CLAIM_HKEY'
src_cdk:
  - 'FOLLOW_UP_REFERENCE_CK'
src_payload:
  - 'ASSIGNED_TO_USER_REFERENCE'
  - 'FIRST_REMINDER_DATE'
  - 'FOLLOW_UP_CREATED_BY_USER_REFERENCE'
  - 'FOLLOW_UP_CREATED_DATE'
  - 'FOLLOW_UP_DESCRIPTION_REMARKS'
  - 'FOLLOW_UP_EFFECTIVE_DATE'
  - 'FOLLOW_UP_EVENT_CODE'
  - 'FOLLOW_UP_KEYWORD'
  - 'FOLLOW_UP_PRIORITY'
  - 'FOLLOW_UP_STATUS'
  - 'FOLLOW_UP_TIMESTAMP'
  - 'FOLLOW_UP_UPDATED_BY_USER_REFERENCE'
  - 'FOLLOW_UP_UPDATED_DATE'
  - 'SECOND_REMINDER_DATE'
  - 'THIRD_REMINDER_DATE'
  - 'WORKFLOW_JOB_STATUS'
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
