-- automate_dv.stage() for SAT_MOTOR_AUG_RISK_OBJECT_VALUATION, read off central view stitch_mxm__v14_risk_object.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v14_risk_object'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'EXCHANGE_RATE'
derived_columns:
  RISK_OBJECT_NK: "case when AUG_RISK_OBJECT_VALUATION__EXCHANGE_RATE is not null then 'HUB_RISK_OBJECT|' || RISK_OBJECT_BK end"
  EXCHANGE_RATE: 'AUG_RISK_OBJECT_VALUATION__EXCHANGE_RATE'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v14_risk_object'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
