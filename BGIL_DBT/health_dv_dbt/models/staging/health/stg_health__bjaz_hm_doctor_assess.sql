-- Staging model for source table BJAZ_HM_DOCTOR_ASSESS (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim(to_varchar("CLAIM_ID")), '') as claim_id,
    nullif(trim(to_varchar("CLID_HPMS")), '') as clid_hpms,
    nullif(trim(to_varchar("DOCASESS_ID")), '') as docasess_id,
    "MEDICAL_MGMT_DATE"::timestamp_ntz as medical_mgmt_date,
    nullif(trim("MEDICAL_MGMT_TYPE"::varchar), '') as medical_mgmt_type,
    "PACKAGE_CHARGE"::number as package_charge
    from {{ source('health_raw', 'BJAZ_HM_DOCTOR_ASSESS') }}

)

select * from source
