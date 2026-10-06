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
    "EXPIRY_DATE"::timestamp_ntz as expiry_date,
    "AUTH_ID"::number as auth_id,
    "CREATED_DATE"::timestamp_ntz as created_date,
    "MODIFY_DATE"::timestamp_ntz as modify_date,
    "GG_CHANGE_DATE"::timestamp_ntz as gg_change_date,
    cast(null as varchar) as taxpayer_type,  -- TAXPAYER_TYPE not present in source table
    cast(null as varchar) as gstin_status,  -- GSTIN_STATUS not present in source table
    "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('partner_test_raw', 'BJAZ_M_KYC_GSTN') }}

)

select * from source
