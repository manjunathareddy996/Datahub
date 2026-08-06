-- Staging model for source table BJAZ_GC_GROUP_GUARD_DTLS (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    "AGE"::number as age,
    nullif(trim(to_varchar("LG_CODE")), '') as lg_code,
    nullif(trim(to_varchar("LOCATION_CODE")), '') as location_code,
    nullif(trim(to_varchar("PARTNER_ID")), '') as partner_id,
    nullif(trim(to_varchar("PLAN_ID")), '') as plan_id,
    nullif(trim(to_varchar("POLICY_REF")), '') as policy_ref,
    nullif(trim("PREEXISTING_DISEASE"::varchar), '') as preexisting_disease,
    nullif(trim(to_varchar("PRODUCT_CODE")), '') as product_code,
    nullif(trim(to_varchar("USER_ID")), '') as user_id
    from {{ source('health_raw', 'BJAZ_GC_GROUP_GUARD_DTLS') }}

)

select * from source
