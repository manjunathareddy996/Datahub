-- automate_dv.stage() for SAT_ASSESSMENT_HEADER, read off central view stitch_v02_assessment.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v02_assessment'
hashed_columns:
  ASSESSMENT_HKEY: 'ASSESSMENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ASSESSMENT_REFERENCE_NUMBER'
      - 'ASSESSMENT_STATUS'
      - 'ASSESSMENT_TYPE'
      - 'ASSESSOR_REFERENCE'
      - 'COMPLETED_DATE'
      - 'CONDUCTED_DATE'
      - 'COST_OF_ASSESSMENT'
      - 'OUTCOME_SUMMARY'
      - 'PRIORITY'
      - 'SCHEDULED_DATE'
derived_columns:
  ASSESSMENT_NK: "case when coalesce(ASSESSMENT_HEADER__ASSESSMENT_REFERENCE_NUMBER, ASSESSMENT_HEADER__ASSESSMENT_STATUS, ASSESSMENT_HEADER__ASSESSMENT_TYPE, ASSESSMENT_HEADER__ASSESSOR_REFERENCE, ASSESSMENT_HEADER__COMPLETED_DATE, ASSESSMENT_HEADER__CONDUCTED_DATE, ASSESSMENT_HEADER__COST_OF_ASSESSMENT, ASSESSMENT_HEADER__OUTCOME_SUMMARY, ASSESSMENT_HEADER__PRIORITY, ASSESSMENT_HEADER__SCHEDULED_DATE) is not null then 'HUB_ASSESSMENT|' || ASSESSMENT_BK end"
  ASSESSMENT_REFERENCE_NUMBER: 'ASSESSMENT_HEADER__ASSESSMENT_REFERENCE_NUMBER'
  ASSESSMENT_STATUS: 'ASSESSMENT_HEADER__ASSESSMENT_STATUS'
  ASSESSMENT_TYPE: 'ASSESSMENT_HEADER__ASSESSMENT_TYPE'
  ASSESSOR_REFERENCE: 'ASSESSMENT_HEADER__ASSESSOR_REFERENCE'
  COMPLETED_DATE: 'ASSESSMENT_HEADER__COMPLETED_DATE'
  CONDUCTED_DATE: 'ASSESSMENT_HEADER__CONDUCTED_DATE'
  COST_OF_ASSESSMENT: 'ASSESSMENT_HEADER__COST_OF_ASSESSMENT'
  OUTCOME_SUMMARY: 'ASSESSMENT_HEADER__OUTCOME_SUMMARY'
  PRIORITY: 'ASSESSMENT_HEADER__PRIORITY'
  SCHEDULED_DATE: 'ASSESSMENT_HEADER__SCHEDULED_DATE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v02_assessment'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
