-- Staging for source table BJAZ_WS_MOT_STP_RATE_SUMM. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("TRANSACTION_ID")), '') as transaction_id,
        nullif(trim(to_varchar("PACKAGE_ID")), '') as package_id,
        nullif(trim(to_varchar("PROD_CODE")), '') as prod_code,
        nullif(trim(to_varchar("VEH_TYPE_CODE")), '') as veh_type_code,
        nullif(trim(to_varchar("PARAM_REF")), '') as param_ref,
        nullif(trim(to_varchar("DISC_PERC")), '') as disc_perc,
        nullif(trim(to_varchar("RECORD_DATE")), '') as record_date,
        nullif(trim(to_varchar("MOTOR_WS_TRANS_ID")), '') as motor_ws_trans_id,
        nullif(trim(to_varchar("CLAIM_PATTERN")), '') as claim_pattern,
        nullif(trim(to_varchar("GG_CHANGE_DATE")), '') as gg_change_date,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_raw', 'BJAZ_WS_MOT_STP_RATE_SUMM') }}

)

select * from source
