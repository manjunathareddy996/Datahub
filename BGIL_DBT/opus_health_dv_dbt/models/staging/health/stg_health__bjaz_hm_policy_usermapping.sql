-- Staging for source table BJAZ_HM_POLICY_USERMAPPING (run opus_health_legacy_v4). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at,
        nullif(trim(to_varchar("LOGINNAME")), '') as loginname,
        nullif(trim(to_varchar("POLICY_REF")), '') as policy_ref
    from {{ source('health_raw', 'BJAZ_HM_POLICY_USERMAPPING') }}

)

select * from source
