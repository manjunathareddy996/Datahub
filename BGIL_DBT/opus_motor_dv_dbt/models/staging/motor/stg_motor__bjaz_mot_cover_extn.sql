-- Staging for source table BJAZ_MOT_COVER_EXTN. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("ACTION_CODE")), '') as action_code,
        nullif(trim(to_varchar("VERSION_NO")), '') as version_no,
        nullif(trim(to_varchar("OBJECT_ID")), '') as object_id,
        nullif(trim(to_varchar("TOP_INDICATOR")), '') as top_indicator,
        nullif(trim(to_varchar("PREVIOUS_VERSION")), '') as previous_version,
        nullif(trim(to_varchar("REVERSING_VERSION")), '') as reversing_version,
        nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
        nullif(trim(to_varchar("PARTITION_NO")), '') as partition_no,
        nullif(trim(to_varchar("COVER_CODE")), '') as cover_code,
        nullif(trim(to_varchar("COVER_NO")), '') as cover_no,
        nullif(trim(to_varchar("COVER_RATE")), '') as cover_rate,
        nullif(trim(to_varchar("VOLUNTARY_EXCESS")), '') as voluntary_excess,
        nullif(trim(to_varchar("PA_NO_OF_PERSONS")), '') as pa_no_of_persons,
        nullif(trim(to_varchar("PA_NO_DRV_CL")), '') as pa_no_drv_cl,
        nullif(trim(to_varchar("COVER_DISC")), '') as cover_disc,
        nullif(trim(to_varchar("COVER_LOAD")), '') as cover_load,
        nullif(trim(to_varchar("ENABLE_DISC")), '') as enable_disc,
        nullif(trim(to_varchar("TYRE1")), '') as tyre1,
        nullif(trim(to_varchar("TYRE2")), '') as tyre2,
        nullif(trim(to_varchar("TYRE3")), '') as tyre3,
        nullif(trim(to_varchar("TYRE4")), '') as tyre4,
        nullif(trim(to_varchar("TYRE5")), '') as tyre5,
        nullif(trim(to_varchar("LAIDUP_TYPE")), '') as laidup_type,
        nullif(trim(to_varchar("LAIDUP_SUBTYPE")), '') as laidup_subtype,
        nullif(trim(to_varchar("LAIDUP_START_DT")), '') as laidup_start_dt,
        nullif(trim(to_varchar("LAIDUP_END_DT")), '') as laidup_end_dt,
        nullif(trim(to_varchar("GG_CHANGE_DATE")), '') as gg_change_date,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_raw', 'BJAZ_MOT_COVER_EXTN') }}

)

select * from source
