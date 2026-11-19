-- automate_dv.stage() for SAT_RISK_HEALTH_MEMBER_MEDICAL, read off central view stitch_v34_risk_object.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v34_risk_object'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CONDITION_NAME'
      - 'DISCLOSED_INDICATOR'
      - 'LAST_TREATMENT_DATE'
      - 'UNDERWRITING_LOADING_PERCENTAGE'
      - 'MEMBER_REFERENCE_CK'
      - 'CONDITION_CODE_CK'
derived_columns:
  RISK_OBJECT_NK: "case when coalesce(RISK_HEALTH_MEMBER_MEDICAL__CONDITION_NAME, RISK_HEALTH_MEMBER_MEDICAL__DISCLOSED_INDICATOR, RISK_HEALTH_MEMBER_MEDICAL__LAST_TREATMENT_DATE, RISK_HEALTH_MEMBER_MEDICAL__UNDERWRITING_LOADING_PERCENTAGE) is not null then 'HUB_RISK_OBJECT|' || RISK_OBJECT_BK end"
  MEMBER_REFERENCE_CK: 'RISK_HEALTH_MEMBER_MEDICAL__MEMBER_REFERENCE_CK'
  CONDITION_CODE_CK: 'RISK_HEALTH_MEMBER_MEDICAL__CONDITION_CODE_CK'
  CONDITION_NAME: 'RISK_HEALTH_MEMBER_MEDICAL__CONDITION_NAME'
  DISCLOSED_INDICATOR: 'RISK_HEALTH_MEMBER_MEDICAL__DISCLOSED_INDICATOR'
  LAST_TREATMENT_DATE: 'RISK_HEALTH_MEMBER_MEDICAL__LAST_TREATMENT_DATE'
  UNDERWRITING_LOADING_PERCENTAGE: 'RISK_HEALTH_MEMBER_MEDICAL__UNDERWRITING_LOADING_PERCENTAGE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v34_risk_object'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
