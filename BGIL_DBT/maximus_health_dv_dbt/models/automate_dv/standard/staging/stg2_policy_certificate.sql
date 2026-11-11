-- automate_dv.stage() for SAT_POLICY_CERTIFICATE, read off central view stitch_v06_coverage.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v06_coverage'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'COVERAGE_END_DATE'
      - 'COVERAGE_START_DATE'
      - 'MEMBER_CATEGORY'
      - 'MEMBER_PREMIUM'
      - 'MEMBER_STATUS'
      - 'TERMINATION_DATE'
      - 'CERTIFICATE_NUMBER_CK'
derived_columns:
  POLICY_NK: "case when coalesce(POLICY_CERTIFICATE__COVERAGE_END_DATE, POLICY_CERTIFICATE__COVERAGE_START_DATE, POLICY_CERTIFICATE__MEMBER_CATEGORY, POLICY_CERTIFICATE__MEMBER_PREMIUM, POLICY_CERTIFICATE__MEMBER_STATUS, POLICY_CERTIFICATE__TERMINATION_DATE) is not null then 'HUB_POLICY|' || POLICY_BK end"
  CERTIFICATE_NUMBER_CK: 'POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK'
  COVERAGE_END_DATE: 'POLICY_CERTIFICATE__COVERAGE_END_DATE'
  COVERAGE_START_DATE: 'POLICY_CERTIFICATE__COVERAGE_START_DATE'
  MEMBER_CATEGORY: 'POLICY_CERTIFICATE__MEMBER_CATEGORY'
  MEMBER_PREMIUM: 'POLICY_CERTIFICATE__MEMBER_PREMIUM'
  MEMBER_STATUS: 'POLICY_CERTIFICATE__MEMBER_STATUS'
  TERMINATION_DATE: 'POLICY_CERTIFICATE__TERMINATION_DATE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v06_coverage'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
