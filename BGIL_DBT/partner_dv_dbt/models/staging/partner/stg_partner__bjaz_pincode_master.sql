-- Staging model for source table BJAZ_PINCODE_MASTER (Partner LOB).
-- Casting: TEXT/VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, TIMESTAMP/DATE -> TIMESTAMP_NTZ.
-- Key columns (hub-key components) -> canonical trimmed VARCHAR regardless of native type,
-- for stable hashing -- same convention as the Health LOB build.

with source as (

    select
    nullif(trim(to_varchar("PINCODE")), '') as pincode,
    nullif(trim("CITY"::varchar), '') as city,
    nullif(trim("STATE"::varchar), '') as state,
    nullif(trim("ZONE_PIN"::varchar), '') as zone_pin,
    nullif(trim("AREA"::varchar), '') as area,
    nullif(trim("ZONE1"::varchar), '') as zone1,
    nullif(trim("ZONE2"::varchar), '') as zone2,
    "STDCODE"::number as stdcode,
    nullif(trim("SOURCE_PIN"::varchar), '') as source_pin,
    nullif(trim("MIGRATED_YN"::varchar), '') as migrated_yn,
    "PID_CNT"::number as pid_cnt,
    "GG_CHANGE_DATE"::timestamp_ntz as gg_change_date,
    "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('partner_raw', 'BJAZ_PINCODE_MASTER') }}

)

select * from source
