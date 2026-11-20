-- automate_dv.stage() for SAT_ASSESSMENT_HEADER, read off central view stitch_mxm__v01_assessment.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v01_assessment'
hashed_columns:
  ASSESSMENT_HKEY: 'ASSESSMENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ASSESSMENT_CHANNEL'
      - 'ASSESSMENT_STATUS'
      - 'ASSESSMENT_TYPE'
      - 'ASSESSOR_REFERENCE'
      - 'CONDUCTED_DATE'
      - 'COST_OF_ASSESSMENT'
      - 'REQUESTED_DATE'
derived_columns:
  ASSESSMENT_NK: "case when coalesce(ASSESSMENT_HEADER__ASSESSMENT_CHANNEL, ASSESSMENT_HEADER__ASSESSMENT_STATUS, ASSESSMENT_HEADER__ASSESSMENT_TYPE, ASSESSMENT_HEADER__ASSESSOR_REFERENCE, ASSESSMENT_HEADER__CONDUCTED_DATE, ASSESSMENT_HEADER__COST_OF_ASSESSMENT, ASSESSMENT_HEADER__REQUESTED_DATE) is not null then 'HUB_ASSESSMENT|' || ASSESSMENT_BK end"
  ASSESSMENT_CHANNEL: 'ASSESSMENT_HEADER__ASSESSMENT_CHANNEL'
  ASSESSMENT_STATUS: 'ASSESSMENT_HEADER__ASSESSMENT_STATUS'
  ASSESSMENT_TYPE: 'ASSESSMENT_HEADER__ASSESSMENT_TYPE'
  ASSESSOR_REFERENCE: 'ASSESSMENT_HEADER__ASSESSOR_REFERENCE'
  CONDUCTED_DATE: 'ASSESSMENT_HEADER__CONDUCTED_DATE'
  COST_OF_ASSESSMENT: 'ASSESSMENT_HEADER__COST_OF_ASSESSMENT'
  REQUESTED_DATE: 'ASSESSMENT_HEADER__REQUESTED_DATE'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v01_assessment'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
