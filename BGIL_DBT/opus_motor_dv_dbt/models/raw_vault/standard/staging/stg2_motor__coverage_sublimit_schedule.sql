-- automate_dv.stage() for SAT_COVERAGE_SUBLIMIT_SCHEDULE, read off central view stitch_motor__v04_coverage.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v04_coverage'
hashed_columns:
  COVERAGE_HKEY: 'COVERAGE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PER_DAY_LIMIT'
      - 'ACTIVE_SEQUENCE_NUMBER_CK'
derived_columns:
  COVERAGE_NK: "case when COVERAGE_SUBLIMIT_SCHEDULE__PER_DAY_LIMIT is not null then 'HUB_COVERAGE|' || COVERAGE_BK end"
  ACTIVE_SEQUENCE_NUMBER_CK: 'COVERAGE_SUBLIMIT_SCHEDULE__ACTIVE_SEQUENCE_NUMBER_CK'
  PER_DAY_LIMIT: 'COVERAGE_SUBLIMIT_SCHEDULE__PER_DAY_LIMIT'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_motor__v04_coverage'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
