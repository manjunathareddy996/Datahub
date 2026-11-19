-- Staging for source view MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_EVENT_FOLLOWUP. Every column trimmed varchar, including the shred keys
-- KEY_HASH / PARENT_KEY_HASH / FOREIGN_KEY that the central views join on.
with source as (

    select
        nullif(trim(to_varchar("INC_JOB_CREATED_AT")), '') as inc_job_created_at,
        nullif(trim(to_varchar("INC_JOB_ID")), '') as inc_job_id,
        nullif(trim(to_varchar("FILE_NAME")), '') as file_name,
        nullif(trim(to_varchar("FILE_TIMESTAMP")), '') as file_timestamp,
        nullif(trim(to_varchar("FOREIGN_KEY")), '') as foreign_key,
        nullif(trim(to_varchar("ROOT_HASH")), '') as root_hash,
        nullif(trim(to_varchar("PARENT_KEY_HASH")), '') as parent_key_hash,
        nullif(trim(to_varchar("PARENT_RECORD_HASH")), '') as parent_record_hash,
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
        nullif(trim(to_varchar("KEY_HASH")), '') as key_hash,
        nullif(trim(to_varchar("RECORD_HASH")), '') as record_hash,
        nullif(trim(to_varchar("CLAIM_EVENT_FOLLOWUP")), '') as claim_event_followup,
        "REC_REFRESH_AT"::timestamp_ntz as rec_refresh_at,
        nullif(trim(to_varchar("REC_REFRESHED_BY")), '') as rec_refreshed_by,
        nullif(trim(to_varchar("PARENT_TABLE_NAME")), '') as parent_table_name
    from {{ source('maximus_motor_raw', 'MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_EVENT_FOLLOWUP') }}

)

select * from source
