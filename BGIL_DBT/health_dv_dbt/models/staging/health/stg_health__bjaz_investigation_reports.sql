-- Staging model for source table BJAZ_INVESTIGATION_REPORTS (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim("BILL_REMARKS"::varchar), '') as bill_remarks,
    nullif(trim(to_varchar("CLAIM_ID")), '') as claim_id,
    "COST_OF_TREATMENT"::number as cost_of_treatment,
    "DATE_ADMISSION"::timestamp_ntz as date_admission,
    "DATE_DISCHARGE"::timestamp_ntz as date_discharge,
    nullif(trim("DIABITIES_FINDINGS"::varchar), '') as diabities_findings,
    nullif(trim("HYPER_TENSION"::varchar), '') as hyper_tension,
    nullif(trim("LINE_OF_TREATMENT"::varchar), '') as line_of_treatment,
    "PAT_DAYS_IN_HOSPIT"::number as pat_days_in_hospit,
    nullif(trim("PRESENT_COMPLAIN"::varchar), '') as present_complain,
    nullif(trim("RELATION_INSURED"::varchar), '') as relation_insured,
    nullif(trim("RELATION_PROPOSER"::varchar), '') as relation_proposer,
    nullif(trim("TREATING_DOCTOR_NAME"::varchar), '') as treating_doctor_name,
    "VERIFIED_AGE"::number as verified_age
    from {{ source('health_raw', 'BJAZ_INVESTIGATION_REPORTS') }}

)

select * from source
