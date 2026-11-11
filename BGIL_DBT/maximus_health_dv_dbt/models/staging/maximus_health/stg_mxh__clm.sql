-- Staging for source view MAXI_HLTH_CLM_VW_DATA. Every column trimmed varchar, including the shred keys
-- KEY_HASH / PARENT_KEY_HASH / FOREIGN_KEY that the central views join on.
with source as (

    select
        nullif(trim(to_varchar("INC_JOB_CREATED_AT")), '') as inc_job_created_at,
        nullif(trim(to_varchar("INC_JOB_ID")), '') as inc_job_id,
        nullif(trim(to_varchar("FILE_NAME")), '') as file_name,
        nullif(trim(to_varchar("FILE_TIMESTAMP")), '') as file_timestamp,
        nullif(trim(to_varchar("FOREIGN_KEY")), '') as foreign_key,
        nullif(trim(to_varchar("ROOT_HASH")), '') as root_hash,
        nullif(trim(to_varchar("AUTHORIZATION_REMARKS")), '') as authorization_remarks,
        nullif(trim(to_varchar("CLAIM_DETAIL")), '') as claim_detail,
        nullif(trim(to_varchar("CLAIM_POLICY_HISTORY")), '') as claim_policy_history,
        nullif(trim(to_varchar("PENAL_INTEREST")), '') as penal_interest,
        nullif(trim(to_varchar("POLICY_CLAIM_HISTORY")), '') as policy_claim_history,
        nullif(trim(to_varchar("RESPONSE")), '') as response,
        nullif(trim(to_varchar("KEY_HASH")), '') as key_hash,
        nullif(trim(to_varchar("RECORD_HASH")), '') as record_hash,
        nullif(trim(to_varchar("DATA")), '') as data,
        nullif(trim(to_varchar("REC_REFRESH_AT")), '') as rec_refresh_at,
        nullif(trim(to_varchar("REC_REFRESHED_BY")), '') as rec_refreshed_by,
        nullif(trim(to_varchar("PARENT_TABLE_NAME")), '') as parent_table_name
    from {{ source('maximus_raw', 'MAXI_HLTH_CLM_VW_DATA') }}

)

select * from source
