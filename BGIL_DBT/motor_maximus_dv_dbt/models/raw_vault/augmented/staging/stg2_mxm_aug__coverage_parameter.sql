-- automate_dv.stage() for SAT_MOTOR_AUG_COVERAGE_PARAMETER, read off central view stitch_mxm__v05_coverage.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v05_coverage'
hashed_columns:
  COVERAGE_HKEY: 'COVERAGE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'BUSINESS_EVENT_CODE'
      - 'PARAMETER_REFERENCE_CK'
derived_columns:
  COVERAGE_NK: "case when AUG_COVERAGE_PARAMETER__BUSINESS_EVENT_CODE is not null then 'HUB_COVERAGE|' || COVERAGE_BK end"
  PARAMETER_REFERENCE_CK: 'AUG_COVERAGE_PARAMETER__PARAMETER_REFERENCE_CK'
  BUSINESS_EVENT_CODE: 'AUG_COVERAGE_PARAMETER__BUSINESS_EVENT_CODE'
  LOAD_DATETIME: 'COVERAGE_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!stitch_mxm__v05_coverage'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
