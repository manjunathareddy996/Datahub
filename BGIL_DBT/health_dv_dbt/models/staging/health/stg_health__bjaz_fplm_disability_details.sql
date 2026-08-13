-- Staging model for source table BJAZ_FPLM_DISABILITY_DETAILS (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim("NAME_DR_DISABILITY_CERT"::varchar), '') as name_dr_disability_cert,
    nullif(trim("QUALI_DOCTOR"::varchar), '') as quali_doctor
    from {{ source('health_raw', 'BJAZ_FPLM_DISABILITY_DETAILS') }}

)

select * from source
