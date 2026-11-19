-- automate_dv.stage() for SAT_COVERAGE_DEFINITION, read off central view stitch_motor__v04_coverage.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v04_coverage'
hashed_columns:
  COVERAGE_HKEY: 'COVERAGE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'COVERAGE_DESCRIPTION'
      - 'COVERAGE_STATUS'
derived_columns:
  COVERAGE_NK: "case when coalesce(COVERAGE_DEFINITION__COVERAGE_DESCRIPTION, COVERAGE_DEFINITION__COVERAGE_STATUS) is not null then 'HUB_COVERAGE|' || COVERAGE_BK end"
  COVERAGE_DESCRIPTION: 'COVERAGE_DEFINITION__COVERAGE_DESCRIPTION'
  COVERAGE_STATUS: 'COVERAGE_DEFINITION__COVERAGE_STATUS'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_MOTOR_V04_COVERAGE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
