-- Staging for source view MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PREVIOUS_POLICY_DETAILS. Every column trimmed varchar, including the shred keys
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
        nullif(trim(to_varchar("POLICY_EXPIRY_DATE")), '') as policy_expiry_date,
        nullif(trim(to_varchar("POLICY_INCEPTION_DATE")), '') as policy_inception_date,
        nullif(trim(to_varchar("POLICY_NUMBER")), '') as policy_number,
        nullif(trim(to_varchar("PRODUCT_CODE")), '') as product_code,
        nullif(trim(to_varchar("PRODUCT_NAME")), '') as product_name,
        nullif(trim(to_varchar("SUM_INSURED")), '') as sum_insured,
        nullif(trim(to_varchar("TOTAL_PREMIUM")), '') as total_premium,
        nullif(trim(to_varchar("KEY_HASH")), '') as key_hash,
        nullif(trim(to_varchar("RECORD_HASH")), '') as record_hash,
        nullif(trim(to_varchar("PREVIOUS_POLICY_DETAILS")), '') as previous_policy_details,
        "REC_REFRESH_AT"::timestamp_ntz as rec_refresh_at,
        nullif(trim(to_varchar("REC_REFRESHED_BY")), '') as rec_refreshed_by,
        nullif(trim(to_varchar("PARENT_TABLE_NAME")), '') as parent_table_name
    from {{ source('maximus_motor_raw', 'MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PREVIOUS_POLICY_DETAILS') }}

)

select * from source
