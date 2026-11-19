-- Staging for source view MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_TELE_VERIFICATION_DETAILS. Every column trimmed varchar, including the shred keys
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
        nullif(trim(to_varchar("END_TIME")), '') as end_time,
        nullif(trim(to_varchar("START_TIME")), '') as start_time,
        nullif(trim(to_varchar("TELE_VARIFICATION_INITIATED_DATE")), '') as tele_varification_initiated_date,
        nullif(trim(to_varchar("TELE_VARIFICATION_STATUS")), '') as tele_varification_status,
        nullif(trim(to_varchar("TRANSACTION_ID")), '') as transaction_id,
        nullif(trim(to_varchar("KEY_HASH")), '') as key_hash,
        nullif(trim(to_varchar("RECORD_HASH")), '') as record_hash,
        nullif(trim(to_varchar("TELE_VERIFICATION_DETAILS")), '') as tele_verification_details,
        "REC_REFRESH_AT"::timestamp_ntz as rec_refresh_at,
        nullif(trim(to_varchar("REC_REFRESHED_BY")), '') as rec_refreshed_by,
        nullif(trim(to_varchar("PARENT_TABLE_NAME")), '') as parent_table_name
    from {{ source('maximus_motor_raw', 'MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_TELE_VERIFICATION_DETAILS') }}

)

select * from source
