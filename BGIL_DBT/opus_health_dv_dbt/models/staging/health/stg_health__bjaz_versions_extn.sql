-- Staging for source table BJAZ_VERSIONS_EXTN (run opus_health_delta3). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("ACTION_CODE")), '') as action_code,
        nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
        nullif(trim(to_varchar("DMS_COMMIT_TIMESTAMP")), '') as dms_commit_timestamp,
        nullif(trim(to_varchar("DMS_H_CHANGE_SEQ")), '') as dms_h_change_seq,
        nullif(trim(to_varchar("DMS_H_STREAM_POSITION")), '') as dms_h_stream_position,
        nullif(trim(to_varchar("DMS_H_USER")), '') as dms_h_user,
        nullif(trim(to_varchar("DMS_TIMESTAMP")), '') as dms_timestamp,
        nullif(trim(to_varchar("ENDORSEMENT_NO")), '') as endorsement_no,
        nullif(trim(to_varchar("ENDORSE_DUE_TO")), '') as endorse_due_to,
        nullif(trim(to_varchar("ENDORSE_REASON")), '') as endorse_reason,
        nullif(trim(to_varchar("ENDORSE_SUB_TYPE")), '') as endorse_sub_type,
        nullif(trim(to_varchar("ENDORSE_WORDING")), '') as endorse_wording,
        nullif(trim(to_varchar("GG_CHANGE_DATE")), '') as gg_change_date,
        nullif(trim(to_varchar("INC_JOB_CREATED_AT")), '') as inc_job_created_at,
        nullif(trim(to_varchar("INC_JOB_CREATED_BY")), '') as inc_job_created_by,
        nullif(trim(to_varchar("INC_JOB_ID")), '') as inc_job_id,
        nullif(trim(to_varchar("INC_JOB_UPDATED_AT")), '') as inc_job_updated_at,
        nullif(trim(to_varchar("INC_JOB_UPDATED_BY")), '') as inc_job_updated_by,
        nullif(trim(to_varchar("OBJECT_ID")), '') as object_id,
        nullif(trim(to_varchar("OP")), '') as op,
        nullif(trim(to_varchar("PREVIOUS_VERSION")), '') as previous_version,
        nullif(trim(to_varchar("REVERSING_VERSION")), '') as reversing_version,
        nullif(trim(to_varchar("TOP_INDICATOR")), '') as top_indicator,
        nullif(trim(to_varchar("VERSION_NO")), '') as version_no
    from {{ source('health_raw', 'BJAZ_VERSIONS_EXTN') }}

)

select * from source
