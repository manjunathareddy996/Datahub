-- automate_dv.stage() for SAT_AUG_COVERAGE_DEFINITION, read off central view stitch_v06_coverage.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v06_coverage'
hashed_columns:
  COVERAGE_HKEY: 'COVERAGE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'COMBINED_CRITICAL_ILLNESS_AND_ACCIDENT_MULTIPLIER_APPLICABLE_INDICATOR'
      - 'DOUBLE_SUM_INSURED_BENEFIT_APPLICABLE_INDICATOR'
      - 'MUTUALLY_EXCLUSIVE_COVERS'
      - 'MUTUALLY_INCLUSIVE_COVERS'
derived_columns:
  COVERAGE_NK: "case when coalesce(AUG_COVERAGE_DEFINITION__COMBINED_CRITICAL_ILLNESS_AND_ACCIDENT_MULTIPLIER_APPLICABLE_INDICATOR, AUG_COVERAGE_DEFINITION__DOUBLE_SUM_INSURED_BENEFIT_APPLICABLE_INDICATOR, AUG_COVERAGE_DEFINITION__MUTUALLY_EXCLUSIVE_COVERS, AUG_COVERAGE_DEFINITION__MUTUALLY_INCLUSIVE_COVERS) is not null then 'HUB_COVERAGE|' || COVERAGE_BK end"
  COMBINED_CRITICAL_ILLNESS_AND_ACCIDENT_MULTIPLIER_APPLICABLE_INDICATOR: 'AUG_COVERAGE_DEFINITION__COMBINED_CRITICAL_ILLNESS_AND_ACCIDENT_MULTIPLIER_APPLICABLE_INDICATOR'
  DOUBLE_SUM_INSURED_BENEFIT_APPLICABLE_INDICATOR: 'AUG_COVERAGE_DEFINITION__DOUBLE_SUM_INSURED_BENEFIT_APPLICABLE_INDICATOR'
  MUTUALLY_EXCLUSIVE_COVERS: 'AUG_COVERAGE_DEFINITION__MUTUALLY_EXCLUSIVE_COVERS'
  MUTUALLY_INCLUSIVE_COVERS: 'AUG_COVERAGE_DEFINITION__MUTUALLY_INCLUSIVE_COVERS'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v06_coverage'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
