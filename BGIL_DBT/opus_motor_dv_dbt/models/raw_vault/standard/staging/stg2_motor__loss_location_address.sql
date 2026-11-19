-- automate_dv.stage() for SAT_LOSS_LOCATION_ADDRESS, read off central view stitch_motor__v01_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v01_claim'
hashed_columns:
  LOSS_EVENT_HKEY: 'LOSS_EVENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ADDRESS_LINE_1'
      - 'ADDRESS_LINE_2'
      - 'CITY'
      - 'LANDMARK'
      - 'POSTAL_CODE'
      - 'STATE_CODE'
derived_columns:
  LOSS_EVENT_NK: "case when coalesce(LOSS_LOCATION_ADDRESS__ADDRESS_LINE_1, LOSS_LOCATION_ADDRESS__ADDRESS_LINE_2, LOSS_LOCATION_ADDRESS__CITY, LOSS_LOCATION_ADDRESS__LANDMARK, LOSS_LOCATION_ADDRESS__POSTAL_CODE, LOSS_LOCATION_ADDRESS__STATE_CODE) is not null then 'HUB_LOSS_EVENT|' || LOSS_EVENT_BK end"
  ADDRESS_LINE_1: 'LOSS_LOCATION_ADDRESS__ADDRESS_LINE_1'
  ADDRESS_LINE_2: 'LOSS_LOCATION_ADDRESS__ADDRESS_LINE_2'
  CITY: 'LOSS_LOCATION_ADDRESS__CITY'
  LANDMARK: 'LOSS_LOCATION_ADDRESS__LANDMARK'
  POSTAL_CODE: 'LOSS_LOCATION_ADDRESS__POSTAL_CODE'
  STATE_CODE: 'LOSS_LOCATION_ADDRESS__STATE_CODE'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_stitch_motor__v01_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
