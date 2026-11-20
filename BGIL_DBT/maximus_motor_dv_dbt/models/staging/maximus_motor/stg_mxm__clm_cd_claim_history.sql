-- Staging for source view MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_HISTORY. Every column trimmed varchar, including the shred keys
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
        nullif(trim(to_varchar("CLAIM_REQUIREMENT_STATUS")), '') as claim_requirement_status,
        nullif(trim(to_varchar("CLAIM_STATUS")), '') as claim_status,
        nullif(trim(to_varchar("CLAIM_SUB_STATUS")), '') as claim_sub_status,
        nullif(trim(to_varchar("CREATED_DATE")), '') as created_date,
        nullif(trim(to_varchar("DELAY_REASON")), '') as delay_reason,
        nullif(trim(to_varchar("DETAILS")), '') as details,
        nullif(trim(to_varchar("EVENT")), '') as event,
        nullif(trim(to_varchar("EVENT_DATE")), '') as event_date,
        nullif(trim(to_varchar("EVENT_DESCRIPTION")), '') as event_description,
        nullif(trim(to_varchar("PPI_INDICATOR")), '') as ppi_indicator,
        nullif(trim(to_varchar("REFERENCE_NUMBER")), '') as reference_number,
        nullif(trim(to_varchar("REMARKS")), '') as remarks,
        nullif(trim(to_varchar("SCRUTINY_STATUS")), '') as scrutiny_status,
        nullif(trim(to_varchar("SURVEY_REPORT_STATUS")), '') as survey_report_status,
        nullif(trim(to_varchar("TYPE")), '') as type,
        nullif(trim(to_varchar("USER_CODE")), '') as user_code,
        nullif(trim(to_varchar("KEY_HASH")), '') as key_hash,
        nullif(trim(to_varchar("RECORD_HASH")), '') as record_hash,
        nullif(trim(to_varchar("CLAIM_HISTORY")), '') as claim_history,
        "REC_REFRESH_AT"::timestamp_ntz as rec_refresh_at,
        nullif(trim(to_varchar("REC_REFRESHED_BY")), '') as rec_refreshed_by,
        nullif(trim(to_varchar("PARENT_TABLE_NAME")), '') as parent_table_name
    from {{ source('maximus_motor_raw', 'MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_HISTORY') }}

)

select * from source
