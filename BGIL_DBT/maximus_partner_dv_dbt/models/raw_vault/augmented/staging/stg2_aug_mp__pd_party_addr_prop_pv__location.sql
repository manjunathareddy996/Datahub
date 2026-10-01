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
  LOCATION_BK: "case when coalesce(upper(trim(to_varchar(land_mark))), upper(trim(to_varchar(area))), upper(trim(to_varchar(post_office))), upper(trim(to_varchar(city))), upper(trim(to_varchar(state))), upper(trim(to_varchar(pincode)))) is null then null else md5(concat_ws('|', coalesce(upper(trim(to_varchar(land_mark))), ''), coalesce(upper(trim(to_varchar(area))), ''), coalesce(upper(trim(to_varchar(post_office))), ''), coalesce(upper(trim(to_varchar(city))), ''), coalesce(upper(trim(to_varchar(state))), ''), coalesce(upper(trim(to_varchar(pincode))), ''))) end"
  LOCATION_NK: "'HUB_LOCATION|' || (case when coalesce(upper(trim(to_varchar(land_mark))), upper(trim(to_varchar(area))), upper(trim(to_varchar(post_office))), upper(trim(to_varchar(city))), upper(trim(to_varchar(state))), upper(trim(to_varchar(pincode)))) is null then null else md5(concat_ws('|', coalesce(upper(trim(to_varchar(land_mark))), ''), coalesce(upper(trim(to_varchar(area))), ''), coalesce(upper(trim(to_varchar(post_office))), ''), coalesce(upper(trim(to_varchar(city))), ''), coalesce(upper(trim(to_varchar(state))), ''), coalesce(upper(trim(to_varchar(pincode))), ''))) end)"
  ALTITUDE: "geo_coordinate_altitude"
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_pd_party_addr_prop_pv'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                     source_model=metadata_dict['source_model'],
                     hashed_columns=metadata_dict['hashed_columns'],
                     derived_columns=metadata_dict['derived_columns']) }}
