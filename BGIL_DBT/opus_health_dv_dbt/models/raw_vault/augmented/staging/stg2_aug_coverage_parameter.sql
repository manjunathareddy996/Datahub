-- automate_dv.stage() for SAT_AUG_COVERAGE_PARAMETER, read off central view stitch_v12_coverage.
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
      - 'PARAMETER_REFERENCE'
      - 'PARAMETER_VALUE'
derived_columns:
  COVERAGE_NK: "case when coalesce(AUG_COVERAGE_PARAMETER__PARAMETER_REFERENCE, AUG_COVERAGE_PARAMETER__PARAMETER_VALUE) is not null then 'HUB_COVERAGE|' || COVERAGE_BK end"
  PARAMETER_REFERENCE: 'AUG_COVERAGE_PARAMETER__PARAMETER_REFERENCE'
  PARAMETER_VALUE: 'AUG_COVERAGE_PARAMETER__PARAMETER_VALUE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v12_coverage'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
