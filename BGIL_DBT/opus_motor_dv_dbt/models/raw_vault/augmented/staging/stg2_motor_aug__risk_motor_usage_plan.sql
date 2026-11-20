-- automate_dv.stage() for SAT_MOTOR_AUG_RISK_MOTOR_USAGE_PLAN, read off central view stitch_motor__v22_quote.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v22_quote'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PLAN_ELECTION_INDICATOR'
      - 'PLAN_CODE_CK'
derived_columns:
  RISK_OBJECT_NK: "case when AUG_RISK_MOTOR_USAGE_PLAN__PLAN_ELECTION_INDICATOR is not null then 'HUB_RISK_OBJECT|' || RISK_OBJECT_BK end"
  PLAN_CODE_CK: 'AUG_RISK_MOTOR_USAGE_PLAN__PLAN_CODE_CK'
  PLAN_ELECTION_INDICATOR: 'AUG_RISK_MOTOR_USAGE_PLAN__PLAN_ELECTION_INDICATOR'
  LOAD_DATETIME: 'RISK_OBJECT_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!OPUS_stitch_motor__v22_quote'
  SOURCE_SYSTEM: '!OPUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
