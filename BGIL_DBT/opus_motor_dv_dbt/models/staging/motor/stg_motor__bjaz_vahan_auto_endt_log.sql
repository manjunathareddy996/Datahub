-- Staging for source table BJAZ_VAHAN_AUTO_ENDT_LOG. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("POLICY_NO")), '') as policy_no,
        nullif(trim(to_varchar("VEHICLE_ID")), '') as vehicle_id,
        nullif(trim(to_varchar("ENGINE_NO")), '') as engine_no,
        nullif(trim(to_varchar("CHASSIS_NO")), '') as chassis_no,
        nullif(trim(to_varchar("REG_NO")), '') as reg_no,
        nullif(trim(to_varchar("ENDT_NO")), '') as endt_no,
        nullif(trim(to_varchar("TERM_START_DATE")), '') as term_start_date,
        nullif(trim(to_varchar("LOG_DATE")), '') as log_date,
        nullif(trim(to_varchar("REMARK")), '') as remark,
        nullif(trim(to_varchar("RTA_FLAG")), '') as rta_flag,
        nullif(trim(to_varchar("ISSUANCE_SOURCE")), '') as issuance_source,
        nullif(trim(to_varchar("CHANNEL")), '') as channel,
        nullif(trim(to_varchar("GG_CHANGE_DATE")), '') as gg_change_date,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_raw', 'BJAZ_VAHAN_AUTO_ENDT_LOG') }}

)

select * from source
