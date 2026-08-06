{{ config(materialized='view') }}

-- STANDARD-MODEL stitch view for SAT_ASSESSMENT_HEADER (HUB_ASSESSMENT grain).
-- Attribute-level merge across 4 table(s) sharing this grain: FULL OUTER JOIN + COALESCE.
-- Reads raw production staging directly (stg_health__*) -- NOT a per-table stage() output; there is
-- nothing to hash until this join has produced one clean row per key. Hashing happens exactly once,
-- downstream, in the companion stg2_assessment_header.sql stage() model.

select parent_bk, assessment_reference_number, assessment_status, assessment_type, assessor_reference, completed_date, conducted_date, cost_of_assessment, outcome_summary, priority, scheduled_date, record_source
from (
    with t0 as (
        select distinct
            scrutiny_no as parent_bk,
            nullif(trim(to_varchar(appointment_code)), '') as assessment_reference_number,
            nullif(trim(to_varchar(status_code)), '') as assessment_status,
            nullif(trim(to_varchar(type_of_checkup)), '') as assessment_type,
            nullif(trim(to_varchar(checkup_amt)), '') as cost_of_assessment,
            nullif(trim(to_varchar(remarks)), '') as outcome_summary,
            nullif(trim(to_varchar(priority_flag)), '') as priority,
            nullif(trim(to_varchar(app_date)), '') as scheduled_date
        from {{ ref('stg_health__ba_hcp_pp_mem_dtls') }}
        where scrutiny_no is not null
        qualify row_number() over (partition by parent_bk order by assessment_reference_number, assessment_status, assessment_type, cost_of_assessment, outcome_summary, priority, scheduled_date) = 1
    ),
         t1 as (
        select distinct
            pd_scrutiny_number as parent_bk,
            nullif(trim(to_varchar(plc_medical_test_alrdy_con)), '') as assessment_status
        from {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
        where pd_scrutiny_number is not null
        qualify row_number() over (partition by parent_bk order by assessment_status) = 1
    ),
         t2 as (
        select distinct
            assess_id as parent_bk,
            nullif(trim(to_varchar(assessment_edate)), '') as completed_date,
            nullif(trim(to_varchar(assessment_sdate)), '') as conducted_date
        from {{ ref('stg_health__bjaz_hm_pro_assessment') }}
        where assess_id is not null
        qualify row_number() over (partition by parent_bk order by completed_date, conducted_date) = 1
    ),
         t3 as (
        select distinct
            scrutiny_no as parent_bk,
            nullif(trim(to_varchar(status)), '') as assessment_status
        from {{ ref('stg_health__bjaz_scr_hlth_portable_dtls') }}
        where scrutiny_no is not null
        qualify row_number() over (partition by parent_bk order by assessment_status) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk, t2.parent_bk, t3.parent_bk) as parent_bk,
        coalesce(t0.assessment_reference_number) as assessment_reference_number,
        coalesce(t0.assessment_status, t1.assessment_status, t3.assessment_status) as assessment_status,
        coalesce(t0.assessment_type) as assessment_type,
        cast(null as varchar) as assessor_reference,
        coalesce(t2.completed_date) as completed_date,
        coalesce(t2.conducted_date) as conducted_date,
        coalesce(t0.cost_of_assessment) as cost_of_assessment,
        coalesce(t0.outcome_summary) as outcome_summary,
        coalesce(t0.priority) as priority,
        coalesce(t0.scheduled_date) as scheduled_date,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BA_HCP_PP_MEM_DTLS' end, case when t1.parent_bk is not null then 'BA_HCP_PROD_8439_CLH_LOADER' end, case when t2.parent_bk is not null then 'BJAZ_HM_PRO_ASSESSMENT' end, case when t3.parent_bk is not null then 'BJAZ_SCR_HLTH_PORTABLE_DTLS' end), ', ') as record_source
    from t0
    full outer join t1 on t0.parent_bk = t1.parent_bk
    full outer join t2 on coalesce(t0.parent_bk, t1.parent_bk) = t2.parent_bk
    full outer join t3 on coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk) = t3.parent_bk
    )
