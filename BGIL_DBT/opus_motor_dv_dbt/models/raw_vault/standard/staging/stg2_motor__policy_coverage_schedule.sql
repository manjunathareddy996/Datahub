-- automate_dv.stage() for SAT_POLICY_COVERAGE_SCHEDULE, read off central view stitch_motor__v05_coverage.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v05_coverage'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'COVERAGE_OPTED_INDICATOR'
      - 'COVERAGE_SEQUENCE'
      - 'PREMIUM_FOR_COVERAGE'
      - 'SUM_INSURED'
      - 'COVERAGE_REFERENCE_CK'
      - 'COVERAGE_SEQUENCE_CK'
derived_columns:
  POLICY_NK: "case when coalesce(POLICY_COVERAGE_SCHEDULE__COVERAGE_OPTED_INDICATOR, POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE, POLICY_COVERAGE_SCHEDULE__PREMIUM_FOR_COVERAGE, POLICY_COVERAGE_SCHEDULE__SUM_INSURED) is not null then 'HUB_POLICY|' || POLICY_BK end"
  COVERAGE_REFERENCE_CK: 'POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK'
  COVERAGE_SEQUENCE_CK: 'POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK'
  COVERAGE_OPTED_INDICATOR: 'POLICY_COVERAGE_SCHEDULE__COVERAGE_OPTED_INDICATOR'
  COVERAGE_SEQUENCE: 'POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE'
  PREMIUM_FOR_COVERAGE: 'POLICY_COVERAGE_SCHEDULE__PREMIUM_FOR_COVERAGE'
  SUM_INSURED: 'POLICY_COVERAGE_SCHEDULE__SUM_INSURED'
  LOAD_DATETIME: 'POLICY_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!stitch_motor__v05_coverage'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
