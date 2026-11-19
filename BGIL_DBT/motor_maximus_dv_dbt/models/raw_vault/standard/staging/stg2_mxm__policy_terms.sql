-- automate_dv.stage() for SAT_POLICY_TERMS, read off central view stitch_mxm__v13_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v13_policy'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'FREE_LOOK_PERIOD'
      - 'GEOGRAPHICAL_SCOPE'
derived_columns:
  POLICY_NK: "case when coalesce(POLICY_TERMS__FREE_LOOK_PERIOD, POLICY_TERMS__GEOGRAPHICAL_SCOPE) is not null then 'HUB_POLICY|' || POLICY_BK end"
  FREE_LOOK_PERIOD: 'POLICY_TERMS__FREE_LOOK_PERIOD'
  GEOGRAPHICAL_SCOPE: 'POLICY_TERMS__GEOGRAPHICAL_SCOPE'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v13_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
