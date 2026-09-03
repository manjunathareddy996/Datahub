{{ config(materialized='view') }}

-- MAXIMUS PARTNER layer-1 cast for BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_ADDRESS.

with source as (

    select
    nullif(trim(to_varchar("ADDRESS1")), '') as address1,
    nullif(trim(to_varchar("ADDRESS2")), '') as address2,
    nullif(trim(to_varchar("ADDRESS3")), '') as address3,
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
    nullif(trim(to_varchar("FOREIGN_KEY")), '') as foreign_key,
    nullif(trim(to_varchar("KEY_HASH")), '') as key_hash,
    nullif(trim(to_varchar("PARENT_KEY_HASH")), '') as parent_key_hash
    from {{ source('maximus_partner', 'BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_ADDRESS') }}

)

select * from source
