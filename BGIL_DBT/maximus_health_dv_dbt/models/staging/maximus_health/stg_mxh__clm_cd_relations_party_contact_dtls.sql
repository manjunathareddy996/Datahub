-- Staging for source view MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_PARTY_CONTACT_DETAILS. Every column trimmed varchar, including the shred keys
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
        nullif(trim(to_varchar("ADDRESS_LINE1")), '') as address_line1,
        nullif(trim(to_varchar("ADDRESS_LINE2")), '') as address_line2,
        nullif(trim(to_varchar("ADDRESS_LINE3")), '') as address_line3,
        nullif(trim(to_varchar("CITY_CODE")), '') as city_code,
        nullif(trim(to_varchar("COUNTRY_CODE")), '') as country_code,
        nullif(trim(to_varchar("DISTRICT_CODE")), '') as district_code,
        nullif(trim(to_varchar("EFFECTIVE_DATE")), '') as effective_date,
        nullif(trim(to_varchar("EMAIL1")), '') as email1,
        nullif(trim(to_varchar("EMAIL2")), '') as email2,
        nullif(trim(to_varchar("EMAIL3")), '') as email3,
        nullif(trim(to_varchar("FAX_NUMBER")), '') as fax_number,
        nullif(trim(to_varchar("MOBILE_NUMBER")), '') as mobile_number,
        nullif(trim(to_varchar("PIN_CODE")), '') as pin_code,
        nullif(trim(to_varchar("STATE_CODE")), '') as state_code,
        nullif(trim(to_varchar("TELEPHONE_NUMBER")), '') as telephone_number,
        nullif(trim(to_varchar("TYPE_OF_CONTACT")), '') as type_of_contact,
        nullif(trim(to_varchar("KEY_HASH")), '') as key_hash,
        nullif(trim(to_varchar("RECORD_HASH")), '') as record_hash,
        nullif(trim(to_varchar("CONTACT_DETAILS")), '') as contact_details,
        nullif(trim(to_varchar("REC_REFRESH_AT")), '') as rec_refresh_at,
        nullif(trim(to_varchar("REC_REFRESHED_BY")), '') as rec_refreshed_by,
        nullif(trim(to_varchar("PARENT_TABLE_NAME")), '') as parent_table_name
    from {{ source('maximus_raw', 'MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_PARTY_CONTACT_DETAILS') }}

)

select * from source
