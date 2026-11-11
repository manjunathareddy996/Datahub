-- Staging for source view MAXI_HLTH_CLM_VW_DATA_POLICY_CLAIM_HISTORY_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW. Every column trimmed varchar, including the shred keys
-- KEY_HASH / PARENT_KEY_HASH / FOREIGN_KEY that the central views join on.
with source as (

    select
        nullif(trim(to_varchar("FOREIGN_KEY")), '') as foreign_key,
        nullif(trim(to_varchar("PARENT_RECORD_HASH")), '') as parent_record_hash,
        nullif(trim(to_varchar("PARENT_KEY_HASH")), '') as parent_key_hash,
        nullif(trim(to_varchar("KEY_HASH")), '') as key_hash,
        nullif(trim(to_varchar("INC_JOB_CREATED_AT")), '') as inc_job_created_at,
        nullif(trim(to_varchar("REC_REFRESH_AT")), '') as rec_refresh_at,
        nullif(trim(to_varchar("POLICY_NUMBER")), '') as policy_number,
        nullif(trim(to_varchar("PRODUCT_CODE")), '') as product_code,
        nullif(trim(to_varchar("PRODUCT_NAME")), '') as product_name,
        nullif(trim(to_varchar("RISK_EXPIRY_DATE")), '') as risk_expiry_date,
        nullif(trim(to_varchar("RISK_START_DATE")), '') as risk_start_date,
        nullif(trim(to_varchar("SOURCE")), '') as source,
        nullif(trim(to_varchar("STATUS")), '') as status,
        nullif(trim(to_varchar("SUB_STATUS")), '') as sub_status,
        nullif(trim(to_varchar("TYPE_OF_PROPOSAL")), '') as type_of_proposal,
        nullif(trim(to_varchar("VIEWPROPOSAL_NUMBER")), '') as viewproposal_number
    from {{ source('maximus_raw', 'MAXI_HLTH_CLM_VW_DATA_POLICY_CLAIM_HISTORY_MULTISET_ATTRIBUTE_ATTRIBUTES_PIVOT_VW') }}

)

select * from source
