-- Staging model for source table BJAZ_HM_ORPHAN_REG (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    nullif(trim("ADDRESS"::varchar), '') as address,
    "AGE"::number as age,
    nullif(trim(to_varchar("CLAIM_ID")), '') as claim_id,
    "CLAIM_TYPE"::number as claim_type,
    nullif(trim("EMPLOYEE_NAME"::varchar), '') as employee_name,
    "END_DATE"::timestamp_ntz as end_date,
    nullif(trim("GENDER"::varchar), '') as gender,
    nullif(trim("IDCARDNO"::varchar), '') as idcardno,
    nullif(trim("ORPHAN_CLOSE_REMARK"::varchar), '') as orphan_close_remark,
    "ORPHAN_DATE"::timestamp_ntz as orphan_date,
    "ORPHAN_FOLLOW_FLAG"::number as orphan_follow_flag,
    "ORPHAN_INTI_DATE"::timestamp_ntz as orphan_inti_date,
    nullif(trim(to_varchar("ORPHAN_LOC")), '') as orphan_loc,
    nullif(trim("ORPHAN_REMARK"::varchar), '') as orphan_remark,
    nullif(trim("PATIENT_NAME"::varchar), '') as patient_name,
    nullif(trim(to_varchar("POLICY_NUMBER")), '') as policy_number,
    nullif(trim("RELATION"::varchar), '') as relation,
    "START_DATE"::timestamp_ntz as start_date,
    "SUMINSURED"::number as suminsured,
    nullif(trim("TELEPHONE_NO"::varchar), '') as telephone_no
    from {{ source('health_raw', 'BJAZ_HM_ORPHAN_REG') }}

)

select * from source
