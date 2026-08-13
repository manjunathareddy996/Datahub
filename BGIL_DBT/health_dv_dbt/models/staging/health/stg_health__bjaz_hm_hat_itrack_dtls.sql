-- Staging model for source table BJAZ_HM_HAT_ITRACK_DTLS (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim(to_varchar("ITRACK_NO")), '') as itrack_no,
    nullif(trim(to_varchar("SCRUTINY_NO")), '') as scrutiny_no
    from {{ source('health_raw', 'BJAZ_HM_HAT_ITRACK_DTLS') }}

)

select * from source
