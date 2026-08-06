-- Staging model for source table BJAZ_FPLM_OD_HOSPITAL_DETAILS (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim("ADD_INFO_HOSP"::varchar), '') as add_info_hosp,
    nullif(trim("AFTER_HOSPITAL_VISIT"::varchar), '') as after_hospital_visit,
    nullif(trim("AMBULANCE_DTLS"::varchar), '') as ambulance_dtls,
    nullif(trim(to_varchar("CLAIM_ID")), '') as claim_id,
    nullif(trim("MEETING_PM_DOCTOR"::varchar), '') as meeting_pm_doctor,
    nullif(trim("TYPE_TREATMENT"::varchar), '') as type_treatment
    from {{ source('health_raw', 'BJAZ_FPLM_OD_HOSPITAL_DETAILS') }}

)

select * from source
