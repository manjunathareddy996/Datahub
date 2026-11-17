-- automate_dv.stage() for SAT_AUG_CLAIM_SLA_TRACKING, read off central view stitch_motor__v01_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v01_claim'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'FOLLOW_UP_REQUIRED_INDICATOR'
      - 'PROCESSING_DELAY_REASON'
      - 'REQUIREMENT_FULFILLED_DATE'
      - 'REQUIREMENT_FULFILLED_INDICATOR'
      - 'WORKFLOW_ACTION'
derived_columns:
  CLAIM_NK: "case when coalesce(AUG_CLAIM_SLA_TRACKING__FOLLOW_UP_REQUIRED_INDICATOR, AUG_CLAIM_SLA_TRACKING__PROCESSING_DELAY_REASON, AUG_CLAIM_SLA_TRACKING__REQUIREMENT_FULFILLED_DATE, AUG_CLAIM_SLA_TRACKING__REQUIREMENT_FULFILLED_INDICATOR, AUG_CLAIM_SLA_TRACKING__WORKFLOW_ACTION) is not null then 'HUB_CLAIM|' || CLAIM_BK end"
  FOLLOW_UP_REQUIRED_INDICATOR: 'AUG_CLAIM_SLA_TRACKING__FOLLOW_UP_REQUIRED_INDICATOR'
  PROCESSING_DELAY_REASON: 'AUG_CLAIM_SLA_TRACKING__PROCESSING_DELAY_REASON'
  REQUIREMENT_FULFILLED_DATE: 'AUG_CLAIM_SLA_TRACKING__REQUIREMENT_FULFILLED_DATE'
  REQUIREMENT_FULFILLED_INDICATOR: 'AUG_CLAIM_SLA_TRACKING__REQUIREMENT_FULFILLED_INDICATOR'
  WORKFLOW_ACTION: 'AUG_CLAIM_SLA_TRACKING__WORKFLOW_ACTION'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_motor__v01_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
