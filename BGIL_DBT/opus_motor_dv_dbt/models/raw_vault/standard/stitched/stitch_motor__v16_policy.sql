-- CENTRAL VIEW v16_policy -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   BGIL_MOTOR_WEBSERVICE_INFO_EQM
--   BGIL_MOTOR_WS_PLAN_DETAILS_EQM
--   BJAZ_AGENCY_MOT_WAR_DTLS
--   BJAZ_CVTP_WS_DATA
--   BJAZ_IIB_SUDARS_POLICY_DTL_HST_QM
--   BJAZ_MOTOR_WEBSERVICE_INFO
--   BJAZ_MOTOR_WS_PLAN_DETAILS
--   BJAZ_MOT_OD_TP_DTLS
--   BJAZ_MOT_ONLINE_POL_DTLS
--   BJAZ_MOT_ONLINE_POL_DTLS_EXTN
--   BJAZ_MOT_RENEWAL
--   BJAZ_MOT_RENEWAL_EXTN
--   BJAZ_MOT_RENEWAL_HIST
--   BJAZ_MOT_SPECIAL_POLICY
--   BJAZ_MOT_WAR_CHILD_DTLS
--   BJAZ_MOT_WAR_MAST_DTLS
--   BJAZ_MOT_WINBACK_DTLS
--   BJAZ_MOT_WS_POL_DTLS
--   BJAZ_VAHAN_AUTO_ENDT_LOG
--   WRN_BJAZ_MOT_RENEWAL
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_MOTOR_AUG_POLICY_EXTENDED_WARRANTY
--   SAT_MOTOR_AUG_POLICY_PREMIUM_SUMMARY
--   SAT_POLICY_HEADER
--   SAT_POLICY_PREMIUM_SUMMARY
--   SAT_POLICY_TAX_HEAD
--   SAT_RISK_OBJECT_CORE
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_FINTXN_POLICY
--   LNK_POLICY_CHANNEL
-- OVER the table limit by rule 3: one satellite on this view needs every feeding table.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: BGIL_MOTOR_WEBSERVICE_INFO_EQM
    select
        cast(null as varchar) as DISTRIBUTION_CHANNEL_BK,
        cast(null as varchar) as FINANCIAL_TRANSACTION_BK,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        cast(null as varchar) as RISK_OBJECT_BK,
        cast(null as number) as __LNK_FINTXN_POLICY,
        cast(null as number) as __LNK_POLICY_CHANNEL,
        cast(null as varchar) as AUG_POLICY_EXTENDED_WARRANTY__CHILD_PRODUCT_CODE,
        cast(null as varchar) as AUG_POLICY_EXTENDED_WARRANTY__WARRANTY_SUB_TYPE,
        cast(null as varchar) as AUG_POLICY_EXTENDED_WARRANTY__WARRANTY_TYPE,
        cast(null as varchar) as AUG_POLICY_PREMIUM_SUMMARY__BOOKED_PREMIUM_AMOUNT,
        cast(null as varchar) as AUG_POLICY_PREMIUM_SUMMARY__DEVIATED_GROSS_PREMIUM,
        cast(null as varchar) as AUG_POLICY_PREMIUM_SUMMARY__FULL_TERM_PREMIUM,
        cast(null as varchar) as AUG_POLICY_PREMIUM_SUMMARY__MINIMUM_GROSS_PREMIUM,
        cast(null as varchar) as AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_BREAKUP_TEXT,
        cast(null as varchar) as AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_CALCULATED_BY,
        cast(null as varchar) as AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_PAYMENT_MODE,
        cast(null as varchar) as POLICY_HEADER__CONVERSION_FROM_QUOTE_INDICATOR,
        cast(null as varchar) as POLICY_HEADER__COVER_NOTE_REFERENCE,
        cast(null as varchar) as POLICY_HEADER__ISSUE_DATE,
        cast(null as varchar) as POLICY_HEADER__ISSUING_CHANNEL_REFERENCE,
        cast(null as varchar) as POLICY_HEADER__ISSUING_ORG_UNIT_CODE,
        cast(null as varchar) as POLICY_HEADER__MASTER_POLICY_REFERENCE,
        cast(null as varchar) as POLICY_HEADER__NUMBER_OF_LIVES_COVERED,
        cast(null as varchar) as POLICY_HEADER__POLICY_CHANNEL_TYPE,
        cast(null as varchar) as POLICY_HEADER__POLICY_NUMBER,
        t0.contract_id as POLICY_HEADER__POLICY_REFERENCE_NUMBER,
        t0.remarks as POLICY_HEADER__POLICY_REMARKS,
        cast(null as varchar) as POLICY_HEADER__POLICY_STATUS,
        cast(null as varchar) as POLICY_HEADER__POLICY_TERM,
        cast(null as varchar) as POLICY_HEADER__POLICY_TERM_DAYS,
        cast(null as varchar) as POLICY_HEADER__POLICY_TYPE,
        t0.term_end_date as POLICY_HEADER__RISK_EXPIRY_DATE,
        t0.term_start_date as POLICY_HEADER__RISK_INCEPTION_DATE,
        cast(null as varchar) as POLICY_HEADER__RISK_START_TIME,
        cast(null as varchar) as POLICY_HEADER__SERVICING_ORG_UNIT_CODE,
        cast(null as varchar) as POLICY_HEADER__SHORT_PERIOD_INDICATOR,
        cast(null as varchar) as POLICY_PREMIUM_SUMMARY__CGST_AMOUNT,
        cast(null as varchar) as POLICY_PREMIUM_SUMMARY__DISCOUNT_AMOUNT,
        t0.gross_premium as POLICY_PREMIUM_SUMMARY__GROSS_PREMIUM,
        t0.service_tax_amt as POLICY_PREMIUM_SUMMARY__GST_AMOUNT,
        cast(null as varchar) as POLICY_PREMIUM_SUMMARY__IGST_AMOUNT,
        cast(null as varchar) as POLICY_PREMIUM_SUMMARY__LOADING_AMOUNT,
        cast(null as varchar) as POLICY_PREMIUM_SUMMARY__LONG_TERM_DISCOUNT_AMOUNT,
        t0.net_premium as POLICY_PREMIUM_SUMMARY__NET_PREMIUM,
        t0.ncb_amt as POLICY_PREMIUM_SUMMARY__NO_CLAIM_BONUS_AMOUNT,
        cast(null as varchar) as POLICY_PREMIUM_SUMMARY__SGST_AMOUNT,
        cast(null as varchar) as POLICY_PREMIUM_SUMMARY__STAMP_DUTY_AMOUNT,
        cast(null as varchar) as POLICY_PREMIUM_SUMMARY__TECHNICAL_PREMIUM,
        cast(null as varchar) as POLICY_PREMIUM_SUMMARY__TERRORISM_PREMIUM,
        cast(null as varchar) as POLICY_TAX_HEAD__TAX_HEAD_CODE_CK,
        cast(null as varchar) as POLICY_TAX_HEAD__TAX_AMOUNT,
        cast(null as varchar) as POLICY_TAX_HEAD__TAX_COMPONENT,
        cast(null as varchar) as POLICY_TAX_HEAD__TAX_HEAD_CODE,
        cast(null as varchar) as POLICY_TAX_HEAD__TAX_HEAD_NAME,
        cast(null as varchar) as RISK_OBJECT_CORE__ACQUISITION_DATE,
        cast(null as varchar) as RISK_OBJECT_CORE__RISK_OBJECT_DESCRIPTION,
        cast(null as varchar) as RISK_OBJECT_CORE__RISK_OBJECT_NAME,
        cast(null as varchar) as RISK_OBJECT_CORE__RISK_OBJECT_REFERENCE_NUMBER,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bgil_motor_webservice_info_eqm') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 1: BGIL_MOTOR_WS_PLAN_DETAILS_EQM
    select
        null, null,
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.partner_type as POLICY_HEADER__POLICY_CHANNEL_TYPE,
        null, null, null, null, null, null,
        t0.pol_type as POLICY_HEADER__POLICY_TYPE,
        t0.term_end_date as POLICY_HEADER__RISK_EXPIRY_DATE,
        t0.term_start_date as POLICY_HEADER__RISK_INCEPTION_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bgil_motor_ws_plan_details_eqm') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 2: BJAZ_AGENCY_MOT_WAR_DTLS
    select
        null, null,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.veh_reg_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.payment_mode as AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_PAYMENT_MODE,
        null, null, null, null, null,
        t0.master_policy as POLICY_HEADER__MASTER_POLICY_REFERENCE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.cgst as POLICY_PREMIUM_SUMMARY__CGST_AMOUNT,
        null,
        t0.gross_premium as POLICY_PREMIUM_SUMMARY__GROSS_PREMIUM,
        null,
        t0.igst as POLICY_PREMIUM_SUMMARY__IGST_AMOUNT,
        null, null, null, null,
        t0.sgst as POLICY_PREMIUM_SUMMARY__SGST_AMOUNT,
        null, null, null, null, null, null, null, null,
        t0.equip_sale_date as RISK_OBJECT_CORE__ACQUISITION_DATE,
        null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_agency_mot_war_dtls') }} t0
    where (coalesce(nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.veh_reg_no), '')), ''), nullif(nullif(trim(t0.policy_ref), ''), ''))) is not null

    union all

    -- branch 3: BJAZ_CVTP_WS_DATA
    select
        null, null,
        nullif(nullif(trim(t0.bjazpolicyno), ''), '') as POLICY_BK,
        nullif(coalesce(nullif(trim(t0.chassisno), ''), nullif(trim(t0.registrationno), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        t0.bjaz_premium as AUG_POLICY_PREMIUM_SUMMARY__BOOKED_PREMIUM_AMOUNT,
        null, null, null, null,
        t0.premiumcalculatedby as AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_CALCULATED_BY,
        null, null, null, null, null, null, null, null, null, null,
        t0.inspolicyno as POLICY_HEADER__POLICY_REFERENCE_NUMBER,
        null, null, null, null,
        t0.inspolicytype as POLICY_HEADER__POLICY_TYPE,
        t0.inspolicyexpirydate as POLICY_HEADER__RISK_EXPIRY_DATE,
        t0.inspolicyeffectivedate as POLICY_HEADER__RISK_INCEPTION_DATE,
        t0.inspolicyeffectivetime as POLICY_HEADER__RISK_START_TIME,
        null, null, null, null,
        t0.grosspremium as POLICY_PREMIUM_SUMMARY__GROSS_PREMIUM,
        t0.servicetax as POLICY_PREMIUM_SUMMARY__GST_AMOUNT,
        null, null, null,
        t0.totalpremium as POLICY_PREMIUM_SUMMARY__NET_PREMIUM,
        t0.ncbamount as POLICY_PREMIUM_SUMMARY__NO_CLAIM_BONUS_AMOUNT,
        null, null, null, null, null, null, null, null, null,
        t0.vehicleinvoicedate as RISK_OBJECT_CORE__ACQUISITION_DATE,
        null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (coalesce(nullif(coalesce(nullif(trim(t0.chassisno), ''), nullif(trim(t0.registrationno), '')), ''), nullif(nullif(trim(t0.bjazpolicyno), ''), ''))) is not null

    union all

    -- branch 4: BJAZ_IIB_SUDARS_POLICY_DTL_HST_QM
    select
        null, null,
        nullif(nullif('IIB:' || nullif(trim(t0.policy_no), ''), 'IIB:'), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.remarks as POLICY_HEADER__POLICY_REMARKS,
        null, null, null,
        t0.type_of_policy as POLICY_HEADER__POLICY_TYPE,
        t0.policy_end_date as POLICY_HEADER__RISK_EXPIRY_DATE,
        t0.policy_start_date as POLICY_HEADER__RISK_INCEPTION_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_iib_sudars_policy_dtl_hst_qm') }} t0
    where (nullif(nullif('IIB:' || nullif(trim(t0.policy_no), ''), 'IIB:'), '')) is not null

    union all

    -- branch 5: BJAZ_MOTOR_WEBSERVICE_INFO
    select
        null, null,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.contract_id as POLICY_HEADER__POLICY_REFERENCE_NUMBER,
        t0.remarks as POLICY_HEADER__POLICY_REMARKS,
        null, null, null, null,
        t0.term_end_date as POLICY_HEADER__RISK_EXPIRY_DATE,
        t0.term_start_date as POLICY_HEADER__RISK_INCEPTION_DATE,
        null, null, null, null, null,
        t0.gross_premium as POLICY_PREMIUM_SUMMARY__GROSS_PREMIUM,
        t0.service_tax_amt as POLICY_PREMIUM_SUMMARY__GST_AMOUNT,
        null, null, null,
        t0.net_premium as POLICY_PREMIUM_SUMMARY__NET_PREMIUM,
        t0.ncb_amt as POLICY_PREMIUM_SUMMARY__NO_CLAIM_BONUS_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_webservice_info') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 6: BJAZ_MOTOR_WS_PLAN_DETAILS
    select
        null, null,
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.partner_type as POLICY_HEADER__POLICY_CHANNEL_TYPE,
        null, null, null, null, null, null,
        t0.pol_type as POLICY_HEADER__POLICY_TYPE,
        t0.term_end_date as POLICY_HEADER__RISK_EXPIRY_DATE,
        t0.term_start_date as POLICY_HEADER__RISK_INCEPTION_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_ws_plan_details') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 7: BJAZ_MOT_OD_TP_DTLS
    select
        null, null,
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.policy_issue_date as POLICY_HEADER__ISSUE_DATE,
        null, null, null, null, null, null,
        t0.policy_ref as POLICY_HEADER__POLICY_REFERENCE_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.gross_premium as POLICY_PREMIUM_SUMMARY__GROSS_PREMIUM,
        null, null, null, null,
        t0.net_premium as POLICY_PREMIUM_SUMMARY__NET_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_od_tp_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 8: BJAZ_MOT_ONLINE_POL_DTLS
    select
        null, null,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        nullif(md5(normalise(upper(nullif(coalesce(t0.student_name, '') || '|' || coalesce(t0.school_name, '') || '|' || coalesce(t0.course, ''), '||')))), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.agree_quote_to_pol as POLICY_HEADER__CONVERSION_FROM_QUOTE_INDICATOR,
        null, null,
        t0.source_id as POLICY_HEADER__ISSUING_CHANNEL_REFERENCE,
        null, null,
        t0.no_of_members as POLICY_HEADER__NUMBER_OF_LIVES_COVERED,
        t0.business_source as POLICY_HEADER__POLICY_CHANNEL_TYPE,
        null,
        t0.contract_id as POLICY_HEADER__POLICY_REFERENCE_NUMBER,
        t0.comments as POLICY_HEADER__POLICY_REMARKS,
        null,
        t0.pol_period as POLICY_HEADER__POLICY_TERM,
        null,
        t0.policy_type as POLICY_HEADER__POLICY_TYPE,
        t0.term_end_date as POLICY_HEADER__RISK_EXPIRY_DATE,
        t0.term_start_date as POLICY_HEADER__RISK_INCEPTION_DATE,
        t0.term_start_time as POLICY_HEADER__RISK_START_TIME,
        null, null, null, null,
        t0.gross_premium as POLICY_PREMIUM_SUMMARY__GROSS_PREMIUM,
        null, null, null,
        t0.lterm_disc_amt as POLICY_PREMIUM_SUMMARY__LONG_TERM_DISCOUNT_AMOUNT,
        null,
        t0.ncb_amt as POLICY_PREMIUM_SUMMARY__NO_CLAIM_BONUS_AMOUNT,
        null,
        t0.stamp_duty_amt as POLICY_PREMIUM_SUMMARY__STAMP_DUTY_AMOUNT,
        null, null, null,
        coalesce(t0.adj_edu_cess_tax, t0.btp_adj_cgst_amt, t0.btp_adj_igst_amt, t0.btp_adj_sgst_amt, t0.btp_adj_utgst_amt, t0.btp_cgst_amt, t0.btp_igst_amt, t0.btp_sgst_amt, t0.btp_utgst_amt, t0.cess1_amt, t0.cess2_amt, t0.cess3_amt, t0.cibil_wd_tax, t0.edu_cess_tax, t0.kkc_amt, t0.ncc_amt, t0.swb_amt, t0.tp_adj_cgst_amt, t0.tp_adj_igst_amt, t0.tp_adj_sgst_amt, t0.tp_adj_utgst_amt, t0.tp_cgst_amt, t0.tp_igst_amt, t0.tp_sgst_amt, t0.tp_utgst_amt) as POLICY_TAX_HEAD__TAX_AMOUNT,
        null,
        coalesce(t0.btp_tax_code, t0.tax_code, t0.tax_type2, t0.tp_tax_code) as POLICY_TAX_HEAD__TAX_HEAD_CODE,
        null, null, null,
        t0.student_name as RISK_OBJECT_CORE__RISK_OBJECT_NAME,
        null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (coalesce(nullif(md5(normalise(upper(nullif(coalesce(t0.student_name, '') || '|' || coalesce(t0.school_name, '') || '|' || coalesce(t0.course, ''), '||')))), ''), nullif(nullif(trim(t0.policy_ref), ''), ''))) is not null

    union all

    -- branch 9: BJAZ_MOT_ONLINE_POL_DTLS
    select
        null, null, null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        t0.vehicle_id as RISK_OBJECT_CORE__RISK_OBJECT_REFERENCE_NUMBER,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 10: BJAZ_MOT_ONLINE_POL_DTLS
    select
        null, null, null,
        nullif(nullif('APPLIANCE:' || nullif(trim(to_char(t0.serial_no)), ''), 'APPLIANCE:'), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        t0.product_description as RISK_OBJECT_CORE__RISK_OBJECT_DESCRIPTION,
        null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(nullif('APPLIANCE:' || nullif(trim(to_char(t0.serial_no)), ''), 'APPLIANCE:'), '')) is not null

    union all

    -- branch 11: BJAZ_MOT_ONLINE_POL_DTLS_EXTN
    select
        null, null,
        nullif(nullif(trim(t0.spca_policy_ref), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null,
        t0.spca_full_term_premium as AUG_POLICY_PREMIUM_SUMMARY__FULL_TERM_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.spca_contract_id as POLICY_HEADER__POLICY_REFERENCE_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.spca_gross_premium as POLICY_PREMIUM_SUMMARY__GROSS_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.spca_tax_type as POLICY_TAX_HEAD__TAX_COMPONENT,
        t0.spca_tax_code as POLICY_TAX_HEAD__TAX_HEAD_CODE,
        null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls_extn') }} t0
    where (nullif(nullif(trim(t0.spca_policy_ref), ''), '')) is not null

    union all

    -- branch 12: BJAZ_MOT_RENEWAL
    select
        null, null,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.location_code as POLICY_HEADER__ISSUING_ORG_UNIT_CODE,
        null, null, null,
        t0.contract_id as POLICY_HEADER__POLICY_NUMBER,
        null, null, null, null, null, null,
        t0.term_end_date as POLICY_HEADER__RISK_EXPIRY_DATE,
        null, null,
        t0.rtm_loc_code as POLICY_HEADER__SERVICING_ORG_UNIT_CODE,
        null, null, null,
        t0.gross_premium as POLICY_PREMIUM_SUMMARY__GROSS_PREMIUM,
        null, null, null, null,
        t0.net_premium as POLICY_PREMIUM_SUMMARY__NET_PREMIUM,
        null, null, null,
        t0.uw_stds_prem as POLICY_PREMIUM_SUMMARY__TECHNICAL_PREMIUM,
        null, null,
        coalesce(t0.cess1_amt, t0.cess2_amt, t0.cess3_amt, t0.cess_total, t0.cess_total_basic_tp, t0.cess_total_tp, t0.edu_cess_tax, t0.kkc_amt, t0.new_service_tax, t0.service_tax, t0.swb_amt) as POLICY_TAX_HEAD__TAX_AMOUNT,
        null,
        t0.tax_code as POLICY_TAX_HEAD__TAX_HEAD_CODE,
        t0.tax_desc as POLICY_TAX_HEAD__TAX_HEAD_NAME,
        null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        10 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 13: BJAZ_MOT_RENEWAL_EXTN
    select
        null, null,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null,
        t0.gross_prem_dev as AUG_POLICY_PREMIUM_SUMMARY__DEVIATED_GROSS_PREMIUM,
        null,
        t0.min_gross_prem as AUG_POLICY_PREMIUM_SUMMARY__MINIMUM_GROSS_PREMIUM,
        null, null, null, null, null, null, null, null, null, null,
        t0.imd_channel as POLICY_HEADER__POLICY_CHANNEL_TYPE,
        null,
        t0.contract_id as POLICY_HEADER__POLICY_REFERENCE_NUMBER,
        t0.remarks as POLICY_HEADER__POLICY_REMARKS,
        null, null, null, null, null, null, null, null,
        t0.short_policy_yn as POLICY_HEADER__SHORT_PERIOD_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.full_yr_terr_prem as POLICY_PREMIUM_SUMMARY__TERRORISM_PREMIUM,
        null,
        coalesce(t0.adj_cgst_amt, t0.adj_igst_amt, t0.adj_ncc_amt, t0.adj_sgst_amt, t0.adj_utgst_amt, t0.cgst_amt, t0.igst_amt, t0.ncc_amt, t0.sgst_amt, t0.utgst_amt) as POLICY_TAX_HEAD__TAX_AMOUNT,
        null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        11 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_extn') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 14: BJAZ_MOT_RENEWAL_HIST
    select
        null, null,
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.remarks as POLICY_HEADER__POLICY_REMARKS,
        null, null, null, null,
        t0.term_end_date as POLICY_HEADER__RISK_EXPIRY_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        coalesce(t0.edu_cess_tax, t0.new_service_tax, t0.service_tax) as POLICY_TAX_HEAD__TAX_AMOUNT,
        null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_hist') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 15: BJAZ_MOT_SPECIAL_POLICY
    select
        null, null,
        nullif(nullif(trim(t0.mot_policy_ref), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.gc_policy_ref as POLICY_HEADER__MASTER_POLICY_REFERENCE,
        null, null, null, null, null, null, null, null,
        t0.pol_type as POLICY_HEADER__POLICY_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        13 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_special_policy') }} t0
    where (nullif(nullif(trim(t0.mot_policy_ref), ''), '')) is not null

    union all

    -- branch 16: BJAZ_MOT_WAR_CHILD_DTLS
    select
        null, null,
        nullif(nullif(trim(t0.motor_policy_no), ''), '') as POLICY_BK,
        nullif(coalesce(nullif(trim(t0.vehicle_reg_no), ''), nullif(trim(t0.equipment_serial_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.motor_covernote_no as POLICY_HEADER__COVER_NOTE_REFERENCE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.commercial_discount as POLICY_PREMIUM_SUMMARY__DISCOUNT_AMOUNT,
        null, null, null,
        t0.underwriting_loading as POLICY_PREMIUM_SUMMARY__LOADING_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.equipment_sale_date as RISK_OBJECT_CORE__ACQUISITION_DATE,
        null, null,
        t0.equipment_serial_no as RISK_OBJECT_CORE__RISK_OBJECT_REFERENCE_NUMBER,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        14 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_war_child_dtls') }} t0
    where (coalesce(nullif(coalesce(nullif(trim(t0.vehicle_reg_no), ''), nullif(trim(t0.equipment_serial_no), '')), ''), nullif(nullif(trim(t0.motor_policy_no), ''), ''))) is not null

    union all

    -- branch 17: BJAZ_MOT_WAR_MAST_DTLS
    select
        nullif(nullif('DEALER:' || nullif(trim(to_char(t0.partner_id)), ''), 'DEALER:'), '') as DISTRIBUTION_CHANNEL_BK,
        nullif(nullif(trim(to_char(t0.transaction_id)), ''), '') as FINANCIAL_TRANSACTION_BK,
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null,
        1 as __LNK_FINTXN_POLICY,
        1 as __LNK_POLICY_CHANNEL,
        t0.child_product_code as AUG_POLICY_EXTENDED_WARRANTY__CHILD_PRODUCT_CODE,
        t0.subtype_of_warranty as AUG_POLICY_EXTENDED_WARRANTY__WARRANTY_SUB_TYPE,
        t0.type_of_warranty as AUG_POLICY_EXTENDED_WARRANTY__WARRANTY_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.policy_status as POLICY_HEADER__POLICY_STATUS,
        null, null, null,
        t0.policy_end_date as POLICY_HEADER__RISK_EXPIRY_DATE,
        t0.policy_start_date as POLICY_HEADER__RISK_INCEPTION_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        15 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_war_mast_dtls') }} t0
    where (coalesce(nullif(nullif('DEALER:' || nullif(trim(to_char(t0.partner_id)), ''), 'DEALER:'), ''), nullif(nullif(trim(to_char(t0.contract_id)), ''), ''), nullif(nullif(trim(to_char(t0.transaction_id)), ''), ''))) is not null

    union all

    -- branch 18: BJAZ_MOT_WINBACK_DTLS
    select
        null, null,
        nullif(nullif(trim(t0.bjazpolicyno), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null,
        t0.prem_dtls as AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_BREAKUP_TEXT,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.contract_id as POLICY_HEADER__POLICY_REFERENCE_NUMBER,
        null, null, null, null, null,
        t0.term_end_date as POLICY_HEADER__RISK_EXPIRY_DATE,
        t0.term_start_date as POLICY_HEADER__RISK_INCEPTION_DATE,
        null, null, null, null, null,
        t0.total_premium as POLICY_PREMIUM_SUMMARY__GROSS_PREMIUM,
        t0.total_tax as POLICY_PREMIUM_SUMMARY__GST_AMOUNT,
        null, null, null,
        t0.net_premium as POLICY_PREMIUM_SUMMARY__NET_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        16 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_winback_dtls') }} t0
    where (nullif(nullif(trim(t0.bjazpolicyno), ''), '')) is not null

    union all

    -- branch 19: BJAZ_MOT_WS_POL_DTLS
    select
        null, null,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.agree_quote_to_pol as POLICY_HEADER__CONVERSION_FROM_QUOTE_INDICATOR,
        null, null, null, null, null,
        t0.no_of_members as POLICY_HEADER__NUMBER_OF_LIVES_COVERED,
        t0.business_source as POLICY_HEADER__POLICY_CHANNEL_TYPE,
        null,
        t0.contract_id as POLICY_HEADER__POLICY_REFERENCE_NUMBER,
        null, null, null,
        t0.no_of_days as POLICY_HEADER__POLICY_TERM_DAYS,
        t0.policy_type as POLICY_HEADER__POLICY_TYPE,
        t0.term_end_date as POLICY_HEADER__RISK_EXPIRY_DATE,
        t0.term_start_date as POLICY_HEADER__RISK_INCEPTION_DATE,
        t0.term_start_time as POLICY_HEADER__RISK_START_TIME,
        null, null, null, null,
        t0.gross_premium as POLICY_PREMIUM_SUMMARY__GROSS_PREMIUM,
        null, null, null, null, null,
        t0.ncb_amt as POLICY_PREMIUM_SUMMARY__NO_CLAIM_BONUS_AMOUNT,
        null, null, null, null, null,
        coalesce(t0.adj_edu_cess_tax, t0.edu_cess_tax, t0.ncc_amt, t0.service_tax_amt) as POLICY_TAX_HEAD__TAX_AMOUNT,
        null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        17 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 20: BJAZ_VAHAN_AUTO_ENDT_LOG
    select
        null, null,
        nullif(nullif(trim(t0.policy_no), ''), '') as POLICY_BK,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.reg_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.channel as POLICY_HEADER__POLICY_CHANNEL_TYPE,
        null, null, null, null, null, null, null, null,
        t0.term_start_date as POLICY_HEADER__RISK_INCEPTION_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.vehicle_id as RISK_OBJECT_CORE__RISK_OBJECT_REFERENCE_NUMBER,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        18 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_vahan_auto_endt_log') }} t0
    where (coalesce(nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.reg_no), '')), ''), nullif(nullif(trim(t0.policy_no), ''), ''))) is not null

    union all

    -- branch 21: WRN_BJAZ_MOT_RENEWAL
    select
        null, null,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.location_code as POLICY_HEADER__ISSUING_ORG_UNIT_CODE,
        null, null, null,
        t0.contract_id as POLICY_HEADER__POLICY_NUMBER,
        null, null, null, null, null, null,
        t0.term_end_date as POLICY_HEADER__RISK_EXPIRY_DATE,
        null, null, null, null, null, null,
        t0.gross_premium as POLICY_PREMIUM_SUMMARY__GROSS_PREMIUM,
        null, null, null, null,
        t0.net_premium as POLICY_PREMIUM_SUMMARY__NET_PREMIUM,
        null, null, null,
        t0.uw_stds_prem as POLICY_PREMIUM_SUMMARY__TECHNICAL_PREMIUM,
        null, null,
        coalesce(t0.cess1_amt, t0.cess2_amt, t0.cess3_amt, t0.cess_total, t0.edu_cess_tax, t0.kkc_amt, t0.new_service_tax, t0.service_tax, t0.swb_amt) as POLICY_TAX_HEAD__TAX_AMOUNT,
        null,
        t0.tax_code as POLICY_TAX_HEAD__TAX_HEAD_CODE,
        t0.tax_desc as POLICY_TAX_HEAD__TAX_HEAD_NAME,
        null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        19 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__wrn_bjaz_mot_renewal') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

)

select
    DISTRIBUTION_CHANNEL_BK,
    FINANCIAL_TRANSACTION_BK,
    POLICY_BK,
    RISK_OBJECT_BK,
    __LNK_FINTXN_POLICY,
    __LNK_POLICY_CHANNEL,
    first_value(AUG_POLICY_EXTENDED_WARRANTY__CHILD_PRODUCT_CODE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_EXTENDED_WARRANTY__CHILD_PRODUCT_CODE,
    first_value(AUG_POLICY_EXTENDED_WARRANTY__WARRANTY_SUB_TYPE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_EXTENDED_WARRANTY__WARRANTY_SUB_TYPE,
    first_value(AUG_POLICY_EXTENDED_WARRANTY__WARRANTY_TYPE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_EXTENDED_WARRANTY__WARRANTY_TYPE,
    first_value(AUG_POLICY_PREMIUM_SUMMARY__BOOKED_PREMIUM_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_SUMMARY__BOOKED_PREMIUM_AMOUNT,
    first_value(AUG_POLICY_PREMIUM_SUMMARY__DEVIATED_GROSS_PREMIUM) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_SUMMARY__DEVIATED_GROSS_PREMIUM,
    first_value(AUG_POLICY_PREMIUM_SUMMARY__FULL_TERM_PREMIUM) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_SUMMARY__FULL_TERM_PREMIUM,
    first_value(AUG_POLICY_PREMIUM_SUMMARY__MINIMUM_GROSS_PREMIUM) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_SUMMARY__MINIMUM_GROSS_PREMIUM,
    first_value(AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_BREAKUP_TEXT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_BREAKUP_TEXT,
    first_value(AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_CALCULATED_BY) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_CALCULATED_BY,
    first_value(AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_PAYMENT_MODE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_PAYMENT_MODE,
    first_value(POLICY_HEADER__CONVERSION_FROM_QUOTE_INDICATOR) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__CONVERSION_FROM_QUOTE_INDICATOR,
    first_value(POLICY_HEADER__COVER_NOTE_REFERENCE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__COVER_NOTE_REFERENCE,
    first_value(POLICY_HEADER__ISSUE_DATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__ISSUE_DATE,
    first_value(POLICY_HEADER__ISSUING_CHANNEL_REFERENCE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__ISSUING_CHANNEL_REFERENCE,
    first_value(POLICY_HEADER__ISSUING_ORG_UNIT_CODE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__ISSUING_ORG_UNIT_CODE,
    first_value(POLICY_HEADER__MASTER_POLICY_REFERENCE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__MASTER_POLICY_REFERENCE,
    first_value(POLICY_HEADER__NUMBER_OF_LIVES_COVERED) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__NUMBER_OF_LIVES_COVERED,
    first_value(POLICY_HEADER__POLICY_CHANNEL_TYPE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__POLICY_CHANNEL_TYPE,
    first_value(POLICY_HEADER__POLICY_NUMBER) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__POLICY_NUMBER,
    first_value(POLICY_HEADER__POLICY_REFERENCE_NUMBER) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__POLICY_REFERENCE_NUMBER,
    first_value(POLICY_HEADER__POLICY_REMARKS) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__POLICY_REMARKS,
    first_value(POLICY_HEADER__POLICY_STATUS) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__POLICY_STATUS,
    first_value(POLICY_HEADER__POLICY_TERM) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__POLICY_TERM,
    first_value(POLICY_HEADER__POLICY_TERM_DAYS) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__POLICY_TERM_DAYS,
    first_value(POLICY_HEADER__POLICY_TYPE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__POLICY_TYPE,
    first_value(POLICY_HEADER__RISK_EXPIRY_DATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__RISK_EXPIRY_DATE,
    first_value(POLICY_HEADER__RISK_INCEPTION_DATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__RISK_INCEPTION_DATE,
    first_value(POLICY_HEADER__RISK_START_TIME) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__RISK_START_TIME,
    first_value(POLICY_HEADER__SERVICING_ORG_UNIT_CODE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__SERVICING_ORG_UNIT_CODE,
    first_value(POLICY_HEADER__SHORT_PERIOD_INDICATOR) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__SHORT_PERIOD_INDICATOR,
    first_value(POLICY_PREMIUM_SUMMARY__CGST_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PREMIUM_SUMMARY__CGST_AMOUNT,
    first_value(POLICY_PREMIUM_SUMMARY__DISCOUNT_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PREMIUM_SUMMARY__DISCOUNT_AMOUNT,
    first_value(POLICY_PREMIUM_SUMMARY__GROSS_PREMIUM) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PREMIUM_SUMMARY__GROSS_PREMIUM,
    first_value(POLICY_PREMIUM_SUMMARY__GST_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PREMIUM_SUMMARY__GST_AMOUNT,
    first_value(POLICY_PREMIUM_SUMMARY__IGST_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PREMIUM_SUMMARY__IGST_AMOUNT,
    first_value(POLICY_PREMIUM_SUMMARY__LOADING_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PREMIUM_SUMMARY__LOADING_AMOUNT,
    first_value(POLICY_PREMIUM_SUMMARY__LONG_TERM_DISCOUNT_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PREMIUM_SUMMARY__LONG_TERM_DISCOUNT_AMOUNT,
    first_value(POLICY_PREMIUM_SUMMARY__NET_PREMIUM) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PREMIUM_SUMMARY__NET_PREMIUM,
    first_value(POLICY_PREMIUM_SUMMARY__NO_CLAIM_BONUS_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PREMIUM_SUMMARY__NO_CLAIM_BONUS_AMOUNT,
    first_value(POLICY_PREMIUM_SUMMARY__SGST_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PREMIUM_SUMMARY__SGST_AMOUNT,
    first_value(POLICY_PREMIUM_SUMMARY__STAMP_DUTY_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PREMIUM_SUMMARY__STAMP_DUTY_AMOUNT,
    first_value(POLICY_PREMIUM_SUMMARY__TECHNICAL_PREMIUM) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PREMIUM_SUMMARY__TECHNICAL_PREMIUM,
    first_value(POLICY_PREMIUM_SUMMARY__TERRORISM_PREMIUM) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PREMIUM_SUMMARY__TERRORISM_PREMIUM,
    POLICY_TAX_HEAD__TAX_HEAD_CODE_CK,
    first_value(POLICY_TAX_HEAD__TAX_AMOUNT) ignore nulls over (partition by POLICY_BK, POLICY_TAX_HEAD__TAX_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_TAX_HEAD__TAX_AMOUNT,
    first_value(POLICY_TAX_HEAD__TAX_COMPONENT) ignore nulls over (partition by POLICY_BK, POLICY_TAX_HEAD__TAX_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_TAX_HEAD__TAX_COMPONENT,
    first_value(POLICY_TAX_HEAD__TAX_HEAD_CODE) ignore nulls over (partition by POLICY_BK, POLICY_TAX_HEAD__TAX_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_TAX_HEAD__TAX_HEAD_CODE,
    first_value(POLICY_TAX_HEAD__TAX_HEAD_NAME) ignore nulls over (partition by POLICY_BK, POLICY_TAX_HEAD__TAX_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_TAX_HEAD__TAX_HEAD_NAME,
    first_value(RISK_OBJECT_CORE__ACQUISITION_DATE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_OBJECT_CORE__ACQUISITION_DATE,
    first_value(RISK_OBJECT_CORE__RISK_OBJECT_DESCRIPTION) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_OBJECT_CORE__RISK_OBJECT_DESCRIPTION,
    first_value(RISK_OBJECT_CORE__RISK_OBJECT_NAME) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_OBJECT_CORE__RISK_OBJECT_NAME,
    first_value(RISK_OBJECT_CORE__RISK_OBJECT_REFERENCE_NUMBER) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_OBJECT_CORE__RISK_OBJECT_REFERENCE_NUMBER,
    -- the row's own source time: LOAD_DATETIME for hubs, links and single-active satellites
    m.INC_JOB_UPDATED_AT,
    -- multi-active satellites on POLICY_BK (SAT_POLICY_TAX_HEAD):
    -- one load time per POLICY_BK, the newest INC_JOB_UPDATED_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when coalesce(m.POLICY_TAX_HEAD__TAX_AMOUNT, m.POLICY_TAX_HEAD__TAX_COMPONENT, m.POLICY_TAX_HEAD__TAX_HEAD_CODE, m.POLICY_TAX_HEAD__TAX_HEAD_NAME) is not null
             then m.INC_JOB_UPDATED_AT end)
        over (partition by m.POLICY_BK) as POLICY_BK__MA_LOAD_DATETIME
from merged m
