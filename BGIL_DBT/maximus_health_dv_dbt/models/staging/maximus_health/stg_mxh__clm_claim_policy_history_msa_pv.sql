-- Staging for source view MAXI_HLTH_CLM_VW_DATA_CLAIM_POLICY_HISTORY_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW. Every column trimmed varchar, including the shred keys
-- KEY_HASH / PARENT_KEY_HASH / FOREIGN_KEY that the central views join on.
with source as (

    select
        nullif(trim(to_varchar("FOREIGN_KEY")), '') as foreign_key,
        nullif(trim(to_varchar("PARENT_RECORD_HASH")), '') as parent_record_hash,
        nullif(trim(to_varchar("PARENT_KEY_HASH")), '') as parent_key_hash,
        nullif(trim(to_varchar("KEY_HASH")), '') as key_hash,
        nullif(trim(to_varchar("INC_JOB_CREATED_AT")), '') as inc_job_created_at,
        nullif(trim(to_varchar("REC_REFRESH_AT")), '') as rec_refresh_at,
        nullif(trim(to_varchar("APPROVED_AMOUNT")), '') as approved_amount,
        nullif(trim(to_varchar("CLAIMED_AMOUNT")), '') as claimed_amount,
        nullif(trim(to_varchar("CLAIM_NUMBER")), '') as claim_number,
        nullif(trim(to_varchar("DATE")), '') as date,
        nullif(trim(to_varchar("POLICY_NUMBER")), '') as policy_number,
        nullif(trim(to_varchar("SOURCE")), '') as source,
        nullif(trim(to_varchar("STATUS")), '') as status,
        nullif(trim(to_varchar("TYPE_OF_CLAIM")), '') as type_of_claim,
        nullif(trim(to_varchar("VIEWINWARD_NUMBER")), '') as viewinward_number
    from {{ source('maximus_raw', 'MAXI_HLTH_CLM_VW_DATA_CLAIM_POLICY_HISTORY_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW') }}

)

select * from source
