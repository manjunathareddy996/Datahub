-- AUGMENTED track (not mapper-ratified) sat() for SAT_AUG_CLAIM_PROCESS_STEP_LOG (parent HUB_CLAIM, history SCD2), fed whole from central view stitch_v09_claim.
{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg2_aug_claim_process_step_log'
src_pk: 'CLAIM_HKEY'
src_payload:
  - 'LOG_TYPE_CODE'
  - 'NEXT_CASE_REFERENCE'
  - 'PROCESS_LOG_REFERENCE'
  - 'PROCESS_TYPE_CODE'
  - 'STEP_ACTOR_USER_REFERENCE'
  - 'STEP_ACTUAL_START_TIMESTAMP'
  - 'STEP_END_TIMESTAMP'
  - 'STEP_START_TIMESTAMP'
  - 'STEP_STATUS_CODE'
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
