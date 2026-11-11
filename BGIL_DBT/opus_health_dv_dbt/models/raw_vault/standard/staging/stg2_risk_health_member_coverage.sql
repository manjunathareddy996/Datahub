-- automate_dv.stage() for SAT_RISK_HEALTH_MEMBER_COVERAGE, read off central view stitch_v34_risk_object.
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
      - 'LOADING_REASON'
      - 'MEMBER_SUM_INSURED'
      - 'PRE_POLICY_CHECKUP_INDICATOR'
      - 'MEMBER_REFERENCE_CK'
derived_columns:
  RISK_OBJECT_NK: "case when coalesce(RISK_HEALTH_MEMBER_COVERAGE__LOADING_REASON, RISK_HEALTH_MEMBER_COVERAGE__MEMBER_SUM_INSURED, RISK_HEALTH_MEMBER_COVERAGE__PRE_POLICY_CHECKUP_INDICATOR) is not null then 'HUB_RISK_OBJECT|' || RISK_OBJECT_BK end"
  MEMBER_REFERENCE_CK: 'RISK_HEALTH_MEMBER_COVERAGE__MEMBER_REFERENCE_CK'
  LOADING_REASON: 'RISK_HEALTH_MEMBER_COVERAGE__LOADING_REASON'
  MEMBER_SUM_INSURED: 'RISK_HEALTH_MEMBER_COVERAGE__MEMBER_SUM_INSURED'
  PRE_POLICY_CHECKUP_INDICATOR: 'RISK_HEALTH_MEMBER_COVERAGE__PRE_POLICY_CHECKUP_INDICATOR'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v34_risk_object'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
