-- Staging for source view MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PAYMENT_INFORMATION. Every column trimmed varchar, including the shred keys
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
        nullif(trim(to_varchar("CHEQUE_NUMBER")), '') as cheque_number,
        nullif(trim(to_varchar("CHEQUE_REALISATION_DATE")), '') as cheque_realisation_date,
        nullif(trim(to_varchar("CHEQUE_STATUS")), '') as cheque_status,
        nullif(trim(to_varchar("COLLECTION_AMOUNT")), '') as collection_amount,
        nullif(trim(to_varchar("COLLECTION_DATE")), '') as collection_date,
        nullif(trim(to_varchar("COLLECTION_MODE")), '') as collection_mode,
        nullif(trim(to_varchar("COLLECTION_SOURCE")), '') as collection_source,
        nullif(trim(to_varchar("COLLECTION_TYPE")), '') as collection_type,
        nullif(trim(to_varchar("RECEIPT_GENERATION_DATE")), '') as receipt_generation_date,
        nullif(trim(to_varchar("RECEIPT_NUMBER")), '') as receipt_number,
        nullif(trim(to_varchar("SUB_CODE")), '') as sub_code,
        nullif(trim(to_varchar("TRANSACTION_DATE")), '') as transaction_date,
        nullif(trim(to_varchar("TRANSACTION_ID")), '') as transaction_id,
        nullif(trim(to_varchar("KEY_HASH")), '') as key_hash,
        nullif(trim(to_varchar("RECORD_HASH")), '') as record_hash,
        nullif(trim(to_varchar("POLICY_PAYMENT_INFORMATION")), '') as policy_payment_information,
        "REC_REFRESH_AT"::timestamp_ntz as rec_refresh_at,
        nullif(trim(to_varchar("REC_REFRESHED_BY")), '') as rec_refreshed_by,
        nullif(trim(to_varchar("PARENT_TABLE_NAME")), '') as parent_table_name
    from {{ source('maximus_motor_raw', 'MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PAYMENT_INFORMATION') }}

)

select * from source
