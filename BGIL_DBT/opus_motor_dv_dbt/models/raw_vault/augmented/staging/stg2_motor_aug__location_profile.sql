-- automate_dv.stage() for SAT_AUG_LOCATION_PROFILE, read off central view stitch_motor__v10_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_motor__v10_party'
hashed_columns:
  LOCATION_HKEY: 'LOCATION_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'DWELLING_DESCRIPTION'
      - 'YEARS_AT_LOCATION'
derived_columns:
  LOCATION_NK: "case when coalesce(AUG_LOCATION_PROFILE__DWELLING_DESCRIPTION, AUG_LOCATION_PROFILE__YEARS_AT_LOCATION) is not null then 'HUB_LOCATION|' || LOCATION_BK end"
  DWELLING_DESCRIPTION: 'AUG_LOCATION_PROFILE__DWELLING_DESCRIPTION'
  YEARS_AT_LOCATION: 'AUG_LOCATION_PROFILE__YEARS_AT_LOCATION'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_motor__v10_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
