-- automate_dv.stage() for SAT_AUG_COMMON_BUSINESS_AUDIT, read off central view stitch_v23_policy.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v23_policy'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'APPROVED_BY_USER_REFERENCE'
      - 'POLICY_CAPTURED_BY_USER_REFERENCE'
      - 'WEB_USER_IDENTIFIER'
derived_columns:
  POLICY_NK: "case when coalesce(AUG_COMMON_BUSINESS_AUDIT__APPROVED_BY_USER_REFERENCE, AUG_COMMON_BUSINESS_AUDIT__POLICY_CAPTURED_BY_USER_REFERENCE, AUG_COMMON_BUSINESS_AUDIT__WEB_USER_IDENTIFIER) is not null then 'HUB_POLICY|' || POLICY_BK end"
  APPROVED_BY_USER_REFERENCE: 'AUG_COMMON_BUSINESS_AUDIT__APPROVED_BY_USER_REFERENCE'
  POLICY_CAPTURED_BY_USER_REFERENCE: 'AUG_COMMON_BUSINESS_AUDIT__POLICY_CAPTURED_BY_USER_REFERENCE'
  WEB_USER_IDENTIFIER: 'AUG_COMMON_BUSINESS_AUDIT__WEB_USER_IDENTIFIER'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v23_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
