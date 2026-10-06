{{ config(materialized='view') }}

-- Staging model for source table BJAZ_M_KYC_VOTER (Partner + KYC scope).
-- Casting: TEXT/VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP ->
-- TIMESTAMP_NTZ. Key columns (hub-key components) -> canonical trimmed VARCHAR
-- regardless of native type, for stable hashing -- the baseline's own convention.

with source as (

    select
    "VOTER_ID"::number as voter_id,
    nullif(trim("VOTER_NUMBER"::varchar), '') as voter_number,
    nullif(trim("NAME"::varchar), '') as name,
    nullif(trim("RELATIVE_NAME"::varchar), '') as relative_name,
    nullif(trim("AGE"::varchar), '') as age,
    nullif(trim("GENDER"::varchar), '') as gender,
    nullif(trim("PART_NAME"::varchar), '') as part_name,
    nullif(trim("DISTRICT"::varchar), '') as district,
    nullif(trim("STATE"::varchar), '') as state,
    nullif(trim("LAST_UPDATE"::varchar), '') as last_update,
    nullif(trim("STATUS"::varchar), '') as status,
    nullif(trim("AUTH_STATUS"::varchar), '') as auth_status,
    "EXPIRY_DATE"::timestamp_ntz as expiry_date,
    "AUTH_ID"::number as auth_id,
    "CREATED_DATE"::timestamp_ntz as created_date,
    "MODIFY_DATE"::timestamp_ntz as modify_date,
    "GG_CHANGE_DATE"::timestamp_ntz as gg_change_date,
    "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('partner_test_raw', 'BJAZ_M_KYC_VOTER') }}

)

select * from source
