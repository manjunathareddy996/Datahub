-- Staging for source table BJAZ_HM_ORPHAN_REG (run opus_health_legacy_v4). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("ADDRESS")), '') as address,
        nullif(trim(to_varchar("AGE")), '') as age,
        nullif(trim(to_varchar("CLAIM_ID")), '') as claim_id,
        nullif(trim(to_varchar("CLAIM_TYPE")), '') as claim_type,
        nullif(trim(to_varchar("COMPANY_NAME")), '') as company_name,
        nullif(trim(to_varchar("EMPLOYEE_NAME")), '') as employee_name,
        nullif(trim(to_varchar("END_DATE")), '') as end_date,
        nullif(trim(to_varchar("GENDER")), '') as gender,
        nullif(trim(to_varchar("IDCARDNO")), '') as idcardno,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at,
        nullif(trim(to_varchar("ORPHAN_CLOSE_REMARK")), '') as orphan_close_remark,
        nullif(trim(to_varchar("ORPHAN_CLOSE_YN")), '') as orphan_close_yn,
        nullif(trim(to_varchar("ORPHAN_DATE")), '') as orphan_date,
        nullif(trim(to_varchar("ORPHAN_FOLLOW_FLAG")), '') as orphan_follow_flag,
        nullif(trim(to_varchar("ORPHAN_INTI_DATE")), '') as orphan_inti_date,
        nullif(trim(to_varchar("ORPHAN_LOC")), '') as orphan_loc,
        nullif(trim(to_varchar("ORPHAN_REMARK")), '') as orphan_remark,
        nullif(trim(to_varchar("PATIENT_NAME")), '') as patient_name,
        nullif(trim(to_varchar("POLICY_NUMBER")), '') as policy_number,
        nullif(trim(to_varchar("RELATION")), '') as relation,
        nullif(trim(to_varchar("START_DATE")), '') as start_date,
        nullif(trim(to_varchar("SUMINSURED")), '') as suminsured,
        nullif(trim(to_varchar("TELEPHONE_NO")), '') as telephone_no
    from {{ source('health_raw', 'BJAZ_HM_ORPHAN_REG') }}

)

select * from source
