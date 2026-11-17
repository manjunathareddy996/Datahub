-- Staging for source table BA_QUOTE_MOT_PREM. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("SCRUTINY_NO")), '') as scrutiny_no,
        nullif(trim(to_varchar("PARAM_REF")), '') as param_ref,
        nullif(trim(to_varchar("PARAM_TYPE")), '') as param_type,
        nullif(trim(to_varchar("OD")), '') as od,
        nullif(trim(to_varchar("ACT")), '') as act,
        nullif(trim(to_varchar("NET")), '') as net,
        nullif(trim(to_varchar("GG_CHANGE_DATE")), '') as gg_change_date,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_raw', 'BA_QUOTE_MOT_PREM') }}

)

select * from source
