-- automate_dv.stage() for SAT_COMMON_GEO, read off central view stitch_v10_party.
-- The key is NULL wherever this satellite has no payload: sat() takes no filter, and it skips a NULL key.
{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model: 'stitch_v10_party'
hashed_columns:
  LOCATION_HKEY: 'LOCATION_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'REGION_NAME'
      - 'URBAN_RURAL_CLASSIFICATION'
      - 'ZONE_CODE'
derived_columns:
  LOCATION_NK: "case when coalesce(COMMON_GEO__REGION_NAME, COMMON_GEO__URBAN_RURAL_CLASSIFICATION, COMMON_GEO__ZONE_CODE) is not null then 'HUB_LOCATION|' || LOCATION_BK end"
  REGION_NAME: 'COMMON_GEO__REGION_NAME'
  URBAN_RURAL_CLASSIFICATION: 'COMMON_GEO__URBAN_RURAL_CLASSIFICATION'
  ZONE_CODE: 'COMMON_GEO__ZONE_CODE'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!stitch_v10_party'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
