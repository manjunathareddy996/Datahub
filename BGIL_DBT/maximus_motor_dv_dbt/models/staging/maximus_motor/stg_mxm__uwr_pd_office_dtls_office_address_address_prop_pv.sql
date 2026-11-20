-- Staging for source view MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_OFFICE_DETAILS_OFFICE_ADDRESS_ADDRESS_PROPERTY_PIVOT_VW. Every column trimmed varchar, including the shred keys
-- KEY_HASH / PARENT_KEY_HASH / FOREIGN_KEY that the central views join on.
with source as (

    select
        nullif(trim(to_varchar("FOREIGN_KEY")), '') as foreign_key,
        nullif(trim(to_varchar("PARENT_RECORD_HASH")), '') as parent_record_hash,
        nullif(trim(to_varchar("PARENT_KEY_HASH")), '') as parent_key_hash,
        nullif(trim(to_varchar("KEY_HASH")), '') as key_hash,
        nullif(trim(to_varchar("INC_JOB_CREATED_AT")), '') as inc_job_created_at,
        "REC_REFRESH_AT"::timestamp_ntz as rec_refresh_at,
        nullif(trim(to_varchar("ALTERNATE_MOB_NUMBERLANDLINE_NUMBER")), '') as alternate_mob_numberlandline_number,
        nullif(trim(to_varchar("AREA")), '') as area,
        nullif(trim(to_varchar("FACEBOOK_ID")), '') as facebook_id,
        nullif(trim(to_varchar("GEO_COORDINATE_ALTITUDE")), '') as geo_coordinate_altitude,
        nullif(trim(to_varchar("GEO_COORDINATE_LATITUDE")), '') as geo_coordinate_latitude,
        nullif(trim(to_varchar("GEO_COORDINATE_LONGITUDE")), '') as geo_coordinate_longitude,
        nullif(trim(to_varchar("INSTAGRAM_ID")), '') as instagram_id,
        nullif(trim(to_varchar("LAND_MARK")), '') as land_mark,
        nullif(trim(to_varchar("LINKED_IN_ID")), '') as linked_in_id,
        nullif(trim(to_varchar("LOCATION_TYPE")), '') as location_type,
        nullif(trim(to_varchar("POST_OFFICE")), '') as post_office,
        nullif(trim(to_varchar("TWITTER_ID")), '') as twitter_id,
        nullif(trim(to_varchar("WHATSAPP_NO")), '') as whatsapp_no
    from {{ source('maximus_motor_raw', 'MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_OFFICE_DETAILS_OFFICE_ADDRESS_ADDRESS_PROPERTY_PIVOT_VW') }}

)

select * from source
