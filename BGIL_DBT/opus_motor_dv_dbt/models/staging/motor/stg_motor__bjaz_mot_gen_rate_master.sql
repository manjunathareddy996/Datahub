-- Staging for source table BJAZ_MOT_GEN_RATE_MASTER. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("PARAM_CODE")), '') as param_code,
        nullif(trim(to_varchar("VEHICLE_TYPE_CODE")), '') as vehicle_type_code,
        nullif(trim(to_varchar("PRODUCT_4DIGIT_CODE")), '') as product_4digit_code,
        nullif(trim(to_varchar("OD_RATE")), '') as od_rate,
        nullif(trim(to_varchar("OD_MIN_VALUE")), '') as od_min_value,
        nullif(trim(to_varchar("OD_MAX_VALUE")), '') as od_max_value,
        nullif(trim(to_varchar("ACT_RATE")), '') as act_rate,
        nullif(trim(to_varchar("ACT_MIN_VALUE")), '') as act_min_value,
        nullif(trim(to_varchar("ACT_MAX_VALUE")), '') as act_max_value,
        nullif(trim(to_varchar("EFFECTIVE_DATE")), '') as effective_date,
        nullif(trim(to_varchar("NOTE")), '') as note,
        nullif(trim(to_varchar("ACT_RATE2")), '') as act_rate2,
        nullif(trim(to_varchar("ACT_RATE3")), '') as act_rate3,
        nullif(trim(to_varchar("ACT_RATE4")), '') as act_rate4,
        nullif(trim(to_varchar("ACT_RATE5")), '') as act_rate5,
        nullif(trim(to_varchar("IMD_CODE")), '') as imd_code,
        nullif(trim(to_varchar("SUBIMD_CODE")), '') as subimd_code,
        nullif(trim(to_varchar("FUEL_TYPE")), '') as fuel_type,
        nullif(trim(to_varchar("STATE_NAME")), '') as state_name,
        nullif(trim(to_varchar("LOCATION_CODE")), '') as location_code,
        nullif(trim(to_varchar("SUB_PRODUCT_CODE")), '') as sub_product_code,
        nullif(trim(to_varchar("TP_DISCOUNT")), '') as tp_discount,
        nullif(trim(to_varchar("OD_DISCOUNT")), '') as od_discount,
        nullif(trim(to_varchar("MAKE_CODE")), '') as make_code,
        nullif(trim(to_varchar("MODEL_CODE")), '') as model_code,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_test_raw', 'BJAZ_MOT_GEN_RATE_MASTER') }}

)

select * from source
