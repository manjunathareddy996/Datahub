-- Staging model for source table BJAZ_CTNGY_GC_MEM_DATA (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    "AGE"::number as age,
    nullif(trim("MEMBER_NAME"::varchar), '') as member_name,
    nullif(trim(to_varchar("PARTNER_ID")), '') as partner_id,
    nullif(trim(to_varchar("POLICY_REF")), '') as policy_ref,
    nullif(trim("RELATION"::varchar), '') as relation
    from {{ source('health_raw', 'BJAZ_CTNGY_GC_MEM_DATA') }}

)

select * from source
