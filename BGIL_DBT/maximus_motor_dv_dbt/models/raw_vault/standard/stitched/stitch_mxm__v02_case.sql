-- CENTRAL VIEW v02_case -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_WORK_ITEM_DETAILS
-- Walk tables, joined only to resolve spine keys (not counted):
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_MOTOR_AUG_CASE_WORKFLOW_TASK
--   SAT_CASE_WORKFLOW_TASK
-- Links whose legs come from one source row on this view (rule 6):
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_WORK_ITEM_DETAILS
    select
        nullif(nullif(trim('CASE-POLICY-SERVICING:' || coalesce(nullif(trim(j1.policy_number), ''), '')), 'CASE-POLICY-SERVICING:'), '') as CASE_BK,
        nullif(trim(t0.task_type),'') as AUG_CASE_WORKFLOW_TASK__TASK_CODE_CK,
        t0.raised_by as AUG_CASE_WORKFLOW_TASK__TASK_RAISED_BY_REFERENCE,
        t0.raised_date as AUG_CASE_WORKFLOW_TASK__TASK_RAISED_DATE,
        t0.remarks as AUG_CASE_WORKFLOW_TASK__TASK_REMARKS,
        nullif(trim(t0.task_type),'') as CASE_WORKFLOW_TASK__TASK_CODE_CK,
        t0.completion_date as CASE_WORKFLOW_TASK__COMPLETED_DATE,
        t0.status as CASE_WORKFLOW_TASK__TASK_STATUS,
        t0.task_type as CASE_WORKFLOW_TASK__TASK_TYPE,
        t0.rec_refresh_at as REC_REFRESH_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_work_item_dtls') }} t0
    left join {{ ref('stg_mxm__uwr_pd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (nullif(nullif(trim('CASE-POLICY-SERVICING:' || coalesce(nullif(trim(j1.policy_number), ''), '')), 'CASE-POLICY-SERVICING:'), '')) is not null

)

select
    CASE_BK,
    AUG_CASE_WORKFLOW_TASK__TASK_CODE_CK,
    first_value(AUG_CASE_WORKFLOW_TASK__TASK_RAISED_BY_REFERENCE) ignore nulls over (partition by CASE_BK, AUG_CASE_WORKFLOW_TASK__TASK_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CASE_WORKFLOW_TASK__TASK_RAISED_BY_REFERENCE,
    first_value(AUG_CASE_WORKFLOW_TASK__TASK_RAISED_DATE) ignore nulls over (partition by CASE_BK, AUG_CASE_WORKFLOW_TASK__TASK_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CASE_WORKFLOW_TASK__TASK_RAISED_DATE,
    first_value(AUG_CASE_WORKFLOW_TASK__TASK_REMARKS) ignore nulls over (partition by CASE_BK, AUG_CASE_WORKFLOW_TASK__TASK_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CASE_WORKFLOW_TASK__TASK_REMARKS,
    CASE_WORKFLOW_TASK__TASK_CODE_CK,
    first_value(CASE_WORKFLOW_TASK__COMPLETED_DATE) ignore nulls over (partition by CASE_BK, CASE_WORKFLOW_TASK__TASK_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CASE_WORKFLOW_TASK__COMPLETED_DATE,
    first_value(CASE_WORKFLOW_TASK__TASK_STATUS) ignore nulls over (partition by CASE_BK, CASE_WORKFLOW_TASK__TASK_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CASE_WORKFLOW_TASK__TASK_STATUS,
    first_value(CASE_WORKFLOW_TASK__TASK_TYPE) ignore nulls over (partition by CASE_BK, CASE_WORKFLOW_TASK__TASK_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CASE_WORKFLOW_TASK__TASK_TYPE,
    -- the row's own source time: LOAD_DATETIME for hubs, links and single-active satellites
    m.REC_REFRESH_AT,
    -- multi-active satellites on CASE_BK (SAT_MOTOR_AUG_CASE_WORKFLOW_TASK, SAT_CASE_WORKFLOW_TASK):
    -- one load time per CASE_BK, the newest REC_REFRESH_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when coalesce(m.AUG_CASE_WORKFLOW_TASK__TASK_RAISED_BY_REFERENCE, m.AUG_CASE_WORKFLOW_TASK__TASK_RAISED_DATE, m.AUG_CASE_WORKFLOW_TASK__TASK_REMARKS, m.CASE_WORKFLOW_TASK__COMPLETED_DATE, m.CASE_WORKFLOW_TASK__TASK_STATUS, m.CASE_WORKFLOW_TASK__TASK_TYPE) is not null
             then m.REC_REFRESH_AT end)
        over (partition by m.CASE_BK) as CASE_BK__MA_LOAD_DATETIME
from merged m
