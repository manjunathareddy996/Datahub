{{ config(materialized='view') }}

-- MAXIMUS PARTNER wide stage() for BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_ADDRESS_ADDRESS_PROPERTY_PIVOT_VW.
-- 2 key(s), 4 single-active satellite(s).

{%- set yaml_metadata -%}
source_model: 'stg_maximus__pd_party_addr_prop_pv'
hashed_columns:
  LOCATION_HKEY: 'LOCATION_NK'
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF_COMMON_ADDRESS:
    is_hashdiff: true
    columns:
      - 'ADDRESS_LINE_1'
      - 'ADDRESS_LINE_2'
      - 'ADDRESS_LINE_3'
      - 'CARE_OF_NAME'
      - 'CITY'
      - 'COUNTRY_NAME'
      - 'DISTRICT'
      - 'LANDMARK'
      - 'LOCALITY'
      - 'POSTAL_CODE'
      - 'POST_OFFICE_NAME'
      - 'STATE_NAME'
  HASHDIFF_COMMON_CONTACT:
    is_hashdiff: true
    columns:
      - 'ALTERNATE_EMAIL_ADDRESS'
      - 'ALTERNATE_MOBILE_NUMBER'
      - 'EMAIL_ADDRESS'
      - 'FAX_NUMBER'
      - 'LANDLINE_NUMBER'
      - 'MOBILE_NUMBER'
      - 'SOCIALMEDIAHANDLE'
      - 'STD_CODE'
  HASHDIFF_COMMON_GEO:
    is_hashdiff: true
    columns:
      - 'LATITUDE'
      - 'LONGITUDE'
      - 'REGIONCODE'
      - 'REGION_NAME'
  HASHDIFF_LOCATION_PROFILE:
    is_hashdiff: true
    columns:
      - 'LOCATION_NAME'
      - 'LOCATIONTYPE'
derived_columns:
  LOCATION_BK: "case when coalesce(upper(trim(to_varchar(land_mark))), upper(trim(to_varchar(area))), upper(trim(to_varchar(post_office))), upper(trim(to_varchar(city))), upper(trim(to_varchar(state))), upper(trim(to_varchar(pincode)))) is null then null else md5(concat_ws('|', coalesce(upper(trim(to_varchar(land_mark))), ''), coalesce(upper(trim(to_varchar(area))), ''), coalesce(upper(trim(to_varchar(post_office))), ''), coalesce(upper(trim(to_varchar(city))), ''), coalesce(upper(trim(to_varchar(state))), ''), coalesce(upper(trim(to_varchar(pincode))), ''))) end"
  LOCATION_NK: "'HUB_LOCATION|' || (case when coalesce(upper(trim(to_varchar(land_mark))), upper(trim(to_varchar(area))), upper(trim(to_varchar(post_office))), upper(trim(to_varchar(city))), upper(trim(to_varchar(state))), upper(trim(to_varchar(pincode)))) is null then null else md5(concat_ws('|', coalesce(upper(trim(to_varchar(land_mark))), ''), coalesce(upper(trim(to_varchar(area))), ''), coalesce(upper(trim(to_varchar(post_office))), ''), coalesce(upper(trim(to_varchar(city))), ''), coalesce(upper(trim(to_varchar(state))), ''), coalesce(upper(trim(to_varchar(pincode))), ''))) end)"
  PARTY_BK: "foreign_key"
  PARTY_NK: "'HUB_PARTY|' || (foreign_key)"
  LOCALITY: "area"
  CITY: "city"
  LANDMARK: "land_mark"
  POSTAL_CODE: "pincode"
  POST_OFFICE_NAME: "post_office"
  STATE_NAME: "state"
  ADDRESS_LINE_2: "cast(null as varchar)"
  ADDRESS_LINE_1: "cast(null as varchar)"
  CARE_OF_NAME: "cast(null as varchar)"
  ADDRESS_LINE_3: "cast(null as varchar)"
  COUNTRY_NAME: "cast(null as varchar)"
  DISTRICT: "cast(null as varchar)"
  ALTERNATE_MOBILE_NUMBER: "alternate_mob_numberlandline_number"
  SOCIALMEDIAHANDLE: "coalesce(facebook_id, instagram_id, linked_in_id, twitter_id)"
  MOBILE_NUMBER: "whatsapp_no"
  LANDLINE_NUMBER: "cast(null as varchar)"
  EMAIL_ADDRESS: "cast(null as varchar)"
  FAX_NUMBER: "cast(null as varchar)"
  STD_CODE: "cast(null as varchar)"
  ALTERNATE_EMAIL_ADDRESS: "cast(null as varchar)"
  LATITUDE: "geo_coordinate_latitude"
  LONGITUDE: "geo_coordinate_longitude"
  REGION_NAME: "cast(null as varchar)"
  REGIONCODE: "cast(null as varchar)"
  LOCATIONTYPE: "location_type"
  LOCATION_NAME: "cast(null as varchar)"
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_ADDRESS_ADDRESS_PROPERTY_PIVOT_VW'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                     source_model=metadata_dict['source_model'],
                     hashed_columns=metadata_dict['hashed_columns'],
                     derived_columns=metadata_dict['derived_columns']) }}
