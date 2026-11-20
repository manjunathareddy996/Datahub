-- Staging for source view MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RESERVE. Every column trimmed varchar, including the shred keys
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
        nullif(trim(to_varchar("PAIDAMOUNT")), '') as paidamount,
        nullif(trim(to_varchar("PENDINGAMOUNT")), '') as pendingamount,
        nullif(trim(to_varchar("RESERVEAMOUNT")), '') as reserveamount,
        nullif(trim(to_varchar("RESERVESTAKE")), '') as reservestake,
        nullif(trim(to_varchar("RESERVETYPE")), '') as reservetype,
        nullif(trim(to_varchar("RESERVETYPEDESC")), '') as reservetypedesc,
        nullif(trim(to_varchar("RESERVPARTY")), '') as reservparty,
        nullif(trim(to_varchar("KEY_HASH")), '') as key_hash,
        nullif(trim(to_varchar("RECORD_HASH")), '') as record_hash,
        nullif(trim(to_varchar("CLAIM_RESERVE")), '') as claim_reserve,
        "REC_REFRESH_AT"::timestamp_ntz as rec_refresh_at,
        nullif(trim(to_varchar("REC_REFRESHED_BY")), '') as rec_refreshed_by,
        nullif(trim(to_varchar("PARENT_TABLE_NAME")), '') as parent_table_name
    from {{ source('maximus_motor_raw', 'MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RESERVE') }}

)

select * from source
