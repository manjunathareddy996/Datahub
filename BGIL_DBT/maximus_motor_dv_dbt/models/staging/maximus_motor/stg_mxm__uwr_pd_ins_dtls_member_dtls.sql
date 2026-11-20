-- Staging for source view MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS. Every column trimmed varchar, including the shred keys
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
        nullif(trim(to_varchar("BUSINESS_NAME")), '') as business_name,
        nullif(trim(to_varchar("CREATED_BY")), '') as created_by,
        nullif(trim(to_varchar("DATE_OF_BIRTH")), '') as date_of_birth,
        nullif(trim(to_varchar("DOCUMENT_DETAIL")), '') as document_detail,
        nullif(trim(to_varchar("FIRST_NAME")), '') as first_name,
        nullif(trim(to_varchar("GENDER")), '') as gender,
        nullif(trim(to_varchar("LAST_NAME")), '') as last_name,
        nullif(trim(to_varchar("MIDDLE_NAME")), '') as middle_name,
        nullif(trim(to_varchar("NATIONALITY")), '') as nationality,
        nullif(trim(to_varchar("OCCUPATION")), '') as occupation,
        nullif(trim(to_varchar("PARENT_PARTY_CODE")), '') as parent_party_code,
        nullif(trim(to_varchar("PARTY_ADDRESS")), '') as party_address,
        nullif(trim(to_varchar("PARTY_CODE")), '') as party_code,
        nullif(trim(to_varchar("PARTY_END_DATE")), '') as party_end_date,
        nullif(trim(to_varchar("PARTY_LAST_MODIFICATION_DATE")), '') as party_last_modification_date,
        nullif(trim(to_varchar("PARTY_PROPERTY")), '') as party_property,
        nullif(trim(to_varchar("PARTY_RELATION")), '') as party_relation,
        nullif(trim(to_varchar("PARTY_START_DATE")), '') as party_start_date,
        nullif(trim(to_varchar("PARTY_STATUS")), '') as party_status,
        nullif(trim(to_varchar("REGISTRATION_DATE")), '') as registration_date,
        nullif(trim(to_varchar("REGISTRATION_NO")), '') as registration_no,
        nullif(trim(to_varchar("RELATED_PARTY")), '') as related_party,
        nullif(trim(to_varchar("TITLE")), '') as title,
        nullif(trim(to_varchar("TYPE_OF_ORGANIZATION")), '') as type_of_organization,
        nullif(trim(to_varchar("TYPE_OF_PARTY")), '') as type_of_party,
        nullif(trim(to_varchar("KEY_HASH")), '') as key_hash,
        nullif(trim(to_varchar("RECORD_HASH")), '') as record_hash,
        nullif(trim(to_varchar("MEMBER_DETAILS")), '') as member_details,
        "REC_REFRESH_AT"::timestamp_ntz as rec_refresh_at,
        nullif(trim(to_varchar("REC_REFRESHED_BY")), '') as rec_refreshed_by,
        nullif(trim(to_varchar("PARENT_TABLE_NAME")), '') as parent_table_name
    from {{ source('maximus_motor_raw', 'MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS') }}

)

select * from source
