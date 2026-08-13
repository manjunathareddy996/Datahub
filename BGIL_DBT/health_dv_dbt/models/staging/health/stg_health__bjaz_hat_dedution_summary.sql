-- Staging model for source table BJAZ_HAT_DEDUTION_SUMMARY (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim(to_varchar("CASE_ID")), '') as case_id,
    "DISC_TOTAL"::number as disc_total,
    "NON_PAYABLE_TOTAL"::number as non_payable_total
    from {{ source('health_raw', 'BJAZ_HAT_DEDUTION_SUMMARY') }}

)

select * from source
