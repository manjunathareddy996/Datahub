-- Staging for source view MAXI_HLTH_UWR_VW_DATA_MEMBER_DETAILS_TAB_GRADED_SI_DETAILS. Every column trimmed varchar, including the shred keys
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
        nullif(trim(to_varchar("CB")), '') as cb,
        nullif(trim(to_varchar("CUMULATIVE_SI_CB")), '') as cumulative_si_cb,
        nullif(trim(to_varchar("EXPIRY_DATE")), '') as expiry_date,
        nullif(trim(to_varchar("GRADED_SI")), '') as graded_si,
        nullif(trim(to_varchar("REMARKS")), '') as remarks,
        nullif(trim(to_varchar("SI")), '') as si,
        nullif(trim(to_varchar("START_DATE")), '') as start_date,
        nullif(trim(to_varchar("WAITING_PERIOD_ELASPED_IN_YEARS")), '') as waiting_period_elasped_in_years,
        nullif(trim(to_varchar("KEY_HASH")), '') as key_hash,
        nullif(trim(to_varchar("RECORD_HASH")), '') as record_hash,
        nullif(trim(to_varchar("GRADED_SI_DETAILS")), '') as graded_si_details,
        nullif(trim(to_varchar("REC_REFRESH_AT")), '') as rec_refresh_at,
        nullif(trim(to_varchar("REC_REFRESHED_BY")), '') as rec_refreshed_by,
        nullif(trim(to_varchar("PARENT_TABLE_NAME")), '') as parent_table_name
    from {{ source('maximus_raw', 'MAXI_HLTH_UWR_VW_DATA_MEMBER_DETAILS_TAB_GRADED_SI_DETAILS') }}

)

select * from source
