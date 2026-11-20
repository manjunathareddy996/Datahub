-- automate_dv.stage() for SAT_LOCATION_PROFILE, read off central view stitch_mxm__v08_location.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_mxm__v08_location'
hashed_columns:
  LOCATION_HKEY: 'LOCATION_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'LOCATION_NAME'
      - 'LOCATION_TYPE'
derived_columns:
  LOCATION_NK: "case when coalesce(LOCATION_PROFILE__LOCATION_NAME, LOCATION_PROFILE__LOCATION_TYPE) is not null then 'HUB_LOCATION|' || LOCATION_BK end"
  LOCATION_NAME: 'LOCATION_PROFILE__LOCATION_NAME'
  LOCATION_TYPE: 'LOCATION_PROFILE__LOCATION_TYPE'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_stitch_mxm__v08_location'
  SOURCE_SYSTEM: '!MAXIMUS_MOTOR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
