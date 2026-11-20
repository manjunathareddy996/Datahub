-- automate_dv.stage() for SAT_MOTOR_AUG_COVERAGE_LIMITS, read off central view stitch_mxm__v01_assessment.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v01_assessment'
hashed_columns:
  COVERAGE_HKEY: 'COVERAGE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'BENEFIT_PERIOD'
      - 'CLAIM_REGISTRATION_COUNT_LIMIT'
      - 'CLAIM_REGISTRATION_LIMIT'
      - 'COVERAGE_SUM_INSURED'
      - 'COVERAGE_SUM_INSURED_CURRENCY'
      - 'DAILY_ALLOWANCE_LIMIT'
      - 'LIMIT_AMOUNT_IN_USD'
derived_columns:
  COVERAGE_NK: "case when coalesce(AUG_COVERAGE_LIMITS__BENEFIT_PERIOD, AUG_COVERAGE_LIMITS__CLAIM_REGISTRATION_COUNT_LIMIT, AUG_COVERAGE_LIMITS__CLAIM_REGISTRATION_LIMIT, AUG_COVERAGE_LIMITS__COVERAGE_SUM_INSURED, AUG_COVERAGE_LIMITS__COVERAGE_SUM_INSURED_CURRENCY, AUG_COVERAGE_LIMITS__DAILY_ALLOWANCE_LIMIT, AUG_COVERAGE_LIMITS__LIMIT_AMOUNT_IN_USD) is not null then 'HUB_COVERAGE|' || COVERAGE_BK end"
  BENEFIT_PERIOD: 'AUG_COVERAGE_LIMITS__BENEFIT_PERIOD'
  CLAIM_REGISTRATION_COUNT_LIMIT: 'AUG_COVERAGE_LIMITS__CLAIM_REGISTRATION_COUNT_LIMIT'
  CLAIM_REGISTRATION_LIMIT: 'AUG_COVERAGE_LIMITS__CLAIM_REGISTRATION_LIMIT'
  COVERAGE_SUM_INSURED: 'AUG_COVERAGE_LIMITS__COVERAGE_SUM_INSURED'
  COVERAGE_SUM_INSURED_CURRENCY: 'AUG_COVERAGE_LIMITS__COVERAGE_SUM_INSURED_CURRENCY'
  DAILY_ALLOWANCE_LIMIT: 'AUG_COVERAGE_LIMITS__DAILY_ALLOWANCE_LIMIT'
  LIMIT_AMOUNT_IN_USD: 'AUG_COVERAGE_LIMITS__LIMIT_AMOUNT_IN_USD'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v01_assessment'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
