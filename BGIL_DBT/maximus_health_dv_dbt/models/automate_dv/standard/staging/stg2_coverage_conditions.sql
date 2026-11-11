-- automate_dv.stage() for SAT_COVERAGE_CONDITIONS, read off central view stitch_v06_coverage.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v06_coverage'
hashed_columns:
  COVERAGE_HKEY: 'COVERAGE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'WAITING_PERIOD_CONDITION'
derived_columns:
  COVERAGE_NK: "case when COVERAGE_CONDITIONS__WAITING_PERIOD_CONDITION is not null then 'HUB_COVERAGE|' || COVERAGE_BK end"
  WAITING_PERIOD_CONDITION: 'COVERAGE_CONDITIONS__WAITING_PERIOD_CONDITION'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v06_coverage'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
