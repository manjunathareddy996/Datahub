-- CENTRAL VIEW v18_policy -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   BGIL_MOTOR_WEBSERVICE_INFO_EQM
--   BGIL_MOTOR_WS_PLAN_DETAILS_EQM
--   BJAZ_CVTP_WS_DATA
--   BJAZ_MOTOR_WEBSERVICE_INFO
--   BJAZ_MOTOR_WS_PLAN_DETAILS
--   BJAZ_MOT_ONLINE_POL_DTLS
--   BJAZ_MOT_RENEWAL
--   BJAZ_MOT_RENEWAL_HIST
--   BJAZ_MOT_STP_PREM_SUMM_EXTN
--   BJAZ_MOT_WINBACK_DTLS
--   BJAZ_MOT_WS_POL_DTLS
--   WRN_BJAZ_MOT_RENEWAL
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_FIN_RECEIPT
--   SAT_POLICY_DISCOUNT_LOADING_APPLIED
--   SAT_POLICY_INTERMEDIARY_SPLIT
--   SAT_POLICY_TP_PRIOR_PERIOD
-- Links whose legs come from one source row on this view (rule 6):
-- OVER the table limit by rule 3: one satellite on this view needs every feeding table.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: BGIL_MOTOR_WEBSERVICE_INFO_EQM
    select
        nullif(nullif(trim(to_char(t0.ptransaction_id)), ''), '') as FINANCIAL_TRANSACTION_BK,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        cast(null as varchar) as FIN_RECEIPT__AMOUNT_RECEIVED,
        cast(null as varchar) as FIN_RECEIPT__AUTHORISATION_CODE,
        cast(null as varchar) as FIN_RECEIPT__BANK_REFERENCE,
        cast(null as varchar) as FIN_RECEIPT__INSTRUMENT_TYPE,
        cast(null as varchar) as FIN_RECEIPT__MERCHANT_REFERENCE,
        t0.trace_no as FIN_RECEIPT__PAYMENT_GATEWAY_REFERENCE,
        cast(null as varchar) as FIN_RECEIPT__REALISATION_DATE,
        cast(null as varchar) as FIN_RECEIPT__REALISATION_STATUS,
        cast(null as varchar) as FIN_RECEIPT__RECEIPT_DATE,
        t0.receipt_no as FIN_RECEIPT__RECEIPT_NUMBER,
        cast(null as varchar) as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        coalesce(t0.grid_cd, t0.grid_load, t0.grid_od, t0.ncb_pack_disc, t0.uw_load_amt) as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        cast(null as varchar) as POLICY_DISCOUNT_LOADING_APPLIED__BASIS,
        cast(null as varchar) as POLICY_DISCOUNT_LOADING_APPLIED__EXTRA_DISCOUNT_OPTED_INDICATOR,
        cast(null as varchar) as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE,
        cast(null as varchar) as POLICY_DISCOUNT_LOADING_APPLIED__JUSTIFICATION,
        coalesce(t0.grid_cd_rate, t0.grid_load_rate, t0.mv_addon_rate, t0.mv_od_rate, t0.mvnd_oth_liability_rate, t0.uw_load_rate) as POLICY_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED,
        t0.imd_code as POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE_CK,
        cast(null as varchar) as POLICY_INTERMEDIARY_SPLIT__BRANCH_REFERENCE,
        cast(null as varchar) as POLICY_INTERMEDIARY_SPLIT__COMMISSION_AMOUNT,
        t0.comm_disc_rate as POLICY_INTERMEDIARY_SPLIT__COMMISSION_RATE,
        cast(null as varchar) as POLICY_INTERMEDIARY_SPLIT__IMD_CODE,
        cast(null as varchar) as POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE,
        cast(null as varchar) as POLICY_INTERMEDIARY_SPLIT__SUB_IMD_CODE,
        cast(null as varchar) as POLICY_TP_PRIOR_PERIOD__PRIOR_POLICY_SEQUENCE_CK,
        cast(null as varchar) as POLICY_TP_PRIOR_PERIOD__PRIOR_INSURER_CODE,
        cast(null as varchar) as POLICY_TP_PRIOR_PERIOD__PRIOR_INSURER_NAME,
        cast(null as varchar) as POLICY_TP_PRIOR_PERIOD__PRIOR_POLICY_END_DATE,
        cast(null as varchar) as POLICY_TP_PRIOR_PERIOD__PRIOR_POLICY_NUMBER,
        cast(null as varchar) as POLICY_TP_PRIOR_PERIOD__PRIOR_POLICY_START_DATE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bgil_motor_webservice_info_eqm') }} t0
    where (coalesce(nullif(nullif(trim(t0.policy_ref), ''), ''), nullif(nullif(trim(to_char(t0.ptransaction_id)), ''), ''))) is not null

    union all

    -- branch 1: BGIL_MOTOR_WS_PLAN_DETAILS_EQM
    select
        null,
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.add_loading as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        t0.add_loading_on as POLICY_DISCOUNT_LOADING_APPLIED__BASIS,
        null, null, null,
        t0.sp_disc_rate as POLICY_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED,
        null, null, null, null, null, null, null, null,
        t0.prv_ins_company as POLICY_TP_PRIOR_PERIOD__PRIOR_INSURER_CODE,
        null,
        t0.prv_expiry_date as POLICY_TP_PRIOR_PERIOD__PRIOR_POLICY_END_DATE,
        t0.prv_policy_ref as POLICY_TP_PRIOR_PERIOD__PRIOR_POLICY_NUMBER,
        null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bgil_motor_ws_plan_details_eqm') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 2: BJAZ_CVTP_WS_DATA
    select
        nullif(nullif(trim(to_char(t0.paymentid)), ''), '') as FINANCIAL_TRANSACTION_BK,
        nullif(nullif(trim(t0.bjazpolicyno), ''), '') as POLICY_BK,
        t0.chequeamount as FIN_RECEIPT__AMOUNT_RECEIVED,
        null, null, null, null, null, null, null, null,
        t0.bjaz_receipt as FIN_RECEIPT__RECEIPT_NUMBER,
        null,
        coalesce(t0.aadiscamount, t0.antitheftdiscamount, t0.voluntarydisc) as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        null, null, null, null,
        t0.oddiscper as POLICY_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED,
        null, null, null, null, null, null, null, null,
        t0.tpprevinsurcompanycode as POLICY_TP_PRIOR_PERIOD__PRIOR_INSURER_CODE,
        t0.tpprevinsurcompanyname as POLICY_TP_PRIOR_PERIOD__PRIOR_INSURER_NAME,
        t0.tpprevtppolicyexpirydate as POLICY_TP_PRIOR_PERIOD__PRIOR_POLICY_END_DATE,
        t0.tpprevpolicyno as POLICY_TP_PRIOR_PERIOD__PRIOR_POLICY_NUMBER,
        t0.tpprevpolicyeffectivedate as POLICY_TP_PRIOR_PERIOD__PRIOR_POLICY_START_DATE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_cvtp_ws_data') }} t0
    where (coalesce(nullif(nullif(trim(t0.bjazpolicyno), ''), ''), nullif(nullif(trim(to_char(t0.paymentid)), ''), ''))) is not null

    union all

    -- branch 3: BJAZ_MOTOR_WEBSERVICE_INFO
    select
        nullif(nullif(trim(to_char(t0.ptransaction_id)), ''), '') as FINANCIAL_TRANSACTION_BK,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null, null,
        t0.trace_no as FIN_RECEIPT__PAYMENT_GATEWAY_REFERENCE,
        null, null, null,
        t0.receipt_no as FIN_RECEIPT__RECEIPT_NUMBER,
        null,
        coalesce(t0.grid_cd, t0.grid_load, t0.grid_od, t0.ncb_pack_disc, t0.uw_load_amt) as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        null, null, null, null,
        coalesce(t0.grid_cd_rate, t0.grid_load_rate, t0.mv_addon_rate, t0.mv_od_rate, t0.mvnd_oth_liability_rate, t0.uw_load_rate) as POLICY_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED,
        t0.imd_code as POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE_CK,
        null, null,
        t0.comm_disc_rate as POLICY_INTERMEDIARY_SPLIT__COMMISSION_RATE,
        null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_webservice_info') }} t0
    where (coalesce(nullif(nullif(trim(t0.policy_ref), ''), ''), nullif(nullif(trim(to_char(t0.ptransaction_id)), ''), ''))) is not null

    union all

    -- branch 4: BJAZ_MOTOR_WS_PLAN_DETAILS
    select
        null,
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.add_loading as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        t0.add_loading_on as POLICY_DISCOUNT_LOADING_APPLIED__BASIS,
        null, null, null,
        t0.sp_disc_rate as POLICY_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED,
        null, null, null, null, null, null, null, null,
        t0.prv_ins_company as POLICY_TP_PRIOR_PERIOD__PRIOR_INSURER_CODE,
        null,
        t0.prv_expiry_date as POLICY_TP_PRIOR_PERIOD__PRIOR_POLICY_END_DATE,
        t0.prv_policy_ref as POLICY_TP_PRIOR_PERIOD__PRIOR_POLICY_NUMBER,
        null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_ws_plan_details') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 5: BJAZ_MOT_ONLINE_POL_DTLS
    select
        nullif(nullif('RECEIPT:' || nullif(trim(t0.receipt_no), ''), 'RECEIPT:'), '') as FINANCIAL_TRANSACTION_BK,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null,
        t0.auth_code as FIN_RECEIPT__AUTHORISATION_CODE,
        null,
        t0.online_pay_mode as FIN_RECEIPT__INSTRUMENT_TYPE,
        t0.merchant_code as FIN_RECEIPT__MERCHANT_REFERENCE,
        t0.trace_number as FIN_RECEIPT__PAYMENT_GATEWAY_REFERENCE,
        t0.payment_res_date_time as FIN_RECEIPT__REALISATION_DATE,
        t0.payment_received_yn as FIN_RECEIPT__REALISATION_STATUS,
        null, null, null,
        coalesce(t0.add_disc_amt, t0.add_load_amt, t0.commercial_disc_amt, t0.terr_surcharge, t0.uw_load_amt) as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        t0.add_loading_on as POLICY_DISCOUNT_LOADING_APPLIED__BASIS,
        t0.avail_disc_by_telling_abt_u as POLICY_DISCOUNT_LOADING_APPLIED__EXTRA_DISCOUNT_OPTED_INDICATOR,
        coalesce(t0.cd_coupon_code, t0.promotion_no) as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE,
        coalesce(t0.add_disc_reason, t0.add_load_reason) as POLICY_DISCOUNT_LOADING_APPLIED__JUSTIFICATION,
        coalesce(t0.add_disc_rate, t0.add_load_rate, t0.cd_coupon_percent, t0.cibil_disc_rate, t0.commercial_disc_rate, t0.lterm_disc_rate, t0.renewal_disc_rate) as POLICY_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (coalesce(nullif(nullif('RECEIPT:' || nullif(trim(t0.receipt_no), ''), 'RECEIPT:'), ''), nullif(nullif(trim(t0.policy_ref), ''), ''))) is not null

    union all

    -- branch 6: BJAZ_MOT_RENEWAL
    select
        null,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null,
        coalesce(t0.add_load_amt, t0.spl_discount) as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        null, null, null,
        t0.add_load_reason as POLICY_DISCOUNT_LOADING_APPLIED__JUSTIFICATION,
        t0.add_load_per as POLICY_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED,
        t0.main_agent_code as POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE_CK,
        t0.comm_rate_branchcd as POLICY_INTERMEDIARY_SPLIT__BRANCH_REFERENCE,
        t0.comm_disc_amt as POLICY_INTERMEDIARY_SPLIT__COMMISSION_AMOUNT,
        t0.comm_disc_rate as POLICY_INTERMEDIARY_SPLIT__COMMISSION_RATE,
        null,
        t0.main_agent_code as POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE,
        null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 7: BJAZ_MOT_RENEWAL_HIST
    select
        null,
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null,
        coalesce(t0.add_load_amt, t0.addon_pkg_disc, t0.comm_disc_amt, t0.comm_disc_amt_1st, t0.spl_discount) as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        null, null, null,
        t0.add_load_reason as POLICY_DISCOUNT_LOADING_APPLIED__JUSTIFICATION,
        coalesce(t0.add_load_per, t0.comm_disc_rate, t0.comm_disc_rate_1st) as POLICY_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_hist') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 8: BJAZ_MOT_STP_PREM_SUMM_EXTN
    select
        null,
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.param_ref as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE,
        null,
        t0.disc_perc as POLICY_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_stp_prem_summ_extn') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 9: BJAZ_MOT_WINBACK_DTLS
    select
        nullif(nullif('RECEIPT:' || nullif(trim(t0.receipt_no), ''), 'RECEIPT:'), '') as FINANCIAL_TRANSACTION_BK,
        nullif(nullif(trim(t0.bjazpolicyno), ''), '') as POLICY_BK,
        t0.trans_amount as FIN_RECEIPT__AMOUNT_RECEIVED,
        t0.auth_code as FIN_RECEIPT__AUTHORISATION_CODE,
        t0.payment_bank_name as FIN_RECEIPT__BANK_REFERENCE,
        null,
        t0.merchant_code as FIN_RECEIPT__MERCHANT_REFERENCE,
        t0.payment_gateway as FIN_RECEIPT__PAYMENT_GATEWAY_REFERENCE,
        null, null,
        t0.payment_date as FIN_RECEIPT__RECEIPT_DATE,
        null, null,
        t0.cd_amount as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        null, null, null, null,
        t0.cd_per as POLICY_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED,
        t0.imd as POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE_CK,
        null, null, null,
        t0.imd as POLICY_INTERMEDIARY_SPLIT__IMD_CODE,
        null,
        t0.subimd as POLICY_INTERMEDIARY_SPLIT__SUB_IMD_CODE,
        null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_winback_dtls') }} t0
    where (coalesce(nullif(nullif('RECEIPT:' || nullif(trim(t0.receipt_no), ''), 'RECEIPT:'), ''), nullif(nullif(trim(t0.bjazpolicyno), ''), ''))) is not null

    union all

    -- branch 10: BJAZ_MOT_WS_POL_DTLS
    select
        nullif(nullif(trim(t0.receipt_no), ''), '') as FINANCIAL_TRANSACTION_BK,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null,
        t0.auth_code as FIN_RECEIPT__AUTHORISATION_CODE,
        null,
        t0.online_pay_mode as FIN_RECEIPT__INSTRUMENT_TYPE,
        t0.merchant_code as FIN_RECEIPT__MERCHANT_REFERENCE,
        t0.payment_gateway as FIN_RECEIPT__PAYMENT_GATEWAY_REFERENCE,
        null, null, null, null, null,
        coalesce(t0.add_disc_amt, t0.add_load_amt, t0.commercial_disc_amt, t0.renewal_disc_amt, t0.terr_surcharge, t0.uw_load_amt) as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        t0.add_loading_on as POLICY_DISCOUNT_LOADING_APPLIED__BASIS,
        null, null,
        coalesce(t0.add_disc_reason, t0.add_load_reason) as POLICY_DISCOUNT_LOADING_APPLIED__JUSTIFICATION,
        coalesce(t0.add_disc_rate, t0.add_load_rate, t0.commercial_disc_rate, t0.renewal_disc_rate) as POLICY_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        10 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (coalesce(nullif(nullif(trim(t0.policy_ref), ''), ''), nullif(nullif(trim(t0.receipt_no), ''), ''))) is not null

    union all

    -- branch 11: WRN_BJAZ_MOT_RENEWAL
    select
        null,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null,
        coalesce(t0.add_load_amt, t0.spl_discount) as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        null, null, null,
        t0.add_load_reason as POLICY_DISCOUNT_LOADING_APPLIED__JUSTIFICATION,
        t0.add_load_per as POLICY_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED,
        t0.main_agent_code as POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE_CK,
        null,
        t0.comm_disc_amt as POLICY_INTERMEDIARY_SPLIT__COMMISSION_AMOUNT,
        t0.comm_disc_rate as POLICY_INTERMEDIARY_SPLIT__COMMISSION_RATE,
        null,
        t0.main_agent_code as POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE,
        null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        11 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__wrn_bjaz_mot_renewal') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

)

select
    FINANCIAL_TRANSACTION_BK,
    POLICY_BK,
    first_value(FIN_RECEIPT__AMOUNT_RECEIVED) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FIN_RECEIPT__AMOUNT_RECEIVED,
    first_value(FIN_RECEIPT__AUTHORISATION_CODE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FIN_RECEIPT__AUTHORISATION_CODE,
    first_value(FIN_RECEIPT__BANK_REFERENCE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FIN_RECEIPT__BANK_REFERENCE,
    first_value(FIN_RECEIPT__INSTRUMENT_TYPE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FIN_RECEIPT__INSTRUMENT_TYPE,
    first_value(FIN_RECEIPT__MERCHANT_REFERENCE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FIN_RECEIPT__MERCHANT_REFERENCE,
    first_value(FIN_RECEIPT__PAYMENT_GATEWAY_REFERENCE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FIN_RECEIPT__PAYMENT_GATEWAY_REFERENCE,
    first_value(FIN_RECEIPT__REALISATION_DATE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FIN_RECEIPT__REALISATION_DATE,
    first_value(FIN_RECEIPT__REALISATION_STATUS) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FIN_RECEIPT__REALISATION_STATUS,
    first_value(FIN_RECEIPT__RECEIPT_DATE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FIN_RECEIPT__RECEIPT_DATE,
    first_value(FIN_RECEIPT__RECEIPT_NUMBER) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FIN_RECEIPT__RECEIPT_NUMBER,
    POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
    first_value(POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED) ignore nulls over (partition by POLICY_BK, POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
    first_value(POLICY_DISCOUNT_LOADING_APPLIED__BASIS) ignore nulls over (partition by POLICY_BK, POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_DISCOUNT_LOADING_APPLIED__BASIS,
    first_value(POLICY_DISCOUNT_LOADING_APPLIED__EXTRA_DISCOUNT_OPTED_INDICATOR) ignore nulls over (partition by POLICY_BK, POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_DISCOUNT_LOADING_APPLIED__EXTRA_DISCOUNT_OPTED_INDICATOR,
    first_value(POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE) ignore nulls over (partition by POLICY_BK, POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE,
    first_value(POLICY_DISCOUNT_LOADING_APPLIED__JUSTIFICATION) ignore nulls over (partition by POLICY_BK, POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_DISCOUNT_LOADING_APPLIED__JUSTIFICATION,
    first_value(POLICY_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED) ignore nulls over (partition by POLICY_BK, POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED,
    POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE_CK,
    first_value(POLICY_INTERMEDIARY_SPLIT__BRANCH_REFERENCE) ignore nulls over (partition by POLICY_BK, POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_INTERMEDIARY_SPLIT__BRANCH_REFERENCE,
    first_value(POLICY_INTERMEDIARY_SPLIT__COMMISSION_AMOUNT) ignore nulls over (partition by POLICY_BK, POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_INTERMEDIARY_SPLIT__COMMISSION_AMOUNT,
    first_value(POLICY_INTERMEDIARY_SPLIT__COMMISSION_RATE) ignore nulls over (partition by POLICY_BK, POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_INTERMEDIARY_SPLIT__COMMISSION_RATE,
    first_value(POLICY_INTERMEDIARY_SPLIT__IMD_CODE) ignore nulls over (partition by POLICY_BK, POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_INTERMEDIARY_SPLIT__IMD_CODE,
    first_value(POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE) ignore nulls over (partition by POLICY_BK, POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE,
    first_value(POLICY_INTERMEDIARY_SPLIT__SUB_IMD_CODE) ignore nulls over (partition by POLICY_BK, POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_INTERMEDIARY_SPLIT__SUB_IMD_CODE,
    POLICY_TP_PRIOR_PERIOD__PRIOR_POLICY_SEQUENCE_CK,
    first_value(POLICY_TP_PRIOR_PERIOD__PRIOR_INSURER_CODE) ignore nulls over (partition by POLICY_BK, POLICY_TP_PRIOR_PERIOD__PRIOR_POLICY_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_TP_PRIOR_PERIOD__PRIOR_INSURER_CODE,
    first_value(POLICY_TP_PRIOR_PERIOD__PRIOR_INSURER_NAME) ignore nulls over (partition by POLICY_BK, POLICY_TP_PRIOR_PERIOD__PRIOR_POLICY_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_TP_PRIOR_PERIOD__PRIOR_INSURER_NAME,
    first_value(POLICY_TP_PRIOR_PERIOD__PRIOR_POLICY_END_DATE) ignore nulls over (partition by POLICY_BK, POLICY_TP_PRIOR_PERIOD__PRIOR_POLICY_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_TP_PRIOR_PERIOD__PRIOR_POLICY_END_DATE,
    first_value(POLICY_TP_PRIOR_PERIOD__PRIOR_POLICY_NUMBER) ignore nulls over (partition by POLICY_BK, POLICY_TP_PRIOR_PERIOD__PRIOR_POLICY_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_TP_PRIOR_PERIOD__PRIOR_POLICY_NUMBER,
    first_value(POLICY_TP_PRIOR_PERIOD__PRIOR_POLICY_START_DATE) ignore nulls over (partition by POLICY_BK, POLICY_TP_PRIOR_PERIOD__PRIOR_POLICY_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_TP_PRIOR_PERIOD__PRIOR_POLICY_START_DATE,
    -- the row's own source time: LOAD_DATETIME for hubs, links and single-active satellites
    m.INC_JOB_UPDATED_AT,
    -- multi-active satellites on POLICY_BK (SAT_POLICY_DISCOUNT_LOADING_APPLIED, SAT_POLICY_INTERMEDIARY_SPLIT, SAT_POLICY_TP_PRIOR_PERIOD):
    -- one load time per POLICY_BK, the newest INC_JOB_UPDATED_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when coalesce(m.POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED, m.POLICY_DISCOUNT_LOADING_APPLIED__BASIS, m.POLICY_DISCOUNT_LOADING_APPLIED__EXTRA_DISCOUNT_OPTED_INDICATOR, m.POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE, m.POLICY_DISCOUNT_LOADING_APPLIED__JUSTIFICATION, m.POLICY_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED, m.POLICY_INTERMEDIARY_SPLIT__BRANCH_REFERENCE, m.POLICY_INTERMEDIARY_SPLIT__COMMISSION_AMOUNT, m.POLICY_INTERMEDIARY_SPLIT__COMMISSION_RATE, m.POLICY_INTERMEDIARY_SPLIT__IMD_CODE, m.POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE, m.POLICY_INTERMEDIARY_SPLIT__SUB_IMD_CODE, m.POLICY_TP_PRIOR_PERIOD__PRIOR_INSURER_CODE, m.POLICY_TP_PRIOR_PERIOD__PRIOR_INSURER_NAME, m.POLICY_TP_PRIOR_PERIOD__PRIOR_POLICY_END_DATE, m.POLICY_TP_PRIOR_PERIOD__PRIOR_POLICY_NUMBER, m.POLICY_TP_PRIOR_PERIOD__PRIOR_POLICY_START_DATE) is not null
             then m.INC_JOB_UPDATED_AT end)
        over (partition by m.POLICY_BK) as POLICY_BK__MA_LOAD_DATETIME
from merged m
