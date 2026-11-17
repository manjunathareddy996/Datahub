-- Staging for source table BJAZ_RTA_STATE_MASTER. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("RTO_CODE")), '') as rto_code,
        nullif(trim(to_varchar("LOCATION_CODE")), '') as location_code,
        nullif(trim(to_varchar("PRODUCT_CODE")), '') as product_code,
        nullif(trim(to_varchar("VEHICLE_TYPE_CODE")), '') as vehicle_type_code,
        nullif(trim(to_varchar("STATE")), '') as state,
        nullif(trim(to_varchar("TOP_INDICATOR")), '') as top_indicator,
        nullif(trim(to_varchar("VERSION_NO")), '') as version_no,
        nullif(trim(to_varchar("RECORD_DATE")), '') as record_date,
        nullif(trim(to_varchar("USER_NAME")), '') as user_name,
        nullif(trim(to_varchar("IMD_CODE")), '') as imd_code,
        nullif(trim(to_varchar("SUB_IMD_CODE")), '') as sub_imd_code,
        nullif(trim(to_varchar("CHANNEL_NAME")), '') as channel_name,
        nullif(trim(to_varchar("SUB_CHANNEL_NAME")), '') as sub_channel_name,
        nullif(trim(to_varchar("CONFIG_TYPE")), '') as config_type,
        nullif(trim(to_varchar("UPDATE_DATE")), '') as update_date,
        nullif(trim(to_varchar("UPDATED_BY")), '') as updated_by,
        nullif(trim(to_varchar("DM_RECORD_DATE")), '') as dm_record_date,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_raw', 'BJAZ_RTA_STATE_MASTER') }}

)

select * from source
