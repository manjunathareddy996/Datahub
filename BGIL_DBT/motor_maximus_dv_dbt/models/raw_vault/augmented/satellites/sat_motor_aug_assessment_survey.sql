-- AUGMENTED track (not mapper-ratified) sat() for SAT_MOTOR_AUG_ASSESSMENT_SURVEY (parent HUB_ASSESSMENT, history SCD2), fed whole from central view stitch_mxm__v01_assessment.
{{ config(materialized='incremental', meta={'apply_source_filter': true}) }}

{%- set yaml_metadata -%}
source_model: 'stg2_mxm_aug__assessment_survey'
src_pk:
  - 'ASSESSMENT_HKEY'
  - 'SOURCE_SYSTEM'
src_payload:
  - 'FINAL_SURVEY_REMARKS'
  - 'FINAL_VISIT_TIME'
  - 'LIVE_VIDEO_SURVEY_INDICATOR'
  - 'PRELIMINARY_SURVEY_REPORT_DELAY_DAYS'
  - 'PRELIMINARY_SURVEY_REPORT_DELAY_REASON'
  - 'PRELIMINARY_SURVEY_REPORT_DELAY_REMARKS'
  - 'SPOT_SURVEY_DATE'
  - 'SPOT_SURVEY_DELAY_DAYS'
  - 'SPOT_SURVEY_OTHER_REMARKS'
  - 'SPOT_SURVEY_REMARKS'
  - 'SPOT_SURVEY_TIME'
  - 'SURVEYOR_GENERAL_OBSERVATIONS'
  - 'SURVEYOR_SCREEN_SAVE_INDICATOR_IS'
  - 'SURVEYOR_SCREEN_SAVE_INDICATOR_PA'
  - 'SURVEYOR_TECHNICAL_OBSERVATIONS'
  - 'SURVEY_CONFIRMATION_DELAY_DAYS'
  - 'SURVEY_CONFIRMATION_OTHER_REMARKS'
  - 'WORK_APPROVAL_DELAY_DAYS'
  - 'WORK_APPROVAL_OTHER_REMARKS'
  - 'WORK_APPROVAL_REMARKS'
  - 'WORK_APPROVAL_TIME'
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
