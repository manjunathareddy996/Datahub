-- automate_dv.stage() for SAT_COMMON_BUSINESS_AUDIT, read off central view stitch_motor__v17_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v17_policy'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CREATED_BY_USER_REFERENCE'
      - 'SOURCE_APPLICATION_NAME'
derived_columns:
  POLICY_NK: "case when coalesce(COMMON_BUSINESS_AUDIT__CREATED_BY_USER_REFERENCE, COMMON_BUSINESS_AUDIT__SOURCE_APPLICATION_NAME) is not null then 'HUB_POLICY|' || POLICY_BK end"
  CREATED_BY_USER_REFERENCE: 'COMMON_BUSINESS_AUDIT__CREATED_BY_USER_REFERENCE'
  SOURCE_APPLICATION_NAME: 'COMMON_BUSINESS_AUDIT__SOURCE_APPLICATION_NAME'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_stitch_motor__v17_policy'
  SOURCE_SYSTEM: '!OPUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
