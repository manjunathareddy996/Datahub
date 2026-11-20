-- automate_dv.stage() for SAT_MOTOR_AUG_RISK_MOTOR_RATING_ZONE_HEAD, read off central view stitch_mxm__v12_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v12_policy'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'RTA_CLUSTER_NAME'
      - 'RATING_HEAD_CODE_CK'
derived_columns:
  RISK_OBJECT_NK: "case when AUG_RISK_MOTOR_RATING_ZONE_HEAD__RTA_CLUSTER_NAME is not null then 'HUB_RISK_OBJECT|' || RISK_OBJECT_BK end"
  RATING_HEAD_CODE_CK: 'AUG_RISK_MOTOR_RATING_ZONE_HEAD__RATING_HEAD_CODE_CK'
  RTA_CLUSTER_NAME: 'AUG_RISK_MOTOR_RATING_ZONE_HEAD__RTA_CLUSTER_NAME'
  LOAD_DATETIME: 'RISK_OBJECT_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v12_policy'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
