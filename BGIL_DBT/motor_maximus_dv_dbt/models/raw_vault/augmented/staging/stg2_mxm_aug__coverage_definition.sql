-- automate_dv.stage() for SAT_MOTOR_AUG_COVERAGE_DEFINITION, read off central view stitch_mxm__v07_financial_transaction.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v07_financial_transaction'
hashed_columns:
  COVERAGE_HKEY: 'COVERAGE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'COVERAGE_DURATION'
      - 'COVERAGE_EXPIRY_DATE'
      - 'COVERAGE_INCEPTION_DATE'
      - 'EVENT_BASED_INDICATOR'
      - 'FACULTATIVE_REINSURANCE_INDICATOR'
      - 'LEADING_COVERAGE_INDICATOR'
derived_columns:
  COVERAGE_NK: "case when coalesce(AUG_COVERAGE_DEFINITION__COVERAGE_DURATION, AUG_COVERAGE_DEFINITION__COVERAGE_EXPIRY_DATE, AUG_COVERAGE_DEFINITION__COVERAGE_INCEPTION_DATE, AUG_COVERAGE_DEFINITION__EVENT_BASED_INDICATOR, AUG_COVERAGE_DEFINITION__FACULTATIVE_REINSURANCE_INDICATOR, AUG_COVERAGE_DEFINITION__LEADING_COVERAGE_INDICATOR) is not null then 'HUB_COVERAGE|' || COVERAGE_BK end"
  COVERAGE_DURATION: 'AUG_COVERAGE_DEFINITION__COVERAGE_DURATION'
  COVERAGE_EXPIRY_DATE: 'AUG_COVERAGE_DEFINITION__COVERAGE_EXPIRY_DATE'
  COVERAGE_INCEPTION_DATE: 'AUG_COVERAGE_DEFINITION__COVERAGE_INCEPTION_DATE'
  EVENT_BASED_INDICATOR: 'AUG_COVERAGE_DEFINITION__EVENT_BASED_INDICATOR'
  FACULTATIVE_REINSURANCE_INDICATOR: 'AUG_COVERAGE_DEFINITION__FACULTATIVE_REINSURANCE_INDICATOR'
  LEADING_COVERAGE_INDICATOR: 'AUG_COVERAGE_DEFINITION__LEADING_COVERAGE_INDICATOR'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v07_financial_transaction'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
