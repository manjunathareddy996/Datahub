-- automate_dv.stage() for SAT_CASE_WORKFLOW_TASK, read off central view stitch_mxm__v02_case.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v02_case'
hashed_columns:
  CASE_HKEY: 'CASE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'COMPLETED_DATE'
      - 'TASK_STATUS'
      - 'TASK_TYPE'
      - 'TASK_CODE_CK'
derived_columns:
  CASE_NK: "case when coalesce(CASE_WORKFLOW_TASK__COMPLETED_DATE, CASE_WORKFLOW_TASK__TASK_STATUS, CASE_WORKFLOW_TASK__TASK_TYPE) is not null then 'HUB_CASE|' || CASE_BK end"
  TASK_CODE_CK: 'CASE_WORKFLOW_TASK__TASK_CODE_CK'
  COMPLETED_DATE: 'CASE_WORKFLOW_TASK__COMPLETED_DATE'
  TASK_STATUS: 'CASE_WORKFLOW_TASK__TASK_STATUS'
  TASK_TYPE: 'CASE_WORKFLOW_TASK__TASK_TYPE'
  LOAD_DATETIME: 'CASE_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v02_case'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
