-- automate_dv.stage() for SAT_CASE_HEADER, read off central view stitch_v05_claim.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v05_claim'
hashed_columns:
  CASE_HKEY: 'CASE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ASSIGNED_TO_REFERENCE'
      - 'CASE_STATUS'
derived_columns:
  CASE_NK: "case when coalesce(CASE_HEADER__ASSIGNED_TO_REFERENCE, CASE_HEADER__CASE_STATUS) is not null then 'HUB_CASE|' || CASE_BK end"
  ASSIGNED_TO_REFERENCE: 'CASE_HEADER__ASSIGNED_TO_REFERENCE'
  CASE_STATUS: 'CASE_HEADER__CASE_STATUS'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v05_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
