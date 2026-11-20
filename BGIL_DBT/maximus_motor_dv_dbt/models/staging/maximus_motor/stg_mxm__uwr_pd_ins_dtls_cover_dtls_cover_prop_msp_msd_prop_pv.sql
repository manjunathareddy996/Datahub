-- Staging for source view MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW. Every column trimmed varchar, including the shred keys
-- KEY_HASH / PARENT_KEY_HASH / FOREIGN_KEY that the central views join on.
with source as (

    select
        nullif(trim(to_varchar("FOREIGN_KEY")), '') as foreign_key,
        nullif(trim(to_varchar("PARENT_RECORD_HASH")), '') as parent_record_hash,
        nullif(trim(to_varchar("PARENT_KEY_HASH")), '') as parent_key_hash,
        nullif(trim(to_varchar("KEY_HASH")), '') as key_hash,
        nullif(trim(to_varchar("INC_JOB_CREATED_AT")), '') as inc_job_created_at,
        "REC_REFRESH_AT"::timestamp_ntz as rec_refresh_at,
        nullif(trim(to_varchar("ALLOCATION_PERCENTAGE")), '') as allocation_percentage,
        nullif(trim(to_varchar("GEOGRAPHICAL_EXTENSION")), '') as geographical_extension,
        nullif(trim(to_varchar("NAME_OF_PERSON")), '') as name_of_person,
        nullif(trim(to_varchar("NOMINEE_NAME")), '') as nominee_name,
        nullif(trim(to_varchar("NOMINEE_RELATION")), '') as nominee_relation,
        nullif(trim(to_varchar("SUM_INSURED")), '') as sum_insured
    from {{ source('maximus_motor_raw', 'MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW') }}

)

select * from source
