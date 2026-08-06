-- Staging model for source table BGIL_GMC_FINAL_INSTL_DATA (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    "AGE"::number as age,
    "ANNUAL_PREMIUM"::number as annual_premium,
    "DATE_OF_BIRTH"::timestamp_ntz as date_of_birth,
    "DOJ"::timestamp_ntz as doj,
    nullif(trim("DWH_RELATIONSHIP"::varchar), '') as dwh_relationship,
    nullif(trim(to_varchar("EMP_CODE")), '') as emp_code,
    nullif(trim("EMP_NAME"::varchar), '') as emp_name,
    nullif(trim("GRADE_BUCKET"::varchar), '') as grade_bucket,
    nullif(trim("GRADE_CODE"::varchar), '') as grade_code,
    "INSTALLMENTS"::number as installments,
    "POLICY_EXPIRY_DATE"::timestamp_ntz as policy_expiry_date,
    nullif(trim(to_varchar("POLICY_NO")), '') as policy_no,
    "POLICY_START_DATE"::timestamp_ntz as policy_start_date,
    nullif(trim("RELATION"::varchar), '') as relation,
    "SUM_INUSRED"::number as sum_inusred
    from {{ source('health_raw', 'BGIL_GMC_FINAL_INSTL_DATA') }}

)

select * from source
