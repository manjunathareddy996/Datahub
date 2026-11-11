-- Staging for source view MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL. Every column trimmed varchar, including the shred keys
-- KEY_HASH / PARENT_KEY_HASH / FOREIGN_KEY that the central views join on.
with source as (

    select
        nullif(trim(to_varchar("INC_JOB_CREATED_AT")), '') as inc_job_created_at,
        nullif(trim(to_varchar("INC_JOB_ID")), '') as inc_job_id,
        nullif(trim(to_varchar("FILE_NAME")), '') as file_name,
        nullif(trim(to_varchar("FILE_TIMESTAMP")), '') as file_timestamp,
        nullif(trim(to_varchar("FOREIGN_KEY")), '') as foreign_key,
        nullif(trim(to_varchar("ROOT_HASH")), '') as root_hash,
        nullif(trim(to_varchar("PARENT_KEY_HASH")), '') as parent_key_hash,
        nullif(trim(to_varchar("PARENT_RECORD_HASH")), '') as parent_record_hash,
        nullif(trim(to_varchar("CANCELLATION_DATE")), '') as cancellation_date,
        nullif(trim(to_varchar("CLAIM_ADJUST")), '') as claim_adjust,
        nullif(trim(to_varchar("CLAIMBENEFITLIMIT")), '') as claimbenefitlimit,
        nullif(trim(to_varchar("CLAIM_COPAY_DETAILS")), '') as claim_copay_details,
        nullif(trim(to_varchar("CLAIMDETAIL_ATTRIBUTE")), '') as claimdetail_attribute,
        nullif(trim(to_varchar("CLAIM_NUMBER")), '') as claim_number,
        nullif(trim(to_varchar("CLAIM_PARTY")), '') as claim_party,
        nullif(trim(to_varchar("CLAIM_PARTYDETAILS")), '') as claim_partydetails,
        nullif(trim(to_varchar("CLAIM_PAYMENT")), '') as claim_payment,
        nullif(trim(to_varchar("CLAIM_RESERVE")), '') as claim_reserve,
        nullif(trim(to_varchar("CLAIM_RESERVE_HISTORY")), '') as claim_reserve_history,
        nullif(trim(to_varchar("CLAIMTRANSITION")), '') as claimtransition,
        nullif(trim(to_varchar("DOCUMENTS")), '') as documents,
        nullif(trim(to_varchar("FOLLOWUP")), '') as followup,
        nullif(trim(to_varchar("LIST_OF_COVERS")), '') as list_of_covers,
        nullif(trim(to_varchar("NOTES")), '') as notes,
        nullif(trim(to_varchar("PACKAGEANDSERVICE")), '') as packageandservice,
        nullif(trim(to_varchar("POL_POLICY_NUMBER")), '') as pol_policy_number,
        nullif(trim(to_varchar("PREVIOUSINSURANCEDETAIL")), '') as previousinsurancedetail,
        nullif(trim(to_varchar("PREVIOUSINSURANCEDETAILS")), '') as previousinsurancedetails,
        nullif(trim(to_varchar("QUERY_DETAILS")), '') as query_details,
        nullif(trim(to_varchar("RELATIONS")), '') as relations,
        nullif(trim(to_varchar("RENEWAL_FLAG")), '') as renewal_flag,
        nullif(trim(to_varchar("REOPEN_INDICATOR")), '') as reopen_indicator,
        nullif(trim(to_varchar("REQUIREMENTS")), '') as requirements,
        nullif(trim(to_varchar("STATUS")), '') as status,
        nullif(trim(to_varchar("TOTAL_CLAIMED_AMOUNT")), '') as total_claimed_amount,
        nullif(trim(to_varchar("KEY_HASH")), '') as key_hash,
        nullif(trim(to_varchar("RECORD_HASH")), '') as record_hash,
        nullif(trim(to_varchar("CLAIM_DETAIL")), '') as claim_detail,
        nullif(trim(to_varchar("REC_REFRESH_AT")), '') as rec_refresh_at,
        nullif(trim(to_varchar("REC_REFRESHED_BY")), '') as rec_refreshed_by,
        nullif(trim(to_varchar("PARENT_TABLE_NAME")), '') as parent_table_name,
        nullif(trim(to_varchar("CLAIM_INWD_DOCUMENTS")), '') as claim_inwd_documents
    from {{ source('maximus_raw', 'MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL') }}

)

select * from source
