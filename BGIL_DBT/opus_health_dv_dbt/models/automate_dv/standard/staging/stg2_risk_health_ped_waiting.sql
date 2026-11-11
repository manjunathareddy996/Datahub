-- automate_dv.stage() for SAT_RISK_HEALTH_PED_WAITING, read off central view stitch_v33_quote.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v33_quote'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CONDITION_NAME'
      - 'CONDITION_CODE_CK'
derived_columns:
  RISK_OBJECT_NK: "case when RISK_HEALTH_PED_WAITING__CONDITION_NAME is not null then 'HUB_RISK_OBJECT|' || RISK_OBJECT_BK end"
  CONDITION_CODE_CK: 'RISK_HEALTH_PED_WAITING__CONDITION_CODE_CK'
  CONDITION_NAME: 'RISK_HEALTH_PED_WAITING__CONDITION_NAME'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v33_quote'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
