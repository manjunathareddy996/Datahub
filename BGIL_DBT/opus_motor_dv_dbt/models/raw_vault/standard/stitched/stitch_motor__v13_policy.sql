-- CENTRAL VIEW v13_policy -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   BGIL_MOTOR_WEBSERVICE_INFO_EQM
--   BJAZ_AGENCY_MOT_WAR_DTLS
--   BJAZ_IIB_SUDARS_POLICY_DTL_HST_QM
--   BJAZ_MOTOR_WEBSERVICE_INFO
--   BJAZ_MOT_COVER_EXTN
--   BJAZ_MOT_OD_TP_DTLS
--   BJAZ_MOT_PAYC_DTLS
--   BJAZ_MOT_RENEWAL_EXTN
--   BJAZ_MOT_SPECIAL_POLICY
--   BJAZ_MOT_TRADE_DTLS_EXTN
--   BJAZ_MOT_WAR_CHILD_DTLS
--   BJAZ_MOT_WAR_PLANS_EXTN
--   BJAZ_MOT_WINBACK_DTLS
--   BJAZ_MOT_WS_POL_DTLS
--   BJAZ_PAYMOTORTHEFT_DTLS
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_CASE_HEADER
--   SAT_AUG_POLICY_DISCOUNT_LOADING_APPLIED
--   SAT_AUG_POLICY_HEADER
-- Links whose legs come from one source row on this view (rule 6):
-- OVER the table limit by rule 3: one satellite on this view needs every feeding table.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: BGIL_MOTOR_WEBSERVICE_INFO_EQM
    select
        cast(null as varchar) as CASE_BK,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        cast(null as varchar) as AUG_CASE_HEADER__CASE_WORKFLOW_STAGE,
        cast(null as varchar) as AUG_CASE_HEADER__INTERACTION_SCRIPT_CODE,
        cast(null as varchar) as AUG_CASE_HEADER__OWNING_STATE_NAME,
        cast(null as varchar) as AUG_POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        t0.od_4grid as AUG_POLICY_DISCOUNT_LOADING_APPLIED__BASIS_AMOUNT,
        cast(null as varchar) as AUG_POLICY_DISCOUNT_LOADING_APPLIED__ITEM_APPLIED_INDICATOR,
        t0.mvnd_factor as AUG_POLICY_DISCOUNT_LOADING_APPLIED__RATING_FACTOR_VALUE,
        cast(null as varchar) as AUG_POLICY_HEADER__ADDITIONAL_REMARKS,
        cast(null as varchar) as AUG_POLICY_HEADER__BUSINESS_VERTICAL_SEGMENT,
        cast(null as varchar) as AUG_POLICY_HEADER__COVER_NOTE_CONVERSION_AGREED_INDICATOR,
        cast(null as varchar) as AUG_POLICY_HEADER__ELECTRONIC_REQUEST_NUMBER,
        cast(null as varchar) as AUG_POLICY_HEADER__FINANCIAL_YEAR,
        cast(null as varchar) as AUG_POLICY_HEADER__FLOAT_FUNDING_TYPE,
        cast(null as varchar) as AUG_POLICY_HEADER__INSURED_NAME,
        cast(null as varchar) as AUG_POLICY_HEADER__INSURED_VEHICLE_INTERNAL_REFERENCE,
        cast(null as varchar) as AUG_POLICY_HEADER__INTERNAL_TRACKING_NUMBER,
        cast(null as varchar) as AUG_POLICY_HEADER__LATEST_PRIOR_POLICY_INDICATOR,
        cast(null as varchar) as AUG_POLICY_HEADER__LIABILITY_COVER_BASIS,
        cast(null as varchar) as AUG_POLICY_HEADER__PLAN_PARTNER_IDENTIFIER,
        cast(null as varchar) as AUG_POLICY_HEADER__POLICY_TRANSACTION_TYPE,
        cast(null as varchar) as AUG_POLICY_HEADER__PRODUCT_PACKAGE_IDENTIFIER,
        t0.promotion_no as AUG_POLICY_HEADER__PROMOTION_REFERENCE,
        cast(null as varchar) as AUG_POLICY_HEADER__RISK_OBJECT_INTERNAL_REFERENCE,
        cast(null as varchar) as AUG_POLICY_HEADER__SCRUTINY_REFERENCE,
        cast(null as varchar) as AUG_POLICY_HEADER__TRADE_CERTIFICATE_COUNT,
        cast(null as varchar) as AUG_POLICY_HEADER__TRADE_CERTIFICATE_INDICATOR,
        cast(null as varchar) as AUG_POLICY_HEADER__UNDERLYING_BASIC_POLICY_REFERENCE,
        cast(null as varchar) as AUG_POLICY_HEADER__UNDERWRITING_YEAR,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bgil_motor_webservice_info_eqm') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 1: BJAZ_AGENCY_MOT_WAR_DTLS
    select
        null,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.scrutiny_no as AUG_POLICY_HEADER__SCRUTINY_REFERENCE,
        null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_agency_mot_war_dtls') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 2: BJAZ_IIB_SUDARS_POLICY_DTL_HST_QM
    select
        null,
        nullif(nullif('IIB:' || nullif(trim(t0.policy_no), ''), 'IIB:'), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.finanacial_year as AUG_POLICY_HEADER__FINANCIAL_YEAR,
        null, null, null, null,
        t0.latest_policy as AUG_POLICY_HEADER__LATEST_PRIOR_POLICY_INDICATOR,
        null, null,
        t0.type_of_transaction as AUG_POLICY_HEADER__POLICY_TRANSACTION_TYPE,
        null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_iib_sudars_policy_dtl_hst_qm') }} t0
    where (nullif(nullif('IIB:' || nullif(trim(t0.policy_no), ''), 'IIB:'), '')) is not null

    union all

    -- branch 3: BJAZ_MOTOR_WEBSERVICE_INFO
    select
        null,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null,
        t0.od_4grid as AUG_POLICY_DISCOUNT_LOADING_APPLIED__BASIS_AMOUNT,
        null,
        t0.mvnd_factor as AUG_POLICY_DISCOUNT_LOADING_APPLIED__RATING_FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.promotion_no as AUG_POLICY_HEADER__PROMOTION_REFERENCE,
        null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_webservice_info') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 4: BJAZ_MOT_COVER_EXTN
    select
        null,
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null, null,
        t0.enable_disc as AUG_POLICY_DISCOUNT_LOADING_APPLIED__ITEM_APPLIED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.object_id as AUG_POLICY_HEADER__RISK_OBJECT_INTERNAL_REFERENCE,
        null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_cover_extn') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 5: BJAZ_MOT_OD_TP_DTLS
    select
        null,
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        t0.uw_year as AUG_POLICY_HEADER__UNDERWRITING_YEAR,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_od_tp_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 6: BJAZ_MOT_PAYC_DTLS
    select
        null,
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.vehicle_id as AUG_POLICY_HEADER__INSURED_VEHICLE_INTERNAL_REFERENCE,
        null, null, null, null, null, null, null,
        t0.object_id as AUG_POLICY_HEADER__RISK_OBJECT_INTERNAL_REFERENCE,
        null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_payc_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 7: BJAZ_MOT_RENEWAL_EXTN
    select
        null,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null,
        t0.vertical_segment as AUG_POLICY_HEADER__BUSINESS_VERTICAL_SEGMENT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_extn') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 8: BJAZ_MOT_SPECIAL_POLICY
    select
        null,
        nullif(nullif(trim(t0.mot_policy_ref), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        t0.basic_mot_policy as AUG_POLICY_HEADER__UNDERLYING_BASIC_POLICY_REFERENCE,
        null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_special_policy') }} t0
    where (nullif(nullif(trim(t0.mot_policy_ref), ''), '')) is not null

    union all

    -- branch 9: BJAZ_MOT_TRADE_DTLS_EXTN
    select
        null,
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.liability as AUG_POLICY_HEADER__LIABILITY_COVER_BASIS,
        null, null, null, null,
        t0.object_id as AUG_POLICY_HEADER__RISK_OBJECT_INTERNAL_REFERENCE,
        null,
        t0.tradecerti_count as AUG_POLICY_HEADER__TRADE_CERTIFICATE_COUNT,
        t0.tradecerti_flag as AUG_POLICY_HEADER__TRADE_CERTIFICATE_INDICATOR,
        null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_trade_dtls_extn') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 10: BJAZ_MOT_WAR_CHILD_DTLS
    select
        null,
        nullif(nullif(trim(t0.motor_policy_no), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null,
        t0.ereqno as AUG_POLICY_HEADER__ELECTRONIC_REQUEST_NUMBER,
        null,
        t0.float_type as AUG_POLICY_HEADER__FLOAT_FUNDING_TYPE,
        null, null, null, null, null,
        t0.ppid as AUG_POLICY_HEADER__PLAN_PARTNER_IDENTIFIER,
        null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        10 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_war_child_dtls') }} t0
    where (nullif(nullif(trim(t0.motor_policy_no), ''), '')) is not null

    union all

    -- branch 11: BJAZ_MOT_WAR_PLANS_EXTN
    select
        null,
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.object_id as AUG_POLICY_HEADER__RISK_OBJECT_INTERNAL_REFERENCE,
        null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        11 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_war_plans_extn') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 12: BJAZ_MOT_WINBACK_DTLS
    select
        null,
        nullif(nullif(trim(t0.bjazpolicyno), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.package_id as AUG_POLICY_HEADER__PRODUCT_PACKAGE_IDENTIFIER,
        null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_winback_dtls') }} t0
    where (nullif(nullif(trim(t0.bjazpolicyno), ''), '')) is not null

    union all

    -- branch 13: BJAZ_MOT_WS_POL_DTLS
    select
        nullif(nullif(trim(to_char(t0.call_id)), ''), '') as CASE_BK,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null,
        t0.message_code as AUG_CASE_HEADER__INTERACTION_SCRIPT_CODE,
        null, null, null, null, null,
        t0.comments as AUG_POLICY_HEADER__ADDITIONAL_REMARKS,
        null,
        t0.agree_cvt_to_pol as AUG_POLICY_HEADER__COVER_NOTE_CONVERSION_AGREED_INDICATOR,
        null, null, null, null, null,
        t0.reference_id as AUG_POLICY_HEADER__INTERNAL_TRACKING_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        13 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (coalesce(nullif(nullif(trim(t0.policy_ref), ''), ''), nullif(nullif(trim(to_char(t0.call_id)), ''), ''))) is not null

    union all

    -- branch 14: BJAZ_PAYMOTORTHEFT_DTLS
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        t0.stage as AUG_CASE_HEADER__CASE_WORKFLOW_STAGE,
        null,
        t0.state_owner as AUG_CASE_HEADER__OWNING_STATE_NAME,
        null, null, null, null, null, null, null, null, null, null,
        t0.insured_name as AUG_POLICY_HEADER__INSURED_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        14 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_paymotortheft_dtls') }} t0
    where (coalesce(nullif(nullif(trim(t0.case_id), ''), ''), nullif(nullif(trim(t0.policy_ref), ''), ''))) is not null

)

select
    CASE_BK,
    POLICY_BK,
    first_value(AUG_CASE_HEADER__CASE_WORKFLOW_STAGE) ignore nulls over (partition by CASE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CASE_HEADER__CASE_WORKFLOW_STAGE,
    first_value(AUG_CASE_HEADER__INTERACTION_SCRIPT_CODE) ignore nulls over (partition by CASE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CASE_HEADER__INTERACTION_SCRIPT_CODE,
    first_value(AUG_CASE_HEADER__OWNING_STATE_NAME) ignore nulls over (partition by CASE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CASE_HEADER__OWNING_STATE_NAME,
    AUG_POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
    first_value(AUG_POLICY_DISCOUNT_LOADING_APPLIED__BASIS_AMOUNT) ignore nulls over (partition by POLICY_BK, AUG_POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_DISCOUNT_LOADING_APPLIED__BASIS_AMOUNT,
    first_value(AUG_POLICY_DISCOUNT_LOADING_APPLIED__ITEM_APPLIED_INDICATOR) ignore nulls over (partition by POLICY_BK, AUG_POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_DISCOUNT_LOADING_APPLIED__ITEM_APPLIED_INDICATOR,
    first_value(AUG_POLICY_DISCOUNT_LOADING_APPLIED__RATING_FACTOR_VALUE) ignore nulls over (partition by POLICY_BK, AUG_POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_DISCOUNT_LOADING_APPLIED__RATING_FACTOR_VALUE,
    first_value(AUG_POLICY_HEADER__ADDITIONAL_REMARKS) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__ADDITIONAL_REMARKS,
    first_value(AUG_POLICY_HEADER__BUSINESS_VERTICAL_SEGMENT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__BUSINESS_VERTICAL_SEGMENT,
    first_value(AUG_POLICY_HEADER__COVER_NOTE_CONVERSION_AGREED_INDICATOR) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__COVER_NOTE_CONVERSION_AGREED_INDICATOR,
    first_value(AUG_POLICY_HEADER__ELECTRONIC_REQUEST_NUMBER) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__ELECTRONIC_REQUEST_NUMBER,
    first_value(AUG_POLICY_HEADER__FINANCIAL_YEAR) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__FINANCIAL_YEAR,
    first_value(AUG_POLICY_HEADER__FLOAT_FUNDING_TYPE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__FLOAT_FUNDING_TYPE,
    first_value(AUG_POLICY_HEADER__INSURED_NAME) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__INSURED_NAME,
    first_value(AUG_POLICY_HEADER__INSURED_VEHICLE_INTERNAL_REFERENCE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__INSURED_VEHICLE_INTERNAL_REFERENCE,
    first_value(AUG_POLICY_HEADER__INTERNAL_TRACKING_NUMBER) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__INTERNAL_TRACKING_NUMBER,
    first_value(AUG_POLICY_HEADER__LATEST_PRIOR_POLICY_INDICATOR) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__LATEST_PRIOR_POLICY_INDICATOR,
    first_value(AUG_POLICY_HEADER__LIABILITY_COVER_BASIS) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__LIABILITY_COVER_BASIS,
    first_value(AUG_POLICY_HEADER__PLAN_PARTNER_IDENTIFIER) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__PLAN_PARTNER_IDENTIFIER,
    first_value(AUG_POLICY_HEADER__POLICY_TRANSACTION_TYPE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__POLICY_TRANSACTION_TYPE,
    first_value(AUG_POLICY_HEADER__PRODUCT_PACKAGE_IDENTIFIER) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__PRODUCT_PACKAGE_IDENTIFIER,
    first_value(AUG_POLICY_HEADER__PROMOTION_REFERENCE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__PROMOTION_REFERENCE,
    first_value(AUG_POLICY_HEADER__RISK_OBJECT_INTERNAL_REFERENCE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__RISK_OBJECT_INTERNAL_REFERENCE,
    first_value(AUG_POLICY_HEADER__SCRUTINY_REFERENCE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__SCRUTINY_REFERENCE,
    first_value(AUG_POLICY_HEADER__TRADE_CERTIFICATE_COUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__TRADE_CERTIFICATE_COUNT,
    first_value(AUG_POLICY_HEADER__TRADE_CERTIFICATE_INDICATOR) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__TRADE_CERTIFICATE_INDICATOR,
    first_value(AUG_POLICY_HEADER__UNDERLYING_BASIC_POLICY_REFERENCE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__UNDERLYING_BASIC_POLICY_REFERENCE,
    first_value(AUG_POLICY_HEADER__UNDERWRITING_YEAR) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__UNDERWRITING_YEAR,
    -- the row's own source time: LOAD_DATETIME for hubs, links and single-active satellites
    m.INC_JOB_UPDATED_AT,
    -- SAT_AUG_POLICY_DISCOUNT_LOADING_APPLIED (ma_sat): one load time per POLICY_BK, so all its child rows share it
    max(case when coalesce(m.AUG_POLICY_DISCOUNT_LOADING_APPLIED__BASIS_AMOUNT, m.AUG_POLICY_DISCOUNT_LOADING_APPLIED__ITEM_APPLIED_INDICATOR, m.AUG_POLICY_DISCOUNT_LOADING_APPLIED__RATING_FACTOR_VALUE) is not null
             then m.INC_JOB_UPDATED_AT end)
        over (partition by m.POLICY_BK) as AUG_POLICY_DISCOUNT_LOADING_APPLIED__LOAD_DATETIME
from merged m
