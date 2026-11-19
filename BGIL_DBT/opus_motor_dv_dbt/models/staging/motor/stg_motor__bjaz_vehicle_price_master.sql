-- Staging for source table BJAZ_VEHICLE_PRICE_MASTER. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("VEHICLE_CODE")), '') as vehicle_code,
        nullif(trim(to_varchar("CITY")), '') as city,
        nullif(trim(to_varchar("YEAR_OF_MANF")), '') as year_of_manf,
        nullif(trim(to_varchar("FUEL")), '') as fuel,
        nullif(trim(to_varchar("PRICE")), '') as price,
        nullif(trim(to_varchar("EFFECTIVE_DATE")), '') as effective_date,
        nullif(trim(to_varchar("USER_NAME")), '') as user_name,
        nullif(trim(to_varchar("SYSTEM_DATE")), '') as system_date,
        nullif(trim(to_varchar("STATE")), '') as state,
        nullif(trim(to_varchar("DM_RECORD_DATE")), '') as dm_record_date,
        nullif(trim(to_varchar("GG_CHANGE_DATE")), '') as gg_change_date,
        nullif(trim(to_varchar("FLAG_S")), '') as flag_s,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_test_raw', 'BJAZ_VEHICLE_PRICE_MASTER') }}

)

select * from source
