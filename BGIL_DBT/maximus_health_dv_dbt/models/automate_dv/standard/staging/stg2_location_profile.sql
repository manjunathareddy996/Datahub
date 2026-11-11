-- automate_dv.stage() for SAT_LOCATION_PROFILE, read off central view stitch_v04_claim.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v04_claim'
hashed_columns:
  LOCATION_HKEY: 'LOCATION_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'LOCATION_NAME'
derived_columns:
  LOCATION_NK: "case when LOCATION_PROFILE__LOCATION_NAME is not null then 'HUB_LOCATION|' || LOCATION_BK end"
  LOCATION_NAME: 'LOCATION_PROFILE__LOCATION_NAME'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v04_claim'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
