{{ config(materialized='view') }}

-- Layer-1 cast for Maximus Travel source view
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_EVENT_FOLLOWUP
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
    nullif(trim(to_varchar("ASSIGNED_PERSONAL")), '') as assigned_personal,
    nullif(trim(to_varchar("CLAIM_FOLLOWUP_STATUS")), '') as claim_followup_status,
    nullif(trim(to_varchar("CREATED_BY")), '') as created_by,
    nullif(trim(to_varchar("CREATED_DATE")), '') as created_date,
    nullif(trim(to_varchar("DESCRIPTION_REMARKS")), '') as description_remarks,
    nullif(trim(to_varchar("EVENT_CODE")), '') as event_code,
    nullif(trim(to_varchar("EVENT_EFFECTIVE_DATE")), '') as event_effective_date,
    nullif(trim(to_varchar("FOLLOWUP_TIMESTAMP")), '') as followup_timestamp,
    nullif(trim(to_varchar("JOB_STATUS")), '') as job_status,
    nullif(trim(to_varchar("KEYWORD")), '') as keyword,
    nullif(trim(to_varchar("LAST_UPDATED_BY")), '') as last_updated_by,
    nullif(trim(to_varchar("LAST_UPDATED_DATE")), '') as last_updated_date,
    nullif(trim(to_varchar("PRIORITY_INDICATOR")), '') as priority_indicator,
    nullif(trim(to_varchar("CLAIM_EVENT_FOLLOWUP")), '') as claim_event_followup,
    nullif(trim(to_varchar("REC_REFRESH_AT")), '') as rec_refresh_at,
    nullif(trim(to_varchar("REC_REFRESHED_BY")), '') as rec_refreshed_by
    from {{ source('maximus_travel_raw', 'NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_EVENT_FOLLOWUP') }}

)

select * from source
