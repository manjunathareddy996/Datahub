-- automate_dv.stage() for SAT_MOTOR_AUG_POLICY_COVERAGE_SCHEDULE, read off central view stitch_motor__v05_coverage.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v05_coverage'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'COVERAGE_RATE'
      - 'SOURCE_LINE_REFERENCE'
      - 'COVERAGE_REFERENCE_CK'
      - 'COVERAGE_SEQUENCE_CK'
derived_columns:
  POLICY_NK: "case when coalesce(AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_RATE, AUG_POLICY_COVERAGE_SCHEDULE__SOURCE_LINE_REFERENCE) is not null then 'HUB_POLICY|' || POLICY_BK end"
  COVERAGE_REFERENCE_CK: 'AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK'
  COVERAGE_SEQUENCE_CK: 'AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK'
  COVERAGE_RATE: 'AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_RATE'
  SOURCE_LINE_REFERENCE: 'AUG_POLICY_COVERAGE_SCHEDULE__SOURCE_LINE_REFERENCE'
  LOAD_DATETIME: 'POLICY_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!OPUS_stitch_motor__v05_coverage'
  SOURCE_SYSTEM: '!OPUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
