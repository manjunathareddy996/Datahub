-- Staging model for source table BJAZ_SCRUTINY_IP_DTLS (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    "DAUGHTERS"::number as daughters,
    nullif(trim(to_varchar("PARTNER_ID")), '') as partner_id,
    nullif(trim(to_varchar("SCRUTINY_NO")), '') as scrutiny_no
    from {{ source('health_raw', 'BJAZ_SCRUTINY_IP_DTLS') }}

)

select * from source
