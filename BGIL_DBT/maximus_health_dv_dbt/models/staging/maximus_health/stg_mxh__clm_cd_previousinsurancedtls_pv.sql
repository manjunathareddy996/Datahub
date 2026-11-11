-- Staging for source view MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_PREVIOUSINSURANCEDETAILS_PIVOT_VW. Every column trimmed varchar, including the shred keys
-- KEY_HASH / PARENT_KEY_HASH / FOREIGN_KEY that the central views join on.
with source as (

    select
        nullif(trim(to_varchar("FOREIGN_KEY")), '') as foreign_key,
        nullif(trim(to_varchar("PARENT_RECORD_HASH")), '') as parent_record_hash,
        nullif(trim(to_varchar("PARENT_KEY_HASH")), '') as parent_key_hash,
        nullif(trim(to_varchar("KEY_HASH")), '') as key_hash,
        nullif(trim(to_varchar("INC_JOB_CREATED_AT")), '') as inc_job_created_at,
        nullif(trim(to_varchar("REC_REFRESH_AT")), '') as rec_refresh_at,
        nullif(trim(to_varchar("CONTINUITY_INDICATOR_APPROVED")), '') as continuity_indicator_approved,
        nullif(trim(to_varchar("CUMULATIVE_BONUS_IN_PREVIOUS_POLICY")), '') as cumulative_bonus_in_previous_policy,
        nullif(trim(to_varchar("INSURER")), '') as insurer,
        nullif(trim(to_varchar("NUMBER_OF_CLAIMS_LODGED")), '') as number_of_claims_lodged,
        nullif(trim(to_varchar("PREVIOUS_POLICY_EXPIRY_DATE")), '') as previous_policy_expiry_date,
        nullif(trim(to_varchar("PREVIOUS_POLICY_START_DATE")), '') as previous_policy_start_date,
        nullif(trim(to_varchar("REMARKS")), '') as remarks,
        nullif(trim(to_varchar("SUM_INSURED_IN_PREVIOUS_POLICY")), '') as sum_insured_in_previous_policy
    from {{ source('maximus_raw', 'MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_PREVIOUSINSURANCEDETAILS_PIVOT_VW') }}

)

select * from source
