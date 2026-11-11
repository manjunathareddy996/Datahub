-- Staging for source view MAXI_HLTH_UWR_VW_DATA_MEMBERS. Every column trimmed varchar, including the shred keys
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
        nullif(trim(to_varchar("ADDITIONAL_TEST")), '') as additional_test,
        nullif(trim(to_varchar("BENEFITS")), '') as benefits,
        nullif(trim(to_varchar("EXPIRY_DATE")), '') as expiry_date,
        nullif(trim(to_varchar("FOLLOW_UP_REPORT")), '') as follow_up_report,
        nullif(trim(to_varchar("GROSS_PREMIUM")), '') as gross_premium,
        nullif(trim(to_varchar("INCEPTION_DATE")), '') as inception_date,
        nullif(trim(to_varchar("MEDICAL_DETAILS")), '') as medical_details,
        nullif(trim(to_varchar("MEDICAL_DIGITIZATION")), '') as medical_digitization,
        nullif(trim(to_varchar("MEDICALRATING")), '') as medicalrating,
        nullif(trim(to_varchar("MEMBER_DETAILS")), '') as member_details,
        nullif(trim(to_varchar("NET_PREMIUM")), '') as net_premium,
        nullif(trim(to_varchar("PARTY")), '') as party,
        nullif(trim(to_varchar("PPC_PACKAGE")), '') as ppc_package,
        nullif(trim(to_varchar("QUESTIONNAIRE")), '') as questionnaire,
        nullif(trim(to_varchar("REQUIREMENT_DETAILS")), '') as requirement_details,
        nullif(trim(to_varchar("KEY_HASH")), '') as key_hash,
        nullif(trim(to_varchar("RECORD_HASH")), '') as record_hash,
        nullif(trim(to_varchar("MEMBERS")), '') as members,
        nullif(trim(to_varchar("REC_REFRESH_AT")), '') as rec_refresh_at,
        nullif(trim(to_varchar("REC_REFRESHED_BY")), '') as rec_refreshed_by,
        nullif(trim(to_varchar("PARENT_TABLE_NAME")), '') as parent_table_name
    from {{ source('maximus_raw', 'MAXI_HLTH_UWR_VW_DATA_MEMBERS') }}

)

select * from source
