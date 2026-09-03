{{ config(materialized='view') }}

-- MAXIMUS PARTNER AUGMENTED (unconfirmed) WIDE stage() for HUB_LOCATION, view 'pd_party_addr_prop_pv'.
-- Serves 1 augmented satellite(s), one HASHDIFF each, from 1
-- column(s) with no faithful home in data_7. The KEY is the standard track's own
-- expression for HUB_LOCATION on this view; the ATTRIBUTE GROUPING is the mapper's
-- proposal and is NOT canonical.

{%- set yaml_metadata -%}
source_model: 'stg_maximus__pd_party_addr_prop_pv'
hashed_columns:
  LOCATION_HKEY: 'LOCATION_NK'
  HASHDIFF_AUG_COMMON_GEO:
    is_hashdiff: true
    columns:
      - 'ALTITUDE'
derived_columns:
  LOCATION_BK: "md5(concat_ws('|', upper(trim(to_varchar(land_mark))), upper(trim(to_varchar(area))), upper(trim(to_varchar(post_office))), upper(trim(to_varchar(city))), upper(trim(to_varchar(state))), upper(trim(to_varchar(pincode)))))"
  LOCATION_NK: "'HUB_LOCATION|' || (md5(concat_ws('|', upper(trim(to_varchar(land_mark))), upper(trim(to_varchar(area))), upper(trim(to_varchar(post_office))), upper(trim(to_varchar(city))), upper(trim(to_varchar(state))), upper(trim(to_varchar(pincode))))))"
  ALTITUDE: "geo_coordinate_altitude"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!pd_party_addr_prop_pv'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                     source_model=metadata_dict['source_model'],
                     hashed_columns=metadata_dict['hashed_columns'],
                     derived_columns=metadata_dict['derived_columns']) }}
