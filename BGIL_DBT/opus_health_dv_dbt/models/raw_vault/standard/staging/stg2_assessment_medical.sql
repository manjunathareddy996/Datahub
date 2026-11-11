-- automate_dv.stage() for SAT_ASSESSMENT_MEDICAL, read off central view stitch_v03_assessment.
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
      - 'MEDICAL_MANAGEMENT_DATE'
      - 'MEDICAL_MANAGEMENT_TYPE'
      - 'MEDICAL_TEST_TYPE'
derived_columns:
  ASSESSMENT_NK: "case when coalesce(ASSESSMENT_MEDICAL__MEDICAL_MANAGEMENT_DATE, ASSESSMENT_MEDICAL__MEDICAL_MANAGEMENT_TYPE, ASSESSMENT_MEDICAL__MEDICAL_TEST_TYPE) is not null then 'HUB_ASSESSMENT|' || ASSESSMENT_BK end"
  MEDICAL_MANAGEMENT_DATE: 'ASSESSMENT_MEDICAL__MEDICAL_MANAGEMENT_DATE'
  MEDICAL_MANAGEMENT_TYPE: 'ASSESSMENT_MEDICAL__MEDICAL_MANAGEMENT_TYPE'
  MEDICAL_TEST_TYPE: 'ASSESSMENT_MEDICAL__MEDICAL_TEST_TYPE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v03_assessment'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
