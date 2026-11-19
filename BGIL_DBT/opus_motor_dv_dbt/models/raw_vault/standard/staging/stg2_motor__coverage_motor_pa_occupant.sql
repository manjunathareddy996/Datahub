-- automate_dv.stage() for SAT_COVERAGE_MOTOR_PA_OCCUPANT, read off central view stitch_motor__v05_coverage.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v05_coverage'
hashed_columns:
  COVERAGE_HKEY: 'COVERAGE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'NUMBER_OF_PERSONS_COVERED'
      - 'PAID_DRIVER_COUNT'
derived_columns:
  COVERAGE_NK: "case when coalesce(COVERAGE_MOTOR_PA_OCCUPANT__NUMBER_OF_PERSONS_COVERED, COVERAGE_MOTOR_PA_OCCUPANT__PAID_DRIVER_COUNT) is not null then 'HUB_COVERAGE|' || COVERAGE_BK end"
  NUMBER_OF_PERSONS_COVERED: 'COVERAGE_MOTOR_PA_OCCUPANT__NUMBER_OF_PERSONS_COVERED'
  PAID_DRIVER_COUNT: 'COVERAGE_MOTOR_PA_OCCUPANT__PAID_DRIVER_COUNT'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_stitch_motor__v05_coverage'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
