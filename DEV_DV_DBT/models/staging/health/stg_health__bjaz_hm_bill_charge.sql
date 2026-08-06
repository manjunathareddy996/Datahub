-- Staging model for source table BJAZ_HM_BILL_CHARGE (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    "BILL_ID"::number as bill_id,
    nullif(trim(to_varchar("CLAIM_ID")), '') as claim_id,
    nullif(trim(to_varchar("CLID_HPMS")), '') as clid_hpms
    from {{ source('health_raw', 'BJAZ_HM_BILL_CHARGE') }}

)

select * from source
