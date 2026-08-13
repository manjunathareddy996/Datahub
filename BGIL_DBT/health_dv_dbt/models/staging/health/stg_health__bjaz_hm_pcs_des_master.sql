-- Staging model for source table BJAZ_HM_PCS_DES_MASTER (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim(to_varchar("PCS_ID")), '') as pcs_id
    from {{ source('health_raw', 'BJAZ_HM_PCS_DES_MASTER') }}

)

select * from source
