-- AUGMENTED track (not mapper-ratified) ma_sat() for SAT_AUG_CASE_WORKFLOW_TASK (parent HUB_CASE, history SCD2), fed whole from central view stitch_motor__v02_claim.
-- GRAIN_UNRATIFIED (P-2): emitted as the map states. Self-named child-key blocks here write several
-- attributes of ONE entity, shredding it into child rows. Not ratified as a grain change; routed to the modeller.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_motor_aug__case_workflow_task'
src_pk: 'CASE_HKEY'
src_cdk:
  - 'TASK_CODE_CK'
src_payload:
  - 'TASK_CORRESPONDENCE_EMAIL_ADDRESS'
  - 'TASK_REMARKS'
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
