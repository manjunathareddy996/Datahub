-- automate_dv.stage() for SAT_AUG_COVERAGE_CONDITIONS, read off central view stitch_motor__v04_coverage.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v04_coverage'
hashed_columns:
  COVERAGE_HKEY: 'COVERAGE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'MAXIMUM_VEHICLE_AGE'
derived_columns:
  COVERAGE_NK: "case when AUG_COVERAGE_CONDITIONS__MAXIMUM_VEHICLE_AGE is not null then 'HUB_COVERAGE|' || COVERAGE_BK end"
  MAXIMUM_VEHICLE_AGE: 'AUG_COVERAGE_CONDITIONS__MAXIMUM_VEHICLE_AGE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_motor__v04_coverage'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
