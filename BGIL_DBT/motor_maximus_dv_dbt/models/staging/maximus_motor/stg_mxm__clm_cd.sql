-- Staging for source view MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS. Every column trimmed varchar, including the shred keys
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
        nullif(trim(to_varchar("CLAIM_ATTRIBUTE")), '') as claim_attribute,
        nullif(trim(to_varchar("CLAIMBRANCH")), '') as claimbranch,
        nullif(trim(to_varchar("CLAIM_BUCKET")), '') as claim_bucket,
        nullif(trim(to_varchar("CLAIM_COVER")), '') as claim_cover,
        nullif(trim(to_varchar("CLAIM_EVENT_FOLLOWUP")), '') as claim_event_followup,
        nullif(trim(to_varchar("CLAIM_HISTORY")), '') as claim_history,
        nullif(trim(to_varchar("CLAIMNO")), '') as claimno,
        nullif(trim(to_varchar("CLAIM_NOTES")), '') as claim_notes,
        nullif(trim(to_varchar("CLAIM_NOTIFICATION_DETAILS")), '') as claim_notification_details,
        nullif(trim(to_varchar("CLAIM_PARTY")), '') as claim_party,
        nullif(trim(to_varchar("CLAIM_PAYMENT")), '') as claim_payment,
        nullif(trim(to_varchar("CLAIM_RESERVE")), '') as claim_reserve,
        nullif(trim(to_varchar("CLAIM_RISK")), '') as claim_risk,
        nullif(trim(to_varchar("CLAIM_RISK_PARTY")), '') as claim_risk_party,
        nullif(trim(to_varchar("CLAIMSTATUS")), '') as claimstatus,
        nullif(trim(to_varchar("CLAIM_SURVEYOR_DEPUTATION")), '') as claim_surveyor_deputation,
        nullif(trim(to_varchar("CLAIM_TRIGGER_DETAILS")), '') as claim_trigger_details,
        nullif(trim(to_varchar("DOCUMENT_DETAILS")), '') as document_details,
        nullif(trim(to_varchar("INTIMATIONDATE")), '') as intimationdate,
        nullif(trim(to_varchar("LOSSDATE")), '') as lossdate,
        nullif(trim(to_varchar("LOSSDESC")), '') as lossdesc,
        nullif(trim(to_varchar("NET_ASSESSED_AMOUNT")), '') as net_assessed_amount,
        nullif(trim(to_varchar("NO_OF_DAYS_AVAILED_CONV")), '') as no_of_days_availed_conv,
        nullif(trim(to_varchar("POLICYNO")), '') as policyno,
        nullif(trim(to_varchar("PRIMARYCAUSECODE")), '') as primarycausecode,
        nullif(trim(to_varchar("PRIMARYCAUSEDESC")), '') as primarycausedesc,
        nullif(trim(to_varchar("SAVING_AMOUNT")), '') as saving_amount,
        nullif(trim(to_varchar("SECONDARYCAUSECODE")), '') as secondarycausecode,
        nullif(trim(to_varchar("SECONDARYCAUSEDESC")), '') as secondarycausedesc,
        nullif(trim(to_varchar("STATUSCHANGEDATE")), '') as statuschangedate,
        nullif(trim(to_varchar("SUBCLAIMNO")), '') as subclaimno,
        nullif(trim(to_varchar("VAHAN_REGISTRATION_VERIFIED")), '') as vahan_registration_verified,
        nullif(trim(to_varchar("KEY_HASH")), '') as key_hash,
        nullif(trim(to_varchar("RECORD_HASH")), '') as record_hash,
        nullif(trim(to_varchar("CLAIM_DETAILS")), '') as claim_details,
        "REC_REFRESH_AT"::timestamp_ntz as rec_refresh_at,
        nullif(trim(to_varchar("REC_REFRESHED_BY")), '') as rec_refreshed_by,
        nullif(trim(to_varchar("PARENT_TABLE_NAME")), '') as parent_table_name
    from {{ source('maximus_motor_raw', 'MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS') }}

)

select * from source
