-- Staging model for source table BJAZ_HAT_CASE_OCR_DTLS (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim(to_varchar("CASE_ID")), '') as case_id,
    nullif(trim(to_varchar("CLAIM_ID")), '') as claim_id,
    nullif(trim(to_varchar("IMD_CODE")), '') as imd_code,
    nullif(trim(to_varchar("MEMBER_ID")), '') as member_id,
    nullif(trim(to_varchar("POLICY_NUMBER")), '') as policy_number,
    nullif(trim(to_varchar("PRODUCT_CODE")), '') as product_code
    from {{ source('health_raw', 'BJAZ_HAT_CASE_OCR_DTLS') }}

)

select * from source
