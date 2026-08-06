-- Staging model for source table BJAZ_HM_EXCLUSION_MASTER (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim("EXCLUSION_CODE"::varchar), '') as exclusion_code,
    nullif(trim("EXCLUSION_DETAIL"::varchar), '') as exclusion_detail,
    "EXCLUSION_ID"::number as exclusion_id,
    nullif(trim("EXCLUSION_SUB_ID"::varchar), '') as exclusion_sub_id
    from {{ source('health_raw', 'BJAZ_HM_EXCLUSION_MASTER') }}

)

select * from source
