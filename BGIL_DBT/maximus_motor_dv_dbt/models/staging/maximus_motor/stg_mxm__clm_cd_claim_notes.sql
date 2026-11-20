-- Staging for source view MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_NOTES. Every column trimmed varchar, including the shred keys
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
        nullif(trim(to_varchar("ASSIGNED_USER_CD")), '') as assigned_user_cd,
        nullif(trim(to_varchar("ASSIGNED_USER_NAME")), '') as assigned_user_name,
        nullif(trim(to_varchar("CREATED_BY")), '') as created_by,
        nullif(trim(to_varchar("CREATED_ON")), '') as created_on,
        nullif(trim(to_varchar("DESCRIPTION")), '') as description,
        nullif(trim(to_varchar("LONG_DESCRIPTION")), '') as long_description,
        nullif(trim(to_varchar("NOTE_ORGANIZATION_CD")), '') as note_organization_cd,
        nullif(trim(to_varchar("NOTE_TYPE_CD")), '') as note_type_cd,
        nullif(trim(to_varchar("TYPE")), '') as type,
        nullif(trim(to_varchar("UPDATED_BY")), '') as updated_by,
        nullif(trim(to_varchar("UPDATED_ON")), '') as updated_on,
        nullif(trim(to_varchar("KEY_HASH")), '') as key_hash,
        nullif(trim(to_varchar("RECORD_HASH")), '') as record_hash,
        nullif(trim(to_varchar("CLAIM_NOTES")), '') as claim_notes,
        "REC_REFRESH_AT"::timestamp_ntz as rec_refresh_at,
        nullif(trim(to_varchar("REC_REFRESHED_BY")), '') as rec_refreshed_by,
        nullif(trim(to_varchar("PARENT_TABLE_NAME")), '') as parent_table_name
    from {{ source('maximus_motor_raw', 'MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_NOTES') }}

)

select * from source
