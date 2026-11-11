-- automate_dv.stage() for SAT_AUG_CLAIM_PROCESS_STEP_LOG, read off central view stitch_v09_claim.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v09_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'LOG_TYPE_CODE'
      - 'NEXT_CASE_REFERENCE'
      - 'PROCESS_LOG_REFERENCE'
      - 'PROCESS_TYPE_CODE'
      - 'STEP_ACTOR_USER_REFERENCE'
      - 'STEP_ACTUAL_START_TIMESTAMP'
      - 'STEP_END_TIMESTAMP'
      - 'STEP_START_TIMESTAMP'
      - 'STEP_STATUS_CODE'
derived_columns:
  CLAIM_NK: "case when coalesce(AUG_CLAIM_PROCESS_STEP_LOG__LOG_TYPE_CODE, AUG_CLAIM_PROCESS_STEP_LOG__NEXT_CASE_REFERENCE, AUG_CLAIM_PROCESS_STEP_LOG__PROCESS_LOG_REFERENCE, AUG_CLAIM_PROCESS_STEP_LOG__PROCESS_TYPE_CODE, AUG_CLAIM_PROCESS_STEP_LOG__STEP_ACTOR_USER_REFERENCE, AUG_CLAIM_PROCESS_STEP_LOG__STEP_ACTUAL_START_TIMESTAMP, AUG_CLAIM_PROCESS_STEP_LOG__STEP_END_TIMESTAMP, AUG_CLAIM_PROCESS_STEP_LOG__STEP_START_TIMESTAMP, AUG_CLAIM_PROCESS_STEP_LOG__STEP_STATUS_CODE) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  LOG_TYPE_CODE: 'AUG_CLAIM_PROCESS_STEP_LOG__LOG_TYPE_CODE'
  NEXT_CASE_REFERENCE: 'AUG_CLAIM_PROCESS_STEP_LOG__NEXT_CASE_REFERENCE'
  PROCESS_LOG_REFERENCE: 'AUG_CLAIM_PROCESS_STEP_LOG__PROCESS_LOG_REFERENCE'
  PROCESS_TYPE_CODE: 'AUG_CLAIM_PROCESS_STEP_LOG__PROCESS_TYPE_CODE'
  STEP_ACTOR_USER_REFERENCE: 'AUG_CLAIM_PROCESS_STEP_LOG__STEP_ACTOR_USER_REFERENCE'
  STEP_ACTUAL_START_TIMESTAMP: 'AUG_CLAIM_PROCESS_STEP_LOG__STEP_ACTUAL_START_TIMESTAMP'
  STEP_END_TIMESTAMP: 'AUG_CLAIM_PROCESS_STEP_LOG__STEP_END_TIMESTAMP'
  STEP_START_TIMESTAMP: 'AUG_CLAIM_PROCESS_STEP_LOG__STEP_START_TIMESTAMP'
  STEP_STATUS_CODE: 'AUG_CLAIM_PROCESS_STEP_LOG__STEP_STATUS_CODE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v09_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
