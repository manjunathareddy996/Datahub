-- automate_dv.stage() for SAT_CASE_HEADER, read off central view stitch_motor__v02_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v02_claim'
hashed_columns:
  CASE_HKEY: 'CASE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ASSIGNED_TO_REFERENCE'
      - 'CASE_STATUS'
      - 'CASE_SUB_STATUS'
      - 'RAISED_DATE'
      - 'RESOLUTION_DATE'
derived_columns:
  CASE_NK: "case when coalesce(CASE_HEADER__ASSIGNED_TO_REFERENCE, CASE_HEADER__CASE_STATUS, CASE_HEADER__CASE_SUB_STATUS, CASE_HEADER__RAISED_DATE, CASE_HEADER__RESOLUTION_DATE) is not null then 'HUB_CASE|' || CASE_BK end"
  ASSIGNED_TO_REFERENCE: 'CASE_HEADER__ASSIGNED_TO_REFERENCE'
  CASE_STATUS: 'CASE_HEADER__CASE_STATUS'
  CASE_SUB_STATUS: 'CASE_HEADER__CASE_SUB_STATUS'
  RAISED_DATE: 'CASE_HEADER__RAISED_DATE'
  RESOLUTION_DATE: 'CASE_HEADER__RESOLUTION_DATE'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!stitch_motor__v02_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
