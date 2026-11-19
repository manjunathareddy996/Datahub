-- automate_dv.stage() for SAT_MOTOR_AUG_PROPOSAL_HEADER, read off central view stitch_mxm__v12_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v12_policy'
hashed_columns:
  PROPOSAL_HKEY: 'PROPOSAL_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'QUESTION_SET_REFERENCE'
derived_columns:
  PROPOSAL_NK: "case when AUG_PROPOSAL_HEADER__QUESTION_SET_REFERENCE is not null then 'HUB_PROPOSAL|' || PROPOSAL_BK end"
  QUESTION_SET_REFERENCE: 'AUG_PROPOSAL_HEADER__QUESTION_SET_REFERENCE'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v12_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
