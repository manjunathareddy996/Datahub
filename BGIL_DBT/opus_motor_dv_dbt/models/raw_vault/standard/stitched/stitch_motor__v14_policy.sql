-- CENTRAL VIEW v14_policy -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   BJAZ_MOT_INS_HST_EXTN
--   BJAZ_MOT_OD_TP_DTLS
--   BJAZ_MOT_ONLINE_POL_DTLS
--   BJAZ_MOT_PREM_SUMM_EXTN_ADJ
--   BJAZ_MOT_RENEWAL
--   BJAZ_MOT_RENEWAL_EXTN
--   BJAZ_MOT_RENEWAL_HIST
--   BJAZ_MOT_REN_SUM_DTLS_A
--   BJAZ_MOT_WS_POL_DTLS
--   WRN_BJAZ_MOT_RENEWAL
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_CHANNEL_DEFINITION
--   SAT_AUG_POLICY_BONUS_TRACKING
--   SAT_AUG_POLICY_PREMIUM_HEAD
--   SAT_AUG_POLICY_PREMIUM_SETTLEMENT
--   SAT_AUG_POLICY_RENEWAL
--   SAT_AUG_RISK_MOTOR_ADDON
--   SAT_AUG_RISK_MOTOR_FITMENTS
--   SAT_COMMON_STATUS
--   SAT_LNK_ROLE_CUSTOMER
--   SAT_POLICY_RENEWAL
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_POLICY_ORG_UNIT
--   LNK_POLICY_PRODUCT
--   LNK_POLICY_RISK_OBJECT
--   LNK_PROPOSAL_POLICY
--   LNK_PROPOSAL_RISK_OBJECT
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: BJAZ_MOT_INS_HST_EXTN
    select
        cast(null as varchar) as DISTRIBUTION_CHANNEL_BK,
        cast(null as varchar) as ORG_UNIT_BK,
        cast(null as varchar) as PARTY_BK,
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        cast(null as varchar) as PRODUCT_BK,
        cast(null as varchar) as PROPOSAL_BK,
        cast(null as varchar) as RISK_OBJECT_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as number) as __LNK_POLICY_ORG_UNIT,
        cast(null as number) as __LNK_POLICY_PRODUCT,
        cast(null as number) as __LNK_POLICY_RISK_OBJECT,
        cast(null as number) as __LNK_PROPOSAL_POLICY,
        cast(null as number) as __LNK_PROPOSAL_RISK_OBJECT,
        cast(null as varchar) as AUG_CHANNEL_DEFINITION__CHANNEL_GSTIN,
        t0.prev_ncb_source as AUG_POLICY_BONUS_TRACKING__PREVIOUS_BONUS_DECLARATION_SOURCE,
        t0.no_of_claims as AUG_POLICY_BONUS_TRACKING__PREVIOUS_POLICY_CLAIM_COUNT,
        cast(null as varchar) as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        cast(null as varchar) as AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        cast(null as varchar) as AUG_POLICY_PREMIUM_HEAD__SECTION_CK,
        cast(null as varchar) as AUG_POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK,
        cast(null as varchar) as AUG_POLICY_PREMIUM_HEAD__ADJUSTMENT_REMARKS,
        cast(null as varchar) as AUG_POLICY_PREMIUM_HEAD__DISCOUNT_PERCENTAGE,
        cast(null as varchar) as AUG_POLICY_PREMIUM_HEAD__HEAD_PREMIUM_RATE,
        cast(null as varchar) as AUG_POLICY_PREMIUM_HEAD__LOADING_PERCENTAGE,
        cast(null as varchar) as AUG_POLICY_PREMIUM_HEAD__MINIMUM_HEAD_PREMIUM,
        cast(null as varchar) as AUG_POLICY_PREMIUM_HEAD__PREMIUM_ADJUSTMENT_AMOUNT,
        cast(null as varchar) as AUG_POLICY_PREMIUM_HEAD__PREMIUM_RATE,
        cast(null as varchar) as AUG_POLICY_PREMIUM_HEAD__SECTION_APPLICABLE_INDICATOR,
        cast(null as varchar) as AUG_POLICY_PREMIUM_SETTLEMENT__SETTLEMENT_LINE_SEQUENCE_CK,
        cast(null as varchar) as AUG_POLICY_PREMIUM_SETTLEMENT__SETTLEMENT_LINE_REFERENCE_CK,
        cast(null as varchar) as AUG_POLICY_PREMIUM_SETTLEMENT__ACCOUNTING_BATCH_REFERENCE,
        cast(null as varchar) as AUG_POLICY_PREMIUM_SETTLEMENT__ACCOUNTING_PASS_INDICATOR,
        cast(null as varchar) as AUG_POLICY_PREMIUM_SETTLEMENT__ACCOUNTING_POSTING_DATE,
        cast(null as varchar) as AUG_POLICY_RENEWAL__BANK_PARTNER_VERSION_MARKER,
        cast(null as varchar) as AUG_POLICY_RENEWAL__DIRECT_MARKETING_LOCATION_CODE,
        cast(null as varchar) as AUG_POLICY_RENEWAL__DOCUMENT_DISPATCH_INDICATOR,
        cast(null as varchar) as AUG_POLICY_RENEWAL__EXPIRING_POLICY_CLAIM_RATIO,
        cast(null as varchar) as AUG_POLICY_RENEWAL__EXPIRING_POLICY_INCURRED_CLAIM_RATIO,
        cast(null as varchar) as AUG_POLICY_RENEWAL__LAST_ENDORSEMENT_DATE,
        cast(null as varchar) as AUG_POLICY_RENEWAL__POLICY_CANCELLATION_REASON,
        t0.prev_policy_term as AUG_POLICY_RENEWAL__PREVIOUS_POLICY_TERM,
        t0.prev_vehicle_make as AUG_POLICY_RENEWAL__PREVIOUS_VEHICLE_MAKE_CODE,
        t0.prev_vehicle_model as AUG_POLICY_RENEWAL__PREVIOUS_VEHICLE_MODEL_CODE,
        t0.prev_vehicle_reg_no as AUG_POLICY_RENEWAL__PREVIOUS_VEHICLE_REGISTRATION_NUMBER,
        t0.prev_vehicle_subtype as AUG_POLICY_RENEWAL__PREVIOUS_VEHICLE_SUB_TYPE_CODE,
        t0.prev_vehicle_type as AUG_POLICY_RENEWAL__PREVIOUS_VEHICLE_TYPE_CODE,
        cast(null as varchar) as AUG_POLICY_RENEWAL__PROFITABILITY_INDICATOR,
        cast(null as varchar) as AUG_POLICY_RENEWAL__PROSPECT_REFERENCE,
        cast(null as varchar) as AUG_POLICY_RENEWAL__QUALITY_CHECK_STATUS,
        cast(null as varchar) as AUG_POLICY_RENEWAL__RENEWAL_CHANNEL,
        cast(null as varchar) as AUG_POLICY_RENEWAL__RENEWAL_GROSS_PREMIUM,
        cast(null as varchar) as AUG_POLICY_RENEWAL__RENEWAL_NOTICE_DOCUMENT_REFERENCE,
        cast(null as varchar) as AUG_POLICY_RENEWAL__RENEWAL_NOTICE_PRINTED_INDICATOR,
        cast(null as varchar) as AUG_POLICY_RENEWAL__RENEWAL_NOTICE_REFERENCE,
        cast(null as varchar) as AUG_POLICY_RENEWAL__RENEWAL_NOTICE_REGENERATED_DATE,
        cast(null as varchar) as AUG_POLICY_RENEWAL__RENEWAL_NOTICE_REGENERATED_INDICATOR,
        cast(null as varchar) as AUG_POLICY_RENEWAL__RENEWAL_POLICY_NUMBER,
        cast(null as varchar) as AUG_POLICY_RENEWAL__RENEWAL_PRICED_INDICATOR,
        cast(null as varchar) as AUG_POLICY_RENEWAL__RENEWAL_REGENERATED_INDICATOR,
        cast(null as varchar) as AUG_POLICY_RENEWAL__RENEWAL_REGENERATION_DATE,
        cast(null as varchar) as AUG_POLICY_RENEWAL__RENEWAL_TARIFF_RATE,
        cast(null as varchar) as AUG_POLICY_RENEWAL__RENEWED_INTO_POLICY_REFERENCE,
        cast(null as varchar) as AUG_POLICY_RENEWAL__RENEWED_POLICY_REFERENCE,
        cast(null as varchar) as AUG_POLICY_RENEWAL__UNDERWRITING_PROFITABILITY_INDICATOR,
        cast(null as varchar) as AUG_POLICY_RENEWAL__UNIFIED_RENEWAL_STATUS,
        cast(null as varchar) as AUG_RISK_MOTOR_ADDON__ADD_ON_CODE_CK,
        cast(null as varchar) as AUG_RISK_MOTOR_ADDON__ADD_ON_DISCOUNT_AMOUNT,
        cast(null as varchar) as AUG_RISK_MOTOR_ADDON__DEVIATED_ADD_ON_PREMIUM,
        cast(null as varchar) as AUG_RISK_MOTOR_FITMENTS__FITMENT_TYPE_CK,
        cast(null as varchar) as AUG_RISK_MOTOR_FITMENTS__SEQUENCE_CK,
        cast(null as varchar) as AUG_RISK_MOTOR_FITMENTS__SYSTEM_CALCULATED_FITMENT_VALUE,
        cast(null as varchar) as COMMON_STATUS__STATUS_CODE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as POLICY_RENEWAL__CANCELLED_POLICY_INDICATOR,
        cast(null as varchar) as POLICY_RENEWAL__PRECEDING_POLICY_REFERENCE,
        cast(null as varchar) as POLICY_RENEWAL__RENEWAL_BLOCK_REASON,
        cast(null as varchar) as POLICY_RENEWAL__RENEWAL_DISCOUNT,
        cast(null as varchar) as POLICY_RENEWAL__RENEWAL_PREMIUM,
        cast(null as varchar) as POLICY_RENEWAL__RENEWAL_STATUS,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ins_hst_extn') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 1: BJAZ_MOT_OD_TP_DTLS | child-key literal(s): AUG_POLICY_PREMIUM_HEAD.Premium Head Code=ADJUSTED_OD, AUG_POLICY_PREMIUM_HEAD.Section=OD
    select
        null, null, null,
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null,
        'ADJUSTED_OD' as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as AUG_POLICY_PREMIUM_HEAD__SECTION_CK,
        null,
        t0.adj_od_rmks as AUG_POLICY_PREMIUM_HEAD__ADJUSTMENT_REMARKS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_od_tp_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 2: BJAZ_MOT_OD_TP_DTLS | child-key literal(s): AUG_POLICY_PREMIUM_HEAD.Premium Head Code=ADJUSTED_TP, AUG_POLICY_PREMIUM_HEAD.Section=TP
    select
        null, null, null,
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null,
        'ADJUSTED_TP' as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'TP' as AUG_POLICY_PREMIUM_HEAD__SECTION_CK,
        null,
        t0.adj_tp_rmks as AUG_POLICY_PREMIUM_HEAD__ADJUSTMENT_REMARKS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_od_tp_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 3: BJAZ_MOT_OD_TP_DTLS
    select
        null,
        nullif(nullif(trim(to_char(t0.branch_code)), ''), '') as ORG_UNIT_BK,
        null,
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        nullif(nullif(trim(to_char(t0.product_code)), ''), '') as PRODUCT_BK,
        null, null, null,
        1 as __LNK_POLICY_ORG_UNIT,
        1 as __LNK_POLICY_PRODUCT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.tp_acc_batch_id as AUG_POLICY_PREMIUM_SETTLEMENT__SETTLEMENT_LINE_REFERENCE_CK,
        t0.tp_acc_batch_id as AUG_POLICY_PREMIUM_SETTLEMENT__ACCOUNTING_BATCH_REFERENCE,
        t0.tp_acc_pass_yn as AUG_POLICY_PREMIUM_SETTLEMENT__ACCOUNTING_PASS_INDICATOR,
        t0.tp_acc_date as AUG_POLICY_PREMIUM_SETTLEMENT__ACCOUNTING_POSTING_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_od_tp_dtls') }} t0
    where (coalesce(nullif(nullif(trim(to_char(t0.branch_code)), ''), ''), nullif(nullif(trim(to_char(t0.contract_id)), ''), ''), nullif(nullif(trim(to_char(t0.product_code)), ''), ''))) is not null

    union all

    -- branch 4: BJAZ_MOT_ONLINE_POL_DTLS
    select
        null, null, null,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rnw_channel as AUG_POLICY_RENEWAL__RENEWAL_CHANNEL,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.renew_pol_no as AUG_POLICY_RENEWAL__RENEWED_INTO_POLICY_REFERENCE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.renewal_disc_amt as POLICY_RENEWAL__RENEWAL_DISCOUNT,
        t0.renewal_premium as POLICY_RENEWAL__RENEWAL_PREMIUM,
        null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_online_pol_dtls') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 5: BJAZ_MOT_PREM_SUMM_EXTN_ADJ
    select
        null, null, null,
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.param_ref as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null, null,
        t0.diff_yn as AUG_POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK,
        null, null, null, null, null,
        t0.diff_prem as AUG_POLICY_PREMIUM_HEAD__PREMIUM_ADJUSTMENT_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_prem_summ_extn_adj') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 6: BJAZ_MOT_RENEWAL | child-key literal(s): AUG_POLICY_PREMIUM_HEAD.Premium Head Code=BASIC_OD, AUG_POLICY_PREMIUM_HEAD.Section=OD
    select
        null, null, null,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null,
        'BASIC_OD' as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as AUG_POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null,
        t0.basic_od_rate as AUG_POLICY_PREMIUM_HEAD__PREMIUM_RATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 7: BJAZ_MOT_RENEWAL
    select
        null, null, null,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        t0.dm_location as AUG_POLICY_RENEWAL__DIRECT_MARKETING_LOCATION_CODE,
        null,
        t0.claim_ratio as AUG_POLICY_RENEWAL__EXPIRING_POLICY_CLAIM_RATIO,
        t0.inc_claim_ratio as AUG_POLICY_RENEWAL__EXPIRING_POLICY_INCURRED_CLAIM_RATIO,
        null, null, null, null, null, null, null, null, null,
        t0.prospect_id as AUG_POLICY_RENEWAL__PROSPECT_REFERENCE,
        null, null,
        t0.new_gross_premium as AUG_POLICY_RENEWAL__RENEWAL_GROSS_PREMIUM,
        null,
        t0.print_flag as AUG_POLICY_RENEWAL__RENEWAL_NOTICE_PRINTED_INDICATOR,
        null, null, null, null, null,
        t0.regenerate as AUG_POLICY_RENEWAL__RENEWAL_REGENERATED_INDICATOR,
        t0.regen_date as AUG_POLICY_RENEWAL__RENEWAL_REGENERATION_DATE,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.status as COMMON_STATUS__STATUS_CODE,
        null, null, null, null, null, null,
        t0.new_net_premium as POLICY_RENEWAL__RENEWAL_PREMIUM,
        t0.rn_status as POLICY_RENEWAL__RENEWAL_STATUS,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 8: BJAZ_MOT_RENEWAL_EXTN
    select
        nullif(nullif('SUBAGENT:' || nullif(trim(t0.sub_agent_code), ''), 'SUBAGENT:'), '') as DISTRIBUTION_CHANNEL_BK,
        null, null,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null,
        1 as __LNK_POLICY_RISK_OBJECT,
        null, null,
        t0.partner_gstn as AUG_CHANNEL_DEFINITION__CHANNEL_GSTIN,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.hdfc_ver as AUG_POLICY_RENEWAL__BANK_PARTNER_VERSION_MARKER,
        null,
        t0.dispatch_flag as AUG_POLICY_RENEWAL__DOCUMENT_DISPATCH_INDICATOR,
        null, null,
        t0.last_endt_date as AUG_POLICY_RENEWAL__LAST_ENDORSEMENT_DATE,
        t0.pol_can_reason as AUG_POLICY_RENEWAL__POLICY_CANCELLATION_REASON,
        null, null, null, null, null, null,
        t0.profitable_flag as AUG_POLICY_RENEWAL__PROFITABILITY_INDICATOR,
        null,
        t0.qc_status as AUG_POLICY_RENEWAL__QUALITY_CHECK_STATUS,
        null, null,
        t0.img_link as AUG_POLICY_RENEWAL__RENEWAL_NOTICE_DOCUMENT_REFERENCE,
        null,
        t0.ren_ref_no as AUG_POLICY_RENEWAL__RENEWAL_NOTICE_REFERENCE,
        null, null, null,
        t0.pricing_flag as AUG_POLICY_RENEWAL__RENEWAL_PRICED_INDICATOR,
        null, null,
        t0.new_tariff_rate as AUG_POLICY_RENEWAL__RENEWAL_TARIFF_RATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.can_pol_flag as POLICY_RENEWAL__CANCELLED_POLICY_INDICATOR,
        null,
        t0.decline_reason as POLICY_RENEWAL__RENEWAL_BLOCK_REASON,
        null, null,
        t0.rn_status_curr as POLICY_RENEWAL__RENEWAL_STATUS,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_extn') }} t0
    where (coalesce(nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), ''), nullif(nullif('SUBAGENT:' || nullif(trim(t0.sub_agent_code), ''), 'SUBAGENT:'), ''), nullif(nullif(trim(t0.policy_ref), ''), ''))) is not null

    union all

    -- branch 9: BJAZ_MOT_RENEWAL_EXTN | child-key literal(s): AUG_POLICY_PREMIUM_HEAD.Premium Head Code=OD_LOADING_FIRST_YEAR, AUG_POLICY_PREMIUM_HEAD.Section=OD
    select
        null, null, null,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null,
        'OD_LOADING_FIRST_YEAR' as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as AUG_POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null,
        t0.od_load_rate_1st as AUG_POLICY_PREMIUM_HEAD__LOADING_PERCENTAGE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_extn') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 10: BJAZ_MOT_RENEWAL_EXTN | child-key literal(s): AUG_POLICY_PREMIUM_HEAD.Premium Head Code=COMMERCIAL_DISCOUNT, AUG_POLICY_PREMIUM_HEAD.Section=OD
    select
        null, null, null,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null,
        'COMMERCIAL_DISCOUNT' as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as AUG_POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.comm_disc_rate_1st as AUG_POLICY_PREMIUM_HEAD__DISCOUNT_PERCENTAGE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_extn') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 11: BJAZ_MOT_RENEWAL_EXTN | child-key literal(s): AUG_POLICY_PREMIUM_HEAD.Premium Head Code=MPMP_DISCOUNT, AUG_POLICY_PREMIUM_HEAD.Section=OD
    select
        null, null, null,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null,
        'MPMP_DISCOUNT' as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as AUG_POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.mpmp_disc_rate as AUG_POLICY_PREMIUM_HEAD__DISCOUNT_PERCENTAGE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_extn') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 12: BJAZ_MOT_RENEWAL_EXTN | child-key literal(s): AUG_RISK_MOTOR_ADDON.Add On Code=PACKAGE
    select
        null, null, null, null, null, null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        'PACKAGE' as AUG_RISK_MOTOR_ADDON__ADD_ON_CODE_CK,
        t0.addon_pkg_disc as AUG_RISK_MOTOR_ADDON__ADD_ON_DISCOUNT_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_extn') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 13: BJAZ_MOT_RENEWAL_EXTN | child-key literal(s): AUG_RISK_MOTOR_ADDON.Add On Code=PACKAGE_URM
    select
        null, null, null, null, null, null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        'PACKAGE_URM' as AUG_RISK_MOTOR_ADDON__ADD_ON_CODE_CK,
        t0.addon_pkg_disc_urm as AUG_RISK_MOTOR_ADDON__ADD_ON_DISCOUNT_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_extn') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 14: BJAZ_MOT_RENEWAL_EXTN | child-key literal(s): LNK_ROLE_CUSTOMER.Role Type=CUSTOMER
    select
        null, null,
        nullif(nullif(trim(to_char(t0.cust_id)), ''), '') as PARTY_BK,
        null, null, null, null,
        'CUSTOMER' as ROLE_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CUSTOMER' as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        t0.vip_flag as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_extn') }} t0
    where (nullif(nullif(trim(to_char(t0.cust_id)), ''), '')) is not null

    union all

    -- branch 15: BJAZ_MOT_RENEWAL_HIST | child-key literal(s): AUG_POLICY_PREMIUM_HEAD.Premium Head Code=BASIC_OD, AUG_POLICY_PREMIUM_HEAD.Section=OD
    select
        null, null, null,
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null,
        'BASIC_OD' as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as AUG_POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.basic_od_rate as AUG_POLICY_PREMIUM_HEAD__HEAD_PREMIUM_RATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_hist') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 16: BJAZ_MOT_RENEWAL_HIST | child-key literal(s): AUG_POLICY_PREMIUM_HEAD.Premium Head Code=MINIMUM_GROSS_PREMIUM, AUG_POLICY_PREMIUM_HEAD.Section=OD
    select
        null, null, null,
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null,
        'MINIMUM_GROSS_PREMIUM' as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as AUG_POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null,
        t0.min_gross_prem as AUG_POLICY_PREMIUM_HEAD__MINIMUM_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_hist') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 17: BJAZ_MOT_RENEWAL_HIST
    select
        null, null, null,
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null,
        nullif(nullif(trim(to_char(t0.ren_ref_no)), ''), '') as PROPOSAL_BK,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null,
        1 as __LNK_POLICY_RISK_OBJECT,
        1 as __LNK_PROPOSAL_POLICY,
        1 as __LNK_PROPOSAL_RISK_OBJECT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.claim_ratio as AUG_POLICY_RENEWAL__EXPIRING_POLICY_CLAIM_RATIO,
        t0.inc_claim_ratio as AUG_POLICY_RENEWAL__EXPIRING_POLICY_INCURRED_CLAIM_RATIO,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.print_flag as AUG_POLICY_RENEWAL__RENEWAL_NOTICE_PRINTED_INDICATOR,
        null,
        t0.regen_date as AUG_POLICY_RENEWAL__RENEWAL_NOTICE_REGENERATED_DATE,
        t0.regenerate as AUG_POLICY_RENEWAL__RENEWAL_NOTICE_REGENERATED_INDICATOR,
        null, null, null, null,
        t0.new_tariff_rate as AUG_POLICY_RENEWAL__RENEWAL_TARIFF_RATE,
        null,
        t0.renewed_policy_ref as AUG_POLICY_RENEWAL__RENEWED_POLICY_REFERENCE,
        t0.profitable_flag as AUG_POLICY_RENEWAL__UNDERWRITING_PROFITABILITY_INDICATOR,
        null, null, null, null, null, null, null, null, null, null,
        t0.can_pol_flag as POLICY_RENEWAL__CANCELLED_POLICY_INDICATOR,
        t0.policy_ref as POLICY_RENEWAL__PRECEDING_POLICY_REFERENCE,
        null, null, null,
        t0.rn_status as POLICY_RENEWAL__RENEWAL_STATUS,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_hist') }} t0
    where (coalesce(nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), ''), nullif(nullif(trim(to_char(t0.contract_id)), ''), ''), nullif(nullif(trim(to_char(t0.ren_ref_no)), ''), ''))) is not null

    union all

    -- branch 18: BJAZ_MOT_RENEWAL_HIST | child-key literal(s): AUG_RISK_MOTOR_ADDON.Add On Code=PACKAGE
    select
        null, null, null, null, null, null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        'PACKAGE' as AUG_RISK_MOTOR_ADDON__ADD_ON_CODE_CK,
        null,
        t0.addon_pkg_prem_dev as AUG_RISK_MOTOR_ADDON__DEVIATED_ADD_ON_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_hist') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 19: BJAZ_MOT_RENEWAL_HIST | child-key literal(s): AUG_RISK_MOTOR_FITMENTS.Fitment Type=ELECTRICAL_ACCESSORY, AUG_RISK_MOTOR_FITMENTS.Sequence=1
    select
        null, null, null, null, null, null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ELECTRICAL_ACCESSORY' as AUG_RISK_MOTOR_FITMENTS__FITMENT_TYPE_CK,
        '1' as AUG_RISK_MOTOR_FITMENTS__SEQUENCE_CK,
        t0.syscal_elecacc_iev as AUG_RISK_MOTOR_FITMENTS__SYSTEM_CALCULATED_FITMENT_VALUE,
        null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_hist') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 20: BJAZ_MOT_RENEWAL_HIST | child-key literal(s): AUG_RISK_MOTOR_FITMENTS.Fitment Type=NON_ELECTRICAL_ACCESSORY, AUG_RISK_MOTOR_FITMENTS.Sequence=1
    select
        null, null, null, null, null, null,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NON_ELECTRICAL_ACCESSORY' as AUG_RISK_MOTOR_FITMENTS__FITMENT_TYPE_CK,
        '1' as AUG_RISK_MOTOR_FITMENTS__SEQUENCE_CK,
        t0.syscal_non_elecacc_iev as AUG_RISK_MOTOR_FITMENTS__SYSTEM_CALCULATED_FITMENT_VALUE,
        null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_renewal_hist') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '')) is not null

    union all

    -- branch 21: BJAZ_MOT_REN_SUM_DTLS_A | child-key literal(s): AUG_POLICY_PREMIUM_HEAD.Section=OD
    select
        null, null, null,
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.param_no as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as AUG_POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null,
        t0.od_tag as AUG_POLICY_PREMIUM_HEAD__SECTION_APPLICABLE_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ren_sum_dtls_a') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 22: BJAZ_MOT_REN_SUM_DTLS_A | child-key literal(s): AUG_POLICY_PREMIUM_HEAD.Section=TP
    select
        null, null, null,
        nullif(nullif(trim(to_char(t0.contract_id)), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.param_no as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'TP' as AUG_POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null,
        t0.tp_tag as AUG_POLICY_PREMIUM_HEAD__SECTION_APPLICABLE_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ren_sum_dtls_a') }} t0
    where (nullif(nullif(trim(to_char(t0.contract_id)), ''), '')) is not null

    union all

    -- branch 23: BJAZ_MOT_WS_POL_DTLS
    select
        null, null, null,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        t0.renew_pol_no as AUG_POLICY_RENEWAL__RENEWAL_POLICY_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_ws_pol_dtls') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 24: WRN_BJAZ_MOT_RENEWAL | child-key literal(s): AUG_POLICY_PREMIUM_HEAD.Premium Head Code=BASIC_OD, AUG_POLICY_PREMIUM_HEAD.Section=OD
    select
        null, null, null,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null,
        'BASIC_OD' as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as AUG_POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null,
        t0.basic_od_rate as AUG_POLICY_PREMIUM_HEAD__PREMIUM_RATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__wrn_bjaz_mot_renewal') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

    union all

    -- branch 25: WRN_BJAZ_MOT_RENEWAL
    select
        null, null, null,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        t0.dm_location as AUG_POLICY_RENEWAL__DIRECT_MARKETING_LOCATION_CODE,
        null,
        t0.claim_ratio as AUG_POLICY_RENEWAL__EXPIRING_POLICY_CLAIM_RATIO,
        t0.inc_claim_ratio as AUG_POLICY_RENEWAL__EXPIRING_POLICY_INCURRED_CLAIM_RATIO,
        null, null, null, null, null, null, null, null, null,
        t0.prospect_id as AUG_POLICY_RENEWAL__PROSPECT_REFERENCE,
        null, null,
        t0.new_gross_premium as AUG_POLICY_RENEWAL__RENEWAL_GROSS_PREMIUM,
        null,
        t0.print_flag as AUG_POLICY_RENEWAL__RENEWAL_NOTICE_PRINTED_INDICATOR,
        null, null, null, null, null,
        t0.regenerate as AUG_POLICY_RENEWAL__RENEWAL_REGENERATED_INDICATOR,
        t0.regen_date as AUG_POLICY_RENEWAL__RENEWAL_REGENERATION_DATE,
        null, null, null, null,
        t0.unified_ren_status as AUG_POLICY_RENEWAL__UNIFIED_RENEWAL_STATUS,
        null, null, null, null, null, null,
        t0.status as COMMON_STATUS__STATUS_CODE,
        null, null, null, null, null, null,
        t0.new_net_premium as POLICY_RENEWAL__RENEWAL_PREMIUM,
        t0.rn_status as POLICY_RENEWAL__RENEWAL_STATUS,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__wrn_bjaz_mot_renewal') }} t0
    where (nullif(nullif(trim(t0.policy_ref), ''), '')) is not null

)

select
    DISTRIBUTION_CHANNEL_BK,
    ORG_UNIT_BK,
    PARTY_BK,
    POLICY_BK,
    PRODUCT_BK,
    PROPOSAL_BK,
    RISK_OBJECT_BK,
    ROLE_TYPE_CODE,
    __LNK_POLICY_ORG_UNIT,
    __LNK_POLICY_PRODUCT,
    __LNK_POLICY_RISK_OBJECT,
    __LNK_PROPOSAL_POLICY,
    __LNK_PROPOSAL_RISK_OBJECT,
    first_value(AUG_CHANNEL_DEFINITION__CHANNEL_GSTIN) ignore nulls over (partition by DISTRIBUTION_CHANNEL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CHANNEL_DEFINITION__CHANNEL_GSTIN,
    first_value(AUG_POLICY_BONUS_TRACKING__PREVIOUS_BONUS_DECLARATION_SOURCE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_BONUS_TRACKING__PREVIOUS_BONUS_DECLARATION_SOURCE,
    first_value(AUG_POLICY_BONUS_TRACKING__PREVIOUS_POLICY_CLAIM_COUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_BONUS_TRACKING__PREVIOUS_POLICY_CLAIM_COUNT,
    AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
    AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
    AUG_POLICY_PREMIUM_HEAD__SECTION_CK,
    AUG_POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK,
    first_value(AUG_POLICY_PREMIUM_HEAD__ADJUSTMENT_REMARKS) ignore nulls over (partition by POLICY_BK, AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK, AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK, AUG_POLICY_PREMIUM_HEAD__SECTION_CK, AUG_POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_HEAD__ADJUSTMENT_REMARKS,
    first_value(AUG_POLICY_PREMIUM_HEAD__DISCOUNT_PERCENTAGE) ignore nulls over (partition by POLICY_BK, AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK, AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK, AUG_POLICY_PREMIUM_HEAD__SECTION_CK, AUG_POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_HEAD__DISCOUNT_PERCENTAGE,
    first_value(AUG_POLICY_PREMIUM_HEAD__HEAD_PREMIUM_RATE) ignore nulls over (partition by POLICY_BK, AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK, AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK, AUG_POLICY_PREMIUM_HEAD__SECTION_CK, AUG_POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_HEAD__HEAD_PREMIUM_RATE,
    first_value(AUG_POLICY_PREMIUM_HEAD__LOADING_PERCENTAGE) ignore nulls over (partition by POLICY_BK, AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK, AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK, AUG_POLICY_PREMIUM_HEAD__SECTION_CK, AUG_POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_HEAD__LOADING_PERCENTAGE,
    first_value(AUG_POLICY_PREMIUM_HEAD__MINIMUM_HEAD_PREMIUM) ignore nulls over (partition by POLICY_BK, AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK, AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK, AUG_POLICY_PREMIUM_HEAD__SECTION_CK, AUG_POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_HEAD__MINIMUM_HEAD_PREMIUM,
    first_value(AUG_POLICY_PREMIUM_HEAD__PREMIUM_ADJUSTMENT_AMOUNT) ignore nulls over (partition by POLICY_BK, AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK, AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK, AUG_POLICY_PREMIUM_HEAD__SECTION_CK, AUG_POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_HEAD__PREMIUM_ADJUSTMENT_AMOUNT,
    first_value(AUG_POLICY_PREMIUM_HEAD__PREMIUM_RATE) ignore nulls over (partition by POLICY_BK, AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK, AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK, AUG_POLICY_PREMIUM_HEAD__SECTION_CK, AUG_POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_HEAD__PREMIUM_RATE,
    first_value(AUG_POLICY_PREMIUM_HEAD__SECTION_APPLICABLE_INDICATOR) ignore nulls over (partition by POLICY_BK, AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK, AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK, AUG_POLICY_PREMIUM_HEAD__SECTION_CK, AUG_POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_HEAD__SECTION_APPLICABLE_INDICATOR,
    AUG_POLICY_PREMIUM_SETTLEMENT__SETTLEMENT_LINE_SEQUENCE_CK,
    AUG_POLICY_PREMIUM_SETTLEMENT__SETTLEMENT_LINE_REFERENCE_CK,
    first_value(AUG_POLICY_PREMIUM_SETTLEMENT__ACCOUNTING_BATCH_REFERENCE) ignore nulls over (partition by POLICY_BK, AUG_POLICY_PREMIUM_SETTLEMENT__SETTLEMENT_LINE_SEQUENCE_CK, AUG_POLICY_PREMIUM_SETTLEMENT__SETTLEMENT_LINE_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_SETTLEMENT__ACCOUNTING_BATCH_REFERENCE,
    first_value(AUG_POLICY_PREMIUM_SETTLEMENT__ACCOUNTING_PASS_INDICATOR) ignore nulls over (partition by POLICY_BK, AUG_POLICY_PREMIUM_SETTLEMENT__SETTLEMENT_LINE_SEQUENCE_CK, AUG_POLICY_PREMIUM_SETTLEMENT__SETTLEMENT_LINE_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_SETTLEMENT__ACCOUNTING_PASS_INDICATOR,
    first_value(AUG_POLICY_PREMIUM_SETTLEMENT__ACCOUNTING_POSTING_DATE) ignore nulls over (partition by POLICY_BK, AUG_POLICY_PREMIUM_SETTLEMENT__SETTLEMENT_LINE_SEQUENCE_CK, AUG_POLICY_PREMIUM_SETTLEMENT__SETTLEMENT_LINE_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_SETTLEMENT__ACCOUNTING_POSTING_DATE,
    first_value(AUG_POLICY_RENEWAL__BANK_PARTNER_VERSION_MARKER) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_RENEWAL__BANK_PARTNER_VERSION_MARKER,
    first_value(AUG_POLICY_RENEWAL__DIRECT_MARKETING_LOCATION_CODE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_RENEWAL__DIRECT_MARKETING_LOCATION_CODE,
    first_value(AUG_POLICY_RENEWAL__DOCUMENT_DISPATCH_INDICATOR) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_RENEWAL__DOCUMENT_DISPATCH_INDICATOR,
    first_value(AUG_POLICY_RENEWAL__EXPIRING_POLICY_CLAIM_RATIO) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_RENEWAL__EXPIRING_POLICY_CLAIM_RATIO,
    first_value(AUG_POLICY_RENEWAL__EXPIRING_POLICY_INCURRED_CLAIM_RATIO) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_RENEWAL__EXPIRING_POLICY_INCURRED_CLAIM_RATIO,
    first_value(AUG_POLICY_RENEWAL__LAST_ENDORSEMENT_DATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_RENEWAL__LAST_ENDORSEMENT_DATE,
    first_value(AUG_POLICY_RENEWAL__POLICY_CANCELLATION_REASON) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_RENEWAL__POLICY_CANCELLATION_REASON,
    first_value(AUG_POLICY_RENEWAL__PREVIOUS_POLICY_TERM) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_RENEWAL__PREVIOUS_POLICY_TERM,
    first_value(AUG_POLICY_RENEWAL__PREVIOUS_VEHICLE_MAKE_CODE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_RENEWAL__PREVIOUS_VEHICLE_MAKE_CODE,
    first_value(AUG_POLICY_RENEWAL__PREVIOUS_VEHICLE_MODEL_CODE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_RENEWAL__PREVIOUS_VEHICLE_MODEL_CODE,
    first_value(AUG_POLICY_RENEWAL__PREVIOUS_VEHICLE_REGISTRATION_NUMBER) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_RENEWAL__PREVIOUS_VEHICLE_REGISTRATION_NUMBER,
    first_value(AUG_POLICY_RENEWAL__PREVIOUS_VEHICLE_SUB_TYPE_CODE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_RENEWAL__PREVIOUS_VEHICLE_SUB_TYPE_CODE,
    first_value(AUG_POLICY_RENEWAL__PREVIOUS_VEHICLE_TYPE_CODE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_RENEWAL__PREVIOUS_VEHICLE_TYPE_CODE,
    first_value(AUG_POLICY_RENEWAL__PROFITABILITY_INDICATOR) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_RENEWAL__PROFITABILITY_INDICATOR,
    first_value(AUG_POLICY_RENEWAL__PROSPECT_REFERENCE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_RENEWAL__PROSPECT_REFERENCE,
    first_value(AUG_POLICY_RENEWAL__QUALITY_CHECK_STATUS) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_RENEWAL__QUALITY_CHECK_STATUS,
    first_value(AUG_POLICY_RENEWAL__RENEWAL_CHANNEL) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_RENEWAL__RENEWAL_CHANNEL,
    first_value(AUG_POLICY_RENEWAL__RENEWAL_GROSS_PREMIUM) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_RENEWAL__RENEWAL_GROSS_PREMIUM,
    first_value(AUG_POLICY_RENEWAL__RENEWAL_NOTICE_DOCUMENT_REFERENCE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_RENEWAL__RENEWAL_NOTICE_DOCUMENT_REFERENCE,
    first_value(AUG_POLICY_RENEWAL__RENEWAL_NOTICE_PRINTED_INDICATOR) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_RENEWAL__RENEWAL_NOTICE_PRINTED_INDICATOR,
    first_value(AUG_POLICY_RENEWAL__RENEWAL_NOTICE_REFERENCE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_RENEWAL__RENEWAL_NOTICE_REFERENCE,
    first_value(AUG_POLICY_RENEWAL__RENEWAL_NOTICE_REGENERATED_DATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_RENEWAL__RENEWAL_NOTICE_REGENERATED_DATE,
    first_value(AUG_POLICY_RENEWAL__RENEWAL_NOTICE_REGENERATED_INDICATOR) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_RENEWAL__RENEWAL_NOTICE_REGENERATED_INDICATOR,
    first_value(AUG_POLICY_RENEWAL__RENEWAL_POLICY_NUMBER) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_RENEWAL__RENEWAL_POLICY_NUMBER,
    first_value(AUG_POLICY_RENEWAL__RENEWAL_PRICED_INDICATOR) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_RENEWAL__RENEWAL_PRICED_INDICATOR,
    first_value(AUG_POLICY_RENEWAL__RENEWAL_REGENERATED_INDICATOR) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_RENEWAL__RENEWAL_REGENERATED_INDICATOR,
    first_value(AUG_POLICY_RENEWAL__RENEWAL_REGENERATION_DATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_RENEWAL__RENEWAL_REGENERATION_DATE,
    first_value(AUG_POLICY_RENEWAL__RENEWAL_TARIFF_RATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_RENEWAL__RENEWAL_TARIFF_RATE,
    first_value(AUG_POLICY_RENEWAL__RENEWED_INTO_POLICY_REFERENCE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_RENEWAL__RENEWED_INTO_POLICY_REFERENCE,
    first_value(AUG_POLICY_RENEWAL__RENEWED_POLICY_REFERENCE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_RENEWAL__RENEWED_POLICY_REFERENCE,
    first_value(AUG_POLICY_RENEWAL__UNDERWRITING_PROFITABILITY_INDICATOR) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_RENEWAL__UNDERWRITING_PROFITABILITY_INDICATOR,
    first_value(AUG_POLICY_RENEWAL__UNIFIED_RENEWAL_STATUS) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_RENEWAL__UNIFIED_RENEWAL_STATUS,
    AUG_RISK_MOTOR_ADDON__ADD_ON_CODE_CK,
    first_value(AUG_RISK_MOTOR_ADDON__ADD_ON_DISCOUNT_AMOUNT) ignore nulls over (partition by RISK_OBJECT_BK, AUG_RISK_MOTOR_ADDON__ADD_ON_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_ADDON__ADD_ON_DISCOUNT_AMOUNT,
    first_value(AUG_RISK_MOTOR_ADDON__DEVIATED_ADD_ON_PREMIUM) ignore nulls over (partition by RISK_OBJECT_BK, AUG_RISK_MOTOR_ADDON__ADD_ON_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_ADDON__DEVIATED_ADD_ON_PREMIUM,
    AUG_RISK_MOTOR_FITMENTS__FITMENT_TYPE_CK,
    AUG_RISK_MOTOR_FITMENTS__SEQUENCE_CK,
    first_value(AUG_RISK_MOTOR_FITMENTS__SYSTEM_CALCULATED_FITMENT_VALUE) ignore nulls over (partition by RISK_OBJECT_BK, AUG_RISK_MOTOR_FITMENTS__FITMENT_TYPE_CK, AUG_RISK_MOTOR_FITMENTS__SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_FITMENTS__SYSTEM_CALCULATED_FITMENT_VALUE,
    first_value(COMMON_STATUS__STATUS_CODE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_STATUS__STATUS_CODE,
    LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
    first_value(LNK_ROLE_CUSTOMER__VIP_INDICATOR) ignore nulls over (partition by PARTY_BK, LNK_ROLE_CUSTOMER__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
    first_value(POLICY_RENEWAL__CANCELLED_POLICY_INDICATOR) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_RENEWAL__CANCELLED_POLICY_INDICATOR,
    first_value(POLICY_RENEWAL__PRECEDING_POLICY_REFERENCE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_RENEWAL__PRECEDING_POLICY_REFERENCE,
    first_value(POLICY_RENEWAL__RENEWAL_BLOCK_REASON) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_RENEWAL__RENEWAL_BLOCK_REASON,
    first_value(POLICY_RENEWAL__RENEWAL_DISCOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_RENEWAL__RENEWAL_DISCOUNT,
    first_value(POLICY_RENEWAL__RENEWAL_PREMIUM) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_RENEWAL__RENEWAL_PREMIUM,
    first_value(POLICY_RENEWAL__RENEWAL_STATUS) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_RENEWAL__RENEWAL_STATUS,
    -- the row's own source time: LOAD_DATETIME for hubs, links and single-active satellites
    m.INC_JOB_UPDATED_AT,
    -- SAT_AUG_POLICY_PREMIUM_HEAD (ma_sat): one load time per POLICY_BK, so all its child rows share it
    max(case when coalesce(m.AUG_POLICY_PREMIUM_HEAD__ADJUSTMENT_REMARKS, m.AUG_POLICY_PREMIUM_HEAD__DISCOUNT_PERCENTAGE, m.AUG_POLICY_PREMIUM_HEAD__HEAD_PREMIUM_RATE, m.AUG_POLICY_PREMIUM_HEAD__LOADING_PERCENTAGE, m.AUG_POLICY_PREMIUM_HEAD__MINIMUM_HEAD_PREMIUM, m.AUG_POLICY_PREMIUM_HEAD__PREMIUM_ADJUSTMENT_AMOUNT, m.AUG_POLICY_PREMIUM_HEAD__PREMIUM_RATE, m.AUG_POLICY_PREMIUM_HEAD__SECTION_APPLICABLE_INDICATOR) is not null
             then m.INC_JOB_UPDATED_AT end)
        over (partition by m.POLICY_BK) as AUG_POLICY_PREMIUM_HEAD__LOAD_DATETIME,
    -- SAT_AUG_POLICY_PREMIUM_SETTLEMENT (ma_sat): one load time per POLICY_BK, so all its child rows share it
    max(case when coalesce(m.AUG_POLICY_PREMIUM_SETTLEMENT__ACCOUNTING_BATCH_REFERENCE, m.AUG_POLICY_PREMIUM_SETTLEMENT__ACCOUNTING_PASS_INDICATOR, m.AUG_POLICY_PREMIUM_SETTLEMENT__ACCOUNTING_POSTING_DATE) is not null
             then m.INC_JOB_UPDATED_AT end)
        over (partition by m.POLICY_BK) as AUG_POLICY_PREMIUM_SETTLEMENT__LOAD_DATETIME,
    -- SAT_AUG_RISK_MOTOR_ADDON (ma_sat): one load time per RISK_OBJECT_BK, so all its child rows share it
    max(case when coalesce(m.AUG_RISK_MOTOR_ADDON__ADD_ON_DISCOUNT_AMOUNT, m.AUG_RISK_MOTOR_ADDON__DEVIATED_ADD_ON_PREMIUM) is not null
             then m.INC_JOB_UPDATED_AT end)
        over (partition by m.RISK_OBJECT_BK) as AUG_RISK_MOTOR_ADDON__LOAD_DATETIME,
    -- SAT_AUG_RISK_MOTOR_FITMENTS (ma_sat): one load time per RISK_OBJECT_BK, so all its child rows share it
    max(case when m.AUG_RISK_MOTOR_FITMENTS__SYSTEM_CALCULATED_FITMENT_VALUE is not null
             then m.INC_JOB_UPDATED_AT end)
        over (partition by m.RISK_OBJECT_BK) as AUG_RISK_MOTOR_FITMENTS__LOAD_DATETIME,
    -- SAT_LNK_ROLE_CUSTOMER (ma_sat): one load time per PARTY_BK, so all its child rows share it
    max(case when m.LNK_ROLE_CUSTOMER__VIP_INDICATOR is not null
             then m.INC_JOB_UPDATED_AT end)
        over (partition by m.PARTY_BK) as LNK_ROLE_CUSTOMER__LOAD_DATETIME
from merged m
