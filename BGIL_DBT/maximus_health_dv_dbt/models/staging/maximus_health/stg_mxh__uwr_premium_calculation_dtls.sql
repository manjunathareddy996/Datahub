-- Staging for source view MAXI_HLTH_UWR_VW_DATA_PREMIUM_CALCULATION_DETAILS. Every column trimmed varchar, including the shred keys
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
        nullif(trim(to_varchar("BASE_PREMIUM")), '') as base_premium,
        nullif(trim(to_varchar("COVER")), '') as cover,
        nullif(trim(to_varchar("COVER_NAME")), '') as cover_name,
        nullif(trim(to_varchar("DURATION")), '') as duration,
        nullif(trim(to_varchar("GROSS_PREMIUM")), '') as gross_premium,
        nullif(trim(to_varchar("LOADING_DISCOUNT")), '') as loading_discount,
        nullif(trim(to_varchar("MEMBER_NAME")), '') as member_name,
        nullif(trim(to_varchar("PERIOD_END_DATE")), '') as period_end_date,
        nullif(trim(to_varchar("PERIOD_START_DATE")), '') as period_start_date,
        nullif(trim(to_varchar("PRORATED_PREMIUM")), '') as prorated_premium,
        nullif(trim(to_varchar("TOTAL_COVER_PERIOD")), '') as total_cover_period,
        nullif(trim(to_varchar("TOTAL_PREMIUM_FOR_ACOVER_PRE_TAX")), '') as total_premium_for_acover_pre_tax,
        nullif(trim(to_varchar("TOTAL_PREMIUM_FOR_POLICY_PRE_TAX")), '') as total_premium_for_policy_pre_tax,
        nullif(trim(to_varchar("KEY_HASH")), '') as key_hash,
        nullif(trim(to_varchar("RECORD_HASH")), '') as record_hash,
        nullif(trim(to_varchar("PREMIUM_CALCULATION_DETAILS")), '') as premium_calculation_details,
        nullif(trim(to_varchar("REC_REFRESH_AT")), '') as rec_refresh_at,
        nullif(trim(to_varchar("REC_REFRESHED_BY")), '') as rec_refreshed_by,
        nullif(trim(to_varchar("PARENT_TABLE_NAME")), '') as parent_table_name
    from {{ source('maximus_raw', 'MAXI_HLTH_UWR_VW_DATA_PREMIUM_CALCULATION_DETAILS') }}

)

select * from source
