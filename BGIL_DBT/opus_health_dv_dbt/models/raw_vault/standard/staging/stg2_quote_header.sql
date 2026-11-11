-- automate_dv.stage() for SAT_QUOTE_HEADER, read off central view stitch_v02_assessment.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v02_assessment'
hashed_columns:
  QUOTE_HKEY: 'QUOTE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'QUOTE_DATE'
      - 'QUOTE_REMARKS'
      - 'QUOTE_STATUS'
      - 'QUOTE_VERSION'
      - 'REQUESTED_COVER_START_DATE'
derived_columns:
  QUOTE_NK: "case when coalesce(QUOTE_HEADER__QUOTE_DATE, QUOTE_HEADER__QUOTE_REMARKS, QUOTE_HEADER__QUOTE_STATUS, QUOTE_HEADER__QUOTE_VERSION, QUOTE_HEADER__REQUESTED_COVER_START_DATE) is not null then 'HUB_QUOTE|' || QUOTE_BK end"
  QUOTE_DATE: 'QUOTE_HEADER__QUOTE_DATE'
  QUOTE_REMARKS: 'QUOTE_HEADER__QUOTE_REMARKS'
  QUOTE_STATUS: 'QUOTE_HEADER__QUOTE_STATUS'
  QUOTE_VERSION: 'QUOTE_HEADER__QUOTE_VERSION'
  REQUESTED_COVER_START_DATE: 'QUOTE_HEADER__REQUESTED_COVER_START_DATE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v02_assessment'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
