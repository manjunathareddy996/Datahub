-- Staging model for source table BJAZ_CLM_SUPP_EXTN (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim(to_varchar("IMD_CODE")), '') as imd_code,
    nullif(trim(to_varchar("LOCATION_CODE")), '') as location_code,
    nullif(trim(to_varchar("LOC_CODE")), '') as loc_code,
    "MRG_ANNIVERSIRY"::timestamp_ntz as mrg_anniversiry,
    nullif(trim(to_varchar("PARTNER_ID")), '') as partner_id,
    nullif(trim(to_varchar("SUB_IMD_CODE")), '') as sub_imd_code
    from {{ source('health_raw', 'BJAZ_CLM_SUPP_EXTN') }}

)

select * from source
