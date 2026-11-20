-- automate_dv.stage() for SAT_COMMON_ADMIN_GEOGRAPHY, read off central view stitch_mxm__v09_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v09_party'
hashed_columns:
  LOCATION_HKEY: 'LOCATION_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'COUNTRY_CODE'
      - 'DISTRICT_NAME'
      - 'PIN_CODE'
      - 'STATE_CODE'
      - 'STATE_NAME'
      - 'TALUKA_NAME'
derived_columns:
  LOCATION_NK: "case when coalesce(COMMON_ADMIN_GEOGRAPHY__COUNTRY_CODE, COMMON_ADMIN_GEOGRAPHY__DISTRICT_NAME, COMMON_ADMIN_GEOGRAPHY__PIN_CODE, COMMON_ADMIN_GEOGRAPHY__STATE_CODE, COMMON_ADMIN_GEOGRAPHY__STATE_NAME, COMMON_ADMIN_GEOGRAPHY__TALUKA_NAME) is not null then 'HUB_LOCATION|' || LOCATION_BK end"
  COUNTRY_CODE: 'COMMON_ADMIN_GEOGRAPHY__COUNTRY_CODE'
  DISTRICT_NAME: 'COMMON_ADMIN_GEOGRAPHY__DISTRICT_NAME'
  PIN_CODE: 'COMMON_ADMIN_GEOGRAPHY__PIN_CODE'
  STATE_CODE: 'COMMON_ADMIN_GEOGRAPHY__STATE_CODE'
  STATE_NAME: 'COMMON_ADMIN_GEOGRAPHY__STATE_NAME'
  TALUKA_NAME: 'COMMON_ADMIN_GEOGRAPHY__TALUKA_NAME'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v09_party'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
