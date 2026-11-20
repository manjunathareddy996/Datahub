-- Staging for source view MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_SURVEYOR_DEPUTATION. Every column trimmed varchar, including the shred keys
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
        nullif(trim(to_varchar("CDC_NUMBER")), '') as cdc_number,
        nullif(trim(to_varchar("CDC_STATUS")), '') as cdc_status,
        nullif(trim(to_varchar("CONFIRMATION_DATE")), '') as confirmation_date,
        nullif(trim(to_varchar("DEPUTATION_NUMBER")), '') as deputation_number,
        nullif(trim(to_varchar("NOTIFICATION_DATE")), '') as notification_date,
        nullif(trim(to_varchar("REPAIRER_CODE")), '') as repairer_code,
        nullif(trim(to_varchar("SURVEYOR_CODE")), '') as surveyor_code,
        nullif(trim(to_varchar("SURVEY_STATUS")), '') as survey_status,
        nullif(trim(to_varchar("SURVEY_TYPE")), '') as survey_type,
        nullif(trim(to_varchar("KEY_HASH")), '') as key_hash,
        nullif(trim(to_varchar("RECORD_HASH")), '') as record_hash,
        nullif(trim(to_varchar("CLAIM_SURVEYOR_DEPUTATION")), '') as claim_surveyor_deputation,
        "REC_REFRESH_AT"::timestamp_ntz as rec_refresh_at,
        nullif(trim(to_varchar("REC_REFRESHED_BY")), '') as rec_refreshed_by,
        nullif(trim(to_varchar("PARENT_TABLE_NAME")), '') as parent_table_name
    from {{ source('maximus_motor_raw', 'MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_SURVEYOR_DEPUTATION') }}

)

select * from source
