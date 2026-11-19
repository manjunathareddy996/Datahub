-- Staging for source table BJAZ_WAP_MOTOR_IW_ASSIST. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("USER_ID")), '') as user_id,
        nullif(trim(to_varchar("MOBILE_NO")), '') as mobile_no,
        nullif(trim(to_varchar("CUSTOMER_NAME")), '') as customer_name,
        nullif(trim(to_varchar("ASSIST_MODE")), '') as assist_mode,
        nullif(trim(to_varchar("PUSHED_YN")), '') as pushed_yn,
        nullif(trim(to_varchar("UPDATE_ON")), '') as update_on,
        nullif(trim(to_varchar("SOS_ID")), '') as sos_id,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_test_raw', 'BJAZ_WAP_MOTOR_IW_ASSIST') }}

)

select * from source
