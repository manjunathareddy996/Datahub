-- CENTRAL VIEW v23_quote -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   BA_QUOTE_MOT_DTLS
--   BGIL_MOTOR_WS_DETARIFF_EQM
--   BJAZ_MOTOR_WS_DETARIFF
--   BJAZ_MOTOR_WS_EXTRA_COVERS
--   BJAZ_MOTOR_WS_PREMIUM_DTLS
--   BJAZ_MOTOR_WS_PREMIUM_SUMMARY
--   BJAZ_MOT_ONLINE_POL_DTLS
--   BJAZ_MOT_ONLINE_POL_DTLS_EXTN
--   BJAZ_MOT_WS_POL_DTLS
--   BJAZ_SCR_MOT_VEH_DTLS
--   BJAZ_WS_MOT_STP_RATE_SUMM
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_QUOTE_HEADER
--   SAT_AUG_QUOTE_PRIOR_INSURANCE
--   SAT_AUG_QUOTE_RATING
--   SAT_QUOTE_HEADER
--   SAT_QUOTE_RATING
-- Links whose legs come from one source row on this view (rule 6):
-- OVER the table limit by rule 3: one satellite on this view needs every feeding table.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: BA_QUOTE_MOT_DTLS
    select
        nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '') as QUOTE_BK,
        t0.geog_extn as AUG_QUOTE_HEADER__QUOTED_GEOGRAPHICAL_SCOPE,
        t0.waiting_period as AUG_QUOTE_HEADER__QUOTED_WAITING_PERIOD,
        t0.rest_prod_pol_reqyn as AUG_QUOTE_HEADER__RESTRICTED_PRODUCT_POLICY_REQUIRED_INDICATOR,
        cast(null as varchar) as AUG_QUOTE_HEADER__SAVED_QUOTE_RETRIEVED_INDICATOR,
        t0.imt_numbers as AUG_QUOTE_HEADER__SELECTED_IMT_CLAUSE_CODE_LIST,
        cast(null as varchar) as AUG_QUOTE_HEADER__STANDALONE_OD_REQUEST_REASON,
        cast(null as varchar) as AUG_QUOTE_PRIOR_INSURANCE__PRIOR_POLICY_COMPONENT_CK,
        cast(null as varchar) as AUG_QUOTE_PRIOR_INSURANCE__PRIOR_INSURER_NAME,
        cast(null as varchar) as AUG_QUOTE_PRIOR_INSURANCE__PRIOR_POLICY_CLAIM_COUNT,
        cast(null as varchar) as AUG_QUOTE_PRIOR_INSURANCE__PRIOR_POLICY_END_DATE,
        cast(null as varchar) as AUG_QUOTE_PRIOR_INSURANCE__PRIOR_POLICY_NUMBER,
        cast(null as varchar) as AUG_QUOTE_PRIOR_INSURANCE__PRIOR_POLICY_START_DATE,
        cast(null as varchar) as AUG_QUOTE_PRIOR_INSURANCE__PRIOR_TENURE_YEARS,
        cast(null as varchar) as AUG_QUOTE_RATING__COLLECTED_PREMIUM_AMOUNT,
        t0.payout_amount as AUG_QUOTE_RATING__COMMISSION_AMOUNT,
        t0.payout_base_amount as AUG_QUOTE_RATING__COMMISSION_BASE_AMOUNT,
        t0.payout_base_nrv as AUG_QUOTE_RATING__COMMISSION_BASE_NET_RATEABLE_VALUE,
        t0.avg_comm_rate as AUG_QUOTE_RATING__COMMISSION_RATE,
        cast(null as varchar) as AUG_QUOTE_RATING__FINAL_PREMIUM,
        cast(null as varchar) as AUG_QUOTE_RATING__LOADING_PERCENTAGE,
        t0.max_comm_rate as AUG_QUOTE_RATING__MAXIMUM_COMMISSION_RATE,
        t0.min_comm_rate as AUG_QUOTE_RATING__MINIMUM_COMMISSION_RATE,
        t0.mpmp_disc_rate as AUG_QUOTE_RATING__MULTI_POLICY_DISCOUNT_PERCENTAGE,
        cast(null as varchar) as AUG_QUOTE_RATING__NET_PREMIUM_COMPONENT,
        cast(null as varchar) as AUG_QUOTE_RATING__NO_CLAIM_BONUS_AMOUNT,
        t0.payout_flag as AUG_QUOTE_RATING__PAYOUT_APPLICABLE_INDICATOR,
        cast(null as varchar) as AUG_QUOTE_RATING__SERVICE_TAX_AMOUNT,
        cast(null as varchar) as AUG_QUOTE_RATING__STAMP_DUTY_AMOUNT,
        t0.theft_excess as AUG_QUOTE_RATING__THEFT_EXCESS_AMOUNT,
        cast(null as varchar) as AUG_QUOTE_RATING__TOTAL_ACT_LIABILITY_PREMIUM,
        cast(null as varchar) as AUG_QUOTE_RATING__TOTAL_IEV_AMOUNT,
        cast(null as varchar) as AUG_QUOTE_RATING__TOTAL_OWN_DAMAGE_PREMIUM,
        cast(null as varchar) as QUOTE_HEADER__CONVERSION_STATUS,
        cast(null as varchar) as QUOTE_HEADER__PROSPECT_REFERENCE,
        cast(null as varchar) as QUOTE_HEADER__QUOTE_CHANNEL,
        cast(null as varchar) as QUOTE_HEADER__QUOTE_DATE,
        cast(null as varchar) as QUOTE_HEADER__QUOTE_REFERENCE_SOURCE,
        cast(null as varchar) as QUOTE_HEADER__QUOTE_SOURCE,
        cast(null as varchar) as QUOTE_HEADER__QUOTE_STATUS,
        t0.ovl_sum_insured as QUOTE_HEADER__REQUESTED_SUM_INSURED,
        t0.mpmp_disc_amt as QUOTE_RATING__DISCOUNT_AMOUNT,
        cast(null as varchar) as QUOTE_RATING__GROSS_PREMIUM,
        cast(null as varchar) as QUOTE_RATING__INDICATIVE_DEDUCTIBLE,
        cast(null as varchar) as QUOTE_RATING__LOADING_AMOUNT,
        cast(null as varchar) as QUOTE_RATING__NET_PREMIUM,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__ba_quote_mot_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '')) is not null

    union all

    -- branch 1: BA_QUOTE_MOT_DTLS | child-key literal(s): AUG_QUOTE_PRIOR_INSURANCE.Prior Policy Component=OD
    select
        nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null,
        'OD' as AUG_QUOTE_PRIOR_INSURANCE__PRIOR_POLICY_COMPONENT_CK,
        null, null, null, null,
        t0.ods_prev_pol_start_date as AUG_QUOTE_PRIOR_INSURANCE__PRIOR_POLICY_START_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__ba_quote_mot_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '')) is not null

    union all

    -- branch 2: BA_QUOTE_MOT_DTLS | child-key literal(s): AUG_QUOTE_PRIOR_INSURANCE.Prior Policy Component=TP
    select
        nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null,
        'TP' as AUG_QUOTE_PRIOR_INSURANCE__PRIOR_POLICY_COMPONENT_CK,
        t0.tp_prev_ins_name as AUG_QUOTE_PRIOR_INSURANCE__PRIOR_INSURER_NAME,
        t0.tp_no_of_claims as AUG_QUOTE_PRIOR_INSURANCE__PRIOR_POLICY_CLAIM_COUNT,
        t0.tp_prev_pol_exp_date as AUG_QUOTE_PRIOR_INSURANCE__PRIOR_POLICY_END_DATE,
        t0.tp_prev_ins_policy_no as AUG_QUOTE_PRIOR_INSURANCE__PRIOR_POLICY_NUMBER,
        t0.tp_prev_pol_start_date as AUG_QUOTE_PRIOR_INSURANCE__PRIOR_POLICY_START_DATE,
        t0.tp_prev_pol_term as AUG_QUOTE_PRIOR_INSURANCE__PRIOR_TENURE_YEARS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__ba_quote_mot_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '')) is not null

    union all

    -- branch 3: BGIL_MOTOR_WS_DETARIFF_EQM
    select
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.uw_load_rate as AUG_QUOTE_RATING__LOADING_PERCENTAGE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.module_from as QUOTE_HEADER__QUOTE_SOURCE,
        null, null, null, null, null,
        t0.uw_load_amt as QUOTE_RATING__LOADING_AMOUNT,
        null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bgil_motor_ws_detariff_eqm') }} t0
    where (nullif(nullif(trim(to_char(t0.transactionid)), ''), '')) is not null

    union all

    -- branch 4: BJAZ_MOTOR_WS_DETARIFF
    select
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.uw_load_rate as AUG_QUOTE_RATING__LOADING_PERCENTAGE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.module_from as QUOTE_HEADER__QUOTE_SOURCE,
        null, null, null, null, null,
        t0.uw_load_amt as QUOTE_RATING__LOADING_AMOUNT,
        null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_ws_detariff') }} t0
    where (nullif(nullif(trim(to_char(t0.transactionid)), ''), '')) is not null

    union all

    -- branch 5: BJAZ_MOTOR_WS_EXTRA_COVERS
    select
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as QUOTE_BK,
        t0.geog_extn as AUG_QUOTE_HEADER__QUOTED_GEOGRAPHICAL_SCOPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.module_from as QUOTE_HEADER__QUOTE_SOURCE,
        null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_ws_extra_covers') }} t0
    where (nullif(nullif(trim(to_char(t0.transactionid)), ''), '')) is not null

    union all

    -- branch 6: BJAZ_MOTOR_WS_PREMIUM_DTLS
    select
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as QUOTE_BK,
        null, null, null, null,
        t0.imt_out as AUG_QUOTE_HEADER__SELECTED_IMT_CLAUSE_CODE_LIST,
        null, null, null, null, null, null, null, null,
        t0.coll_premium as AUG_QUOTE_RATING__COLLECTED_PREMIUM_AMOUNT,
        null, null, null, null,
        t0.final_premium as AUG_QUOTE_RATING__FINAL_PREMIUM,
        null, null, null, null,
        t0.net_premium as AUG_QUOTE_RATING__NET_PREMIUM_COMPONENT,
        t0.ncb_amt as AUG_QUOTE_RATING__NO_CLAIM_BONUS_AMOUNT,
        null,
        t0.service_tax as AUG_QUOTE_RATING__SERVICE_TAX_AMOUNT,
        t0.stamp_duty as AUG_QUOTE_RATING__STAMP_DUTY_AMOUNT,
        null,
        t0.total_act_premium as AUG_QUOTE_RATING__TOTAL_ACT_LIABILITY_PREMIUM,
        t0.total_iev as AUG_QUOTE_RATING__TOTAL_IEV_AMOUNT,
        t0.total_od_premium as AUG_QUOTE_RATING__TOTAL_OWN_DAMAGE_PREMIUM,
        null, null, null, null, null,
        t0.module_from as QUOTE_HEADER__QUOTE_SOURCE,
        null, null,
        t0.sp_disc as QUOTE_RATING__DISCOUNT_AMOUNT,
        t0.total_premium as QUOTE_RATING__GROSS_PREMIUM,
        null,
        t0.add_load_prem as QUOTE_RATING__LOADING_AMOUNT,
        t0.total_net_premium as QUOTE_RATING__NET_PREMIUM,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_ws_premium_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.transactionid)), ''), '')) is not null

    union all

    -- branch 7: BJAZ_MOTOR_WS_PREMIUM_SUMMARY
    select
        nullif(nullif(trim(to_char(t0.transactionid)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.module_from as QUOTE_HEADER__QUOTE_SOURCE,
        null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motor_ws_premium_summary') }} t0
    where (nullif(nullif(trim(to_char(t0.transactionid)), ''), '')) is not null

    union all

    -- branch 8: BJAZ_MOT_ONLINE_POL_DTLS
    select
        nullif(nullif(trim(t0.quote_ref_no), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        t0.agree_cvt_to_pol as QUOTE_HEADER__CONVERSION_STATUS,
        t0.prospect_id as QUOTE_HEADER__PROSPECT_REFERENCE,
        null, null, null, null,
        t0.quote_status as QUOTE_HEADER__QUOTE_STATUS,
        null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(nullif(trim(t0.quote_ref_no), ''), '')) is not null

    union all

    -- branch 9: BJAZ_MOT_ONLINE_POL_DTLS_EXTN
    select
        nullif(nullif(trim(to_char(t0.reference_id)), ''), '') as QUOTE_BK,
        null, null, null,
        t0.retrieve_quote_flag as AUG_QUOTE_HEADER__SAVED_QUOTE_RETRIEVED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        t0.get_quote_date as QUOTE_HEADER__QUOTE_DATE,
        null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls_extn') }} t0
    where (nullif(nullif(trim(to_char(t0.reference_id)), ''), '')) is not null

    union all

    -- branch 10: BJAZ_MOT_WS_POL_DTLS
    select
        nullif(nullif(trim(t0.quote_ref_no), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.prospect_id as QUOTE_HEADER__PROSPECT_REFERENCE,
        null, null, null, null,
        t0.quote_status as QUOTE_HEADER__QUOTE_STATUS,
        null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(nullif(trim(t0.quote_ref_no), ''), '')) is not null

    union all

    -- branch 11: BJAZ_SCR_MOT_VEH_DTLS
    select
        nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '') as QUOTE_BK,
        t0.geog_extn as AUG_QUOTE_HEADER__QUOTED_GEOGRAPHICAL_SCOPE,
        null, null, null, null,
        t0.od_standalone_req_for as AUG_QUOTE_HEADER__STANDALONE_OD_REQUEST_REASON,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        t0.partner_type as QUOTE_HEADER__QUOTE_CHANNEL,
        null, null, null, null, null, null, null,
        t0.voluntary_deduc as QUOTE_RATING__INDICATIVE_DEDUCTIBLE,
        null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_scr_mot_veh_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '')) is not null

    union all

    -- branch 12: BJAZ_SCR_MOT_VEH_DTLS | child-key literal(s): AUG_QUOTE_PRIOR_INSURANCE.Prior Policy Component=TP
    select
        nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null,
        'TP' as AUG_QUOTE_PRIOR_INSURANCE__PRIOR_POLICY_COMPONENT_CK,
        t0.tp_prev_comp_name as AUG_QUOTE_PRIOR_INSURANCE__PRIOR_INSURER_NAME,
        null,
        t0.tp_prev_pol_red as AUG_QUOTE_PRIOR_INSURANCE__PRIOR_POLICY_END_DATE,
        t0.tp_prev_pol_no as AUG_QUOTE_PRIOR_INSURANCE__PRIOR_POLICY_NUMBER,
        t0.tp_prev_pol_rid as AUG_QUOTE_PRIOR_INSURANCE__PRIOR_POLICY_START_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_scr_mot_veh_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.scrutiny_no)), ''), '')) is not null

    union all

    -- branch 13: BJAZ_WS_MOT_STP_RATE_SUMM
    select
        nullif(nullif(trim(to_char(t0.transaction_id)), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.motor_ws_trans_id as QUOTE_HEADER__QUOTE_REFERENCE_SOURCE,
        null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        10 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_ws_mot_stp_rate_summ') }} t0
    where (nullif(nullif(trim(to_char(t0.transaction_id)), ''), '')) is not null

)

select
    QUOTE_BK,
    first_value(AUG_QUOTE_HEADER__QUOTED_GEOGRAPHICAL_SCOPE) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_HEADER__QUOTED_GEOGRAPHICAL_SCOPE,
    first_value(AUG_QUOTE_HEADER__QUOTED_WAITING_PERIOD) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_HEADER__QUOTED_WAITING_PERIOD,
    first_value(AUG_QUOTE_HEADER__RESTRICTED_PRODUCT_POLICY_REQUIRED_INDICATOR) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_HEADER__RESTRICTED_PRODUCT_POLICY_REQUIRED_INDICATOR,
    first_value(AUG_QUOTE_HEADER__SAVED_QUOTE_RETRIEVED_INDICATOR) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_HEADER__SAVED_QUOTE_RETRIEVED_INDICATOR,
    first_value(AUG_QUOTE_HEADER__SELECTED_IMT_CLAUSE_CODE_LIST) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_HEADER__SELECTED_IMT_CLAUSE_CODE_LIST,
    first_value(AUG_QUOTE_HEADER__STANDALONE_OD_REQUEST_REASON) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_HEADER__STANDALONE_OD_REQUEST_REASON,
    AUG_QUOTE_PRIOR_INSURANCE__PRIOR_POLICY_COMPONENT_CK,
    first_value(AUG_QUOTE_PRIOR_INSURANCE__PRIOR_INSURER_NAME) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_PRIOR_INSURANCE__PRIOR_POLICY_COMPONENT_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_PRIOR_INSURANCE__PRIOR_INSURER_NAME,
    first_value(AUG_QUOTE_PRIOR_INSURANCE__PRIOR_POLICY_CLAIM_COUNT) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_PRIOR_INSURANCE__PRIOR_POLICY_COMPONENT_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_PRIOR_INSURANCE__PRIOR_POLICY_CLAIM_COUNT,
    first_value(AUG_QUOTE_PRIOR_INSURANCE__PRIOR_POLICY_END_DATE) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_PRIOR_INSURANCE__PRIOR_POLICY_COMPONENT_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_PRIOR_INSURANCE__PRIOR_POLICY_END_DATE,
    first_value(AUG_QUOTE_PRIOR_INSURANCE__PRIOR_POLICY_NUMBER) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_PRIOR_INSURANCE__PRIOR_POLICY_COMPONENT_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_PRIOR_INSURANCE__PRIOR_POLICY_NUMBER,
    first_value(AUG_QUOTE_PRIOR_INSURANCE__PRIOR_POLICY_START_DATE) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_PRIOR_INSURANCE__PRIOR_POLICY_COMPONENT_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_PRIOR_INSURANCE__PRIOR_POLICY_START_DATE,
    first_value(AUG_QUOTE_PRIOR_INSURANCE__PRIOR_TENURE_YEARS) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_PRIOR_INSURANCE__PRIOR_POLICY_COMPONENT_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_PRIOR_INSURANCE__PRIOR_TENURE_YEARS,
    first_value(AUG_QUOTE_RATING__COLLECTED_PREMIUM_AMOUNT) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_RATING__COLLECTED_PREMIUM_AMOUNT,
    first_value(AUG_QUOTE_RATING__COMMISSION_AMOUNT) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_RATING__COMMISSION_AMOUNT,
    first_value(AUG_QUOTE_RATING__COMMISSION_BASE_AMOUNT) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_RATING__COMMISSION_BASE_AMOUNT,
    first_value(AUG_QUOTE_RATING__COMMISSION_BASE_NET_RATEABLE_VALUE) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_RATING__COMMISSION_BASE_NET_RATEABLE_VALUE,
    first_value(AUG_QUOTE_RATING__COMMISSION_RATE) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_RATING__COMMISSION_RATE,
    first_value(AUG_QUOTE_RATING__FINAL_PREMIUM) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_RATING__FINAL_PREMIUM,
    first_value(AUG_QUOTE_RATING__LOADING_PERCENTAGE) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_RATING__LOADING_PERCENTAGE,
    first_value(AUG_QUOTE_RATING__MAXIMUM_COMMISSION_RATE) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_RATING__MAXIMUM_COMMISSION_RATE,
    first_value(AUG_QUOTE_RATING__MINIMUM_COMMISSION_RATE) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_RATING__MINIMUM_COMMISSION_RATE,
    first_value(AUG_QUOTE_RATING__MULTI_POLICY_DISCOUNT_PERCENTAGE) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_RATING__MULTI_POLICY_DISCOUNT_PERCENTAGE,
    first_value(AUG_QUOTE_RATING__NET_PREMIUM_COMPONENT) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_RATING__NET_PREMIUM_COMPONENT,
    first_value(AUG_QUOTE_RATING__NO_CLAIM_BONUS_AMOUNT) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_RATING__NO_CLAIM_BONUS_AMOUNT,
    first_value(AUG_QUOTE_RATING__PAYOUT_APPLICABLE_INDICATOR) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_RATING__PAYOUT_APPLICABLE_INDICATOR,
    first_value(AUG_QUOTE_RATING__SERVICE_TAX_AMOUNT) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_RATING__SERVICE_TAX_AMOUNT,
    first_value(AUG_QUOTE_RATING__STAMP_DUTY_AMOUNT) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_RATING__STAMP_DUTY_AMOUNT,
    first_value(AUG_QUOTE_RATING__THEFT_EXCESS_AMOUNT) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_RATING__THEFT_EXCESS_AMOUNT,
    first_value(AUG_QUOTE_RATING__TOTAL_ACT_LIABILITY_PREMIUM) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_RATING__TOTAL_ACT_LIABILITY_PREMIUM,
    first_value(AUG_QUOTE_RATING__TOTAL_IEV_AMOUNT) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_RATING__TOTAL_IEV_AMOUNT,
    first_value(AUG_QUOTE_RATING__TOTAL_OWN_DAMAGE_PREMIUM) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_RATING__TOTAL_OWN_DAMAGE_PREMIUM,
    first_value(QUOTE_HEADER__CONVERSION_STATUS) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as QUOTE_HEADER__CONVERSION_STATUS,
    first_value(QUOTE_HEADER__PROSPECT_REFERENCE) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as QUOTE_HEADER__PROSPECT_REFERENCE,
    first_value(QUOTE_HEADER__QUOTE_CHANNEL) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as QUOTE_HEADER__QUOTE_CHANNEL,
    first_value(QUOTE_HEADER__QUOTE_DATE) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as QUOTE_HEADER__QUOTE_DATE,
    first_value(QUOTE_HEADER__QUOTE_REFERENCE_SOURCE) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as QUOTE_HEADER__QUOTE_REFERENCE_SOURCE,
    first_value(QUOTE_HEADER__QUOTE_SOURCE) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as QUOTE_HEADER__QUOTE_SOURCE,
    first_value(QUOTE_HEADER__QUOTE_STATUS) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as QUOTE_HEADER__QUOTE_STATUS,
    first_value(QUOTE_HEADER__REQUESTED_SUM_INSURED) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as QUOTE_HEADER__REQUESTED_SUM_INSURED,
    first_value(QUOTE_RATING__DISCOUNT_AMOUNT) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as QUOTE_RATING__DISCOUNT_AMOUNT,
    first_value(QUOTE_RATING__GROSS_PREMIUM) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as QUOTE_RATING__GROSS_PREMIUM,
    first_value(QUOTE_RATING__INDICATIVE_DEDUCTIBLE) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as QUOTE_RATING__INDICATIVE_DEDUCTIBLE,
    first_value(QUOTE_RATING__LOADING_AMOUNT) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as QUOTE_RATING__LOADING_AMOUNT,
    first_value(QUOTE_RATING__NET_PREMIUM) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as QUOTE_RATING__NET_PREMIUM,
    -- the row's own source time: LOAD_DATETIME for hubs, links and single-active satellites
    m.INC_JOB_UPDATED_AT,
    -- SAT_AUG_QUOTE_PRIOR_INSURANCE (ma_sat): one load time per QUOTE_BK, so all its child rows share it
    max(case when coalesce(m.AUG_QUOTE_PRIOR_INSURANCE__PRIOR_INSURER_NAME, m.AUG_QUOTE_PRIOR_INSURANCE__PRIOR_POLICY_CLAIM_COUNT, m.AUG_QUOTE_PRIOR_INSURANCE__PRIOR_POLICY_END_DATE, m.AUG_QUOTE_PRIOR_INSURANCE__PRIOR_POLICY_NUMBER, m.AUG_QUOTE_PRIOR_INSURANCE__PRIOR_POLICY_START_DATE, m.AUG_QUOTE_PRIOR_INSURANCE__PRIOR_TENURE_YEARS) is not null
             then m.INC_JOB_UPDATED_AT end)
        over (partition by m.QUOTE_BK) as AUG_QUOTE_PRIOR_INSURANCE__LOAD_DATETIME
from merged m
