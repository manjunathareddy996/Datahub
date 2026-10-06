{{ config(materialized='view') }}

-- Staging model for source table BJAZ_M_KYC_GSTN (Partner + KYC scope).
-- Casting: TEXT/VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP ->
-- TIMESTAMP_NTZ. Key columns (hub-key components) -> canonical trimmed VARCHAR
-- regardless of native type, for stable hashing -- the baseline's own convention.

with source as (

    select
    "GSTIN_ID"::number as gstin_id,
    nullif(trim("BUSINESS_TYPE"::varchar), '') as business_type,
    nullif(trim("GSTIN_NUMBER"::varchar), '') as gstin_number,
    nullif(trim("TRADE_NAME"::varchar), '') as trade_name,
    nullif(trim("LEGAL_NAME"::varchar), '') as legal_name,
    nullif(trim("BUSINESS_PLACE"::varchar), '') as business_place,
    nullif(trim("EFFECTIVE_CANCELLATION_DATE"::varchar), '') as effective_cancellation_date,
    nullif(trim("EFFECTIVE_REGISTRATION_DATE"::varchar), '') as effective_registration_date,
    nullif(trim("STATUS"::varchar), '') as status,
    nullif(trim("AUTH_STATUS"::varchar), '') as auth_status,
    try_to_timestamp_ntz(regexp_replace("EXPIRY_DATE"::varchar, '^Z[ ]*', '')) as expiry_date,
    "AUTH_ID"::number as auth_id,
    try_to_timestamp_ntz(regexp_replace("CREATED_DATE"::varchar, '^Z[ ]*', '')) as created_date,
    try_to_timestamp_ntz(regexp_replace("MODIFY_DATE"::varchar, '^Z[ ]*', '')) as modify_date,
    try_to_timestamp_ntz(regexp_replace("GG_CHANGE_DATE"::varchar, '^Z[ ]*', '')) as gg_change_date,
    cast(null as varchar) as taxpayer_type,  -- TAXPAYER_TYPE not present in source table
    cast(null as varchar) as gstin_status,  -- GSTIN_STATUS not present in source table
    to_timestamp_ntz(regexp_replace("INC_JOB_UPDATED_AT"::varchar, '^Z[ ]*', '')) as inc_job_updated_at
    from {{ source('partner_test_raw', 'BJAZ_M_KYC_GSTN') }}

)

select * from source
