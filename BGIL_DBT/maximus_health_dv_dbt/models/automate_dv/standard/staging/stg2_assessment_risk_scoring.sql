-- automate_dv.stage() for SAT_ASSESSMENT_RISK_SCORING, read off central view stitch_v16_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v16_policy'
hashed_columns:
  ASSESSMENT_HKEY: 'ASSESSMENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'SCORE_BAND'
      - 'SCORE_VALUE'
derived_columns:
  ASSESSMENT_NK: "case when coalesce(ASSESSMENT_RISK_SCORING__SCORE_BAND, ASSESSMENT_RISK_SCORING__SCORE_VALUE) is not null then 'HUB_ASSESSMENT|' || ASSESSMENT_BK end"
  SCORE_BAND: 'ASSESSMENT_RISK_SCORING__SCORE_BAND'
  SCORE_VALUE: 'ASSESSMENT_RISK_SCORING__SCORE_VALUE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v16_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
