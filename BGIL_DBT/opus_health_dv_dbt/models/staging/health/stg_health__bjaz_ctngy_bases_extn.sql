-- Staging for source table BJAZ_CTNGY_BASES_EXTN (run opus_health_v2). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("ACTION_CODE")), '') as action_code,
        nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
        nullif(trim(to_varchar("CVR_CODE")), '') as cvr_code,
        nullif(trim(to_varchar("PARAM_ID")), '') as param_id,
        nullif(trim(to_varchar("PARAM_REF")), '') as param_ref,
        nullif(trim(to_varchar("PARAM_VAL")), '') as param_val,
        nullif(trim(to_varchar("PLAN_ID")), '') as plan_id,
        nullif(trim(to_varchar("SCHEME_CODE")), '') as scheme_code,
        nullif(trim(to_varchar("SCHEME_VERSION")), '') as scheme_version,
        nullif(trim(to_varchar("SECTION_ID")), '') as section_id,
        nullif(trim(to_varchar("VERSION_NO")), '') as version_no
    from {{ source('health_raw', 'BJAZ_CTNGY_BASES_EXTN') }}

)

select * from source
