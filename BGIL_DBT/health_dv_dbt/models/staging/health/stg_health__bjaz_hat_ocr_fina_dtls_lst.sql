-- Staging model for source table BJAZ_HAT_OCR_FINA_DTLS_LST (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim(to_varchar("CASE_ID")), '') as case_id,
    nullif(trim("INWARD_NO"::varchar), '') as inward_no,
    nullif(trim("NAME"::varchar), '') as name,
    nullif(trim("TOTAL"::varchar), '') as total
    from {{ source('health_raw', 'BJAZ_HAT_OCR_FINA_DTLS_LST') }}

)

select * from source
