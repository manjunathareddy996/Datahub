-- automate_dv.stage() for SAT_MOTOR_AUG_RISK_OBJECT_VALUATION, read off central view stitch_motor__v24_risk_object.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v24_risk_object'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CUBIC_METRE_DECLARED_VALUE'
      - 'EXPECTED_RESALE_VALUE_FROM'
      - 'EXPECTED_RESALE_VALUE_TO'
derived_columns:
  RISK_OBJECT_NK: "case when coalesce(AUG_RISK_OBJECT_VALUATION__CUBIC_METRE_DECLARED_VALUE, AUG_RISK_OBJECT_VALUATION__EXPECTED_RESALE_VALUE_FROM, AUG_RISK_OBJECT_VALUATION__EXPECTED_RESALE_VALUE_TO) is not null then 'HUB_RISK_OBJECT|' || RISK_OBJECT_BK end"
  CUBIC_METRE_DECLARED_VALUE: 'AUG_RISK_OBJECT_VALUATION__CUBIC_METRE_DECLARED_VALUE'
  EXPECTED_RESALE_VALUE_FROM: 'AUG_RISK_OBJECT_VALUATION__EXPECTED_RESALE_VALUE_FROM'
  EXPECTED_RESALE_VALUE_TO: 'AUG_RISK_OBJECT_VALUATION__EXPECTED_RESALE_VALUE_TO'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!stitch_motor__v24_risk_object'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
