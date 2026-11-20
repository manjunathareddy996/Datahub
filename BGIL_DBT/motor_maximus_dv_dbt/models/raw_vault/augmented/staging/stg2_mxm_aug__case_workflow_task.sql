-- automate_dv.stage() for SAT_MOTOR_AUG_CASE_WORKFLOW_TASK, read off central view stitch_mxm__v02_case.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v02_case'
hashed_columns:
  CASE_HKEY: 'CASE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'TASK_RAISED_BY_REFERENCE'
      - 'TASK_RAISED_DATE'
      - 'TASK_REMARKS'
      - 'TASK_CODE_CK'
derived_columns:
  CASE_NK: "case when coalesce(AUG_CASE_WORKFLOW_TASK__TASK_RAISED_BY_REFERENCE, AUG_CASE_WORKFLOW_TASK__TASK_RAISED_DATE, AUG_CASE_WORKFLOW_TASK__TASK_REMARKS) is not null then 'HUB_CASE|' || CASE_BK end"
  TASK_CODE_CK: 'AUG_CASE_WORKFLOW_TASK__TASK_CODE_CK'
  TASK_RAISED_BY_REFERENCE: 'AUG_CASE_WORKFLOW_TASK__TASK_RAISED_BY_REFERENCE'
  TASK_RAISED_DATE: 'AUG_CASE_WORKFLOW_TASK__TASK_RAISED_DATE'
  TASK_REMARKS: 'AUG_CASE_WORKFLOW_TASK__TASK_REMARKS'
  LOAD_DATETIME: 'CASE_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v02_case'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
