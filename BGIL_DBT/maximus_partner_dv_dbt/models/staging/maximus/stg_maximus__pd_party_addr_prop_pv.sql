{{ config(materialized='view') }}

-- MAXIMUS PARTNER layer-1 cast for BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_ADDRESS_ADDRESS_PROPERTY_PIVOT_VW_2_1.

with source as (

    select
    nullif(trim(to_varchar("ALTERNATE_MOB_NUMBERLANDLINE_NUMBER")), '') as alternate_mob_numberlandline_number,
    nullif(trim(to_varchar("AREA")), '') as area,
    nullif(trim(to_varchar("CITY")), '') as city,
    nullif(trim(to_varchar("FACEBOOK_ID")), '') as facebook_id,
    nullif(trim(to_varchar("GEO_COORDINATE_ALTITUDE")), '') as geo_coordinate_altitude,
    nullif(trim(to_varchar("GEO_COORDINATE_LATITUDE")), '') as geo_coordinate_latitude,
    nullif(trim(to_varchar("GEO_COORDINATE_LONGITUDE")), '') as geo_coordinate_longitude,
    nullif(trim(to_varchar("INSTAGRAM_ID")), '') as instagram_id,
    nullif(trim(to_varchar("LAND_MARK")), '') as land_mark,
    nullif(trim(to_varchar("LINKED_IN_ID")), '') as linked_in_id,
    nullif(trim(to_varchar("LOCATION_TYPE")), '') as location_type,
    nullif(trim(to_varchar("PINCODE")), '') as pincode,
    nullif(trim(to_varchar("POST_OFFICE")), '') as post_office,
    nullif(trim(to_varchar("STATE")), '') as state,
    nullif(trim(to_varchar("TWITTER_ID")), '') as twitter_id,
    nullif(trim(to_varchar("WHATSAPP_NO")), '') as whatsapp_no,
    nullif(trim(to_varchar("FOREIGN_KEY")), '') as foreign_key,
    nullif(trim(to_varchar("KEY_HASH")), '') as key_hash,
    nullif(trim(to_varchar("PARENT_KEY_HASH")), '') as parent_key_hash
    from {{ source('maximus_partner', 'BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_ADDRESS_ADDRESS_PROPERTY_PIVOT_VW_2_1') }}

)

select * from source
