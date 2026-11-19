-- automate_dv.stage() for SAT_MOTOR_AUG_QUOTE_TAX_BREAKUP, read off central view stitch_mxm__v14_risk_object.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v14_risk_object'
hashed_columns:
  QUOTE_HKEY: 'QUOTE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CGST_AMOUNT'
      - 'EXEMPTION_REASON'
      - 'PLACE_OF_SUPPLY'
derived_columns:
  QUOTE_NK: "case when coalesce(AUG_QUOTE_TAX_BREAKUP__CGST_AMOUNT, AUG_QUOTE_TAX_BREAKUP__EXEMPTION_REASON, AUG_QUOTE_TAX_BREAKUP__PLACE_OF_SUPPLY) is not null then 'HUB_QUOTE|' || QUOTE_BK end"
  CGST_AMOUNT: 'AUG_QUOTE_TAX_BREAKUP__CGST_AMOUNT'
  EXEMPTION_REASON: 'AUG_QUOTE_TAX_BREAKUP__EXEMPTION_REASON'
  PLACE_OF_SUPPLY: 'AUG_QUOTE_TAX_BREAKUP__PLACE_OF_SUPPLY'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v14_risk_object'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
