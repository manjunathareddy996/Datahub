-- automate_dv.stage() for SAT_MOTOR_AUG_RISK_MOTOR_CPA, read off central view stitch_motor__v11_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v11_party'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'COMPULSORY_PA_DEFAULT_INDICATOR'
derived_columns:
  RISK_OBJECT_NK: "case when AUG_RISK_MOTOR_CPA__COMPULSORY_PA_DEFAULT_INDICATOR is not null then 'HUB_RISK_OBJECT|' || RISK_OBJECT_BK end"
  COMPULSORY_PA_DEFAULT_INDICATOR: 'AUG_RISK_MOTOR_CPA__COMPULSORY_PA_DEFAULT_INDICATOR'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!stitch_motor__v11_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
