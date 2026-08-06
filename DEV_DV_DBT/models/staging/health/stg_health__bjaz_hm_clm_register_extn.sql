-- Staging model for source table BJAZ_HM_CLM_REGISTER_EXTN (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    "ANAESTHETIS"::number as anaesthetis,
    nullif(trim(to_varchar("CLAIM_ID")), '') as claim_id,
    nullif(trim(to_varchar("CLID_HPMS")), '') as clid_hpms,
    nullif(trim("ELIGIBLE_ROOM_CATEGORY"::varchar), '') as eligible_room_category,
    "ICU_RENT"::number as icu_rent,
    nullif(trim("MODE_OF_TREATMENT"::varchar), '') as mode_of_treatment,
    "NURSING_CHARGES"::number as nursing_charges,
    "OT"::number as ot,
    "ROOM_RENT"::number as room_rent,
    "SURGEON_FEES"::number as surgeon_fees
    from {{ source('health_raw', 'BJAZ_HM_CLM_REGISTER_EXTN') }}

)

select * from source
