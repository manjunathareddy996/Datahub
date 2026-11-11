-- Staging for source table BJAZ_CTNGY_COVERS_EXT (run opus_health_v2). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("ACTION_CODE")), '') as action_code,
        nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
        nullif(trim(to_varchar("COVER_CODE")), '') as cover_code,
        nullif(trim(to_varchar("COVER_NO")), '') as cover_no,
        nullif(trim(to_varchar("COVER_PREM")), '') as cover_prem,
        nullif(trim(to_varchar("PARTITION_NO")), '') as partition_no,
        nullif(trim(to_varchar("PLAN_ID")), '') as plan_id,
        nullif(trim(to_varchar("SCHEME_CODE")), '') as scheme_code,
        nullif(trim(to_varchar("SCHEME_VERSION")), '') as scheme_version,
        nullif(trim(to_varchar("SECTION_ID")), '') as section_id,
        nullif(trim(to_varchar("VERSION_NO")), '') as version_no
    from {{ source('health_raw', 'BJAZ_CTNGY_COVERS_EXT') }}

)

select * from source
