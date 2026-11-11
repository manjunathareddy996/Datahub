-- Staging for source view MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_FOLLOWUP_ATTRIBUTES_PIVOT_VW. Every column trimmed varchar, including the shred keys
-- KEY_HASH / PARENT_KEY_HASH / FOREIGN_KEY that the central views join on.
with source as (

    select
        nullif(trim(to_varchar("FOREIGN_KEY")), '') as foreign_key,
        nullif(trim(to_varchar("PARENT_RECORD_HASH")), '') as parent_record_hash,
        nullif(trim(to_varchar("PARENT_KEY_HASH")), '') as parent_key_hash,
        nullif(trim(to_varchar("KEY_HASH")), '') as key_hash,
        nullif(trim(to_varchar("INC_JOB_CREATED_AT")), '') as inc_job_created_at,
        nullif(trim(to_varchar("REC_REFRESH_AT")), '') as rec_refresh_at,
        nullif(trim(to_varchar("ACTION")), '') as action,
        nullif(trim(to_varchar("ASSIGNED_TO")), '') as assigned_to,
        nullif(trim(to_varchar("COMPLETION_DATE")), '') as completion_date,
        nullif(trim(to_varchar("CREATED_BY")), '') as created_by,
        nullif(trim(to_varchar("FOLLOW_UP_DATE")), '') as follow_up_date,
        nullif(trim(to_varchar("PROCESS_NAME")), '') as process_name,
        nullif(trim(to_varchar("QUEUE_NAME")), '') as queue_name,
        nullif(trim(to_varchar("REMARKS")), '') as remarks,
        nullif(trim(to_varchar("SLA")), '') as sla,
        nullif(trim(to_varchar("TASK_DESCRIPTION")), '') as task_description,
        nullif(trim(to_varchar("TASK_STATUS")), '') as task_status,
        nullif(trim(to_varchar("TEAM_NAME")), '') as team_name
    from {{ source('maximus_raw', 'MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_FOLLOWUP_ATTRIBUTES_PIVOT_VW') }}

)

select * from source
