-- automate_dv.stage() for SAT_CASE_LITIGATION, read off central view stitch_motor__v02_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v02_claim'
hashed_columns:
  CASE_HKEY: 'CASE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CASE_FILING_DATE'
      - 'CASE_STAGE'
      - 'COURT_NAME'
      - 'NEXT_HEARING_DATE'
derived_columns:
  CASE_NK: "case when coalesce(CASE_LITIGATION__CASE_FILING_DATE, CASE_LITIGATION__CASE_STAGE, CASE_LITIGATION__COURT_NAME, CASE_LITIGATION__NEXT_HEARING_DATE) is not null then 'HUB_CASE|' || CASE_BK end"
  CASE_FILING_DATE: 'CASE_LITIGATION__CASE_FILING_DATE'
  CASE_STAGE: 'CASE_LITIGATION__CASE_STAGE'
  COURT_NAME: 'CASE_LITIGATION__COURT_NAME'
  NEXT_HEARING_DATE: 'CASE_LITIGATION__NEXT_HEARING_DATE'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_stitch_motor__v02_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
