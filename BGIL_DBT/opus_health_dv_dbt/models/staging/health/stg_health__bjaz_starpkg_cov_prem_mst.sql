-- Staging for source table BJAZ_STARPKG_COV_PREM_MST (run opus_health_delta3). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("AGE_LIMIT")), '') as age_limit,
        nullif(trim(to_varchar("COVER_CODE")), '') as cover_code,
        nullif(trim(to_varchar("DMS_COMMIT_TIMESTAMP")), '') as dms_commit_timestamp,
        nullif(trim(to_varchar("DMS_H_CHANGE_SEQ")), '') as dms_h_change_seq,
        nullif(trim(to_varchar("DMS_H_STREAM_POSITION")), '') as dms_h_stream_position,
        nullif(trim(to_varchar("DMS_H_USER")), '') as dms_h_user,
        nullif(trim(to_varchar("DMS_TIMESTAMP")), '') as dms_timestamp,
        nullif(trim(to_varchar("EFF_DATE")), '') as eff_date,
        nullif(trim(to_varchar("GG_CHANGE_DATE")), '') as gg_change_date,
        nullif(trim(to_varchar("INC_JOB_CREATED_AT")), '') as inc_job_created_at,
        nullif(trim(to_varchar("INC_JOB_CREATED_BY")), '') as inc_job_created_by,
        nullif(trim(to_varchar("INC_JOB_ID")), '') as inc_job_id,
        nullif(trim(to_varchar("INC_JOB_UPDATED_AT")), '') as inc_job_updated_at,
        nullif(trim(to_varchar("INC_JOB_UPDATED_BY")), '') as inc_job_updated_by,
        nullif(trim(to_varchar("PLAN_CODE")), '') as plan_code,
        nullif(trim(to_varchar("PREMIUM")), '') as premium,
        nullif(trim(to_varchar("PREM_FLAG")), '') as prem_flag,
        nullif(trim(to_varchar("SECTION_ID")), '') as section_id,
        nullif(trim(to_varchar("SR_NO")), '') as sr_no,
        nullif(trim(to_varchar("TOTAL_SI")), '') as total_si,
        nullif(trim(to_varchar("T_INDICATOR")), '') as t_indicator
    from {{ source('health_raw', 'BJAZ_STARPKG_COV_PREM_MST') }}

)

select * from source
