-- automate_dv.stage() for SAT_MOTOR_AUG_POLICY_SERVICING_SUMMARY, read off central view stitch_mxm__v12_policy.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v12_policy'
hashed_columns:
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'BANCASSURANCE_CHARGE_FILE_PROCESS_COUNT'
derived_columns:
  POLICY_NK: "case when AUG_POLICY_SERVICING_SUMMARY__BANCASSURANCE_CHARGE_FILE_PROCESS_COUNT is not null then 'HUB_POLICY|' || POLICY_BK end"
  BANCASSURANCE_CHARGE_FILE_PROCESS_COUNT: 'AUG_POLICY_SERVICING_SUMMARY__BANCASSURANCE_CHARGE_FILE_PROCESS_COUNT'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!stitch_mxm__v12_policy'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
