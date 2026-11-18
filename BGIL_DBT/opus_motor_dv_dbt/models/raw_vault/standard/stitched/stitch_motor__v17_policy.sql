-- CENTRAL VIEW v17_policy -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   BGIL_MOTOR_WEBSERVICE_INFO_EQM
--   BGIL_MOTOR_WS_PLAN_DETAILS_EQM
--   BJAZ_AGENCY_MOT_WAR_DTLS
--   BJAZ_CVTP_WS_DATA
--   BJAZ_MOTOR_WEBSERVICE_INFO
--   BJAZ_MOTOR_WS_PLAN_DETAILS
--   BJAZ_MOT_ONLINE_POL_DTLS
--   BJAZ_MOT_ONLINE_POL_DTLS_EXTN
--   BJAZ_MOT_RENEWAL
--   BJAZ_MOT_RENEWAL_HIST
--   BJAZ_MOT_RNW_VALIDATE_VEH_DTLS
--   BJAZ_MOT_RN_CLS_VEH_DTLS_HIST
--   BJAZ_MOT_SPECIAL_POLICY
--   BJAZ_MOT_WAR_PLANS_EXTN
--   BJAZ_MOT_WINBACK_DTLS
--   BJAZ_MOT_WS_POL_DTLS
--   WRN_BJAZ_MOT_RENEWAL
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_COMMON_BUSINESS_AUDIT
--   SAT_COMMON_LIFECYCLE
-- Links whose legs come from one source row on this view (rule 6):
-- OVER the table limit by rule 3: one satellite on this view needs every feeding table.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: BGIL_MOTOR_WEBSERVICE_INFO_EQM
    select
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        t0.user_name as COMMON_BUSINESS_AUDIT__CREATED_BY_USER_REFERENCE,
        cast(null as varchar) as COMMON_BUSINESS_AUDIT__SOURCE_APPLICATION_NAME,
        cast(null as varchar) as COMMON_LIFECYCLE__EFFECTIVE_DATE,
        cast(null as varchar) as COMMON_LIFECYCLE__EXPIRY_DATE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bgil_motor_webservice_info_eqm') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 1: BGIL_MOTOR_WS_PLAN_DETAILS_EQM
    select
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null,
        t0.module_from as COMMON_BUSINESS_AUDIT__SOURCE_APPLICATION_NAME,
        null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bgil_motor_ws_plan_details_eqm') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 2: BJAZ_AGENCY_MOT_WAR_DTLS
    select
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        t0.user_name as COMMON_BUSINESS_AUDIT__CREATED_BY_USER_REFERENCE,
        null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_agency_mot_war_dtls') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 3: BJAZ_CVTP_WS_DATA
    select
        nullif(nullif(trim(t0.bjazpolicyno), ''), '') as POLICY_BK,
        t0.username as COMMON_BUSINESS_AUDIT__CREATED_BY_USER_REFERENCE,
        null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (nullif(nullif(trim(t0.bjazpolicyno), ''), '')) is not null

    union all

    -- branch 4: BJAZ_MOTOR_WEBSERVICE_INFO
    select
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        t0.user_name as COMMON_BUSINESS_AUDIT__CREATED_BY_USER_REFERENCE,
        null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_webservice_info') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 5: BJAZ_MOTOR_WS_PLAN_DETAILS
    select
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null,
        t0.module_from as COMMON_BUSINESS_AUDIT__SOURCE_APPLICATION_NAME,
        null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_ws_plan_details') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 6: BJAZ_MOT_ONLINE_POL_DTLS
    select
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        t0.username as COMMON_BUSINESS_AUDIT__CREATED_BY_USER_REFERENCE,
        t0.data_source as COMMON_BUSINESS_AUDIT__SOURCE_APPLICATION_NAME,
        t0.business_start_date as COMMON_LIFECYCLE__EFFECTIVE_DATE,
        t0.business_end_date as COMMON_LIFECYCLE__EXPIRY_DATE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 7: BJAZ_MOT_ONLINE_POL_DTLS_EXTN
    select
        nullif(nullif(trim(t0.spca_policy_ref), ''), '') as POLICY_BK,
        t0.username as COMMON_BUSINESS_AUDIT__CREATED_BY_USER_REFERENCE,
        null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls_extn') }} t0
    where (nullif(nullif(trim(t0.spca_policy_ref), ''), '')) is not null

    union all

    -- branch 8: BJAZ_MOT_RENEWAL
    select
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        t0.web_userid as COMMON_BUSINESS_AUDIT__CREATED_BY_USER_REFERENCE,
        null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 9: BJAZ_MOT_RENEWAL_HIST
    select
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        t0.web_userid as COMMON_BUSINESS_AUDIT__CREATED_BY_USER_REFERENCE,
        null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_hist') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 10: BJAZ_MOT_RNW_VALIDATE_VEH_DTLS
    select
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        t0.user_id as COMMON_BUSINESS_AUDIT__CREATED_BY_USER_REFERENCE,
        null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        10 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_rnw_validate_veh_dtls') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 11: BJAZ_MOT_RN_CLS_VEH_DTLS_HIST
    select
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        t0.user_id as COMMON_BUSINESS_AUDIT__CREATED_BY_USER_REFERENCE,
        null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        11 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_rn_cls_veh_dtls_hist') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 12: BJAZ_MOT_SPECIAL_POLICY
    select
        nullif(nullif(trim(t0.mot_policy_ref), ''), '') as POLICY_BK,
        t0.user_id as COMMON_BUSINESS_AUDIT__CREATED_BY_USER_REFERENCE,
        null,
        t0.eff_date as COMMON_LIFECYCLE__EFFECTIVE_DATE,
        null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_special_policy') }} t0
    where (nullif(nullif(trim(t0.mot_policy_ref), ''), '')) is not null

    union all

    -- branch 13: BJAZ_MOT_WAR_PLANS_EXTN
    select
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        t0.user_name as COMMON_BUSINESS_AUDIT__CREATED_BY_USER_REFERENCE,
        null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        13 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_war_plans_extn') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 14: BJAZ_MOT_WINBACK_DTLS
    select
        nullif(nullif(trim(t0.bjazpolicyno), ''), '') as POLICY_BK,
        t0.userid as COMMON_BUSINESS_AUDIT__CREATED_BY_USER_REFERENCE,
        null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        14 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_winback_dtls') }} t0
    where (nullif(nullif(trim(t0.bjazpolicyno), ''), '')) is not null

    union all

    -- branch 15: BJAZ_MOT_WS_POL_DTLS
    select
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null,
        t0.data_source as COMMON_BUSINESS_AUDIT__SOURCE_APPLICATION_NAME,
        t0.business_start_date as COMMON_LIFECYCLE__EFFECTIVE_DATE,
        t0.business_end_date as COMMON_LIFECYCLE__EXPIRY_DATE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        15 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 16: WRN_BJAZ_MOT_RENEWAL
    select
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        t0.web_userid as COMMON_BUSINESS_AUDIT__CREATED_BY_USER_REFERENCE,
        null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        16 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__wrn_bjaz_mot_renewal') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

)

select
    POLICY_BK,
    first_value(COMMON_BUSINESS_AUDIT__CREATED_BY_USER_REFERENCE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_BUSINESS_AUDIT__CREATED_BY_USER_REFERENCE,
    first_value(COMMON_BUSINESS_AUDIT__SOURCE_APPLICATION_NAME) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_BUSINESS_AUDIT__SOURCE_APPLICATION_NAME,
    first_value(COMMON_LIFECYCLE__EFFECTIVE_DATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_LIFECYCLE__EFFECTIVE_DATE,
    first_value(COMMON_LIFECYCLE__EXPIRY_DATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_LIFECYCLE__EXPIRY_DATE,
    -- the row's own source time: LOAD_DATETIME for hubs, links and single-active satellites
    m.INC_JOB_UPDATED_AT
from merged m
