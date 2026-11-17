-- Staging for source table BJAZ_MOT_PROD_UIN_MAPPING. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("PROD_CODE")), '') as prod_code,
        nullif(trim(to_varchar("VEH_TYPE_CODE")), '') as veh_type_code,
        nullif(trim(to_varchar("PROD_DESC")), '') as prod_desc,
        nullif(trim(to_varchar("TENURE")), '') as tenure,
        nullif(trim(to_varchar("PROD_UIN")), '') as prod_uin,
        nullif(trim(to_varchar("RECORD_DATE")), '') as record_date,
        nullif(trim(to_varchar("STATUS")), '') as status,
        nullif(trim(to_varchar("PROD_NAME")), '') as prod_name,
        nullif(trim(to_varchar("USER_ID")), '') as user_id,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_raw', 'BJAZ_MOT_PROD_UIN_MAPPING') }}

)

select * from source
