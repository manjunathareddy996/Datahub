-- automate_dv.stage() for SAT_MOTOR_AUG_QUOTE_EXCESS_STRUCTURE, read off central view stitch_mxm__v14_risk_object.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v14_risk_object'
hashed_columns:
  QUOTE_HKEY: 'QUOTE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'EXCESS_AMOUNT'
      - 'EXCESS_TYPE'
      - 'EXCESS_CODE_CK'
derived_columns:
  QUOTE_NK: "case when coalesce(AUG_QUOTE_EXCESS_STRUCTURE__EXCESS_AMOUNT, AUG_QUOTE_EXCESS_STRUCTURE__EXCESS_TYPE) is not null then 'HUB_QUOTE|' || QUOTE_BK end"
  EXCESS_CODE_CK: 'AUG_QUOTE_EXCESS_STRUCTURE__EXCESS_CODE_CK'
  EXCESS_AMOUNT: 'AUG_QUOTE_EXCESS_STRUCTURE__EXCESS_AMOUNT'
  EXCESS_TYPE: 'AUG_QUOTE_EXCESS_STRUCTURE__EXCESS_TYPE'
  LOAD_DATETIME: 'QUOTE_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v14_risk_object'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
