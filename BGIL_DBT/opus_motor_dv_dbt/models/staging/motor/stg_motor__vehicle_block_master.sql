-- Staging for source table VEHICLE_BLOCK_MASTER. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("OPUS_UNIQUE_ID")), '') as opus_unique_id,
        nullif(trim(to_varchar("MAXIMUS_UNIQUE_ID")), '') as maximus_unique_id,
        nullif(trim(to_varchar("UPDATE_FLAG")), '') as update_flag,
        nullif(trim(to_varchar("START_DATE")), '') as start_date,
        nullif(trim(to_varchar("END_DATE")), '') as end_date,
        nullif(trim(to_varchar("REGISTRATION_NO")), '') as registration_no,
        nullif(trim(to_varchar("ENGINE_NUMBER")), '') as engine_number,
        nullif(trim(to_varchar("CHASSIS_NUMBER")), '') as chassis_number,
        nullif(trim(to_varchar("STATUS")), '') as status,
        nullif(trim(to_varchar("PROCESS_DATE")), '') as process_date,
        nullif(trim(to_varchar("MAXIMUS_PROCESS_DATE")), '') as maximus_process_date,
        nullif(trim(to_varchar("GG_CHANGE_DATE")), '') as gg_change_date,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_test_raw', 'VEHICLE_BLOCK_MASTER') }}

)

select * from source
