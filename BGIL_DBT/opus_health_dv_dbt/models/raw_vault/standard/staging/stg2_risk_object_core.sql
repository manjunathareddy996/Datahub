-- automate_dv.stage() for SAT_RISK_OBJECT_CORE, read off central view stitch_v13_financial_account.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v13_financial_account'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'RISK_CLASS_CODE'
derived_columns:
  RISK_OBJECT_NK: "case when RISK_OBJECT_CORE__RISK_CLASS_CODE is not null then 'HUB_RISK_OBJECT|' || RISK_OBJECT_BK end"
  RISK_CLASS_CODE: 'RISK_OBJECT_CORE__RISK_CLASS_CODE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v13_financial_account'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
