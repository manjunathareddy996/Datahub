-- automate_dv.stage() for SAT_COMMON_ADDRESS, read off central view stitch_v12_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v12_party'
hashed_columns:
  LOCATION_HKEY: 'LOCATION_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ADDRESS_LINE_1'
      - 'ADDRESS_LINE_2'
      - 'ADDRESS_LINE_3'
      - 'BUILDING_NAME'
      - 'CARE_OF_NAME'
      - 'CITY'
      - 'COUNTRY_CODE'
      - 'COUNTRY_NAME'
      - 'DISTRICT'
      - 'DOOR_NUMBER'
      - 'FLOOR_NUMBER'
      - 'POSTAL_CODE'
      - 'STATE_CODE'
      - 'STATE_NAME'
      - 'STREET_NAME'
derived_columns:
  LOCATION_NK: "case when coalesce(COMMON_ADDRESS__ADDRESS_LINE_1, COMMON_ADDRESS__ADDRESS_LINE_2, COMMON_ADDRESS__ADDRESS_LINE_3, COMMON_ADDRESS__BUILDING_NAME, COMMON_ADDRESS__CARE_OF_NAME, COMMON_ADDRESS__CITY, COMMON_ADDRESS__COUNTRY_CODE, COMMON_ADDRESS__COUNTRY_NAME, COMMON_ADDRESS__DISTRICT, COMMON_ADDRESS__DOOR_NUMBER, COMMON_ADDRESS__FLOOR_NUMBER, COMMON_ADDRESS__POSTAL_CODE, COMMON_ADDRESS__STATE_CODE, COMMON_ADDRESS__STATE_NAME, COMMON_ADDRESS__STREET_NAME) is not null then 'HUB_LOCATION|' || LOCATION_BK end"
  ADDRESS_LINE_1: 'COMMON_ADDRESS__ADDRESS_LINE_1'
  ADDRESS_LINE_2: 'COMMON_ADDRESS__ADDRESS_LINE_2'
  ADDRESS_LINE_3: 'COMMON_ADDRESS__ADDRESS_LINE_3'
  BUILDING_NAME: 'COMMON_ADDRESS__BUILDING_NAME'
  CARE_OF_NAME: 'COMMON_ADDRESS__CARE_OF_NAME'
  CITY: 'COMMON_ADDRESS__CITY'
  COUNTRY_CODE: 'COMMON_ADDRESS__COUNTRY_CODE'
  COUNTRY_NAME: 'COMMON_ADDRESS__COUNTRY_NAME'
  DISTRICT: 'COMMON_ADDRESS__DISTRICT'
  DOOR_NUMBER: 'COMMON_ADDRESS__DOOR_NUMBER'
  FLOOR_NUMBER: 'COMMON_ADDRESS__FLOOR_NUMBER'
  POSTAL_CODE: 'COMMON_ADDRESS__POSTAL_CODE'
  STATE_CODE: 'COMMON_ADDRESS__STATE_CODE'
  STATE_NAME: 'COMMON_ADDRESS__STATE_NAME'
  STREET_NAME: 'COMMON_ADDRESS__STREET_NAME'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v12_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
