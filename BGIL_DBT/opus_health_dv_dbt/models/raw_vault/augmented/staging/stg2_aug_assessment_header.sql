-- automate_dv.stage() for SAT_AUG_ASSESSMENT_HEADER, read off central view stitch_v03_assessment.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v03_assessment'
hashed_columns:
  ASSESSMENT_HKEY: 'ASSESSMENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ASSESSMENT_SUB_STATUS_CODE'
      - 'ASSESSMENT_SUB_STATUS_DESCRIPTION'
      - 'RESCHEDULED_DATE'
      - 'RESCHEDULED_TIME'
      - 'SCHEDULED_TIME'
derived_columns:
  ASSESSMENT_NK: "case when coalesce(AUG_ASSESSMENT_HEADER__ASSESSMENT_SUB_STATUS_CODE, AUG_ASSESSMENT_HEADER__ASSESSMENT_SUB_STATUS_DESCRIPTION, AUG_ASSESSMENT_HEADER__RESCHEDULED_DATE, AUG_ASSESSMENT_HEADER__RESCHEDULED_TIME, AUG_ASSESSMENT_HEADER__SCHEDULED_TIME) is not null then 'HUB_ASSESSMENT|' || ASSESSMENT_BK end"
  ASSESSMENT_SUB_STATUS_CODE: 'AUG_ASSESSMENT_HEADER__ASSESSMENT_SUB_STATUS_CODE'
  ASSESSMENT_SUB_STATUS_DESCRIPTION: 'AUG_ASSESSMENT_HEADER__ASSESSMENT_SUB_STATUS_DESCRIPTION'
  RESCHEDULED_DATE: 'AUG_ASSESSMENT_HEADER__RESCHEDULED_DATE'
  RESCHEDULED_TIME: 'AUG_ASSESSMENT_HEADER__RESCHEDULED_TIME'
  SCHEDULED_TIME: 'AUG_ASSESSMENT_HEADER__SCHEDULED_TIME'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v03_assessment'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
