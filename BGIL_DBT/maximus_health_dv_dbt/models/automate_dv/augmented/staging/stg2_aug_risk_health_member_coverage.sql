-- automate_dv.stage() for SAT_AUG_RISK_HEALTH_MEMBER_COVERAGE, read off central view stitch_v15_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v15_policy'
hashed_columns:
  RISK_OBJECT_HKEY: 'RISK_OBJECT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ELIGIBLE_SUM_INSURED'
      - 'MEMBER_REFERENCE_CK'
derived_columns:
  RISK_OBJECT_NK: "case when AUG_RISK_HEALTH_MEMBER_COVERAGE__ELIGIBLE_SUM_INSURED is not null then 'HUB_RISK_OBJECT|' || RISK_OBJECT_BK end"
  MEMBER_REFERENCE_CK: 'AUG_RISK_HEALTH_MEMBER_COVERAGE__MEMBER_REFERENCE_CK'
  ELIGIBLE_SUM_INSURED: 'AUG_RISK_HEALTH_MEMBER_COVERAGE__ELIGIBLE_SUM_INSURED'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v15_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
