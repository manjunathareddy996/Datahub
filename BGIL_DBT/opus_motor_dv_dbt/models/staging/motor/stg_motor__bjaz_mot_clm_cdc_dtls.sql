-- Staging for source table BJAZ_MOT_CLM_CDC_DTLS. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("CLAIM_REF")), '') as claim_ref,
        nullif(trim(to_varchar("TOP_INDICATOR")), '') as top_indicator,
        nullif(trim(to_varchar("VERSION_NO")), '') as version_no,
        nullif(trim(to_varchar("LEFT_CODE")), '') as left_code,
        nullif(trim(to_varchar("FRONT_CODE")), '') as front_code,
        nullif(trim(to_varchar("RIGHT_CODE")), '') as right_code,
        nullif(trim(to_varchar("TOP_CODE")), '') as top_code,
        nullif(trim(to_varchar("BACK_CODE")), '') as back_code,
        nullif(trim(to_varchar("UNDER_CODE")), '') as under_code,
        nullif(trim(to_varchar("ROLL_OVER_CODE")), '') as roll_over_code,
        nullif(trim(to_varchar("UNCLASSIFYABLE_CODE")), '') as unclassifyable_code,
        nullif(trim(to_varchar("UPDATED_ON")), '') as updated_on,
        nullif(trim(to_varchar("UPDATED_BY")), '') as updated_by,
        nullif(trim(to_varchar("WINDSHIELD_CODE")), '') as windshield_code,
        nullif(trim(to_varchar("REARGLASS_CODE")), '') as rearglass_code,
        nullif(trim(to_varchar("TIRE_CODE")), '') as tire_code,
        nullif(trim(to_varchar("CAR_TYPE")), '') as car_type,
        nullif(trim(to_varchar("DEVICE_SOURCE")), '') as device_source,
        nullif(trim(to_varchar("INVALID_CARRIAG")), '') as invalid_carriag,
        nullif(trim(to_varchar("W_FLOOD")), '') as w_flood,
        nullif(trim(to_varchar("FIRE")), '') as fire,
        nullif(trim(to_varchar("ENGINE")), '') as engine,
        nullif(trim(to_varchar("CHASSIS")), '') as chassis,
        nullif(trim(to_varchar("FUEL_TANK")), '') as fuel_tank,
        nullif(trim(to_varchar("WHEEL_RIM")), '') as wheel_rim,
        nullif(trim(to_varchar("PARTIAL_THEFT")), '') as partial_theft,
        nullif(trim(to_varchar("TOTAL_LOSS")), '') as total_loss,
        nullif(trim(to_varchar("SILENCER")), '') as silencer,
        nullif(trim(to_varchar("RIM_WITH_TYRE")), '') as rim_with_tyre,
        nullif(trim(to_varchar("GG_CHANGE_DATE")), '') as gg_change_date,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_test_raw', 'BJAZ_MOT_CLM_CDC_DTLS') }}

)

select * from source
