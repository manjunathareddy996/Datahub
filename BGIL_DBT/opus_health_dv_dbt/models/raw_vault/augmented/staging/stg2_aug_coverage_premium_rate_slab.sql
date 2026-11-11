-- automate_dv.stage() for SAT_AUG_COVERAGE_PREMIUM_RATE_SLAB, read off central view stitch_v12_coverage.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v12_coverage'
hashed_columns:
  COVERAGE_HKEY: 'COVERAGE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'AGE_LIMIT_BAND'
      - 'LINE_SEQUENCE_NUMBER'
      - 'PLAN_REFERENCE'
      - 'PREMIUM_APPLICABILITY_BASIS'
      - 'RATE_EFFECTIVE_DATE'
      - 'SECTION_REFERENCE'
      - 'SLAB_PREMIUM_RATE'
      - 'SUM_INSURED_SLAB_AMOUNT'
derived_columns:
  COVERAGE_NK: "case when coalesce(AUG_COVERAGE_PREMIUM_RATE_SLAB__AGE_LIMIT_BAND, AUG_COVERAGE_PREMIUM_RATE_SLAB__LINE_SEQUENCE_NUMBER, AUG_COVERAGE_PREMIUM_RATE_SLAB__PLAN_REFERENCE, AUG_COVERAGE_PREMIUM_RATE_SLAB__PREMIUM_APPLICABILITY_BASIS, AUG_COVERAGE_PREMIUM_RATE_SLAB__RATE_EFFECTIVE_DATE, AUG_COVERAGE_PREMIUM_RATE_SLAB__SECTION_REFERENCE, AUG_COVERAGE_PREMIUM_RATE_SLAB__SLAB_PREMIUM_RATE, AUG_COVERAGE_PREMIUM_RATE_SLAB__SUM_INSURED_SLAB_AMOUNT) is not null then 'HUB_COVERAGE|' || COVERAGE_BK end"
  AGE_LIMIT_BAND: 'AUG_COVERAGE_PREMIUM_RATE_SLAB__AGE_LIMIT_BAND'
  LINE_SEQUENCE_NUMBER: 'AUG_COVERAGE_PREMIUM_RATE_SLAB__LINE_SEQUENCE_NUMBER'
  PLAN_REFERENCE: 'AUG_COVERAGE_PREMIUM_RATE_SLAB__PLAN_REFERENCE'
  PREMIUM_APPLICABILITY_BASIS: 'AUG_COVERAGE_PREMIUM_RATE_SLAB__PREMIUM_APPLICABILITY_BASIS'
  RATE_EFFECTIVE_DATE: 'AUG_COVERAGE_PREMIUM_RATE_SLAB__RATE_EFFECTIVE_DATE'
  SECTION_REFERENCE: 'AUG_COVERAGE_PREMIUM_RATE_SLAB__SECTION_REFERENCE'
  SLAB_PREMIUM_RATE: 'AUG_COVERAGE_PREMIUM_RATE_SLAB__SLAB_PREMIUM_RATE'
  SUM_INSURED_SLAB_AMOUNT: 'AUG_COVERAGE_PREMIUM_RATE_SLAB__SUM_INSURED_SLAB_AMOUNT'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v12_coverage'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
