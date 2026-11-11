-- Staging for source table BA_CCP_INSURED_DETAILS (run opus_health_delta3). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("action_code")), '') as action_code,
        nullif(trim(to_varchar("age")), '') as age,
        nullif(trim(to_varchar("borrower_type")), '') as borrower_type,
        nullif(trim(to_varchar("co_app_cover_req")), '') as co_app_cover_req,
        nullif(trim(to_varchar("contract_id")), '') as contract_id,
        nullif(trim(to_varchar("date_of_birth")), '') as date_of_birth,
        nullif(trim(to_varchar("first_name")), '') as first_name,
        nullif(trim(to_varchar("gender")), '') as gender,
        nullif(trim(to_varchar("height")), '') as height,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at,
        nullif(trim(to_varchar("insured_prem")), '') as insured_prem,
        nullif(trim(to_varchar("last_name")), '') as last_name,
        nullif(trim(to_varchar("middle_name")), '') as middle_name,
        nullif(trim(to_varchar("moninee_rel")), '') as moninee_rel,
        nullif(trim(to_varchar("no_of_coapp")), '') as no_of_coapp,
        nullif(trim(to_varchar("nominee_name")), '') as nominee_name,
        nullif(trim(to_varchar("object_id")), '') as object_id,
        nullif(trim(to_varchar("occupation")), '') as occupation,
        nullif(trim(to_varchar("pre_exist_reason")), '') as pre_exist_reason,
        nullif(trim(to_varchar("previous_version")), '') as previous_version,
        nullif(trim(to_varchar("proposer_pre_exist")), '') as proposer_pre_exist,
        nullif(trim(to_varchar("proposer_relation")), '') as proposer_relation,
        nullif(trim(to_varchar("reversing_version")), '') as reversing_version,
        nullif(trim(to_varchar("top_indicator")), '') as top_indicator,
        nullif(trim(to_varchar("version_no")), '') as version_no,
        nullif(trim(to_varchar("weight")), '') as weight
    from {{ source('health_raw', 'BA_CCP_INSURED_DETAILS') }}

)

select * from source
