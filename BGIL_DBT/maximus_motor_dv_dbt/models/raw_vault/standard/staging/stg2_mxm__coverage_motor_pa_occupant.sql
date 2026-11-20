-- automate_dv.stage() for SAT_COVERAGE_MOTOR_PA_OCCUPANT, read off central view stitch_mxm__v14_risk_object.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v14_risk_object'
hashed_columns:
  COVERAGE_HKEY: 'COVERAGE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'NUMBER_OF_PERSONS_COVERED'
derived_columns:
  COVERAGE_NK: "case when COVERAGE_MOTOR_PA_OCCUPANT__NUMBER_OF_PERSONS_COVERED is not null then 'HUB_COVERAGE|' || COVERAGE_BK end"
  NUMBER_OF_PERSONS_COVERED: 'COVERAGE_MOTOR_PA_OCCUPANT__NUMBER_OF_PERSONS_COVERED'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v14_risk_object'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
