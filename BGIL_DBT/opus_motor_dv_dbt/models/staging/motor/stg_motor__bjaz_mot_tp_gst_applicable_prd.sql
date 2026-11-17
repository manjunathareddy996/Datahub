-- Staging for source table BJAZ_MOT_TP_GST_APPLICABLE_PRD. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("VEHICLE_TYPE_CODE")), '') as vehicle_type_code,
        nullif(trim(to_varchar("PRODUCT_CODE")), '') as product_code,
        nullif(trim(to_varchar("ACTIVE_STATUS")), '') as active_status,
        nullif(trim(to_varchar("EFFECTIVE_DATE")), '') as effective_date,
        nullif(trim(to_varchar("INSERTED_BY")), '') as inserted_by,
        nullif(trim(to_varchar("RECORD_DATE")), '') as record_date,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_raw', 'BJAZ_MOT_TP_GST_APPLICABLE_PRD') }}

)

select * from source
