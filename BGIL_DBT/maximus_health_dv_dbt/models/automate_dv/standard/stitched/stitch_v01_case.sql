-- CENTRAL VIEW v01_case -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_FOLLOWUP_ATTRIBUTES_PIVOT_VW
-- Walk tables, joined only to resolve spine keys (not counted):
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_CASE_WORKFLOW_TASK
-- Links whose legs come from one source row on this view (rule 6):
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_FOLLOWUP_ATTRIBUTES_PIVOT_VW
    select
        nullif(md5(normalise(nullif(trim('CLAIM_SERVICE_CASE#' || coalesce(t0.foreign_key,'')), 'CLAIM_SERVICE_CASE#'))), '') as CASE_BK,
        t0.process_name || '#' || t0.follow_up_date as CASE_WORKFLOW_TASK__TASK_CODE_CK,
        t0.assigned_to as CASE_WORKFLOW_TASK__ASSIGNED_TO_REFERENCE,
        t0.completion_date as CASE_WORKFLOW_TASK__COMPLETED_DATE,
        t0.follow_up_date as CASE_WORKFLOW_TASK__DUE_DATE,
        t0.action as CASE_WORKFLOW_TASK__OUTCOME,
        t0.queue_name as CASE_WORKFLOW_TASK__QUEUE_REFERENCE,
        t0.task_description as CASE_WORKFLOW_TASK__TASK_NAME,
        t0.task_status as CASE_WORKFLOW_TASK__TASK_STATUS,
        t0.process_name as CASE_WORKFLOW_TASK__TASK_TYPE,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_followup_attrs_pv') }} t0
    where (nullif(md5(normalise(nullif(trim('CLAIM_SERVICE_CASE#' || coalesce(t0.foreign_key,'')), 'CLAIM_SERVICE_CASE#'))), '')) is not null

)

select
    CASE_BK,
    CASE_WORKFLOW_TASK__TASK_CODE_CK,
    first_value(CASE_WORKFLOW_TASK__ASSIGNED_TO_REFERENCE) ignore nulls over (partition by CASE_BK, CASE_WORKFLOW_TASK__TASK_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CASE_WORKFLOW_TASK__ASSIGNED_TO_REFERENCE,
    first_value(CASE_WORKFLOW_TASK__COMPLETED_DATE) ignore nulls over (partition by CASE_BK, CASE_WORKFLOW_TASK__TASK_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CASE_WORKFLOW_TASK__COMPLETED_DATE,
    first_value(CASE_WORKFLOW_TASK__DUE_DATE) ignore nulls over (partition by CASE_BK, CASE_WORKFLOW_TASK__TASK_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CASE_WORKFLOW_TASK__DUE_DATE,
    first_value(CASE_WORKFLOW_TASK__OUTCOME) ignore nulls over (partition by CASE_BK, CASE_WORKFLOW_TASK__TASK_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CASE_WORKFLOW_TASK__OUTCOME,
    first_value(CASE_WORKFLOW_TASK__QUEUE_REFERENCE) ignore nulls over (partition by CASE_BK, CASE_WORKFLOW_TASK__TASK_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CASE_WORKFLOW_TASK__QUEUE_REFERENCE,
    first_value(CASE_WORKFLOW_TASK__TASK_NAME) ignore nulls over (partition by CASE_BK, CASE_WORKFLOW_TASK__TASK_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CASE_WORKFLOW_TASK__TASK_NAME,
    first_value(CASE_WORKFLOW_TASK__TASK_STATUS) ignore nulls over (partition by CASE_BK, CASE_WORKFLOW_TASK__TASK_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CASE_WORKFLOW_TASK__TASK_STATUS,
    first_value(CASE_WORKFLOW_TASK__TASK_TYPE) ignore nulls over (partition by CASE_BK, CASE_WORKFLOW_TASK__TASK_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CASE_WORKFLOW_TASK__TASK_TYPE
from merged
