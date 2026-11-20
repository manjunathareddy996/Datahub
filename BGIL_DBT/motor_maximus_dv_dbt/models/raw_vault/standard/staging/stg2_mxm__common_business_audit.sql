-- automate_dv.stage() for SAT_COMMON_BUSINESS_AUDIT, read off central view stitch_mxm__v12_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v12_policy'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CREATED_BY_USER_REFERENCE'
      - 'CREATED_DATE'
      - 'SOURCE_APPLICATION_NAME'
derived_columns:
  POLICY_NK: "case when coalesce(COMMON_BUSINESS_AUDIT__CREATED_BY_USER_REFERENCE, COMMON_BUSINESS_AUDIT__CREATED_DATE, COMMON_BUSINESS_AUDIT__SOURCE_APPLICATION_NAME) is not null then 'HUB_POLICY|' || POLICY_BK end"
  CREATED_BY_USER_REFERENCE: 'COMMON_BUSINESS_AUDIT__CREATED_BY_USER_REFERENCE'
  CREATED_DATE: 'COMMON_BUSINESS_AUDIT__CREATED_DATE'
  SOURCE_APPLICATION_NAME: 'COMMON_BUSINESS_AUDIT__SOURCE_APPLICATION_NAME'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v12_policy'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
