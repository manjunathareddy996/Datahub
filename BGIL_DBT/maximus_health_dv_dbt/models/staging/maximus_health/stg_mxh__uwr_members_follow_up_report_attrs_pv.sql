-- Staging for source view MAXI_HLTH_UWR_VW_DATA_MEMBERS_FOLLOW_UP_REPORT_ATTRIBUTES_PIVOT_VW. Every column trimmed varchar, including the shred keys
-- KEY_HASH / PARENT_KEY_HASH / FOREIGN_KEY that the central views join on.
with source as (

    select
        nullif(trim(to_varchar("FOREIGN_KEY")), '') as foreign_key,
        nullif(trim(to_varchar("PARENT_RECORD_HASH")), '') as parent_record_hash,
        nullif(trim(to_varchar("PARENT_KEY_HASH")), '') as parent_key_hash,
        nullif(trim(to_varchar("KEY_HASH")), '') as key_hash,
        nullif(trim(to_varchar("INC_JOB_CREATED_AT")), '') as inc_job_created_at,
        nullif(trim(to_varchar("REC_REFRESH_AT")), '') as rec_refresh_at,
        nullif(trim(to_varchar("DATE")), '') as date,
        nullif(trim(to_varchar("EFFECTIVE_DATE")), '') as effective_date,
        nullif(trim(to_varchar("ENDORSEMENT_NUMBER_CLAIM_NUMBER")), '') as endorsement_number_claim_number,
        nullif(trim(to_varchar("REMARKS")), '') as remarks,
        nullif(trim(to_varchar("STATUS")), '') as status,
        nullif(trim(to_varchar("SUBSTATUS")), '') as substatus,
        nullif(trim(to_varchar("TIME")), '') as time,
        nullif(trim(to_varchar("USER_CODE")), '') as user_code
    from {{ source('maximus_raw', 'MAXI_HLTH_UWR_VW_DATA_MEMBERS_FOLLOW_UP_REPORT_ATTRIBUTES_PIVOT_VW') }}

)

select * from source
