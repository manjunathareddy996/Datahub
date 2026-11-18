-- automate_dv.stage() for SAT_AUG_POLICY_BONUS_TRACKING, read off central view stitch_motor__v14_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v14_policy'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PREVIOUS_BONUS_DECLARATION_SOURCE'
      - 'PREVIOUS_POLICY_CLAIM_COUNT'
derived_columns:
  POLICY_NK: "case when coalesce(AUG_POLICY_BONUS_TRACKING__PREVIOUS_BONUS_DECLARATION_SOURCE, AUG_POLICY_BONUS_TRACKING__PREVIOUS_POLICY_CLAIM_COUNT) is not null then 'HUB_POLICY|' || POLICY_BK end"
  PREVIOUS_BONUS_DECLARATION_SOURCE: 'AUG_POLICY_BONUS_TRACKING__PREVIOUS_BONUS_DECLARATION_SOURCE'
  PREVIOUS_POLICY_CLAIM_COUNT: 'AUG_POLICY_BONUS_TRACKING__PREVIOUS_POLICY_CLAIM_COUNT'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!stitch_motor__v14_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
