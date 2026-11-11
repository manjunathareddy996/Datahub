-- Staging for source table BJAZ_HM_CLAIM_REOPEN (run opus_health_v2). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("CLAIM_ID")), '') as claim_id,
        nullif(trim(to_varchar("CLID_HPMS")), '') as clid_hpms,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at,
        nullif(trim(to_varchar("REOPEN_DATE")), '') as reopen_date,
        nullif(trim(to_varchar("REOPEN_REMARK")), '') as reopen_remark,
        nullif(trim(to_varchar("UPDATED_BY")), '') as updated_by,
        nullif(trim(to_varchar("UPDATED_ON")), '') as updated_on
    from {{ source('health_raw', 'BJAZ_HM_CLAIM_REOPEN') }}

)

select * from source
