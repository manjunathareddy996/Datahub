-- Staging for source table BJAZ_MOT_NAMED_DRIVER_EXTN. Every column trimmed varchar: the tables index carries
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
        nullif(trim(to_varchar("PARTICULARS")), '') as particulars,
        nullif(trim(to_varchar("DRIVER_NAME")), '') as driver_name,
        nullif(trim(to_varchar("AGE")), '') as age,
        nullif(trim(to_varchar("GENDER")), '') as gender,
        nullif(trim(to_varchar("RELATIONSHIP")), '') as relationship,
        nullif(trim(to_varchar("DRIVER_LICENCE_NO")), '') as driver_licence_no,
        nullif(trim(to_varchar("OWNER_DRIVER_FLAG")), '') as owner_driver_flag,
        nullif(trim(to_varchar("REF_ID")), '') as ref_id,
        nullif(trim(to_varchar("GG_CHANGE_DATE")), '') as gg_change_date,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_raw', 'BJAZ_MOT_NAMED_DRIVER_EXTN') }}

)

select * from source
