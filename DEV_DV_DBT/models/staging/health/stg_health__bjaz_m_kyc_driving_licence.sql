-- Staging model for source table BJAZ_M_KYC_DRIVING_LICENCE (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim("BLOOD_GROUP"::varchar), '') as blood_group
    from {{ source('health_raw', 'BJAZ_M_KYC_DRIVING_LICENCE') }}

)

select * from source
