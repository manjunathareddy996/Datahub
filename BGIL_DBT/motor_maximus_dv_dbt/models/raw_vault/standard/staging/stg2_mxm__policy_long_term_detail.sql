-- automate_dv.stage() for SAT_POLICY_LONG_TERM_DETAIL, read off central view stitch_mxm__v14_risk_object.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v14_risk_object'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'POLICY_DURATION_YEARS'
derived_columns:
  POLICY_NK: "case when POLICY_LONG_TERM_DETAIL__POLICY_DURATION_YEARS is not null then 'HUB_POLICY|' || POLICY_BK end"
  POLICY_DURATION_YEARS: 'POLICY_LONG_TERM_DETAIL__POLICY_DURATION_YEARS'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v14_risk_object'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
