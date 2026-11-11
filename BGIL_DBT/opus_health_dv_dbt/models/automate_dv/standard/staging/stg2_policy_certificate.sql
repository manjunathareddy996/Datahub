-- automate_dv.stage() for SAT_POLICY_CERTIFICATE, read off central view stitch_v20_party.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v20_party'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CERTIFICATE_NUMBER'
      - 'COVERAGE_END_DATE'
      - 'COVERAGE_START_DATE'
      - 'ENROLMENT_DATE'
      - 'JOINING_TYPE'
      - 'MEMBER_PREMIUM'
      - 'MEMBER_STATUS'
      - 'MEMBER_SUM_INSURED'
      - 'CERTIFICATE_NUMBER_CK'
derived_columns:
  POLICY_NK: "case when coalesce(POLICY_CERTIFICATE__CERTIFICATE_NUMBER, POLICY_CERTIFICATE__COVERAGE_END_DATE, POLICY_CERTIFICATE__COVERAGE_START_DATE, POLICY_CERTIFICATE__ENROLMENT_DATE, POLICY_CERTIFICATE__JOINING_TYPE, POLICY_CERTIFICATE__MEMBER_PREMIUM, POLICY_CERTIFICATE__MEMBER_STATUS, POLICY_CERTIFICATE__MEMBER_SUM_INSURED) is not null then 'HUB_POLICY|' || POLICY_BK end"
  CERTIFICATE_NUMBER_CK: 'POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK'
  CERTIFICATE_NUMBER: 'POLICY_CERTIFICATE__CERTIFICATE_NUMBER'
  COVERAGE_END_DATE: 'POLICY_CERTIFICATE__COVERAGE_END_DATE'
  COVERAGE_START_DATE: 'POLICY_CERTIFICATE__COVERAGE_START_DATE'
  ENROLMENT_DATE: 'POLICY_CERTIFICATE__ENROLMENT_DATE'
  JOINING_TYPE: 'POLICY_CERTIFICATE__JOINING_TYPE'
  MEMBER_PREMIUM: 'POLICY_CERTIFICATE__MEMBER_PREMIUM'
  MEMBER_STATUS: 'POLICY_CERTIFICATE__MEMBER_STATUS'
  MEMBER_SUM_INSURED: 'POLICY_CERTIFICATE__MEMBER_SUM_INSURED'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v20_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
