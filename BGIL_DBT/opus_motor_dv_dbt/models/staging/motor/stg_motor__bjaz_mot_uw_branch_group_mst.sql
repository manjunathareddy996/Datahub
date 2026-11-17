-- Staging for source table BJAZ_MOT_UW_BRANCH_GROUP_MST. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("BRANCH_CODE")), '') as branch_code,
        nullif(trim(to_varchar("GROUP_CODE")), '') as group_code,
        nullif(trim(to_varchar("USER_NAME")), '') as user_name,
        nullif(trim(to_varchar("ENTRY_DATE")), '') as entry_date,
        nullif(trim(to_varchar("STATUS")), '') as status,
        nullif(trim(to_varchar("EFFECTIVE_DATE")), '') as effective_date,
        nullif(trim(to_varchar("INTERMEDIARY_ID")), '') as intermediary_id,
        nullif(trim(to_varchar("ZONE")), '') as zone,
        nullif(trim(to_varchar("ZM_ID")), '') as zm_id,
        nullif(trim(to_varchar("GG_CHANGE_DATE")), '') as gg_change_date,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_raw', 'BJAZ_MOT_UW_BRANCH_GROUP_MST') }}

)

select * from source
