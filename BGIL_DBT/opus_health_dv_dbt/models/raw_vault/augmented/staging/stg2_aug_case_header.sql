-- automate_dv.stage() for SAT_AUG_CASE_HEADER, read off central view stitch_v05_claim.
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
      - 'ALLOCATION_DATE'
      - 'ALLOCATION_INDICATOR'
      - 'QUERY_RESPONSE_TEXT'
derived_columns:
  CASE_NK: "case when coalesce(AUG_CASE_HEADER__ALLOCATION_DATE, AUG_CASE_HEADER__ALLOCATION_INDICATOR, AUG_CASE_HEADER__QUERY_RESPONSE_TEXT) is not null then 'HUB_CASE|' || CASE_BK end"
  ALLOCATION_DATE: 'AUG_CASE_HEADER__ALLOCATION_DATE'
  ALLOCATION_INDICATOR: 'AUG_CASE_HEADER__ALLOCATION_INDICATOR'
  QUERY_RESPONSE_TEXT: 'AUG_CASE_HEADER__QUERY_RESPONSE_TEXT'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v05_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
