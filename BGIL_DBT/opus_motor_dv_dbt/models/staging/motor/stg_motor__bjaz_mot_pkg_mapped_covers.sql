-- Staging for source table BJAZ_MOT_PKG_MAPPED_COVERS. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("PACKAGE_ID")), '') as package_id,
        nullif(trim(to_varchar("COVER_CODE")), '') as cover_code,
        nullif(trim(to_varchar("DISCOUNT_RATE")), '') as discount_rate,
        nullif(trim(to_varchar("LOADING_RATE")), '') as loading_rate,
        nullif(trim(to_varchar("ENABLE_DISC_YN")), '') as enable_disc_yn,
        nullif(trim(to_varchar("SUM_INSURED")), '') as sum_insured,
        nullif(trim(to_varchar("MAX_NODAYS_BENEFIT")), '') as max_nodays_benefit,
        nullif(trim(to_varchar("PER_DAYS_BENEFIT")), '') as per_days_benefit,
        nullif(trim(to_varchar("GG_CHANGE_DATE")), '') as gg_change_date,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_raw', 'BJAZ_MOT_PKG_MAPPED_COVERS') }}

)

select * from source
