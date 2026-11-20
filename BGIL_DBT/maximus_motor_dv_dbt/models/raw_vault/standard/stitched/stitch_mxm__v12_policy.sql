-- CENTRAL VIEW v12_policy -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_PARTY
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_PARTY
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_RELATION
--   MAXI_MOTOR_UWR_VW_DATA_PREMIUM_DETAILS
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY
-- Walk tables, joined only to resolve spine keys (not counted):
--   MAXI_MOTOR_UWR_VW_DATA
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_ASSESSMENT_UNDERWRITING
--   SAT_MOTOR_AUG_ASSESSMENT_UNDERWRITING
--   SAT_MOTOR_AUG_COMMON_ADMIN_GEOGRAPHY
--   SAT_MOTOR_AUG_COMMON_BUSINESS_AUDIT
--   SAT_MOTOR_AUG_COMMON_CONTACT
--   SAT_MOTOR_AUG_LNK_POLICY_PARTY_ROLE
--   SAT_MOTOR_AUG_POLICY_CANCELLATION
--   SAT_MOTOR_AUG_POLICY_DECLARED_CLAIM_HISTORY
--   SAT_MOTOR_AUG_POLICY_DELIVERY
--   SAT_MOTOR_AUG_POLICY_DOC_CHECKLIST
--   SAT_MOTOR_AUG_POLICY_EXTERNAL_TP_LINK
--   SAT_MOTOR_AUG_POLICY_INTERMEDIARY_SPLIT
--   SAT_MOTOR_AUG_POLICY_LIFECYCLE
--   SAT_MOTOR_AUG_POLICY_LONG_TERM_DETAIL
--   SAT_MOTOR_AUG_POLICY_RENEWAL
--   SAT_MOTOR_AUG_POLICY_SERVICING_SUMMARY
--   SAT_MOTOR_AUG_POLICY_SUM_INSURED_BREAKUP
--   SAT_MOTOR_AUG_POLICY_TAX_BREAKUP
--   SAT_MOTOR_AUG_POLICY_TERMS
--   SAT_MOTOR_AUG_POLICY_UNDERWRITING_WORKFLOW
--   SAT_MOTOR_AUG_PRODUCT_TERMS
--   SAT_MOTOR_AUG_PROPOSAL_HEADER
--   SAT_MOTOR_AUG_PROPOSAL_SCRUTINY
--   SAT_MOTOR_AUG_RISK_MOTOR_BUREAU_ENQUIRY
--   SAT_MOTOR_AUG_RISK_MOTOR_BUREAU_PROFILE
--   SAT_MOTOR_AUG_RISK_MOTOR_RATING_ZONE_HEAD
--   SAT_MOTOR_AUG_RISK_OBJECT_OWNERSHIP_HISTORY
--   SAT_MOTOR_AUG_RISK_OBJECT_PARAMETER
--   SAT_COMMON_BUSINESS_AUDIT
--   SAT_COMMON_LIFECYCLE
--   SAT_LNK_PARTY_ROLE_CORE
--   SAT_ORG_UNIT_DEFINITION
--   SAT_PARTY_MARKETING
--   SAT_POLICY_CANCELLATION
--   SAT_POLICY_EXCESS_STRUCTURE
--   SAT_POLICY_INTERMEDIARY_SPLIT
--   SAT_POLICY_PREMIUM_SUMMARY
--   SAT_POLICY_TAX_BREAKUP
--   SAT_PROPOSAL_HEADER
--   SAT_RISK_PERSON_INSURED
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_POLICY_PARTY
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_PARTY
    select
        cast(null as varchar) as ASSESSMENT_BK,
        cast(null as varchar) as LOCATION_BK,
        cast(null as varchar) as ORG_UNIT_BK,
        nullif(nullif(trim(t0.partycode),''), '') as PARTY_BK,
        cast(null as varchar) as POLICY_BK,
        cast(null as varchar) as PRODUCT_BK,
        cast(null as varchar) as PROPOSAL_BK,
        cast(null as varchar) as RISK_OBJECT_BK,
        cast(null as number) as __LNK_POLICY_PARTY,
        cast(null as varchar) as ASSESSMENT_UNDERWRITING__REFERRAL_INDICATOR,
        cast(null as varchar) as AUG_ASSESSMENT_UNDERWRITING__REFERRAL_LIMIT_AMOUNT,
        cast(null as varchar) as AUG_COMMON_ADMIN_GEOGRAPHY__RTO_CLUSTER_CODE,
        cast(null as varchar) as AUG_COMMON_BUSINESS_AUDIT__CREATED_TIME,
        cast(null as varchar) as AUG_COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        cast(null as varchar) as AUG_COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
        cast(null as varchar) as AUG_COMMON_CONTACT__CONTACT_POINT_OWNER_RELATIONSHIP,
        cast(null as varchar) as AUG_LNK_POLICY_PARTY_ROLE__RELATIONSHIP_TO_INSURED,
        cast(null as varchar) as AUG_POLICY_CANCELLATION__ELAPSED_PERIOD_PREMIUM_AMOUNT,
        cast(null as varchar) as AUG_POLICY_CANCELLATION__RETAINED_ADMINISTRATION_CHARGES,
        cast(null as varchar) as AUG_POLICY_CANCELLATION__UNEXPIRED_PERIOD_PREMIUM_AMOUNT,
        cast(null as varchar) as AUG_POLICY_DECLARED_CLAIM_HISTORY__ACCIDENT_DATE,
        cast(null as varchar) as AUG_POLICY_DECLARED_CLAIM_HISTORY__ACCIDENT_LOCATION_DESCRIPTION,
        cast(null as varchar) as AUG_POLICY_DECLARED_CLAIM_HISTORY__CASE_FILED_BEFORE_FORUM,
        cast(null as varchar) as AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_AREA_CODE,
        cast(null as varchar) as AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_HANDLING_LOCATION_CODE,
        cast(null as varchar) as AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_INTIMATION_DATE,
        cast(null as varchar) as AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_INTIMATION_TIME,
        cast(null as varchar) as AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_INTIMATION_TYPE,
        cast(null as varchar) as AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_INTIMATOR_MOBILE_NUMBER,
        cast(null as varchar) as AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_INTIMATOR_NAME,
        cast(null as varchar) as AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_LOCATION_DESCRIPTION,
        cast(null as varchar) as AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_REGISTRATION_LOCATION_CODE,
        cast(null as varchar) as AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_REQUIREMENT_STATUS,
        cast(null as varchar) as AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_SUB_STATUS,
        cast(null as varchar) as AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_TYPE,
        cast(null as varchar) as AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_TYPES_LIST,
        cast(null as varchar) as AUG_POLICY_DECLARED_CLAIM_HISTORY__COURT_LOCATION_AS_PER_INTIMATION,
        cast(null as varchar) as AUG_POLICY_DECLARED_CLAIM_HISTORY__COURT_NAME_AS_PER_INTIMATION,
        cast(null as varchar) as AUG_POLICY_DECLARED_CLAIM_HISTORY__COURT_TYPE,
        cast(null as varchar) as AUG_POLICY_DECLARED_CLAIM_HISTORY__DECLARED_CLAIM_AMOUNT,
        cast(null as varchar) as AUG_POLICY_DECLARED_CLAIM_HISTORY__DECLARED_CLAIM_DATE,
        cast(null as varchar) as AUG_POLICY_DECLARED_CLAIM_HISTORY__EXPENSE_FEE_HEAD_CODE,
        cast(null as varchar) as AUG_POLICY_DECLARED_CLAIM_HISTORY__EXPENSE_PAYMENT_AMOUNT,
        cast(null as varchar) as AUG_POLICY_DECLARED_CLAIM_HISTORY__EXPENSE_PAYMENT_APPROVED_BY,
        cast(null as varchar) as AUG_POLICY_DECLARED_CLAIM_HISTORY__EXPENSE_PAYMENT_DATE,
        cast(null as varchar) as AUG_POLICY_DECLARED_CLAIM_HISTORY__EXPENSE_PAYMENT_REFERENCE_NUMBER,
        cast(null as varchar) as AUG_POLICY_DECLARED_CLAIM_HISTORY__EXPENSE_PAYMENT_TYPE,
        cast(null as varchar) as AUG_POLICY_DECLARED_CLAIM_HISTORY__EXPENSE_PORTAL_PAYMENT_REFERENCE_NUMBER,
        cast(null as varchar) as AUG_POLICY_DECLARED_CLAIM_HISTORY__EXPENSE_REFERENCE_TEXT,
        cast(null as varchar) as AUG_POLICY_DECLARED_CLAIM_HISTORY__LOSS_CAUSE,
        cast(null as varchar) as AUG_POLICY_DECLARED_CLAIM_HISTORY__LOSS_DATE,
        cast(null as varchar) as AUG_POLICY_DECLARED_CLAIM_HISTORY__LOSS_DESCRIPTION,
        cast(null as varchar) as AUG_POLICY_DECLARED_CLAIM_HISTORY__LOSS_INFORMATION_DESCRIPTION,
        cast(null as varchar) as AUG_POLICY_DECLARED_CLAIM_HISTORY__PERSONAL_ACCIDENT_LOSS_CAUSE,
        cast(null as varchar) as AUG_POLICY_DELIVERY__DOCUMENT_QR_CODE,
        cast(null as varchar) as AUG_POLICY_DELIVERY__PROOF_OF_DELIVERY_DETAILS,
        cast(null as varchar) as AUG_POLICY_DOC_CHECKLIST__ACTIVE_SEQUENCE_NUMBER_CK,
        cast(null as varchar) as AUG_POLICY_DOC_CHECKLIST__DEFICIENCY_STATUS,
        cast(null as varchar) as AUG_POLICY_EXTERNAL_TP_LINK__TP_INSURER_BRANCH_ADDRESS_TEXT,
        cast(null as varchar) as AUG_POLICY_EXTERNAL_TP_LINK__TP_POLICY_CLAIM_AMOUNT,
        cast(null as varchar) as AUG_POLICY_EXTERNAL_TP_LINK__TP_POLICY_CLAIM_DATE,
        cast(null as varchar) as AUG_POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE_CK,
        cast(null as varchar) as AUG_POLICY_INTERMEDIARY_SPLIT__COMMISSION_DISCOUNT_AMOUNT,
        cast(null as varchar) as AUG_POLICY_INTERMEDIARY_SPLIT__COMMISSION_LOADING_AMOUNT,
        cast(null as varchar) as AUG_POLICY_INTERMEDIARY_SPLIT__LINE_OF_BUSINESS_COMMISSION_APPLICABLE_INDICATOR,
        cast(null as varchar) as AUG_POLICY_INTERMEDIARY_SPLIT__LINE_OF_BUSINESS_COMMISSION_IMPACT_AMOUNT,
        cast(null as varchar) as AUG_POLICY_INTERMEDIARY_SPLIT__SERVICE_CHARGE_AMOUNT,
        cast(null as varchar) as AUG_POLICY_LIFECYCLE__NEXT_ANNIVERSARY_DATE,
        cast(null as varchar) as AUG_POLICY_LONG_TERM_DETAIL__REMAINING_ANNIVERSARY_COUNT,
        cast(null as varchar) as AUG_POLICY_RENEWAL__PROFITABILITY_INDICATOR,
        cast(null as varchar) as AUG_POLICY_RENEWAL__RENEWAL_BUSINESS_INDICATOR,
        cast(null as varchar) as AUG_POLICY_SERVICING_SUMMARY__BANCASSURANCE_CHARGE_FILE_PROCESS_COUNT,
        cast(null as varchar) as AUG_POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_HEAD_CK,
        cast(null as varchar) as AUG_POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_CURRENCY_CODE,
        cast(null as varchar) as AUG_POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_CURRENCY_EXCHANGE_RATE,
        cast(null as varchar) as AUG_POLICY_TAX_BREAKUP__EXEMPTION_REASON,
        cast(null as varchar) as AUG_POLICY_TAX_BREAKUP__GST_APPLICABLE_INDICATOR,
        cast(null as varchar) as AUG_POLICY_TAX_BREAKUP__GST_BIFURCATION_BASIS,
        cast(null as varchar) as AUG_POLICY_TAX_BREAKUP__GST_TDS_AMOUNT,
        cast(null as varchar) as AUG_POLICY_TAX_BREAKUP__GST_TYPE,
        cast(null as varchar) as AUG_POLICY_TAX_BREAKUP__STAMP_DUTY_RECEIPT_NUMBER,
        cast(null as varchar) as AUG_POLICY_TAX_BREAKUP__TAX_PAYMENT_CYCLE_REFERENCE_NUMBER,
        cast(null as varchar) as AUG_POLICY_TAX_BREAKUP__TDS_APPLICABLE_INDICATOR,
        cast(null as varchar) as AUG_POLICY_TAX_BREAKUP__TOTAL_TAX_AMOUNT,
        cast(null as varchar) as AUG_POLICY_TAX_BREAKUP__UTGST_AMOUNT,
        cast(null as varchar) as AUG_POLICY_TERMS__FRANCHISE_AMOUNT,
        cast(null as varchar) as AUG_POLICY_TERMS__GEOGRAPHICAL_EXTENSION_CODE,
        cast(null as varchar) as AUG_POLICY_TERMS__NIL_DEPRECIATION_APPLICABLE_FOR_ORGANISATION_INDICATOR,
        cast(null as varchar) as AUG_POLICY_TERMS__OWN_DAMAGE_EXTENSION_DAYS,
        cast(null as varchar) as AUG_POLICY_TERMS__PRESENT_QUOTA_LIMIT,
        cast(null as varchar) as AUG_POLICY_TERMS__THIRD_PARTY_EXTENSION_DAYS,
        cast(null as varchar) as AUG_POLICY_UNDERWRITING_WORKFLOW__ADDITIONAL_INFORMATION_TEXT,
        cast(null as varchar) as AUG_POLICY_UNDERWRITING_WORKFLOW__DEFICIENCY_STATUS,
        cast(null as varchar) as AUG_POLICY_UNDERWRITING_WORKFLOW__UNDERWRITER_ACCEPTANCE_DECISION,
        cast(null as varchar) as AUG_PRODUCT_TERMS__CHASSIS_NUMBER_VALIDATION_PATTERN,
        cast(null as varchar) as AUG_PRODUCT_TERMS__ENGINE_NUMBER_VALIDATION_PATTERN,
        cast(null as varchar) as AUG_PROPOSAL_HEADER__QUESTION_SET_REFERENCE,
        cast(null as varchar) as AUG_PROPOSAL_SCRUTINY__BYPASSED_RULE_LIST,
        cast(null as varchar) as AUG_RISK_MOTOR_BUREAU_ENQUIRY__BUREAU_ENQUIRY_REFERENCE_CK,
        cast(null as varchar) as AUG_RISK_MOTOR_BUREAU_ENQUIRY__BUREAU_ENQUIRY_REFERENCE,
        cast(null as varchar) as AUG_RISK_MOTOR_BUREAU_PROFILE__BUREAU_REPORTED_OWN_DAMAGE_CLAIM_COUNT,
        cast(null as varchar) as AUG_RISK_MOTOR_RATING_ZONE_HEAD__RATING_HEAD_CODE_CK,
        cast(null as varchar) as AUG_RISK_MOTOR_RATING_ZONE_HEAD__RTA_CLUSTER_NAME,
        cast(null as varchar) as AUG_RISK_OBJECT_OWNERSHIP_HISTORY__OWNER_SEQUENCE_CK,
        cast(null as varchar) as AUG_RISK_OBJECT_OWNERSHIP_HISTORY__TRANSFEREE_NAME,
        cast(null as varchar) as AUG_RISK_OBJECT_PARAMETER__PARAMETER_REFERENCE_CK,
        cast(null as varchar) as AUG_RISK_OBJECT_PARAMETER__BUSINESS_EVENT_CODE,
        cast(null as varchar) as COMMON_BUSINESS_AUDIT__CREATED_BY_USER_REFERENCE,
        cast(null as varchar) as COMMON_BUSINESS_AUDIT__CREATED_DATE,
        cast(null as varchar) as COMMON_BUSINESS_AUDIT__SOURCE_APPLICATION_NAME,
        cast(null as varchar) as COMMON_LIFECYCLE__EFFECTIVE_DATE,
        cast(null as varchar) as COMMON_LIFECYCLE__EXPIRY_DATE,
        nullif(trim(t0.stakecode),'') as LNK_PARTY_ROLE_CORE__ROLE_CODE_CK,
        cast(null as varchar) as LNK_PARTY_ROLE_CORE__ROLE_SEQUENCE_CK,
        t0.stakecode as LNK_PARTY_ROLE_CORE__ROLE_CODE,
        cast(null as varchar) as LNK_PARTY_ROLE_CORE__ROLE_START_DATE,
        cast(null as varchar) as ORG_UNIT_DEFINITION__ORG_UNIT_NAME,
        cast(null as varchar) as PARTY_MARKETING__CAMPAIGN_REFERENCE,
        cast(null as varchar) as POLICY_CANCELLATION__CANCELLATION_REASON,
        cast(null as varchar) as POLICY_CANCELLATION__CANCELLATION_REQUESTED_BY_ROLE,
        cast(null as varchar) as POLICY_CANCELLATION__CANCELLATION_TYPE,
        cast(null as varchar) as POLICY_CANCELLATION__SHORT_PERIOD_BASIS,
        cast(null as varchar) as POLICY_EXCESS_STRUCTURE__EXCESS_CODE_CK,
        cast(null as varchar) as POLICY_EXCESS_STRUCTURE__EXCESS_AMOUNT,
        cast(null as varchar) as POLICY_EXCESS_STRUCTURE__EXCESS_TYPE,
        cast(null as varchar) as POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE_CK,
        cast(null as varchar) as POLICY_INTERMEDIARY_SPLIT__COMMISSION_AMOUNT,
        cast(null as varchar) as POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE,
        cast(null as varchar) as POLICY_INTERMEDIARY_SPLIT__SUB_IMD_CODE,
        cast(null as varchar) as POLICY_PREMIUM_SUMMARY__BASE_PREMIUM,
        cast(null as varchar) as POLICY_PREMIUM_SUMMARY__GROSS_PREMIUM,
        cast(null as varchar) as POLICY_PREMIUM_SUMMARY__GST_AMOUNT,
        cast(null as varchar) as POLICY_PREMIUM_SUMMARY__LOADING_AMOUNT,
        cast(null as varchar) as POLICY_PREMIUM_SUMMARY__MINIMUM_PREMIUM_APPLIED_INDICATOR,
        cast(null as varchar) as POLICY_PREMIUM_SUMMARY__NET_PREMIUM,
        cast(null as varchar) as POLICY_PREMIUM_SUMMARY__PREMIUM_OUTSTANDING,
        cast(null as varchar) as POLICY_PREMIUM_SUMMARY__REFUND_AMOUNT,
        cast(null as varchar) as POLICY_PREMIUM_SUMMARY__STAMP_DUTY_AMOUNT,
        cast(null as varchar) as POLICY_PREMIUM_SUMMARY__TOTAL_PREMIUM_COLLECTED,
        cast(null as varchar) as POLICY_TAX_BREAKUP__CGST_AMOUNT,
        cast(null as varchar) as POLICY_TAX_BREAKUP__CGST_RATE,
        cast(null as varchar) as POLICY_TAX_BREAKUP__GST_RATE,
        cast(null as varchar) as POLICY_TAX_BREAKUP__IGST_AMOUNT,
        cast(null as varchar) as POLICY_TAX_BREAKUP__PLACE_OF_SUPPLY,
        cast(null as varchar) as POLICY_TAX_BREAKUP__SGST_AMOUNT,
        cast(null as varchar) as POLICY_TAX_BREAKUP__SUPPLIER_STATE_CODE,
        cast(null as varchar) as PROPOSAL_HEADER__DECLINE_REASON,
        cast(null as varchar) as PROPOSAL_HEADER__SUBMISSION_CHANNEL,
        cast(null as varchar) as RISK_PERSON_INSURED__INSURED_MEMBER_NAME,
        t0.rec_refresh_at as REC_REFRESH_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_party') }} t0
    where (nullif(nullif(trim(t0.partycode),''), '')) is not null

    union all

    -- branch 1: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_PARTY
    select
        null, null, null,
        nullif(nullif(trim(t0.partycode),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        nullif(trim(t0.stakecode),'') as LNK_PARTY_ROLE_CORE__ROLE_CODE_CK,
        null,
        t0.stakecode as LNK_PARTY_ROLE_CORE__ROLE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_risk_party') }} t0
    where (nullif(nullif(trim(t0.partycode),''), '')) is not null

    union all

    -- branch 2: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS
    select
        null, null, null, null,
        nullif(nullif(trim(t0.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.renewal_flag as AUG_POLICY_RENEWAL__RENEWAL_BUSINESS_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        nullif(trim(t0.agent_code),'') as POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE_CK,
        t0.commision as POLICY_INTERMEDIARY_SPLIT__COMMISSION_AMOUNT,
        t0.agent_code as POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE,
        null, null,
        t0.total_premium as POLICY_PREMIUM_SUMMARY__GROSS_PREMIUM,
        t0.gst as POLICY_PREMIUM_SUMMARY__GST_AMOUNT,
        null, null,
        t0.net_premium as POLICY_PREMIUM_SUMMARY__NET_PREMIUM,
        null, null,
        t0.stamp_duty as POLICY_PREMIUM_SUMMARY__STAMP_DUTY_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd') }} t0
    where (nullif(nullif(trim(t0.policy_number),''), '')) is not null

    union all

    -- branch 3: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null, null, null,
        nullif(nullif(trim(j4.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        nullif(trim(j4.agent_code),'') as AUG_POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE_CK,
        t0.discount_in_commission as AUG_POLICY_INTERMEDIARY_SPLIT__COMMISSION_DISCOUNT_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.exemption_reason as AUG_POLICY_TAX_BREAKUP__EXEMPTION_REASON,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.additional_info_workflow as AUG_POLICY_UNDERWRITING_WORKFLOW__ADDITIONAL_INFORMATION_TEXT,
        t0.deficiency_status as AUG_POLICY_UNDERWRITING_WORKFLOW__DEFICIENCY_STATUS,
        t0.approvedrejected_by_uw as AUG_POLICY_UNDERWRITING_WORKFLOW__UNDERWRITER_ACCEPTANCE_DECISION,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.created_date as COMMON_BUSINESS_AUDIT__CREATED_DATE,
        t0.data_source as COMMON_BUSINESS_AUDIT__SOURCE_APPLICATION_NAME,
        t0.effective_date as COMMON_LIFECYCLE__EFFECTIVE_DATE,
        t0.expiry_date as COMMON_LIFECYCLE__EXPIRY_DATE,
        null, null, null, null, null, null, null, null, null, null,
        'ADDON' as POLICY_EXCESS_STRUCTURE__EXCESS_CODE_CK,
        t0.addon_excess as POLICY_EXCESS_STRUCTURE__EXCESS_AMOUNT,
        t0.excess_type as POLICY_EXCESS_STRUCTURE__EXCESS_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.cgst_amount as POLICY_TAX_BREAKUP__CGST_AMOUNT,
        null, null, null,
        t0.consumption_state as POLICY_TAX_BREAKUP__PLACE_OF_SUPPLY,
        null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_number),''), '')) is not null

    union all

    -- branch 4: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null, null, null,
        nullif(coalesce(nullif(trim(t0.policyquote_number),''), nullif(trim(j4.policy_number),'')), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        nullif(trim(j4.agent_code),'') as AUG_POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE_CK,
        null,
        t0.loading_in_commission as AUG_POLICY_INTERMEDIARY_SPLIT__COMMISSION_LOADING_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.gst_tds as AUG_POLICY_TAX_BREAKUP__GST_TDS_AMOUNT,
        t0.gst_type as AUG_POLICY_TAX_BREAKUP__GST_TYPE,
        null, null, null, null, null, null,
        t0.geographical_extension as AUG_POLICY_TERMS__GEOGRAPHICAL_EXTENSION_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        t0.reason_for_cancel_and_reissue as POLICY_CANCELLATION__CANCELLATION_REASON,
        null, null, null,
        'IMPOSED' as POLICY_EXCESS_STRUCTURE__EXCESS_CODE_CK,
        t0.imposed_excess_rs as POLICY_EXCESS_STRUCTURE__EXCESS_AMOUNT,
        null, null, null, null, null, null,
        t0.gross_premium as POLICY_PREMIUM_SUMMARY__GROSS_PREMIUM,
        null,
        t0.loading_in_premium as POLICY_PREMIUM_SUMMARY__LOADING_AMOUNT,
        t0.minimum_premium_applicability as POLICY_PREMIUM_SUMMARY__MINIMUM_PREMIUM_APPLIED_INDICATOR,
        t0.net_premium_in_premium_currency as POLICY_PREMIUM_SUMMARY__NET_PREMIUM,
        null, null, null,
        t0.premium_collected as POLICY_PREMIUM_SUMMARY__TOTAL_PREMIUM_COLLECTED,
        null, null, null,
        t0.igst_amount as POLICY_TAX_BREAKUP__IGST_AMOUNT,
        null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(coalesce(nullif(trim(t0.policyquote_number),''), nullif(trim(j4.policy_number),'')), '')) is not null

    union all

    -- branch 5: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null, null, null,
        nullif(nullif(trim(j4.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        t0.tax_payment_cycle_ref_no as AUG_POLICY_TAX_BREAKUP__TAX_PAYMENT_CYCLE_REFERENCE_NUMBER,
        null,
        t0.total_taxes as AUG_POLICY_TAX_BREAKUP__TOTAL_TAX_AMOUNT,
        t0.utgst_amount as AUG_POLICY_TAX_BREAKUP__UTGST_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        'THEFT' as POLICY_EXCESS_STRUCTURE__EXCESS_CODE_CK,
        t0.theft_excess as POLICY_EXCESS_STRUCTURE__EXCESS_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.total_premium_due as POLICY_PREMIUM_SUMMARY__PREMIUM_OUTSTANDING,
        null, null, null, null, null, null, null, null,
        t0.sgst_amount as POLICY_TAX_BREAKUP__SGST_AMOUNT,
        t0.servicing_state as POLICY_TAX_BREAKUP__SUPPLIER_STATE_CODE,
        null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_number), ''), '')) is not null

    union all

    -- branch 6: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null, null, null,
        nullif(nullif(trim(j4.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'BATTERY_THEFT' as POLICY_EXCESS_STRUCTURE__EXCESS_CODE_CK,
        t0.battery_theft_excess as POLICY_EXCESS_STRUCTURE__EXCESS_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_number),''), '')) is not null

    union all

    -- branch 7: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null, null, null,
        nullif(nullif(trim(j4.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'COMPULSORY' as POLICY_EXCESS_STRUCTURE__EXCESS_CODE_CK,
        t0.compulsory_excess as POLICY_EXCESS_STRUCTURE__EXCESS_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_number),''), '')) is not null

    union all

    -- branch 8: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null, null, null,
        nullif(nullif(trim(j4.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ESCALATED' as POLICY_EXCESS_STRUCTURE__EXCESS_CODE_CK,
        t0.escalated_excess as POLICY_EXCESS_STRUCTURE__EXCESS_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_number),''), '')) is not null

    union all

    -- branch 9: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null, null, null,
        nullif(nullif(trim(j4.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EXCESS' as POLICY_EXCESS_STRUCTURE__EXCESS_CODE_CK,
        t0.excess as POLICY_EXCESS_STRUCTURE__EXCESS_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_number),''), '')) is not null

    union all

    -- branch 10: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null, null, null,
        nullif(coalesce(nullif(trim(t0.policyquote_number),''), nullif(trim(j4.policy_number),'')), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PARTIAL_THEFT' as POLICY_EXCESS_STRUCTURE__EXCESS_CODE_CK,
        t0.partial_theft_excess as POLICY_EXCESS_STRUCTURE__EXCESS_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(coalesce(nullif(trim(t0.policyquote_number),''), nullif(trim(j4.policy_number),'')), '')) is not null

    union all

    -- branch 11: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null, null, null,
        nullif(coalesce(nullif(trim(t0.policyquote_number),''), nullif(trim(j4.policy_number),'')), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'POLICY' as POLICY_EXCESS_STRUCTURE__EXCESS_CODE_CK,
        t0.policy_excess_rs as POLICY_EXCESS_STRUCTURE__EXCESS_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(coalesce(nullif(trim(t0.policyquote_number),''), nullif(trim(j4.policy_number),'')), '')) is not null

    union all

    -- branch 12: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null, null, null,
        nullif(coalesce(nullif(trim(t0.policyquote_number),''), nullif(trim(j4.policy_number),'')), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PREFERRED_GARAGE' as POLICY_EXCESS_STRUCTURE__EXCESS_CODE_CK,
        t0.preferred_garage_excess as POLICY_EXCESS_STRUCTURE__EXCESS_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(coalesce(nullif(trim(t0.policyquote_number),''), nullif(trim(j4.policy_number),'')), '')) is not null

    union all

    -- branch 13: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null, null, null,
        nullif(coalesce(nullif(trim(t0.policyquote_number),''), nullif(trim(j4.policy_number),'')), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'RALLY' as POLICY_EXCESS_STRUCTURE__EXCESS_CODE_CK,
        t0.rally_excess as POLICY_EXCESS_STRUCTURE__EXCESS_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(coalesce(nullif(trim(t0.policyquote_number),''), nullif(trim(j4.policy_number),'')), '')) is not null

    union all

    -- branch 14: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null, null, null,
        nullif(nullif(trim(j4.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'TOTAL_THEFT' as POLICY_EXCESS_STRUCTURE__EXCESS_CODE_CK,
        t0.total_theft_excess as POLICY_EXCESS_STRUCTURE__EXCESS_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_number), ''), '')) is not null

    union all

    -- branch 15: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null, null, null,
        nullif(nullif(trim(j4.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'UNDERWRITER' as POLICY_EXCESS_STRUCTURE__EXCESS_CODE_CK,
        t0.underwriter_excess as POLICY_EXCESS_STRUCTURE__EXCESS_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_number), ''), '')) is not null

    union all

    -- branch 16: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(t0.pre_inspection_number), ''), '') as ASSESSMENT_BK,
        nullif(nullif(trim(t0.rta_code), ''), '') as LOCATION_BK,
        nullif(nullif(trim(t0.branch_code), ''), '') as ORG_UNIT_BK,
        nullif('PAYEE:' || nullif(trim(t0.expense_payee_party_code), ''), '') as PARTY_BK,
        nullif(nullif(trim(j3.policy_number), ''), '') as POLICY_BK,
        nullif(nullif(trim(j3.product_code), ''), '') as PRODUCT_BK,
        nullif(nullif(trim(t0.app_no), ''), '') as PROPOSAL_BK,
        nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), '') as RISK_OBJECT_BK,
        null,
        t0.underwriting_rqrd_flag as ASSESSMENT_UNDERWRITING__REFERRAL_INDICATOR,
        t0.uw_ref_limit as AUG_ASSESSMENT_UNDERWRITING__REFERRAL_LIMIT_AMOUNT,
        t0.rta_cluster_name as AUG_COMMON_ADMIN_GEOGRAPHY__RTO_CLUSTER_CODE,
        t0.entry_time as AUG_COMMON_BUSINESS_AUDIT__CREATED_TIME,
        null, null, null, null,
        t0.calculated_amount_for_elapsed_period as AUG_POLICY_CANCELLATION__ELAPSED_PERIOD_PREMIUM_AMOUNT,
        null,
        t0.calculated_amount_for_remaining_period as AUG_POLICY_CANCELLATION__UNEXPIRED_PERIOD_PREMIUM_AMOUNT,
        t0.date_of_accident as AUG_POLICY_DECLARED_CLAIM_HISTORY__ACCIDENT_DATE,
        t0.accident_location as AUG_POLICY_DECLARED_CLAIM_HISTORY__ACCIDENT_LOCATION_DESCRIPTION,
        t0.case_filed_before as AUG_POLICY_DECLARED_CLAIM_HISTORY__CASE_FILED_BEFORE_FORUM,
        t0.areaclaim as AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_AREA_CODE,
        t0.claim_handling_location_codemact_location_code as AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_HANDLING_LOCATION_CODE,
        t0.claim_intimation_date as AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_INTIMATION_DATE,
        t0.claim_intimation_time as AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_INTIMATION_TIME,
        t0.claim_intimation_type as AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_INTIMATION_TYPE,
        t0.claim_intimator_mobile_number as AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_INTIMATOR_MOBILE_NUMBER,
        t0.claim_intimator_name as AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_INTIMATOR_NAME,
        t0.claim_location as AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_LOCATION_DESCRIPTION,
        t0.claim_registration_location_ as AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_REGISTRATION_LOCATION_CODE,
        t0.claim_requirement_status as AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_REQUIREMENT_STATUS,
        t0.claim_substatus as AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_SUB_STATUS,
        t0.claim_type as AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_TYPE,
        t0.claim_types as AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_TYPES_LIST,
        t0.court_location_as_per_intimation_details as AUG_POLICY_DECLARED_CLAIM_HISTORY__COURT_LOCATION_AS_PER_INTIMATION,
        t0.court_name_as_per_intimation_details as AUG_POLICY_DECLARED_CLAIM_HISTORY__COURT_NAME_AS_PER_INTIMATION,
        t0.court_type as AUG_POLICY_DECLARED_CLAIM_HISTORY__COURT_TYPE,
        t0.claim_amount as AUG_POLICY_DECLARED_CLAIM_HISTORY__DECLARED_CLAIM_AMOUNT,
        t0.claim_date as AUG_POLICY_DECLARED_CLAIM_HISTORY__DECLARED_CLAIM_DATE,
        t0.expense_fee_head_code as AUG_POLICY_DECLARED_CLAIM_HISTORY__EXPENSE_FEE_HEAD_CODE,
        t0.expense_payment_amount as AUG_POLICY_DECLARED_CLAIM_HISTORY__EXPENSE_PAYMENT_AMOUNT,
        t0.expense_payment_approved_by as AUG_POLICY_DECLARED_CLAIM_HISTORY__EXPENSE_PAYMENT_APPROVED_BY,
        t0.expense_payment_date as AUG_POLICY_DECLARED_CLAIM_HISTORY__EXPENSE_PAYMENT_DATE,
        t0.expense_payment_reference_no as AUG_POLICY_DECLARED_CLAIM_HISTORY__EXPENSE_PAYMENT_REFERENCE_NUMBER,
        t0.expense_payment_type as AUG_POLICY_DECLARED_CLAIM_HISTORY__EXPENSE_PAYMENT_TYPE,
        t0.expense_portal_payment_reference_number as AUG_POLICY_DECLARED_CLAIM_HISTORY__EXPENSE_PORTAL_PAYMENT_REFERENCE_NUMBER,
        t0.expense_reference_text as AUG_POLICY_DECLARED_CLAIM_HISTORY__EXPENSE_REFERENCE_TEXT,
        t0.cause_of_loss as AUG_POLICY_DECLARED_CLAIM_HISTORY__LOSS_CAUSE,
        t0.date_of_loss as AUG_POLICY_DECLARED_CLAIM_HISTORY__LOSS_DATE,
        t0.description_of_loss as AUG_POLICY_DECLARED_CLAIM_HISTORY__LOSS_DESCRIPTION,
        t0.about_loss_information as AUG_POLICY_DECLARED_CLAIM_HISTORY__LOSS_INFORMATION_DESCRIPTION,
        t0.cause_of_losspa as AUG_POLICY_DECLARED_CLAIM_HISTORY__PERSONAL_ACCIDENT_LOSS_CAUSE,
        null, null, null,
        t0.deficiency_status as AUG_POLICY_DOC_CHECKLIST__DEFICIENCY_STATUS,
        t0.active_tp_branch_address as AUG_POLICY_EXTERNAL_TP_LINK__TP_INSURER_BRANCH_ADDRESS_TEXT,
        t0.active_tp_claim_amount as AUG_POLICY_EXTERNAL_TP_LINK__TP_POLICY_CLAIM_AMOUNT,
        t0.active_tp_claim_date as AUG_POLICY_EXTERNAL_TP_LINK__TP_POLICY_CLAIM_DATE,
        null, null, null, null, null, null, null, null, null, null,
        t0.banca_charge_file_process_count as AUG_POLICY_SERVICING_SUMMARY__BANCASSURANCE_CHARGE_FILE_PROCESS_COUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.chassis_number_format as AUG_PRODUCT_TERMS__CHASSIS_NUMBER_VALIDATION_PATTERN,
        t0.engine_number_format as AUG_PRODUCT_TERMS__ENGINE_NUMBER_VALIDATION_PATTERN,
        t0.answer_set_indicator as AUG_PROPOSAL_HEADER__QUESTION_SET_REFERENCE,
        t0.bypass_rules as AUG_PROPOSAL_SCRUTINY__BYPASSED_RULE_LIST,
        null,
        t0.iibrefno as AUG_RISK_MOTOR_BUREAU_ENQUIRY__BUREAU_ENQUIRY_REFERENCE,
        t0.iib_od_claim_count as AUG_RISK_MOTOR_BUREAU_PROFILE__BUREAU_REPORTED_OWN_DAMAGE_CLAIM_COUNT,
        null,
        coalesce(t0.rta_cluster_name_addonncb, t0.rta_cluster_name_cd, t0.rta_cluster_name_clu_est1, t0.rta_cluster_name_clu_est10, t0.rta_cluster_name_clu_est11, t0.rta_cluster_name_clu_est12, t0.rta_cluster_name_clu_est14, t0.rta_cluster_name_clu_est19, t0.rta_cluster_name_clu_est1a, t0.rta_cluster_name_clu_est21, t0.rta_cluster_name_clu_est24, t0.rta_cluster_name_clu_est28, t0.rta_cluster_name_clu_est7, t0.rta_cluster_name_cpa, t0.rta_cluster_name_cvtp, t0.rta_cluster_name_excess, t0.rta_cluster_name_fixed, t0.rta_cluster_name_idv_dep, t0.rta_cluster_name_idv_var, t0.rta_cluster_name_min_prem, t0.rta_cluster_name_od_rate, t0.rta_cluster_name_pref, t0.rta_cluster_name_rn_exception, t0.rta_cluster_name_used_car, t0.rta_cluster_name_volex) as AUG_RISK_MOTOR_RATING_ZONE_HEAD__RTA_CLUSTER_NAME,
        'CURRENT_OWNER' as AUG_RISK_OBJECT_OWNERSHIP_HISTORY__OWNER_SEQUENCE_CK,
        t0.vehicle_transferred_to_whom as AUG_RISK_OBJECT_OWNERSHIP_HISTORY__TRANSFEREE_NAME,
        null, null,
        t0.created_by as COMMON_BUSINESS_AUDIT__CREATED_BY_USER_REFERENCE,
        t0.entry_date as COMMON_BUSINESS_AUDIT__CREATED_DATE,
        t0.data_source as COMMON_BUSINESS_AUDIT__SOURCE_APPLICATION_NAME,
        t0.effective_date as COMMON_LIFECYCLE__EFFECTIVE_DATE,
        null,
        nullif(trim(t0.expense_payee_stake_code),'') as LNK_PARTY_ROLE_CORE__ROLE_CODE_CK,
        null,
        t0.expense_payee_stake_code as LNK_PARTY_ROLE_CORE__ROLE_CODE,
        null,
        t0.reported_branch as ORG_UNIT_DEFINITION__ORG_UNIT_NAME,
        null, null,
        t0.cancelled_by as POLICY_CANCELLATION__CANCELLATION_REQUESTED_BY_ROLE,
        t0.cancellation_type as POLICY_CANCELLATION__CANCELLATION_TYPE,
        t0.cancellation_basis as POLICY_CANCELLATION__SHORT_PERIOD_BASIS,
        'ADDON' as POLICY_EXCESS_STRUCTURE__EXCESS_CODE_CK,
        t0.addon_excess as POLICY_EXCESS_STRUCTURE__EXCESS_AMOUNT,
        null, null, null, null, null,
        t0.base_premium as POLICY_PREMIUM_SUMMARY__BASE_PREMIUM,
        null, null, null, null, null, null, null, null,
        t0.amount_recevied as POLICY_PREMIUM_SUMMARY__TOTAL_PREMIUM_COLLECTED,
        t0.cgst_amount as POLICY_TAX_BREAKUP__CGST_AMOUNT,
        t0.cgst_percentage as POLICY_TAX_BREAKUP__CGST_RATE,
        null, null, null, null, null,
        t0.banca_decline_reason as PROPOSAL_HEADER__DECLINE_REASON,
        null,
        t0.member_name as RISK_PERSON_INSURED__INSURED_MEMBER_NAME,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_policy_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_policy_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (coalesce(nullif('PAYEE:' || nullif(trim(t0.expense_payee_party_code), ''), ''), nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), ''), nullif(nullif(trim(j3.policy_number), ''), ''), nullif(nullif(trim(j3.product_code), ''), ''), nullif(nullif(trim(t0.app_no), ''), ''), nullif(nullif(trim(t0.branch_code), ''), ''), nullif(nullif(trim(t0.pre_inspection_number), ''), ''), nullif(nullif(trim(t0.rta_code), ''), ''))) is not null

    union all

    -- branch 17: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | child-key literal(s): AUG_COMMON_CONTACT.Contact Point Type=CLAIMS_ALTERNATE_MOBILE
    select
        null, null, null,
        nullif(nullif(trim(j3.policy_holder_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null,
        'CLAIMS_ALTERNATE_MOBILE' as AUG_COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null,
        t0.alternate_mobile_number_belongs_to as AUG_COMMON_CONTACT__CONTACT_POINT_OWNER_RELATIONSHIP,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_policy_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_policy_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_holder_code), ''), '')) is not null

    union all

    -- branch 18: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null, null,
        nullif(nullif(trim(t0.premium_payer_id), ''), '') as PARTY_BK,
        nullif(nullif(trim(j3.policy_number), ''), '') as POLICY_BK,
        null, null, null,
        1 as __LNK_POLICY_PARTY,
        null, null, null, null, null, null, null,
        t0.payer_relation as AUG_LNK_POLICY_PARTY_ROLE__RELATIONSHIP_TO_INSURED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.qr_code as AUG_POLICY_DELIVERY__DOCUMENT_QR_CODE,
        t0.pod_details as AUG_POLICY_DELIVERY__PROOF_OF_DELIVERY_DETAILS,
        null, null, null, null, null, null, null, null,
        t0.lob_comm_flag as AUG_POLICY_INTERMEDIARY_SPLIT__LINE_OF_BUSINESS_COMMISSION_APPLICABLE_INDICATOR,
        t0.impacted_lob_commission as AUG_POLICY_INTERMEDIARY_SPLIT__LINE_OF_BUSINESS_COMMISSION_IMPACT_AMOUNT,
        null,
        t0.next_anniversary_date as AUG_POLICY_LIFECYCLE__NEXT_ANNIVERSARY_DATE,
        null, null, null, null, null, null, null, null,
        t0.gst_applicability as AUG_POLICY_TAX_BREAKUP__GST_APPLICABLE_INDICATOR,
        t0.gst_bifurcation as AUG_POLICY_TAX_BREAKUP__GST_BIFURCATION_BASIS,
        null,
        t0.gst_type as AUG_POLICY_TAX_BREAKUP__GST_TYPE,
        null, null, null, null, null,
        t0.franchise as AUG_POLICY_TERMS__FRANCHISE_AMOUNT,
        null,
        t0.nd_applicable_for_organization as AUG_POLICY_TERMS__NIL_DEPRECIATION_APPLICABLE_FOR_ORGANISATION_INDICATOR,
        t0.no_of_extension_days_for_od as AUG_POLICY_TERMS__OWN_DAMAGE_EXTENSION_DAYS,
        t0.present_quota_limit as AUG_POLICY_TERMS__PRESENT_QUOTA_LIMIT,
        t0.no_of_extension_days_for_tp as AUG_POLICY_TERMS__THIRD_PARTY_EXTENSION_DAYS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        'PARTIAL_THEFT' as POLICY_EXCESS_STRUCTURE__EXCESS_CODE_CK,
        t0.partial_theft_excess as POLICY_EXCESS_STRUCTURE__EXCESS_AMOUNT,
        null, null, null, null, null, null, null, null, null,
        t0.minimum_premium_applicability as POLICY_PREMIUM_SUMMARY__MINIMUM_PREMIUM_APPLIED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_policy_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_policy_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (coalesce(nullif(nullif(trim(j3.policy_number), ''), ''), nullif(nullif(trim(t0.premium_payer_id), ''), ''))) is not null

    union all

    -- branch 19: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null, null,
        nullif(nullif(trim(j3.policy_holder_code), ''), '') as PARTY_BK,
        nullif(coalesce(nullif(trim(t0.policy_number), ''), nullif(trim(j3.policy_number), '')), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.retained_admin_charges as AUG_POLICY_CANCELLATION__RETAINED_ADMINISTRATION_CHARGES,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        nullif(trim(j3.agent_code),'') as AUG_POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE_CK,
        null, null, null, null,
        t0.service_charge as AUG_POLICY_INTERMEDIARY_SPLIT__SERVICE_CHARGE_AMOUNT,
        null,
        t0.remaining_anniversary_counter as AUG_POLICY_LONG_TERM_DETAIL__REMAINING_ANNIVERSARY_COUNT,
        t0.renewal_profitable as AUG_POLICY_RENEWAL__PROFITABILITY_INDICATOR,
        null, null, null, null, null, null, null, null, null, null,
        t0.stamp_receipt_no as AUG_POLICY_TAX_BREAKUP__STAMP_DUTY_RECEIPT_NUMBER,
        null,
        t0.tds_applicability as AUG_POLICY_TAX_BREAKUP__TDS_APPLICABLE_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.campaign_code as PARTY_MARKETING__CAMPAIGN_REFERENCE,
        t0.reason_for_cancel_and_reissue as POLICY_CANCELLATION__CANCELLATION_REASON,
        null, null, null, null,
        coalesce(t0.total_theft_excess, t0.underwriter_excess, t0.voluntary_excess) as POLICY_EXCESS_STRUCTURE__EXCESS_AMOUNT,
        null,
        nullif(trim(j3.agent_code),'') as POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE_CK,
        null, null,
        t0.sub_imd_code as POLICY_INTERMEDIARY_SPLIT__SUB_IMD_CODE,
        null, null,
        t0.total_taxes as POLICY_PREMIUM_SUMMARY__GST_AMOUNT,
        null, null, null,
        t0.total_premium_due as POLICY_PREMIUM_SUMMARY__PREMIUM_OUTSTANDING,
        t0.refund_amount as POLICY_PREMIUM_SUMMARY__REFUND_AMOUNT,
        null, null, null, null,
        t0.total_gst_percentage as POLICY_TAX_BREAKUP__GST_RATE,
        null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_policy_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_policy_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (coalesce(nullif(coalesce(nullif(trim(t0.policy_number), ''), nullif(trim(j3.policy_number), '')), ''), nullif(nullif(trim(j3.policy_holder_code), ''), ''))) is not null

    union all

    -- branch 20: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | child-key literal(s): AUG_POLICY_SUM_INSURED_BREAKUP.Sum Insured Head=TOTAL_IN_SUM_INSURED_CURRENCY
    select
        null, null, null, null,
        nullif(coalesce(nullif(trim(t0.policy_number), ''), nullif(trim(j3.policy_number), '')), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'TOTAL_IN_SUM_INSURED_CURRENCY' as AUG_POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_HEAD_CK,
        t0.sum_insured_currency as AUG_POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_CURRENCY_CODE,
        t0.sum_insured_currency_exchange_rate as AUG_POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_CURRENCY_EXCHANGE_RATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_policy_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_policy_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(coalesce(nullif(trim(t0.policy_number), ''), nullif(trim(j3.policy_number), '')), '')) is not null

    union all

    -- branch 21: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null, null, null,
        nullif(nullif(trim(j3.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'BATTERY_THEFT' as POLICY_EXCESS_STRUCTURE__EXCESS_CODE_CK,
        t0.battery_theft_excess as POLICY_EXCESS_STRUCTURE__EXCESS_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_policy_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_policy_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_number), ''), '')) is not null

    union all

    -- branch 22: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null, null, null,
        nullif(nullif(trim(j3.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'COMPULSORY' as POLICY_EXCESS_STRUCTURE__EXCESS_CODE_CK,
        t0.compulsory_excess as POLICY_EXCESS_STRUCTURE__EXCESS_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_policy_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_policy_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_number), ''), '')) is not null

    union all

    -- branch 23: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null, null, null,
        nullif(nullif(trim(j3.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ESCALATED' as POLICY_EXCESS_STRUCTURE__EXCESS_CODE_CK,
        t0.escalated_excess as POLICY_EXCESS_STRUCTURE__EXCESS_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_policy_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_policy_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_number), ''), '')) is not null

    union all

    -- branch 24: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null, null, null,
        nullif(nullif(trim(j3.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PRE_INSPECTION' as POLICY_EXCESS_STRUCTURE__EXCESS_CODE_CK,
        t0.pin_excess_amount as POLICY_EXCESS_STRUCTURE__EXCESS_AMOUNT,
        t0.pin_excess as POLICY_EXCESS_STRUCTURE__EXCESS_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_policy_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_policy_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_number), ''), '')) is not null

    union all

    -- branch 25: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null, null, null,
        nullif(nullif(trim(j3.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PREFERRED_GARAGE' as POLICY_EXCESS_STRUCTURE__EXCESS_CODE_CK,
        t0.preferred_garage_excess as POLICY_EXCESS_STRUCTURE__EXCESS_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_policy_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_policy_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_number), ''), '')) is not null

    union all

    -- branch 26: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null, null, null,
        nullif(nullif(trim(j3.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'RALLY' as POLICY_EXCESS_STRUCTURE__EXCESS_CODE_CK,
        t0.rally_excess as POLICY_EXCESS_STRUCTURE__EXCESS_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_policy_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_policy_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_number), ''), '')) is not null

    union all

    -- branch 27: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_RELATION
    select
        null, null, null,
        nullif(nullif(trim(j1.party_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.stake_name as LNK_PARTY_ROLE_CORE__ROLE_CODE,
        t0.start_date as LNK_PARTY_ROLE_CORE__ROLE_START_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_relation') }} t0
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (nullif(nullif(trim(j1.party_code), ''), '')) is not null

    union all

    -- branch 28: MAXI_MOTOR_UWR_VW_DATA_PREMIUM_DETAILS
    select
        null, null, null, null,
        nullif(nullif(trim((case when x1._N = 1 then x1._V end)), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.outstanding_premium as POLICY_PREMIUM_SUMMARY__PREMIUM_OUTSTANDING,
        null, null,
        t0.collected_premium as POLICY_PREMIUM_SUMMARY__TOTAL_PREMIUM_COLLECTED,
        null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_premium_dtls') }} t0
    left join {{ ref('stg_mxm__uwr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.policy_number) as _V, count(distinct d0.policy_number) as _N
            from {{ ref('stg_mxm__uwr_pd') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j1.KEY_HASH
    where (nullif(nullif(trim((case when x1._N = 1 then x1._V end)), ''), '')) is not null

    union all

    -- branch 29: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        nullif(nullif(trim(t0.pre_inspection_number), ''), '') as ASSESSMENT_BK,
        nullif(nullif(trim(t0.rta_code), ''), '') as LOCATION_BK,
        nullif(nullif(trim(t0.branch_code), ''), '') as ORG_UNIT_BK,
        nullif('PAYEE:' || nullif(trim(t0.expense_payee_party_code), ''), '') as PARTY_BK,
        null,
        nullif(nullif(trim(j3.product_code), ''), '') as PRODUCT_BK,
        nullif(nullif(trim(t0.app_no), ''), '') as PROPOSAL_BK,
        nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), '') as RISK_OBJECT_BK,
        null,
        t0.underwriting_rqrd_flag as ASSESSMENT_UNDERWRITING__REFERRAL_INDICATOR,
        t0.uw_ref_limit as AUG_ASSESSMENT_UNDERWRITING__REFERRAL_LIMIT_AMOUNT,
        t0.rta_cluster_name as AUG_COMMON_ADMIN_GEOGRAPHY__RTO_CLUSTER_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.chassis_number_format as AUG_PRODUCT_TERMS__CHASSIS_NUMBER_VALIDATION_PATTERN,
        t0.engine_number_format as AUG_PRODUCT_TERMS__ENGINE_NUMBER_VALIDATION_PATTERN,
        t0.answer_set_indicator as AUG_PROPOSAL_HEADER__QUESTION_SET_REFERENCE,
        t0.bypass_rules as AUG_PROPOSAL_SCRUTINY__BYPASSED_RULE_LIST,
        null,
        t0.iibrefno as AUG_RISK_MOTOR_BUREAU_ENQUIRY__BUREAU_ENQUIRY_REFERENCE,
        t0.iib_od_claim_count as AUG_RISK_MOTOR_BUREAU_PROFILE__BUREAU_REPORTED_OWN_DAMAGE_CLAIM_COUNT,
        null,
        coalesce(t0.rta_cluster_name_addonncb, t0.rta_cluster_name_cd, t0.rta_cluster_name_clu_est1, t0.rta_cluster_name_clu_est10, t0.rta_cluster_name_clu_est11, t0.rta_cluster_name_clu_est12, t0.rta_cluster_name_clu_est14, t0.rta_cluster_name_clu_est19, t0.rta_cluster_name_clu_est1a, t0.rta_cluster_name_clu_est21, t0.rta_cluster_name_clu_est24, t0.rta_cluster_name_clu_est28, t0.rta_cluster_name_clu_est7, t0.rta_cluster_name_cpa, t0.rta_cluster_name_cvtp, t0.rta_cluster_name_excess, t0.rta_cluster_name_fixed, t0.rta_cluster_name_idv_dep, t0.rta_cluster_name_idv_var, t0.rta_cluster_name_min_prem, t0.rta_cluster_name_od_rate, t0.rta_cluster_name_pref, t0.rta_cluster_name_rn_exception, t0.rta_cluster_name_used_car, t0.rta_cluster_name_volex) as AUG_RISK_MOTOR_RATING_ZONE_HEAD__RTA_CLUSTER_NAME,
        'CURRENT_OWNER' as AUG_RISK_OBJECT_OWNERSHIP_HISTORY__OWNER_SEQUENCE_CK,
        t0.vehicle_transferred_to_whom as AUG_RISK_OBJECT_OWNERSHIP_HISTORY__TRANSFEREE_NAME,
        null, null, null, null, null, null, null,
        nullif(trim(t0.expense_payee_stake_code),'') as LNK_PARTY_ROLE_CORE__ROLE_CODE_CK,
        null,
        t0.expense_payee_stake_code as LNK_PARTY_ROLE_CORE__ROLE_CODE,
        null,
        t0.reported_branch as ORG_UNIT_DEFINITION__ORG_UNIT_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        t0.source_of_proposal as PROPOSAL_HEADER__SUBMISSION_CHANNEL,
        t0.member_name as RISK_PERSON_INSURED__INSURED_MEMBER_NAME,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (coalesce(nullif('PAYEE:' || nullif(trim(t0.expense_payee_party_code), ''), ''), nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), ''), nullif(nullif(trim(j3.product_code), ''), ''), nullif(nullif(trim(t0.app_no), ''), ''), nullif(nullif(trim(t0.branch_code), ''), ''), nullif(nullif(trim(t0.pre_inspection_number), ''), ''), nullif(nullif(trim(t0.rta_code), ''), ''))) is not null

    union all

    -- branch 30: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW | child-key literal(s): AUG_COMMON_CONTACT.Contact Point Type=CLAIMS_ALTERNATE_MOBILE
    select
        null, null, null,
        nullif(nullif(trim(j3.policy_holder_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null,
        'CLAIMS_ALTERNATE_MOBILE' as AUG_COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
        null,
        t0.alternate_mobile_number_belongs_to as AUG_COMMON_CONTACT__CONTACT_POINT_OWNER_RELATIONSHIP,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_holder_code), ''), '')) is not null

    union all

    -- branch 31: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null,
        nullif(nullif(trim(j3.policy_holder_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.campaign_code as PARTY_MARKETING__CAMPAIGN_REFERENCE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_holder_code), ''), '')) is not null

    union all

    -- branch 32: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST
    select
        null, null, null,
        nullif(nullif(trim(t0.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        nullif(trim(t0.billing_stake),'') as LNK_PARTY_ROLE_CORE__ROLE_CODE_CK,
        null,
        t0.billing_stake as LNK_PARTY_ROLE_CORE__ROLE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} t0
    where (nullif(nullif(trim(t0.party_code),''), '')) is not null

    union all

    -- branch 33: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY
    select
        null, null, null, null, null, null, null,
        nullif(nullif(trim(coalesce(nullif(trim(j2.policy_quote_number), ''), '') || '|' || coalesce(nullif(trim(j1.pol_risk_id), ''), '')), '|'), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        t0.event_code as AUG_RISK_OBJECT_PARAMETER__BUSINESS_EVENT_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(coalesce(nullif(trim(j2.policy_quote_number), ''), '') || '|' || coalesce(nullif(trim(j1.pol_risk_id), ''), '')), '|'), '')) is not null

)

select
    ASSESSMENT_BK,
    LOCATION_BK,
    ORG_UNIT_BK,
    PARTY_BK,
    POLICY_BK,
    PRODUCT_BK,
    PROPOSAL_BK,
    RISK_OBJECT_BK,
    __LNK_POLICY_PARTY,
    first_value(ASSESSMENT_UNDERWRITING__REFERRAL_INDICATOR) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_UNDERWRITING__REFERRAL_INDICATOR,
    first_value(AUG_ASSESSMENT_UNDERWRITING__REFERRAL_LIMIT_AMOUNT) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_UNDERWRITING__REFERRAL_LIMIT_AMOUNT,
    first_value(AUG_COMMON_ADMIN_GEOGRAPHY__RTO_CLUSTER_CODE) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COMMON_ADMIN_GEOGRAPHY__RTO_CLUSTER_CODE,
    first_value(AUG_COMMON_BUSINESS_AUDIT__CREATED_TIME) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COMMON_BUSINESS_AUDIT__CREATED_TIME,
    AUG_COMMON_CONTACT__CONTACT_POINT_TYPE_CK,
    AUG_COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK,
    first_value(AUG_COMMON_CONTACT__CONTACT_POINT_OWNER_RELATIONSHIP) ignore nulls over (partition by PARTY_BK, AUG_COMMON_CONTACT__CONTACT_POINT_TYPE_CK, AUG_COMMON_CONTACT__CONTACT_PRIORITY_ORDER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COMMON_CONTACT__CONTACT_POINT_OWNER_RELATIONSHIP,
    first_value(AUG_LNK_POLICY_PARTY_ROLE__RELATIONSHIP_TO_INSURED) ignore nulls over (partition by PARTY_BK, POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_LNK_POLICY_PARTY_ROLE__RELATIONSHIP_TO_INSURED,
    first_value(AUG_POLICY_CANCELLATION__ELAPSED_PERIOD_PREMIUM_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_CANCELLATION__ELAPSED_PERIOD_PREMIUM_AMOUNT,
    first_value(AUG_POLICY_CANCELLATION__RETAINED_ADMINISTRATION_CHARGES) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_CANCELLATION__RETAINED_ADMINISTRATION_CHARGES,
    first_value(AUG_POLICY_CANCELLATION__UNEXPIRED_PERIOD_PREMIUM_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_CANCELLATION__UNEXPIRED_PERIOD_PREMIUM_AMOUNT,
    first_value(AUG_POLICY_DECLARED_CLAIM_HISTORY__ACCIDENT_DATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_DECLARED_CLAIM_HISTORY__ACCIDENT_DATE,
    first_value(AUG_POLICY_DECLARED_CLAIM_HISTORY__ACCIDENT_LOCATION_DESCRIPTION) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_DECLARED_CLAIM_HISTORY__ACCIDENT_LOCATION_DESCRIPTION,
    first_value(AUG_POLICY_DECLARED_CLAIM_HISTORY__CASE_FILED_BEFORE_FORUM) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_DECLARED_CLAIM_HISTORY__CASE_FILED_BEFORE_FORUM,
    first_value(AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_AREA_CODE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_AREA_CODE,
    first_value(AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_HANDLING_LOCATION_CODE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_HANDLING_LOCATION_CODE,
    first_value(AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_INTIMATION_DATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_INTIMATION_DATE,
    first_value(AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_INTIMATION_TIME) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_INTIMATION_TIME,
    first_value(AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_INTIMATION_TYPE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_INTIMATION_TYPE,
    first_value(AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_INTIMATOR_MOBILE_NUMBER) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_INTIMATOR_MOBILE_NUMBER,
    first_value(AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_INTIMATOR_NAME) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_INTIMATOR_NAME,
    first_value(AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_LOCATION_DESCRIPTION) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_LOCATION_DESCRIPTION,
    first_value(AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_REGISTRATION_LOCATION_CODE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_REGISTRATION_LOCATION_CODE,
    first_value(AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_REQUIREMENT_STATUS) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_REQUIREMENT_STATUS,
    first_value(AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_SUB_STATUS) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_SUB_STATUS,
    first_value(AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_TYPE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_TYPE,
    first_value(AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_TYPES_LIST) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_DECLARED_CLAIM_HISTORY__CLAIM_TYPES_LIST,
    first_value(AUG_POLICY_DECLARED_CLAIM_HISTORY__COURT_LOCATION_AS_PER_INTIMATION) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_DECLARED_CLAIM_HISTORY__COURT_LOCATION_AS_PER_INTIMATION,
    first_value(AUG_POLICY_DECLARED_CLAIM_HISTORY__COURT_NAME_AS_PER_INTIMATION) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_DECLARED_CLAIM_HISTORY__COURT_NAME_AS_PER_INTIMATION,
    first_value(AUG_POLICY_DECLARED_CLAIM_HISTORY__COURT_TYPE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_DECLARED_CLAIM_HISTORY__COURT_TYPE,
    first_value(AUG_POLICY_DECLARED_CLAIM_HISTORY__DECLARED_CLAIM_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_DECLARED_CLAIM_HISTORY__DECLARED_CLAIM_AMOUNT,
    first_value(AUG_POLICY_DECLARED_CLAIM_HISTORY__DECLARED_CLAIM_DATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_DECLARED_CLAIM_HISTORY__DECLARED_CLAIM_DATE,
    first_value(AUG_POLICY_DECLARED_CLAIM_HISTORY__EXPENSE_FEE_HEAD_CODE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_DECLARED_CLAIM_HISTORY__EXPENSE_FEE_HEAD_CODE,
    first_value(AUG_POLICY_DECLARED_CLAIM_HISTORY__EXPENSE_PAYMENT_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_DECLARED_CLAIM_HISTORY__EXPENSE_PAYMENT_AMOUNT,
    first_value(AUG_POLICY_DECLARED_CLAIM_HISTORY__EXPENSE_PAYMENT_APPROVED_BY) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_DECLARED_CLAIM_HISTORY__EXPENSE_PAYMENT_APPROVED_BY,
    first_value(AUG_POLICY_DECLARED_CLAIM_HISTORY__EXPENSE_PAYMENT_DATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_DECLARED_CLAIM_HISTORY__EXPENSE_PAYMENT_DATE,
    first_value(AUG_POLICY_DECLARED_CLAIM_HISTORY__EXPENSE_PAYMENT_REFERENCE_NUMBER) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_DECLARED_CLAIM_HISTORY__EXPENSE_PAYMENT_REFERENCE_NUMBER,
    first_value(AUG_POLICY_DECLARED_CLAIM_HISTORY__EXPENSE_PAYMENT_TYPE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_DECLARED_CLAIM_HISTORY__EXPENSE_PAYMENT_TYPE,
    first_value(AUG_POLICY_DECLARED_CLAIM_HISTORY__EXPENSE_PORTAL_PAYMENT_REFERENCE_NUMBER) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_DECLARED_CLAIM_HISTORY__EXPENSE_PORTAL_PAYMENT_REFERENCE_NUMBER,
    first_value(AUG_POLICY_DECLARED_CLAIM_HISTORY__EXPENSE_REFERENCE_TEXT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_DECLARED_CLAIM_HISTORY__EXPENSE_REFERENCE_TEXT,
    first_value(AUG_POLICY_DECLARED_CLAIM_HISTORY__LOSS_CAUSE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_DECLARED_CLAIM_HISTORY__LOSS_CAUSE,
    first_value(AUG_POLICY_DECLARED_CLAIM_HISTORY__LOSS_DATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_DECLARED_CLAIM_HISTORY__LOSS_DATE,
    first_value(AUG_POLICY_DECLARED_CLAIM_HISTORY__LOSS_DESCRIPTION) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_DECLARED_CLAIM_HISTORY__LOSS_DESCRIPTION,
    first_value(AUG_POLICY_DECLARED_CLAIM_HISTORY__LOSS_INFORMATION_DESCRIPTION) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_DECLARED_CLAIM_HISTORY__LOSS_INFORMATION_DESCRIPTION,
    first_value(AUG_POLICY_DECLARED_CLAIM_HISTORY__PERSONAL_ACCIDENT_LOSS_CAUSE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_DECLARED_CLAIM_HISTORY__PERSONAL_ACCIDENT_LOSS_CAUSE,
    first_value(AUG_POLICY_DELIVERY__DOCUMENT_QR_CODE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_DELIVERY__DOCUMENT_QR_CODE,
    first_value(AUG_POLICY_DELIVERY__PROOF_OF_DELIVERY_DETAILS) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_DELIVERY__PROOF_OF_DELIVERY_DETAILS,
    AUG_POLICY_DOC_CHECKLIST__ACTIVE_SEQUENCE_NUMBER_CK,
    first_value(AUG_POLICY_DOC_CHECKLIST__DEFICIENCY_STATUS) ignore nulls over (partition by POLICY_BK, AUG_POLICY_DOC_CHECKLIST__ACTIVE_SEQUENCE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_DOC_CHECKLIST__DEFICIENCY_STATUS,
    first_value(AUG_POLICY_EXTERNAL_TP_LINK__TP_INSURER_BRANCH_ADDRESS_TEXT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_EXTERNAL_TP_LINK__TP_INSURER_BRANCH_ADDRESS_TEXT,
    first_value(AUG_POLICY_EXTERNAL_TP_LINK__TP_POLICY_CLAIM_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_EXTERNAL_TP_LINK__TP_POLICY_CLAIM_AMOUNT,
    first_value(AUG_POLICY_EXTERNAL_TP_LINK__TP_POLICY_CLAIM_DATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_EXTERNAL_TP_LINK__TP_POLICY_CLAIM_DATE,
    AUG_POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE_CK,
    first_value(AUG_POLICY_INTERMEDIARY_SPLIT__COMMISSION_DISCOUNT_AMOUNT) ignore nulls over (partition by POLICY_BK, AUG_POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_INTERMEDIARY_SPLIT__COMMISSION_DISCOUNT_AMOUNT,
    first_value(AUG_POLICY_INTERMEDIARY_SPLIT__COMMISSION_LOADING_AMOUNT) ignore nulls over (partition by POLICY_BK, AUG_POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_INTERMEDIARY_SPLIT__COMMISSION_LOADING_AMOUNT,
    first_value(AUG_POLICY_INTERMEDIARY_SPLIT__LINE_OF_BUSINESS_COMMISSION_APPLICABLE_INDICATOR) ignore nulls over (partition by POLICY_BK, AUG_POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_INTERMEDIARY_SPLIT__LINE_OF_BUSINESS_COMMISSION_APPLICABLE_INDICATOR,
    first_value(AUG_POLICY_INTERMEDIARY_SPLIT__LINE_OF_BUSINESS_COMMISSION_IMPACT_AMOUNT) ignore nulls over (partition by POLICY_BK, AUG_POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_INTERMEDIARY_SPLIT__LINE_OF_BUSINESS_COMMISSION_IMPACT_AMOUNT,
    first_value(AUG_POLICY_INTERMEDIARY_SPLIT__SERVICE_CHARGE_AMOUNT) ignore nulls over (partition by POLICY_BK, AUG_POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_INTERMEDIARY_SPLIT__SERVICE_CHARGE_AMOUNT,
    first_value(AUG_POLICY_LIFECYCLE__NEXT_ANNIVERSARY_DATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_LIFECYCLE__NEXT_ANNIVERSARY_DATE,
    first_value(AUG_POLICY_LONG_TERM_DETAIL__REMAINING_ANNIVERSARY_COUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_LONG_TERM_DETAIL__REMAINING_ANNIVERSARY_COUNT,
    first_value(AUG_POLICY_RENEWAL__PROFITABILITY_INDICATOR) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_RENEWAL__PROFITABILITY_INDICATOR,
    first_value(AUG_POLICY_RENEWAL__RENEWAL_BUSINESS_INDICATOR) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_RENEWAL__RENEWAL_BUSINESS_INDICATOR,
    first_value(AUG_POLICY_SERVICING_SUMMARY__BANCASSURANCE_CHARGE_FILE_PROCESS_COUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_SERVICING_SUMMARY__BANCASSURANCE_CHARGE_FILE_PROCESS_COUNT,
    AUG_POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_HEAD_CK,
    first_value(AUG_POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_CURRENCY_CODE) ignore nulls over (partition by POLICY_BK, AUG_POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_HEAD_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_CURRENCY_CODE,
    first_value(AUG_POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_CURRENCY_EXCHANGE_RATE) ignore nulls over (partition by POLICY_BK, AUG_POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_HEAD_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_CURRENCY_EXCHANGE_RATE,
    first_value(AUG_POLICY_TAX_BREAKUP__EXEMPTION_REASON) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_TAX_BREAKUP__EXEMPTION_REASON,
    first_value(AUG_POLICY_TAX_BREAKUP__GST_APPLICABLE_INDICATOR) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_TAX_BREAKUP__GST_APPLICABLE_INDICATOR,
    first_value(AUG_POLICY_TAX_BREAKUP__GST_BIFURCATION_BASIS) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_TAX_BREAKUP__GST_BIFURCATION_BASIS,
    first_value(AUG_POLICY_TAX_BREAKUP__GST_TDS_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_TAX_BREAKUP__GST_TDS_AMOUNT,
    first_value(AUG_POLICY_TAX_BREAKUP__GST_TYPE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_TAX_BREAKUP__GST_TYPE,
    first_value(AUG_POLICY_TAX_BREAKUP__STAMP_DUTY_RECEIPT_NUMBER) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_TAX_BREAKUP__STAMP_DUTY_RECEIPT_NUMBER,
    first_value(AUG_POLICY_TAX_BREAKUP__TAX_PAYMENT_CYCLE_REFERENCE_NUMBER) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_TAX_BREAKUP__TAX_PAYMENT_CYCLE_REFERENCE_NUMBER,
    first_value(AUG_POLICY_TAX_BREAKUP__TDS_APPLICABLE_INDICATOR) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_TAX_BREAKUP__TDS_APPLICABLE_INDICATOR,
    first_value(AUG_POLICY_TAX_BREAKUP__TOTAL_TAX_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_TAX_BREAKUP__TOTAL_TAX_AMOUNT,
    first_value(AUG_POLICY_TAX_BREAKUP__UTGST_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_TAX_BREAKUP__UTGST_AMOUNT,
    first_value(AUG_POLICY_TERMS__FRANCHISE_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_TERMS__FRANCHISE_AMOUNT,
    first_value(AUG_POLICY_TERMS__GEOGRAPHICAL_EXTENSION_CODE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_TERMS__GEOGRAPHICAL_EXTENSION_CODE,
    first_value(AUG_POLICY_TERMS__NIL_DEPRECIATION_APPLICABLE_FOR_ORGANISATION_INDICATOR) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_TERMS__NIL_DEPRECIATION_APPLICABLE_FOR_ORGANISATION_INDICATOR,
    first_value(AUG_POLICY_TERMS__OWN_DAMAGE_EXTENSION_DAYS) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_TERMS__OWN_DAMAGE_EXTENSION_DAYS,
    first_value(AUG_POLICY_TERMS__PRESENT_QUOTA_LIMIT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_TERMS__PRESENT_QUOTA_LIMIT,
    first_value(AUG_POLICY_TERMS__THIRD_PARTY_EXTENSION_DAYS) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_TERMS__THIRD_PARTY_EXTENSION_DAYS,
    first_value(AUG_POLICY_UNDERWRITING_WORKFLOW__ADDITIONAL_INFORMATION_TEXT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_UNDERWRITING_WORKFLOW__ADDITIONAL_INFORMATION_TEXT,
    first_value(AUG_POLICY_UNDERWRITING_WORKFLOW__DEFICIENCY_STATUS) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_UNDERWRITING_WORKFLOW__DEFICIENCY_STATUS,
    first_value(AUG_POLICY_UNDERWRITING_WORKFLOW__UNDERWRITER_ACCEPTANCE_DECISION) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_UNDERWRITING_WORKFLOW__UNDERWRITER_ACCEPTANCE_DECISION,
    first_value(AUG_PRODUCT_TERMS__CHASSIS_NUMBER_VALIDATION_PATTERN) ignore nulls over (partition by PRODUCT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_TERMS__CHASSIS_NUMBER_VALIDATION_PATTERN,
    first_value(AUG_PRODUCT_TERMS__ENGINE_NUMBER_VALIDATION_PATTERN) ignore nulls over (partition by PRODUCT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_TERMS__ENGINE_NUMBER_VALIDATION_PATTERN,
    first_value(AUG_PROPOSAL_HEADER__QUESTION_SET_REFERENCE) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PROPOSAL_HEADER__QUESTION_SET_REFERENCE,
    first_value(AUG_PROPOSAL_SCRUTINY__BYPASSED_RULE_LIST) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PROPOSAL_SCRUTINY__BYPASSED_RULE_LIST,
    AUG_RISK_MOTOR_BUREAU_ENQUIRY__BUREAU_ENQUIRY_REFERENCE_CK,
    first_value(AUG_RISK_MOTOR_BUREAU_ENQUIRY__BUREAU_ENQUIRY_REFERENCE) ignore nulls over (partition by RISK_OBJECT_BK, AUG_RISK_MOTOR_BUREAU_ENQUIRY__BUREAU_ENQUIRY_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_BUREAU_ENQUIRY__BUREAU_ENQUIRY_REFERENCE,
    first_value(AUG_RISK_MOTOR_BUREAU_PROFILE__BUREAU_REPORTED_OWN_DAMAGE_CLAIM_COUNT) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_BUREAU_PROFILE__BUREAU_REPORTED_OWN_DAMAGE_CLAIM_COUNT,
    AUG_RISK_MOTOR_RATING_ZONE_HEAD__RATING_HEAD_CODE_CK,
    first_value(AUG_RISK_MOTOR_RATING_ZONE_HEAD__RTA_CLUSTER_NAME) ignore nulls over (partition by RISK_OBJECT_BK, AUG_RISK_MOTOR_RATING_ZONE_HEAD__RATING_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_RATING_ZONE_HEAD__RTA_CLUSTER_NAME,
    AUG_RISK_OBJECT_OWNERSHIP_HISTORY__OWNER_SEQUENCE_CK,
    first_value(AUG_RISK_OBJECT_OWNERSHIP_HISTORY__TRANSFEREE_NAME) ignore nulls over (partition by RISK_OBJECT_BK, AUG_RISK_OBJECT_OWNERSHIP_HISTORY__OWNER_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_OBJECT_OWNERSHIP_HISTORY__TRANSFEREE_NAME,
    AUG_RISK_OBJECT_PARAMETER__PARAMETER_REFERENCE_CK,
    first_value(AUG_RISK_OBJECT_PARAMETER__BUSINESS_EVENT_CODE) ignore nulls over (partition by RISK_OBJECT_BK, AUG_RISK_OBJECT_PARAMETER__PARAMETER_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_OBJECT_PARAMETER__BUSINESS_EVENT_CODE,
    first_value(COMMON_BUSINESS_AUDIT__CREATED_BY_USER_REFERENCE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_BUSINESS_AUDIT__CREATED_BY_USER_REFERENCE,
    first_value(COMMON_BUSINESS_AUDIT__CREATED_DATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_BUSINESS_AUDIT__CREATED_DATE,
    first_value(COMMON_BUSINESS_AUDIT__SOURCE_APPLICATION_NAME) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_BUSINESS_AUDIT__SOURCE_APPLICATION_NAME,
    first_value(COMMON_LIFECYCLE__EFFECTIVE_DATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_LIFECYCLE__EFFECTIVE_DATE,
    first_value(COMMON_LIFECYCLE__EXPIRY_DATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_LIFECYCLE__EXPIRY_DATE,
    LNK_PARTY_ROLE_CORE__ROLE_CODE_CK,
    LNK_PARTY_ROLE_CORE__ROLE_SEQUENCE_CK,
    first_value(LNK_PARTY_ROLE_CORE__ROLE_CODE) ignore nulls over (partition by PARTY_BK, LNK_PARTY_ROLE_CORE__ROLE_CODE_CK, LNK_PARTY_ROLE_CORE__ROLE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_PARTY_ROLE_CORE__ROLE_CODE,
    first_value(LNK_PARTY_ROLE_CORE__ROLE_START_DATE) ignore nulls over (partition by PARTY_BK, LNK_PARTY_ROLE_CORE__ROLE_CODE_CK, LNK_PARTY_ROLE_CORE__ROLE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_PARTY_ROLE_CORE__ROLE_START_DATE,
    first_value(ORG_UNIT_DEFINITION__ORG_UNIT_NAME) ignore nulls over (partition by ORG_UNIT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ORG_UNIT_DEFINITION__ORG_UNIT_NAME,
    first_value(PARTY_MARKETING__CAMPAIGN_REFERENCE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_MARKETING__CAMPAIGN_REFERENCE,
    first_value(POLICY_CANCELLATION__CANCELLATION_REASON) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_CANCELLATION__CANCELLATION_REASON,
    first_value(POLICY_CANCELLATION__CANCELLATION_REQUESTED_BY_ROLE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_CANCELLATION__CANCELLATION_REQUESTED_BY_ROLE,
    first_value(POLICY_CANCELLATION__CANCELLATION_TYPE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_CANCELLATION__CANCELLATION_TYPE,
    first_value(POLICY_CANCELLATION__SHORT_PERIOD_BASIS) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_CANCELLATION__SHORT_PERIOD_BASIS,
    POLICY_EXCESS_STRUCTURE__EXCESS_CODE_CK,
    first_value(POLICY_EXCESS_STRUCTURE__EXCESS_AMOUNT) ignore nulls over (partition by POLICY_BK, POLICY_EXCESS_STRUCTURE__EXCESS_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_EXCESS_STRUCTURE__EXCESS_AMOUNT,
    first_value(POLICY_EXCESS_STRUCTURE__EXCESS_TYPE) ignore nulls over (partition by POLICY_BK, POLICY_EXCESS_STRUCTURE__EXCESS_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_EXCESS_STRUCTURE__EXCESS_TYPE,
    POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE_CK,
    first_value(POLICY_INTERMEDIARY_SPLIT__COMMISSION_AMOUNT) ignore nulls over (partition by POLICY_BK, POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_INTERMEDIARY_SPLIT__COMMISSION_AMOUNT,
    first_value(POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE) ignore nulls over (partition by POLICY_BK, POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE,
    first_value(POLICY_INTERMEDIARY_SPLIT__SUB_IMD_CODE) ignore nulls over (partition by POLICY_BK, POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_INTERMEDIARY_SPLIT__SUB_IMD_CODE,
    first_value(POLICY_PREMIUM_SUMMARY__BASE_PREMIUM) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PREMIUM_SUMMARY__BASE_PREMIUM,
    first_value(POLICY_PREMIUM_SUMMARY__GROSS_PREMIUM) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PREMIUM_SUMMARY__GROSS_PREMIUM,
    first_value(POLICY_PREMIUM_SUMMARY__GST_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PREMIUM_SUMMARY__GST_AMOUNT,
    first_value(POLICY_PREMIUM_SUMMARY__LOADING_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PREMIUM_SUMMARY__LOADING_AMOUNT,
    first_value(POLICY_PREMIUM_SUMMARY__MINIMUM_PREMIUM_APPLIED_INDICATOR) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PREMIUM_SUMMARY__MINIMUM_PREMIUM_APPLIED_INDICATOR,
    first_value(POLICY_PREMIUM_SUMMARY__NET_PREMIUM) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PREMIUM_SUMMARY__NET_PREMIUM,
    first_value(POLICY_PREMIUM_SUMMARY__PREMIUM_OUTSTANDING) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PREMIUM_SUMMARY__PREMIUM_OUTSTANDING,
    first_value(POLICY_PREMIUM_SUMMARY__REFUND_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PREMIUM_SUMMARY__REFUND_AMOUNT,
    first_value(POLICY_PREMIUM_SUMMARY__STAMP_DUTY_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PREMIUM_SUMMARY__STAMP_DUTY_AMOUNT,
    first_value(POLICY_PREMIUM_SUMMARY__TOTAL_PREMIUM_COLLECTED) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PREMIUM_SUMMARY__TOTAL_PREMIUM_COLLECTED,
    first_value(POLICY_TAX_BREAKUP__CGST_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_TAX_BREAKUP__CGST_AMOUNT,
    first_value(POLICY_TAX_BREAKUP__CGST_RATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_TAX_BREAKUP__CGST_RATE,
    first_value(POLICY_TAX_BREAKUP__GST_RATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_TAX_BREAKUP__GST_RATE,
    first_value(POLICY_TAX_BREAKUP__IGST_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_TAX_BREAKUP__IGST_AMOUNT,
    first_value(POLICY_TAX_BREAKUP__PLACE_OF_SUPPLY) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_TAX_BREAKUP__PLACE_OF_SUPPLY,
    first_value(POLICY_TAX_BREAKUP__SGST_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_TAX_BREAKUP__SGST_AMOUNT,
    first_value(POLICY_TAX_BREAKUP__SUPPLIER_STATE_CODE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_TAX_BREAKUP__SUPPLIER_STATE_CODE,
    first_value(PROPOSAL_HEADER__DECLINE_REASON) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PROPOSAL_HEADER__DECLINE_REASON,
    first_value(PROPOSAL_HEADER__SUBMISSION_CHANNEL) ignore nulls over (partition by PROPOSAL_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PROPOSAL_HEADER__SUBMISSION_CHANNEL,
    first_value(RISK_PERSON_INSURED__INSURED_MEMBER_NAME) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_PERSON_INSURED__INSURED_MEMBER_NAME,
    -- the row's own source time: LOAD_DATETIME for hubs, links and single-active satellites
    m.REC_REFRESH_AT,
    -- multi-active satellites on PARTY_BK (SAT_MOTOR_AUG_COMMON_CONTACT, SAT_LNK_PARTY_ROLE_CORE):
    -- one load time per PARTY_BK, the newest REC_REFRESH_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when coalesce(m.AUG_COMMON_CONTACT__CONTACT_POINT_OWNER_RELATIONSHIP, m.LNK_PARTY_ROLE_CORE__ROLE_CODE, m.LNK_PARTY_ROLE_CORE__ROLE_START_DATE) is not null
             then m.REC_REFRESH_AT end)
        over (partition by m.PARTY_BK) as PARTY_BK__MA_LOAD_DATETIME,
    -- multi-active satellites on POLICY_BK (SAT_MOTOR_AUG_POLICY_DOC_CHECKLIST, SAT_MOTOR_AUG_POLICY_INTERMEDIARY_SPLIT, SAT_MOTOR_AUG_POLICY_SUM_INSURED_BREAKUP, SAT_POLICY_EXCESS_STRUCTURE, SAT_POLICY_INTERMEDIARY_SPLIT):
    -- one load time per POLICY_BK, the newest REC_REFRESH_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when coalesce(m.AUG_POLICY_DOC_CHECKLIST__DEFICIENCY_STATUS, m.AUG_POLICY_INTERMEDIARY_SPLIT__COMMISSION_DISCOUNT_AMOUNT, m.AUG_POLICY_INTERMEDIARY_SPLIT__COMMISSION_LOADING_AMOUNT, m.AUG_POLICY_INTERMEDIARY_SPLIT__LINE_OF_BUSINESS_COMMISSION_APPLICABLE_INDICATOR, m.AUG_POLICY_INTERMEDIARY_SPLIT__LINE_OF_BUSINESS_COMMISSION_IMPACT_AMOUNT, m.AUG_POLICY_INTERMEDIARY_SPLIT__SERVICE_CHARGE_AMOUNT, m.AUG_POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_CURRENCY_CODE, m.AUG_POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_CURRENCY_EXCHANGE_RATE, m.POLICY_EXCESS_STRUCTURE__EXCESS_AMOUNT, m.POLICY_EXCESS_STRUCTURE__EXCESS_TYPE, m.POLICY_INTERMEDIARY_SPLIT__COMMISSION_AMOUNT, m.POLICY_INTERMEDIARY_SPLIT__INTERMEDIARY_REFERENCE, m.POLICY_INTERMEDIARY_SPLIT__SUB_IMD_CODE) is not null
             then m.REC_REFRESH_AT end)
        over (partition by m.POLICY_BK) as POLICY_BK__MA_LOAD_DATETIME,
    -- multi-active satellites on RISK_OBJECT_BK (SAT_MOTOR_AUG_RISK_MOTOR_BUREAU_ENQUIRY, SAT_MOTOR_AUG_RISK_MOTOR_RATING_ZONE_HEAD, SAT_MOTOR_AUG_RISK_OBJECT_OWNERSHIP_HISTORY, SAT_MOTOR_AUG_RISK_OBJECT_PARAMETER):
    -- one load time per RISK_OBJECT_BK, the newest REC_REFRESH_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when coalesce(m.AUG_RISK_MOTOR_BUREAU_ENQUIRY__BUREAU_ENQUIRY_REFERENCE, m.AUG_RISK_MOTOR_RATING_ZONE_HEAD__RTA_CLUSTER_NAME, m.AUG_RISK_OBJECT_OWNERSHIP_HISTORY__TRANSFEREE_NAME, m.AUG_RISK_OBJECT_PARAMETER__BUSINESS_EVENT_CODE) is not null
             then m.REC_REFRESH_AT end)
        over (partition by m.RISK_OBJECT_BK) as RISK_OBJECT_BK__MA_LOAD_DATETIME
from merged m
