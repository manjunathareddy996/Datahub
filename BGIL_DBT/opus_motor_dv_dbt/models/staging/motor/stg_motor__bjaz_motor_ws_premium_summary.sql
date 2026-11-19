-- Staging for source table BJAZ_MOTOR_WS_PREMIUM_SUMMARY. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("TRANSACTIONID")), '') as transactionid,
        nullif(trim(to_varchar("VERSION_NO")), '') as version_no,
        nullif(trim(to_varchar("SUB_VERSION_NO")), '') as sub_version_no,
        nullif(trim(to_varchar("TOP_INDICATOR")), '') as top_indicator,
        nullif(trim(to_varchar("ENTRY_DATE")), '') as entry_date,
        nullif(trim(to_varchar("MODULE_FROM")), '') as module_from,
        nullif(trim(to_varchar("PARAM_DESC")), '') as param_desc,
        nullif(trim(to_varchar("PARAM_REF")), '') as param_ref,
        nullif(trim(to_varchar("PARAM_TYPE")), '') as param_type,
        nullif(trim(to_varchar("OD")), '') as od,
        nullif(trim(to_varchar("ACT")), '') as act,
        nullif(trim(to_varchar("NET")), '') as net,
        nullif(trim(to_varchar("GG_CHANGE_DATE")), '') as gg_change_date,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_test_raw', 'BJAZ_MOTOR_WS_PREMIUM_SUMMARY') }}

)

select * from source
