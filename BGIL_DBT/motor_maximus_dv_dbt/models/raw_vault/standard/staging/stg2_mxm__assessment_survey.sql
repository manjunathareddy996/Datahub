-- automate_dv.stage() for SAT_ASSESSMENT_SURVEY, read off central view stitch_mxm__v01_assessment.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v01_assessment'
hashed_columns:
  ASSESSMENT_HKEY: 'ASSESSMENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'FINAL_SURVEY_INDICATOR'
      - 'FINAL_VISIT_DATE'
      - 'NUMBER_OF_VISITS'
      - 'SPOT_SURVEY_INDICATOR'
      - 'SURVEY_ALLOCATION_DATE'
      - 'SURVEY_TYPE'
      - 'WORK_APPROVAL_DATE'
derived_columns:
  ASSESSMENT_NK: "case when coalesce(ASSESSMENT_SURVEY__FINAL_SURVEY_INDICATOR, ASSESSMENT_SURVEY__FINAL_VISIT_DATE, ASSESSMENT_SURVEY__NUMBER_OF_VISITS, ASSESSMENT_SURVEY__SPOT_SURVEY_INDICATOR, ASSESSMENT_SURVEY__SURVEY_ALLOCATION_DATE, ASSESSMENT_SURVEY__SURVEY_TYPE, ASSESSMENT_SURVEY__WORK_APPROVAL_DATE) is not null then 'HUB_ASSESSMENT|' || ASSESSMENT_BK end"
  FINAL_SURVEY_INDICATOR: 'ASSESSMENT_SURVEY__FINAL_SURVEY_INDICATOR'
  FINAL_VISIT_DATE: 'ASSESSMENT_SURVEY__FINAL_VISIT_DATE'
  NUMBER_OF_VISITS: 'ASSESSMENT_SURVEY__NUMBER_OF_VISITS'
  SPOT_SURVEY_INDICATOR: 'ASSESSMENT_SURVEY__SPOT_SURVEY_INDICATOR'
  SURVEY_ALLOCATION_DATE: 'ASSESSMENT_SURVEY__SURVEY_ALLOCATION_DATE'
  SURVEY_TYPE: 'ASSESSMENT_SURVEY__SURVEY_TYPE'
  WORK_APPROVAL_DATE: 'ASSESSMENT_SURVEY__WORK_APPROVAL_DATE'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v01_assessment'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
