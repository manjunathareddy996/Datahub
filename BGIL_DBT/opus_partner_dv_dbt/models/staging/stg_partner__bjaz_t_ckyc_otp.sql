{{ config(materialized='view') }}

-- Staging model for source table BJAZ_T_CKYC_OTP (Partner + KYC scope).
-- Casting: TEXT/VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP ->
-- TIMESTAMP_NTZ. Key columns (hub-key components) -> canonical trimmed VARCHAR
-- regardless of native type, for stable hashing -- the baseline's own convention.

with source as (

    select
    "CKYC_OP_ID"::number as ckyc_op_id,
    "INCOMING_ID"::number as incoming_id,
    nullif(trim("BUSINESS_UNIT"::varchar), '') as business_unit,
    nullif(trim("FIELD_TYPE"::varchar), '') as field_type,
    nullif(trim("FIELD_VALUE"::varchar), '') as field_value,
    nullif(trim("CKYC_REFERENCE_ID"::varchar), '') as ckyc_reference_id,
    "SEARCH_ID"::number as search_id,
    nullif(trim("OTP_STATUS"::varchar), '') as otp_status,
    try_to_timestamp_ntz(regexp_replace("CREATED_DATE"::varchar, '^Z[ ]*', '')) as created_date,
    try_to_timestamp_ntz(regexp_replace("MODIFY_DATE"::varchar, '^Z[ ]*', '')) as modify_date,
    nullif(trim("REQUEST_ID"::varchar), '') as request_id,
    nullif(trim("MOBILE_NUMBER"::varchar), '') as mobile_number,
    nullif(trim("CATEGORY"::varchar), '') as category,
    nullif(trim("INPUT"::varchar), '') as input,
    to_timestamp_ntz(regexp_replace("INC_JOB_UPDATED_AT"::varchar, '^Z[ ]*', '')) as inc_job_updated_at
    from {{ source('partner_test_raw', 'BJAZ_T_CKYC_OTP') }}

)

select * from source
