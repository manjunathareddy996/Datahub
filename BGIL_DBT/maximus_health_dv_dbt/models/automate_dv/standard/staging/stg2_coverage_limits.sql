-- automate_dv.stage() for SAT_COVERAGE_LIMITS, read off central view stitch_v06_coverage.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v06_coverage'
hashed_columns:
  COVERAGE_HKEY: 'COVERAGE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'INDEMNITY_PERIOD'
      - 'LIMIT_TYPE'
      - 'REINSTATEMENT_INDICATOR'
      - 'RESTORATION_INDICATOR'
      - 'SURVIVAL_PERIOD'
      - 'VOLUNTARY_DEDUCTIBLE_AMOUNT'
derived_columns:
  COVERAGE_NK: "case when coalesce(COVERAGE_LIMITS__INDEMNITY_PERIOD, COVERAGE_LIMITS__LIMIT_TYPE, COVERAGE_LIMITS__REINSTATEMENT_INDICATOR, COVERAGE_LIMITS__RESTORATION_INDICATOR, COVERAGE_LIMITS__SURVIVAL_PERIOD, COVERAGE_LIMITS__VOLUNTARY_DEDUCTIBLE_AMOUNT) is not null then 'HUB_COVERAGE|' || COVERAGE_BK end"
  INDEMNITY_PERIOD: 'COVERAGE_LIMITS__INDEMNITY_PERIOD'
  LIMIT_TYPE: 'COVERAGE_LIMITS__LIMIT_TYPE'
  REINSTATEMENT_INDICATOR: 'COVERAGE_LIMITS__REINSTATEMENT_INDICATOR'
  RESTORATION_INDICATOR: 'COVERAGE_LIMITS__RESTORATION_INDICATOR'
  SURVIVAL_PERIOD: 'COVERAGE_LIMITS__SURVIVAL_PERIOD'
  VOLUNTARY_DEDUCTIBLE_AMOUNT: 'COVERAGE_LIMITS__VOLUNTARY_DEDUCTIBLE_AMOUNT'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v06_coverage'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
