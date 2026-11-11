-- automate_dv.stage() for SAT_RISK_HEALTH_MEMBER_COVERAGE, read off central view stitch_v06_coverage.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v06_coverage'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CUMULATIVE_BONUS_AMOUNT'
      - 'CUMULATIVE_BONUS_PERCENTAGE'
      - 'MEMBER_SUM_INSURED'
      - 'MEMBER_REFERENCE_CK'
derived_columns:
  RISK_OBJECT_NK: "case when coalesce(RISK_HEALTH_MEMBER_COVERAGE__CUMULATIVE_BONUS_AMOUNT, RISK_HEALTH_MEMBER_COVERAGE__CUMULATIVE_BONUS_PERCENTAGE, RISK_HEALTH_MEMBER_COVERAGE__MEMBER_SUM_INSURED) is not null then 'HUB_RISK_OBJECT|' || RISK_OBJECT_BK end"
  MEMBER_REFERENCE_CK: 'RISK_HEALTH_MEMBER_COVERAGE__MEMBER_REFERENCE_CK'
  CUMULATIVE_BONUS_AMOUNT: 'RISK_HEALTH_MEMBER_COVERAGE__CUMULATIVE_BONUS_AMOUNT'
  CUMULATIVE_BONUS_PERCENTAGE: 'RISK_HEALTH_MEMBER_COVERAGE__CUMULATIVE_BONUS_PERCENTAGE'
  MEMBER_SUM_INSURED: 'RISK_HEALTH_MEMBER_COVERAGE__MEMBER_SUM_INSURED'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v06_coverage'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
