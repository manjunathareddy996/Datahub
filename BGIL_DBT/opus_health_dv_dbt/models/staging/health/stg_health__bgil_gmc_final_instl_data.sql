-- Staging for source table BGIL_GMC_FINAL_INSTL_DATA (run opus_health_legacy_v4). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("AGE")), '') as age,
        nullif(trim(to_varchar("ANNUAL_ER_CNTR")), '') as annual_er_cntr,
        nullif(trim(to_varchar("ANNUAL_PREMIUM")), '') as annual_premium,
        nullif(trim(to_varchar("CLAIMN_REG_FLAG")), '') as claimn_reg_flag,
        nullif(trim(to_varchar("DATE_OF_BIRTH")), '') as date_of_birth,
        nullif(trim(to_varchar("DOJ")), '') as doj,
        nullif(trim(to_varchar("DWH_RELATIONSHIP")), '') as dwh_relationship,
        nullif(trim(to_varchar("ELIGIBLE_DAYS")), '') as eligible_days,
        nullif(trim(to_varchar("EMP_CODE")), '') as emp_code,
        nullif(trim(to_varchar("EMP_NAME")), '') as emp_name,
        nullif(trim(to_varchar("FINAL_PAYABLE")), '') as final_payable,
        nullif(trim(to_varchar("GRADE_BUCKET")), '') as grade_bucket,
        nullif(trim(to_varchar("GRADE_CODE")), '') as grade_code,
        nullif(trim(to_varchar("INSTALLMENTS")), '') as installments,
        nullif(trim(to_varchar("POLICY_EXPIRY_DATE")), '') as policy_expiry_date,
        nullif(trim(to_varchar("POLICY_NO")), '') as policy_no,
        nullif(trim(to_varchar("POLICY_START_DATE")), '') as policy_start_date,
        nullif(trim(to_varchar("PRORATA_ER_CNTR")), '') as prorata_er_cntr,
        nullif(trim(to_varchar("PRORATA_PREMIUM")), '') as prorata_premium,
        nullif(trim(to_varchar("RELATION")), '') as relation,
        nullif(trim(to_varchar("SUM_INUSRED")), '') as sum_inusred
    from {{ source('health_raw', 'BGIL_GMC_FINAL_INSTL_DATA') }}

)

select * from source
