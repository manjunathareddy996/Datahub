-- Staging for source table BJAZ_MOT_CLM_COMPARABLE_DTLS. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("CLAIM_REF")), '') as claim_ref,
        nullif(trim(to_varchar("COMPARABLE_CLAIM_REF")), '') as comparable_claim_ref,
        nullif(trim(to_varchar("SOURCE")), '') as source,
        nullif(trim(to_varchar("UPDATE_ON")), '') as update_on,
        nullif(trim(to_varchar("GG_CHANGE_DATE")), '') as gg_change_date,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_raw', 'BJAZ_MOT_CLM_COMPARABLE_DTLS') }}

)

select * from source
