-- Staging for source view MAXI_HLTH_UWR_VW_DATA_POLICY_PAYMENT_CYCLE_DETAILS_PAYMENT_CYCLE_DETAILS_PAYMENT_CYCLE_PIVOT_VW. Every column trimmed varchar, including the shred keys
-- KEY_HASH / PARENT_KEY_HASH / FOREIGN_KEY that the central views join on.
with source as (

    select
        nullif(trim(to_varchar("FOREIGN_KEY")), '') as foreign_key,
        nullif(trim(to_varchar("PARENT_RECORD_HASH")), '') as parent_record_hash,
        nullif(trim(to_varchar("PARENT_KEY_HASH")), '') as parent_key_hash,
        nullif(trim(to_varchar("KEY_HASH")), '') as key_hash,
        nullif(trim(to_varchar("INC_JOB_CREATED_AT")), '') as inc_job_created_at,
        nullif(trim(to_varchar("REC_REFRESH_AT")), '') as rec_refresh_at,
        nullif(trim(to_varchar("ACTUALPAYMENTDATE")), '') as actualpaymentdate,
        nullif(trim(to_varchar("INVOICENUMBER")), '') as invoicenumber,
        nullif(trim(to_varchar("PAYEECODE")), '') as payeecode,
        nullif(trim(to_varchar("PAYMENTAMOUNT")), '') as paymentamount,
        nullif(trim(to_varchar("PAYMENTDUEDATE")), '') as paymentduedate,
        nullif(trim(to_varchar("PAYMENTSTATUS")), '') as paymentstatus,
        nullif(trim(to_varchar("PAYMENTTODATE")), '') as paymenttodate,
        nullif(trim(to_varchar("PAYMENTUNPAIDAMOUNT")), '') as paymentunpaidamount
    from {{ source('maximus_raw', 'MAXI_HLTH_UWR_VW_DATA_POLICY_PAYMENT_CYCLE_DETAILS_PAYMENT_CYCLE_DETAILS_PAYMENT_CYCLE_PIVOT_VW') }}

)

select * from source
