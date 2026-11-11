-- Staging for source view MAXI_HLTH_CLM_VW_DATA_PENAL_INTEREST_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW. Every column trimmed varchar, including the shred keys
-- KEY_HASH / PARENT_KEY_HASH / FOREIGN_KEY that the central views join on.
with source as (

    select
        nullif(trim(to_varchar("FOREIGN_KEY")), '') as foreign_key,
        nullif(trim(to_varchar("PARENT_RECORD_HASH")), '') as parent_record_hash,
        nullif(trim(to_varchar("PARENT_KEY_HASH")), '') as parent_key_hash,
        nullif(trim(to_varchar("KEY_HASH")), '') as key_hash,
        nullif(trim(to_varchar("INC_JOB_CREATED_AT")), '') as inc_job_created_at,
        nullif(trim(to_varchar("REC_REFRESH_AT")), '') as rec_refresh_at,
        nullif(trim(to_varchar("NO_OF_DAYS_DELAYED_SETTLEMENT")), '') as no_of_days_delayed_settlement,
        nullif(trim(to_varchar("PENAL_INTEREST")), '') as penal_interest,
        nullif(trim(to_varchar("PENAL_INTEREST_AMOUNT")), '') as penal_interest_amount,
        nullif(trim(to_varchar("REASON")), '') as reason,
        nullif(trim(to_varchar("TO_BE_PAID")), '') as to_be_paid
    from {{ source('maximus_raw', 'MAXI_HLTH_CLM_VW_DATA_PENAL_INTEREST_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW') }}

)

select * from source
