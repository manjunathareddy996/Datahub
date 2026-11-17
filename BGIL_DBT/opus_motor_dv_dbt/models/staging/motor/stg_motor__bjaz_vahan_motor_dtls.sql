-- Staging for source table BJAZ_VAHAN_MOTOR_DTLS. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("REG_NO")), '') as reg_no,
        nullif(trim(to_varchar("ENGINE_NO")), '') as engine_no,
        nullif(trim(to_varchar("CHASSIS_NO")), '') as chassis_no,
        nullif(trim(to_varchar("MAKER_NAME")), '') as maker_name,
        nullif(trim(to_varchar("MODEL_NAME")), '') as model_name,
        nullif(trim(to_varchar("REGN_NO_RES")), '') as regn_no_res,
        nullif(trim(to_varchar("CHASIS_NO_RES")), '') as chasis_no_res,
        nullif(trim(to_varchar("ENGINE_NO_RES")), '') as engine_no_res,
        nullif(trim(to_varchar("PUCC_FLAG")), '') as pucc_flag,
        nullif(trim(to_varchar("STATUS")), '') as status,
        nullif(trim(to_varchar("VEHICLE_CLASS")), '') as vehicle_class,
        nullif(trim(to_varchar("SEQ_NO")), '') as seq_no,
        nullif(trim(to_varchar("CALL_METHOD")), '') as call_method,
        nullif(trim(to_varchar("RECORD_DATE")), '') as record_date,
        nullif(trim(to_varchar("VAHAN_RESPONSE")), '') as vahan_response,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_raw', 'BJAZ_VAHAN_MOTOR_DTLS') }}

)

select * from source
