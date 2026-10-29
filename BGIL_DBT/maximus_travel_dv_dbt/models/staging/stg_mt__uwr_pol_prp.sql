{{ config(materialized='view') }}

-- Layer-1 cast for Maximus Travel source view
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS
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
-- Shred lineage carried through deliberately (FOREIGN_KEY, KEY_HASH, PARENT_KEY_HASH, ROOT_HASH, RECORD_HASH, PARENT_RECORD_HASH, PARENT_TABLE_NAME): it appears in no row of the map and
-- the whole sub-document key layer is built on it.

with source as (

    select
    "FOREIGN_KEY" as foreign_key,
    "ROOT_HASH" as root_hash,
    "PARENT_KEY_HASH" as parent_key_hash,
    "PARENT_RECORD_HASH" as parent_record_hash,
    "KEY_HASH" as key_hash,
    "RECORD_HASH" as record_hash,
    "PARENT_TABLE_NAME" as parent_table_name,
    try_to_timestamp_ntz(trim(to_varchar("INC_JOB_CREATED_AT"))) as inc_job_created_at,
    nullif(trim(to_varchar("INC_JOB_ID")), '') as inc_job_id,
    nullif(trim(to_varchar("FILE_NAME")), '') as file_name,
    nullif(trim(to_varchar("FILE_TIMESTAMP")), '') as file_timestamp,
    nullif(trim(to_varchar("BUSINESS_NAME")), '') as business_name,
    nullif(trim(to_varchar("CREATED_BY")), '') as created_by,
    nullif(trim(to_varchar("DATE_OF_BIRTH")), '') as date_of_birth,
    nullif(trim(to_varchar("DOCUMENT_DETAIL")), '') as document_detail,
    nullif(trim(to_varchar("FIRST_NAME")), '') as first_name,
    nullif(trim(to_varchar("GENDER")), '') as gender,
    nullif(trim(to_varchar("LAST_NAME")), '') as last_name,
    nullif(trim(to_varchar("MIDDLE_NAME")), '') as middle_name,
    nullif(trim(to_varchar("NATIONALITY")), '') as nationality,
    nullif(trim(to_varchar("OCCUPATION")), '') as occupation,
    nullif(trim(to_varchar("PARENT_PARTY_CODE")), '') as parent_party_code,
    nullif(trim(to_varchar("PARTY_ADDRESS")), '') as party_address,
    nullif(trim(to_varchar("PARTY_CODE")), '') as party_code,
    nullif(trim(to_varchar("PARTY_END_DATE")), '') as party_end_date,
    nullif(trim(to_varchar("PARTY_LAST_MODIFICATION_DATE")), '') as party_last_modification_date,
    nullif(trim(to_varchar("PARTY_PROPERTY")), '') as party_property,
    nullif(trim(to_varchar("PARTY_RELATION")), '') as party_relation,
    nullif(trim(to_varchar("PARTY_START_DATE")), '') as party_start_date,
    nullif(trim(to_varchar("PARTY_STATUS")), '') as party_status,
    nullif(trim(to_varchar("REGISTRATION_DATE")), '') as registration_date,
    nullif(trim(to_varchar("REGISTRATION_NO")), '') as registration_no,
    nullif(trim(to_varchar("RELATED_PARTY")), '') as related_party,
    nullif(trim(to_varchar("TITLE")), '') as title,
    nullif(trim(to_varchar("TYPE_OF_ORGANIZATION")), '') as type_of_organization,
    nullif(trim(to_varchar("TYPE_OF_PARTY")), '') as type_of_party,
    nullif(trim(to_varchar("PROPOSER_DETAILS")), '') as proposer_details,
    nullif(trim(to_varchar("REC_REFRESH_AT")), '') as rec_refresh_at,
    nullif(trim(to_varchar("REC_REFRESHED_BY")), '') as rec_refreshed_by
    from {{ source('maximus_travel_raw', 'NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS') }}

)

select * from source
