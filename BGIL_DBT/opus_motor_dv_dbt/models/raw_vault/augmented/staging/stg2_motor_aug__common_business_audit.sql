-- automate_dv.stage() for SAT_AUG_COMMON_BUSINESS_AUDIT, read off central view stitch_motor__v15_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v15_policy'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'LAST_MODIFIED_BY_USER_NAME'
      - 'LAST_MODIFIED_BY_USER_REFERENCE'
derived_columns:
  POLICY_NK: "case when coalesce(AUG_COMMON_BUSINESS_AUDIT__LAST_MODIFIED_BY_USER_NAME, AUG_COMMON_BUSINESS_AUDIT__LAST_MODIFIED_BY_USER_REFERENCE) is not null then 'HUB_POLICY|' || POLICY_BK end"
  LAST_MODIFIED_BY_USER_NAME: 'AUG_COMMON_BUSINESS_AUDIT__LAST_MODIFIED_BY_USER_NAME'
  LAST_MODIFIED_BY_USER_REFERENCE: 'AUG_COMMON_BUSINESS_AUDIT__LAST_MODIFIED_BY_USER_REFERENCE'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!stitch_motor__v15_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
