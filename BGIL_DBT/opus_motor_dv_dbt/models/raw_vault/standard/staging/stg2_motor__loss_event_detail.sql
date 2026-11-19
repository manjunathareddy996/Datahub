-- automate_dv.stage() for SAT_LOSS_EVENT_DETAIL, read off central view stitch_motor__v01_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v01_claim'
hashed_columns:
  LOSS_EVENT_HKEY: 'LOSS_EVENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CAUSE_OF_LOSS'
      - 'ESTIMATED_LOSS_AMOUNT'
      - 'FIR_NUMBER'
      - 'LOSS_DATE'
      - 'LOSS_DESCRIPTION'
      - 'LOSS_EVENT_TYPE'
      - 'LOSS_TIME'
      - 'PERIL_CODE'
      - 'POLICE_STATION_NAME'
      - 'SUB_PERIL_CODE'
      - 'THIRD_PARTY_INVOLVED_INDICATOR'
derived_columns:
  LOSS_EVENT_NK: "case when coalesce(LOSS_EVENT_DETAIL__CAUSE_OF_LOSS, LOSS_EVENT_DETAIL__ESTIMATED_LOSS_AMOUNT, LOSS_EVENT_DETAIL__FIR_NUMBER, LOSS_EVENT_DETAIL__LOSS_DATE, LOSS_EVENT_DETAIL__LOSS_DESCRIPTION, LOSS_EVENT_DETAIL__LOSS_EVENT_TYPE, LOSS_EVENT_DETAIL__LOSS_TIME, LOSS_EVENT_DETAIL__PERIL_CODE, LOSS_EVENT_DETAIL__POLICE_STATION_NAME, LOSS_EVENT_DETAIL__SUB_PERIL_CODE, LOSS_EVENT_DETAIL__THIRD_PARTY_INVOLVED_INDICATOR) is not null then 'HUB_LOSS_EVENT|' || LOSS_EVENT_BK end"
  CAUSE_OF_LOSS: 'LOSS_EVENT_DETAIL__CAUSE_OF_LOSS'
  ESTIMATED_LOSS_AMOUNT: 'LOSS_EVENT_DETAIL__ESTIMATED_LOSS_AMOUNT'
  FIR_NUMBER: 'LOSS_EVENT_DETAIL__FIR_NUMBER'
  LOSS_DATE: 'LOSS_EVENT_DETAIL__LOSS_DATE'
  LOSS_DESCRIPTION: 'LOSS_EVENT_DETAIL__LOSS_DESCRIPTION'
  LOSS_EVENT_TYPE: 'LOSS_EVENT_DETAIL__LOSS_EVENT_TYPE'
  LOSS_TIME: 'LOSS_EVENT_DETAIL__LOSS_TIME'
  PERIL_CODE: 'LOSS_EVENT_DETAIL__PERIL_CODE'
  POLICE_STATION_NAME: 'LOSS_EVENT_DETAIL__POLICE_STATION_NAME'
  SUB_PERIL_CODE: 'LOSS_EVENT_DETAIL__SUB_PERIL_CODE'
  THIRD_PARTY_INVOLVED_INDICATOR: 'LOSS_EVENT_DETAIL__THIRD_PARTY_INVOLVED_INDICATOR'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_stitch_motor__v01_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
