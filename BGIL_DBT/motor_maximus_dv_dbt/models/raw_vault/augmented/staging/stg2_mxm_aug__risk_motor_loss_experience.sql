-- automate_dv.stage() for SAT_MOTOR_AUG_RISK_MOTOR_LOSS_EXPERIENCE, read off central view stitch_mxm__v14_risk_object.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v14_risk_object'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'OWN_DAMAGE_CLAIM_FREQUENCY'
      - 'OWN_DAMAGE_CLAIM_SEVERITY'
      - 'OWN_DAMAGE_LOSS_RATIO'
derived_columns:
  RISK_OBJECT_NK: "case when coalesce(AUG_RISK_MOTOR_LOSS_EXPERIENCE__OWN_DAMAGE_CLAIM_FREQUENCY, AUG_RISK_MOTOR_LOSS_EXPERIENCE__OWN_DAMAGE_CLAIM_SEVERITY, AUG_RISK_MOTOR_LOSS_EXPERIENCE__OWN_DAMAGE_LOSS_RATIO) is not null then 'HUB_RISK_OBJECT|' || RISK_OBJECT_BK end"
  OWN_DAMAGE_CLAIM_FREQUENCY: 'AUG_RISK_MOTOR_LOSS_EXPERIENCE__OWN_DAMAGE_CLAIM_FREQUENCY'
  OWN_DAMAGE_CLAIM_SEVERITY: 'AUG_RISK_MOTOR_LOSS_EXPERIENCE__OWN_DAMAGE_CLAIM_SEVERITY'
  OWN_DAMAGE_LOSS_RATIO: 'AUG_RISK_MOTOR_LOSS_EXPERIENCE__OWN_DAMAGE_LOSS_RATIO'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v14_risk_object'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
