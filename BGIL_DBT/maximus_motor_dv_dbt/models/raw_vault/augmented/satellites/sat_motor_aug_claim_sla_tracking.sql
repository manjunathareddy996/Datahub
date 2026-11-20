-- AUGMENTED track (not mapper-ratified) sat() for SAT_MOTOR_AUG_CLAIM_SLA_TRACKING (parent HUB_CLAIM, history SCD2), fed whole from central view stitch_mxm__v03_claim.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm_aug__claim_sla_tracking'
src_pk:
  - 'CLAIM_HKEY'
  - 'SOURCE_SYSTEM'
src_payload:
  - 'ADMISSIBILITY_DELAY_INDICATOR'
  - 'ADMISSIBILITY_DELAY_REMARKS'
  - 'EXECUTION_STEP_REQUIRED_INDICATOR'
  - 'PROCESSING_DELAY_REASON'
  - 'REFERRAL_REASON_AT_ASSESSMENT'
  - 'REFERRAL_REASON_FOR_PERSONAL_ACCIDENT'
  - 'REFERRED_TO_REFERENCE'
  - 'REFERRED_TO_REFERENCE_FOR_PERSONAL_ACCIDENT'
  - 'REQUIREMENT_STATUS'
  - 'WORKFLOW_ACTION'
  - 'WORK_BUCKET_CODE'
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
