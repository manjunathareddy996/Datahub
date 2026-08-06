{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL stage() pass for stitch_shared__common_admin_geography_common_geo -- serves SAT_COMMON_ADMIN_GEOGRAPHY, SAT_COMMON_GEO.
-- LOCATION_HKEY hashed once here (namespaced: 'HUB_LOCATION|' || raw key).

{%- set yaml_metadata -%}
source_model: 'stitch_shared__common_admin_geography_common_geo'
hashed_columns:
  LOCATION_HKEY: 'LOCATION_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PINCODE'
      - 'REGIONCODE'
      - 'REGIONNAME'
      - 'SUBZONECODE'
      - 'ZONECODE'
derived_columns:
  LOCATION_NK: "'HUB_LOCATION|' || PARENT_BK"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
