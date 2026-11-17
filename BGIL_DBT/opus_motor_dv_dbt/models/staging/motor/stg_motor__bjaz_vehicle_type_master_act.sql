-- Staging for source table BJAZ_VEHICLE_TYPE_MASTER_ACT. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("VEHICLE_TYPE_CODE")), '') as vehicle_type_code,
        nullif(trim(to_varchar("IMD_CODE")), '') as imd_code,
        nullif(trim(to_varchar("LOCATION_CODE")), '') as location_code,
        nullif(trim(to_varchar("USER_NAME")), '') as user_name,
        nullif(trim(to_varchar("COVER_TYPE")), '') as cover_type,
        nullif(trim(to_varchar("MIN_RID")), '') as min_rid,
        nullif(trim(to_varchar("EFFECTIVE_DATE")), '') as effective_date,
        nullif(trim(to_varchar("ACTIVE_YN")), '') as active_yn,
        nullif(trim(to_varchar("PRODUCT_CODE")), '') as product_code,
        nullif(trim(to_varchar("SUBIMD_CODE")), '') as subimd_code,
        nullif(trim(to_varchar("DM_RECORD_DATE")), '') as dm_record_date,
        nullif(trim(to_varchar("GG_CHANGE_DATE")), '') as gg_change_date,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_raw', 'BJAZ_VEHICLE_TYPE_MASTER_ACT') }}

)

select * from source
