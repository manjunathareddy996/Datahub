-- Staging for source view MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_RESERVE_ATTRIBUTES_PIVOT_VW. Every column trimmed varchar, including the shred keys
-- KEY_HASH / PARENT_KEY_HASH / FOREIGN_KEY that the central views join on.
with source as (

    select
        nullif(trim(to_varchar("FOREIGN_KEY")), '') as foreign_key,
        nullif(trim(to_varchar("PARENT_RECORD_HASH")), '') as parent_record_hash,
        nullif(trim(to_varchar("PARENT_KEY_HASH")), '') as parent_key_hash,
        nullif(trim(to_varchar("KEY_HASH")), '') as key_hash,
        nullif(trim(to_varchar("INC_JOB_CREATED_AT")), '') as inc_job_created_at,
        nullif(trim(to_varchar("REC_REFRESH_AT")), '') as rec_refresh_at,
        nullif(trim(to_varchar("IMPACTED_COVER_CODE")), '') as impacted_cover_code,
        nullif(trim(to_varchar("PAID_AMOUNT")), '') as paid_amount,
        nullif(trim(to_varchar("PENDING_AMOUNT")), '') as pending_amount,
        nullif(trim(to_varchar("RESERVE_AMOUNT")), '') as reserve_amount,
        nullif(trim(to_varchar("TYPE")), '') as type
    from {{ source('maximus_raw', 'MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_RESERVE_ATTRIBUTES_PIVOT_VW') }}

)

select * from source
