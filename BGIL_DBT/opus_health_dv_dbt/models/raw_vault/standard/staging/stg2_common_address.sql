-- automate_dv.stage() for SAT_COMMON_ADDRESS, read off central view stitch_v11_claim.
-- The key is NULL wherever this satellite has no payload: automate_dv.sat() takes
-- no filter, and a NULL key is the one row it is guaranteed to skip.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v11_claim'
hashed_columns:
  LOCATION_HKEY: 'LOCATION_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ADDRESS_LINE_1'
      - 'ADDRESS_LINE_2'
      - 'BUILDING_NAME'
      - 'CITY'
      - 'COUNTRY_NAME'
      - 'LOCALITY'
      - 'POSTAL_CODE'
      - 'STATE_CODE'
      - 'STATE_NAME'
      - 'STREET_NAME'
derived_columns:
  LOCATION_NK: "case when coalesce(COMMON_ADDRESS__ADDRESS_LINE_1, COMMON_ADDRESS__ADDRESS_LINE_2, COMMON_ADDRESS__BUILDING_NAME, COMMON_ADDRESS__CITY, COMMON_ADDRESS__COUNTRY_NAME, COMMON_ADDRESS__LOCALITY, COMMON_ADDRESS__POSTAL_CODE, COMMON_ADDRESS__STATE_CODE, COMMON_ADDRESS__STATE_NAME, COMMON_ADDRESS__STREET_NAME) is not null then 'HUB_LOCATION|' || LOCATION_BK end"
  ADDRESS_LINE_1: 'COMMON_ADDRESS__ADDRESS_LINE_1'
  ADDRESS_LINE_2: 'COMMON_ADDRESS__ADDRESS_LINE_2'
  BUILDING_NAME: 'COMMON_ADDRESS__BUILDING_NAME'
  CITY: 'COMMON_ADDRESS__CITY'
  COUNTRY_NAME: 'COMMON_ADDRESS__COUNTRY_NAME'
  LOCALITY: 'COMMON_ADDRESS__LOCALITY'
  POSTAL_CODE: 'COMMON_ADDRESS__POSTAL_CODE'
  STATE_CODE: 'COMMON_ADDRESS__STATE_CODE'
  STATE_NAME: 'COMMON_ADDRESS__STATE_NAME'
  STREET_NAME: 'COMMON_ADDRESS__STREET_NAME'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v11_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
