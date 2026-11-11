-- automate_dv.stage() for SAT_RISK_HEALTH_MEMBER_MEDICAL, read off central view stitch_v17_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v17_policy'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CONDITION_NAME'
      - 'DISCLOSED_INDICATOR'
      - 'ICD_CODE'
      - 'PERMANENT_EXCLUSION_INDICATOR'
      - 'MEMBER_REFERENCE_CK'
      - 'CONDITION_CODE_CK'
derived_columns:
  RISK_OBJECT_NK: "case when coalesce(RISK_HEALTH_MEMBER_MEDICAL__CONDITION_NAME, RISK_HEALTH_MEMBER_MEDICAL__DISCLOSED_INDICATOR, RISK_HEALTH_MEMBER_MEDICAL__ICD_CODE, RISK_HEALTH_MEMBER_MEDICAL__PERMANENT_EXCLUSION_INDICATOR) is not null then 'HUB_RISK_OBJECT|' || RISK_OBJECT_BK end"
  MEMBER_REFERENCE_CK: 'RISK_HEALTH_MEMBER_MEDICAL__MEMBER_REFERENCE_CK'
  CONDITION_CODE_CK: 'RISK_HEALTH_MEMBER_MEDICAL__CONDITION_CODE_CK'
  CONDITION_NAME: 'RISK_HEALTH_MEMBER_MEDICAL__CONDITION_NAME'
  DISCLOSED_INDICATOR: 'RISK_HEALTH_MEMBER_MEDICAL__DISCLOSED_INDICATOR'
  ICD_CODE: 'RISK_HEALTH_MEMBER_MEDICAL__ICD_CODE'
  PERMANENT_EXCLUSION_INDICATOR: 'RISK_HEALTH_MEMBER_MEDICAL__PERMANENT_EXCLUSION_INDICATOR'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v17_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
