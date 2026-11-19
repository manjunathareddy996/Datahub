-- automate_dv.stage() for SAT_CASE_INVESTIGATION, read off central view stitch_motor__v02_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v02_claim'
hashed_columns:
  CASE_HKEY: 'CASE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'FINDINGS_SUMMARY'
derived_columns:
  CASE_NK: "case when CASE_INVESTIGATION__FINDINGS_SUMMARY is not null then 'HUB_CASE|' || CASE_BK end"
  FINDINGS_SUMMARY: 'CASE_INVESTIGATION__FINDINGS_SUMMARY'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_MOTOR_V02_CLAIM'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
