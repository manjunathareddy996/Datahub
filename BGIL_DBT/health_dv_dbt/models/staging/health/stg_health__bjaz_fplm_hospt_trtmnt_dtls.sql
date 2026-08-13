-- Staging model for source table BJAZ_FPLM_HOSPT_TRTMNT_DTLS (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    "ADMISSION_DATE"::timestamp_ntz as admission_date,
    nullif(trim("ADMISSION_TIME"::varchar), '') as admission_time,
    "DISCHARGE_DATE"::timestamp_ntz as discharge_date,
    nullif(trim("DISCHARGE_TIME"::varchar), '') as discharge_time,
    nullif(trim("DOCTOR_NAME"::varchar), '') as doctor_name,
    nullif(trim("TYPE_OF_TREATMENT"::varchar), '') as type_of_treatment
    from {{ source('health_raw', 'BJAZ_FPLM_HOSPT_TRTMNT_DTLS') }}

)

select * from source
