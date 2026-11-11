-- automate_dv.stage() for SAT_AUG_COVERAGE_CONDITIONS, read off central view stitch_v06_coverage.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v06_coverage'
hashed_columns:
  COVERAGE_HKEY: 'COVERAGE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'OPERATIVE_TIME_AT_RISK'
      - 'REINSTATEMENT_TRIGGER_CONDITION'
derived_columns:
  COVERAGE_NK: "case when coalesce(AUG_COVERAGE_CONDITIONS__OPERATIVE_TIME_AT_RISK, AUG_COVERAGE_CONDITIONS__REINSTATEMENT_TRIGGER_CONDITION) is not null then 'HUB_COVERAGE|' || COVERAGE_BK end"
  OPERATIVE_TIME_AT_RISK: 'AUG_COVERAGE_CONDITIONS__OPERATIVE_TIME_AT_RISK'
  REINSTATEMENT_TRIGGER_CONDITION: 'AUG_COVERAGE_CONDITIONS__REINSTATEMENT_TRIGGER_CONDITION'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v06_coverage'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
