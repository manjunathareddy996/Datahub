-- Staging for source table CVTP_GUIDELINES. Every column trimmed varchar: the tables index carries
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
        nullif(trim(to_varchar("VEHICLE_MODEL")), '') as vehicle_model,
        nullif(trim(to_varchar("ENGINE_CAPACITY_TYPE")), '') as engine_capacity_type,
        nullif(trim(to_varchar("ENGINE_CAPACITY_VALUE_FROM")), '') as engine_capacity_value_from,
        nullif(trim(to_varchar("ENGINE_CAPACITY_VALUE_TO")), '') as engine_capacity_value_to,
        nullif(trim(to_varchar("FUEL_TYPE")), '') as fuel_type,
        nullif(trim(to_varchar("BUSINESS_TYPE")), '') as business_type,
        nullif(trim(to_varchar("VEHICLE_AGE_FROM")), '') as vehicle_age_from,
        nullif(trim(to_varchar("VEHICLE_AGE_TO")), '') as vehicle_age_to,
        nullif(trim(to_varchar("POLICY_TERM")), '') as policy_term,
        nullif(trim(to_varchar("DUMPER_OR_TIPPER_FLAG")), '') as dumper_or_tipper_flag,
        nullif(trim(to_varchar("RTA_CLUSTER")), '') as rta_cluster,
        nullif(trim(to_varchar("PRODUCT_CODE")), '') as product_code,
        nullif(trim(to_varchar("POLICY_PLAN")), '') as policy_plan,
        nullif(trim(to_varchar("LOCATION_CODE")), '') as location_code,
        nullif(trim(to_varchar("IMD_CODE")), '') as imd_code,
        nullif(trim(to_varchar("SUB_IMD_CODE")), '') as sub_imd_code,
        nullif(trim(to_varchar("VEHICLE_TYPE")), '') as vehicle_type,
        nullif(trim(to_varchar("VEHICLE_MAKE")), '') as vehicle_make,
        nullif(trim(to_varchar("ISSUANCE_SOURCE")), '') as issuance_source,
        nullif(trim(to_varchar("REFERRAL_TO")), '') as referral_to,
        nullif(trim(to_varchar("PROCESS_DATE")), '') as process_date,
        nullif(trim(to_varchar("MAXIMUS_PROCESS_DATE")), '') as maximus_process_date,
        nullif(trim(to_varchar("GG_CHANGE_DATE")), '') as gg_change_date,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_test_raw', 'CVTP_GUIDELINES') }}

)

select * from source
