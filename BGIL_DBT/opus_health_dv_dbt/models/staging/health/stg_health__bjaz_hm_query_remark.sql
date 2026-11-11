-- Staging for source table BJAZ_HM_QUERY_REMARK (run opus_health_legacy_v4). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("CLAIM_ID")), '') as claim_id,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at,
        nullif(trim(to_varchar("QUERY_REMARK")), '') as query_remark
    from {{ source('health_raw', 'BJAZ_HM_QUERY_REMARK') }}

)

select * from source
