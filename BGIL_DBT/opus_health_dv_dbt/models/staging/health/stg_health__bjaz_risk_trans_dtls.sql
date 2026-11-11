-- Staging for source table BJAZ_RISK_TRANS_DTLS (run opus_health_delta3). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("CLAIM_ID")), '') as claim_id,
        nullif(trim(to_varchar("CLAIM_REF")), '') as claim_ref,
        nullif(trim(to_varchar("CLID_HPMS")), '') as clid_hpms,
        nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
        nullif(trim(to_varchar("DELETE_FLAG")), '') as delete_flag,
        nullif(trim(to_varchar("DMS_COMMIT_TIMESTAMP")), '') as dms_commit_timestamp,
        nullif(trim(to_varchar("DMS_H_CHANGE_SEQ")), '') as dms_h_change_seq,
        nullif(trim(to_varchar("DMS_H_STREAM_POSITION")), '') as dms_h_stream_position,
        nullif(trim(to_varchar("DMS_H_USER")), '') as dms_h_user,
        nullif(trim(to_varchar("DMS_TIMESTAMP")), '') as dms_timestamp,
        nullif(trim(to_varchar("GG_CHANGE_DATE")), '') as gg_change_date,
        nullif(trim(to_varchar("INC_JOB_CREATED_AT")), '') as inc_job_created_at,
        nullif(trim(to_varchar("INC_JOB_CREATED_BY")), '') as inc_job_created_by,
        nullif(trim(to_varchar("INC_JOB_ID")), '') as inc_job_id,
        nullif(trim(to_varchar("INC_JOB_UPDATED_AT")), '') as inc_job_updated_at,
        nullif(trim(to_varchar("INC_JOB_UPDATED_BY")), '') as inc_job_updated_by,
        nullif(trim(to_varchar("OP")), '') as op,
        nullif(trim(to_varchar("POLICY_REF")), '') as policy_ref,
        nullif(trim(to_varchar("QR_NEEDED")), '') as qr_needed,
        nullif(trim(to_varchar("RISK_ACTUAL_SCORE")), '') as risk_actual_score,
        nullif(trim(to_varchar("RISK_ID")), '') as risk_id,
        nullif(trim(to_varchar("RISK_SUBCATEGORY_CODE")), '') as risk_subcategory_code,
        nullif(trim(to_varchar("RISK_SUSP_FRAUD_ID")), '') as risk_susp_fraud_id,
        nullif(trim(to_varchar("TOP_INDICATOR")), '') as top_indicator,
        nullif(trim(to_varchar("TRIGGER_TYPE")), '') as trigger_type,
        nullif(trim(to_varchar("UPDATED_BY")), '') as updated_by,
        nullif(trim(to_varchar("UPDATED_ON")), '') as updated_on
    from {{ source('health_raw', 'BJAZ_RISK_TRANS_DTLS') }}

)

select * from source
