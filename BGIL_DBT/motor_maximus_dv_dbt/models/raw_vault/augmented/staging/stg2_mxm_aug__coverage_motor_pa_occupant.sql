-- automate_dv.stage() for SAT_MOTOR_AUG_COVERAGE_MOTOR_PA_OCCUPANT, read off central view stitch_mxm__v14_risk_object.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v14_risk_object'
hashed_columns:
  COVERAGE_HKEY: 'COVERAGE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'OCCUPANT_PERSON_DETAIL_TEXT'
derived_columns:
  COVERAGE_NK: "case when AUG_COVERAGE_MOTOR_PA_OCCUPANT__OCCUPANT_PERSON_DETAIL_TEXT is not null then 'HUB_COVERAGE|' || COVERAGE_BK end"
  OCCUPANT_PERSON_DETAIL_TEXT: 'AUG_COVERAGE_MOTOR_PA_OCCUPANT__OCCUPANT_PERSON_DETAIL_TEXT'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v14_risk_object'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
