{{ config(materialized='view') }}

-- MAXIMUS PARTNER layer-1 cast for BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL.

with source as (

    select
    nullif(trim(to_varchar("BUSINESS_NAME")), '') as business_name,
    nullif(trim(to_varchar("DATE_OF_BIRTH")), '') as date_of_birth,
    nullif(trim(to_varchar("FIRST_NAME")), '') as first_name,
    nullif(trim(to_varchar("GENDER")), '') as gender,
    nullif(trim(to_varchar("LAST_NAME")), '') as last_name,
    nullif(trim(to_varchar("MIDDLE_NAME")), '') as middle_name,
    nullif(trim(to_varchar("NATIONALITY")), '') as nationality,
    nullif(trim(to_varchar("OCCUPATION")), '') as occupation,
    nullif(trim(to_varchar("PARENT_PARTY_CODE")), '') as parent_party_code,
    nullif(trim(to_varchar("PARTY_CODE")), '') as party_code,
    nullif(trim(to_varchar("PARTY_END_DATE")), '') as party_end_date,
    nullif(trim(to_varchar("PARTY_LAST_MODIFICATION_DATE")), '') as party_last_modification_date,
    nullif(trim(to_varchar("PARTY_START_DATE")), '') as party_start_date,
    nullif(trim(to_varchar("PARTY_STATUS")), '') as party_status,
    nullif(trim(to_varchar("REGISTRATION_DATE")), '') as registration_date,
    nullif(trim(to_varchar("REGISTRATION_NO")), '') as registration_no,
    nullif(trim(to_varchar("TITLE")), '') as title,
    nullif(trim(to_varchar("TYPE_OF_ORGANIZATION")), '') as type_of_organization,
    nullif(trim(to_varchar("TYPE_OF_PARTY")), '') as type_of_party,
    nullif(trim(to_varchar("FOREIGN_KEY")), '') as foreign_key,
    nullif(trim(to_varchar("KEY_HASH")), '') as key_hash,
    nullif(trim(to_varchar("PARENT_KEY_HASH")), '') as parent_key_hash
    from {{ source('maximus_partner', 'BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL') }}

)

select * from source
