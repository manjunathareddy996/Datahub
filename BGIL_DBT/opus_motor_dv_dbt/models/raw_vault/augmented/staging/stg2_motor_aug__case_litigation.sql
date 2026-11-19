-- automate_dv.stage() for SAT_MOTOR_AUG_CASE_LITIGATION, read off central view stitch_motor__v02_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v02_claim'
hashed_columns:
  CASE_HKEY: 'CASE_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'COURT_CASE_NUMBER'
      - 'COURT_RELEASE_ORDER_OBTAINED_INDICATOR'
      - 'COURT_RELEASE_ORDER_RECEIVED_DATE'
      - 'COURT_SALE_ORDER_OBTAINED_INDICATOR'
      - 'COURT_SALE_ORDER_RECEIVED_DATE'
derived_columns:
  CASE_NK: "case when coalesce(AUG_CASE_LITIGATION__COURT_CASE_NUMBER, AUG_CASE_LITIGATION__COURT_RELEASE_ORDER_OBTAINED_INDICATOR, AUG_CASE_LITIGATION__COURT_RELEASE_ORDER_RECEIVED_DATE, AUG_CASE_LITIGATION__COURT_SALE_ORDER_OBTAINED_INDICATOR, AUG_CASE_LITIGATION__COURT_SALE_ORDER_RECEIVED_DATE) is not null then 'HUB_CASE|' || CASE_BK end"
  COURT_CASE_NUMBER: 'AUG_CASE_LITIGATION__COURT_CASE_NUMBER'
  COURT_RELEASE_ORDER_OBTAINED_INDICATOR: 'AUG_CASE_LITIGATION__COURT_RELEASE_ORDER_OBTAINED_INDICATOR'
  COURT_RELEASE_ORDER_RECEIVED_DATE: 'AUG_CASE_LITIGATION__COURT_RELEASE_ORDER_RECEIVED_DATE'
  COURT_SALE_ORDER_OBTAINED_INDICATOR: 'AUG_CASE_LITIGATION__COURT_SALE_ORDER_OBTAINED_INDICATOR'
  COURT_SALE_ORDER_RECEIVED_DATE: 'AUG_CASE_LITIGATION__COURT_SALE_ORDER_RECEIVED_DATE'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_stitch_motor__v02_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
