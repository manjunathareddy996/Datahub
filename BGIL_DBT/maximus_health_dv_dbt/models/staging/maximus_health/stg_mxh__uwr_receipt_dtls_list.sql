-- Staging for source view MAXI_HLTH_UWR_VW_DATA_RECEIPT_DETAILS_LIST. Every column trimmed varchar, including the shred keys
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
        nullif(trim(to_varchar("CREATED_BY")), '') as created_by,
        nullif(trim(to_varchar("CREATED_ON")), '') as created_on,
        nullif(trim(to_varchar("INSTRUMENT_DATE")), '') as instrument_date,
        nullif(trim(to_varchar("INSTRUMENT_MODE")), '') as instrument_mode,
        nullif(trim(to_varchar("INSTRUMENT_NUMBER")), '') as instrument_number,
        nullif(trim(to_varchar("INSTRUMENT_STATUS")), '') as instrument_status,
        nullif(trim(to_varchar("RECEIPT_NUMBER")), '') as receipt_number,
        nullif(trim(to_varchar("UPDATED_ON")), '') as updated_on,
        nullif(trim(to_varchar("KEY_HASH")), '') as key_hash,
        nullif(trim(to_varchar("RECORD_HASH")), '') as record_hash,
        nullif(trim(to_varchar("RECEIPT_DETAILS_LIST")), '') as receipt_details_list,
        nullif(trim(to_varchar("REC_REFRESH_AT")), '') as rec_refresh_at,
        nullif(trim(to_varchar("REC_REFRESHED_BY")), '') as rec_refreshed_by,
        nullif(trim(to_varchar("PARENT_TABLE_NAME")), '') as parent_table_name
    from {{ source('maximus_raw', 'MAXI_HLTH_UWR_VW_DATA_RECEIPT_DETAILS_LIST') }}

)

select * from source
