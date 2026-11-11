-- automate_dv.stage() for SAT_COVERAGE_DEFINITION, read off central view stitch_v12_coverage.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v12_coverage'
hashed_columns:
  COVERAGE_HKEY: 'COVERAGE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'COVERAGE_DESCRIPTION'
derived_columns:
  COVERAGE_NK: "case when COVERAGE_DEFINITION__COVERAGE_DESCRIPTION is not null then 'HUB_COVERAGE|' || COVERAGE_BK end"
  COVERAGE_DESCRIPTION: 'COVERAGE_DEFINITION__COVERAGE_DESCRIPTION'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v12_coverage'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
