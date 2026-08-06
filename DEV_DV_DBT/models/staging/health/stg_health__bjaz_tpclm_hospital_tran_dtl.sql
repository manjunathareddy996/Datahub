-- Staging model for source table BJAZ_TPCLM_HOSPITAL_TRAN_DTL (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    "ADMISSION_DATE"::timestamp_ntz as admission_date,
    nullif(trim("ADMISSION_TIME"::varchar), '') as admission_time,
    nullif(trim(to_varchar("CLAIM_ID")), '') as claim_id,
    "DISCHARGE_DATE"::timestamp_ntz as discharge_date,
    nullif(trim("DISCHARGE_TIME"::varchar), '') as discharge_time,
    "REASON_BILL_REJECTION"::number as reason_bill_rejection,
    "TREATMENT_TYPE"::number as treatment_type
    from {{ source('health_raw', 'BJAZ_TPCLM_HOSPITAL_TRAN_DTL') }}

)

select * from source
