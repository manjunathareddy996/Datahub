-- Staging for source table BJAZ_GMC_BASES_EXTN (run opus_health_delta3). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("action_code")), '') as action_code,
        nullif(trim(to_varchar("clauses")), '') as clauses,
        nullif(trim(to_varchar("comments")), '') as comments,
        nullif(trim(to_varchar("contract_id")), '') as contract_id,
        nullif(trim(to_varchar("exclusions")), '') as exclusions,
        nullif(trim(to_varchar("family_includes")), '') as family_includes,
        nullif(trim(to_varchar("first_policy_ref")), '') as first_policy_ref,
        nullif(trim(to_varchar("inception_date")), '') as inception_date,
        nullif(trim(to_varchar("members_per_family")), '') as members_per_family,
        nullif(trim(to_varchar("parents_si_limit")), '') as parents_si_limit,
        nullif(trim(to_varchar("previous_version")), '') as previous_version,
        nullif(trim(to_varchar("relationship")), '') as relationship,
        nullif(trim(to_varchar("reversing_version")), '') as reversing_version,
        nullif(trim(to_varchar("risk_covered")), '') as risk_covered,
        nullif(trim(to_varchar("sp_conditions")), '') as sp_conditions,
        nullif(trim(to_varchar("sp_perils")), '') as sp_perils,
        nullif(trim(to_varchar("top_indicator")), '') as top_indicator,
        nullif(trim(to_varchar("version_no")), '') as version_no,
        nullif(trim(to_varchar("warrenties")), '') as warrenties
    from {{ source('health_raw', 'BJAZ_GMC_BASES_EXTN') }}

)

select * from source
