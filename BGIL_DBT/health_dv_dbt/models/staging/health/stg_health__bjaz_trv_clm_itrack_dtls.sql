-- Staging model for source table BJAZ_TRV_CLM_ITRACK_DTLS (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    "DATE_OF_ADMISSION"::timestamp_ntz as date_of_admission,
    "DATE_OF_DISCHARGE"::timestamp_ntz as date_of_discharge,
    nullif(trim("DIAGNOSIS"::varchar), '') as diagnosis,
    nullif(trim("DOCTOR_NAME"::varchar), '') as doctor_name,
    nullif(trim("EMP_CERT_NO"::varchar), '') as emp_cert_no,
    nullif(trim(to_varchar("ITRACK_NO")), '') as itrack_no,
    nullif(trim(to_varchar("POLICY_NO")), '') as policy_no,
    nullif(trim("TREATMENT_TAKEN"::varchar), '') as treatment_taken
    from {{ source('health_raw', 'BJAZ_TRV_CLM_ITRACK_DTLS') }}

)

select * from source
