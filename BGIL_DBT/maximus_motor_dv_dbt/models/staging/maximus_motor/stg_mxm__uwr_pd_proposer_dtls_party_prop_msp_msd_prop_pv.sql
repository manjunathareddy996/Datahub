-- Staging for source view MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW. Every column trimmed varchar, including the shred keys
-- KEY_HASH / PARENT_KEY_HASH / FOREIGN_KEY that the central views join on.
with source as (

    select
        nullif(trim(to_varchar("FOREIGN_KEY")), '') as foreign_key,
        nullif(trim(to_varchar("PARENT_RECORD_HASH")), '') as parent_record_hash,
        nullif(trim(to_varchar("PARENT_KEY_HASH")), '') as parent_key_hash,
        nullif(trim(to_varchar("KEY_HASH")), '') as key_hash,
        nullif(trim(to_varchar("INC_JOB_CREATED_AT")), '') as inc_job_created_at,
        "REC_REFRESH_AT"::timestamp_ntz as rec_refresh_at,
        nullif(trim(to_varchar("ACCOUNT_TYPE")), '') as account_type,
        nullif(trim(to_varchar("APPROVEDREJECTED_BY")), '') as approvedrejected_by,
        nullif(trim(to_varchar("APPROVEDREJECTED_DATE")), '') as approvedrejected_date,
        nullif(trim(to_varchar("BANK_ACCOUNT_NUMBER")), '') as bank_account_number,
        nullif(trim(to_varchar("BANK_BRANCH_NAME")), '') as bank_branch_name,
        nullif(trim(to_varchar("BANK_NAME")), '') as bank_name,
        nullif(trim(to_varchar("CONFIRM_BANK_ACCOUNT_NUMBER")), '') as confirm_bank_account_number,
        nullif(trim(to_varchar("CREDIT_CARD_NUMBER")), '') as credit_card_number,
        nullif(trim(to_varchar("CREDIT_CARD_TYPE")), '') as credit_card_type,
        nullif(trim(to_varchar("EXPIRY_DATE")), '') as expiry_date,
        nullif(trim(to_varchar("IFSC")), '') as ifsc,
        nullif(trim(to_varchar("MICR")), '') as micr,
        nullif(trim(to_varchar("NAME_AS_PER_BANK_AC")), '') as name_as_per_bank_ac,
        nullif(trim(to_varchar("NAME_OF_THE_BANK")), '') as name_of_the_bank,
        nullif(trim(to_varchar("NEFT_STATUS")), '') as neft_status,
        nullif(trim(to_varchar("PASSPORT_EXPIRY_DATE")), '') as passport_expiry_date,
        nullif(trim(to_varchar("PASSPORT_FILE_NO")), '') as passport_file_no,
        nullif(trim(to_varchar("PASSPORT_ISSUE_COUNTRY")), '') as passport_issue_country,
        nullif(trim(to_varchar("PASSPORT_ISSUE_DATE")), '') as passport_issue_date,
        nullif(trim(to_varchar("PASSPORT_NUMBER")), '') as passport_number,
        nullif(trim(to_varchar("PAYEE_NAME_AS_PER_BANK_RECORD")), '') as payee_name_as_per_bank_record,
        nullif(trim(to_varchar("PENNYDROPLESS_FLAG")), '') as pennydropless_flag,
        nullif(trim(to_varchar("PENNY_SCORE")), '') as penny_score,
        nullif(trim(to_varchar("PRIMARY_SECONDARY")), '') as primary_secondary,
        nullif(trim(to_varchar("REMARKS")), '') as remarks
    from {{ source('maximus_motor_raw', 'MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW') }}

)

select * from source
