{{ config(materialized='view') }}

-- Staging model for source table BJAZ_M_KYC_DRIVING_LICENCE (Partner + KYC scope).
-- Casting: TEXT/VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP ->
-- TIMESTAMP_NTZ. Key columns (hub-key components) -> canonical trimmed VARCHAR
-- regardless of native type, for stable hashing -- the baseline's own convention.

with source as (

    select
    "LICENCE_ID"::number as licence_id,
    nullif(trim("LICENCE_NUMBER"::varchar), '') as licence_number,
    nullif(trim("NAME"::varchar), '') as name,
    nullif(trim("FATHER_NAME"::varchar), '') as father_name,
    nullif(trim("GENDER"::varchar), '') as gender,
    nullif(trim("DOB"::varchar), '') as dob,
    nullif(trim("BLOOD_GROUP"::varchar), '') as blood_group,
    nullif(trim("ADDRESS"::varchar), '') as address,
    nullif(trim("STATE"::varchar), '') as state,
    nullif(trim("ZIP_CODE"::varchar), '') as zip_code,
    nullif(trim("CITIZENSHIP"::varchar), '') as citizenship,
    nullif(trim("DOI"::varchar), '') as doi,
    nullif(trim("DOE"::varchar), '') as doe,
    nullif(trim("LAST_TRANSACTION_AT"::varchar), '') as last_transaction_at,
    nullif(trim("STATUS"::varchar), '') as status,
    nullif(trim("AUTH_STATUS"::varchar), '') as auth_status,
    "EXPIRY_DATE"::timestamp_ntz as expiry_date,
    "AUTH_ID"::number as auth_id,
    "CREATED_DATE"::timestamp_ntz as created_date,
    "MODIFY_DATE"::timestamp_ntz as modify_date,
    "GG_CHANGE_DATE"::timestamp_ntz as gg_change_date,
    "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('partner_test_raw', 'BJAZ_M_KYC_DRIVING_LICENCE') }}

)

select * from source
