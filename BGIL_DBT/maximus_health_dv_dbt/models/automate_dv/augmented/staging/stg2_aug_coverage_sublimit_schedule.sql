-- automate_dv.stage() for SAT_AUG_COVERAGE_SUBLIMIT_SCHEDULE, read off central view stitch_v16_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v16_policy'
hashed_columns:
  COVERAGE_HKEY: 'COVERAGE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'BENEFIT_DAYS_ALLOWED_PER_MONTH'
      - 'BENEFIT_DAY_COUNT'
      - 'BENEFIT_MONTHS_PAYABLE_PER_YEAR'
      - 'ACTIVE_SEQUENCE_NUMBER_CK'
derived_columns:
  COVERAGE_NK: "case when coalesce(AUG_COVERAGE_SUBLIMIT_SCHEDULE__BENEFIT_DAYS_ALLOWED_PER_MONTH, AUG_COVERAGE_SUBLIMIT_SCHEDULE__BENEFIT_DAY_COUNT, AUG_COVERAGE_SUBLIMIT_SCHEDULE__BENEFIT_MONTHS_PAYABLE_PER_YEAR) is not null then 'HUB_COVERAGE|' || COVERAGE_BK end"
  ACTIVE_SEQUENCE_NUMBER_CK: 'AUG_COVERAGE_SUBLIMIT_SCHEDULE__ACTIVE_SEQUENCE_NUMBER_CK'
  BENEFIT_DAYS_ALLOWED_PER_MONTH: 'AUG_COVERAGE_SUBLIMIT_SCHEDULE__BENEFIT_DAYS_ALLOWED_PER_MONTH'
  BENEFIT_DAY_COUNT: 'AUG_COVERAGE_SUBLIMIT_SCHEDULE__BENEFIT_DAY_COUNT'
  BENEFIT_MONTHS_PAYABLE_PER_YEAR: 'AUG_COVERAGE_SUBLIMIT_SCHEDULE__BENEFIT_MONTHS_PAYABLE_PER_YEAR'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v16_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
