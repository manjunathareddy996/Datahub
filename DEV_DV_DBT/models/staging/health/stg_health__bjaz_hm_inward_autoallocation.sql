-- Staging model for source table BJAZ_HM_INWARD_AUTOALLOCATION (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim(to_varchar("ALLOCATE_ID")), '') as allocate_id,
    nullif(trim("ALLOCATE_TO"::varchar), '') as allocate_to,
    "BUCKET_STATUS"::number as bucket_status,
    nullif(trim("CASHLESS_IN_NO"::varchar), '') as cashless_in_no,
    nullif(trim(to_varchar("CLAIM_ID")), '') as claim_id,
    nullif(trim(to_varchar("OMNI_INWARD_NO")), '') as omni_inward_no
    from {{ source('health_raw', 'BJAZ_HM_INWARD_AUTOALLOCATION') }}

)

select * from source
