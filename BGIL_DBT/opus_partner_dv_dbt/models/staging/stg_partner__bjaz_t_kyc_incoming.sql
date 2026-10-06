{{ config(materialized='view') }}

-- Staging model for source table BJAZ_T_KYC_INCOMING (Partner + KYC scope).
-- Casting: TEXT/VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP ->
-- TIMESTAMP_NTZ. Key columns (hub-key components) -> canonical trimmed VARCHAR
-- regardless of native type, for stable hashing -- the baseline's own convention.

with source as (

    select
    "INCOMING_ID"::number as incoming_id,
    "TOKEN_ID"::number as token_id,
    nullif(trim("BUSINESS_UNIT"::varchar), '') as business_unit,
    nullif(trim("SEARCH_CATEGORY"::varchar), '') as search_category,
    nullif(trim("SEARCH_INPUT"::varchar), '') as search_input,
    nullif(trim("FILE_NUMBER"::varchar), '') as file_number,
    nullif(trim("CUSTOMER_TYPE"::varchar), '') as customer_type,
    nullif(trim("FULL_NAME"::varchar), '') as full_name,
    nullif(trim("DOB"::varchar), '') as dob,
    nullif(trim("GENDER"::varchar), '') as gender,
    nullif(trim("FIELD_TYPE"::varchar), '') as field_type,
    nullif(trim("FIELD_VALUE"::varchar), '') as field_value,
    nullif(trim("ORDER_NUMBER"::varchar), '') as order_number,
    nullif(trim("KYC_TYPE"::varchar), '') as kyc_type,
    nullif(trim("KYC_MODE"::varchar), '') as kyc_mode,
    nullif(trim("RETURN_URL"::varchar), '') as return_url,
    nullif(trim("UDF1"::varchar), '') as udf1,
    nullif(trim("UDF2"::varchar), '') as udf2,
    nullif(trim("UDF3"::varchar), '') as udf3,
    nullif(trim("UDF4"::varchar), '') as udf4,
    nullif(trim("UDF5"::varchar), '') as udf5,
    nullif(trim("RESERVED_FIELD1"::varchar), '') as reserved_field1,
    nullif(trim("RESERVED_FIELD2"::varchar), '') as reserved_field2,
    try_to_timestamp_ntz(regexp_replace("CREATED_DATE"::varchar, '^Z[ ]*', '')) as created_date,
    try_to_timestamp_ntz(regexp_replace("MODIFY_DATE"::varchar, '^Z[ ]*', '')) as modify_date,
    nullif(trim("BUSINESS_TYPE"::varchar), '') as business_type,
    cast(null as number) as premium_amount,  -- PREMIUM_AMOUNT not present in source table
    to_timestamp_ntz(regexp_replace("INC_JOB_UPDATED_AT"::varchar, '^Z[ ]*', '')) as inc_job_updated_at
    from {{ source('partner_test_raw', 'BJAZ_T_KYC_INCOMING') }}

)

select * from source
