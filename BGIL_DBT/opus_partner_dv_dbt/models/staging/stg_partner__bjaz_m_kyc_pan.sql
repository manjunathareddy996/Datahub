{{ config(materialized='view') }}

-- Staging model for source table BJAZ_M_KYC_PAN (Partner + KYC scope).
-- Casting: TEXT/VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP ->
-- TIMESTAMP_NTZ. Key columns (hub-key components) -> canonical trimmed VARCHAR
-- regardless of native type, for stable hashing -- the baseline's own convention.

with source as (

    select
    "PAN_ID"::number as pan_id,
    nullif(trim("PAN_CATEGORY"::varchar), '') as pan_category,
    nullif(trim("PAN_NUMBER"::varchar), '') as pan_number,
    nullif(trim("NAME"::varchar), '') as name,
    nullif(trim("STATUS"::varchar), '') as status,
    nullif(trim("AUTH_STATUS"::varchar), '') as auth_status,
    try_to_timestamp_ntz(regexp_replace("EXPIRY_DATE"::varchar, '^Z[ ]*', '')) as expiry_date,
    "AUTH_ID"::number as auth_id,
    try_to_timestamp_ntz(regexp_replace("CREATED_DATE"::varchar, '^Z[ ]*', '')) as created_date,
    try_to_timestamp_ntz(regexp_replace("MODIFY_DATE"::varchar, '^Z[ ]*', '')) as modify_date,
    try_to_timestamp_ntz(regexp_replace("GG_CHANGE_DATE"::varchar, '^Z[ ]*', '')) as gg_change_date,
    to_timestamp_ntz(regexp_replace("INC_JOB_UPDATED_AT"::varchar, '^Z[ ]*', '')) as inc_job_updated_at
    from {{ source('partner_test_raw', 'BJAZ_M_KYC_PAN') }}

)

select * from source
