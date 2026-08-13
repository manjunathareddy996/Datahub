-- Staging model for source table BJAZ_HM_PRO_ASSESSMENT (Health LOB).
-- Casting: VARCHAR2/CHAR -> trimmed VARCHAR, NUMBER -> NUMBER, DATE/TIMESTAMP -> TIMESTAMP_NTZ.
-- Key columns (hub/link/composite-key components) -> canonical trimmed VARCHAR regardless of
-- native type, for stable hashing. See docs/HEALTH_DV_BUILD_NOTES.md "Key normalisation".

with source as (

    select
    "ASSESSMENT_EDATE"::timestamp_ntz as assessment_edate,
    "ASSESSMENT_SDATE"::timestamp_ntz as assessment_sdate,
    nullif(trim(to_varchar("ASSESS_ID")), '') as assess_id,
    nullif(trim(to_varchar("CLAIM_ID")), '') as claim_id,
    nullif(trim(to_varchar("CLID_HPMS")), '') as clid_hpms,
    "CLOSER_LETDATE"::timestamp_ntz as closer_letdate,
    "PREMIUM_COLLECT"::number as premium_collect,
    "REPUDI_DATE"::timestamp_ntz as repudi_date,
    nullif(trim("REPUDI_REMARK"::varchar), '') as repudi_remark,
    "TOT_APPROVED_AMT"::number as tot_approved_amt,
    "TOT_CLAIMED_AMT"::number as tot_claimed_amt,
    "TOT_DISALLOW_AMT"::number as tot_disallow_amt
    from {{ source('health_raw', 'BJAZ_HM_PRO_ASSESSMENT') }}

)

select * from source
