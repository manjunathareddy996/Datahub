-- Staging model for source table BJAZ_HCS_PLANSI_MAPP (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    "AIR_AMBULANCE_SI"::number as air_ambulance_si,
    "DONOR_SI"::number as donor_si,
    "EFFECTIVE_DT"::timestamp_ntz as effective_dt,
    "HOSP_SI"::number as hosp_si,
    "MATERNITY_SI"::number as maternity_si,
    "OPD_SI"::number as opd_si,
    "PHY_SI"::number as phy_si,
    nullif(trim("PLAN_NAME"::varchar), '') as plan_name,
    "PLAN_SI"::number as plan_si,
    nullif(trim(to_varchar("PRODUCT_CODE")), '') as product_code,
    "RECOVERY_THEFT_SI"::number as recovery_theft_si
    from {{ source('health_raw', 'BJAZ_HCS_PLANSI_MAPP') }}

)

select * from source
