-- automate_dv.stage() for SAT_COVERAGE_LIMITS, read off central view stitch_mxm__v01_assessment.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v01_assessment'
hashed_columns:
  COVERAGE_HKEY: 'COVERAGE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'DEDUCTIBLE_AMOUNT'
      - 'EXCESS_AMOUNT'
      - 'FRANCHISE_AMOUNT'
      - 'INDEMNITY_PERIOD'
      - 'LIMIT_AMOUNT'
      - 'PER_PERSON_LIMIT'
      - 'VOLUNTARY_DEDUCTIBLE_AMOUNT'
derived_columns:
  COVERAGE_NK: "case when coalesce(COVERAGE_LIMITS__DEDUCTIBLE_AMOUNT, COVERAGE_LIMITS__EXCESS_AMOUNT, COVERAGE_LIMITS__FRANCHISE_AMOUNT, COVERAGE_LIMITS__INDEMNITY_PERIOD, COVERAGE_LIMITS__LIMIT_AMOUNT, COVERAGE_LIMITS__PER_PERSON_LIMIT, COVERAGE_LIMITS__VOLUNTARY_DEDUCTIBLE_AMOUNT) is not null then 'HUB_COVERAGE|' || COVERAGE_BK end"
  DEDUCTIBLE_AMOUNT: 'COVERAGE_LIMITS__DEDUCTIBLE_AMOUNT'
  EXCESS_AMOUNT: 'COVERAGE_LIMITS__EXCESS_AMOUNT'
  FRANCHISE_AMOUNT: 'COVERAGE_LIMITS__FRANCHISE_AMOUNT'
  INDEMNITY_PERIOD: 'COVERAGE_LIMITS__INDEMNITY_PERIOD'
  LIMIT_AMOUNT: 'COVERAGE_LIMITS__LIMIT_AMOUNT'
  PER_PERSON_LIMIT: 'COVERAGE_LIMITS__PER_PERSON_LIMIT'
  VOLUNTARY_DEDUCTIBLE_AMOUNT: 'COVERAGE_LIMITS__VOLUNTARY_DEDUCTIBLE_AMOUNT'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v01_assessment'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
