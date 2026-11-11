-- Staging for source view MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_ADJUST_PIVOT_VW. Every column trimmed varchar, including the shred keys
-- KEY_HASH / PARENT_KEY_HASH / FOREIGN_KEY that the central views join on.
with source as (

    select
        nullif(trim(to_varchar("FOREIGN_KEY")), '') as foreign_key,
        nullif(trim(to_varchar("PARENT_RECORD_HASH")), '') as parent_record_hash,
        nullif(trim(to_varchar("PARENT_KEY_HASH")), '') as parent_key_hash,
        nullif(trim(to_varchar("KEY_HASH")), '') as key_hash,
        nullif(trim(to_varchar("INC_JOB_CREATED_AT")), '') as inc_job_created_at,
        nullif(trim(to_varchar("REC_REFRESH_AT")), '') as rec_refresh_at,
        nullif(trim(to_varchar("CONTACT_EMAIL_ID")), '') as contact_email_id,
        nullif(trim(to_varchar("CONTACT_NUMBER")), '') as contact_number,
        nullif(trim(to_varchar("NAME")), '') as name,
        nullif(trim(to_varchar("STAKE_CODE")), '') as stake_code,
        nullif(trim(to_varchar("STAKE_HOLDER")), '') as stake_holder
    from {{ source('maximus_raw', 'MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_ADJUST_PIVOT_VW') }}

)

select * from source
