-- automate_dv.stage() for SAT_MOTOR_AUG_COVERAGE_MOTOR_LAID_UP, read off central view stitch_motor__v05_coverage.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v05_coverage'
hashed_columns:
  COVERAGE_HKEY: 'COVERAGE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'LAID_UP_END_DATE'
      - 'LAID_UP_START_DATE'
      - 'LAID_UP_SUB_TYPE'
      - 'LAID_UP_TYPE'
derived_columns:
  COVERAGE_NK: "case when coalesce(AUG_COVERAGE_MOTOR_LAID_UP__LAID_UP_END_DATE, AUG_COVERAGE_MOTOR_LAID_UP__LAID_UP_START_DATE, AUG_COVERAGE_MOTOR_LAID_UP__LAID_UP_SUB_TYPE, AUG_COVERAGE_MOTOR_LAID_UP__LAID_UP_TYPE) is not null then 'HUB_COVERAGE|' || COVERAGE_BK end"
  LAID_UP_END_DATE: 'AUG_COVERAGE_MOTOR_LAID_UP__LAID_UP_END_DATE'
  LAID_UP_START_DATE: 'AUG_COVERAGE_MOTOR_LAID_UP__LAID_UP_START_DATE'
  LAID_UP_SUB_TYPE: 'AUG_COVERAGE_MOTOR_LAID_UP__LAID_UP_SUB_TYPE'
  LAID_UP_TYPE: 'AUG_COVERAGE_MOTOR_LAID_UP__LAID_UP_TYPE'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_stitch_motor__v05_coverage'
  SOURCE_SYSTEM: '!OPUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
