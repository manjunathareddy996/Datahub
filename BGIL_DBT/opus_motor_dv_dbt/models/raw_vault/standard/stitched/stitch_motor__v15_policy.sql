-- CENTRAL VIEW v15_policy -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   BGIL_MOTWS_OTHER_DTLS_EQM
--   BJAZ_IIB_SUDARS_POLICY_DTL_HST_QM
--   BJAZ_MOT_INS_HST_EXTN
--   BJAZ_MOT_RNW_VALIDATE_VEH_DTLS
--   BJAZ_MOT_RN_CLS_VEH_DTLS_HIST
--   BJAZ_MOT_WS_POL_DTLS
--   BJAZ_RTA_STATE_MASTER
--   BJAZ_SCR_MOT_VEH_DTLS
--   BJAZ_VAHAN_AUTO_ENDT_LOG
--   RTO_MASTER
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_MOTOR_AUG_COMMON_BUSINESS_AUDIT
--   SAT_MOTOR_AUG_COMMON_GEO
--   SAT_MOTOR_AUG_POLICY_ENDORSEMENT
--   SAT_MOTOR_AUG_POLICY_EXTERNAL_TP_LINK
--   SAT_COMMON_ADMIN_GEOGRAPHY
--   SAT_POLICY_BONUS_TRACKING
--   SAT_POLICY_ENDORSEMENT
--   SAT_RISK_MOTOR_VERIFICATION
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_POLICY_PRODUCT
--   LNK_POLICY_RISK_OBJECT
--   LNK_PROPOSAL_RISK_OBJECT
--   LNK_QUOTE_RISK_OBJECT
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: BGIL_MOTWS_OTHER_DTLS_EQM
    select
        cast(null as varchar) as LOCATION_BK,
        cast(null as varchar) as POLICY_BK,
        cast(null as varchar) as PRODUCT_BK,
        cast(null as varchar) as PROPOSAL_BK,
        cast(null as varchar) as QUOTE_BK,
        nullif(nullif(trim(t0.reg_no), ''), '') as RISK_OBJECT_BK,
        cast(null as number) as __LNK_POLICY_PRODUCT,
        cast(null as number) as __LNK_POLICY_RISK_OBJECT,
        cast(null as number) as __LNK_PROPOSAL_RISK_OBJECT,
        cast(null as number) as __LNK_QUOTE_RISK_OBJECT,
        cast(null as varchar) as AUG_COMMON_BUSINESS_AUDIT__LAST_MODIFIED_BY_USER_NAME,
        cast(null as varchar) as AUG_COMMON_BUSINESS_AUDIT__LAST_MODIFIED_BY_USER_REFERENCE,
        cast(null as varchar) as AUG_COMMON_GEO__TEMPERATURE_ZONE_CODE,
        cast(null as varchar) as AUG_POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER_CK,
        cast(null as varchar) as AUG_POLICY_ENDORSEMENT__ENDORSEMENT_REMARKS,
        cast(null as varchar) as AUG_POLICY_EXTERNAL_TP_LINK__OD_POLICY_END_DATE,
        cast(null as varchar) as AUG_POLICY_EXTERNAL_TP_LINK__OD_POLICY_START_DATE,
        cast(null as varchar) as COMMON_ADMIN_GEOGRAPHY__DISTRICT_NAME,
        cast(null as varchar) as COMMON_ADMIN_GEOGRAPHY__PIN_CODE,
        cast(null as varchar) as COMMON_ADMIN_GEOGRAPHY__RTO_REGION_CODE,
        cast(null as varchar) as COMMON_ADMIN_GEOGRAPHY__STATE_NAME,
        cast(null as varchar) as POLICY_BONUS_TRACKING__BONUS_CARRIED_FORWARD_PERCENTAGE,
        cast(null as varchar) as POLICY_BONUS_TRACKING__NCB_PERCENTAGE,
        cast(null as varchar) as POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER_CK,
        cast(null as varchar) as POLICY_ENDORSEMENT__ENDORSEMENT_CHANNEL,
        cast(null as varchar) as POLICY_ENDORSEMENT__ENDORSEMENT_DATE,
        cast(null as varchar) as POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER,
        cast(null as varchar) as RISK_MOTOR_VERIFICATION__VAHAN_CHECK_STATUS,
        cast(null as varchar) as RISK_MOTOR_VERIFICATION__VEHICLE_VERIFICATION_REFERENCE,
        cast(null as varchar) as RISK_MOTOR_VERIFICATION__VERIFICATION_REMARKS,
        t0.iib_ref_no as RISK_MOTOR_VERIFICATION__VERIFICATION_REQUEST_NUMBER,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bgil_motws_other_dtls_eqm') }} t0
    where (nullif(nullif(trim(t0.reg_no), ''), '')) is not null

    union all

    -- branch 1: BJAZ_IIB_SUDARS_POLICY_DTL_HST_QM
    select
        null,
        nullif(nullif('IIB:' || nullif(trim(t0.policy_no), ''), 'IIB:'), '') as POLICY_BK,
        null,
        nullif(nullif(trim(t0.maximusrefno), ''), '') as PROPOSAL_BK,
        null,
        nullif(nullif(trim(t0.regno), ''), '') as RISK_OBJECT_BK,
        null, null,
        1 as __LNK_PROPOSAL_RISK_OBJECT,
        null, null, null, null, null, null,
        t0.od_policy_end_date as AUG_POLICY_EXTERNAL_TP_LINK__OD_POLICY_END_DATE,
        t0.od_policy_start_date as AUG_POLICY_EXTERNAL_TP_LINK__OD_POLICY_START_DATE,
        null, null, null, null, null,
        t0.ncb_per as POLICY_BONUS_TRACKING__NCB_PERCENTAGE,
        null, null, null, null, null, null, null,
        t0.ref_no as RISK_MOTOR_VERIFICATION__VERIFICATION_REQUEST_NUMBER,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_iib_sudars_policy_dtl_hst_qm') }} t0
    where (coalesce(nullif(nullif('IIB:' || nullif(trim(t0.policy_no), ''), 'IIB:'), ''), nullif(nullif(trim(t0.maximusrefno), ''), ''), nullif(nullif(trim(t0.regno), ''), ''))) is not null

    union all

    -- branch 2: BJAZ_MOT_INS_HST_EXTN
    select
        null,
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.prev_ncb_rate as POLICY_BONUS_TRACKING__BONUS_CARRIED_FORWARD_PERCENTAGE,
        null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ins_hst_extn') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 3: BJAZ_MOT_RNW_VALIDATE_VEH_DTLS
    select
        null,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        nullif(nullif(trim(to_char(t0.product_code)), ''), '') as PRODUCT_BK,
        null, null,
        nullif(coalesce(nullif(trim(t0.chasis_number), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        1 as __LNK_POLICY_PRODUCT,
        1 as __LNK_POLICY_RISK_OBJECT,
        null, null,
        t0.change_status_by_user as AUG_COMMON_BUSINESS_AUDIT__LAST_MODIFIED_BY_USER_NAME,
        t0.status_change_user_id as AUG_COMMON_BUSINESS_AUDIT__LAST_MODIFIED_BY_USER_REFERENCE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.status as RISK_MOTOR_VERIFICATION__VAHAN_CHECK_STATUS,
        t0.vahan_refno as RISK_MOTOR_VERIFICATION__VEHICLE_VERIFICATION_REFERENCE,
        t0.validate_msg as RISK_MOTOR_VERIFICATION__VERIFICATION_REMARKS,
        null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_rnw_validate_veh_dtls') }} t0
    where (coalesce(nullif(coalesce(nullif(trim(t0.chasis_number), ''), nullif(trim(t0.registration_no), '')), ''), nullif(nullif(trim(t0.policy_ref), ''), ''), nullif(nullif(trim(to_char(t0.product_code)), ''), ''))) is not null

    union all

    -- branch 4: BJAZ_MOT_RN_CLS_VEH_DTLS_HIST
    select
        null,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        nullif(nullif(trim(to_char(t0.product_code)), ''), '') as PRODUCT_BK,
        null, null,
        nullif(coalesce(nullif(trim(t0.chasis_number), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        1 as __LNK_POLICY_PRODUCT,
        1 as __LNK_POLICY_RISK_OBJECT,
        null, null,
        t0.change_status_by_user as AUG_COMMON_BUSINESS_AUDIT__LAST_MODIFIED_BY_USER_NAME,
        t0.status_change_user_id as AUG_COMMON_BUSINESS_AUDIT__LAST_MODIFIED_BY_USER_REFERENCE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.status as RISK_MOTOR_VERIFICATION__VAHAN_CHECK_STATUS,
        t0.vahan_refno as RISK_MOTOR_VERIFICATION__VEHICLE_VERIFICATION_REFERENCE,
        t0.validate_msg as RISK_MOTOR_VERIFICATION__VERIFICATION_REMARKS,
        null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_rn_cls_veh_dtls_hist') }} t0
    where (coalesce(nullif(coalesce(nullif(trim(t0.chasis_number), ''), nullif(trim(t0.registration_no), '')), ''), nullif(nullif(trim(t0.policy_ref), ''), ''), nullif(nullif(trim(to_char(t0.product_code)), ''), ''))) is not null

    union all

    -- branch 5: BJAZ_MOT_WS_POL_DTLS
    select
        nullif(md5(normalise(upper(nullif(trim(t0.registration_loc), '')))), '') as LOCATION_BK,
        null, null, null, null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.registration_loc as COMMON_ADMIN_GEOGRAPHY__RTO_REGION_CODE,
        null, null, null, null, null, null, null, null, null,
        t0.damage_details as RISK_MOTOR_VERIFICATION__VERIFICATION_REMARKS,
        null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (coalesce(nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), ''), nullif(md5(normalise(upper(nullif(trim(t0.registration_loc), '')))), ''))) is not null

    union all

    -- branch 6: BJAZ_RTA_STATE_MASTER
    select
        nullif(md5(normalise(upper(nullif(coalesce(t0.state, ''), '')))), '') as LOCATION_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.state as COMMON_ADMIN_GEOGRAPHY__STATE_NAME,
        null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_rta_state_master') }} t0
    where (nullif(md5(normalise(upper(nullif(coalesce(t0.state, ''), '')))), '')) is not null

    union all

    -- branch 7: BJAZ_SCR_MOT_VEH_DTLS
    select
        null, null, null, null,
        nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '') as QUOTE_BK,
        nullif(coalesce(nullif(trim(t0.chasis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null,
        1 as __LNK_QUOTE_RISK_OBJECT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.vahan_ref_no as RISK_MOTOR_VERIFICATION__VEHICLE_VERIFICATION_REFERENCE,
        null,
        t0.iib_ref_no as RISK_MOTOR_VERIFICATION__VERIFICATION_REQUEST_NUMBER,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_scr_mot_veh_dtls') }} t0
    where (coalesce(nullif(coalesce(nullif(trim(t0.chasis_no), ''), nullif(trim(t0.registration_no), '')), ''), nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), ''))) is not null

    union all

    -- branch 8: BJAZ_VAHAN_AUTO_ENDT_LOG
    select
        null,
        nullif(nullif(trim(t0.policy_no), ''), '') as POLICY_BK,
        null, null, null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.reg_no), '')), '') as RISK_OBJECT_BK,
        null,
        1 as __LNK_POLICY_RISK_OBJECT,
        null, null, null, null, null,
        t0.endt_no as AUG_POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER_CK,
        t0.remark as AUG_POLICY_ENDORSEMENT__ENDORSEMENT_REMARKS,
        null, null, null, null, null, null, null, null,
        t0.endt_no as POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER_CK,
        t0.issuance_source as POLICY_ENDORSEMENT__ENDORSEMENT_CHANNEL,
        t0.log_date as POLICY_ENDORSEMENT__ENDORSEMENT_DATE,
        t0.endt_no as POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER,
        t0.rta_flag as RISK_MOTOR_VERIFICATION__VAHAN_CHECK_STATUS,
        null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_vahan_auto_endt_log') }} t0
    where (coalesce(nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.reg_no), '')), ''), nullif(nullif(trim(t0.policy_no), ''), ''))) is not null

    union all

    -- branch 9: RTO_MASTER
    select
        nullif(nullif('RTO:' || nullif(trim(t0.rta_code), ''), 'RTO:'), '') as LOCATION_BK,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.temperature_zone as AUG_COMMON_GEO__TEMPERATURE_ZONE_CODE,
        null, null, null, null,
        t0.rta_district as COMMON_ADMIN_GEOGRAPHY__DISTRICT_NAME,
        t0.rta_pincode as COMMON_ADMIN_GEOGRAPHY__PIN_CODE,
        null,
        t0.rta_state as COMMON_ADMIN_GEOGRAPHY__STATE_NAME,
        null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__rto_master') }} t0
    where (nullif(nullif('RTO:' || nullif(trim(t0.rta_code), ''), 'RTO:'), '')) is not null

)

select
    LOCATION_BK,
    POLICY_BK,
    PRODUCT_BK,
    PROPOSAL_BK,
    QUOTE_BK,
    RISK_OBJECT_BK,
    __LNK_POLICY_PRODUCT,
    __LNK_POLICY_RISK_OBJECT,
    __LNK_PROPOSAL_RISK_OBJECT,
    __LNK_QUOTE_RISK_OBJECT,
    first_value(AUG_COMMON_BUSINESS_AUDIT__LAST_MODIFIED_BY_USER_NAME) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COMMON_BUSINESS_AUDIT__LAST_MODIFIED_BY_USER_NAME,
    first_value(AUG_COMMON_BUSINESS_AUDIT__LAST_MODIFIED_BY_USER_REFERENCE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COMMON_BUSINESS_AUDIT__LAST_MODIFIED_BY_USER_REFERENCE,
    first_value(AUG_COMMON_GEO__TEMPERATURE_ZONE_CODE) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COMMON_GEO__TEMPERATURE_ZONE_CODE,
    AUG_POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER_CK,
    first_value(AUG_POLICY_ENDORSEMENT__ENDORSEMENT_REMARKS) ignore nulls over (partition by POLICY_BK, AUG_POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_ENDORSEMENT__ENDORSEMENT_REMARKS,
    first_value(AUG_POLICY_EXTERNAL_TP_LINK__OD_POLICY_END_DATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_EXTERNAL_TP_LINK__OD_POLICY_END_DATE,
    first_value(AUG_POLICY_EXTERNAL_TP_LINK__OD_POLICY_START_DATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_EXTERNAL_TP_LINK__OD_POLICY_START_DATE,
    first_value(COMMON_ADMIN_GEOGRAPHY__DISTRICT_NAME) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADMIN_GEOGRAPHY__DISTRICT_NAME,
    first_value(COMMON_ADMIN_GEOGRAPHY__PIN_CODE) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADMIN_GEOGRAPHY__PIN_CODE,
    first_value(COMMON_ADMIN_GEOGRAPHY__RTO_REGION_CODE) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADMIN_GEOGRAPHY__RTO_REGION_CODE,
    first_value(COMMON_ADMIN_GEOGRAPHY__STATE_NAME) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADMIN_GEOGRAPHY__STATE_NAME,
    first_value(POLICY_BONUS_TRACKING__BONUS_CARRIED_FORWARD_PERCENTAGE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_BONUS_TRACKING__BONUS_CARRIED_FORWARD_PERCENTAGE,
    first_value(POLICY_BONUS_TRACKING__NCB_PERCENTAGE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_BONUS_TRACKING__NCB_PERCENTAGE,
    POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER_CK,
    first_value(POLICY_ENDORSEMENT__ENDORSEMENT_CHANNEL) ignore nulls over (partition by POLICY_BK, POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_ENDORSEMENT__ENDORSEMENT_CHANNEL,
    first_value(POLICY_ENDORSEMENT__ENDORSEMENT_DATE) ignore nulls over (partition by POLICY_BK, POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_ENDORSEMENT__ENDORSEMENT_DATE,
    first_value(POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER) ignore nulls over (partition by POLICY_BK, POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER,
    first_value(RISK_MOTOR_VERIFICATION__VAHAN_CHECK_STATUS) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_VERIFICATION__VAHAN_CHECK_STATUS,
    first_value(RISK_MOTOR_VERIFICATION__VEHICLE_VERIFICATION_REFERENCE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_VERIFICATION__VEHICLE_VERIFICATION_REFERENCE,
    first_value(RISK_MOTOR_VERIFICATION__VERIFICATION_REMARKS) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_VERIFICATION__VERIFICATION_REMARKS,
    first_value(RISK_MOTOR_VERIFICATION__VERIFICATION_REQUEST_NUMBER) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_VERIFICATION__VERIFICATION_REQUEST_NUMBER,
    -- the row's own source time: LOAD_DATETIME for hubs, links and single-active satellites
    m.INC_JOB_UPDATED_AT,
    -- multi-active satellites on POLICY_BK (SAT_MOTOR_AUG_POLICY_ENDORSEMENT, SAT_POLICY_ENDORSEMENT):
    -- one load time per POLICY_BK, the newest INC_JOB_UPDATED_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when coalesce(m.AUG_POLICY_ENDORSEMENT__ENDORSEMENT_REMARKS, m.POLICY_ENDORSEMENT__ENDORSEMENT_CHANNEL, m.POLICY_ENDORSEMENT__ENDORSEMENT_DATE, m.POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER) is not null
             then m.INC_JOB_UPDATED_AT end)
        over (partition by m.POLICY_BK) as POLICY_BK__MA_LOAD_DATETIME
from merged m
