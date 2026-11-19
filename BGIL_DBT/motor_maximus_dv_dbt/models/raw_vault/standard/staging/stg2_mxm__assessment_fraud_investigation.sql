-- automate_dv.stage() for SAT_ASSESSMENT_FRAUD_INVESTIGATION, read off central view stitch_mxm__v01_assessment.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v01_assessment'
hashed_columns:
  ASSESSMENT_HKEY: 'ASSESSMENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'FINDINGS_SUMMARY'
derived_columns:
  ASSESSMENT_NK: "case when ASSESSMENT_FRAUD_INVESTIGATION__FINDINGS_SUMMARY is not null then 'HUB_ASSESSMENT|' || ASSESSMENT_BK end"
  FINDINGS_SUMMARY: 'ASSESSMENT_FRAUD_INVESTIGATION__FINDINGS_SUMMARY'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v01_assessment'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
