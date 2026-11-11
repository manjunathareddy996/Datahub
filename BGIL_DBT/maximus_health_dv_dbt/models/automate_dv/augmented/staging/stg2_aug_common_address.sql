-- automate_dv.stage() for SAT_AUG_COMMON_ADDRESS, read off central view stitch_v10_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v10_party'
hashed_columns:
  LOCATION_HKEY: 'LOCATION_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'FULL_ADDRESS_TEXT'
derived_columns:
  LOCATION_NK: "case when AUG_COMMON_ADDRESS__FULL_ADDRESS_TEXT is not null then 'HUB_LOCATION|' || LOCATION_BK end"
  FULL_ADDRESS_TEXT: 'AUG_COMMON_ADDRESS__FULL_ADDRESS_TEXT'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v10_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
