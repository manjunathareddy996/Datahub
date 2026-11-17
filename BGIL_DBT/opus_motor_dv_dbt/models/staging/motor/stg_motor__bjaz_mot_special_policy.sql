-- Staging for source table BJAZ_MOT_SPECIAL_POLICY. Every column trimmed varchar: the tables index carries
-- data_type absent_from_source, so no type is inferred.
-- inc_job_updated_at: the mandatory load/CDC watermark (skill.md section 1a), cast to timestamp_ntz
-- as in the partner, travel and health stg1 models.
with source as (

    select
        nullif(trim(to_varchar("MOT_POLICY_REF")), '') as mot_policy_ref,
        nullif(trim(to_varchar("GC_POLICY_REF")), '') as gc_policy_ref,
        nullif(trim(to_varchar("USER_ID")), '') as user_id,
        nullif(trim(to_varchar("EFF_DATE")), '') as eff_date,
        nullif(trim(to_varchar("POL_TYPE")), '') as pol_type,
        nullif(trim(to_varchar("BASIC_MOT_POLICY")), '') as basic_mot_policy,
        "INC_JOB_UPDATED_AT"::timestamp_ntz as inc_job_updated_at
    from {{ source('motor_raw', 'BJAZ_MOT_SPECIAL_POLICY') }}

)

select * from source
