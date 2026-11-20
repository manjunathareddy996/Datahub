-- automate_dv.stage() for SAT_MOTOR_AUG_COVERAGE_MOTOR_ADDON_PARAMS, read off central view stitch_motor__v05_coverage.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v05_coverage'
hashed_columns:
  COVERAGE_HKEY: 'COVERAGE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'TYRE_DESCRIPTION'
      - 'TYRE_DETAIL'
      - 'ADD_ON_COVERAGE_CODE_CK'
      - 'TYRE_POSITION_CK'
derived_columns:
  COVERAGE_NK: "case when coalesce(AUG_COVERAGE_MOTOR_ADDON_PARAMS__TYRE_DESCRIPTION, AUG_COVERAGE_MOTOR_ADDON_PARAMS__TYRE_DETAIL) is not null then 'HUB_COVERAGE|' || COVERAGE_BK end"
  ADD_ON_COVERAGE_CODE_CK: 'AUG_COVERAGE_MOTOR_ADDON_PARAMS__ADD_ON_COVERAGE_CODE_CK'
  TYRE_POSITION_CK: 'AUG_COVERAGE_MOTOR_ADDON_PARAMS__TYRE_POSITION_CK'
  TYRE_DESCRIPTION: 'AUG_COVERAGE_MOTOR_ADDON_PARAMS__TYRE_DESCRIPTION'
  TYRE_DETAIL: 'AUG_COVERAGE_MOTOR_ADDON_PARAMS__TYRE_DETAIL'
  LOAD_DATETIME: 'COVERAGE_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!OPUS_stitch_motor__v05_coverage'
  SOURCE_SYSTEM: '!OPUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
