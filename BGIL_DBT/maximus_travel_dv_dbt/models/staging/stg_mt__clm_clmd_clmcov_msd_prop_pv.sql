{{ config(materialized='view') }}

-- Layer-1 cast for Maximus Travel source view
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_COVER_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
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
    nullif(trim(to_varchar("1ST_REMINDER_DATE")), '') as col_1st_reminder_date,
    nullif(trim(to_varchar("2ND_REMINDER_DATE")), '') as col_2nd_reminder_date,
    nullif(trim(to_varchar("3RD_REMINDER_DATE")), '') as col_3rd_reminder_date,
    nullif(trim(to_varchar("CITY")), '') as city,
    nullif(trim(to_varchar("CLOSURE_DATE")), '') as closure_date,
    nullif(trim(to_varchar("COURIER_NAME")), '') as courier_name,
    nullif(trim(to_varchar("COVER_NAME")), '') as cover_name,
    nullif(trim(to_varchar("COVER_TAKEN")), '') as cover_taken,
    nullif(trim(to_varchar("DOCUMENT_DETAILS")), '') as document_details,
    nullif(trim(to_varchar("DOCUMENT_RECEIVED_DATE")), '') as document_received_date,
    nullif(trim(to_varchar("DOCUMENT_TYPE_INWARD")), '') as document_type_inward,
    nullif(trim(to_varchar("INTIMATION_DATE")), '') as intimation_date,
    nullif(trim(to_varchar("INWARD_DATE")), '') as inward_date,
    nullif(trim(to_varchar("INWARD_NUMBER")), '') as inward_number,
    nullif(trim(to_varchar("LAST_UPDATED_BY")), '') as last_updated_by,
    nullif(trim(to_varchar("MODE_OF_INWARD")), '') as mode_of_inward,
    nullif(trim(to_varchar("PIN_CODE")), '') as pin_code,
    nullif(trim(to_varchar("POD_NUMBER")), '') as pod_number,
    nullif(trim(to_varchar("REMARKS")), '') as remarks,
    nullif(trim(to_varchar("REQUIRED_FROM")), '') as required_from,
    nullif(trim(to_varchar("REQUIREMENT_STATUS")), '') as requirement_status,
    nullif(trim(to_varchar("REQUIREMENT_TYPE_NAME")), '') as requirement_type_name,
    nullif(trim(to_varchar("RESPONSE")), '') as response,
    nullif(trim(to_varchar("SENDER_NAME")), '') as sender_name,
    nullif(trim(to_varchar("SPECIAL_ENCLOSURES_DETAILS")), '') as special_enclosures_details,
    nullif(trim(to_varchar("SPECIAL_ENCLOSURES_FLAG")), '') as special_enclosures_flag,
    nullif(trim(to_varchar("STATE")), '') as state
    from {{ source('maximus_travel_raw', 'NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_COVER_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW') }}

)

select * from source
