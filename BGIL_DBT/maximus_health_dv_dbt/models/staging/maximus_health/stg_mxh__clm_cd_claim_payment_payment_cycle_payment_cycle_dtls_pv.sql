-- Staging for source view MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_PAYMENT_PAYMENT_CYCLE_PAYMENT_CYCLE_DETAILS_PIVOT_VW. Every column trimmed varchar, including the shred keys
-- KEY_HASH / PARENT_KEY_HASH / FOREIGN_KEY that the central views join on.
with source as (

    select
        nullif(trim(to_varchar("FOREIGN_KEY")), '') as foreign_key,
        nullif(trim(to_varchar("PARENT_RECORD_HASH")), '') as parent_record_hash,
        nullif(trim(to_varchar("PARENT_KEY_HASH")), '') as parent_key_hash,
        nullif(trim(to_varchar("KEY_HASH")), '') as key_hash,
        nullif(trim(to_varchar("INC_JOB_CREATED_AT")), '') as inc_job_created_at,
        nullif(trim(to_varchar("REC_REFRESH_AT")), '') as rec_refresh_at,
        nullif(trim(to_varchar("INVOICE_NUMBER")), '') as invoice_number,
        nullif(trim(to_varchar("PAYEE_CODE")), '') as payee_code,
        nullif(trim(to_varchar("PAYMENT_AMOUNT")), '') as payment_amount,
        nullif(trim(to_varchar("PAYMENT_DUE_DATE")), '') as payment_due_date,
        nullif(trim(to_varchar("PAYMENT_END_DATE")), '') as payment_end_date,
        nullif(trim(to_varchar("PAYMENT_START_DATE")), '') as payment_start_date,
        nullif(trim(to_varchar("PAYMENT_STATUS")), '') as payment_status,
        nullif(trim(to_varchar("PAYMENT_UNPAID_AMOUNT")), '') as payment_unpaid_amount,
        nullif(trim(to_varchar("PURPOSE")), '') as purpose,
        nullif(trim(to_varchar("REFERENCE_NO")), '') as reference_no
    from {{ source('maximus_raw', 'MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_PAYMENT_PAYMENT_CYCLE_PAYMENT_CYCLE_DETAILS_PIVOT_VW') }}

)

select * from source
