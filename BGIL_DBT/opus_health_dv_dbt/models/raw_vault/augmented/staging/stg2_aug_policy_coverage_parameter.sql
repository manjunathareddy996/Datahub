-- automate_dv.stage() for SAT_AUG_POLICY_COVERAGE_PARAMETER, read off central view stitch_v24_policy.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v24_policy'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PARAMETER_DEFINITION_REFERENCE'
      - 'PARAMETER_REFERENCE'
      - 'PARAMETER_VALUE'
      - 'PLAN_REFERENCE'
      - 'SECTION_REFERENCE'
      - 'PARAMETER_REFERENCE_CK'
      - 'PLAN_REFERENCE_CK'
      - 'SECTION_REFERENCE_CK'
      - 'COVERAGE_REFERENCE_CK'
derived_columns:
  POLICY_NK: "case when coalesce(AUG_POLICY_COVERAGE_PARAMETER__PARAMETER_DEFINITION_REFERENCE, AUG_POLICY_COVERAGE_PARAMETER__PARAMETER_REFERENCE, AUG_POLICY_COVERAGE_PARAMETER__PARAMETER_VALUE, AUG_POLICY_COVERAGE_PARAMETER__PLAN_REFERENCE, AUG_POLICY_COVERAGE_PARAMETER__SECTION_REFERENCE) is not null then 'HUB_POLICY|' || POLICY_BK end"
  PARAMETER_REFERENCE_CK: 'AUG_POLICY_COVERAGE_PARAMETER__PARAMETER_REFERENCE_CK'
  PLAN_REFERENCE_CK: 'AUG_POLICY_COVERAGE_PARAMETER__PLAN_REFERENCE_CK'
  SECTION_REFERENCE_CK: 'AUG_POLICY_COVERAGE_PARAMETER__SECTION_REFERENCE_CK'
  COVERAGE_REFERENCE_CK: 'AUG_POLICY_COVERAGE_PARAMETER__COVERAGE_REFERENCE_CK'
  PARAMETER_DEFINITION_REFERENCE: 'AUG_POLICY_COVERAGE_PARAMETER__PARAMETER_DEFINITION_REFERENCE'
  PARAMETER_REFERENCE: 'AUG_POLICY_COVERAGE_PARAMETER__PARAMETER_REFERENCE'
  PARAMETER_VALUE: 'AUG_POLICY_COVERAGE_PARAMETER__PARAMETER_VALUE'
  PLAN_REFERENCE: 'AUG_POLICY_COVERAGE_PARAMETER__PLAN_REFERENCE'
  SECTION_REFERENCE: 'AUG_POLICY_COVERAGE_PARAMETER__SECTION_REFERENCE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v24_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
