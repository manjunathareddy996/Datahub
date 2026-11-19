-- automate_dv.stage() for SAT_RISK_OBJECT_VALUATION, read off central view stitch_motor__v24_risk_object.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v24_risk_object'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'DECLARED_VALUE'
      - 'DEPRECIATION_PERCENTAGE'
      - 'MARKET_VALUE'
derived_columns:
  RISK_OBJECT_NK: "case when coalesce(RISK_OBJECT_VALUATION__DECLARED_VALUE, RISK_OBJECT_VALUATION__DEPRECIATION_PERCENTAGE, RISK_OBJECT_VALUATION__MARKET_VALUE) is not null then 'HUB_RISK_OBJECT|' || RISK_OBJECT_BK end"
  DECLARED_VALUE: 'RISK_OBJECT_VALUATION__DECLARED_VALUE'
  DEPRECIATION_PERCENTAGE: 'RISK_OBJECT_VALUATION__DEPRECIATION_PERCENTAGE'
  MARKET_VALUE: 'RISK_OBJECT_VALUATION__MARKET_VALUE'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_stitch_motor__v24_risk_object'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
