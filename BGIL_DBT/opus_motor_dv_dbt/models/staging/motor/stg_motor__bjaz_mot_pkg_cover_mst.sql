-- Staging for source table BJAZ_MOT_PKG_COVER_MST. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("COVER_CODE")), '') as cover_code,
        nullif(trim(to_varchar("COVER_DESC")), '') as cover_desc,
        nullif(trim(to_varchar("STATUS")), '') as status,
        nullif(trim(to_varchar("VEH_MAX_AGE")), '') as veh_max_age,
        nullif(trim(to_varchar("USER_NAME")), '') as user_name,
        nullif(trim(to_varchar("ENTRY_DATE")), '') as entry_date,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_test_raw', 'BJAZ_MOT_PKG_COVER_MST') }}

)

select * from source
