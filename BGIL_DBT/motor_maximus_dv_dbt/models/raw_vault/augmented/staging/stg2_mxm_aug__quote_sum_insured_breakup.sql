-- automate_dv.stage() for SAT_MOTOR_AUG_QUOTE_SUM_INSURED_BREAKUP, read off central view stitch_mxm__v01_assessment.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v01_assessment'
hashed_columns:
  QUOTE_HKEY: 'QUOTE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'HEAD_DESCRIPTION'
      - 'SUM_INSURED_AMOUNT'
      - 'SUM_INSURED_HEAD_CK'
derived_columns:
  QUOTE_NK: "case when coalesce(AUG_QUOTE_SUM_INSURED_BREAKUP__HEAD_DESCRIPTION, AUG_QUOTE_SUM_INSURED_BREAKUP__SUM_INSURED_AMOUNT) is not null then 'HUB_QUOTE|' || QUOTE_BK end"
  SUM_INSURED_HEAD_CK: 'AUG_QUOTE_SUM_INSURED_BREAKUP__SUM_INSURED_HEAD_CK'
  HEAD_DESCRIPTION: 'AUG_QUOTE_SUM_INSURED_BREAKUP__HEAD_DESCRIPTION'
  SUM_INSURED_AMOUNT: 'AUG_QUOTE_SUM_INSURED_BREAKUP__SUM_INSURED_AMOUNT'
  LOAD_DATETIME: 'QUOTE_BK__MA_LOAD_DATETIME'
  RECORD_SOURCE: '!stitch_mxm__v01_assessment'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
