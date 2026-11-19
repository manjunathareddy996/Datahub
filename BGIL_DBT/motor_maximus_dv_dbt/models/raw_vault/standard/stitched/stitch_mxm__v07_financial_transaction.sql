-- CENTRAL VIEW v07_financial_transaction -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_PAYMENT
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_PAYMENT_PAYMENTPROPERTY_PIVOT_VW
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PAYMENT_INFORMATION
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
-- Walk tables, joined only to resolve spine keys (not counted):
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_PAYMENT_PAYMENTPROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_MOTOR_AUG_COVERAGE_DEFINITION
--   SAT_MOTOR_AUG_FINTXN_CLAIM_PAYMENT
--   SAT_MOTOR_AUG_FINTXN_TAX
--   SAT_MOTOR_AUG_POLICY_PREMIUM_HEAD
--   SAT_COVERAGE_DEFINITION
--   SAT_FINTXN_HEADER
--   SAT_FINTXN_TAX
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_POLICY_COVERAGE
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_PAYMENT
    select
        cast(null as varchar) as COVERAGE_BK,
        nullif(nullif(trim(t0.claimpaymentid), ''), '') as FINANCIAL_TRANSACTION_BK,
        cast(null as varchar) as POLICY_BK,
        cast(null as number) as __LNK_POLICY_COVERAGE,
        cast(null as varchar) as AUG_COVERAGE_DEFINITION__COVERAGE_DURATION,
        cast(null as varchar) as AUG_COVERAGE_DEFINITION__COVERAGE_EXPIRY_DATE,
        cast(null as varchar) as AUG_COVERAGE_DEFINITION__COVERAGE_INCEPTION_DATE,
        cast(null as varchar) as AUG_COVERAGE_DEFINITION__EVENT_BASED_INDICATOR,
        cast(null as varchar) as AUG_COVERAGE_DEFINITION__FACULTATIVE_REINSURANCE_INDICATOR,
        cast(null as varchar) as AUG_COVERAGE_DEFINITION__LEADING_COVERAGE_INDICATOR,
        cast(null as varchar) as AUG_FINTXN_CLAIM_PAYMENT__AOL_MODE,
        cast(null as varchar) as AUG_FINTXN_CLAIM_PAYMENT__CLAIM_EXPENSE_PAYMENT_MODE,
        cast(null as varchar) as AUG_FINTXN_CLAIM_PAYMENT__INSTRUMENT_PAYABLE_AT_LOCATION,
        cast(null as varchar) as AUG_FINTXN_CLAIM_PAYMENT__INSTRUMENT_PRINT_LOCATION_CODE,
        cast(null as varchar) as AUG_FINTXN_CLAIM_PAYMENT__INTEREST_AMOUNT,
        cast(null as varchar) as AUG_FINTXN_CLAIM_PAYMENT__INTERIM_OR_FINAL_PAYMENT_INDICATOR,
        cast(null as varchar) as AUG_FINTXN_CLAIM_PAYMENT__NCB_RECOVERY_AMOUNT,
        cast(null as varchar) as AUG_FINTXN_CLAIM_PAYMENT__NEFT_STATUS,
        cast(null as varchar) as AUG_FINTXN_CLAIM_PAYMENT__OWN_DAMAGE_PAYMENT_MODE,
        t0.payreservetypre as AUG_FINTXN_CLAIM_PAYMENT__PAID_AGAINST_RESERVE_TYPE,
        t0.approvedby as AUG_FINTXN_CLAIM_PAYMENT__PAYMENT_APPROVED_BY_USER_REFERENCE,
        cast(null as varchar) as AUG_FINTXN_CLAIM_PAYMENT__PAYMENT_AUTHORISATION_DATE,
        cast(null as varchar) as AUG_FINTXN_CLAIM_PAYMENT__PAYMENT_DETAIL_TEXT,
        cast(null as varchar) as AUG_FINTXN_CLAIM_PAYMENT__PAYMENT_GROUP_CODE,
        cast(null as varchar) as AUG_FINTXN_CLAIM_PAYMENT__PAYMENT_MODE_OTHER_REMARKS,
        cast(null as varchar) as AUG_FINTXN_CLAIM_PAYMENT__PAYMENT_MODE_REMARKS,
        t0.paymentpurpose as AUG_FINTXN_CLAIM_PAYMENT__PAYMENT_PURPOSE,
        t0.payindicator as AUG_FINTXN_CLAIM_PAYMENT__PAYMENT_RELEASED_INDICATOR,
        cast(null as varchar) as AUG_FINTXN_CLAIM_PAYMENT__POLICY_SECTION_CODE,
        cast(null as varchar) as AUG_FINTXN_CLAIM_PAYMENT__PORTAL_PAYMENT_REFERENCE_NUMBER,
        cast(null as varchar) as AUG_FINTXN_CLAIM_PAYMENT__SUPPORTING_INVOICE_MODE,
        cast(null as varchar) as AUG_FINTXN_CLAIM_PAYMENT__SUPPORTING_INVOICE_NUMBER,
        cast(null as varchar) as AUG_FINTXN_CLAIM_PAYMENT__UTR_DATE,
        cast(null as varchar) as AUG_FINTXN_TAX__TAX_TYPE_CK,
        cast(null as varchar) as AUG_FINTXN_TAX__TAX_PAYMENT_CYCLE_REFERENCE_NUMBER,
        cast(null as varchar) as AUG_FINTXN_TAX__TDS_APPLICABILITY_BASIS,
        cast(null as varchar) as AUG_FINTXN_TAX__TDS_CERTIFICATE_REFERENCE,
        cast(null as varchar) as AUG_FINTXN_TAX__TDS_DEMAND_DRAFT_PAYABLE_AT,
        cast(null as varchar) as AUG_FINTXN_TAX__TDS_DEMAND_DRAFT_STATE,
        cast(null as varchar) as AUG_FINTXN_TAX__TDS_NON_DEDUCTION_INDICATOR,
        cast(null as varchar) as AUG_FINTXN_TAX__TDS_NON_DEDUCTION_REASON,
        cast(null as varchar) as AUG_FINTXN_TAX__TDS_ON_INTEREST_AMOUNT,
        cast(null as varchar) as AUG_FINTXN_TAX__TDS_PAYMENT_MODE,
        cast(null as varchar) as AUG_FINTXN_TAX__TDS_PORTAL_PAYMENT_REFERENCE_NUMBER,
        cast(null as varchar) as AUG_FINTXN_TAX__TDS_SEPARATE_CHEQUE_INDICATOR,
        cast(null as varchar) as AUG_FINTXN_TAX__TDS_SEPARATE_PAYMENT_INDICATOR,
        cast(null as varchar) as AUG_FINTXN_TAX__TDS_SOURCE_SYSTEM_REFERENCE_NUMBER,
        cast(null as varchar) as AUG_FINTXN_TAX__TDS_WAIVER_INDICATOR,
        cast(null as varchar) as AUG_FINTXN_TAX__TDS_WAIVER_REASON,
        cast(null as varchar) as AUG_FINTXN_TAX__TOTAL_GST_RATE,
        cast(null as varchar) as AUG_FINTXN_TAX__UTGST_AMOUNT,
        cast(null as varchar) as AUG_FINTXN_TAX__UTGST_RATE,
        cast(null as varchar) as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        cast(null as varchar) as AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        cast(null as varchar) as AUG_POLICY_PREMIUM_HEAD__SECTION_CK,
        cast(null as varchar) as AUG_POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK,
        cast(null as varchar) as AUG_POLICY_PREMIUM_HEAD__EARNED_HEAD_PREMIUM,
        cast(null as varchar) as AUG_POLICY_PREMIUM_HEAD__EXCHANGE_RATE_APPLIED,
        cast(null as varchar) as AUG_POLICY_PREMIUM_HEAD__EXPIRING_PREMIUM_AMOUNT,
        cast(null as varchar) as AUG_POLICY_PREMIUM_HEAD__FIXED_PREMIUM_SYSTEM_CODE,
        cast(null as varchar) as AUG_POLICY_PREMIUM_HEAD__GROSS_HEAD_PREMIUM,
        cast(null as varchar) as AUG_POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM_IN_BASE_CURRENCY,
        cast(null as varchar) as AUG_POLICY_PREMIUM_HEAD__PREMIUM_ADJUSTMENT_AMOUNT,
        cast(null as varchar) as AUG_POLICY_PREMIUM_HEAD__PREMIUM_ADJUSTMENT_TYPE,
        cast(null as varchar) as AUG_POLICY_PREMIUM_HEAD__PREMIUM_RATE_APPLIED,
        cast(null as varchar) as COVERAGE_DEFINITION__COVERAGE_DISPLAY_NAME,
        cast(null as varchar) as COVERAGE_DEFINITION__COVERAGE_NAME,
        cast(null as varchar) as COVERAGE_DEFINITION__PERIL_COVERED,
        cast(null as varchar) as FINTXN_HEADER__APPROVAL_STATUS,
        cast(null as varchar) as FINTXN_HEADER__GROSS_AMOUNT,
        t0.remarks as FINTXN_HEADER__NARRATION,
        cast(null as varchar) as FINTXN_HEADER__SOURCE_REFERENCE_NUMBER,
        cast(null as varchar) as FINTXN_HEADER__SOURCE_REFERENCE_TYPE,
        cast(null as varchar) as FINTXN_HEADER__TAX_AMOUNT,
        cast(null as varchar) as FINTXN_HEADER__TRANSACTION_DATE,
        cast(null as varchar) as FINTXN_HEADER__TRANSACTION_NUMBER,
        cast(null as varchar) as FINTXN_HEADER__TRANSACTION_STATUS,
        cast(null as varchar) as FINTXN_HEADER__TRANSACTION_SUB_TYPE,
        cast(null as varchar) as FINTXN_HEADER__TRANSACTION_TYPE,
        cast(null as varchar) as FINTXN_TAX__TAX_TYPE_CK,
        cast(null as varchar) as FINTXN_TAX__CGST_AMOUNT,
        cast(null as varchar) as FINTXN_TAX__IGST_AMOUNT,
        cast(null as varchar) as FINTXN_TAX__SGST_AMOUNT,
        cast(null as varchar) as FINTXN_TAX__SGST_RATE,
        cast(null as varchar) as FINTXN_TAX__TAXABLE_VALUE,
        cast(null as varchar) as FINTXN_TAX__TAX_APPLICABLE_INDICATOR,
        cast(null as varchar) as FINTXN_TAX__TAX_INVOICE_DATE,
        cast(null as varchar) as FINTXN_TAX__TAX_INVOICE_NUMBER,
        cast(null as varchar) as FINTXN_TAX__TAX_RATE,
        cast(null as varchar) as FINTXN_TAX__TDS_AMOUNT,
        cast(null as varchar) as FINTXN_TAX__TDS_RATE,
        t0.rec_refresh_at as REC_REFRESH_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_payment') }} t0
    where (nullif(nullif(trim(t0.claimpaymentid), ''), '')) is not null

    union all

    -- branch 1: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_PAYMENT_PAYMENTPROPERTY_PIVOT_VW
    select
        null,
        nullif(nullif(trim(j2.claimpaymentid),''), '') as FINANCIAL_TRANSACTION_BK,
        null, null, null, null, null, null, null, null,
        t0.aol_mode as AUG_FINTXN_CLAIM_PAYMENT__AOL_MODE,
        null,
        t0.payable_at as AUG_FINTXN_CLAIM_PAYMENT__INSTRUMENT_PAYABLE_AT_LOCATION,
        t0.print_location_code as AUG_FINTXN_CLAIM_PAYMENT__INSTRUMENT_PRINT_LOCATION_CODE,
        t0.interest_amount as AUG_FINTXN_CLAIM_PAYMENT__INTEREST_AMOUNT,
        null, null, null, null, null, null,
        t0.payment_authorization_date as AUG_FINTXN_CLAIM_PAYMENT__PAYMENT_AUTHORISATION_DATE,
        null, null, null, null, null, null,
        t0.section as AUG_FINTXN_CLAIM_PAYMENT__POLICY_SECTION_CODE,
        null,
        t0.invoice_mode as AUG_FINTXN_CLAIM_PAYMENT__SUPPORTING_INVOICE_MODE,
        t0.invoice_no as AUG_FINTXN_CLAIM_PAYMENT__SUPPORTING_INVOICE_NUMBER,
        t0.utr_date as AUG_FINTXN_CLAIM_PAYMENT__UTR_DATE,
        'TDS' as AUG_FINTXN_TAX__TAX_TYPE_CK,
        null, null, null, null, null, null, null,
        t0.tds_on_interest as AUG_FINTXN_TAX__TDS_ON_INTEREST_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        t0.neft_approval as FINTXN_HEADER__APPROVAL_STATUS,
        t0.total_amount_including_taxtransaction_currency as FINTXN_HEADER__GROSS_AMOUNT,
        null,
        t0.reference_id as FINTXN_HEADER__SOURCE_REFERENCE_NUMBER,
        t0.reference_type as FINTXN_HEADER__SOURCE_REFERENCE_TYPE,
        null, null,
        t0.transactionid as FINTXN_HEADER__TRANSACTION_NUMBER,
        t0.payment_state as FINTXN_HEADER__TRANSACTION_STATUS,
        null,
        t0.payment_transaction_type as FINTXN_HEADER__TRANSACTION_TYPE,
        'GST' as FINTXN_TAX__TAX_TYPE_CK,
        t0.cgst_amount as FINTXN_TAX__CGST_AMOUNT,
        t0.igst_amount as FINTXN_TAX__IGST_AMOUNT,
        t0.sgst_amount as FINTXN_TAX__SGST_AMOUNT,
        null, null, null,
        t0.tax_invoice_date as FINTXN_TAX__TAX_INVOICE_DATE,
        t0.tax_invoice_number as FINTXN_TAX__TAX_INVOICE_NUMBER,
        t0.gst_percentage as FINTXN_TAX__TAX_RATE,
        null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_payment_paymentprop_pv') }} t0
    left join {{ ref('stg_mxm__clm_cd_claim_payment_paymentprop') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_payment') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.claimpaymentid),''), '')) is not null

    union all

    -- branch 2: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_PAYMENT_PAYMENTPROPERTY_PIVOT_VW
    select
        null,
        nullif(nullif(trim(j2.claimpaymentid),''), '') as FINANCIAL_TRANSACTION_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        'GST' as AUG_FINTXN_TAX__TAX_TYPE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.ugst_amount as AUG_FINTXN_TAX__UTGST_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        'TDS' as FINTXN_TAX__TAX_TYPE_CK,
        null, null, null, null, null, null, null, null, null,
        t0.tds_amount as FINTXN_TAX__TDS_AMOUNT,
        null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_payment_paymentprop_pv') }} t0
    left join {{ ref('stg_mxm__clm_cd_claim_payment_paymentprop') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_payment') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.claimpaymentid),''), '')) is not null

    union all

    -- branch 3: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_PAYMENT_PAYMENTPROPERTY_PIVOT_VW
    select
        null,
        nullif(nullif(trim(j2.claimpaymentid),''), '') as FINANCIAL_TRANSACTION_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        'VAT' as FINTXN_TAX__TAX_TYPE_CK,
        null, null, null, null, null,
        t0.vat_applicable as FINTXN_TAX__TAX_APPLICABLE_INDICATOR,
        null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_payment_paymentprop_pv') }} t0
    left join {{ ref('stg_mxm__clm_cd_claim_payment_paymentprop') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_payment') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.claimpaymentid),''), '')) is not null

    union all

    -- branch 4: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
    select
        null,
        nullif(nullif(trim('CLAIM-PAYMENT:' || nullif(trim(t0.payment_reference_no), '')), 'CLAIM-PAYMENT:'), '') as FINANCIAL_TRANSACTION_BK,
        null, null, null, null, null, null, null, null, null,
        t0.mode_of_paymentce as AUG_FINTXN_CLAIM_PAYMENT__CLAIM_EXPENSE_PAYMENT_MODE,
        null, null, null,
        t0.payment_type_interimfinal as AUG_FINTXN_CLAIM_PAYMENT__INTERIM_OR_FINAL_PAYMENT_INDICATOR,
        t0.ncb_recovery_amount as AUG_FINTXN_CLAIM_PAYMENT__NCB_RECOVERY_AMOUNT,
        t0.neft_status as AUG_FINTXN_CLAIM_PAYMENT__NEFT_STATUS,
        t0.mode_of_paymentod as AUG_FINTXN_CLAIM_PAYMENT__OWN_DAMAGE_PAYMENT_MODE,
        null, null,
        t0.payment_authorization_date as AUG_FINTXN_CLAIM_PAYMENT__PAYMENT_AUTHORISATION_DATE,
        t0.payment_details as AUG_FINTXN_CLAIM_PAYMENT__PAYMENT_DETAIL_TEXT,
        t0.payment_group as AUG_FINTXN_CLAIM_PAYMENT__PAYMENT_GROUP_CODE,
        t0.mode_of_payment_remarks_other as AUG_FINTXN_CLAIM_PAYMENT__PAYMENT_MODE_OTHER_REMARKS,
        t0.mode_of_payment_remarks as AUG_FINTXN_CLAIM_PAYMENT__PAYMENT_MODE_REMARKS,
        null, null, null,
        t0.portal_payment_reference_number as AUG_FINTXN_CLAIM_PAYMENT__PORTAL_PAYMENT_REFERENCE_NUMBER,
        null, null, null, null, null,
        t0.tds_applicability as AUG_FINTXN_TAX__TDS_APPLICABILITY_BASIS,
        t0.tds_certificate as AUG_FINTXN_TAX__TDS_CERTIFICATE_REFERENCE,
        t0.tds_dd_payable_at as AUG_FINTXN_TAX__TDS_DEMAND_DRAFT_PAYABLE_AT,
        t0.tds_dd_state as AUG_FINTXN_TAX__TDS_DEMAND_DRAFT_STATE,
        t0.tds_nondeduction_flag as AUG_FINTXN_TAX__TDS_NON_DEDUCTION_INDICATOR,
        t0.tds_nondeduction_reason as AUG_FINTXN_TAX__TDS_NON_DEDUCTION_REASON,
        null,
        t0.tds_mode_of_payment as AUG_FINTXN_TAX__TDS_PAYMENT_MODE,
        t0.tds_portal_payment_reference_number as AUG_FINTXN_TAX__TDS_PORTAL_PAYMENT_REFERENCE_NUMBER,
        t0.tds_separate_cheque_flag as AUG_FINTXN_TAX__TDS_SEPARATE_CHEQUE_INDICATOR,
        t0.tds_separate_payment_flag as AUG_FINTXN_TAX__TDS_SEPARATE_PAYMENT_INDICATOR,
        t0.tds_maximus_reference_no as AUG_FINTXN_TAX__TDS_SOURCE_SYSTEM_REFERENCE_NUMBER,
        t0.tds_waived_flag as AUG_FINTXN_TAX__TDS_WAIVER_INDICATOR,
        t0.tds_waived_reason as AUG_FINTXN_TAX__TDS_WAIVER_REASON,
        t0.total_gst_percentage as AUG_FINTXN_TAX__TOTAL_GST_RATE,
        t0.ugst as AUG_FINTXN_TAX__UTGST_AMOUNT,
        t0.ugst_percentage as AUG_FINTXN_TAX__UTGST_RATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.reference_text as FINTXN_HEADER__NARRATION,
        t0.reference_number as FINTXN_HEADER__SOURCE_REFERENCE_NUMBER,
        null,
        t0.tax_amount as FINTXN_HEADER__TAX_AMOUNT,
        null, null, null,
        t0.payment_transaction_type as FINTXN_HEADER__TRANSACTION_SUB_TYPE,
        t0.transaction_type as FINTXN_HEADER__TRANSACTION_TYPE,
        null, null, null,
        t0.sgst as FINTXN_TAX__SGST_AMOUNT,
        t0.sgst_percentage as FINTXN_TAX__SGST_RATE,
        t0.taxable_amount as FINTXN_TAX__TAXABLE_VALUE,
        t0.tds_applicable_flag as FINTXN_TAX__TAX_APPLICABLE_INDICATOR,
        null, null,
        t0.tax_rate as FINTXN_TAX__TAX_RATE,
        t0.tds_amount as FINTXN_TAX__TDS_AMOUNT,
        t0.tds_rate as FINTXN_TAX__TDS_RATE,
        t0.rec_refresh_at as REC_REFRESH_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop_pv') }} t0
    where (nullif(nullif(trim('CLAIM-PAYMENT:' || nullif(trim(t0.payment_reference_no), '')), 'CLAIM-PAYMENT:'), '')) is not null

    union all

    -- branch 5: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS
    select
        null, null,
        nullif(nullif(trim(j1.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'PREMIUM' as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null, null, null, null, null, null, null,
        t0.total_premium as AUG_POLICY_PREMIUM_HEAD__GROSS_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls') }} t0
    left join {{ ref('stg_mxm__uwr_pd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (nullif(nullif(trim(j1.policy_number), ''), '')) is not null

    union all

    -- branch 6: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS
    select
        nullif(nullif(trim(t0.cover_code),''), '') as COVERAGE_BK,
        null,
        nullif(nullif(trim(j2.policy_number),''), '') as POLICY_BK,
        1 as __LNK_POLICY_COVERAGE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PREMIUM' as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(t0.cover_code),'') as AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null, null, null,
        t0.total_premium as AUG_POLICY_PREMIUM_HEAD__GROSS_HEAD_PREMIUM,
        null, null, null, null, null,
        t0.cover_name as COVERAGE_DEFINITION__COVERAGE_NAME,
        t0.event_code as COVERAGE_DEFINITION__PERIL_COVERED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (coalesce(nullif(nullif(trim(j2.policy_number),''), ''), nullif(nullif(trim(t0.cover_code),''), ''))) is not null

    union all

    -- branch 7: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null,
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'EARNED_TOTAL_Y1' as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null,
        t0.final_earned_premium_1st_year as AUG_POLICY_PREMIUM_HEAD__EARNED_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_number), ''), '')) is not null

    union all

    -- branch 8: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null,
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'EARNED_SUB_TOTAL_1' as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null,
        t0.final_earned_premium_sub_total_1 as AUG_POLICY_PREMIUM_HEAD__EARNED_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_number), ''), '')) is not null

    union all

    -- branch 9: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null,
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'EARNED_SUB_TOTAL_10' as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null,
        t0.final_earned_premium_sub_total_10 as AUG_POLICY_PREMIUM_HEAD__EARNED_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_number), ''), '')) is not null

    union all

    -- branch 10: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null,
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'EARNED_SUB_TOTAL_11' as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null,
        t0.final_earned_premium_sub_total_11 as AUG_POLICY_PREMIUM_HEAD__EARNED_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_number), ''), '')) is not null

    union all

    -- branch 11: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null,
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'EARNED_SUB_TOTAL_12' as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null,
        t0.final_earned_premium_sub_total_12 as AUG_POLICY_PREMIUM_HEAD__EARNED_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_number), ''), '')) is not null

    union all

    -- branch 12: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null,
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'EARNED_SUB_TOTAL_13' as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null,
        t0.final_earned_premium_sub_total_13 as AUG_POLICY_PREMIUM_HEAD__EARNED_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_number), ''), '')) is not null

    union all

    -- branch 13: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null,
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'EARNED_SUB_TOTAL_14' as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null,
        t0.final_earned_premium_sub_total_14 as AUG_POLICY_PREMIUM_HEAD__EARNED_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_number), ''), '')) is not null

    union all

    -- branch 14: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null,
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'EARNED_SUB_TOTAL_15' as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null,
        t0.final_earned_premium_sub_total_15 as AUG_POLICY_PREMIUM_HEAD__EARNED_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_number), ''), '')) is not null

    union all

    -- branch 15: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null,
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'EARNED_SUB_TOTAL_2' as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null,
        t0.final_earned_premium_sub_total_2 as AUG_POLICY_PREMIUM_HEAD__EARNED_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_number), ''), '')) is not null

    union all

    -- branch 16: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null,
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'EARNED_SUB_TOTAL_3' as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null,
        t0.final_earned_premium_sub_total_3 as AUG_POLICY_PREMIUM_HEAD__EARNED_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_number), ''), '')) is not null

    union all

    -- branch 17: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null,
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'EARNED_SUB_TOTAL_4' as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null,
        t0.final_earned_premium_sub_total_4 as AUG_POLICY_PREMIUM_HEAD__EARNED_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_number), ''), '')) is not null

    union all

    -- branch 18: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null,
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'EARNED_SUB_TOTAL_5' as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null,
        t0.final_earned_premium_sub_total_5 as AUG_POLICY_PREMIUM_HEAD__EARNED_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_number), ''), '')) is not null

    union all

    -- branch 19: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null,
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'EARNED_SUB_TOTAL_6' as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null,
        t0.final_earned_premium_sub_total_6 as AUG_POLICY_PREMIUM_HEAD__EARNED_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_number), ''), '')) is not null

    union all

    -- branch 20: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null,
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'EARNED_SUB_TOTAL_7' as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null,
        t0.final_earned_premium_sub_total_7 as AUG_POLICY_PREMIUM_HEAD__EARNED_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_number), ''), '')) is not null

    union all

    -- branch 21: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null,
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'EARNED_SUB_TOTAL_8' as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null,
        t0.final_earned_premium_sub_total_8 as AUG_POLICY_PREMIUM_HEAD__EARNED_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_number), ''), '')) is not null

    union all

    -- branch 22: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null,
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'EARNED_SUB_TOTAL_9' as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null,
        t0.final_earned_premium_sub_total_9 as AUG_POLICY_PREMIUM_HEAD__EARNED_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_number), ''), '')) is not null

    union all

    -- branch 23: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null,
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'EARNED_NET_OD' as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_POLICY_PREMIUM_HEAD__SECTION_CK,
        null,
        t0.final_total_od_earned_premium as AUG_POLICY_PREMIUM_HEAD__EARNED_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_number), ''), '')) is not null

    union all

    -- branch 24: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null,
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'FIXED_SYSTEM_CD1' as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null, null,
        t0.fixed_premium_system_cd1 as AUG_POLICY_PREMIUM_HEAD__FIXED_PREMIUM_SYSTEM_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_number), ''), '')) is not null

    union all

    -- branch 25: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null,
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'FIXED_SYSTEM_CD2' as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null, null,
        t0.fixed_premium_system_cd2 as AUG_POLICY_PREMIUM_HEAD__FIXED_PREMIUM_SYSTEM_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_number), ''), '')) is not null

    union all

    -- branch 26: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null,
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'FIXED_SYSTEM_CD3' as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null, null,
        t0.fixed_premium_system_cd3 as AUG_POLICY_PREMIUM_HEAD__FIXED_PREMIUM_SYSTEM_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_number), ''), '')) is not null

    union all

    -- branch 27: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null,
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'FIXED_SYSTEM_CD4' as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null, null,
        t0.fixed_premium_system_cd4 as AUG_POLICY_PREMIUM_HEAD__FIXED_PREMIUM_SYSTEM_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_number), ''), '')) is not null

    union all

    -- branch 28: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null,
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'FIXED_SYSTEM_CD5' as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null, null,
        t0.fixed_premium_system_cd5 as AUG_POLICY_PREMIUM_HEAD__FIXED_PREMIUM_SYSTEM_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_number), ''), '')) is not null

    union all

    -- branch 29: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null,
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'COVER_FOREX_RATE' as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null,
        t0.forex_rate_at_cover_level as AUG_POLICY_PREMIUM_HEAD__EXCHANGE_RATE_APPLIED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_number), ''), '')) is not null

    union all

    -- branch 30: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null,
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'IMT44_RATE' as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null,
        t0.imt44_rate as AUG_POLICY_PREMIUM_HEAD__PREMIUM_RATE_APPLIED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_number), ''), '')) is not null

    union all

    -- branch 31: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null,
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'NDR_ADDON_RATE' as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'ADDON' as AUG_POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null,
        t0.ndr_addon_rate as AUG_POLICY_PREMIUM_HEAD__PREMIUM_RATE_APPLIED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_number), ''), '')) is not null

    union all

    -- branch 32: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null,
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'NF_ADDON_RATE' as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'ADDON' as AUG_POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null,
        t0.nf_addon_rate as AUG_POLICY_PREMIUM_HEAD__PREMIUM_RATE_APPLIED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_number), ''), '')) is not null

    union all

    -- branch 33: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null,
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'OLD' as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.old_premium as AUG_POLICY_PREMIUM_HEAD__EXPIRING_PREMIUM_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_number), ''), '')) is not null

    union all

    -- branch 34: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null,
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'PERIL_RATE' as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.peril_rate as AUG_POLICY_PREMIUM_HEAD__PREMIUM_RATE_APPLIED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_number), ''), '')) is not null

    union all

    -- branch 35: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null,
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'REVISED_EARNED_SUB_TOTAL_16_Y1' as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null,
        t0.rev_earned_premium_sub_total_16_1st_year as AUG_POLICY_PREMIUM_HEAD__EARNED_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_number), ''), '')) is not null

    union all

    -- branch 36: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null,
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'REVISED_FINAL_EARNED_SUB_TOTAL_16' as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null,
        t0.rev_final_earned_premium_sub_total_16 as AUG_POLICY_PREMIUM_HEAD__EARNED_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_number), ''), '')) is not null

    union all

    -- branch 37: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null,
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'BASIC_TP' as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as AUG_POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null,
        t0.tp_premium_rate as AUG_POLICY_PREMIUM_HEAD__PREMIUM_RATE_APPLIED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_number), ''), '')) is not null

    union all

    -- branch 38: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(coalesce(nullif(trim(t0.cover_code), ''), nullif(trim(t0.covercode), '')), '') as COVERAGE_BK,
        nullif(nullif(trim(t0.parent_payment_cycle_ref_no),''), '') as FINANCIAL_TRANSACTION_BK,
        nullif(nullif(trim(j4.policy_number),''), '') as POLICY_BK,
        null,
        t0.cover_duration as AUG_COVERAGE_DEFINITION__COVERAGE_DURATION,
        null, null,
        t0.event_based as AUG_COVERAGE_DEFINITION__EVENT_BASED_INDICATOR,
        t0.cover_level_fac_ri as AUG_COVERAGE_DEFINITION__FACULTATIVE_REINSURANCE_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'COVER_PREMIUM_BASE_CURRENCY' as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(t0.cover_code),'') as AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null, null, null, null,
        t0.cover_premium_in_base_currency as AUG_POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM_IN_BASE_CURRENCY,
        null, null, null,
        t0.coverage as COVERAGE_DEFINITION__COVERAGE_DISPLAY_NAME,
        t0.cover_name as COVERAGE_DEFINITION__COVERAGE_NAME,
        null, null,
        t0.parent_payment_amount as FINTXN_HEADER__GROSS_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (coalesce(nullif(coalesce(nullif(trim(t0.cover_code), ''), nullif(trim(t0.covercode), '')), ''), nullif(nullif(trim(j4.policy_number),''), ''), nullif(nullif(trim(t0.parent_payment_cycle_ref_no),''), ''))) is not null

    union all

    -- branch 39: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(t0.cover_code),''), '') as COVERAGE_BK,
        null,
        nullif(coalesce(nullif(trim(t0.policyquote_number),''), nullif(trim(j4.policy_number),'')), '') as POLICY_BK,
        null, null, null, null, null, null,
        t0.leading_cover as AUG_COVERAGE_DEFINITION__LEADING_COVERAGE_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        nullif(trim(t0.premium_adjustment_type),'') as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null, null, null, null, null, null, null, null, null,
        t0.premium_adjustment as AUG_POLICY_PREMIUM_HEAD__PREMIUM_ADJUSTMENT_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (coalesce(nullif(coalesce(nullif(trim(t0.policyquote_number),''), nullif(trim(j4.policy_number),'')), ''), nullif(nullif(trim(t0.cover_code),''), ''))) is not null

    union all

    -- branch 40: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null,
        nullif(coalesce(nullif(trim(t0.policyquote_number),''), nullif(trim(j4.policy_number),'')), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'PREMIUM_ADJUSTMENT_TYPE' as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(t0.cover_code),'') as AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null, null, null, null, null, null,
        t0.premium_adjustment_type as AUG_POLICY_PREMIUM_HEAD__PREMIUM_ADJUSTMENT_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(coalesce(nullif(trim(t0.policyquote_number),''), nullif(trim(j4.policy_number),'')), '')) is not null

    union all

    -- branch 41: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null,
        nullif(coalesce(nullif(trim(t0.policyquote_number),''), nullif(trim(j4.policy_number),'')), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'RATE_PERCENTAGE' as AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(t0.cover_code),'') as AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.rate_percentage as AUG_POLICY_PREMIUM_HEAD__PREMIUM_RATE_APPLIED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(coalesce(nullif(trim(t0.policyquote_number),''), nullif(trim(j4.policy_number),'')), '')) is not null

    union all

    -- branch 42: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PAYMENT_INFORMATION
    select
        null,
        nullif(nullif(trim(t0.transaction_id),''), '') as FINANCIAL_TRANSACTION_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.transaction_date as FINTXN_HEADER__TRANSACTION_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_policy_payment_info') }} t0
    where (nullif(nullif(trim(t0.transaction_id),''), '')) is not null

    union all

    -- branch 43: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER
    select
        nullif(nullif(trim('COV:' || coalesce(nullif(trim(j2.policy_quote_number), ''), '') || '|' || coalesce(nullif(trim(j1.pol_risk_id), ''), '') || '|' || coalesce(nullif(trim(t0.cover_code), ''), '')), 'COV:||'), '') as COVERAGE_BK,
        null, null, null, null,
        t0.cover_expiry_date as AUG_COVERAGE_DEFINITION__COVERAGE_EXPIRY_DATE,
        t0.cover_inception_date as AUG_COVERAGE_DEFINITION__COVERAGE_INCEPTION_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim('COV:' || coalesce(nullif(trim(j2.policy_quote_number), ''), '') || '|' || coalesce(nullif(trim(j1.pol_risk_id), ''), '') || '|' || coalesce(nullif(trim(t0.cover_code), ''), '')), 'COV:||'), '')) is not null

    union all

    -- branch 44: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
    select
        nullif(coalesce(nullif(trim(t0.cover_code), ''), nullif(trim(t0.covercode), '')), '') as COVERAGE_BK,
        nullif(nullif(trim(t0.parent_payment_cycle_ref_no),''), '') as FINANCIAL_TRANSACTION_BK,
        null, null,
        t0.cover_duration as AUG_COVERAGE_DEFINITION__COVERAGE_DURATION,
        null, null,
        t0.event_based as AUG_COVERAGE_DEFINITION__EVENT_BASED_INDICATOR,
        t0.cover_level_fac_ri as AUG_COVERAGE_DEFINITION__FACULTATIVE_REINSURANCE_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        nullif(trim(t0.tax_type),'') as AUG_FINTXN_TAX__TAX_TYPE_CK,
        t0.tax_payment_cycle_ref_no as AUG_FINTXN_TAX__TAX_PAYMENT_CYCLE_REFERENCE_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        t0.coverage as COVERAGE_DEFINITION__COVERAGE_DISPLAY_NAME,
        t0.cover_name as COVERAGE_DEFINITION__COVERAGE_NAME,
        null, null,
        t0.parent_payment_amount as FINTXN_HEADER__GROSS_AMOUNT,
        null, null, null, null, null, null, null, null, null,
        nullif(trim(t0.tax_type),'') as FINTXN_TAX__TAX_TYPE_CK,
        null, null, null, null, null, null, null,
        t0.tax_invoice_no as FINTXN_TAX__TAX_INVOICE_NUMBER,
        null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list_pv') }} t0
    where (coalesce(nullif(coalesce(nullif(trim(t0.cover_code), ''), nullif(trim(t0.covercode), '')), ''), nullif(nullif(trim(t0.parent_payment_cycle_ref_no),''), ''))) is not null

    union all

    -- branch 45: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
    select
        nullif(nullif(trim(t0.cover_code),''), '') as COVERAGE_BK,
        null, null, null, null, null, null, null, null,
        t0.leading_cover as AUG_COVERAGE_DEFINITION__LEADING_COVERAGE_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list_pv') }} t0
    where (nullif(nullif(trim(t0.cover_code),''), '')) is not null

)

select
    COVERAGE_BK,
    FINANCIAL_TRANSACTION_BK,
    POLICY_BK,
    __LNK_POLICY_COVERAGE,
    first_value(AUG_COVERAGE_DEFINITION__COVERAGE_DURATION) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_DEFINITION__COVERAGE_DURATION,
    first_value(AUG_COVERAGE_DEFINITION__COVERAGE_EXPIRY_DATE) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_DEFINITION__COVERAGE_EXPIRY_DATE,
    first_value(AUG_COVERAGE_DEFINITION__COVERAGE_INCEPTION_DATE) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_DEFINITION__COVERAGE_INCEPTION_DATE,
    first_value(AUG_COVERAGE_DEFINITION__EVENT_BASED_INDICATOR) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_DEFINITION__EVENT_BASED_INDICATOR,
    first_value(AUG_COVERAGE_DEFINITION__FACULTATIVE_REINSURANCE_INDICATOR) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_DEFINITION__FACULTATIVE_REINSURANCE_INDICATOR,
    first_value(AUG_COVERAGE_DEFINITION__LEADING_COVERAGE_INDICATOR) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_DEFINITION__LEADING_COVERAGE_INDICATOR,
    first_value(AUG_FINTXN_CLAIM_PAYMENT__AOL_MODE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_CLAIM_PAYMENT__AOL_MODE,
    first_value(AUG_FINTXN_CLAIM_PAYMENT__CLAIM_EXPENSE_PAYMENT_MODE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_CLAIM_PAYMENT__CLAIM_EXPENSE_PAYMENT_MODE,
    first_value(AUG_FINTXN_CLAIM_PAYMENT__INSTRUMENT_PAYABLE_AT_LOCATION) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_CLAIM_PAYMENT__INSTRUMENT_PAYABLE_AT_LOCATION,
    first_value(AUG_FINTXN_CLAIM_PAYMENT__INSTRUMENT_PRINT_LOCATION_CODE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_CLAIM_PAYMENT__INSTRUMENT_PRINT_LOCATION_CODE,
    first_value(AUG_FINTXN_CLAIM_PAYMENT__INTEREST_AMOUNT) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_CLAIM_PAYMENT__INTEREST_AMOUNT,
    first_value(AUG_FINTXN_CLAIM_PAYMENT__INTERIM_OR_FINAL_PAYMENT_INDICATOR) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_CLAIM_PAYMENT__INTERIM_OR_FINAL_PAYMENT_INDICATOR,
    first_value(AUG_FINTXN_CLAIM_PAYMENT__NCB_RECOVERY_AMOUNT) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_CLAIM_PAYMENT__NCB_RECOVERY_AMOUNT,
    first_value(AUG_FINTXN_CLAIM_PAYMENT__NEFT_STATUS) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_CLAIM_PAYMENT__NEFT_STATUS,
    first_value(AUG_FINTXN_CLAIM_PAYMENT__OWN_DAMAGE_PAYMENT_MODE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_CLAIM_PAYMENT__OWN_DAMAGE_PAYMENT_MODE,
    first_value(AUG_FINTXN_CLAIM_PAYMENT__PAID_AGAINST_RESERVE_TYPE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_CLAIM_PAYMENT__PAID_AGAINST_RESERVE_TYPE,
    first_value(AUG_FINTXN_CLAIM_PAYMENT__PAYMENT_APPROVED_BY_USER_REFERENCE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_CLAIM_PAYMENT__PAYMENT_APPROVED_BY_USER_REFERENCE,
    first_value(AUG_FINTXN_CLAIM_PAYMENT__PAYMENT_AUTHORISATION_DATE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_CLAIM_PAYMENT__PAYMENT_AUTHORISATION_DATE,
    first_value(AUG_FINTXN_CLAIM_PAYMENT__PAYMENT_DETAIL_TEXT) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_CLAIM_PAYMENT__PAYMENT_DETAIL_TEXT,
    first_value(AUG_FINTXN_CLAIM_PAYMENT__PAYMENT_GROUP_CODE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_CLAIM_PAYMENT__PAYMENT_GROUP_CODE,
    first_value(AUG_FINTXN_CLAIM_PAYMENT__PAYMENT_MODE_OTHER_REMARKS) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_CLAIM_PAYMENT__PAYMENT_MODE_OTHER_REMARKS,
    first_value(AUG_FINTXN_CLAIM_PAYMENT__PAYMENT_MODE_REMARKS) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_CLAIM_PAYMENT__PAYMENT_MODE_REMARKS,
    first_value(AUG_FINTXN_CLAIM_PAYMENT__PAYMENT_PURPOSE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_CLAIM_PAYMENT__PAYMENT_PURPOSE,
    first_value(AUG_FINTXN_CLAIM_PAYMENT__PAYMENT_RELEASED_INDICATOR) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_CLAIM_PAYMENT__PAYMENT_RELEASED_INDICATOR,
    first_value(AUG_FINTXN_CLAIM_PAYMENT__POLICY_SECTION_CODE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_CLAIM_PAYMENT__POLICY_SECTION_CODE,
    first_value(AUG_FINTXN_CLAIM_PAYMENT__PORTAL_PAYMENT_REFERENCE_NUMBER) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_CLAIM_PAYMENT__PORTAL_PAYMENT_REFERENCE_NUMBER,
    first_value(AUG_FINTXN_CLAIM_PAYMENT__SUPPORTING_INVOICE_MODE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_CLAIM_PAYMENT__SUPPORTING_INVOICE_MODE,
    first_value(AUG_FINTXN_CLAIM_PAYMENT__SUPPORTING_INVOICE_NUMBER) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_CLAIM_PAYMENT__SUPPORTING_INVOICE_NUMBER,
    first_value(AUG_FINTXN_CLAIM_PAYMENT__UTR_DATE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_CLAIM_PAYMENT__UTR_DATE,
    AUG_FINTXN_TAX__TAX_TYPE_CK,
    first_value(AUG_FINTXN_TAX__TAX_PAYMENT_CYCLE_REFERENCE_NUMBER) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK, AUG_FINTXN_TAX__TAX_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_TAX__TAX_PAYMENT_CYCLE_REFERENCE_NUMBER,
    first_value(AUG_FINTXN_TAX__TDS_APPLICABILITY_BASIS) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK, AUG_FINTXN_TAX__TAX_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_TAX__TDS_APPLICABILITY_BASIS,
    first_value(AUG_FINTXN_TAX__TDS_CERTIFICATE_REFERENCE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK, AUG_FINTXN_TAX__TAX_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_TAX__TDS_CERTIFICATE_REFERENCE,
    first_value(AUG_FINTXN_TAX__TDS_DEMAND_DRAFT_PAYABLE_AT) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK, AUG_FINTXN_TAX__TAX_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_TAX__TDS_DEMAND_DRAFT_PAYABLE_AT,
    first_value(AUG_FINTXN_TAX__TDS_DEMAND_DRAFT_STATE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK, AUG_FINTXN_TAX__TAX_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_TAX__TDS_DEMAND_DRAFT_STATE,
    first_value(AUG_FINTXN_TAX__TDS_NON_DEDUCTION_INDICATOR) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK, AUG_FINTXN_TAX__TAX_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_TAX__TDS_NON_DEDUCTION_INDICATOR,
    first_value(AUG_FINTXN_TAX__TDS_NON_DEDUCTION_REASON) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK, AUG_FINTXN_TAX__TAX_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_TAX__TDS_NON_DEDUCTION_REASON,
    first_value(AUG_FINTXN_TAX__TDS_ON_INTEREST_AMOUNT) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK, AUG_FINTXN_TAX__TAX_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_TAX__TDS_ON_INTEREST_AMOUNT,
    first_value(AUG_FINTXN_TAX__TDS_PAYMENT_MODE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK, AUG_FINTXN_TAX__TAX_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_TAX__TDS_PAYMENT_MODE,
    first_value(AUG_FINTXN_TAX__TDS_PORTAL_PAYMENT_REFERENCE_NUMBER) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK, AUG_FINTXN_TAX__TAX_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_TAX__TDS_PORTAL_PAYMENT_REFERENCE_NUMBER,
    first_value(AUG_FINTXN_TAX__TDS_SEPARATE_CHEQUE_INDICATOR) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK, AUG_FINTXN_TAX__TAX_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_TAX__TDS_SEPARATE_CHEQUE_INDICATOR,
    first_value(AUG_FINTXN_TAX__TDS_SEPARATE_PAYMENT_INDICATOR) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK, AUG_FINTXN_TAX__TAX_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_TAX__TDS_SEPARATE_PAYMENT_INDICATOR,
    first_value(AUG_FINTXN_TAX__TDS_SOURCE_SYSTEM_REFERENCE_NUMBER) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK, AUG_FINTXN_TAX__TAX_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_TAX__TDS_SOURCE_SYSTEM_REFERENCE_NUMBER,
    first_value(AUG_FINTXN_TAX__TDS_WAIVER_INDICATOR) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK, AUG_FINTXN_TAX__TAX_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_TAX__TDS_WAIVER_INDICATOR,
    first_value(AUG_FINTXN_TAX__TDS_WAIVER_REASON) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK, AUG_FINTXN_TAX__TAX_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_TAX__TDS_WAIVER_REASON,
    first_value(AUG_FINTXN_TAX__TOTAL_GST_RATE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK, AUG_FINTXN_TAX__TAX_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_TAX__TOTAL_GST_RATE,
    first_value(AUG_FINTXN_TAX__UTGST_AMOUNT) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK, AUG_FINTXN_TAX__TAX_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_TAX__UTGST_AMOUNT,
    first_value(AUG_FINTXN_TAX__UTGST_RATE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK, AUG_FINTXN_TAX__TAX_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_TAX__UTGST_RATE,
    AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
    AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
    AUG_POLICY_PREMIUM_HEAD__SECTION_CK,
    AUG_POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK,
    first_value(AUG_POLICY_PREMIUM_HEAD__EARNED_HEAD_PREMIUM) ignore nulls over (partition by POLICY_BK, AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK, AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK, AUG_POLICY_PREMIUM_HEAD__SECTION_CK, AUG_POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_HEAD__EARNED_HEAD_PREMIUM,
    first_value(AUG_POLICY_PREMIUM_HEAD__EXCHANGE_RATE_APPLIED) ignore nulls over (partition by POLICY_BK, AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK, AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK, AUG_POLICY_PREMIUM_HEAD__SECTION_CK, AUG_POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_HEAD__EXCHANGE_RATE_APPLIED,
    first_value(AUG_POLICY_PREMIUM_HEAD__EXPIRING_PREMIUM_AMOUNT) ignore nulls over (partition by POLICY_BK, AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK, AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK, AUG_POLICY_PREMIUM_HEAD__SECTION_CK, AUG_POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_HEAD__EXPIRING_PREMIUM_AMOUNT,
    first_value(AUG_POLICY_PREMIUM_HEAD__FIXED_PREMIUM_SYSTEM_CODE) ignore nulls over (partition by POLICY_BK, AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK, AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK, AUG_POLICY_PREMIUM_HEAD__SECTION_CK, AUG_POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_HEAD__FIXED_PREMIUM_SYSTEM_CODE,
    first_value(AUG_POLICY_PREMIUM_HEAD__GROSS_HEAD_PREMIUM) ignore nulls over (partition by POLICY_BK, AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK, AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK, AUG_POLICY_PREMIUM_HEAD__SECTION_CK, AUG_POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_HEAD__GROSS_HEAD_PREMIUM,
    first_value(AUG_POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM_IN_BASE_CURRENCY) ignore nulls over (partition by POLICY_BK, AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK, AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK, AUG_POLICY_PREMIUM_HEAD__SECTION_CK, AUG_POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM_IN_BASE_CURRENCY,
    first_value(AUG_POLICY_PREMIUM_HEAD__PREMIUM_ADJUSTMENT_AMOUNT) ignore nulls over (partition by POLICY_BK, AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK, AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK, AUG_POLICY_PREMIUM_HEAD__SECTION_CK, AUG_POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_HEAD__PREMIUM_ADJUSTMENT_AMOUNT,
    first_value(AUG_POLICY_PREMIUM_HEAD__PREMIUM_ADJUSTMENT_TYPE) ignore nulls over (partition by POLICY_BK, AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK, AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK, AUG_POLICY_PREMIUM_HEAD__SECTION_CK, AUG_POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_HEAD__PREMIUM_ADJUSTMENT_TYPE,
    first_value(AUG_POLICY_PREMIUM_HEAD__PREMIUM_RATE_APPLIED) ignore nulls over (partition by POLICY_BK, AUG_POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK, AUG_POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK, AUG_POLICY_PREMIUM_HEAD__SECTION_CK, AUG_POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_HEAD__PREMIUM_RATE_APPLIED,
    first_value(COVERAGE_DEFINITION__COVERAGE_DISPLAY_NAME) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COVERAGE_DEFINITION__COVERAGE_DISPLAY_NAME,
    first_value(COVERAGE_DEFINITION__COVERAGE_NAME) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COVERAGE_DEFINITION__COVERAGE_NAME,
    first_value(COVERAGE_DEFINITION__PERIL_COVERED) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COVERAGE_DEFINITION__PERIL_COVERED,
    first_value(FINTXN_HEADER__APPROVAL_STATUS) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_HEADER__APPROVAL_STATUS,
    first_value(FINTXN_HEADER__GROSS_AMOUNT) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_HEADER__GROSS_AMOUNT,
    first_value(FINTXN_HEADER__NARRATION) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_HEADER__NARRATION,
    first_value(FINTXN_HEADER__SOURCE_REFERENCE_NUMBER) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_HEADER__SOURCE_REFERENCE_NUMBER,
    first_value(FINTXN_HEADER__SOURCE_REFERENCE_TYPE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_HEADER__SOURCE_REFERENCE_TYPE,
    first_value(FINTXN_HEADER__TAX_AMOUNT) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_HEADER__TAX_AMOUNT,
    first_value(FINTXN_HEADER__TRANSACTION_DATE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_HEADER__TRANSACTION_DATE,
    first_value(FINTXN_HEADER__TRANSACTION_NUMBER) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_HEADER__TRANSACTION_NUMBER,
    first_value(FINTXN_HEADER__TRANSACTION_STATUS) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_HEADER__TRANSACTION_STATUS,
    first_value(FINTXN_HEADER__TRANSACTION_SUB_TYPE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_HEADER__TRANSACTION_SUB_TYPE,
    first_value(FINTXN_HEADER__TRANSACTION_TYPE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_HEADER__TRANSACTION_TYPE,
    FINTXN_TAX__TAX_TYPE_CK,
    first_value(FINTXN_TAX__CGST_AMOUNT) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK, FINTXN_TAX__TAX_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_TAX__CGST_AMOUNT,
    first_value(FINTXN_TAX__IGST_AMOUNT) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK, FINTXN_TAX__TAX_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_TAX__IGST_AMOUNT,
    first_value(FINTXN_TAX__SGST_AMOUNT) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK, FINTXN_TAX__TAX_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_TAX__SGST_AMOUNT,
    first_value(FINTXN_TAX__SGST_RATE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK, FINTXN_TAX__TAX_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_TAX__SGST_RATE,
    first_value(FINTXN_TAX__TAXABLE_VALUE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK, FINTXN_TAX__TAX_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_TAX__TAXABLE_VALUE,
    first_value(FINTXN_TAX__TAX_APPLICABLE_INDICATOR) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK, FINTXN_TAX__TAX_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_TAX__TAX_APPLICABLE_INDICATOR,
    first_value(FINTXN_TAX__TAX_INVOICE_DATE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK, FINTXN_TAX__TAX_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_TAX__TAX_INVOICE_DATE,
    first_value(FINTXN_TAX__TAX_INVOICE_NUMBER) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK, FINTXN_TAX__TAX_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_TAX__TAX_INVOICE_NUMBER,
    first_value(FINTXN_TAX__TAX_RATE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK, FINTXN_TAX__TAX_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_TAX__TAX_RATE,
    first_value(FINTXN_TAX__TDS_AMOUNT) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK, FINTXN_TAX__TAX_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_TAX__TDS_AMOUNT,
    first_value(FINTXN_TAX__TDS_RATE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK, FINTXN_TAX__TAX_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_TAX__TDS_RATE,
    -- the row's own source time: LOAD_DATETIME for hubs, links and single-active satellites
    m.REC_REFRESH_AT,
    -- multi-active satellites on FINANCIAL_TRANSACTION_BK (SAT_MOTOR_AUG_FINTXN_TAX, SAT_FINTXN_TAX):
    -- one load time per FINANCIAL_TRANSACTION_BK, the newest REC_REFRESH_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when coalesce(m.AUG_FINTXN_TAX__TAX_PAYMENT_CYCLE_REFERENCE_NUMBER, m.AUG_FINTXN_TAX__TDS_APPLICABILITY_BASIS, m.AUG_FINTXN_TAX__TDS_CERTIFICATE_REFERENCE, m.AUG_FINTXN_TAX__TDS_DEMAND_DRAFT_PAYABLE_AT, m.AUG_FINTXN_TAX__TDS_DEMAND_DRAFT_STATE, m.AUG_FINTXN_TAX__TDS_NON_DEDUCTION_INDICATOR, m.AUG_FINTXN_TAX__TDS_NON_DEDUCTION_REASON, m.AUG_FINTXN_TAX__TDS_ON_INTEREST_AMOUNT, m.AUG_FINTXN_TAX__TDS_PAYMENT_MODE, m.AUG_FINTXN_TAX__TDS_PORTAL_PAYMENT_REFERENCE_NUMBER, m.AUG_FINTXN_TAX__TDS_SEPARATE_CHEQUE_INDICATOR, m.AUG_FINTXN_TAX__TDS_SEPARATE_PAYMENT_INDICATOR, m.AUG_FINTXN_TAX__TDS_SOURCE_SYSTEM_REFERENCE_NUMBER, m.AUG_FINTXN_TAX__TDS_WAIVER_INDICATOR, m.AUG_FINTXN_TAX__TDS_WAIVER_REASON, m.AUG_FINTXN_TAX__TOTAL_GST_RATE, m.AUG_FINTXN_TAX__UTGST_AMOUNT, m.AUG_FINTXN_TAX__UTGST_RATE, m.FINTXN_TAX__CGST_AMOUNT, m.FINTXN_TAX__IGST_AMOUNT, m.FINTXN_TAX__SGST_AMOUNT, m.FINTXN_TAX__SGST_RATE, m.FINTXN_TAX__TAXABLE_VALUE, m.FINTXN_TAX__TAX_APPLICABLE_INDICATOR, m.FINTXN_TAX__TAX_INVOICE_DATE, m.FINTXN_TAX__TAX_INVOICE_NUMBER, m.FINTXN_TAX__TAX_RATE, m.FINTXN_TAX__TDS_AMOUNT, m.FINTXN_TAX__TDS_RATE) is not null
             then m.REC_REFRESH_AT end)
        over (partition by m.FINANCIAL_TRANSACTION_BK) as FINANCIAL_TRANSACTION_BK__MA_LOAD_DATETIME,
    -- multi-active satellites on POLICY_BK (SAT_MOTOR_AUG_POLICY_PREMIUM_HEAD):
    -- one load time per POLICY_BK, the newest REC_REFRESH_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when coalesce(m.AUG_POLICY_PREMIUM_HEAD__EARNED_HEAD_PREMIUM, m.AUG_POLICY_PREMIUM_HEAD__EXCHANGE_RATE_APPLIED, m.AUG_POLICY_PREMIUM_HEAD__EXPIRING_PREMIUM_AMOUNT, m.AUG_POLICY_PREMIUM_HEAD__FIXED_PREMIUM_SYSTEM_CODE, m.AUG_POLICY_PREMIUM_HEAD__GROSS_HEAD_PREMIUM, m.AUG_POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM_IN_BASE_CURRENCY, m.AUG_POLICY_PREMIUM_HEAD__PREMIUM_ADJUSTMENT_AMOUNT, m.AUG_POLICY_PREMIUM_HEAD__PREMIUM_ADJUSTMENT_TYPE, m.AUG_POLICY_PREMIUM_HEAD__PREMIUM_RATE_APPLIED) is not null
             then m.REC_REFRESH_AT end)
        over (partition by m.POLICY_BK) as POLICY_BK__MA_LOAD_DATETIME
from merged m
