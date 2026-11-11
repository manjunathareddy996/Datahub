-- Standard ma_sat() for SAT_CASE_WORKFLOW_TASK (parent HUB_CASE, history Multi-Active SCD2), fed whole from central view stitch_v01_case.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_case_workflow_task'
src_pk: 'CASE_HKEY'
src_cdk:
  - 'TASK_CODE_CK'
src_payload:
  - 'ASSIGNED_TO_REFERENCE'
  - 'COMPLETED_DATE'
  - 'DUE_DATE'
  - 'OUTCOME'
  - 'QUEUE_REFERENCE'
  - 'TASK_NAME'
  - 'TASK_STATUS'
  - 'TASK_TYPE'
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
