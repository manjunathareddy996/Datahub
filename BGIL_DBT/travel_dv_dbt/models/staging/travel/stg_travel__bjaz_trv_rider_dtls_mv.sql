-- Staging model for source table BJAZ_TRV_RIDER_DTLS_MV (Travel LOB).
-- Casting: TEXT/VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, TIMESTAMP/DATE -> TIMESTAMP_NTZ.
-- Key columns (hub-key components) -> canonical trimmed VARCHAR regardless of native type,
-- for stable hashing -- same convention as the Health/Partner LOB builds.
-- Types read from OPUS_TRAVEL_SCHEMA_with_DATA_TYPE.csv (real Snowflake DESCRIBE-style
-- metadata, supplied by the mapper) -- not inferred.

with source as (

    select
    "NO_MEMBERS"::number as no_members,
    "NO_OF_DAYS"::number as no_of_days,
    nullif(trim(to_varchar("P_POLICY_TYPE")), '') as p_policy_type,
    nullif(trim(to_varchar("RIDER_NAME")), '') as rider_name,
    nullif(trim(to_varchar("RIDER_NO")), '') as rider_no,
    "RIDER_PREMIUM"::number as rider_premium,
    "RIDER_SI"::number as rider_si,
    nullif(trim(to_varchar("STUDENT_PLAN_YN")), '') as student_plan_yn,
    nullif(trim(to_varchar("TRV_DATA_NO")), '') as trv_data_no
    from {{ source('travel_raw', 'BJAZ_TRV_RIDER_DTLS_MV') }}

)

select * from source
