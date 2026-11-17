-- Staging for source table BJAZ_MOT_WAR_PLANS_EXTN. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
        nullif(trim(to_varchar("PLAN_DESC")), '') as plan_desc,
        nullif(trim(to_varchar("AGE_FROM_DAYS")), '') as age_from_days,
        nullif(trim(to_varchar("AGE_TO_DAYS")), '') as age_to_days,
        nullif(trim(to_varchar("WARRANTY_PERIOD")), '') as warranty_period,
        nullif(trim(to_varchar("WAR_KM_LIMIT")), '') as war_km_limit,
        nullif(trim(to_varchar("WAR_HOUR_LIMIT")), '') as war_hour_limit,
        nullif(trim(to_varchar("CEILING_KM")), '') as ceiling_km,
        nullif(trim(to_varchar("CEILING_HOUR")), '') as ceiling_hour,
        nullif(trim(to_varchar("PREMIUM")), '') as premium,
        nullif(trim(to_varchar("EFFECTIVE_FROM")), '') as effective_from,
        nullif(trim(to_varchar("VEHICLE_MODEL")), '') as vehicle_model,
        nullif(trim(to_varchar("USER_NAME")), '') as user_name,
        nullif(trim(to_varchar("VEHICLE_MAKE")), '') as vehicle_make,
        nullif(trim(to_varchar("PLAN_ID")), '') as plan_id,
        nullif(trim(to_varchar("FUEL_TYPE")), '') as fuel_type,
        nullif(trim(to_varchar("OBJECT_ID")), '') as object_id,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_raw', 'BJAZ_MOT_WAR_PLANS_EXTN') }}

)

select * from source
