-- automate_dv.stage() for SAT_COMMON_STATUS, read off central view stitch_mxm__v14_risk_object.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v14_risk_object'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'STATUS_CODE'
      - 'SUB_STATUS_CODE'
derived_columns:
  POLICY_NK: "case when coalesce(COMMON_STATUS__STATUS_CODE, COMMON_STATUS__SUB_STATUS_CODE) is not null then 'HUB_POLICY|' || POLICY_BK end"
  STATUS_CODE: 'COMMON_STATUS__STATUS_CODE'
  SUB_STATUS_CODE: 'COMMON_STATUS__SUB_STATUS_CODE'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v14_risk_object'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
