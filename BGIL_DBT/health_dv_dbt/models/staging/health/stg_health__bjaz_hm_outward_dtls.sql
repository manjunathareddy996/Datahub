-- Staging model for source table BJAZ_HM_OUTWARD_DTLS (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim(to_varchar("CLAIM_ID")), '') as claim_id,
    nullif(trim(to_varchar("CLID_HPMS")), '') as clid_hpms,
    nullif(trim(to_varchar("LOCATION_CODE")), '') as location_code,
    nullif(trim("MODE_OF_DISPATCH"::varchar), '') as mode_of_dispatch,
    nullif(trim(to_varchar("OUTWARD_ID")), '') as outward_id,
    nullif(trim("PATIENT_NAME"::varchar), '') as patient_name,
    nullif(trim(to_varchar("POLICY_REF")), '') as policy_ref
    from {{ source('health_raw', 'BJAZ_HM_OUTWARD_DTLS') }}

)

select * from source
