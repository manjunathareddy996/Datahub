-- Staging for source table BJAZ_CTNGY_NR_BASES_EXTN (run opus_health_v2). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at,
        nullif(trim(to_varchar("PARAM_ID")), '') as param_id,
        nullif(trim(to_varchar("PARAM_REF")), '') as param_ref,
        nullif(trim(to_varchar("PARAM_VALUE")), '') as param_value,
        nullif(trim(to_varchar("SCHEME_CODE")), '') as scheme_code,
        nullif(trim(to_varchar("SCHEME_VERSION")), '') as scheme_version
    from {{ source('health_raw', 'BJAZ_CTNGY_NR_BASES_EXTN') }}

)

select * from source
