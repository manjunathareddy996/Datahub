-- automate_dv.stage() for SAT_MOTOR_AUG_COVERAGE_CONDITIONS, read off central view stitch_mxm__v01_assessment.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v01_assessment'
hashed_columns:
  COVERAGE_HKEY: 'COVERAGE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CONDITIONAL_SECTION_REFERENCE'
      - 'GEOGRAPHICAL_EXTENSION_CODE'
      - 'MAXIMUM_AGE_ELIGIBLE'
      - 'NIL_DEPRECIATION_APPLICABLE_FOR_ORGANISATION_INDICATOR'
derived_columns:
  COVERAGE_NK: "case when coalesce(AUG_COVERAGE_CONDITIONS__CONDITIONAL_SECTION_REFERENCE, AUG_COVERAGE_CONDITIONS__GEOGRAPHICAL_EXTENSION_CODE, AUG_COVERAGE_CONDITIONS__MAXIMUM_AGE_ELIGIBLE, AUG_COVERAGE_CONDITIONS__NIL_DEPRECIATION_APPLICABLE_FOR_ORGANISATION_INDICATOR) is not null then 'HUB_COVERAGE|' || COVERAGE_BK end"
  CONDITIONAL_SECTION_REFERENCE: 'AUG_COVERAGE_CONDITIONS__CONDITIONAL_SECTION_REFERENCE'
  GEOGRAPHICAL_EXTENSION_CODE: 'AUG_COVERAGE_CONDITIONS__GEOGRAPHICAL_EXTENSION_CODE'
  MAXIMUM_AGE_ELIGIBLE: 'AUG_COVERAGE_CONDITIONS__MAXIMUM_AGE_ELIGIBLE'
  NIL_DEPRECIATION_APPLICABLE_FOR_ORGANISATION_INDICATOR: 'AUG_COVERAGE_CONDITIONS__NIL_DEPRECIATION_APPLICABLE_FOR_ORGANISATION_INDICATOR'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v01_assessment'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
