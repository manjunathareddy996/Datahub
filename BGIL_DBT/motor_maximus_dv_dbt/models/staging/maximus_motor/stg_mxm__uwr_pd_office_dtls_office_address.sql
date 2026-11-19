-- Staging for source view MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_OFFICE_DETAILS_OFFICE_ADDRESS. Every column trimmed varchar, including the shred keys
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
        nullif(trim(to_varchar("ADDRESS1")), '') as address1,
        nullif(trim(to_varchar("ADDRESS2")), '') as address2,
        nullif(trim(to_varchar("ADDRESS3")), '') as address3,
        nullif(trim(to_varchar("ADDRESS_PROPERTY")), '') as address_property,
        nullif(trim(to_varchar("ADDRESS_TYPE")), '') as address_type,
        nullif(trim(to_varchar("ALTERNATE_EMAIL_ID")), '') as alternate_email_id,
        nullif(trim(to_varchar("CITY")), '') as city,
        nullif(trim(to_varchar("COUNTRY")), '') as country,
        nullif(trim(to_varchar("DISTRICT")), '') as district,
        nullif(trim(to_varchar("EMAIL_ID")), '') as email_id,
        nullif(trim(to_varchar("FAX")), '') as fax,
        nullif(trim(to_varchar("LANDLINE_NO")), '') as landline_no,
        nullif(trim(to_varchar("MOBILE_NO")), '') as mobile_no,
        nullif(trim(to_varchar("PHONE_NO")), '') as phone_no,
        nullif(trim(to_varchar("PINCODE")), '') as pincode,
        nullif(trim(to_varchar("STATE")), '') as state,
        nullif(trim(to_varchar("STD_CODE")), '') as std_code,
        nullif(trim(to_varchar("WORK_NO")), '') as work_no,
        nullif(trim(to_varchar("KEY_HASH")), '') as key_hash,
        nullif(trim(to_varchar("RECORD_HASH")), '') as record_hash,
        nullif(trim(to_varchar("OFFICE_ADDRESS")), '') as office_address,
        "REC_REFRESH_AT"::timestamp_ntz as rec_refresh_at,
        nullif(trim(to_varchar("REC_REFRESHED_BY")), '') as rec_refreshed_by,
        nullif(trim(to_varchar("PARENT_TABLE_NAME")), '') as parent_table_name
    from {{ source('maximus_motor_raw', 'MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_OFFICE_DETAILS_OFFICE_ADDRESS') }}

)

select * from source
