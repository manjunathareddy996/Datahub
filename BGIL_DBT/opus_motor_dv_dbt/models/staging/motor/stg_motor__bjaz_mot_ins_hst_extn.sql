-- Staging for source table BJAZ_MOT_INS_HST_EXTN. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("ACTION_CODE")), '') as action_code,
        nullif(trim(to_varchar("VERSION_NO")), '') as version_no,
        nullif(trim(to_varchar("TOP_INDICATOR")), '') as top_indicator,
        nullif(trim(to_varchar("PREVIOUS_VERSION")), '') as previous_version,
        nullif(trim(to_varchar("REVERSING_VERSION")), '') as reversing_version,
        nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
        nullif(trim(to_varchar("PREV_NCB_RATE")), '') as prev_ncb_rate,
        nullif(trim(to_varchar("PREV_NCB_SOURCE")), '') as prev_ncb_source,
        nullif(trim(to_varchar("PREV_VEHICLE_REG_NO")), '') as prev_vehicle_reg_no,
        nullif(trim(to_varchar("PREV_VEHICLE_MAKE")), '') as prev_vehicle_make,
        nullif(trim(to_varchar("PREV_VEHICLE_MODEL")), '') as prev_vehicle_model,
        nullif(trim(to_varchar("PREV_VEHICLE_SUBTYPE")), '') as prev_vehicle_subtype,
        nullif(trim(to_varchar("PREV_VEHICLE_TYPE")), '') as prev_vehicle_type,
        nullif(trim(to_varchar("PREV_POLICY_TERM")), '') as prev_policy_term,
        nullif(trim(to_varchar("NO_OF_CLAIMS")), '') as no_of_claims,
        nullif(trim(to_varchar("GG_CHANGE_DATE")), '') as gg_change_date,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_raw', 'BJAZ_MOT_INS_HST_EXTN') }}

)

select * from source
