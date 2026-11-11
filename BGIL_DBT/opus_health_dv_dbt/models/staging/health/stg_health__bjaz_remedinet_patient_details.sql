-- Staging for source table BJAZ_REMEDINET_PATIENT_DETAILS (run opus_health_delta3). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("ADDRESS1")), '') as address1,
        nullif(trim(to_varchar("ADDRESS2")), '') as address2,
        nullif(trim(to_varchar("ADDRESS3")), '') as address3,
        nullif(trim(to_varchar("AGE_DAY")), '') as age_day,
        nullif(trim(to_varchar("AGE_MONTH")), '') as age_month,
        nullif(trim(to_varchar("AGE_YEAR")), '') as age_year,
        nullif(trim(to_varchar("CITY")), '') as city,
        nullif(trim(to_varchar("DOB")), '') as dob,
        nullif(trim(to_varchar("EMAIL_ID")), '') as email_id,
        nullif(trim(to_varchar("FAX_NO")), '') as fax_no,
        nullif(trim(to_varchar("FIRST_NAME")), '') as first_name,
        nullif(trim(to_varchar("GENDER")), '') as gender,
        nullif(trim(to_varchar("LAST_NAME")), '') as last_name,
        nullif(trim(to_varchar("MARITAL_STATUS_NAME")), '') as marital_status_name,
        nullif(trim(to_varchar("MEMBER_NO")), '') as member_no,
        nullif(trim(to_varchar("MIDDLE_NAME")), '') as middle_name,
        nullif(trim(to_varchar("MOBILE_NO")), '') as mobile_no,
        nullif(trim(to_varchar("PATIENT_HOSPITAL_NO")), '') as patient_hospital_no,
        nullif(trim(to_varchar("PHONE_NO")), '') as phone_no,
        nullif(trim(to_varchar("PIN_CODE")), '') as pin_code,
        nullif(trim(to_varchar("PREAUTH_NO")), '') as preauth_no,
        nullif(trim(to_varchar("RELATIONSHIP_NAME")), '') as relationship_name,
        nullif(trim(to_varchar("REQUESTID")), '') as requestid,
        nullif(trim(to_varchar("STATE")), '') as state,
        nullif(trim(to_varchar("TOP_INDICATOR")), '') as top_indicator,
        nullif(trim(to_varchar("UPDATED_ON")), '') as updated_on
    from {{ source('health_raw', 'BJAZ_REMEDINET_PATIENT_DETAILS') }}

)

select * from source
