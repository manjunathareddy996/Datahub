-- Staging for source table BJAZ_HM_PRO_ASSESSMENT (run opus_health_legacy_v4). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("ASSESSMENT_EDATE")), '') as assessment_edate,
        nullif(trim(to_varchar("ASSESSMENT_SDATE")), '') as assessment_sdate,
        nullif(trim(to_varchar("ASSESS_ID")), '') as assess_id,
        nullif(trim(to_varchar("BALANCE_INSTALL")), '') as balance_install,
        nullif(trim(to_varchar("CLAIM_ID")), '') as claim_id,
        nullif(trim(to_varchar("CLID_HPMS")), '') as clid_hpms,
        nullif(trim(to_varchar("CLOSER_LETDATE")), '') as closer_letdate,
        nullif(trim(to_varchar("FINAL_DIAGNOSIS")), '') as final_diagnosis,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at,
        nullif(trim(to_varchar("PREMIUM_COLLECT")), '') as premium_collect,
        nullif(trim(to_varchar("REPUDI_DATE")), '') as repudi_date,
        nullif(trim(to_varchar("REPUDI_REMARK")), '') as repudi_remark,
        nullif(trim(to_varchar("TOT_APPROVED_AMT")), '') as tot_approved_amt,
        nullif(trim(to_varchar("TOT_CLAIMED_AMT")), '') as tot_claimed_amt,
        nullif(trim(to_varchar("TOT_DISALLOW_AMT")), '') as tot_disallow_amt
    from {{ source('health_raw', 'BJAZ_HM_PRO_ASSESSMENT') }}

)

select * from source
