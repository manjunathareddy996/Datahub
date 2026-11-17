-- automate_dv.stage() for SAT_RISK_PERSON_STUDENT_PA, read off central view stitch_motor__v11_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v11_party'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'COURSE_DURATION_MONTHS'
      - 'COURSE_NAME'
      - 'INSTITUTION_ADDRESS'
      - 'INSTITUTION_NAME'
      - 'SEMESTER_NUMBER'
      - 'STUDENT_FITNESS_STATUS'
      - 'TUITION_FEE_AMOUNT'
      - 'TUITION_FEE_PAYER'
derived_columns:
  RISK_OBJECT_NK: "case when coalesce(RISK_PERSON_STUDENT_PA__COURSE_DURATION_MONTHS, RISK_PERSON_STUDENT_PA__COURSE_NAME, RISK_PERSON_STUDENT_PA__INSTITUTION_ADDRESS, RISK_PERSON_STUDENT_PA__INSTITUTION_NAME, RISK_PERSON_STUDENT_PA__SEMESTER_NUMBER, RISK_PERSON_STUDENT_PA__STUDENT_FITNESS_STATUS, RISK_PERSON_STUDENT_PA__TUITION_FEE_AMOUNT, RISK_PERSON_STUDENT_PA__TUITION_FEE_PAYER) is not null then 'HUB_RISK_OBJECT|' || RISK_OBJECT_BK end"
  COURSE_DURATION_MONTHS: 'RISK_PERSON_STUDENT_PA__COURSE_DURATION_MONTHS'
  COURSE_NAME: 'RISK_PERSON_STUDENT_PA__COURSE_NAME'
  INSTITUTION_ADDRESS: 'RISK_PERSON_STUDENT_PA__INSTITUTION_ADDRESS'
  INSTITUTION_NAME: 'RISK_PERSON_STUDENT_PA__INSTITUTION_NAME'
  SEMESTER_NUMBER: 'RISK_PERSON_STUDENT_PA__SEMESTER_NUMBER'
  STUDENT_FITNESS_STATUS: 'RISK_PERSON_STUDENT_PA__STUDENT_FITNESS_STATUS'
  TUITION_FEE_AMOUNT: 'RISK_PERSON_STUDENT_PA__TUITION_FEE_AMOUNT'
  TUITION_FEE_PAYER: 'RISK_PERSON_STUDENT_PA__TUITION_FEE_PAYER'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_motor__v11_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
