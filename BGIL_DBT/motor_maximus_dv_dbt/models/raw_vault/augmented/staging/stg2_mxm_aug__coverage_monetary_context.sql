-- automate_dv.stage() for SAT_MOTOR_AUG_COVERAGE_MONETARY_CONTEXT, read off central view stitch_mxm__v14_risk_object.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v14_risk_object'
hashed_columns:
  COVERAGE_HKEY: 'COVERAGE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'BASE_CURRENCY_CODE'
      - 'EXCHANGE_RATE'
      - 'SUM_INSURED_CURRENCY_CODE'
      - 'TRANSACTION_CURRENCY_CODE'
derived_columns:
  COVERAGE_NK: "case when coalesce(AUG_COVERAGE_MONETARY_CONTEXT__BASE_CURRENCY_CODE, AUG_COVERAGE_MONETARY_CONTEXT__EXCHANGE_RATE, AUG_COVERAGE_MONETARY_CONTEXT__SUM_INSURED_CURRENCY_CODE, AUG_COVERAGE_MONETARY_CONTEXT__TRANSACTION_CURRENCY_CODE) is not null then 'HUB_COVERAGE|' || COVERAGE_BK end"
  BASE_CURRENCY_CODE: 'AUG_COVERAGE_MONETARY_CONTEXT__BASE_CURRENCY_CODE'
  EXCHANGE_RATE: 'AUG_COVERAGE_MONETARY_CONTEXT__EXCHANGE_RATE'
  SUM_INSURED_CURRENCY_CODE: 'AUG_COVERAGE_MONETARY_CONTEXT__SUM_INSURED_CURRENCY_CODE'
  TRANSACTION_CURRENCY_CODE: 'AUG_COVERAGE_MONETARY_CONTEXT__TRANSACTION_CURRENCY_CODE'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v14_risk_object'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
