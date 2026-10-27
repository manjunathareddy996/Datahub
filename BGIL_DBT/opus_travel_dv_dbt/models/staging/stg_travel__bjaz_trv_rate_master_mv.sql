-- Staging model for source table BJAZ_TRV_RATE_MASTER_MV (Travel LOB).
-- Casting: TEXT/VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, TIMESTAMP/DATE -> TIMESTAMP_NTZ.
-- Key columns (hub-key components) -> canonical trimmed VARCHAR regardless of native type,
-- for stable hashing -- same convention as the Health/Partner LOB builds.
-- Types read from OPUS_TRAVEL_SCHEMA_with_DATA_TYPE.csv (real Snowflake DESCRIBE-style
-- metadata, supplied by the mapper) -- not inferred.

with source as (

    select
    "AGE_FROM"::number as age_from,
    "AGE_TO"::number as age_to,
    nullif(trim(to_varchar("AREA")), '') as area,
    nullif(trim(to_varchar("CFT_MST_CONTRACT_ID")), '') as cft_mst_contract_id,
    nullif(trim(to_varchar("CFT_YN")), '') as cft_yn,
    "DAYS_FROM"::number as days_from,
    "DAYS_TO"::number as days_to,
    "EFFECTIVE_DATE"::timestamp_ntz as effective_date,
    nullif(trim(to_varchar("PLAN")), '') as plan,
    "PREMIUM"::number as premium,
    nullif(trim(to_varchar("USER_TYPE")), '') as user_type,
    "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('travel_raw', 'BJAZ_TRV_RATE_MASTER_MV') }}

)

select * from source
