-- automate_dv.stage() for SAT_MOTOR_AUG_COVERAGE_PACKAGE_RATING, read off central view stitch_mxm__v14_risk_object.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v14_risk_object'
hashed_columns:
  COVERAGE_HKEY: 'COVERAGE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ADD_ON_PACKAGE_CODE'
      - 'MAIN_PACKAGE_CODE'
derived_columns:
  COVERAGE_NK: "case when coalesce(AUG_COVERAGE_PACKAGE_RATING__ADD_ON_PACKAGE_CODE, AUG_COVERAGE_PACKAGE_RATING__MAIN_PACKAGE_CODE) is not null then 'HUB_COVERAGE|' || COVERAGE_BK end"
  ADD_ON_PACKAGE_CODE: 'AUG_COVERAGE_PACKAGE_RATING__ADD_ON_PACKAGE_CODE'
  MAIN_PACKAGE_CODE: 'AUG_COVERAGE_PACKAGE_RATING__MAIN_PACKAGE_CODE'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v14_risk_object'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
