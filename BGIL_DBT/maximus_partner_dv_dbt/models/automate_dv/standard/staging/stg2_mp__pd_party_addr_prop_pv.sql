{{ config(materialized='view') }}

-- MAXIMUS PARTNER wide stage() for BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_ADDRESS_ADDRESS_PROPERTY_PIVOT_VW_2_1.
-- 2 key(s), 4 single-active satellite(s).

{%- set yaml_metadata -%}
source_model: 'stg_maximus__pd_party_addr_prop_pv'
hashed_columns:
  LOCATION_HKEY: 'LOCATION_NK'
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF_COMMON_ADDRESS:
    is_hashdiff: true
    columns:
      - 'ADDRESSLINE1'
      - 'ADDRESSLINE2'
      - 'ADDRESSLINE3'
      - 'CAREOFNAME'
      - 'CITY'
      - 'COUNTRYNAME'
      - 'DISTRICT'
      - 'LANDMARK'
      - 'LOCALITY'
      - 'POSTALCODE'
      - 'POSTOFFICENAME'
      - 'STATENAME'
  HASHDIFF_COMMON_CONTACT:
    is_hashdiff: true
    columns:
      - 'ALTERNATEEMAILADDRESS'
      - 'ALTERNATEMOBILENUMBER'
      - 'EMAILADDRESS'
      - 'FAXNUMBER'
      - 'LANDLINENUMBER'
      - 'MOBILENUMBER'
      - 'SOCIALMEDIAHANDLE'
      - 'STDCODE'
  HASHDIFF_COMMON_GEO:
    is_hashdiff: true
    columns:
      - 'LATITUDE'
      - 'LONGITUDE'
      - 'REGIONCODE'
      - 'REGIONNAME'
  HASHDIFF_LOCATION_PROFILE:
    is_hashdiff: true
    columns:
      - 'LOCATIONNAME'
      - 'LOCATIONTYPE'
derived_columns:
  LOCATION_BK: "md5(concat_ws('|', upper(trim(to_varchar(land_mark))), upper(trim(to_varchar(area))), upper(trim(to_varchar(post_office))), upper(trim(to_varchar(city))), upper(trim(to_varchar(state))), upper(trim(to_varchar(pincode)))))"
  LOCATION_NK: "'HUB_LOCATION|' || (md5(concat_ws('|', upper(trim(to_varchar(land_mark))), upper(trim(to_varchar(area))), upper(trim(to_varchar(post_office))), upper(trim(to_varchar(city))), upper(trim(to_varchar(state))), upper(trim(to_varchar(pincode))))))"
  PARTY_BK: "foreign_key"
  PARTY_NK: "'HUB_PARTY|' || (foreign_key)"
  LOCALITY: "area"
  CITY: "city"
  LANDMARK: "land_mark"
  POSTALCODE: "pincode"
  POSTOFFICENAME: "post_office"
  STATENAME: "state"
  ADDRESSLINE2: "cast(null as varchar)"
  ADDRESSLINE1: "cast(null as varchar)"
  CAREOFNAME: "cast(null as varchar)"
  ADDRESSLINE3: "cast(null as varchar)"
  COUNTRYNAME: "cast(null as varchar)"
  DISTRICT: "cast(null as varchar)"
  ALTERNATEMOBILENUMBER: "alternate_mob_numberlandline_number"
  SOCIALMEDIAHANDLE: "coalesce(facebook_id, instagram_id, linked_in_id, twitter_id)"
  MOBILENUMBER: "whatsapp_no"
  LANDLINENUMBER: "cast(null as varchar)"
  EMAILADDRESS: "cast(null as varchar)"
  FAXNUMBER: "cast(null as varchar)"
  STDCODE: "cast(null as varchar)"
  ALTERNATEEMAILADDRESS: "cast(null as varchar)"
  LATITUDE: "geo_coordinate_latitude"
  LONGITUDE: "geo_coordinate_longitude"
  REGIONNAME: "cast(null as varchar)"
  REGIONCODE: "cast(null as varchar)"
  LOCATIONTYPE: "location_type"
  LOCATIONNAME: "cast(null as varchar)"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_ADDRESS_ADDRESS_PROPERTY_PIVOT_VW_2_1'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                     source_model=metadata_dict['source_model'],
                     hashed_columns=metadata_dict['hashed_columns'],
                     derived_columns=metadata_dict['derived_columns']) }}
