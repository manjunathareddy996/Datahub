-- automate_dv.stage() for SAT_MOTOR_AUG_CASE_WORKFLOW_TASK, read off central view stitch_motor__v02_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v02_claim'
hashed_columns:
  CASE_HKEY: 'CASE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'TASK_CORRESPONDENCE_EMAIL_ADDRESS'
      - 'TASK_REMARKS'
      - 'TASK_CODE_CK'
derived_columns:
  CASE_NK: "case when coalesce(AUG_CASE_WORKFLOW_TASK__TASK_CORRESPONDENCE_EMAIL_ADDRESS, AUG_CASE_WORKFLOW_TASK__TASK_REMARKS) is not null then 'HUB_CASE|' || CASE_BK end"
  TASK_CODE_CK: 'AUG_CASE_WORKFLOW_TASK__TASK_CODE_CK'
  TASK_CORRESPONDENCE_EMAIL_ADDRESS: 'AUG_CASE_WORKFLOW_TASK__TASK_CORRESPONDENCE_EMAIL_ADDRESS'
  TASK_REMARKS: 'AUG_CASE_WORKFLOW_TASK__TASK_REMARKS'
  LOAD_DATETIME: 'CASE_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!OPUS_stitch_motor__v02_claim'
  SOURCE_SYSTEM: '!OPUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
