-- Staging for source table BJAZ_IIB_INSURER_MASTER. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("INSURER_CODE")), '') as insurer_code,
        nullif(trim(to_varchar("INSURER_NAME")), '') as insurer_name,
        nullif(trim(to_varchar("TOP_INDICATOR")), '') as top_indicator,
        nullif(trim(to_varchar("RECORD_DATE")), '') as record_date,
        nullif(trim(to_varchar("USER_NAME")), '') as user_name,
        nullif(trim(to_varchar("BJAZINSURERCODE")), '') as bjazinsurercode,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_raw', 'BJAZ_IIB_INSURER_MASTER') }}

)

select * from source
