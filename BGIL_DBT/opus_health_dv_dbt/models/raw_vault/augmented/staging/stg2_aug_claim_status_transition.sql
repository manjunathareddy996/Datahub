-- automate_dv.stage() for SAT_AUG_CLAIM_STATUS_TRANSITION, read off central view stitch_v34_risk_object.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v34_risk_object'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CLAIM_RECORD_VERSION_NUMBER'
      - 'PREVIOUS_CLAIM_STATUS_CODE'
      - 'TRANSITION_ACTOR_USER_REFERENCE'
      - 'WORKFLOW_PROCESS_NAME'
derived_columns:
  CLAIM_NK: "case when coalesce(AUG_CLAIM_STATUS_TRANSITION__CLAIM_RECORD_VERSION_NUMBER, AUG_CLAIM_STATUS_TRANSITION__PREVIOUS_CLAIM_STATUS_CODE, AUG_CLAIM_STATUS_TRANSITION__TRANSITION_ACTOR_USER_REFERENCE, AUG_CLAIM_STATUS_TRANSITION__WORKFLOW_PROCESS_NAME) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  CLAIM_RECORD_VERSION_NUMBER: 'AUG_CLAIM_STATUS_TRANSITION__CLAIM_RECORD_VERSION_NUMBER'
  PREVIOUS_CLAIM_STATUS_CODE: 'AUG_CLAIM_STATUS_TRANSITION__PREVIOUS_CLAIM_STATUS_CODE'
  TRANSITION_ACTOR_USER_REFERENCE: 'AUG_CLAIM_STATUS_TRANSITION__TRANSITION_ACTOR_USER_REFERENCE'
  WORKFLOW_PROCESS_NAME: 'AUG_CLAIM_STATUS_TRANSITION__WORKFLOW_PROCESS_NAME'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v34_risk_object'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
