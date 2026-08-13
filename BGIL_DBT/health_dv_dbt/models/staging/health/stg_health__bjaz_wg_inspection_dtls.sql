-- Staging model for source table BJAZ_WG_INSPECTION_DTLS (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim(to_varchar("CLAIM_ID")), '') as claim_id,
    nullif(trim("DIAGNOSIS_REMARKS"::varchar), '') as diagnosis_remarks
    from {{ source('health_raw', 'BJAZ_WG_INSPECTION_DTLS') }}

)

select * from source
