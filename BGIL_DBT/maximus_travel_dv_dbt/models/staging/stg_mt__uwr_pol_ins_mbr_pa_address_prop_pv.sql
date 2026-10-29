{{ config(materialized='view') }}

-- Layer-1 cast for Maximus Travel source view
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS_PARTY_ADDRESS_ADDRESS_PROPERTY_PIVOT_VW
--
-- This view CARRIES MAP ROWS; it is a start view for the key and payload layers.
--
-- Typing: flattened JSON shreds and pivoted EAV views with no source type list, so every
-- value is cast to a trimmed VARCHAR. An absent EAV label on this feed is the EMPTY
-- STRING, not NULL, which is why each value is nullif(trim(...),'') here and why every
-- key is guarded again in mt_keyrules.render_key().
--
-- Every source identifier is DOUBLE-QUOTED (directive D-QUOTE): seven column names in
-- this feed begin with a digit and do not compile unquoted. Their aliases carry a col_
-- prefix for the same reason -- an alias may not begin with a digit either.
--
-- Shred lineage carried through deliberately (FOREIGN_KEY, KEY_HASH, PARENT_KEY_HASH, PARENT_RECORD_HASH): it appears in no row of the map and
-- the whole sub-document key layer is built on it.

with source as (

    select
    "FOREIGN_KEY" as foreign_key,
    "PARENT_RECORD_HASH" as parent_record_hash,
    "PARENT_KEY_HASH" as parent_key_hash,
    "KEY_HASH" as key_hash,
    try_to_timestamp_ntz(trim(to_varchar("INC_JOB_CREATED_AT"))) as inc_job_created_at,
    nullif(trim(to_varchar("REC_REFRESH_AT")), '') as rec_refresh_at,
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
    nullif(trim(to_varchar("WHATSAPP_NO")), '') as whatsapp_no
    from {{ source('maximus_travel_raw', 'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS_PARTY_ADDRESS_ADDRESS_PROPERTY_PIVOT_VW') }}

)

select * from source
