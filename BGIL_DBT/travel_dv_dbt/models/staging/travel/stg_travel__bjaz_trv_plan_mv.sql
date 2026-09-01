-- Staging model for source table BJAZ_TRV_PLAN_MV (Travel LOB).
-- Casting: TEXT/VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, TIMESTAMP/DATE -> TIMESTAMP_NTZ.
-- Key columns (hub-key components) -> canonical trimmed VARCHAR regardless of native type,
-- for stable hashing -- same convention as the Health/Partner LOB builds.
-- Types read from OPUS_TRAVEL_SCHEMA_with_DATA_TYPE.csv (real Snowflake DESCRIBE-style
-- metadata, supplied by the mapper) -- not inferred.

with source as (

    select
    nullif(trim(to_varchar("AREA")), '') as area,
    nullif(trim(to_varchar("CLAIM_COVER_DESC")), '') as claim_cover_desc,
    nullif(trim(to_varchar("COVER_CODE")), '') as cover_code,
    nullif(trim(to_varchar("COVER_DESC")), '') as cover_desc,
    nullif(trim(to_varchar("CURRENCY")), '') as currency,
    "DEDUCTABLE_AMT"::number as deductable_amt,
    nullif(trim(to_varchar("DEDUCTABLE_TIME")), '') as deductable_time,
    nullif(trim(to_varchar("DEDUCTIBLE_DESC")), '') as deductible_desc,
    "EFF_DATE"::timestamp_ntz as eff_date,
    "LIMIT"::number as limit,
    nullif(trim(to_varchar("LIMIT_DESC")), '') as limit_desc,
    "MAX_DAYS"::number as max_days,
    nullif(trim(to_varchar("PLAN_ID")), '') as plan_id,
    "SEQUENCE_COVERS"::number as sequence_covers,
    nullif(trim(to_varchar("TYPE_OF_CLAIM")), '') as type_of_claim,
    "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('travel_raw', 'BJAZ_TRV_PLAN_MV') }}

)

select * from source
