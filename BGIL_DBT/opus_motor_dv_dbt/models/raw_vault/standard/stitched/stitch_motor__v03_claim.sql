-- CENTRAL VIEW v03_claim -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   BJAZ_CLM_BASE_MOT_EXT
--   BJAZ_CLM_MOTOR_INTIM_DETAILS
--   BJAZ_CLM_MOT_TAX_DTLS
--   BJAZ_MOTORTHEFT_CASE_DTLS
--   BJAZ_MOT_CLM_CDC_DTLS
--   BJAZ_MOT_CLM_TRANS_EXTN
--   BJAZ_PAYMOTORTHEFT_DTLS
--   BJAZ_WB_CLM_BASE_MOT_EXT
--   BJAZ_WS_MOTCLM_DETAILS
--   BJAZ_WS_MOTCLM_SURVEY_DTLS
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_MOTOR_AUG_CLAIM_CO_RI_SHARE
--   SAT_MOTOR_AUG_CLAIM_RECOVERY_SALVAGE
--   SAT_MOTOR_AUG_CLAIM_SETTLEMENT
--   SAT_MOTOR_AUG_FINTXN_CLAIM_PAYMENT
--   SAT_CLAIM_MOTOR_DETAIL
--   SAT_CLAIM_RESERVE
--   SAT_CLAIM_SALVAGE_BIDDER
--   SAT_CLAIM_SETTLEMENT
--   SAT_COMMON_MONETARY_CONTEXT
--   SAT_FINTXN_CLAIM_PAYMENT
--   SAT_LNK_PARTY_ROLE_CORE
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_CASE_POLICY
--   LNK_CLAIM_CASE
--   LNK_CLAIM_POLICY
--   LNK_CLAIM_RISK_OBJECT
--   LNK_FINTXN_CLAIM
--   LNK_POLICY_ORG_UNIT
--   LNK_POLICY_RISK_OBJECT
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: BJAZ_CLM_BASE_MOT_EXT
    select
        cast(null as varchar) as CASE_BK,
        nullif(nullif(trim(to_char(t0.claim_id)), ''), '') as CLAIM_BK,
        cast(null as varchar) as FINANCIAL_TRANSACTION_BK,
        cast(null as varchar) as ORG_UNIT_BK,
        cast(null as varchar) as PARTY_BK,
        cast(null as varchar) as POLICY_BK,
        cast(null as varchar) as RISK_OBJECT_BK,
        cast(null as number) as __LNK_CASE_POLICY,
        cast(null as number) as __LNK_CLAIM_CASE,
        cast(null as number) as __LNK_CLAIM_POLICY,
        cast(null as number) as __LNK_CLAIM_RISK_OBJECT,
        cast(null as number) as __LNK_FINTXN_CLAIM,
        cast(null as number) as __LNK_POLICY_ORG_UNIT,
        cast(null as number) as __LNK_POLICY_RISK_OBJECT,
        cast(null as varchar) as AUG_CLAIM_CO_RI_SHARE__CO_INSURANCE_RECOVERY_AMOUNT,
        cast(null as varchar) as AUG_CLAIM_CO_RI_SHARE__REINSURANCE_ENDORSEMENT_NUMBER,
        t0.reins_exp_date as AUG_CLAIM_CO_RI_SHARE__REINSURANCE_EXPIRY_DATE,
        cast(null as varchar) as AUG_CLAIM_CO_RI_SHARE__REINSURANCE_PREMIUM_AMOUNT,
        cast(null as varchar) as AUG_CLAIM_RECOVERY_SALVAGE__BENCHMARK_AVERAGE_SOLD_AMOUNT,
        cast(null as varchar) as AUG_CLAIM_RECOVERY_SALVAGE__BENCHMARK_HIGHEST_SOLD_AMOUNT,
        cast(null as varchar) as AUG_CLAIM_RECOVERY_SALVAGE__BEST_SALVAGE_QUOTATION_AMOUNT,
        t0.indemnity_rec_bond as AUG_CLAIM_RECOVERY_SALVAGE__INDEMNITY_BOND_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_RECOVERY_SALVAGE__OTHER_DEDUCTION_AMOUNT,
        cast(null as varchar) as AUG_CLAIM_RECOVERY_SALVAGE__RECOVERED_VEHICLE_CONDITION,
        cast(null as varchar) as AUG_CLAIM_RECOVERY_SALVAGE__RECOVERY_POLICE_STATION_NAME,
        cast(null as varchar) as AUG_CLAIM_RECOVERY_SALVAGE__RECOVERY_TYPE,
        cast(null as varchar) as AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_AUCTION_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_BIDDING_END_DATE,
        cast(null as varchar) as AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_BIDDING_START_DATE,
        cast(null as varchar) as AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_PROCEEDS_INSTRUMENT_DATE,
        cast(null as varchar) as AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_PROCEEDS_INSTRUMENT_DETAILS,
        cast(null as varchar) as AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_PROCEEDS_PAYMENT_MODE,
        cast(null as varchar) as AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_PROCEEDS_RECEIPT_DATE,
        cast(null as varchar) as AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_PROCEEDS_RECEIPT_DETAILS,
        cast(null as varchar) as AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_REALISATION_PERCENTAGE,
        cast(null as varchar) as AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_RETAINED_BY_INSURED_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_TRANSACTION_YEAR,
        cast(null as varchar) as AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_TYPE,
        cast(null as varchar) as AUG_CLAIM_RECOVERY_SALVAGE__SCRAP_DISPOSAL_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_RECOVERY_SALVAGE__VEHICLE_RECOVERY_DATE,
        cast(null as varchar) as AUG_CLAIM_SETTLEMENT__AML_WAIVER_REASON,
        cast(null as varchar) as AUG_CLAIM_SETTLEMENT__INTEREST_RATE_PERCENTAGE,
        cast(null as varchar) as AUG_CLAIM_SETTLEMENT__NEFT_DETAILS_VERIFIED_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_SETTLEMENT__OTSP_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_SETTLEMENT__OTSP_REASON,
        cast(null as varchar) as AUG_CLAIM_SETTLEMENT__SETTLEMENT_FILE_NUMBER,
        cast(null as varchar) as AUG_FINTXN_CLAIM_PAYMENT__CHEQUE_ISSUE_REASON,
        cast(null as varchar) as AUG_FINTXN_CLAIM_PAYMENT__EXCHANGE_GAIN_LOSS_AMOUNT,
        cast(null as varchar) as AUG_FINTXN_CLAIM_PAYMENT__FOREIGN_CURRENCY_INDICATOR,
        cast(null as varchar) as AUG_FINTXN_CLAIM_PAYMENT__LOCAL_PAYMENT_INDICATOR,
        cast(null as varchar) as AUG_FINTXN_CLAIM_PAYMENT__NCB_RECOVERY_AMOUNT,
        cast(null as varchar) as AUG_FINTXN_CLAIM_PAYMENT__PAYEE_BANK_BRANCH_CODE,
        cast(null as varchar) as AUG_FINTXN_CLAIM_PAYMENT__PAYEE_BANK_CODE,
        cast(null as varchar) as AUG_FINTXN_CLAIM_PAYMENT__PAYMENT_REQUEST_REFERENCE,
        cast(null as varchar) as AUG_FINTXN_CLAIM_PAYMENT__SUPPORTING_INVOICE_DATE,
        t0.time_of_loss as CLAIM_MOTOR_DETAIL__ACCIDENT_TIME,
        cast(null as varchar) as CLAIM_MOTOR_DETAIL__DAMAGED_PARTS_DESCRIPTION,
        cast(null as varchar) as CLAIM_MOTOR_DETAIL__DAMAGE_DESCRIPTION,
        cast(null as varchar) as CLAIM_MOTOR_DETAIL__DAMAGE_TYPE,
        cast(null as varchar) as CLAIM_MOTOR_DETAIL__DRIVER_LICENCE_NUMBER,
        cast(null as varchar) as CLAIM_MOTOR_DETAIL__DRIVER_NAME,
        t0.driver_insured_status as CLAIM_MOTOR_DETAIL__DRIVER_TYPE,
        cast(null as varchar) as CLAIM_MOTOR_DETAIL__ENGINE_DAMAGE_INDICATOR,
        cast(null as varchar) as CLAIM_MOTOR_DETAIL__ESTIMATED_LABOUR_AMOUNT,
        cast(null as varchar) as CLAIM_MOTOR_DETAIL__ESTIMATED_OTHER_COST_AMOUNT,
        cast(null as varchar) as CLAIM_MOTOR_DETAIL__ESTIMATED_PARTS_AMOUNT,
        cast(null as varchar) as CLAIM_MOTOR_DETAIL__FIBRE_PARTS_AMOUNT,
        cast(null as varchar) as CLAIM_MOTOR_DETAIL__GARAGE_REFERENCE,
        cast(null as varchar) as CLAIM_MOTOR_DETAIL__GLASS_PARTS_AMOUNT,
        cast(null as varchar) as CLAIM_MOTOR_DETAIL__IDV_AMOUNT,
        cast(null as varchar) as CLAIM_MOTOR_DETAIL__INVALID_CARRIAGE_INDICATOR,
        cast(null as varchar) as CLAIM_MOTOR_DETAIL__LABOUR_AMOUNT,
        cast(null as varchar) as CLAIM_MOTOR_DETAIL__PAINT_AMOUNT,
        cast(null as varchar) as CLAIM_MOTOR_DETAIL__REPAIR_ESTIMATE_AMOUNT,
        cast(null as varchar) as CLAIM_MOTOR_DETAIL__REPAIR_ESTIMATE_DATE,
        cast(null as varchar) as CLAIM_MOTOR_DETAIL__REPAIR_ESTIMATE_REFERENCE,
        cast(null as varchar) as CLAIM_MOTOR_DETAIL__THIRD_PARTY_CLAIM_INDICATOR,
        cast(null as varchar) as CLAIM_MOTOR_DETAIL__TOTAL_LOSS_INDICATOR,
        t0.tyre_damage_yn as CLAIM_MOTOR_DETAIL__TYRE_DAMAGE_INDICATOR,
        cast(null as varchar) as CLAIM_MOTOR_DETAIL__VEHICLE_LEFT_AT_REPAIRER_INDICATOR,
        cast(null as varchar) as CLAIM_MOTOR_DETAIL__VEHICLE_LOADED_INDICATOR,
        cast(null as varchar) as CLAIM_MOTOR_DETAIL__VEHICLE_PARKED_INDICATOR,
        cast(null as varchar) as CLAIM_MOTOR_DETAIL__WHEEL_RIM_DAMAGE_INDICATOR,
        cast(null as varchar) as CLAIM_MOTOR_DETAIL__WINDSHIELD_DAMAGE_CODE,
        cast(null as varchar) as CLAIM_MOTOR_DETAIL__WORKSHOP_REPAIR_STATUS,
        cast(null as varchar) as CLAIM_RESERVE__RESERVE_HEAD_CK,
        cast(null as varchar) as CLAIM_RESERVE__CURRENT_RESERVE_AMOUNT,
        cast(null as varchar) as CLAIM_RESERVE__OUTSTANDING_RESERVE_AMOUNT,
        cast(null as varchar) as CLAIM_SALVAGE_BIDDER__BIDDER_SEQUENCE_CK,
        cast(null as varchar) as CLAIM_SALVAGE_BIDDER__BIDDER_NAME,
        cast(null as varchar) as CLAIM_SALVAGE_BIDDER__BID_AMOUNT,
        cast(null as varchar) as CLAIM_SALVAGE_BIDDER__BID_DATE,
        cast(null as varchar) as CLAIM_SETTLEMENT__AML_WAIVER_INDICATOR,
        cast(null as varchar) as CLAIM_SETTLEMENT__INTEREST_PAID_AMOUNT,
        cast(null as varchar) as CLAIM_SETTLEMENT__PAYMENT_DUE_DATE,
        cast(null as varchar) as CLAIM_SETTLEMENT__SETTLEMENT_AMOUNT,
        cast(null as varchar) as CLAIM_SETTLEMENT__SETTLEMENT_TYPE,
        cast(null as varchar) as COMMON_MONETARY_CONTEXT__CURRENCY_CODE,
        cast(null as varchar) as COMMON_MONETARY_CONTEXT__EXCHANGE_RATE,
        cast(null as varchar) as FINTXN_CLAIM_PAYMENT__PAYMENT_MODE,
        cast(null as varchar) as FINTXN_CLAIM_PAYMENT__RECOVERY_AMOUNT,
        cast(null as varchar) as FINTXN_CLAIM_PAYMENT__SALVAGE_REALISATION_AMOUNT,
        cast(null as varchar) as LNK_PARTY_ROLE_CORE__ROLE_CODE_CK,
        cast(null as varchar) as LNK_PARTY_ROLE_CORE__ROLE_SEQUENCE_CK,
        cast(null as varchar) as LNK_PARTY_ROLE_CORE__ROLE_START_DATE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_clm_base_mot_ext') }} t0
    where (nullif(nullif(trim(to_char(t0.claim_id)), ''), '')) is not null

    union all

    -- branch 1: BJAZ_CLM_MOTOR_INTIM_DETAILS
    select
        null,
        nullif(nullif('INTIMATION:' || nullif(trim(t0.intimation_id), ''), 'INTIMATION:'), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.driver_license_no as CLAIM_MOTOR_DETAIL__DRIVER_LICENCE_NUMBER,
        t0.driver_name as CLAIM_MOTOR_DETAIL__DRIVER_NAME,
        null, null, null, null, null, null,
        t0.garage_id as CLAIM_MOTOR_DETAIL__GARAGE_REFERENCE,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.vehicle_left_yn as CLAIM_MOTOR_DETAIL__VEHICLE_LEFT_AT_REPAIRER_INDICATOR,
        null, null, null, null,
        t0.workshop_status as CLAIM_MOTOR_DETAIL__WORKSHOP_REPAIR_STATUS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_clm_motor_intim_details') }} t0
    where (nullif(nullif('INTIMATION:' || nullif(trim(t0.intimation_id), ''), 'INTIMATION:'), '')) is not null

    union all

    -- branch 2: BJAZ_CLM_MOT_TAX_DTLS
    select
        null,
        nullif(nullif(trim(to_char(t0.claim_id)), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        t0.vehicle_parked as CLAIM_MOTOR_DETAIL__VEHICLE_PARKED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_clm_mot_tax_dtls') }} t0
    where (nullif(nullif(trim(to_char(t0.claim_id)), ''), '')) is not null

    union all

    -- branch 3: BJAZ_MOTORTHEFT_CASE_DTLS
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        nullif(nullif(trim(to_char(t0.claim_id)), ''), '') as CLAIM_BK,
        null, null, null, null, null, null,
        1 as __LNK_CLAIM_CASE,
        null, null, null, null, null, null, null, null, null,
        t0.average_sold_amount as AUG_CLAIM_RECOVERY_SALVAGE__BENCHMARK_AVERAGE_SOLD_AMOUNT,
        t0.highest_sold_amount as AUG_CLAIM_RECOVERY_SALVAGE__BENCHMARK_HIGHEST_SOLD_AMOUNT,
        t0.best_quote as AUG_CLAIM_RECOVERY_SALVAGE__BEST_SALVAGE_QUOTATION_AMOUNT,
        null,
        t0.other_deductions as AUG_CLAIM_RECOVERY_SALVAGE__OTHER_DEDUCTION_AMOUNT,
        t0.vehicle_condition as AUG_CLAIM_RECOVERY_SALVAGE__RECOVERED_VEHICLE_CONDITION,
        t0.recovered_police_stn as AUG_CLAIM_RECOVERY_SALVAGE__RECOVERY_POLICE_STATION_NAME,
        null,
        t0.bid_number as AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_AUCTION_REFERENCE,
        t0.bid_end_date as AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_BIDDING_END_DATE,
        t0.bid_start_date as AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_BIDDING_START_DATE,
        t0.dd_date as AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_PROCEEDS_INSTRUMENT_DATE,
        t0.dd_detail as AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_PROCEEDS_INSTRUMENT_DETAILS,
        t0.pay_mode as AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_PROCEEDS_PAYMENT_MODE,
        t0.receiept_date as AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_PROCEEDS_RECEIPT_DATE,
        t0.receiept_detail as AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_PROCEEDS_RECEIPT_DETAILS,
        t0.realization_pre as AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_REALISATION_PERCENTAGE,
        null,
        t0.year_of_transaction as AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_TRANSACTION_YEAR,
        null,
        t0.scrap_flag as AUG_CLAIM_RECOVERY_SALVAGE__SCRAP_DISPOSAL_INDICATOR,
        t0.recovery_date as AUG_CLAIM_RECOVERY_SALVAGE__VEHICLE_RECOVERY_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        coalesce(t0.external_bidder1, t0.external_bidder2, t0.external_bidder3, t0.highest_bidder_name) as CLAIM_SALVAGE_BIDDER__BIDDER_NAME,
        coalesce(t0.external_bidder1_amt, t0.external_bidder2_amt, t0.external_bidder3_amt, t0.highest_bidder_amount) as CLAIM_SALVAGE_BIDDER__BID_AMOUNT,
        coalesce(t0.external_rcvd_date1, t0.external_rcvd_date2, t0.external_rcvd_date3) as CLAIM_SALVAGE_BIDDER__BID_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (coalesce(nullif(nullif(trim(t0.case_id), ''), ''), nullif(nullif(trim(to_char(t0.claim_id)), ''), ''))) is not null

    union all

    -- branch 4: BJAZ_MOTORTHEFT_CASE_DTLS | child-key literal(s): LNK_PARTY_ROLE_CORE.Role Code=ADVOCATE
    select
        null, null, null, null,
        nullif(nullif(trim(regexp_replace(upper(nullif(coalesce(t0.adv_name, '') || '|' || coalesce(t0.adv_email, '') || '|' || coalesce(t0.adv_contact, ''), '||')), '[[:space:]]+', ' ')), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'ADVOCATE' as LNK_PARTY_ROLE_CORE__ROLE_CODE_CK,
        null,
        t0.adv_assign_date as LNK_PARTY_ROLE_CORE__ROLE_START_DATE,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_motortheft_case_dtls') }} t0
    where (nullif(nullif(trim(regexp_replace(upper(nullif(coalesce(t0.adv_name, '') || '|' || coalesce(t0.adv_email, '') || '|' || coalesce(t0.adv_contact, ''), '||')), '[[:space:]]+', ' ')), ''), '')) is not null

    union all

    -- branch 5: BJAZ_MOT_CLM_CDC_DTLS
    select
        null,
        nullif(nullif(trim(t0.claim_ref), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.engine as CLAIM_MOTOR_DETAIL__ENGINE_DAMAGE_INDICATOR,
        null, null, null, null, null, null, null,
        t0.invalid_carriag as CLAIM_MOTOR_DETAIL__INVALID_CARRIAGE_INDICATOR,
        null, null, null, null, null, null,
        t0.total_loss as CLAIM_MOTOR_DETAIL__TOTAL_LOSS_INDICATOR,
        null, null, null, null,
        t0.wheel_rim as CLAIM_MOTOR_DETAIL__WHEEL_RIM_DAMAGE_INDICATOR,
        t0.windshield_code as CLAIM_MOTOR_DETAIL__WINDSHIELD_DAMAGE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_clm_cdc_dtls') }} t0
    where (nullif(nullif(trim(t0.claim_ref), ''), '')) is not null

    union all

    -- branch 6: BJAZ_MOT_CLM_TRANS_EXTN
    select
        null,
        nullif(nullif(trim(to_char(t0.claim_id)), ''), '') as CLAIM_BK,
        nullif(nullif('CLMTXN:' || nullif(trim(to_char(t0.trans_no)), ''), 'CLMTXN:'), '') as FINANCIAL_TRANSACTION_BK,
        null, null, null, null, null, null, null, null,
        1 as __LNK_FINTXN_CLAIM,
        null, null,
        t0.coins_recovery_amt as AUG_CLAIM_CO_RI_SHARE__CO_INSURANCE_RECOVERY_AMOUNT,
        null, null,
        t0.reins_premium as AUG_CLAIM_CO_RI_SHARE__REINSURANCE_PREMIUM_AMOUNT,
        null, null, null, null, null, null, null,
        t0.type_of_recovery as AUG_CLAIM_RECOVERY_SALVAGE__RECOVERY_TYPE,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.type_of_salvage as AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_TYPE,
        null, null, null,
        t0.interest_perc as AUG_CLAIM_SETTLEMENT__INTEREST_RATE_PERCENTAGE,
        null, null, null,
        t0.sf_no as AUG_CLAIM_SETTLEMENT__SETTLEMENT_FILE_NUMBER,
        t0.reason_for_chq as AUG_FINTXN_CLAIM_PAYMENT__CHEQUE_ISSUE_REASON,
        t0.exchange_gain_amt as AUG_FINTXN_CLAIM_PAYMENT__EXCHANGE_GAIN_LOSS_AMOUNT,
        t0.foreign_curr_flag as AUG_FINTXN_CLAIM_PAYMENT__FOREIGN_CURRENCY_INDICATOR,
        t0.pay_local as AUG_FINTXN_CLAIM_PAYMENT__LOCAL_PAYMENT_INDICATOR,
        t0.ncb_recovery_amt as AUG_FINTXN_CLAIM_PAYMENT__NCB_RECOVERY_AMOUNT,
        t0.bank_branch_code as AUG_FINTXN_CLAIM_PAYMENT__PAYEE_BANK_BRANCH_CODE,
        t0.bank_code as AUG_FINTXN_CLAIM_PAYMENT__PAYEE_BANK_CODE,
        t0.request_id as AUG_FINTXN_CLAIM_PAYMENT__PAYMENT_REQUEST_REFERENCE,
        t0.invoice_date as AUG_FINTXN_CLAIM_PAYMENT__SUPPORTING_INVOICE_DATE,
        null,
        t0.damaged_object as CLAIM_MOTOR_DETAIL__DAMAGED_PARTS_DESCRIPTION,
        null,
        t0.damage_type as CLAIM_MOTOR_DETAIL__DAMAGE_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.interest_amt as CLAIM_SETTLEMENT__INTEREST_PAID_AMOUNT,
        t0.payment_due_date as CLAIM_SETTLEMENT__PAYMENT_DUE_DATE,
        null, null,
        t0.exchange_rate_curr as COMMON_MONETARY_CONTEXT__CURRENCY_CODE,
        t0.exchange_rate as COMMON_MONETARY_CONTEXT__EXCHANGE_RATE,
        t0.payment_mode as FINTXN_CLAIM_PAYMENT__PAYMENT_MODE,
        t0.recovery_amt as FINTXN_CLAIM_PAYMENT__RECOVERY_AMOUNT,
        t0.salvage_amt as FINTXN_CLAIM_PAYMENT__SALVAGE_REALISATION_AMOUNT,
        null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_clm_trans_extn') }} t0
    where (coalesce(nullif(nullif('CLMTXN:' || nullif(trim(to_char(t0.trans_no)), ''), 'CLMTXN:'), ''), nullif(nullif(trim(to_char(t0.claim_id)), ''), ''))) is not null

    union all

    -- branch 7: BJAZ_MOT_CLM_TRANS_EXTN | child-key literal(s): CLAIM_RESERVE.Reserve Head=AVAILABLE_RSV_AMT
    select
        null,
        nullif(nullif(trim(to_char(t0.claim_id)), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        'AVAILABLE_RSV_AMT' as CLAIM_RESERVE__RESERVE_HEAD_CK,
        null,
        t0.available_rsv_amt as CLAIM_RESERVE__OUTSTANDING_RESERVE_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_mot_clm_trans_extn') }} t0
    where (nullif(nullif(trim(to_char(t0.claim_id)), ''), '')) is not null

    union all

    -- branch 8: BJAZ_PAYMOTORTHEFT_DTLS
    select
        nullif(nullif(trim(t0.case_id), ''), '') as CASE_BK,
        nullif(nullif(trim(to_char(t0.claim_id)), ''), '') as CLAIM_BK,
        null,
        nullif(nullif(trim(to_char(t0.ho_id)), ''), '') as ORG_UNIT_BK,
        null,
        nullif(nullif(trim(t0.policy_ref), ''), '') as POLICY_BK,
        nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), '') as RISK_OBJECT_BK,
        1 as __LNK_CASE_POLICY,
        1 as __LNK_CLAIM_CASE,
        1 as __LNK_CLAIM_POLICY,
        1 as __LNK_CLAIM_RISK_OBJECT,
        null,
        1 as __LNK_POLICY_ORG_UNIT,
        1 as __LNK_POLICY_RISK_OBJECT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        t0.idv as CLAIM_MOTOR_DETAIL__IDV_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.paid_amount as CLAIM_SETTLEMENT__SETTLEMENT_AMOUNT,
        null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_paymotortheft_dtls') }} t0
    where (coalesce(nullif(coalesce(nullif(trim(t0.chassis_no), ''), nullif(trim(t0.registration_no), '')), ''), nullif(nullif(trim(t0.case_id), ''), ''), nullif(nullif(trim(t0.policy_ref), ''), ''), nullif(nullif(trim(to_char(t0.claim_id)), ''), ''), nullif(nullif(trim(to_char(t0.ho_id)), ''), ''))) is not null

    union all

    -- branch 9: BJAZ_WB_CLM_BASE_MOT_EXT
    select
        null,
        nullif(nullif(trim(to_char(t0.claim_id)), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.reins_endorse_no as AUG_CLAIM_CO_RI_SHARE__REINSURANCE_ENDORSEMENT_NUMBER,
        t0.reins_exp_date as AUG_CLAIM_CO_RI_SHARE__REINSURANCE_EXPIRY_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.salvage_retain as AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_RETAINED_BY_INSURED_INDICATOR,
        null, null, null, null,
        t0.aml_waiver_reason as AUG_CLAIM_SETTLEMENT__AML_WAIVER_REASON,
        null,
        t0.neft_check as AUG_CLAIM_SETTLEMENT__NEFT_DETAILS_VERIFIED_INDICATOR,
        t0.otsp_flag as AUG_CLAIM_SETTLEMENT__OTSP_INDICATOR,
        t0.otsp_reason as AUG_CLAIM_SETTLEMENT__OTSP_REASON,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.partdamage as CLAIM_MOTOR_DETAIL__DAMAGED_PARTS_DESCRIPTION,
        t0.col_desc as CLAIM_MOTOR_DETAIL__DAMAGE_DESCRIPTION,
        null, null,
        t0.whodrive as CLAIM_MOTOR_DETAIL__DRIVER_NAME,
        t0.driver_insured_status as CLAIM_MOTOR_DETAIL__DRIVER_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.tp_claim as CLAIM_MOTOR_DETAIL__THIRD_PARTY_CLAIM_INDICATOR,
        null, null, null,
        t0.vehicle_loaded as CLAIM_MOTOR_DETAIL__VEHICLE_LOADED_INDICATOR,
        null, null, null,
        t0.workshop_status as CLAIM_MOTOR_DETAIL__WORKSHOP_REPAIR_STATUS,
        null, null, null, null, null, null, null,
        t0.aml_waiver as CLAIM_SETTLEMENT__AML_WAIVER_INDICATOR,
        null, null, null,
        t0.settlement_type as CLAIM_SETTLEMENT__SETTLEMENT_TYPE,
        null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_wb_clm_base_mot_ext') }} t0
    where (nullif(nullif(trim(to_char(t0.claim_id)), ''), '')) is not null

    union all

    -- branch 10: BJAZ_WS_MOTCLM_DETAILS
    select
        null,
        nullif(nullif(trim(to_char(t0.clm_ref_id)), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.labour_est_amt as CLAIM_MOTOR_DETAIL__ESTIMATED_LABOUR_AMOUNT,
        t0.misc_est_amt as CLAIM_MOTOR_DETAIL__ESTIMATED_OTHER_COST_AMOUNT,
        t0.total_part_est_mat as CLAIM_MOTOR_DETAIL__ESTIMATED_PARTS_AMOUNT,
        null,
        t0.work_shop_id as CLAIM_MOTOR_DETAIL__GARAGE_REFERENCE,
        t0.glass_parts_est_amt as CLAIM_MOTOR_DETAIL__GLASS_PARTS_AMOUNT,
        null, null, null,
        t0.paint_est_amt as CLAIM_MOTOR_DETAIL__PAINT_AMOUNT,
        t0.est_amount as CLAIM_MOTOR_DETAIL__REPAIR_ESTIMATE_AMOUNT,
        t0.estimate_date as CLAIM_MOTOR_DETAIL__REPAIR_ESTIMATE_DATE,
        t0.estimation_no as CLAIM_MOTOR_DETAIL__REPAIR_ESTIMATE_REFERENCE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_ws_motclm_details') }} t0
    where (nullif(nullif(trim(to_char(t0.clm_ref_id)), ''), '')) is not null

    union all

    -- branch 11: BJAZ_WS_MOTCLM_DETAILS | child-key literal(s): CLAIM_RESERVE.Reserve Head=PROVISION_AMT
    select
        null,
        nullif(nullif(trim(to_char(t0.clm_ref_id)), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        'PROVISION_AMT' as CLAIM_RESERVE__RESERVE_HEAD_CK,
        t0.provision_amt as CLAIM_RESERVE__CURRENT_RESERVE_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_ws_motclm_details') }} t0
    where (nullif(nullif(trim(to_char(t0.clm_ref_id)), ''), '')) is not null

    union all

    -- branch 12: BJAZ_WS_MOTCLM_SURVEY_DTLS
    select
        null,
        nullif(nullif(trim(t0.clm_ref), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.plastic_parts_asd_amt as CLAIM_MOTOR_DETAIL__FIBRE_PARTS_AMOUNT,
        null,
        t0.glasd_parts_asd_amt as CLAIM_MOTOR_DETAIL__GLASS_PARTS_AMOUNT,
        null, null,
        t0.labour_asd_amt as CLAIM_MOTOR_DETAIL__LABOUR_AMOUNT,
        t0.painting_asd_amt as CLAIM_MOTOR_DETAIL__PAINT_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        t0.inc_job_updated_at as INC_JOB_UPDATED_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_motor__bjaz_ws_motclm_survey_dtls') }} t0
    where (nullif(nullif(trim(t0.clm_ref), ''), '')) is not null

)

select
    CASE_BK,
    CLAIM_BK,
    FINANCIAL_TRANSACTION_BK,
    ORG_UNIT_BK,
    PARTY_BK,
    POLICY_BK,
    RISK_OBJECT_BK,
    __LNK_CASE_POLICY,
    __LNK_CLAIM_CASE,
    __LNK_CLAIM_POLICY,
    __LNK_CLAIM_RISK_OBJECT,
    __LNK_FINTXN_CLAIM,
    __LNK_POLICY_ORG_UNIT,
    __LNK_POLICY_RISK_OBJECT,
    first_value(AUG_CLAIM_CO_RI_SHARE__CO_INSURANCE_RECOVERY_AMOUNT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_CO_RI_SHARE__CO_INSURANCE_RECOVERY_AMOUNT,
    first_value(AUG_CLAIM_CO_RI_SHARE__REINSURANCE_ENDORSEMENT_NUMBER) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_CO_RI_SHARE__REINSURANCE_ENDORSEMENT_NUMBER,
    first_value(AUG_CLAIM_CO_RI_SHARE__REINSURANCE_EXPIRY_DATE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_CO_RI_SHARE__REINSURANCE_EXPIRY_DATE,
    first_value(AUG_CLAIM_CO_RI_SHARE__REINSURANCE_PREMIUM_AMOUNT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_CO_RI_SHARE__REINSURANCE_PREMIUM_AMOUNT,
    first_value(AUG_CLAIM_RECOVERY_SALVAGE__BENCHMARK_AVERAGE_SOLD_AMOUNT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_RECOVERY_SALVAGE__BENCHMARK_AVERAGE_SOLD_AMOUNT,
    first_value(AUG_CLAIM_RECOVERY_SALVAGE__BENCHMARK_HIGHEST_SOLD_AMOUNT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_RECOVERY_SALVAGE__BENCHMARK_HIGHEST_SOLD_AMOUNT,
    first_value(AUG_CLAIM_RECOVERY_SALVAGE__BEST_SALVAGE_QUOTATION_AMOUNT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_RECOVERY_SALVAGE__BEST_SALVAGE_QUOTATION_AMOUNT,
    first_value(AUG_CLAIM_RECOVERY_SALVAGE__INDEMNITY_BOND_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_RECOVERY_SALVAGE__INDEMNITY_BOND_INDICATOR,
    first_value(AUG_CLAIM_RECOVERY_SALVAGE__OTHER_DEDUCTION_AMOUNT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_RECOVERY_SALVAGE__OTHER_DEDUCTION_AMOUNT,
    first_value(AUG_CLAIM_RECOVERY_SALVAGE__RECOVERED_VEHICLE_CONDITION) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_RECOVERY_SALVAGE__RECOVERED_VEHICLE_CONDITION,
    first_value(AUG_CLAIM_RECOVERY_SALVAGE__RECOVERY_POLICE_STATION_NAME) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_RECOVERY_SALVAGE__RECOVERY_POLICE_STATION_NAME,
    first_value(AUG_CLAIM_RECOVERY_SALVAGE__RECOVERY_TYPE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_RECOVERY_SALVAGE__RECOVERY_TYPE,
    first_value(AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_AUCTION_REFERENCE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_AUCTION_REFERENCE,
    first_value(AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_BIDDING_END_DATE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_BIDDING_END_DATE,
    first_value(AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_BIDDING_START_DATE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_BIDDING_START_DATE,
    first_value(AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_PROCEEDS_INSTRUMENT_DATE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_PROCEEDS_INSTRUMENT_DATE,
    first_value(AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_PROCEEDS_INSTRUMENT_DETAILS) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_PROCEEDS_INSTRUMENT_DETAILS,
    first_value(AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_PROCEEDS_PAYMENT_MODE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_PROCEEDS_PAYMENT_MODE,
    first_value(AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_PROCEEDS_RECEIPT_DATE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_PROCEEDS_RECEIPT_DATE,
    first_value(AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_PROCEEDS_RECEIPT_DETAILS) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_PROCEEDS_RECEIPT_DETAILS,
    first_value(AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_REALISATION_PERCENTAGE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_REALISATION_PERCENTAGE,
    first_value(AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_RETAINED_BY_INSURED_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_RETAINED_BY_INSURED_INDICATOR,
    first_value(AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_TRANSACTION_YEAR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_TRANSACTION_YEAR,
    first_value(AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_TYPE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_TYPE,
    first_value(AUG_CLAIM_RECOVERY_SALVAGE__SCRAP_DISPOSAL_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_RECOVERY_SALVAGE__SCRAP_DISPOSAL_INDICATOR,
    first_value(AUG_CLAIM_RECOVERY_SALVAGE__VEHICLE_RECOVERY_DATE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_RECOVERY_SALVAGE__VEHICLE_RECOVERY_DATE,
    first_value(AUG_CLAIM_SETTLEMENT__AML_WAIVER_REASON) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_SETTLEMENT__AML_WAIVER_REASON,
    first_value(AUG_CLAIM_SETTLEMENT__INTEREST_RATE_PERCENTAGE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_SETTLEMENT__INTEREST_RATE_PERCENTAGE,
    first_value(AUG_CLAIM_SETTLEMENT__NEFT_DETAILS_VERIFIED_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_SETTLEMENT__NEFT_DETAILS_VERIFIED_INDICATOR,
    first_value(AUG_CLAIM_SETTLEMENT__OTSP_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_SETTLEMENT__OTSP_INDICATOR,
    first_value(AUG_CLAIM_SETTLEMENT__OTSP_REASON) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_SETTLEMENT__OTSP_REASON,
    first_value(AUG_CLAIM_SETTLEMENT__SETTLEMENT_FILE_NUMBER) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_SETTLEMENT__SETTLEMENT_FILE_NUMBER,
    first_value(AUG_FINTXN_CLAIM_PAYMENT__CHEQUE_ISSUE_REASON) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_CLAIM_PAYMENT__CHEQUE_ISSUE_REASON,
    first_value(AUG_FINTXN_CLAIM_PAYMENT__EXCHANGE_GAIN_LOSS_AMOUNT) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_CLAIM_PAYMENT__EXCHANGE_GAIN_LOSS_AMOUNT,
    first_value(AUG_FINTXN_CLAIM_PAYMENT__FOREIGN_CURRENCY_INDICATOR) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_CLAIM_PAYMENT__FOREIGN_CURRENCY_INDICATOR,
    first_value(AUG_FINTXN_CLAIM_PAYMENT__LOCAL_PAYMENT_INDICATOR) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_CLAIM_PAYMENT__LOCAL_PAYMENT_INDICATOR,
    first_value(AUG_FINTXN_CLAIM_PAYMENT__NCB_RECOVERY_AMOUNT) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_CLAIM_PAYMENT__NCB_RECOVERY_AMOUNT,
    first_value(AUG_FINTXN_CLAIM_PAYMENT__PAYEE_BANK_BRANCH_CODE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_CLAIM_PAYMENT__PAYEE_BANK_BRANCH_CODE,
    first_value(AUG_FINTXN_CLAIM_PAYMENT__PAYEE_BANK_CODE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_CLAIM_PAYMENT__PAYEE_BANK_CODE,
    first_value(AUG_FINTXN_CLAIM_PAYMENT__PAYMENT_REQUEST_REFERENCE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_CLAIM_PAYMENT__PAYMENT_REQUEST_REFERENCE,
    first_value(AUG_FINTXN_CLAIM_PAYMENT__SUPPORTING_INVOICE_DATE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_CLAIM_PAYMENT__SUPPORTING_INVOICE_DATE,
    first_value(CLAIM_MOTOR_DETAIL__ACCIDENT_TIME) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_MOTOR_DETAIL__ACCIDENT_TIME,
    first_value(CLAIM_MOTOR_DETAIL__DAMAGED_PARTS_DESCRIPTION) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_MOTOR_DETAIL__DAMAGED_PARTS_DESCRIPTION,
    first_value(CLAIM_MOTOR_DETAIL__DAMAGE_DESCRIPTION) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_MOTOR_DETAIL__DAMAGE_DESCRIPTION,
    first_value(CLAIM_MOTOR_DETAIL__DAMAGE_TYPE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_MOTOR_DETAIL__DAMAGE_TYPE,
    first_value(CLAIM_MOTOR_DETAIL__DRIVER_LICENCE_NUMBER) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_MOTOR_DETAIL__DRIVER_LICENCE_NUMBER,
    first_value(CLAIM_MOTOR_DETAIL__DRIVER_NAME) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_MOTOR_DETAIL__DRIVER_NAME,
    first_value(CLAIM_MOTOR_DETAIL__DRIVER_TYPE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_MOTOR_DETAIL__DRIVER_TYPE,
    first_value(CLAIM_MOTOR_DETAIL__ENGINE_DAMAGE_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_MOTOR_DETAIL__ENGINE_DAMAGE_INDICATOR,
    first_value(CLAIM_MOTOR_DETAIL__ESTIMATED_LABOUR_AMOUNT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_MOTOR_DETAIL__ESTIMATED_LABOUR_AMOUNT,
    first_value(CLAIM_MOTOR_DETAIL__ESTIMATED_OTHER_COST_AMOUNT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_MOTOR_DETAIL__ESTIMATED_OTHER_COST_AMOUNT,
    first_value(CLAIM_MOTOR_DETAIL__ESTIMATED_PARTS_AMOUNT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_MOTOR_DETAIL__ESTIMATED_PARTS_AMOUNT,
    first_value(CLAIM_MOTOR_DETAIL__FIBRE_PARTS_AMOUNT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_MOTOR_DETAIL__FIBRE_PARTS_AMOUNT,
    first_value(CLAIM_MOTOR_DETAIL__GARAGE_REFERENCE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_MOTOR_DETAIL__GARAGE_REFERENCE,
    first_value(CLAIM_MOTOR_DETAIL__GLASS_PARTS_AMOUNT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_MOTOR_DETAIL__GLASS_PARTS_AMOUNT,
    first_value(CLAIM_MOTOR_DETAIL__IDV_AMOUNT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_MOTOR_DETAIL__IDV_AMOUNT,
    first_value(CLAIM_MOTOR_DETAIL__INVALID_CARRIAGE_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_MOTOR_DETAIL__INVALID_CARRIAGE_INDICATOR,
    first_value(CLAIM_MOTOR_DETAIL__LABOUR_AMOUNT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_MOTOR_DETAIL__LABOUR_AMOUNT,
    first_value(CLAIM_MOTOR_DETAIL__PAINT_AMOUNT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_MOTOR_DETAIL__PAINT_AMOUNT,
    first_value(CLAIM_MOTOR_DETAIL__REPAIR_ESTIMATE_AMOUNT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_MOTOR_DETAIL__REPAIR_ESTIMATE_AMOUNT,
    first_value(CLAIM_MOTOR_DETAIL__REPAIR_ESTIMATE_DATE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_MOTOR_DETAIL__REPAIR_ESTIMATE_DATE,
    first_value(CLAIM_MOTOR_DETAIL__REPAIR_ESTIMATE_REFERENCE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_MOTOR_DETAIL__REPAIR_ESTIMATE_REFERENCE,
    first_value(CLAIM_MOTOR_DETAIL__THIRD_PARTY_CLAIM_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_MOTOR_DETAIL__THIRD_PARTY_CLAIM_INDICATOR,
    first_value(CLAIM_MOTOR_DETAIL__TOTAL_LOSS_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_MOTOR_DETAIL__TOTAL_LOSS_INDICATOR,
    first_value(CLAIM_MOTOR_DETAIL__TYRE_DAMAGE_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_MOTOR_DETAIL__TYRE_DAMAGE_INDICATOR,
    first_value(CLAIM_MOTOR_DETAIL__VEHICLE_LEFT_AT_REPAIRER_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_MOTOR_DETAIL__VEHICLE_LEFT_AT_REPAIRER_INDICATOR,
    first_value(CLAIM_MOTOR_DETAIL__VEHICLE_LOADED_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_MOTOR_DETAIL__VEHICLE_LOADED_INDICATOR,
    first_value(CLAIM_MOTOR_DETAIL__VEHICLE_PARKED_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_MOTOR_DETAIL__VEHICLE_PARKED_INDICATOR,
    first_value(CLAIM_MOTOR_DETAIL__WHEEL_RIM_DAMAGE_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_MOTOR_DETAIL__WHEEL_RIM_DAMAGE_INDICATOR,
    first_value(CLAIM_MOTOR_DETAIL__WINDSHIELD_DAMAGE_CODE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_MOTOR_DETAIL__WINDSHIELD_DAMAGE_CODE,
    first_value(CLAIM_MOTOR_DETAIL__WORKSHOP_REPAIR_STATUS) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_MOTOR_DETAIL__WORKSHOP_REPAIR_STATUS,
    CLAIM_RESERVE__RESERVE_HEAD_CK,
    first_value(CLAIM_RESERVE__CURRENT_RESERVE_AMOUNT) ignore nulls over (partition by CLAIM_BK, CLAIM_RESERVE__RESERVE_HEAD_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_RESERVE__CURRENT_RESERVE_AMOUNT,
    first_value(CLAIM_RESERVE__OUTSTANDING_RESERVE_AMOUNT) ignore nulls over (partition by CLAIM_BK, CLAIM_RESERVE__RESERVE_HEAD_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_RESERVE__OUTSTANDING_RESERVE_AMOUNT,
    CLAIM_SALVAGE_BIDDER__BIDDER_SEQUENCE_CK,
    first_value(CLAIM_SALVAGE_BIDDER__BIDDER_NAME) ignore nulls over (partition by CLAIM_BK, CLAIM_SALVAGE_BIDDER__BIDDER_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_SALVAGE_BIDDER__BIDDER_NAME,
    first_value(CLAIM_SALVAGE_BIDDER__BID_AMOUNT) ignore nulls over (partition by CLAIM_BK, CLAIM_SALVAGE_BIDDER__BIDDER_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_SALVAGE_BIDDER__BID_AMOUNT,
    first_value(CLAIM_SALVAGE_BIDDER__BID_DATE) ignore nulls over (partition by CLAIM_BK, CLAIM_SALVAGE_BIDDER__BIDDER_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_SALVAGE_BIDDER__BID_DATE,
    first_value(CLAIM_SETTLEMENT__AML_WAIVER_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_SETTLEMENT__AML_WAIVER_INDICATOR,
    first_value(CLAIM_SETTLEMENT__INTEREST_PAID_AMOUNT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_SETTLEMENT__INTEREST_PAID_AMOUNT,
    first_value(CLAIM_SETTLEMENT__PAYMENT_DUE_DATE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_SETTLEMENT__PAYMENT_DUE_DATE,
    first_value(CLAIM_SETTLEMENT__SETTLEMENT_AMOUNT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_SETTLEMENT__SETTLEMENT_AMOUNT,
    first_value(CLAIM_SETTLEMENT__SETTLEMENT_TYPE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_SETTLEMENT__SETTLEMENT_TYPE,
    first_value(COMMON_MONETARY_CONTEXT__CURRENCY_CODE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_MONETARY_CONTEXT__CURRENCY_CODE,
    first_value(COMMON_MONETARY_CONTEXT__EXCHANGE_RATE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_MONETARY_CONTEXT__EXCHANGE_RATE,
    first_value(FINTXN_CLAIM_PAYMENT__PAYMENT_MODE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_CLAIM_PAYMENT__PAYMENT_MODE,
    first_value(FINTXN_CLAIM_PAYMENT__RECOVERY_AMOUNT) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_CLAIM_PAYMENT__RECOVERY_AMOUNT,
    first_value(FINTXN_CLAIM_PAYMENT__SALVAGE_REALISATION_AMOUNT) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_CLAIM_PAYMENT__SALVAGE_REALISATION_AMOUNT,
    LNK_PARTY_ROLE_CORE__ROLE_CODE_CK,
    LNK_PARTY_ROLE_CORE__ROLE_SEQUENCE_CK,
    first_value(LNK_PARTY_ROLE_CORE__ROLE_START_DATE) ignore nulls over (partition by PARTY_BK, LNK_PARTY_ROLE_CORE__ROLE_CODE_CK, LNK_PARTY_ROLE_CORE__ROLE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_PARTY_ROLE_CORE__ROLE_START_DATE,
    -- the row's own source time: LOAD_DATETIME for hubs, links and single-active satellites
    m.INC_JOB_UPDATED_AT,
    -- multi-active satellites on CLAIM_BK (SAT_CLAIM_RESERVE, SAT_CLAIM_SALVAGE_BIDDER):
    -- one load time per CLAIM_BK, the newest INC_JOB_UPDATED_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when coalesce(m.CLAIM_RESERVE__CURRENT_RESERVE_AMOUNT, m.CLAIM_RESERVE__OUTSTANDING_RESERVE_AMOUNT, m.CLAIM_SALVAGE_BIDDER__BIDDER_NAME, m.CLAIM_SALVAGE_BIDDER__BID_AMOUNT, m.CLAIM_SALVAGE_BIDDER__BID_DATE) is not null
             then m.INC_JOB_UPDATED_AT end)
        over (partition by m.CLAIM_BK) as CLAIM_BK__MA_LOAD_DATETIME,
    -- multi-active satellites on PARTY_BK (SAT_LNK_PARTY_ROLE_CORE):
    -- one load time per PARTY_BK, the newest INC_JOB_UPDATED_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when m.LNK_PARTY_ROLE_CORE__ROLE_START_DATE is not null
             then m.INC_JOB_UPDATED_AT end)
        over (partition by m.PARTY_BK) as PARTY_BK__MA_LOAD_DATETIME
from merged m
