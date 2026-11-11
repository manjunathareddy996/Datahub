-- Staging for source table OCP_POLICY_COVERS (run opus_health_delta3). Every column is trimmed varchar: the pinned
-- inputs carry no datatype catalogue for this half, so no type is inferred.
with source as (

    select
        nullif(trim(to_varchar("ACTION_CODE")), '') as action_code,
        nullif(trim(to_varchar("AGENT_COMMISSION_COMPANY_SHARE")), '') as agent_commission_company_share,
        nullif(trim(to_varchar("AGENT_COMMISSION_COM_SHARE_SWF")), '') as agent_commission_com_share_swf,
        nullif(trim(to_varchar("AGENT_COMMISSION_WHOLE_COVER")), '') as agent_commission_whole_cover,
        nullif(trim(to_varchar("AGENT_COMMISSION_WHOLE_COV_SWF")), '') as agent_commission_whole_cov_swf,
        nullif(trim(to_varchar("CONTRACT_ID")), '') as contract_id,
        nullif(trim(to_varchar("COVER_CODE")), '') as cover_code,
        nullif(trim(to_varchar("COVER_NO")), '') as cover_no,
        nullif(trim(to_varchar("CVC_CODE")), '') as cvc_code,
        nullif(trim(to_varchar("DMS_COMMIT_TIMESTAMP")), '') as dms_commit_timestamp,
        nullif(trim(to_varchar("DMS_H_CHANGE_SEQ")), '') as dms_h_change_seq,
        nullif(trim(to_varchar("DMS_H_STREAM_POSITION")), '') as dms_h_stream_position,
        nullif(trim(to_varchar("DMS_H_USER")), '') as dms_h_user,
        nullif(trim(to_varchar("DMS_TIMESTAMP")), '') as dms_timestamp,
        nullif(trim(to_varchar("FTPREMIUM_OR_COMPANY_SHARE")), '') as ftpremium_or_company_share,
        nullif(trim(to_varchar("FTPREMIUM_OR_COMPANY_SHARE_SWF")), '') as ftpremium_or_company_share_swf,
        nullif(trim(to_varchar("FTPREMIUM_OR_WHOLE_COVER")), '') as ftpremium_or_whole_cover,
        nullif(trim(to_varchar("FTPREMIUM_OR_WHOLE_COVER_SWF")), '') as ftpremium_or_whole_cover_swf,
        nullif(trim(to_varchar("FTPREMIUM_SYS_COMPANY_SHARE")), '') as ftpremium_sys_company_share,
        nullif(trim(to_varchar("FTPREMIUM_SYS_COMP_SHARE_SWF")), '') as ftpremium_sys_comp_share_swf,
        nullif(trim(to_varchar("FTPREMIUM_SYS_WHOLE_COVER")), '') as ftpremium_sys_whole_cover,
        nullif(trim(to_varchar("FTPREMIUM_SYS_WHOLE_COVER_SWF")), '') as ftpremium_sys_whole_cover_swf,
        nullif(trim(to_varchar("GG_CHANGE_DATE")), '') as gg_change_date,
        nullif(trim(to_varchar("INC_JOB_CREATED_AT")), '') as inc_job_created_at,
        nullif(trim(to_varchar("INC_JOB_CREATED_BY")), '') as inc_job_created_by,
        nullif(trim(to_varchar("INC_JOB_ID")), '') as inc_job_id,
        nullif(trim(to_varchar("INC_JOB_UPDATED_AT")), '') as inc_job_updated_at,
        nullif(trim(to_varchar("INC_JOB_UPDATED_BY")), '') as inc_job_updated_by,
        nullif(trim(to_varchar("OBJECT_ID")), '') as object_id,
        nullif(trim(to_varchar("OP")), '') as op,
        nullif(trim(to_varchar("PARTITION_NO")), '') as partition_no,
        nullif(trim(to_varchar("PCOV_CONTRACT_ID")), '') as pcov_contract_id,
        nullif(trim(to_varchar("PCOV_COVER_CODE")), '') as pcov_cover_code,
        nullif(trim(to_varchar("PCOV_COVER_NO")), '') as pcov_cover_no,
        nullif(trim(to_varchar("PCOV_PARTITION_NO")), '') as pcov_partition_no,
        nullif(trim(to_varchar("PREVIOUS_VERSION")), '') as previous_version,
        nullif(trim(to_varchar("REINSURABLE_RISK_AMOUNT")), '') as reinsurable_risk_amount,
        nullif(trim(to_varchar("REINSURABLE_RISK_AMOUNT_SWF")), '') as reinsurable_risk_amount_swf,
        nullif(trim(to_varchar("REVERSING_VERSION")), '') as reversing_version,
        nullif(trim(to_varchar("SHARE_PORTION")), '') as share_portion,
        nullif(trim(to_varchar("SUM_INSURED_COMPANY_SHARE")), '') as sum_insured_company_share,
        nullif(trim(to_varchar("SUM_INSURED_COMPANY_SHARE_SWF")), '') as sum_insured_company_share_swf,
        nullif(trim(to_varchar("SUM_INSURED_WHOLE_COVER")), '') as sum_insured_whole_cover,
        nullif(trim(to_varchar("SUM_INSURED_WHOLE_COVER_SWF")), '') as sum_insured_whole_cover_swf,
        nullif(trim(to_varchar("SURCHARGE_DISCOUNT")), '') as surcharge_discount,
        nullif(trim(to_varchar("TOP_INDICATOR")), '') as top_indicator,
        nullif(trim(to_varchar("VERSION_NO")), '') as version_no
    from {{ source('health_raw', 'OCP_POLICY_COVERS') }}

)

select * from source
