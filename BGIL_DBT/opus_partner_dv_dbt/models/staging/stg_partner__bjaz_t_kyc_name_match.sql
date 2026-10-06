{{ config(materialized='view') }}

-- Staging model for source table BJAZ_T_KYC_NAME_MATCH (Partner + KYC scope).
-- Casting: TEXT/VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP ->
-- TIMESTAMP_NTZ. Key columns (hub-key components) -> canonical trimmed VARCHAR
-- regardless of native type, for stable hashing -- the baseline's own convention.

with source as (

    select
    "NAME_MATCH_ID"::number as name_match_id,
    nullif(trim("BUSINESS_UNIT"::varchar), '') as business_unit,
    nullif(trim("FIELD_TYPE"::varchar), '') as field_type,
    nullif(trim("FIELD_VALUE"::varchar), '') as field_value,
    "INCOMING_ID"::number as incoming_id,
    nullif(trim("CATEGORY"::varchar), '') as category,
    nullif(trim("INPUT"::varchar), '') as input,
    nullif(trim("REQUEST_NAME"::varchar), '') as request_name,
    nullif(trim("RESPONSE_NAME"::varchar), '') as response_name,
    nullif(trim("STATUS"::varchar), '') as status,
    nullif(trim("SCORE"::varchar), '') as score,
    "REQUEST_DATE"::timestamp_ntz as request_date,
    "RESPONSE_DATE"::timestamp_ntz as response_date,
    "REFERENCE_ID"::number as reference_id,
    nullif(trim("CONFIG_FLAG"::varchar), '') as config_flag,
    "CONFIG_SCORE"::number as config_score,
    nullif(trim("REMARK"::varchar), '') as remark,
    "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('partner_test_raw', 'BJAZ_T_KYC_NAME_MATCH') }}

)

select * from source
