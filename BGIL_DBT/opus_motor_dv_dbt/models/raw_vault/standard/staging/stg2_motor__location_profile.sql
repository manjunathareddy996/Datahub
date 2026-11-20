-- automate_dv.stage() for SAT_LOCATION_PROFILE, read off central view stitch_motor__v07_location.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v07_location'
hashed_columns:
  LOCATION_HKEY: 'LOCATION_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CONNECTIVITY_GRADE'
      - 'LOCATION_NAME'
derived_columns:
  LOCATION_NK: "case when coalesce(LOCATION_PROFILE__CONNECTIVITY_GRADE, LOCATION_PROFILE__LOCATION_NAME) is not null then 'HUB_LOCATION|' || LOCATION_BK end"
  CONNECTIVITY_GRADE: 'LOCATION_PROFILE__CONNECTIVITY_GRADE'
  LOCATION_NAME: 'LOCATION_PROFILE__LOCATION_NAME'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_stitch_motor__v07_location'
  SOURCE_SYSTEM: '!OPUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
