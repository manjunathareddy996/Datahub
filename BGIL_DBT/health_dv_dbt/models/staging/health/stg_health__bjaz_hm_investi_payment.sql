-- Staging model for source table BJAZ_HM_INVESTI_PAYMENT (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim(to_varchar("CHEQUE_NO")), '') as cheque_no,
    nullif(trim(to_varchar("CLAIM_ID")), '') as claim_id,
    nullif(trim(to_varchar("CLID_HPMS")), '') as clid_hpms,
    nullif(trim(to_varchar("PART_ID")), '') as part_id
    from {{ source('health_raw', 'BJAZ_HM_INVESTI_PAYMENT') }}

)

select * from source
