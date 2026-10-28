{{ config(materialized='view') }}

-- Layer-1 cast for Maximus Travel V2 source view
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS
--
-- This view CARRIES MAP ROWS; it is a start view for the key and payload layers.
--
-- Typing: flattened JSON shreds and pivoted EAV views with no source type list, so every
-- value is cast to a trimmed VARCHAR. An absent EAV label on this feed is the EMPTY
-- STRING, not NULL, which is why each value is nullif(trim(...),'') here and why every
-- key is guarded again in mtv2_keyrules.render_key().
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
    nullif(trim(to_varchar("CLAIM_ATTRIBUTE")), '') as claim_attribute,
    nullif(trim(to_varchar("CLAIMBRANCH")), '') as claimbranch,
    nullif(trim(to_varchar("CLAIM_BUCKET")), '') as claim_bucket,
    nullif(trim(to_varchar("CLAIM_COVER")), '') as claim_cover,
    nullif(trim(to_varchar("CLAIM_EVENT_FOLLOWUP")), '') as claim_event_followup,
    nullif(trim(to_varchar("CLAIM_HISTORY")), '') as claim_history,
    nullif(trim(to_varchar("CLAIMNO")), '') as claimno,
    nullif(trim(to_varchar("CLAIM_NOTES")), '') as claim_notes,
    nullif(trim(to_varchar("CLAIM_NOTIFICATION_DETAILS")), '') as claim_notification_details,
    nullif(trim(to_varchar("CLAIM_PARTY")), '') as claim_party,
    nullif(trim(to_varchar("CLAIM_PAYMENT")), '') as claim_payment,
    nullif(trim(to_varchar("CLAIM_RESERVE")), '') as claim_reserve,
    nullif(trim(to_varchar("CLAIM_RISK")), '') as claim_risk,
    nullif(trim(to_varchar("CLAIM_RISK_PARTY")), '') as claim_risk_party,
    nullif(trim(to_varchar("CLAIMSTATUS")), '') as claimstatus,
    nullif(trim(to_varchar("CLAIM_SURVEYOR_DEPUTATION")), '') as claim_surveyor_deputation,
    nullif(trim(to_varchar("CLAIM_TRIGGER_DETAILS")), '') as claim_trigger_details,
    nullif(trim(to_varchar("DOCUMENT_DETAILS")), '') as document_details,
    nullif(trim(to_varchar("INTIMATIONDATE")), '') as intimationdate,
    nullif(trim(to_varchar("LOSSDATE")), '') as lossdate,
    nullif(trim(to_varchar("LOSSDESC")), '') as lossdesc,
    nullif(trim(to_varchar("NET_ASSESSED_AMOUNT")), '') as net_assessed_amount,
    nullif(trim(to_varchar("POLICYNO")), '') as policyno,
    nullif(trim(to_varchar("PRIMARYCAUSECODE")), '') as primarycausecode,
    nullif(trim(to_varchar("PRIMARYCAUSEDESC")), '') as primarycausedesc,
    nullif(trim(to_varchar("SAVING_AMOUNT")), '') as saving_amount,
    nullif(trim(to_varchar("SECONDARYCAUSECODE")), '') as secondarycausecode,
    nullif(trim(to_varchar("SECONDARYCAUSEDESC")), '') as secondarycausedesc,
    nullif(trim(to_varchar("STATUSCHANGEDATE")), '') as statuschangedate,
    nullif(trim(to_varchar("SUBCLAIMNO")), '') as subclaimno,
    nullif(trim(to_varchar("VAHAN_REGISTRATION_VERIFIED")), '') as vahan_registration_verified,
    nullif(trim(to_varchar("CLAIM_DETAILS")), '') as claim_details,
    nullif(trim(to_varchar("REC_REFRESH_AT")), '') as rec_refresh_at,
    nullif(trim(to_varchar("REC_REFRESHED_BY")), '') as rec_refreshed_by,
    nullif(trim(to_varchar("NO_OF_DAYS_AVAILED_CONV")), '') as no_of_days_availed_conv
    from {{ source('maximus_travel_v2_raw', 'NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS') }}

)

select * from source
