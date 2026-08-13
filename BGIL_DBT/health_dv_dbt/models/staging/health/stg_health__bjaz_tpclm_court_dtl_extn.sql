-- Staging model for source table BJAZ_TPCLM_COURT_DTL_EXTN (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim(to_varchar("CLAIM_ID")), '') as claim_id,
    nullif(trim("TREATING_DOCTOR"::varchar), '') as treating_doctor
    from {{ source('health_raw', 'BJAZ_TPCLM_COURT_DTL_EXTN') }}

)

select * from source
