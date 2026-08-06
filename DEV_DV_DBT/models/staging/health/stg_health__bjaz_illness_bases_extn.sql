-- Staging model for source table BJAZ_ILLNESS_BASES_EXTN (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    "ANNUAL_INCOME"::number as annual_income,
    nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
    "COVERNOTE_DATE"::timestamp_ntz as covernote_date,
    "COVERNOTE_NO"::number as covernote_no,
    "MEDICAL_EXPENSES"::number as medical_expenses,
    nullif(trim("NOMINEE_RELATION"::varchar), '') as nominee_relation,
    nullif(trim("RELATION"::varchar), '') as relation,
    nullif(trim("SPECIAL_CONDITION"::varchar), '') as special_condition,
    "SUM_INSURED"::number as sum_insured
    from {{ source('health_raw', 'BJAZ_ILLNESS_BASES_EXTN') }}

)

select * from source
