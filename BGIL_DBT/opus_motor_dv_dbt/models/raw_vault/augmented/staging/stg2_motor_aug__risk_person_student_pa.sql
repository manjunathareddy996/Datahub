-- automate_dv.stage() for SAT_MOTOR_AUG_RISK_PERSON_STUDENT_PA, read off central view stitch_motor__v11_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v11_party'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'FAMILY_PHYSICIAN_CONTACT_NUMBER'
      - 'FAMILY_PHYSICIAN_NAME'
      - 'STUDENT_REMARKS'
derived_columns:
  RISK_OBJECT_NK: "case when coalesce(AUG_RISK_PERSON_STUDENT_PA__FAMILY_PHYSICIAN_CONTACT_NUMBER, AUG_RISK_PERSON_STUDENT_PA__FAMILY_PHYSICIAN_NAME, AUG_RISK_PERSON_STUDENT_PA__STUDENT_REMARKS) is not null then 'HUB_RISK_OBJECT|' || RISK_OBJECT_BK end"
  FAMILY_PHYSICIAN_CONTACT_NUMBER: 'AUG_RISK_PERSON_STUDENT_PA__FAMILY_PHYSICIAN_CONTACT_NUMBER'
  FAMILY_PHYSICIAN_NAME: 'AUG_RISK_PERSON_STUDENT_PA__FAMILY_PHYSICIAN_NAME'
  STUDENT_REMARKS: 'AUG_RISK_PERSON_STUDENT_PA__STUDENT_REMARKS'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_MOTOR_V11_PARTY'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
