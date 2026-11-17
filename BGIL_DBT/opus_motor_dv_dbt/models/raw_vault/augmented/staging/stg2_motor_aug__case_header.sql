-- automate_dv.stage() for SAT_AUG_CASE_HEADER, read off central view stitch_motor__v13_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v13_policy'
hashed_columns:
  CASE_HKEY: 'CASE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CASE_WORKFLOW_STAGE'
      - 'INTERACTION_SCRIPT_CODE'
      - 'OWNING_STATE_NAME'
derived_columns:
  CASE_NK: "case when coalesce(AUG_CASE_HEADER__CASE_WORKFLOW_STAGE, AUG_CASE_HEADER__INTERACTION_SCRIPT_CODE, AUG_CASE_HEADER__OWNING_STATE_NAME) is not null then 'HUB_CASE|' || CASE_BK end"
  CASE_WORKFLOW_STAGE: 'AUG_CASE_HEADER__CASE_WORKFLOW_STAGE'
  INTERACTION_SCRIPT_CODE: 'AUG_CASE_HEADER__INTERACTION_SCRIPT_CODE'
  OWNING_STATE_NAME: 'AUG_CASE_HEADER__OWNING_STATE_NAME'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_motor__v13_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
