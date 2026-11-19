-- CENTRAL VIEW v01_assessment -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_PROPERTIES_PIVOT_VW
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_SURVEYOR_DEPUTATION
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_TELE_VERIFICATION_DETAILS
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
-- Walk tables, joined only to resolve spine keys (not counted):
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_PROPERTIES
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_ASSESSMENT_FRAUD_INVESTIGATION
--   SAT_ASSESSMENT_HEADER
--   SAT_ASSESSMENT_SURVEY
--   SAT_MOTOR_AUG_ASSESSMENT_HEADER
--   SAT_MOTOR_AUG_ASSESSMENT_PRE_INSPECTION
--   SAT_MOTOR_AUG_ASSESSMENT_SURVEY
--   SAT_MOTOR_AUG_CLAIM_COVER_SECTION_ASSESSMENT
--   SAT_MOTOR_AUG_CLAIM_DEDUCTION_WAIVER
--   SAT_MOTOR_AUG_COVERAGE_CONDITIONS
--   SAT_MOTOR_AUG_COVERAGE_LIMITS
--   SAT_MOTOR_AUG_POLICY_COVERAGE_SCHEDULE
--   SAT_MOTOR_AUG_POLICY_PREMIUM_TENURE
--   SAT_MOTOR_AUG_QUOTE_COVERAGE_SCHEDULE
--   SAT_MOTOR_AUG_QUOTE_DISCOUNT_LOADING_APPLIED
--   SAT_MOTOR_AUG_QUOTE_PREMIUM_HEAD
--   SAT_MOTOR_AUG_QUOTE_SUM_INSURED_BREAKUP
--   SAT_CLAIM_DEDUCTION_WAIVER
--   SAT_CLAIM_PA_DETAIL
--   SAT_CLAIM_QUALITY_AUDIT
--   SAT_COVERAGE_LIMITS
--   SAT_QUOTE_RATING_INPUT
--   SAT_RISK_MOTOR_CPA
--   SAT_RISK_MOTOR_FITMENTS
--   SAT_RISK_MOTOR_IDV_TENURE
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_CLAIM_ASSESSMENT
--   LNK_CLAIM_COVERAGE
--   LNK_QUOTE_RISK_OBJECT
--   LNK_RISK_OBJECT_DOCUMENT
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(t0.assessment_no), ''), '') as ASSESSMENT_BK,
        cast(null as varchar) as CLAIM_BK,
        cast(null as varchar) as COVERAGE_BK,
        cast(null as varchar) as DOCUMENT_BK,
        cast(null as varchar) as POLICY_BK,
        cast(null as varchar) as QUOTE_BK,
        cast(null as varchar) as RISK_OBJECT_BK,
        cast(null as number) as __LNK_CLAIM_ASSESSMENT,
        cast(null as number) as __LNK_CLAIM_COVERAGE,
        cast(null as number) as __LNK_QUOTE_RISK_OBJECT,
        cast(null as number) as __LNK_RISK_OBJECT_DOCUMENT,
        cast(null as varchar) as ASSESSMENT_FRAUD_INVESTIGATION__FINDINGS_SUMMARY,
        cast(null as varchar) as ASSESSMENT_HEADER__ASSESSMENT_CHANNEL,
        cast(null as varchar) as ASSESSMENT_HEADER__ASSESSMENT_STATUS,
        cast(null as varchar) as ASSESSMENT_HEADER__ASSESSMENT_TYPE,
        cast(null as varchar) as ASSESSMENT_HEADER__ASSESSOR_REFERENCE,
        t0.date_of_survey as ASSESSMENT_HEADER__CONDUCTED_DATE,
        cast(null as varchar) as ASSESSMENT_HEADER__COST_OF_ASSESSMENT,
        cast(null as varchar) as ASSESSMENT_HEADER__REQUESTED_DATE,
        t0.final_survey_conductedod as ASSESSMENT_SURVEY__FINAL_SURVEY_INDICATOR,
        t0.final_survey_date as ASSESSMENT_SURVEY__FINAL_VISIT_DATE,
        cast(null as varchar) as ASSESSMENT_SURVEY__NUMBER_OF_VISITS,
        cast(null as varchar) as ASSESSMENT_SURVEY__SPOT_SURVEY_INDICATOR,
        cast(null as varchar) as ASSESSMENT_SURVEY__SURVEY_ALLOCATION_DATE,
        cast(null as varchar) as ASSESSMENT_SURVEY__SURVEY_TYPE,
        cast(null as varchar) as ASSESSMENT_SURVEY__WORK_APPROVAL_DATE,
        t0.ai_assessment_status as AUG_ASSESSMENT_HEADER__AI_ASSESSMENT_STATUS,
        cast(null as varchar) as AUG_ASSESSMENT_HEADER__ASSESSMENT_END_TIME,
        cast(null as varchar) as AUG_ASSESSMENT_HEADER__ASSESSMENT_NATURE,
        cast(null as varchar) as AUG_ASSESSMENT_HEADER__ASSESSMENT_REPORT_REFERENCE,
        cast(null as varchar) as AUG_ASSESSMENT_HEADER__ASSESSMENT_REVIEW_REMARKS,
        cast(null as varchar) as AUG_ASSESSMENT_HEADER__ASSESSMENT_SCALE,
        cast(null as varchar) as AUG_ASSESSMENT_HEADER__ASSESSMENT_START_TIME,
        cast(null as varchar) as AUG_ASSESSMENT_HEADER__CDC_REFERENCE_NUMBER,
        cast(null as varchar) as AUG_ASSESSMENT_HEADER__CDC_STATUS,
        cast(null as varchar) as AUG_ASSESSMENT_HEADER__DEPUTATION_CONFIRMATION_DATE,
        t0.ko_conducted_od as AUG_ASSESSMENT_HEADER__INSPECTION_CONDUCTED_INDICATOR,
        t0.other_remarks_ko_inspection as AUG_ASSESSMENT_HEADER__INSPECTION_OTHER_REMARKS,
        cast(null as varchar) as AUG_ASSESSMENT_HEADER__PERSONAL_ACCIDENT_ASSESSMENT_ACTION,
        cast(null as varchar) as AUG_ASSESSMENT_PRE_INSPECTION__IMPOSED_EXCESS_AMOUNT,
        cast(null as varchar) as AUG_ASSESSMENT_PRE_INSPECTION__IMPOSED_EXCESS_INDICATOR,
        t0.delay_in_ko_inspection as AUG_ASSESSMENT_PRE_INSPECTION__INSPECTION_DELAY_DAYS,
        cast(null as varchar) as AUG_ASSESSMENT_PRE_INSPECTION__OWN_DAMAGE_INSPECTION_LOCATION_ADDRESS,
        t0.final_survey_remarks as AUG_ASSESSMENT_SURVEY__FINAL_SURVEY_REMARKS,
        t0.final_survey_time as AUG_ASSESSMENT_SURVEY__FINAL_VISIT_TIME,
        cast(null as varchar) as AUG_ASSESSMENT_SURVEY__LIVE_VIDEO_SURVEY_INDICATOR,
        t0.delay_in_preliminary_survey_report_psr as AUG_ASSESSMENT_SURVEY__PRELIMINARY_SURVEY_REPORT_DELAY_DAYS,
        t0.delay_reason_of_preliminary_survey_report as AUG_ASSESSMENT_SURVEY__PRELIMINARY_SURVEY_REPORT_DELAY_REASON,
        t0.delay_remarks_of_preliminary_survey_report as AUG_ASSESSMENT_SURVEY__PRELIMINARY_SURVEY_REPORT_DELAY_REMARKS,
        cast(null as varchar) as AUG_ASSESSMENT_SURVEY__SPOT_SURVEY_DATE,
        t0.delay_in_spot_survey as AUG_ASSESSMENT_SURVEY__SPOT_SURVEY_DELAY_DAYS,
        cast(null as varchar) as AUG_ASSESSMENT_SURVEY__SPOT_SURVEY_OTHER_REMARKS,
        cast(null as varchar) as AUG_ASSESSMENT_SURVEY__SPOT_SURVEY_REMARKS,
        cast(null as varchar) as AUG_ASSESSMENT_SURVEY__SPOT_SURVEY_TIME,
        cast(null as varchar) as AUG_ASSESSMENT_SURVEY__SURVEYOR_GENERAL_OBSERVATIONS,
        t0.gscrsurisaveindicator as AUG_ASSESSMENT_SURVEY__SURVEYOR_SCREEN_SAVE_INDICATOR_IS,
        t0.gscrsurpasaveindicator as AUG_ASSESSMENT_SURVEY__SURVEYOR_SCREEN_SAVE_INDICATOR_PA,
        cast(null as varchar) as AUG_ASSESSMENT_SURVEY__SURVEYOR_TECHNICAL_OBSERVATIONS,
        t0.delay_in_survey_confirmation as AUG_ASSESSMENT_SURVEY__SURVEY_CONFIRMATION_DELAY_DAYS,
        cast(null as varchar) as AUG_ASSESSMENT_SURVEY__SURVEY_CONFIRMATION_OTHER_REMARKS,
        t0.delay_in_work_approval as AUG_ASSESSMENT_SURVEY__WORK_APPROVAL_DELAY_DAYS,
        cast(null as varchar) as AUG_ASSESSMENT_SURVEY__WORK_APPROVAL_OTHER_REMARKS,
        cast(null as varchar) as AUG_ASSESSMENT_SURVEY__WORK_APPROVAL_REMARKS,
        cast(null as varchar) as AUG_ASSESSMENT_SURVEY__WORK_APPROVAL_TIME,
        cast(null as varchar) as AUG_CLAIM_COVER_SECTION_ASSESSMENT__ADVERSE_MEDICAL_HISTORY_FINDING,
        cast(null as varchar) as AUG_CLAIM_COVER_SECTION_ASSESSMENT__CASE_MANAGEMENT_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_COVER_SECTION_ASSESSMENT__NON_DISCLOSURE_FINDING,
        cast(null as varchar) as AUG_CLAIM_DEDUCTION_WAIVER__ADDITIONAL_EXCESS_WAIVED_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_DEDUCTION_WAIVER__COMPULSORY_EXCESS_WAIVED_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_DEDUCTION_WAIVER__FRANCHISE_EXCESS_FOR_OWN_DAMAGE_WAIVED_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_DEDUCTION_WAIVER__VOLUNTARY_EXCESS_WAIVED_INDICATOR,
        cast(null as varchar) as AUG_COVERAGE_CONDITIONS__CONDITIONAL_SECTION_REFERENCE,
        cast(null as varchar) as AUG_COVERAGE_CONDITIONS__GEOGRAPHICAL_EXTENSION_CODE,
        cast(null as varchar) as AUG_COVERAGE_CONDITIONS__MAXIMUM_AGE_ELIGIBLE,
        cast(null as varchar) as AUG_COVERAGE_CONDITIONS__NIL_DEPRECIATION_APPLICABLE_FOR_ORGANISATION_INDICATOR,
        cast(null as varchar) as AUG_COVERAGE_LIMITS__BENEFIT_PERIOD,
        cast(null as varchar) as AUG_COVERAGE_LIMITS__CLAIM_REGISTRATION_COUNT_LIMIT,
        cast(null as varchar) as AUG_COVERAGE_LIMITS__CLAIM_REGISTRATION_LIMIT,
        cast(null as varchar) as AUG_COVERAGE_LIMITS__COVERAGE_SUM_INSURED,
        cast(null as varchar) as AUG_COVERAGE_LIMITS__COVERAGE_SUM_INSURED_CURRENCY,
        cast(null as varchar) as AUG_COVERAGE_LIMITS__DAILY_ALLOWANCE_LIMIT,
        cast(null as varchar) as AUG_COVERAGE_LIMITS__LIMIT_AMOUNT_IN_USD,
        cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
        cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK,
        cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_AVAILED_FROM_DATE,
        cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_AVAILED_TO_DATE,
        cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_BASE_CURRENCY_CODE,
        cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_DELETED_INDICATOR,
        cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_DURATION,
        cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_NAME,
        cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_RECORD_EFFECTIVE_DATE,
        cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_RECORD_EXPIRY_DATE,
        cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_SUM_INSURED_CURRENCY_CODE,
        cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_TERM,
        cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_TERM_UNIT,
        cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_TRANSACTION_CURRENCY_CODE,
        cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__DISCOUNT_PERCENTAGE_APPLIED,
        cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__PLAN_REFERENCE,
        cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__PREMIUM_FOR_COVERAGE_IN_BASE_CURRENCY,
        cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__SUM_INSURED_IN_BASE_CURRENCY,
        cast(null as varchar) as AUG_POLICY_COVERAGE_SCHEDULE__SUM_INSURED_IN_TRANSACTION_CURRENCY,
        cast(null as varchar) as AUG_POLICY_PREMIUM_TENURE__TENURE_YEAR_CK,
        cast(null as varchar) as AUG_POLICY_PREMIUM_TENURE__PREMIUM_HEAD_CODE_CK,
        cast(null as varchar) as AUG_POLICY_PREMIUM_TENURE__EARNED_PREMIUM_AMOUNT,
        cast(null as varchar) as AUG_POLICY_PREMIUM_TENURE__EARNED_PREMIUM_SUB_TOTAL_AMOUNT,
        cast(null as varchar) as AUG_POLICY_PREMIUM_TENURE__HEAD_PREMIUM_AMOUNT,
        cast(null as varchar) as AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
        cast(null as varchar) as AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK,
        cast(null as varchar) as AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_AVAILED_FROM_DATE,
        cast(null as varchar) as AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_AVAILED_TO_DATE,
        cast(null as varchar) as AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_BASE_CURRENCY_CODE,
        cast(null as varchar) as AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_DELETED_INDICATOR,
        cast(null as varchar) as AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_DURATION,
        cast(null as varchar) as AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_END_DATE,
        cast(null as varchar) as AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_RECORD_EFFECTIVE_DATE,
        cast(null as varchar) as AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_RECORD_EXPIRY_DATE,
        cast(null as varchar) as AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_START_DATE,
        cast(null as varchar) as AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_STATUS,
        cast(null as varchar) as AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_SUM_INSURED_CURRENCY_CODE,
        cast(null as varchar) as AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_TERM,
        cast(null as varchar) as AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_TERM_UNIT,
        cast(null as varchar) as AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_TRANSACTION_CURRENCY_CODE,
        cast(null as varchar) as AUG_QUOTE_COVERAGE_SCHEDULE__DISCOUNT_PERCENTAGE_APPLIED,
        cast(null as varchar) as AUG_QUOTE_COVERAGE_SCHEDULE__PREMIUM_FOR_COVERAGE,
        cast(null as varchar) as AUG_QUOTE_COVERAGE_SCHEDULE__PREMIUM_FOR_COVERAGE_IN_BASE_CURRENCY,
        cast(null as varchar) as AUG_QUOTE_COVERAGE_SCHEDULE__SUM_INSURED,
        cast(null as varchar) as AUG_QUOTE_COVERAGE_SCHEDULE__SUM_INSURED_IN_BASE_CURRENCY,
        cast(null as varchar) as AUG_QUOTE_COVERAGE_SCHEDULE__SUM_INSURED_IN_TRANSACTION_CURRENCY,
        cast(null as varchar) as AUG_QUOTE_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        cast(null as varchar) as AUG_QUOTE_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        cast(null as varchar) as AUG_QUOTE_DISCOUNT_LOADING_APPLIED__COMMISSION_DISCOUNT_AMOUNT,
        cast(null as varchar) as AUG_QUOTE_DISCOUNT_LOADING_APPLIED__EXTRA_DISCOUNT_OPTED_INDICATOR,
        cast(null as varchar) as AUG_QUOTE_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED,
        cast(null as varchar) as AUG_QUOTE_DISCOUNT_LOADING_APPLIED__RATING_FACTOR_VALUE,
        cast(null as varchar) as AUG_QUOTE_PREMIUM_HEAD__TENURE_YEAR_CK,
        cast(null as varchar) as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        cast(null as varchar) as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        cast(null as varchar) as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        cast(null as varchar) as AUG_QUOTE_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK,
        cast(null as varchar) as AUG_QUOTE_PREMIUM_HEAD__BASE_AMOUNT,
        cast(null as varchar) as AUG_QUOTE_PREMIUM_HEAD__DISCOUNT_AMOUNT,
        cast(null as varchar) as AUG_QUOTE_PREMIUM_HEAD__EARNED_HEAD_PREMIUM,
        cast(null as varchar) as AUG_QUOTE_PREMIUM_HEAD__EARNED_PREMIUM_AMOUNT,
        cast(null as varchar) as AUG_QUOTE_PREMIUM_HEAD__EARNED_PREMIUM_SUB_TOTAL_AMOUNT,
        cast(null as varchar) as AUG_QUOTE_PREMIUM_HEAD__EXCHANGE_RATE_APPLIED,
        cast(null as varchar) as AUG_QUOTE_PREMIUM_HEAD__EXPIRING_PREMIUM_AMOUNT,
        cast(null as varchar) as AUG_QUOTE_PREMIUM_HEAD__FIXED_PREMIUM_SYSTEM_CODE,
        cast(null as varchar) as AUG_QUOTE_PREMIUM_HEAD__HEAD_PREMIUM_AMOUNT,
        cast(null as varchar) as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        cast(null as varchar) as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM_IN_BASE_CURRENCY,
        cast(null as varchar) as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_RATE_APPLIED,
        cast(null as varchar) as AUG_QUOTE_SUM_INSURED_BREAKUP__SUM_INSURED_HEAD_CK,
        cast(null as varchar) as AUG_QUOTE_SUM_INSURED_BREAKUP__HEAD_DESCRIPTION,
        cast(null as varchar) as AUG_QUOTE_SUM_INSURED_BREAKUP__SUM_INSURED_AMOUNT,
        cast(null as varchar) as CLAIM_DEDUCTION_WAIVER__GOODWILL_AMOUNT,
        cast(null as varchar) as CLAIM_DEDUCTION_WAIVER__GOODWILL_INDICATOR,
        cast(null as varchar) as CLAIM_DEDUCTION_WAIVER__WAIVER_INDICATOR,
        cast(null as varchar) as CLAIM_PA_DETAIL__INJURY_TYPE,
        cast(null as varchar) as CLAIM_QUALITY_AUDIT__LEAKAGE_IDENTIFIED_INDICATOR,
        cast(null as varchar) as COVERAGE_LIMITS__DEDUCTIBLE_AMOUNT,
        cast(null as varchar) as COVERAGE_LIMITS__EXCESS_AMOUNT,
        cast(null as varchar) as COVERAGE_LIMITS__FRANCHISE_AMOUNT,
        cast(null as varchar) as COVERAGE_LIMITS__INDEMNITY_PERIOD,
        cast(null as varchar) as COVERAGE_LIMITS__LIMIT_AMOUNT,
        cast(null as varchar) as COVERAGE_LIMITS__PER_PERSON_LIMIT,
        cast(null as varchar) as COVERAGE_LIMITS__VOLUNTARY_DEDUCTIBLE_AMOUNT,
        cast(null as varchar) as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        cast(null as varchar) as QUOTE_RATING_INPUT__FACTOR_VALUE,
        cast(null as varchar) as RISK_MOTOR_CPA__COMPULSORY_PA_EFFECTIVE_DATE,
        cast(null as varchar) as RISK_MOTOR_CPA__COMPULSORY_PA_EXPIRY_DATE,
        cast(null as varchar) as RISK_MOTOR_CPA__COMPULSORY_PA_OWNER_DRIVER_INDICATOR,
        cast(null as varchar) as RISK_MOTOR_CPA__COMPULSORY_PA_PREMIUM,
        cast(null as varchar) as RISK_MOTOR_CPA__COMPULSORY_PA_SUM_INSURED,
        cast(null as varchar) as RISK_MOTOR_CPA__COMPULSORY_PA_TENURE_YEARS,
        cast(null as varchar) as RISK_MOTOR_CPA__HANDICAPPED_VEHICLE_INDICATOR,
        cast(null as varchar) as RISK_MOTOR_CPA__OWNER_DRIVER_LICENCE_EXISTS_INDICATOR,
        cast(null as varchar) as RISK_MOTOR_FITMENTS__FITMENT_TYPE_CK,
        cast(null as varchar) as RISK_MOTOR_FITMENTS__SEQUENCE_CK,
        cast(null as varchar) as RISK_MOTOR_FITMENTS__FITMENT_DESCRIPTION,
        cast(null as varchar) as RISK_MOTOR_IDV_TENURE__TENURE_YEAR_CK,
        cast(null as varchar) as RISK_MOTOR_IDV_TENURE__IDV_COMPONENT_CK,
        cast(null as varchar) as RISK_MOTOR_IDV_TENURE__AGREED_IDV,
        t0.rec_refresh_at as REC_REFRESH_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop_pv') }} t0
    where (nullif(nullif(trim(t0.assessment_no), ''), '')) is not null

    union all

    -- branch 1: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(t0.preliminary_assesment_number), ''), '') as ASSESSMENT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.preliminary_assesment_date as ASSESSMENT_HEADER__CONDUCTED_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop_pv') }} t0
    where (nullif(nullif(trim(t0.preliminary_assesment_number), ''), '')) is not null

    union all

    -- branch 2: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(t0.survey_number), ''), '') as ASSESSMENT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.no_of_visits as ASSESSMENT_SURVEY__NUMBER_OF_VISITS,
        t0.spot_survey_conducted_od as ASSESSMENT_SURVEY__SPOT_SURVEY_INDICATOR,
        null,
        t0.survey_type as ASSESSMENT_SURVEY__SURVEY_TYPE,
        t0.work_approval_date as ASSESSMENT_SURVEY__WORK_APPROVAL_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.live_video_survey_flag as AUG_ASSESSMENT_SURVEY__LIVE_VIDEO_SURVEY_INDICATOR,
        null, null, null,
        t0.spot_survey_date as AUG_ASSESSMENT_SURVEY__SPOT_SURVEY_DATE,
        null,
        t0.other_remarks_spot_survey as AUG_ASSESSMENT_SURVEY__SPOT_SURVEY_OTHER_REMARKS,
        t0.spot_survey_remarks as AUG_ASSESSMENT_SURVEY__SPOT_SURVEY_REMARKS,
        t0.spot_survey_time as AUG_ASSESSMENT_SURVEY__SPOT_SURVEY_TIME,
        t0.surveyor_general_observations as AUG_ASSESSMENT_SURVEY__SURVEYOR_GENERAL_OBSERVATIONS,
        null, null,
        t0.surveyor_technical_observations as AUG_ASSESSMENT_SURVEY__SURVEYOR_TECHNICAL_OBSERVATIONS,
        null,
        t0.other_remarks_survey_confirmation as AUG_ASSESSMENT_SURVEY__SURVEY_CONFIRMATION_OTHER_REMARKS,
        null,
        t0.other_remarks_work_aproval as AUG_ASSESSMENT_SURVEY__WORK_APPROVAL_OTHER_REMARKS,
        t0.work_approval_remark as AUG_ASSESSMENT_SURVEY__WORK_APPROVAL_REMARKS,
        t0.work_approval_time as AUG_ASSESSMENT_SURVEY__WORK_APPROVAL_TIME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop_pv') }} t0
    where (nullif(nullif(trim(t0.survey_number), ''), '')) is not null

    union all

    -- branch 3: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_PROPERTIES_PIVOT_VW
    select
        nullif(nullif(trim(t0.assessment_no),''), '') as ASSESSMENT_BK,
        nullif(nullif(trim(j4.claimno), ''), '') as CLAIM_BK,
        nullif(nullif(trim(t0.cover_code),''), '') as COVERAGE_BK,
        null, null, null, null,
        1 as __LNK_CLAIM_ASSESSMENT,
        1 as __LNK_CLAIM_COVERAGE,
        null, null,
        t0.investigation_findings as ASSESSMENT_FRAUD_INVESTIGATION__FINDINGS_SUMMARY,
        null, null,
        t0.assessmenttype as ASSESSMENT_HEADER__ASSESSMENT_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.assessmentnature as AUG_ASSESSMENT_HEADER__ASSESSMENT_NATURE,
        null,
        t0.assessment_review_remarksassm as AUG_ASSESSMENT_HEADER__ASSESSMENT_REVIEW_REMARKS,
        t0.assessmentscale as AUG_ASSESSMENT_HEADER__ASSESSMENT_SCALE,
        null, null, null, null, null, null,
        t0.assessment_actionpa as AUG_ASSESSMENT_HEADER__PERSONAL_ACCIDENT_ASSESSMENT_ACTION,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.surveyor_general_observations as AUG_ASSESSMENT_SURVEY__SURVEYOR_GENERAL_OBSERVATIONS,
        null, null,
        t0.surveyor_technical_observations as AUG_ASSESSMENT_SURVEY__SURVEYOR_TECHNICAL_OBSERVATIONS,
        null, null, null, null,
        t0.work_approval_remarks as AUG_ASSESSMENT_SURVEY__WORK_APPROVAL_REMARKS,
        null,
        t0.adverse_medical_history as AUG_CLAIM_COVER_SECTION_ASSESSMENT__ADVERSE_MEDICAL_HISTORY_FINDING,
        t0.case_management as AUG_CLAIM_COVER_SECTION_ASSESSMENT__CASE_MANAGEMENT_INDICATOR,
        t0.non_disclosure as AUG_CLAIM_COVER_SECTION_ASSESSMENT__NON_DISCLOSURE_FINDING,
        t0.is_additional_excess_waived_off as AUG_CLAIM_DEDUCTION_WAIVER__ADDITIONAL_EXCESS_WAIVED_INDICATOR,
        t0.is_compulsory_excess_waived_off as AUG_CLAIM_DEDUCTION_WAIVER__COMPULSORY_EXCESS_WAIVED_INDICATOR,
        t0.is_franchise_excess_for_od_waived_off as AUG_CLAIM_DEDUCTION_WAIVER__FRANCHISE_EXCESS_FOR_OWN_DAMAGE_WAIVED_INDICATOR,
        t0.is_voluntary_excess_waived_off as AUG_CLAIM_DEDUCTION_WAIVER__VOLUNTARY_EXCESS_WAIVED_INDICATOR,
        null, null, null, null, null, null, null,
        t0.cover_sum_insured as AUG_COVERAGE_LIMITS__COVERAGE_SUM_INSURED,
        t0.cover_sum_insured_currency as AUG_COVERAGE_LIMITS__COVERAGE_SUM_INSURED_CURRENCY,
        null,
        t0.benefit_limit_usd as AUG_COVERAGE_LIMITS__LIMIT_AMOUNT_IN_USD,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.goodwill_direct_settlement_amount as CLAIM_DEDUCTION_WAIVER__GOODWILL_AMOUNT,
        t0.goodwill_settlement as CLAIM_DEDUCTION_WAIVER__GOODWILL_INDICATOR,
        t0.deductible_waived as CLAIM_DEDUCTION_WAIVER__WAIVER_INDICATOR,
        t0.nature_of_injurypa_admissibility as CLAIM_PA_DETAIL__INJURY_TYPE,
        t0.potential_leakage as CLAIM_QUALITY_AUDIT__LEAKAGE_IDENTIFIED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_properties_pv') }} t0
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_properties') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (coalesce(nullif(nullif(trim(j4.claimno), ''), ''), nullif(nullif(trim(t0.assessment_no),''), ''), nullif(nullif(trim(t0.cover_code),''), ''))) is not null

    union all

    -- branch 4: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_SURVEYOR_DEPUTATION
    select
        nullif(nullif(trim(t0.deputation_number),''), '') as ASSESSMENT_BK,
        nullif(nullif(trim(j1.claimno),''), '') as CLAIM_BK,
        null, null, null, null, null,
        1 as __LNK_CLAIM_ASSESSMENT,
        null, null, null, null, null,
        t0.survey_status as ASSESSMENT_HEADER__ASSESSMENT_STATUS,
        null,
        t0.surveyor_code as ASSESSMENT_HEADER__ASSESSOR_REFERENCE,
        null, null, null, null, null, null, null,
        t0.notification_date as ASSESSMENT_SURVEY__SURVEY_ALLOCATION_DATE,
        t0.survey_type as ASSESSMENT_SURVEY__SURVEY_TYPE,
        null, null, null, null, null, null, null, null,
        t0.cdc_number as AUG_ASSESSMENT_HEADER__CDC_REFERENCE_NUMBER,
        t0.cdc_status as AUG_ASSESSMENT_HEADER__CDC_STATUS,
        t0.confirmation_date as AUG_ASSESSMENT_HEADER__DEPUTATION_CONFIRMATION_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_surveyor_deputation') }} t0
    left join {{ ref('stg_mxm__clm_cd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (coalesce(nullif(nullif(trim(j1.claimno),''), ''), nullif(nullif(trim(t0.deputation_number),''), ''))) is not null

    union all

    -- branch 5: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null,
        nullif('COV:' || nullif(trim(j3.cover_code), ''), '') as COVERAGE_BK,
        nullif('CERT:' || nullif(trim(t0.certificate_number), ''), '') as DOCUMENT_BK,
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null,
        nullif(nullif(trim(j4.pol_risk_id), ''), '') as RISK_OBJECT_BK,
        null, null, null,
        1 as __LNK_RISK_OBJECT_DOCUMENT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.cover_max_age as AUG_COVERAGE_CONDITIONS__MAXIMUM_AGE_ELIGIBLE,
        null, null,
        t0.claim_registration_limit as AUG_COVERAGE_LIMITS__CLAIM_REGISTRATION_COUNT_LIMIT,
        null, null, null,
        t0.daily_allowance_limit as AUG_COVERAGE_LIMITS__DAILY_ALLOWANCE_LIMIT,
        null,
        nullif(trim(j3.cover_code),'') as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
        null,
        t0.cover_availed_from as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_AVAILED_FROM_DATE,
        t0.cover_availed_to as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_AVAILED_TO_DATE,
        t0.cover_level_base_currency as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_BASE_CURRENCY_CODE,
        t0.delete_risk_cover_ind as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_DELETED_INDICATOR,
        t0.cover_duration as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_DURATION,
        null,
        t0.effective_date as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_RECORD_EFFECTIVE_DATE,
        t0.expiry_date as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_RECORD_EXPIRY_DATE,
        t0.cover_level_transaction_currency_for_sum_insured as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_SUM_INSURED_CURRENCY_CODE,
        t0.cover_term as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_TERM,
        t0.cover_term_unit as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_TERM_UNIT,
        t0.cover_level_transaction_currency as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_TRANSACTION_CURRENCY_CODE,
        t0.discount_percentage as AUG_POLICY_COVERAGE_SCHEDULE__DISCOUNT_PERCENTAGE_APPLIED,
        null,
        t0.cover_premium_in_base_currency as AUG_POLICY_COVERAGE_SCHEDULE__PREMIUM_FOR_COVERAGE_IN_BASE_CURRENCY,
        t0.cover_sum_insured_in_base_currency as AUG_POLICY_COVERAGE_SCHEDULE__SUM_INSURED_IN_BASE_CURRENCY,
        t0.cover_sum_insured_in_transaction_currency as AUG_POLICY_COVERAGE_SCHEDULE__SUM_INSURED_IN_TRANSACTION_CURRENCY,
        null, null,
        coalesce(t0.earned_premium_antitheft_device_discount_1st_year, t0.earned_premium_attached_trailer, t0.earned_premium_automobile_association_member_1st_year, t0.earned_premium_basic_od_1_year, t0.earned_premium_cd_1st_year, t0.earned_premium_cng_kit_1_year, t0.earned_premium_courtesy_car_1st_year, t0.earned_premium_demo_extn_cover_1st_year, t0.earned_premium_driving_tuition_1st_year, t0.earned_premium_electrical_accessories_1st_year, t0.earned_premium_extended_stp_1st_year, t0.earned_premium_fibre_glass_fuel_tank_1st_year, t0.earned_premium_geog_extension_1st_year, t0.earned_premium_handicapped_discount_1st_year, t0.earned_premium_imported_vehicle_1st_year, t0.earned_premium_imt14, t0.earned_premium_imt23_1st_year, t0.earned_premium_imt34_1st_year, t0.earned_premium_imt43, t0.earned_premium_imt44, t0.earned_premium_imt45, t0.earned_premium_imt47, t0.earned_premium_imt53, t0.earned_premium_loss_of_accessories_1st_year, t0.earned_premium_ltd_1st_year, t0.earned_premium_ncb_1st_year, t0.earned_premium_nonelectrical_accessories_1st_year, t0.earned_premium_normal_rally_1st_year, t0.earned_premium_side_car_1st_year, t0.earned_premium_side_car_discount_1st_year, t0.earned_premium_speed_rally_1st_year, t0.earned_premium_use_within_own_premises_1st_year, t0.earned_premium_voluntary_deductible_1st_year) as AUG_POLICY_PREMIUM_TENURE__EARNED_PREMIUM_AMOUNT,
        coalesce(t0.earned_premium_sub_total_10_1st_year, t0.earned_premium_sub_total_11_1st_year, t0.earned_premium_sub_total_12_1st_year, t0.earned_premium_sub_total_13_1st_year, t0.earned_premium_sub_total_14_1st_year, t0.earned_premium_sub_total_15_1st_year, t0.earned_premium_sub_total_16_1st_year, t0.earned_premium_sub_total_1_1st_year, t0.earned_premium_sub_total_2_1st_year, t0.earned_premium_sub_total_3_1st_year, t0.earned_premium_sub_total_4_1st_year, t0.earned_premium_sub_total_5_1st_year, t0.earned_premium_sub_total_6_1st_year, t0.earned_premium_sub_total_7_1st_year, t0.earned_premium_sub_total_8_1st_year, t0.earned_premium_sub_total_9_1st_year) as AUG_POLICY_PREMIUM_TENURE__EARNED_PREMIUM_SUB_TOTAL_AMOUNT,
        coalesce(t0.accidents_tp_premium_1st_year, t0.accidents_tp_premium_2nd_year, t0.accidents_tp_premium_3rd_year, t0.accidents_tp_premium_4th_year, t0.accidents_tp_premium_5th_year, t0.add_on_premium_after_1st_year, t0.add_on_premium_after_2nd_year, t0.add_on_premium_after_3rd_year, t0.add_on_premium_after_4th_year, t0.add_on_premium_after_5th_year, t0.additional_od_premium_1st_year, t0.antitheft_device_discount_premium_1st_year, t0.antitheft_device_discount_premium_2nd_year, t0.antitheft_device_discount_premium_3rd_year, t0.antitheft_device_discount_premium_4th_year, t0.antitheft_device_discount_premium_5th_year, t0.attached_trailer_premium_1st_year, t0.attached_trailer_premium_2nd_year, t0.attached_trailer_premium_3rd_year, t0.attached_trailer_premium_4th_year, t0.attached_trailer_premium_5th_year, t0.automobile_association_member_premium_1st_year, t0.automobile_association_member_premium_2nd_year, t0.automobile_association_member_premium_3rd_year, t0.automobile_association_member_premium_4th_year, t0.automobile_association_member_premium_5th_year, t0.base_premium_of_add_on_cover, t0.base_premium_of_add_on_cover_2nd_year, t0.base_premium_of_add_on_cover_3rd_year, t0.base_premium_of_add_on_cover_4th_year, t0.base_premium_of_add_on_cover_5th_year, t0.basic_od_premium_1st_year, t0.basic_tp_premium_1st_year, t0.basic_tp_premium_2nd_year, t0.basic_tp_premium_3rd_year, t0.basic_tp_premium_4th_year, t0.basic_tp_premium_5th_year, t0.cd_discount_1, t0.cd_discount_1st_year, t0.cd_discount_2, t0.cd_discount_3, t0.cd_discount_4, t0.cd_discount_5, t0.cng_kit_fittings_premium_1st_year, t0.cng_kit_fittings_premium_2nd_year, t0.cng_kit_fittings_premium_3rd_year, t0.cng_kit_fittings_premium_4th_year, t0.cng_kit_fittings_premium_5th_year, t0.courtesy_car_premium_1st_year, t0.courtesy_car_premium_2nd_year, t0.courtesy_car_premium_3rd_year, t0.courtesy_car_premium_4th_year, t0.courtesy_car_premium_5th_year, t0.cover_premium_after_discount_a1, t0.cover_premium_after_discount_a1_2nd_year, t0.cover_premium_after_discount_a1_3rd_year, t0.cover_premium_after_discount_a1_4th_year, t0.cover_premium_after_discount_a1_5th_year, t0.cpa_premium_1st_year, t0.cpa_premium_2nd_year, t0.cpa_premium_3rd_year, t0.cpa_premium_4th_year, t0.cpa_premium_5th_year, t0.demo_car_apportion_1st_year, t0.demonstration_extension_cover_premium_1st_year, t0.driving_tuition_1st_year, t0.driving_tuition_2nd_year, t0.driving_tuition_3rd_year, t0.driving_tuition_4th_year, t0.driving_tuition_5th_year, t0.driving_tuition_apportion_1st_year, t0.electrical_accessories_premium_1st_year) as AUG_POLICY_PREMIUM_TENURE__HEAD_PREMIUM_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        t0.compulsory_excess as COVERAGE_LIMITS__DEDUCTIBLE_AMOUNT,
        t0.excess as COVERAGE_LIMITS__EXCESS_AMOUNT,
        null,
        t0.benefit_period as COVERAGE_LIMITS__INDEMNITY_PERIOD,
        null, null, null, null, null, null, null, null, null, null,
        t0.cpa_tenure as RISK_MOTOR_CPA__COMPULSORY_PA_TENURE_YEARS,
        null, null,
        'TYRE' as RISK_MOTOR_FITMENTS__FITMENT_TYPE_CK,
        'WHEEL_1' as RISK_MOTOR_FITMENTS__SEQUENCE_CK,
        t0.tyre_1 as RISK_MOTOR_FITMENTS__FITMENT_DESCRIPTION,
        '1' as RISK_MOTOR_IDV_TENURE__TENURE_YEAR_CK,
        'VEHICLE' as RISK_MOTOR_IDV_TENURE__IDV_COMPONENT_CK,
        t0.c_1st_year_idv as RISK_MOTOR_IDV_TENURE__AGREED_IDV,
        t0.rec_refresh_at as REC_REFRESH_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (coalesce(nullif('CERT:' || nullif(trim(t0.certificate_number), ''), ''), nullif('COV:' || nullif(trim(j3.cover_code), ''), ''), nullif(nullif(trim(j4.pol_risk_id), ''), ''), nullif(nullif(trim(j5.policy_number), ''), ''))) is not null

    union all

    -- branch 6: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(j4.pol_risk_id), ''), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'TYRE' as RISK_MOTOR_FITMENTS__FITMENT_TYPE_CK,
        'WHEEL_2' as RISK_MOTOR_FITMENTS__SEQUENCE_CK,
        t0.tyre_2 as RISK_MOTOR_FITMENTS__FITMENT_DESCRIPTION,
        '2' as RISK_MOTOR_IDV_TENURE__TENURE_YEAR_CK,
        'VEHICLE' as RISK_MOTOR_IDV_TENURE__IDV_COMPONENT_CK,
        t0.c_2nd_year_idv as RISK_MOTOR_IDV_TENURE__AGREED_IDV,
        t0.rec_refresh_at as REC_REFRESH_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.pol_risk_id), ''), '')) is not null

    union all

    -- branch 7: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(j4.pol_risk_id), ''), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'TYRE' as RISK_MOTOR_FITMENTS__FITMENT_TYPE_CK,
        'WHEEL_3' as RISK_MOTOR_FITMENTS__SEQUENCE_CK,
        t0.tyre_3 as RISK_MOTOR_FITMENTS__FITMENT_DESCRIPTION,
        '3' as RISK_MOTOR_IDV_TENURE__TENURE_YEAR_CK,
        'VEHICLE' as RISK_MOTOR_IDV_TENURE__IDV_COMPONENT_CK,
        t0.c_3rd_year_idv as RISK_MOTOR_IDV_TENURE__AGREED_IDV,
        t0.rec_refresh_at as REC_REFRESH_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.pol_risk_id), ''), '')) is not null

    union all

    -- branch 8: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(j4.pol_risk_id), ''), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'TYRE' as RISK_MOTOR_FITMENTS__FITMENT_TYPE_CK,
        'WHEEL_4' as RISK_MOTOR_FITMENTS__SEQUENCE_CK,
        t0.tyre_4 as RISK_MOTOR_FITMENTS__FITMENT_DESCRIPTION,
        '4' as RISK_MOTOR_IDV_TENURE__TENURE_YEAR_CK,
        'VEHICLE' as RISK_MOTOR_IDV_TENURE__IDV_COMPONENT_CK,
        t0.c_4th_year_idv as RISK_MOTOR_IDV_TENURE__AGREED_IDV,
        t0.rec_refresh_at as REC_REFRESH_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.pol_risk_id), ''), '')) is not null

    union all

    -- branch 9: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(j4.pol_risk_id), ''), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'TYRE' as RISK_MOTOR_FITMENTS__FITMENT_TYPE_CK,
        'WHEEL_5' as RISK_MOTOR_FITMENTS__SEQUENCE_CK,
        t0.tyre_5 as RISK_MOTOR_FITMENTS__FITMENT_DESCRIPTION,
        '5' as RISK_MOTOR_IDV_TENURE__TENURE_YEAR_CK,
        'VEHICLE' as RISK_MOTOR_IDV_TENURE__IDV_COMPONENT_CK,
        t0.c_5th_year_idv as RISK_MOTOR_IDV_TENURE__AGREED_IDV,
        t0.rec_refresh_at as REC_REFRESH_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.pol_risk_id), ''), '')) is not null

    union all

    -- branch 10: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(t0.pre_inspection_number),''), '') as ASSESSMENT_BK,
        null,
        nullif(coalesce(nullif(trim(t0.cover_code), ''), nullif(trim(t0.covercode), '')), '') as COVERAGE_BK,
        null,
        nullif(nullif(trim(j4.policy_number),''), '') as POLICY_BK,
        null,
        nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        t0.pin_source as ASSESSMENT_HEADER__ASSESSMENT_CHANNEL,
        t0.pin_status as ASSESSMENT_HEADER__ASSESSMENT_STATUS,
        null, null, null,
        t0.preinspection_charges as ASSESSMENT_HEADER__COST_OF_ASSESSMENT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.pin_excess_amount as AUG_ASSESSMENT_PRE_INSPECTION__IMPOSED_EXCESS_AMOUNT,
        t0.pin_excess as AUG_ASSESSMENT_PRE_INSPECTION__IMPOSED_EXCESS_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        t0.conditional_section as AUG_COVERAGE_CONDITIONS__CONDITIONAL_SECTION_REFERENCE,
        null,
        t0.cover_max_age as AUG_COVERAGE_CONDITIONS__MAXIMUM_AGE_ELIGIBLE,
        null,
        t0.benefit_period as AUG_COVERAGE_LIMITS__BENEFIT_PERIOD,
        null,
        t0.claim_registration_limit as AUG_COVERAGE_LIMITS__CLAIM_REGISTRATION_LIMIT,
        null, null,
        t0.daily_allowance_limit as AUG_COVERAGE_LIMITS__DAILY_ALLOWANCE_LIMIT,
        null,
        nullif(trim(t0.cover_code),'') as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.cover_sum_insured_in_base_currency as AUG_POLICY_COVERAGE_SCHEDULE__SUM_INSURED_IN_BASE_CURRENCY,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.franchise as COVERAGE_LIMITS__FRANCHISE_AMOUNT,
        null, null, null, null, null, null,
        t0.scpa_cover_inception_date as RISK_MOTOR_CPA__COMPULSORY_PA_EFFECTIVE_DATE,
        t0.scpa_cover_expiry_date as RISK_MOTOR_CPA__COMPULSORY_PA_EXPIRY_DATE,
        t0.compulsory_personal_accident_cover_applicability as RISK_MOTOR_CPA__COMPULSORY_PA_OWNER_DRIVER_INDICATOR,
        t0.scpa_cover_premium as RISK_MOTOR_CPA__COMPULSORY_PA_PREMIUM,
        t0.scpa_sum_insured as RISK_MOTOR_CPA__COMPULSORY_PA_SUM_INSURED,
        t0.cpa_tenure as RISK_MOTOR_CPA__COMPULSORY_PA_TENURE_YEARS,
        t0.vehicle_designed_for_blindhandicappedmentally_challenged_persons_and_endorsed_by_rta as RISK_MOTOR_CPA__HANDICAPPED_VEHICLE_INDICATOR,
        t0.do_you_hold_valid_driving_license as RISK_MOTOR_CPA__OWNER_DRIVER_LICENCE_EXISTS_INDICATOR,
        'BIFUEL_KIT' as RISK_MOTOR_FITMENTS__FITMENT_TYPE_CK,
        '1' as RISK_MOTOR_FITMENTS__SEQUENCE_CK,
        t0.fiber_glass_tank_unit as RISK_MOTOR_FITMENTS__FITMENT_DESCRIPTION,
        '1' as RISK_MOTOR_IDV_TENURE__TENURE_YEAR_CK,
        'VEHICLE' as RISK_MOTOR_IDV_TENURE__IDV_COMPONENT_CK,
        t0.c_1st_year_idv as RISK_MOTOR_IDV_TENURE__AGREED_IDV,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (coalesce(nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), ''), nullif(coalesce(nullif(trim(t0.cover_code), ''), nullif(trim(t0.covercode), '')), ''), nullif(nullif(trim(j4.policy_number),''), ''), nullif(nullif(trim(t0.pre_inspection_number),''), ''))) is not null

    union all

    -- branch 11: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null,
        nullif(nullif(trim(t0.cover_code),''), '') as COVERAGE_BK,
        null,
        nullif(nullif(trim(j4.policy_number), ''), '') as POLICY_BK,
        null,
        nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.nd_applicable_for_organization as AUG_COVERAGE_CONDITIONS__NIL_DEPRECIATION_APPLICABLE_FOR_ORGANISATION_INDICATOR,
        null, null, null, null, null, null, null,
        nullif(trim(t0.cover_code),'') as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.risk_plan as AUG_POLICY_COVERAGE_SCHEDULE__PLAN_REFERENCE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.limit as COVERAGE_LIMITS__LIMIT_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        '2' as RISK_MOTOR_IDV_TENURE__TENURE_YEAR_CK,
        'VEHICLE' as RISK_MOTOR_IDV_TENURE__IDV_COMPONENT_CK,
        t0.c_2nd_year_idv as RISK_MOTOR_IDV_TENURE__AGREED_IDV,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (coalesce(nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), ''), nullif(nullif(trim(j4.policy_number), ''), ''), nullif(nullif(trim(t0.cover_code),''), ''))) is not null

    union all

    -- branch 12: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null,
        nullif(nullif(trim(t0.cover_code), ''), '') as COVERAGE_BK,
        null, null, null,
        nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.sum_insured_per_person as COVERAGE_LIMITS__PER_PERSON_LIMIT,
        t0.voluntary_excess as COVERAGE_LIMITS__VOLUNTARY_DEDUCTIBLE_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        '3' as RISK_MOTOR_IDV_TENURE__TENURE_YEAR_CK,
        'VEHICLE' as RISK_MOTOR_IDV_TENURE__IDV_COMPONENT_CK,
        t0.c_3rd_year_idv as RISK_MOTOR_IDV_TENURE__AGREED_IDV,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp_pv') }} t0
    where (coalesce(nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), ''), nullif(nullif(trim(t0.cover_code), ''), ''))) is not null

    union all

    -- branch 13: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null, null, null, null, null,
        nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        '4' as RISK_MOTOR_IDV_TENURE__TENURE_YEAR_CK,
        'VEHICLE' as RISK_MOTOR_IDV_TENURE__IDV_COMPONENT_CK,
        t0.c_4th_year_idv as RISK_MOTOR_IDV_TENURE__AGREED_IDV,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp_pv') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), '')) is not null

    union all

    -- branch 14: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null, null, null, null, null,
        nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        '5' as RISK_MOTOR_IDV_TENURE__TENURE_YEAR_CK,
        'VEHICLE' as RISK_MOTOR_IDV_TENURE__IDV_COMPONENT_CK,
        t0.c_5th_year_idv as RISK_MOTOR_IDV_TENURE__AGREED_IDV,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp_pv') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), '')) is not null

    union all

    -- branch 15: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(t0.pre_inspection_number), ''), '') as ASSESSMENT_BK,
        null, null, null,
        nullif(nullif(trim(j3.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null,
        t0.pin_source as ASSESSMENT_HEADER__ASSESSMENT_CHANNEL,
        t0.pin_status as ASSESSMENT_HEADER__ASSESSMENT_STATUS,
        null, null, null,
        t0.preinspection_charges as ASSESSMENT_HEADER__COST_OF_ASSESSMENT,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.acr_report as AUG_ASSESSMENT_HEADER__ASSESSMENT_REPORT_REFERENCE,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.select_inspection_addressod as AUG_ASSESSMENT_PRE_INSPECTION__OWN_DAMAGE_INSPECTION_LOCATION_ADDRESS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        nullif(trim(t0.cover_name),'') as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
        null, null, null, null, null, null,
        t0.cover_name as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_policy_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_policy_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (coalesce(nullif(nullif(trim(j3.policy_number), ''), ''), nullif(nullif(trim(t0.pre_inspection_number), ''), ''))) is not null

    union all

    -- branch 16: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_TELE_VERIFICATION_DETAILS
    select
        nullif(nullif(trim('TELEVERIFY:' || coalesce(nullif(trim(t0.transaction_id), ''), '')), 'TELEVERIFY:'), '') as ASSESSMENT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.tele_varification_status as ASSESSMENT_HEADER__ASSESSMENT_STATUS,
        null, null, null, null,
        t0.tele_varification_initiated_date as ASSESSMENT_HEADER__REQUESTED_DATE,
        null, null, null, null, null, null, null, null,
        t0.end_time as AUG_ASSESSMENT_HEADER__ASSESSMENT_END_TIME,
        null, null, null, null,
        t0.start_time as AUG_ASSESSMENT_HEADER__ASSESSMENT_START_TIME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_tele_verification_dtls') }} t0
    where (nullif(nullif(trim('TELEVERIFY:' || coalesce(nullif(trim(t0.transaction_id), ''), '')), 'TELEVERIFY:'), '')) is not null

    union all

    -- branch 17: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        nullif(nullif(trim(t0.pre_inspection_number), ''), '') as ASSESSMENT_BK,
        null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null,
        t0.pin_source as ASSESSMENT_HEADER__ASSESSMENT_CHANNEL,
        t0.pin_status as ASSESSMENT_HEADER__ASSESSMENT_STATUS,
        null, null, null,
        t0.preinspection_charges as ASSESSMENT_HEADER__COST_OF_ASSESSMENT,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.acr_report as AUG_ASSESSMENT_HEADER__ASSESSMENT_REPORT_REFERENCE,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.select_inspection_addressod as AUG_ASSESSMENT_PRE_INSPECTION__OWN_DAMAGE_INSPECTION_LOCATION_ADDRESS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        'ABOUT_LOSS_INFORMATION' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.about_loss_information as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (coalesce(nullif(nullif(trim(j3.policy_quote_number), ''), ''), nullif(nullif(trim(t0.pre_inspection_number), ''), ''))) is not null

    union all

    -- branch 18: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ACCIDENT_LOCATION' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.accident_location as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 19: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ACTIVE_TP_BRANCH_ADDRESS' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.active_tp_branch_address as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 20: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ACTIVE_TP_CLAIM_AMOUNT' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.active_tp_claim_amount as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 21: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ACTIVE_TP_CLAIM_DATE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.active_tp_claim_date as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 22: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ACTIVE_TP_FLAG' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.active_tp_flag as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 23: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ACTIVE_TP_INSURANCE_COMPANY_NAME' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.active_tp_insurance_company_name as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 24: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ACTIVE_TP_POLICY_EXPIRY_DATE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.active_tp_policy_expiry_date as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 25: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ACTIVE_TP_POLICY_INCEPTION_DATE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.active_tp_policy_inception_date as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 26: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ACTIVE_TP_POLICY_NUMBER' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.active_tp_policy_number as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 27: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ACTIVE_TP_POLICY_TERM' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.active_tp_policy_term as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 28: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ADDON_EXCESS' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.addon_excess as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 29: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ADMIN_CHARGES' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.admin_charges as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 30: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ADMIN_FEE_DETAILS' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.admin_fee_details as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 31: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'AMOUNT_RECEVIED' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.amount_recevied as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 32: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'AREACLAIM' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.areaclaim as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 33: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'BANCA_CHARGE_FILE_PROCESS_COUNT' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.banca_charge_file_process_count as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 34: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'BANK_CHARGES' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.bank_charges as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 35: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'BATTERY_THEFT_EXCESS' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.battery_theft_excess as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 36: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'BILL_TO' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.bill_to as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 37: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'BUCKET_DESCRIPTION' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.bucket_description as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 38: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CALCULATED_AMOUNT_FOR_ELAPSED_PERIOD' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.calculated_amount_for_elapsed_period as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 39: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CALCULATED_AMOUNT_FOR_REMAINING_PERIOD' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.calculated_amount_for_remaining_period as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 40: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CANCELLATION_BASIS' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.cancellation_basis as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 41: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CANCELLATION_TYPE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.cancellation_type as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 42: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CANCELLED_BY' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.cancelled_by as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 43: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CASE_FILED_BEFORE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.case_filed_before as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 44: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CATEGORY' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.category as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 45: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CAUSE_OF_LOSS' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.cause_of_loss as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 46: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CAUSE_OF_LOSSPA' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.cause_of_losspa as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 47: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CGST' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.cgst as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 48: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CGST_AMOUNT' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.cgst_amount as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 49: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CGST_PERCENTAGE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.cgst_percentage as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 50: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CLAIM_AMOUNT' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.claim_amount as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 51: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CLAIM_DATE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.claim_date as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 52: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CLAIM_HANDLING_LOCATION_CODEMACT_LOCATION_CODE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.claim_handling_location_codemact_location_code as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 53: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CLAIM_INTIMATION_DATE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.claim_intimation_date as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 54: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CLAIM_INTIMATION_TIME' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.claim_intimation_time as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 55: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CLAIM_INTIMATION_TYPE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.claim_intimation_type as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 56: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CLAIM_INTIMATOR_MOBILE_NUMBER' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.claim_intimator_mobile_number as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 57: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CLAIM_INTIMATOR_NAME' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.claim_intimator_name as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 58: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CLAIM_LOCATION' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.claim_location as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 59: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CLAIM_REGISTRATION_LOCATION_' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.claim_registration_location_ as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 60: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CLAIM_REQUIREMENT_STATUS' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.claim_requirement_status as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 61: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CLAIM_SUBSTATUS' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.claim_substatus as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 62: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CLAIM_TYPE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.claim_type as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 63: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CLAIM_TYPES' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.claim_types as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 64: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CLU_DISCOUNT' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.clu_discount as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 65: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'COINSURANCE_APPLICABLE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.coinsurance_applicable as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 66: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'COLUMN_DETAILS' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.column_details as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 67: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'COMPULSORY_EXCESS' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.compulsory_excess as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 68: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'COR_FLAG' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.cor_flag as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 69: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'COURT_LOCATION_AS_PER_INTIMATION_DETAILS' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.court_location_as_per_intimation_details as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 70: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'COURT_NAME_AS_PER_INTIMATION_DETAILS' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.court_name_as_per_intimation_details as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 71: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'COURT_TYPE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.court_type as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 72: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'COVERAGE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.coverage as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 73: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'COVER_NAME' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.cover_name as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 74: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CREATED_BY' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.created_by as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 75: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CROSS_SELL_DISCOUNT' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.cross_sell_discount as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 76: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CSD' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.csd as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 77: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CUMULATIVE_MINIMUM_PREMIUM' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.cumulative_minimum_premium as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 78: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'DATE_OF_ACCIDENT' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.date_of_accident as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 79: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'DATE_OF_LOSS' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.date_of_loss as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 80: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'DEFICIENCY_STATUS' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.deficiency_status as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 81: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'DESCRIPTION_OF_LOSS' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.description_of_loss as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 82: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'DESPATCH_DATE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.despatch_date as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 83: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'DESPATCH_NUMBER' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.despatch_number as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 84: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'DESPATCH_TYPE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.despatch_type as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 85: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EFFECTIVE_DATE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.effective_date as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 86: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EMPLOYEE_DISCOUNT_APPLICABLE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.employee_discount_applicable as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 87: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EMPLOYEE_OR_VIP_FLAG_DISCOUNT_APPLICABLE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.employee_or_vip_flag_discount_applicable as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 88: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ENDORSEMENT_APPLICABLE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.endorsement_applicable as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 89: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ENDORSEMENT_PREMIUM' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.endorsement_premium as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 90: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ENTRY_DATE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.entry_date as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 91: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ENTRY_TIME' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.entry_time as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 92: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ESCALATED_EXCESS' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.escalated_excess as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 93: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EST11_PROFESSION_DISCOUNT' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.est11_profession_discount as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 94: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EST1A_TP_CLAIMS_TAKEN_IN_POLICY_DISCOUNT' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.est1a_tp_claims_taken_in_policy_discount as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 95: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EST1_OD_CLAIMS_TAKEN_IN_POLICY_DISCOUNT' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.est1_od_claims_taken_in_policy_discount as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 96: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EST21_PURPOSE_OF_USE_DISCOUNT' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.est21_purpose_of_use_discount as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 97: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EXPENSE_FEE_HEAD_CODE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.expense_fee_head_code as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 98: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EXPENSE_PAYMENT_AMOUNT' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.expense_payment_amount as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 99: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EXPENSE_PAYMENT_APPROVED_BY' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.expense_payment_approved_by as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 100: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EXPENSE_PAYMENT_DATE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.expense_payment_date as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 101: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EXPENSE_PAYMENT_REFERENCE_NO' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.expense_payment_reference_no as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 102: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EXPENSE_PAYMENT_TYPE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.expense_payment_type as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 103: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EXPENSE_PORTAL_PAYMENT_REFERENCE_NUMBER' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.expense_portal_payment_reference_number as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 104: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EXPENSE_REFERENCE_TEXT' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.expense_reference_text as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 105: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EXTENDED_STP_DISCOUNT' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.extended_stp_discount as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 106: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'FIRST_TIME_EXECUTED' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.first_time_executed as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 107: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'FIXEDCDFLAG' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.fixedcdflag as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 108: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=RELATION_WITH_EMPLOYEE
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'RELATION_WITH_EMPLOYEE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.relation_with_employee as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 109: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=RENEWAL_CD
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'RENEWAL_CD' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.renewal_cd_ as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 110: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=RENEWAL_CD_AMOUNT
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'RENEWAL_CD_AMOUNT' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.renewal_cd_amount as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 111: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=RENEWAL_LOADING
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'RENEWAL_LOADING' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.renewal_loading_ as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 112: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=RENEWAL_LOADING_AMOUNT
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'RENEWAL_LOADING_AMOUNT' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.renewal_loading_amount as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 113: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=RID_APPLICABILITY_FACTOR
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'RID_APPLICABILITY_FACTOR' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.rid_applicability_factor as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 114: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=SGST
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SGST' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.sgst as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 115: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=SGST_AMOUNT
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SGST_AMOUNT' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.sgst_amount as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 116: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=SGST_PERCENTAGE
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SGST_PERCENTAGE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.sgst_percentage as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 117: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=SUM_INSURED_IN_SI_CURRENCY
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SUM_INSURED_IN_SI_CURRENCY' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.sum_insured_in_si_currency as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 118: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=SYSTEM_CD1
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SYSTEM_CD1' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.system_cd1 as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 119: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=SYSTEM_CD2
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SYSTEM_CD2' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.system_cd2 as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 120: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=SYSTEM_CD3
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SYSTEM_CD3' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.system_cd3 as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 121: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=SYSTEM_CD4
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SYSTEM_CD4' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.system_cd4 as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 122: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=SYSTEM_CD5
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SYSTEM_CD5' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.system_cd5 as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 123: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=TOTAL_GST_PERCENTAGE
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'TOTAL_GST_PERCENTAGE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.total_gst_percentage as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 124: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=TOTAL_STP_DISCOUNT
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'TOTAL_STP_DISCOUNT' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.total_stp_discount as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 125: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=TOTAL_THEFT_EXCESS
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'TOTAL_THEFT_EXCESS' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.total_theft_excess as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 126: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=UGST
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'UGST' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.ugst as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 127: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=UGST_PERCENTAGE
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'UGST_PERCENTAGE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.ugst_percentage as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 128: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=UNDERWRITER_EXCESS
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'UNDERWRITER_EXCESS' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.underwriter_excess as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 129: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=USER_CD
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'USER_CD' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.user_cd as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 130: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=USER_PREMIUM
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'USER_PREMIUM' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.user_premium as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 131: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=UTGST_AMOUNT
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'UTGST_AMOUNT' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.utgst_amount as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 132: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=UW_APPROVED_CD
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'UW_APPROVED_CD' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.uw_approved_cd as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 133: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW | child-key literal(s): QUOTE_RATING_INPUT.Factor Code=VOLUNTARY_EXCESS
    select
        null, null, null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'VOLUNTARY_EXCESS' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.voluntary_excess as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_quote_number), ''), '')) is not null

    union all

    -- branch 134: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null,
        nullif('COV:' || nullif(trim(j3.cover_code), ''), '') as COVERAGE_BK,
        nullif('CERT:' || nullif(trim(t0.certificate_number), ''), '') as DOCUMENT_BK,
        null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        nullif(nullif(trim(j4.pol_risk_id), ''), '') as RISK_OBJECT_BK,
        null, null,
        1 as __LNK_QUOTE_RISK_OBJECT,
        1 as __LNK_RISK_OBJECT_DOCUMENT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.cover_max_age as AUG_COVERAGE_CONDITIONS__MAXIMUM_AGE_ELIGIBLE,
        null, null,
        t0.claim_registration_limit as AUG_COVERAGE_LIMITS__CLAIM_REGISTRATION_COUNT_LIMIT,
        null, null, null,
        t0.daily_allowance_limit as AUG_COVERAGE_LIMITS__DAILY_ALLOWANCE_LIMIT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        t0.cover_availed_from as AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_AVAILED_FROM_DATE,
        t0.cover_availed_to as AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_AVAILED_TO_DATE,
        t0.cover_level_base_currency as AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_BASE_CURRENCY_CODE,
        t0.delete_risk_cover_ind as AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_DELETED_INDICATOR,
        t0.cover_duration as AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_DURATION,
        t0.cover_expiry_date as AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_END_DATE,
        t0.effective_date as AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_RECORD_EFFECTIVE_DATE,
        t0.expiry_date as AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_RECORD_EXPIRY_DATE,
        t0.cover_inception_date as AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_START_DATE,
        null,
        t0.cover_level_transaction_currency_for_sum_insured as AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_SUM_INSURED_CURRENCY_CODE,
        t0.cover_term as AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_TERM,
        t0.cover_term_unit as AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_TERM_UNIT,
        t0.cover_level_transaction_currency as AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_TRANSACTION_CURRENCY_CODE,
        t0.discount_percentage as AUG_QUOTE_COVERAGE_SCHEDULE__DISCOUNT_PERCENTAGE_APPLIED,
        t0.cover_premium_in_transaction_currency as AUG_QUOTE_COVERAGE_SCHEDULE__PREMIUM_FOR_COVERAGE,
        t0.cover_premium_in_base_currency as AUG_QUOTE_COVERAGE_SCHEDULE__PREMIUM_FOR_COVERAGE_IN_BASE_CURRENCY,
        t0.cover_sum_insured as AUG_QUOTE_COVERAGE_SCHEDULE__SUM_INSURED,
        t0.cover_sum_insured_in_base_currency as AUG_QUOTE_COVERAGE_SCHEDULE__SUM_INSURED_IN_BASE_CURRENCY,
        t0.cover_sum_insured_in_transaction_currency as AUG_QUOTE_COVERAGE_SCHEDULE__SUM_INSURED_IN_TRANSACTION_CURRENCY,
        null, null, null, null, null, null, null,
        'SUB_TOTAL_16_Y1' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null,
        t0.base_amt_on_current_pmm_slab as AUG_QUOTE_PREMIUM_HEAD__BASE_AMOUNT,
        null, null,
        coalesce(t0.earned_premium_antitheft_device_discount_1st_year, t0.earned_premium_attached_trailer, t0.earned_premium_automobile_association_member_1st_year, t0.earned_premium_basic_od_1_year, t0.earned_premium_cd_1st_year, t0.earned_premium_cng_kit_1_year, t0.earned_premium_courtesy_car_1st_year, t0.earned_premium_demo_extn_cover_1st_year, t0.earned_premium_driving_tuition_1st_year, t0.earned_premium_electrical_accessories_1st_year, t0.earned_premium_extended_stp_1st_year, t0.earned_premium_fibre_glass_fuel_tank_1st_year, t0.earned_premium_geog_extension_1st_year, t0.earned_premium_handicapped_discount_1st_year, t0.earned_premium_imported_vehicle_1st_year, t0.earned_premium_imt14, t0.earned_premium_imt23_1st_year, t0.earned_premium_imt34_1st_year, t0.earned_premium_imt43, t0.earned_premium_imt44, t0.earned_premium_imt45, t0.earned_premium_imt47, t0.earned_premium_imt53, t0.earned_premium_loss_of_accessories_1st_year, t0.earned_premium_ltd_1st_year, t0.earned_premium_ncb_1st_year, t0.earned_premium_nonelectrical_accessories_1st_year, t0.earned_premium_normal_rally_1st_year, t0.earned_premium_side_car_1st_year, t0.earned_premium_side_car_discount_1st_year, t0.earned_premium_speed_rally_1st_year, t0.earned_premium_use_within_own_premises_1st_year, t0.earned_premium_voluntary_deductible_1st_year) as AUG_QUOTE_PREMIUM_HEAD__EARNED_PREMIUM_AMOUNT,
        coalesce(t0.earned_premium_sub_total_10_1st_year, t0.earned_premium_sub_total_11_1st_year, t0.earned_premium_sub_total_12_1st_year, t0.earned_premium_sub_total_13_1st_year, t0.earned_premium_sub_total_14_1st_year, t0.earned_premium_sub_total_15_1st_year, t0.earned_premium_sub_total_16_1st_year, t0.earned_premium_sub_total_1_1st_year, t0.earned_premium_sub_total_2_1st_year, t0.earned_premium_sub_total_3_1st_year, t0.earned_premium_sub_total_4_1st_year, t0.earned_premium_sub_total_5_1st_year, t0.earned_premium_sub_total_6_1st_year, t0.earned_premium_sub_total_7_1st_year, t0.earned_premium_sub_total_8_1st_year, t0.earned_premium_sub_total_9_1st_year) as AUG_QUOTE_PREMIUM_HEAD__EARNED_PREMIUM_SUB_TOTAL_AMOUNT,
        null, null, null,
        coalesce(t0.accidents_tp_premium_1st_year, t0.accidents_tp_premium_2nd_year, t0.accidents_tp_premium_3rd_year, t0.accidents_tp_premium_4th_year, t0.accidents_tp_premium_5th_year, t0.add_on_premium_after_1st_year, t0.add_on_premium_after_2nd_year, t0.add_on_premium_after_3rd_year, t0.add_on_premium_after_4th_year, t0.add_on_premium_after_5th_year, t0.additional_od_premium_1st_year, t0.antitheft_device_discount_premium_1st_year, t0.antitheft_device_discount_premium_2nd_year, t0.antitheft_device_discount_premium_3rd_year, t0.antitheft_device_discount_premium_4th_year, t0.antitheft_device_discount_premium_5th_year, t0.attached_trailer_premium_1st_year, t0.attached_trailer_premium_2nd_year, t0.attached_trailer_premium_3rd_year, t0.attached_trailer_premium_4th_year, t0.attached_trailer_premium_5th_year, t0.automobile_association_member_premium_1st_year, t0.automobile_association_member_premium_2nd_year, t0.automobile_association_member_premium_3rd_year, t0.automobile_association_member_premium_4th_year, t0.automobile_association_member_premium_5th_year, t0.base_premium_of_add_on_cover, t0.base_premium_of_add_on_cover_2nd_year, t0.base_premium_of_add_on_cover_3rd_year, t0.base_premium_of_add_on_cover_4th_year, t0.base_premium_of_add_on_cover_5th_year, t0.basic_od_premium_1st_year, t0.basic_tp_premium_1st_year, t0.basic_tp_premium_2nd_year, t0.basic_tp_premium_3rd_year, t0.basic_tp_premium_4th_year, t0.basic_tp_premium_5th_year, t0.cd_discount_1, t0.cd_discount_1st_year, t0.cd_discount_2, t0.cd_discount_3, t0.cd_discount_4, t0.cd_discount_5, t0.cng_kit_fittings_premium_1st_year, t0.cng_kit_fittings_premium_2nd_year, t0.cng_kit_fittings_premium_3rd_year, t0.cng_kit_fittings_premium_4th_year, t0.cng_kit_fittings_premium_5th_year, t0.courtesy_car_premium_1st_year, t0.courtesy_car_premium_2nd_year, t0.courtesy_car_premium_3rd_year, t0.courtesy_car_premium_4th_year, t0.courtesy_car_premium_5th_year, t0.cover_premium_after_discount_a1, t0.cover_premium_after_discount_a1_2nd_year, t0.cover_premium_after_discount_a1_3rd_year, t0.cover_premium_after_discount_a1_4th_year, t0.cover_premium_after_discount_a1_5th_year, t0.cpa_premium_1st_year, t0.cpa_premium_2nd_year, t0.cpa_premium_3rd_year, t0.cpa_premium_4th_year, t0.cpa_premium_5th_year, t0.demo_car_apportion_1st_year, t0.demonstration_extension_cover_premium_1st_year, t0.driving_tuition_1st_year, t0.driving_tuition_2nd_year, t0.driving_tuition_3rd_year, t0.driving_tuition_4th_year, t0.driving_tuition_5th_year, t0.driving_tuition_apportion_1st_year, t0.electrical_accessories_premium_1st_year) as AUG_QUOTE_PREMIUM_HEAD__HEAD_PREMIUM_AMOUNT,
        coalesce(t0.balance_vehicle_laid_off_premium, t0.commercial_premium, t0.sub_total_16_1st_year) as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null,
        'COVER' as AUG_QUOTE_SUM_INSURED_BREAKUP__SUM_INSURED_HEAD_CK,
        null,
        t0.sum_insured as AUG_QUOTE_SUM_INSURED_BREAKUP__SUM_INSURED_AMOUNT,
        null, null, null, null, null,
        t0.compulsory_excess as COVERAGE_LIMITS__DEDUCTIBLE_AMOUNT,
        t0.excess as COVERAGE_LIMITS__EXCESS_AMOUNT,
        null,
        t0.benefit_period as COVERAGE_LIMITS__INDEMNITY_PERIOD,
        null, null, null,
        'TPTERRIF_RATE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.tp_premium_rate as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null,
        t0.cpa_tenure as RISK_MOTOR_CPA__COMPULSORY_PA_TENURE_YEARS,
        null, null,
        'TYRE' as RISK_MOTOR_FITMENTS__FITMENT_TYPE_CK,
        'WHEEL_1' as RISK_MOTOR_FITMENTS__SEQUENCE_CK,
        t0.tyre_1 as RISK_MOTOR_FITMENTS__FITMENT_DESCRIPTION,
        '1' as RISK_MOTOR_IDV_TENURE__TENURE_YEAR_CK,
        'VEHICLE' as RISK_MOTOR_IDV_TENURE__IDV_COMPONENT_CK,
        t0.c_1st_year_idv as RISK_MOTOR_IDV_TENURE__AGREED_IDV,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (coalesce(nullif('CERT:' || nullif(trim(t0.certificate_number), ''), ''), nullif('COV:' || nullif(trim(j3.cover_code), ''), ''), nullif(nullif(trim(j4.pol_risk_id), ''), ''), nullif(nullif(trim(j5.policy_quote_number), ''), ''))) is not null

    union all

    -- branch 135: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        nullif(nullif(trim(j4.pol_risk_id), ''), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        coalesce(t0.handicapped_discount_premium_1st_year, t0.lt_discount_1st_year, t0.no_claim_bonus_premium_1st_year, t0.oem_loading_discount, t0.rev_cd_1st_year, t0.side_car_discount_1st_year) as AUG_QUOTE_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        null,
        t0.further_discount_applicable as AUG_QUOTE_DISCOUNT_LOADING_APPLIED__EXTRA_DISCOUNT_OPTED_INDICATOR,
        coalesce(t0.further_discount_percentage, t0.loading_percentage, t0.ncb_discount_percentage, t0.ncb_discount_percentage_2nd_year, t0.ncb_discount_percentage_3rd_year, t0.ncb_discount_percentage_4th_year, t0.ncb_discount_percentage_5th_year) as AUG_QUOTE_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED,
        coalesce(t0.pmm_adj_factor_for_prd_elapsed, t0.pmm_adj_factor_for_prd_remain, t0.pmm_adj_factor_for_product_remain) as AUG_QUOTE_DISCOUNT_LOADING_APPLIED__RATING_FACTOR_VALUE,
        null, null, null, null, null, null, null,
        coalesce(t0.final_earned_premium_1st_year, t0.final_earned_premium_sub_total_1, t0.final_earned_premium_sub_total_10, t0.final_earned_premium_sub_total_11, t0.final_earned_premium_sub_total_12, t0.final_earned_premium_sub_total_13, t0.final_earned_premium_sub_total_14, t0.final_earned_premium_sub_total_15, t0.final_earned_premium_sub_total_2, t0.final_earned_premium_sub_total_3, t0.final_earned_premium_sub_total_4, t0.final_earned_premium_sub_total_5, t0.final_earned_premium_sub_total_6, t0.final_earned_premium_sub_total_7, t0.final_earned_premium_sub_total_8, t0.final_earned_premium_sub_total_9, t0.final_total_od_earned_premium, t0.rev_earned_premium_sub_total_16_1st_year, t0.rev_final_earned_premium_sub_total_16) as AUG_QUOTE_PREMIUM_HEAD__EARNED_HEAD_PREMIUM,
        null, null,
        t0.forex_rate_at_cover_level as AUG_QUOTE_PREMIUM_HEAD__EXCHANGE_RATE_APPLIED,
        t0.old_premium as AUG_QUOTE_PREMIUM_HEAD__EXPIRING_PREMIUM_AMOUNT,
        coalesce(t0.fixed_premium_system_cd1, t0.fixed_premium_system_cd2, t0.fixed_premium_system_cd3, t0.fixed_premium_system_cd4, t0.fixed_premium_system_cd5) as AUG_QUOTE_PREMIUM_HEAD__FIXED_PREMIUM_SYSTEM_CODE,
        null,
        coalesce(t0.extended_stp_1st_year, t0.fibre_glass_fuel_tank_premium_1st_yr, t0.final_cover_premium_after_fd_b, t0.final_cover_premium_after_fd_b_2nd_year, t0.final_cover_premium_after_fd_b_3rd_year, t0.final_cover_premium_after_fd_b_4th_year, t0.final_cover_premium_after_fd_b_5th_year, t0.final_od_premium_1st_year, t0.final_sub_total_1, t0.final_sub_total_10, t0.final_sub_total_11, t0.final_sub_total_12, t0.final_sub_total_13, t0.final_sub_total_14, t0.final_sub_total_15, t0.final_sub_total_1_tp, t0.final_sub_total_2, t0.final_sub_total_3, t0.final_sub_total_4, t0.final_sub_total_5, t0.final_sub_total_6, t0.final_sub_total_7, t0.final_sub_total_8, t0.final_sub_total_9, t0.final_total_od_premium, t0.geog_extn_1st_year, t0.geog_extn_2nd_year, t0.geog_extn_3rd_year, t0.geog_extn_4th_year, t0.geog_extn_5th_year, t0.imported_vehicle_1st_year, t0.imt14_premium_1st_year, t0.imt23_premium_1st_year, t0.imt34_premium_1st_year, t0.imt43_premium_1st_year, t0.imt44_premium_1st_year, t0.imt45_premium_1st_year, t0.imt47_premium_1st_year, t0.imt53_premium_1st_year, t0.indemnity_to_hirer_imt_44_premium_1st_year, t0.indemnity_to_hirer_premium_1st_year, t0.indemnity_to_hirer_premium_2nd_year, t0.indemnity_to_hirer_premium_3rd_year, t0.indemnity_to_hirer_premium_4th_year, t0.indemnity_to_hirer_premium_5th_year, t0.ll_for_employees_other_than_driver_and_cleaner_premium_1st_year, t0.ll_for_employees_other_than_driver_and_cleaner_premium_2nd_year, t0.ll_for_employees_other_than_driver_and_cleaner_premium_3rd_year, t0.ll_for_employees_other_than_driver_and_cleaner_premium_4th_year, t0.ll_for_employees_other_than_driver_and_cleaner_premium_5th_year, t0.ll_insured_carrying_vehicle_premium_1st_year, t0.ll_operation_maintenance_above_6_premium_1st_year, t0.ll_operation_maintenance_premium_1st_year, t0.ll_to_employee_premium_1st_year, t0.ll_to_employee_premium_2nd_year, t0.ll_to_employee_premium_3rd_year, t0.ll_to_employee_premium_4th_year, t0.ll_to_employee_premium_5th_year, t0.ll_to_fare_paying_passenger_employees_premium_1st_year, t0.ll_to_passenger_premium_1st_year, t0.loss_of_accessories_1st_year, t0.named_passenger_pa_premium_1st_year, t0.named_passenger_pa_premium_2nd_year, t0.named_passenger_pa_premium_3rd_year, t0.named_passenger_pa_premium_4th_year, t0.named_passenger_pa_premium_5th_year, t0.net_premium, t0.net_premium_without_loading_discount, t0.net_tp_premium, t0.non_fare_paying_employee_premium_1st_year, t0.non_fare_paying_passenger_premium_1st_year, t0.nonelectrical_accessories_premium_1st_year, t0.normal_rally_cover_premium_1st_year, t0.normal_rally_cover_premium_2nd_year, t0.normal_rally_cover_premium_3rd_year, t0.normal_rally_cover_premium_4th_year, t0.normal_rally_cover_premium_5th_year, t0.od_vehicle_laid_off_premium, t0.pa_for_driver_and_cleaner_premium_1st_year, t0.pa_for_driver_and_cleaner_premium_2nd_year, t0.pa_for_driver_and_cleaner_premium_3rd_year, t0.pa_for_driver_and_cleaner_premium_4th_year, t0.pa_for_driver_and_cleaner_premium_5th_year, t0.pa_for_pillion_rider_premium_1st_year, t0.pa_for_pillion_rider_premium_2nd_year, t0.pa_for_pillion_rider_premium_3rd_year, t0.pa_for_pillion_rider_premium_4th_year, t0.pa_for_pillion_rider_premium_5th_year, t0.pa_to_unnamed_hirer_and_pillion_premium_1st_year, t0.rev_final_sub_total_16, t0.rev_sub_total_14_1st_year, t0.rev_sub_total_15_1st_year, t0.rev_sub_total_16_1st_year, t0.rev_total_od_1st_year, t0.side_car_premium_1st_year, t0.speed_rally_premium_1st_year, t0.speed_rally_premium_2nd_year, t0.speed_rally_premium_3rd_year, t0.speed_rally_premium_4th_year, t0.speed_rally_premium_5th_year, t0.sub_total_10_1st_year, t0.sub_total_11_1st_year, t0.sub_total_12_1st_year, t0.sub_total_13_1st_year, t0.sub_total_14_1st_year, t0.sub_total_15_1st_year) as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null,
        coalesce(t0.imt44_rate, t0.ndr_addon_rate, t0.nf_addon_rate, t0.peril_rate) as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_RATE_APPLIED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'TYRE' as RISK_MOTOR_FITMENTS__FITMENT_TYPE_CK,
        'WHEEL_2' as RISK_MOTOR_FITMENTS__SEQUENCE_CK,
        t0.tyre_2 as RISK_MOTOR_FITMENTS__FITMENT_DESCRIPTION,
        '2' as RISK_MOTOR_IDV_TENURE__TENURE_YEAR_CK,
        'VEHICLE' as RISK_MOTOR_IDV_TENURE__IDV_COMPONENT_CK,
        t0.c_2nd_year_idv as RISK_MOTOR_IDV_TENURE__AGREED_IDV,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (coalesce(nullif(nullif(trim(j4.pol_risk_id), ''), ''), nullif(nullif(trim(j5.policy_quote_number), ''), ''))) is not null

    union all

    -- branch 136: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        nullif(nullif(trim(j4.pol_risk_id), ''), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        'SUB_TOTAL_16_Y2' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.sub_total_16_2nd_year as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null,
        'TOTAL' as AUG_QUOTE_SUM_INSURED_BREAKUP__SUM_INSURED_HEAD_CK,
        t0.sum_insured_details as AUG_QUOTE_SUM_INSURED_BREAKUP__HEAD_DESCRIPTION,
        t0.total_sum_insured as AUG_QUOTE_SUM_INSURED_BREAKUP__SUM_INSURED_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'TYRE' as RISK_MOTOR_FITMENTS__FITMENT_TYPE_CK,
        'WHEEL_3' as RISK_MOTOR_FITMENTS__SEQUENCE_CK,
        t0.tyre_3 as RISK_MOTOR_FITMENTS__FITMENT_DESCRIPTION,
        '3' as RISK_MOTOR_IDV_TENURE__TENURE_YEAR_CK,
        'VEHICLE' as RISK_MOTOR_IDV_TENURE__IDV_COMPONENT_CK,
        t0.c_3rd_year_idv as RISK_MOTOR_IDV_TENURE__AGREED_IDV,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (coalesce(nullif(nullif(trim(j4.pol_risk_id), ''), ''), nullif(nullif(trim(j5.policy_quote_number), ''), ''))) is not null

    union all

    -- branch 137: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        nullif(nullif(trim(j4.pol_risk_id), ''), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        'SUB_TOTAL_16_Y3' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.sub_total_16_3rd_year as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null,
        'PER_PERSON' as AUG_QUOTE_SUM_INSURED_BREAKUP__SUM_INSURED_HEAD_CK,
        null,
        t0.sum_insured_per_person as AUG_QUOTE_SUM_INSURED_BREAKUP__SUM_INSURED_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'TYRE' as RISK_MOTOR_FITMENTS__FITMENT_TYPE_CK,
        'WHEEL_4' as RISK_MOTOR_FITMENTS__SEQUENCE_CK,
        t0.tyre_4 as RISK_MOTOR_FITMENTS__FITMENT_DESCRIPTION,
        '4' as RISK_MOTOR_IDV_TENURE__TENURE_YEAR_CK,
        'VEHICLE' as RISK_MOTOR_IDV_TENURE__IDV_COMPONENT_CK,
        t0.c_4th_year_idv as RISK_MOTOR_IDV_TENURE__AGREED_IDV,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (coalesce(nullif(nullif(trim(j4.pol_risk_id), ''), ''), nullif(nullif(trim(j5.policy_quote_number), ''), ''))) is not null

    union all

    -- branch 138: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        nullif(nullif(trim(j4.pol_risk_id), ''), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        'SUB_TOTAL_16_Y4' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.sub_total_16_4th_year as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        'TYRE' as RISK_MOTOR_FITMENTS__FITMENT_TYPE_CK,
        'WHEEL_5' as RISK_MOTOR_FITMENTS__SEQUENCE_CK,
        t0.tyre_5 as RISK_MOTOR_FITMENTS__FITMENT_DESCRIPTION,
        '5' as RISK_MOTOR_IDV_TENURE__TENURE_YEAR_CK,
        'VEHICLE' as RISK_MOTOR_IDV_TENURE__IDV_COMPONENT_CK,
        t0.c_5th_year_idv as RISK_MOTOR_IDV_TENURE__AGREED_IDV,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (coalesce(nullif(nullif(trim(j4.pol_risk_id), ''), ''), nullif(nullif(trim(j5.policy_quote_number), ''), ''))) is not null

    union all

    -- branch 139: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'SUB_TOTAL_16_Y5' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.sub_total_16_5th_year as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 140: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'SUB_TOTAL_1_Y1' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.sub_total_1_1st_year as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 141: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'SUB_TOTAL_1_TP_Y1' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.sub_total_1_tp_1st_year as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 142: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'SUB_TOTAL_1_TP_Y2' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.sub_total_1_tp_2nd_year as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 143: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'SUB_TOTAL_1_TP_Y3' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.sub_total_1_tp_3rd_year as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 144: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'SUB_TOTAL_1_TP_Y4' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.sub_total_1_tp_4th_year as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 145: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'SUB_TOTAL_1_TP_Y5' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.sub_total_1_tp_5th_year as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 146: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'SUB_TOTAL_2_Y1' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.sub_total_2_1st_year as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 147: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'SUB_TOTAL_3_Y1' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.sub_total_3_1st_year as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 148: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'SUB_TOTAL_4_Y1' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.sub_total_4_1st_year as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 149: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'SUB_TOTAL_5_Y1' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.sub_total_5_1st_year as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 150: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'SUB_TOTAL_6_Y1' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.sub_total_6_1st_year as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 151: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'SUB_TOTAL_7_Y1' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.sub_total_7_1st_year as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 152: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'SUB_TOTAL_8_Y1' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.sub_total_8_1st_year as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 153: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'SUB_TOTAL_9_Y1' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.sub_total_9_1st_year as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 154: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'ACCIDENTS_TP' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_accidents_tp_premium as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 155: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'ANTI_THEFT_DISCOUNT' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.total_antitheft_device_discount_premium as AUG_QUOTE_PREMIUM_HEAD__DISCOUNT_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 156: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'ATTACHED_TRAILERS' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_attached_trailers_premium as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 157: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'TRAILER' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_attached_trailer_premium as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 158: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'AUTOMOBILE_ASSOCIATION_MEMBER' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_automobile_association_member_premium as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 159: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'BASIC_OD' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null,
        t0.total_basic_od_premium as AUG_QUOTE_PREMIUM_HEAD__BASE_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 160: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'BASIC_TP' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null,
        t0.total_basic_tp_premium as AUG_QUOTE_PREMIUM_HEAD__BASE_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 161: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'CD_DISCOUNT' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.total_cd_discount as AUG_QUOTE_PREMIUM_HEAD__DISCOUNT_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 162: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'CNG_KIT' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_cng_kit_fittings_premium as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 163: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'ADDON_COURTESY_CAR' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'ADDON' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_courtesy_car_premium as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 164: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'COMPULSORY_PA' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'PA' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_cpa_premium as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 165: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'DEMONSTRATION_EXTENSION' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_demonstration_extension_cover_premium as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 166: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'DEMO_CAR_APPORTION' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_demo_car_apportion as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 167: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'DRIVING_TUITION_APPORTION' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_driving_tuition_apportion as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 168: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'DRIVING_TUITION' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_driving_tuition_extension_premium as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 169: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'EARNED_TOTAL' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.total_earned_premium as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 170: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'EARNED_TOTAL_Y1' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.total_earned_premium_1st_year as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 171: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'EARNED_ANTI_THEFT_DISCOUNT' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.total_earned_premium_antitheft_device_discount as AUG_QUOTE_PREMIUM_HEAD__DISCOUNT_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 172: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'EARNED_TRAILER' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_earned_premium_attached_trailer as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 173: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'EARNED_AUTOMOBILE_ASSOCIATION_MEMBER' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_earned_premium_automobile_association_member as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 174: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'EARNED_BASIC_OD' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null,
        t0.total_earned_premium_basic_od as AUG_QUOTE_PREMIUM_HEAD__BASE_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 175: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'EARNED_CD_DISCOUNT' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.total_earned_premium_cd as AUG_QUOTE_PREMIUM_HEAD__DISCOUNT_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 176: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'EARNED_CNG_KIT' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_earned_premium_cng_kit as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 177: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'EARNED_ADDON_COURTESY_CAR' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'ADDON' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_earned_premium_courtesy_car as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 178: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'EARNED_DEMONSTRATION_EXTENSION' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_earned_premium_demo_extn_cover as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 179: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'EARNED_DRIVING_TUITION' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_earned_premium_driving_tuition as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 180: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'EARNED_ELECTRICAL_ACCESSORY' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_earned_premium_electrical_accessories as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 181: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'EARNED_EXTENDED_STP' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_earned_premium_extended_stp as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 182: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'EARNED_FIBRE_GLASS_FUEL_TANK' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_earned_premium_fibre_glass_fuel_tank as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 183: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'EARNED_GEOGRAPHICAL_EXTENSION' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_earned_premium_geog_extension as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 184: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'EARNED_HANDICAPPED_DISCOUNT' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.total_earned_premium_handicapped_discount as AUG_QUOTE_PREMIUM_HEAD__DISCOUNT_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 185: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'EARNED_IMPORTED_VEHICLE' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_earned_premium_imported_vehicle as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 186: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'EARNED_IMT14' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_earned_premium_imt14 as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 187: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'EARNED_IMT23' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_earned_premium_imt23 as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 188: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'EARNED_IMT34' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_earned_premium_imt34 as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 189: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'EARNED_IMT43' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_earned_premium_imt43 as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 190: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'EARNED_IMT44' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_earned_premium_imt44 as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 191: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'EARNED_IMT45' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_earned_premium_imt45 as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 192: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'EARNED_IMT47' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_earned_premium_imt47 as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 193: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'EARNED_IMT53' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_earned_premium_imt53 as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 194: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'EARNED_LOSS_OF_ACCESSORIES' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_earned_premium_loss_of_accessories as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 195: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'EARNED_LONG_TERM_DISCOUNT' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.total_earned_premium_ltd as AUG_QUOTE_PREMIUM_HEAD__DISCOUNT_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 196: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'EARNED_NO_CLAIM_BONUS' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.total_earned_premium_ncb as AUG_QUOTE_PREMIUM_HEAD__DISCOUNT_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 197: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'EARNED_NON_ELECTRICAL_ACCESSORY' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_earned_premium_nonelectrical_accessories as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 198: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'EARNED_NORMAL_RALLY' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_earned_premium_normal_rally as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 199: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'EARNED_SIDE_CAR' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_earned_premium_side_car as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 200: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'EARNED_SIDE_CAR_DISCOUNT' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.total_earned_premium_side_car_discount as AUG_QUOTE_PREMIUM_HEAD__DISCOUNT_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 201: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'EARNED_SPEED_RALLY' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_earned_premium_speed_rally as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 202: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'EARNED_SUB_TOTAL_16' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.total_earned_premium_sub_total_16 as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 203: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'EARNED_USE_WITHIN_OWN_PREMISES' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_earned_premium_use_within_own_premises as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 204: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'EARNED_VOLUNTARY_DEDUCTIBLE' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.total_earned_premium_voluntary_deductible as AUG_QUOTE_PREMIUM_HEAD__DISCOUNT_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 205: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'ELECTRICAL_ACCESSORY' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_electrical_accessories_premium as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 206: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'EXTENDED_STP' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_extended_stp as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 207: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'FIBRE_GLASS_FUEL_TANK' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_fibre_glass_fuel_tank_premium as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 208: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'GEOGRAPHICAL_EXTENSION' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_geographical_extension_premium as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 209: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'HANDICAPPED_DISCOUNT' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.total_handicapped_discount_premium as AUG_QUOTE_PREMIUM_HEAD__DISCOUNT_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 210: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'IMPORTED_VEHICLE_WITHOUT_CUSTOMS_DUTY' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_imported_vehicle_without_customs_duty_premium as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 211: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'IMT14' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_imt14_premium as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 212: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'IMT23' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_imt23_premium as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 213: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'IMT34' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_imt34_premium as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 214: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'IMT43' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_imt43_premium as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 215: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'IMT45' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_imt45_premium as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 216: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'IMT47' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_imt47_premium as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 217: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'IMT53' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_imt53_premium as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 218: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'IMT44' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_indemnity_to_hirer_imt_44_premium as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 219: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'INDEMNITY_TO_HIRER' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_indemnity_to_hirer_premium as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 220: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'LL_OTHER_EMPLOYEE' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_ll_for_employees_other_than_driver_and_cleaner_premium as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 221: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'LL_INSURED_CARRYING_VEHICLE' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_ll_insured_carrying_vehicle_premium as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 222: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'LL_OPERATION_MAINTENANCE_ABOVE_6' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_ll_operation_maintenance_above_6_premium as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 223: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'LL_OPERATION_MAINTENANCE' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_ll_operation_maintenance_premium as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 224: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'LL_EMPLOYEE' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_ll_to_employee_premium as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 225: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'LL_FARE_PAYING_PASSENGER_EMPLOYEE' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_ll_to_fare_paying_passenger_employees_premium as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 226: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'LL_PASSENGER' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_ll_to_passenger_premium as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 227: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'LOB_COMM' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.total_lob_comm_premium as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 228: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'LOB_COMM_Y1' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.total_lob_comm_premium_1st_year as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 229: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'LOSS_OF_ACCESSORIES' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_loss_of_accessories_premium as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 230: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'LONG_TERM_DISCOUNT' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.total_lt_discount as AUG_QUOTE_PREMIUM_HEAD__DISCOUNT_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 231: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'PA_NAMED_PASSENGER' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'PA' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_named_passenger_pa_premium as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 232: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'NON_ELECTRICAL_ACCESSORY' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_nonelectrical_accessories_premium as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 233: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'LL_NON_FARE_PAYING_EMPLOYEE' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_non_fare_paying_employee_premium as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 234: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'LL_NON_FARE_PAYING_PASSENGER' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_non_fare_paying_passenger_premium as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 235: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'NORMAL_RALLY' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_normal_rally_cover_premium as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 236: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'NO_CLAIM_BONUS' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.total_no_claim_bonus_premium as AUG_QUOTE_PREMIUM_HEAD__DISCOUNT_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 237: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'NET_OD' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_od_premium as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 238: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'NET_OD_Y1' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_od_premium_1st_year as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 239: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'PA_DRIVER_AND_CLEANER' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'PA' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_pa_for_driver_and_cleaner_premium as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 240: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'PA_PILLION_RIDER' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'PA' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_pa_for_pillion_rider_premium as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 241: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'PA_UNNAMED_HIRER_AND_PILLION' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'PA' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_pa_to_unnamed_hirer_and_pillion_premium as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 242: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'SIDE_CAR_DISCOUNT' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.total_side_car_discount_premium as AUG_QUOTE_PREMIUM_HEAD__DISCOUNT_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 243: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'SIDE_CAR' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_side_car_premium as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 244: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'SPEED_RALLY' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_speed_rally_premium as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 245: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'SUB_TOTAL_16' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.total_sub_total_16 as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 246: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'TPPD_RESTRICTION' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_tppd_restriction_premium as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 247: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'NET_TP' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_tp_premium as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 248: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'NET_TP_Y1' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_tp_premium_1st_year as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 249: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'NET_TP_Y2' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_tp_premium_2nd_year as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 250: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'NET_TP_Y3' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_tp_premium_3rd_year as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 251: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'NET_TP_Y4' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_tp_premium_4th_year as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 252: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'NET_TP_Y5' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_tp_premium_5th_year as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 253: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'PA_UNNAMED_PASSENGER' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'PA' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_unnamed_passenger_pa_premium as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 254: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'USE_OF_COMMERCIAL_VEHICLE' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_use_of_commercial_vehicle_premium as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 255: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'USE_WITHIN_OWN_PREMISES' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.total_use_within_own_premises_premium as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 256: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'VINTAGE_CAR_DISCOUNT' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.total_vintage_car_discount_premium as AUG_QUOTE_PREMIUM_HEAD__DISCOUNT_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 257: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'VOLUNTARY_DEDUCTIBLE' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.total_voluntary_deductible_premium as AUG_QUOTE_PREMIUM_HEAD__DISCOUNT_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 258: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'TPPD_RESTRICTION_Y1' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.tppd_restriction_premium_1st_year as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 259: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'TPPD_RESTRICTION_Y2' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.tppd_restriction_premium_2nd_year as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 260: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'TPPD_RESTRICTION_Y3' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.tppd_restriction_premium_3rd_year as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 261: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'TPPD_RESTRICTION_Y4' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.tppd_restriction_premium_4th_year as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 262: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'TPPD_RESTRICTION_Y5' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.tppd_restriction_premium_5th_year as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 263: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'TP_VEHICLE_LAID_OFF' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.tp_vehicle_laid_off_premium as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 264: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'PA_UNNAMED_PASSENGER_Y1' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'PA' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.unnamed_passenger_pa_premium_1st_year as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 265: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'PA_UNNAMED_PASSENGER_Y2' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'PA' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.unnamed_passenger_pa_premium_2nd_year as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 266: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'PA_UNNAMED_PASSENGER_Y3' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'PA' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.unnamed_passenger_pa_premium_3rd_year as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 267: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'PA_UNNAMED_PASSENGER_Y4' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'PA' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.unnamed_passenger_pa_premium_4th_year as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 268: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'PA_UNNAMED_PASSENGER_Y5' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'PA' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.unnamed_passenger_pa_premium_5th_year as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 269: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'USE_OF_COMMERCIAL_VEHICLE_Y1' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.use_of_commercial_vehicle_premium_1st_year as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 270: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'USE_OF_COMMERCIAL_VEHICLE_Y2' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.use_of_commercial_vehicle_premium_2nd_year as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 271: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'USE_OF_COMMERCIAL_VEHICLE_Y3' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.use_of_commercial_vehicle_premium_3rd_year as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 272: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'USE_OF_COMMERCIAL_VEHICLE_Y4' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.use_of_commercial_vehicle_premium_4th_year as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 273: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'USE_OF_COMMERCIAL_VEHICLE_Y5' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.use_of_commercial_vehicle_premium_5th_year as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 274: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'USE_WITHIN_OWN_PREMISES_Y1' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.use_within_own_premises_1st_year as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 275: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'VINTAGE_CAR_DISCOUNT_Y1' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.vintage_car_discount_premium_1st_year as AUG_QUOTE_PREMIUM_HEAD__DISCOUNT_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 276: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'VINTAGE_CAR_DISCOUNT_Y2' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.vintage_car_discount_premium_2nd_year as AUG_QUOTE_PREMIUM_HEAD__DISCOUNT_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 277: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'VINTAGE_CAR_DISCOUNT_Y3' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.vintage_car_discount_premium_3rd_year as AUG_QUOTE_PREMIUM_HEAD__DISCOUNT_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 278: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'VINTAGE_CAR_DISCOUNT_Y4' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.vintage_car_discount_premium_4th_year as AUG_QUOTE_PREMIUM_HEAD__DISCOUNT_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 279: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'VINTAGE_CAR_DISCOUNT_Y5' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.vintage_car_discount_premium_5th_year as AUG_QUOTE_PREMIUM_HEAD__DISCOUNT_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 280: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'VOLUNTARY_DEDUCTIBLE_Y1' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.voluntary_deductible_premium_1st_year as AUG_QUOTE_PREMIUM_HEAD__DISCOUNT_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 281: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'VOLUNTARY_DEDUCTIBLE_Y2' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.voluntary_deductible_premium_2nd_year as AUG_QUOTE_PREMIUM_HEAD__DISCOUNT_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 282: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'VOLUNTARY_DEDUCTIBLE_Y3' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.voluntary_deductible_premium_3rd_year as AUG_QUOTE_PREMIUM_HEAD__DISCOUNT_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 283: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'VOLUNTARY_DEDUCTIBLE_Y4' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.voluntary_deductible_premium_4th_year as AUG_QUOTE_PREMIUM_HEAD__DISCOUNT_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 284: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_COVER_RISK_COVER_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j5.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'VOLUNTARY_DEDUCTIBLE_Y5' as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.voluntary_deductible_premium_5th_year as AUG_QUOTE_PREMIUM_HEAD__DISCOUNT_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_16f3552d') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cove_9669cd85') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover_risk_cover_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_cover') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_quote_number), ''), '')) is not null

    union all

    -- branch 285: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
    select
        nullif(nullif(trim(t0.pre_inspection_number),''), '') as ASSESSMENT_BK,
        null,
        nullif(coalesce(nullif(trim(t0.cover_code), ''), nullif(trim(t0.covercode), '')), '') as COVERAGE_BK,
        null, null,
        nullif(nullif(trim(j4.policy_quote_number),''), '') as QUOTE_BK,
        nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null,
        t0.pin_source as ASSESSMENT_HEADER__ASSESSMENT_CHANNEL,
        t0.pin_status as ASSESSMENT_HEADER__ASSESSMENT_STATUS,
        null, null, null,
        t0.preinspection_charges as ASSESSMENT_HEADER__COST_OF_ASSESSMENT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.pin_excess_amount as AUG_ASSESSMENT_PRE_INSPECTION__IMPOSED_EXCESS_AMOUNT,
        t0.pin_excess as AUG_ASSESSMENT_PRE_INSPECTION__IMPOSED_EXCESS_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        t0.conditional_section as AUG_COVERAGE_CONDITIONS__CONDITIONAL_SECTION_REFERENCE,
        null,
        t0.cover_max_age as AUG_COVERAGE_CONDITIONS__MAXIMUM_AGE_ELIGIBLE,
        null,
        t0.benefit_period as AUG_COVERAGE_LIMITS__BENEFIT_PERIOD,
        null,
        t0.claim_registration_limit as AUG_COVERAGE_LIMITS__CLAIM_REGISTRATION_LIMIT,
        null, null,
        t0.daily_allowance_limit as AUG_COVERAGE_LIMITS__DAILY_ALLOWANCE_LIMIT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        t0.cover_end_date as AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_END_DATE,
        null, null,
        t0.cover_start_date as AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_START_DATE,
        t0.cover_status as AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_STATUS,
        null, null, null, null, null, null, null,
        t0.cover_sum_insured_in_transaction_currency as AUG_QUOTE_COVERAGE_SCHEDULE__SUM_INSURED,
        t0.cover_sum_insured_in_base_currency as AUG_QUOTE_COVERAGE_SCHEDULE__SUM_INSURED_IN_BASE_CURRENCY,
        null, null,
        coalesce(t0.admin_fee_details, t0.auto_adjusted_amount, t0.avg_cd, t0.clu_discount, t0.cross_sell_discount, t0.csd, t0.discount_in_premium) as AUG_QUOTE_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        t0.discount_in_commission as AUG_QUOTE_DISCOUNT_LOADING_APPLIED__COMMISSION_DISCOUNT_AMOUNT,
        coalesce(t0.employee_discount_applicable, t0.employee_or_vip_flag_discount_applicable) as AUG_QUOTE_DISCOUNT_LOADING_APPLIED__EXTRA_DISCOUNT_OPTED_INDICATOR,
        t0.discount_percentage as AUG_QUOTE_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        coalesce(t0.cover_premium_in_transaction_currency, t0.cumulative_minimum_premium, t0.earned_od_premium, t0.earned_policy, t0.earned_tp_premium, t0.endorsement_premium) as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        t0.cover_premium_in_base_currency as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM_IN_BASE_CURRENCY,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.franchise as COVERAGE_LIMITS__FRANCHISE_AMOUNT,
        null, null, null, null, null, null,
        t0.scpa_cover_inception_date as RISK_MOTOR_CPA__COMPULSORY_PA_EFFECTIVE_DATE,
        t0.scpa_cover_expiry_date as RISK_MOTOR_CPA__COMPULSORY_PA_EXPIRY_DATE,
        t0.compulsory_personal_accident_cover_applicability as RISK_MOTOR_CPA__COMPULSORY_PA_OWNER_DRIVER_INDICATOR,
        t0.scpa_cover_premium as RISK_MOTOR_CPA__COMPULSORY_PA_PREMIUM,
        t0.scpa_sum_insured as RISK_MOTOR_CPA__COMPULSORY_PA_SUM_INSURED,
        t0.cpa_tenure as RISK_MOTOR_CPA__COMPULSORY_PA_TENURE_YEARS,
        t0.vehicle_designed_for_blindhandicappedmentally_challenged_persons_and_endorsed_by_rta as RISK_MOTOR_CPA__HANDICAPPED_VEHICLE_INDICATOR,
        t0.do_you_hold_valid_driving_license as RISK_MOTOR_CPA__OWNER_DRIVER_LICENCE_EXISTS_INDICATOR,
        'BIFUEL_KIT' as RISK_MOTOR_FITMENTS__FITMENT_TYPE_CK,
        '1' as RISK_MOTOR_FITMENTS__SEQUENCE_CK,
        t0.fiber_glass_tank_unit as RISK_MOTOR_FITMENTS__FITMENT_DESCRIPTION,
        '1' as RISK_MOTOR_IDV_TENURE__TENURE_YEAR_CK,
        'VEHICLE' as RISK_MOTOR_IDV_TENURE__IDV_COMPONENT_CK,
        t0.c_1st_year_idv as RISK_MOTOR_IDV_TENURE__AGREED_IDV,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (coalesce(nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), ''), nullif(coalesce(nullif(trim(t0.cover_code), ''), nullif(trim(t0.covercode), '')), ''), nullif(nullif(trim(j4.policy_quote_number),''), ''), nullif(nullif(trim(t0.pre_inspection_number),''), ''))) is not null

    union all

    -- branch 286: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null,
        nullif(nullif(trim(t0.cover_code),''), '') as COVERAGE_BK,
        null, null,
        nullif(nullif(trim(j4.policy_quote_number), ''), '') as QUOTE_BK,
        nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.geographical_extension as AUG_COVERAGE_CONDITIONS__GEOGRAPHICAL_EXTENSION_CODE,
        null,
        t0.nd_applicable_for_organization as AUG_COVERAGE_CONDITIONS__NIL_DEPRECIATION_APPLICABLE_FOR_ORGANISATION_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.limit as COVERAGE_LIMITS__LIMIT_AMOUNT,
        null, null,
        'REASON_FOR_NONRENEWAL' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.reason_for_nonrenewal as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null,
        '2' as RISK_MOTOR_IDV_TENURE__TENURE_YEAR_CK,
        'VEHICLE' as RISK_MOTOR_IDV_TENURE__IDV_COMPONENT_CK,
        t0.c_2nd_year_idv as RISK_MOTOR_IDV_TENURE__AGREED_IDV,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (coalesce(nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), ''), nullif(nullif(trim(j4.policy_quote_number), ''), ''), nullif(nullif(trim(t0.cover_code),''), ''))) is not null

    union all

    -- branch 287: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null,
        nullif(nullif(trim(t0.cover_code), ''), '') as COVERAGE_BK,
        null, null,
        nullif(nullif(trim(j4.policy_quote_number), ''), '') as QUOTE_BK,
        nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.sum_insured_per_person as COVERAGE_LIMITS__PER_PERSON_LIMIT,
        t0.voluntary_excess as COVERAGE_LIMITS__VOLUNTARY_DEDUCTIBLE_AMOUNT,
        'REINS_PENDING_INDICATOR' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.reins_pending_indicator as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null,
        '3' as RISK_MOTOR_IDV_TENURE__TENURE_YEAR_CK,
        'VEHICLE' as RISK_MOTOR_IDV_TENURE__IDV_COMPONENT_CK,
        t0.c_3rd_year_idv as RISK_MOTOR_IDV_TENURE__AGREED_IDV,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (coalesce(nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), ''), nullif(nullif(trim(j4.policy_quote_number), ''), ''), nullif(nullif(trim(t0.cover_code), ''), ''))) is not null

    union all

    -- branch 288: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j4.policy_quote_number), ''), '') as QUOTE_BK,
        nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'RELATION_WITH_EMPLOYEE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.relation_with_employee as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null,
        '4' as RISK_MOTOR_IDV_TENURE__TENURE_YEAR_CK,
        'VEHICLE' as RISK_MOTOR_IDV_TENURE__IDV_COMPONENT_CK,
        t0.c_4th_year_idv as RISK_MOTOR_IDV_TENURE__AGREED_IDV,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (coalesce(nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), ''), nullif(nullif(trim(j4.policy_quote_number), ''), ''))) is not null

    union all

    -- branch 289: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j4.policy_quote_number), ''), '') as QUOTE_BK,
        nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'RENEWAL_CD' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.renewal_cd_ as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null,
        '5' as RISK_MOTOR_IDV_TENURE__TENURE_YEAR_CK,
        'VEHICLE' as RISK_MOTOR_IDV_TENURE__IDV_COMPONENT_CK,
        t0.c_5th_year_idv as RISK_MOTOR_IDV_TENURE__AGREED_IDV,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (coalesce(nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), ''), nullif(nullif(trim(j4.policy_quote_number), ''), ''))) is not null

    union all

    -- branch 290: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j4.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'RENEWAL_CD_AMOUNT' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.renewal_cd_amount as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_quote_number), ''), '')) is not null

    union all

    -- branch 291: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j4.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'RENEWAL_LOADING' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.renewal_loading_ as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_quote_number), ''), '')) is not null

    union all

    -- branch 292: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j4.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'RENEWAL_LOADING_AMOUNT' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.renewal_loading_amount as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_quote_number), ''), '')) is not null

    union all

    -- branch 293: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j4.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'RENEWAL_STATUS' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.renewal_status as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_quote_number), ''), '')) is not null

    union all

    -- branch 294: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j4.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'RENEWAL_STATUSS' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.renewal_statuss as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_quote_number), ''), '')) is not null

    union all

    -- branch 295: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j4.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'RISK_EXPIRY_TIME' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.risk_expiry_time as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_quote_number), ''), '')) is not null

    union all

    -- branch 296: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j4.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'RISK_INCEPTION_TIME' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.risk_inception_time as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_quote_number), ''), '')) is not null

    union all

    -- branch 297: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j4.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'RISK_PLAN' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.risk_plan as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_quote_number), ''), '')) is not null

    union all

    -- branch 298: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j4.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'RISK_PREMIUM_IN_BASE_CURRENCY' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.risk_premium_in_base_currency as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_quote_number), ''), '')) is not null

    union all

    -- branch 299: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j4.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'RISK_PREMIUM_IN_TRANSACTION_CURRENCY' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.risk_premium_in_transaction_currency as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_quote_number), ''), '')) is not null

    union all

    -- branch 300: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j4.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SERVICING_STATE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.servicing_state as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_quote_number), ''), '')) is not null

    union all

    -- branch 301: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j4.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SUB1' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.sub1 as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_quote_number), ''), '')) is not null

    union all

    -- branch 302: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j4.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SUB_STATUS' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.sub_status as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_quote_number), ''), '')) is not null

    union all

    -- branch 303: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j4.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SYSTEM_CD1' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.system_cd1 as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_quote_number), ''), '')) is not null

    union all

    -- branch 304: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j4.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SYSTEM_CD2' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.system_cd2 as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_quote_number), ''), '')) is not null

    union all

    -- branch 305: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j4.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SYSTEM_CD3' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.system_cd3 as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_quote_number), ''), '')) is not null

    union all

    -- branch 306: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j4.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SYSTEM_CD4' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.system_cd4 as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_quote_number), ''), '')) is not null

    union all

    -- branch 307: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j4.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SYSTEM_CD5' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.system_cd5 as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_quote_number), ''), '')) is not null

    union all

    -- branch 308: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j4.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'TOTAL_FEES' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.total_fees as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_quote_number), ''), '')) is not null

    union all

    -- branch 309: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j4.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'TOTAL_PREMIUM_DUE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.total_premium_due as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_quote_number), ''), '')) is not null

    union all

    -- branch 310: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j4.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'TP_PREMIUM_RATE' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.tp_premium_rate as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_quote_number), ''), '')) is not null

    union all

    -- branch 311: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j4.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'TRANSACTION_EVENT' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.transaction_event as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_quote_number), ''), '')) is not null

    union all

    -- branch 312: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j4.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'TYPEOFPOLICY' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.typeofpolicy as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_quote_number), ''), '')) is not null

    union all

    -- branch 313: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j4.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'USER_CD' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.user_cd as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_quote_number), ''), '')) is not null

    union all

    -- branch 314: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j4.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'USER_PREMIUM' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.user_premium as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_quote_number), ''), '')) is not null

    union all

    -- branch 315: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j4.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'UW_APPROVED_CD' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.uw_approved_cd as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_quote_number), ''), '')) is not null

    union all

    -- branch 316: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j4.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'UW_EXPLANATORY_NOTES' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.uw_explanatory_notes as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_quote_number), ''), '')) is not null

    union all

    -- branch 317: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j4.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'WRITTEN_OD' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.written_od as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_quote_number), ''), '')) is not null

    union all

    -- branch 318: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null,
        nullif(nullif(trim(j4.policy_quote_number), ''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'WRITTEN_TP' as QUOTE_RATING_INPUT__FACTOR_CODE_CK,
        t0.written_tp as QUOTE_RATING_INPUT__FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_quote_number), ''), '')) is not null

)

select
    ASSESSMENT_BK,
    CLAIM_BK,
    COVERAGE_BK,
    DOCUMENT_BK,
    POLICY_BK,
    QUOTE_BK,
    RISK_OBJECT_BK,
    __LNK_CLAIM_ASSESSMENT,
    __LNK_CLAIM_COVERAGE,
    __LNK_QUOTE_RISK_OBJECT,
    __LNK_RISK_OBJECT_DOCUMENT,
    first_value(ASSESSMENT_FRAUD_INVESTIGATION__FINDINGS_SUMMARY) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_FRAUD_INVESTIGATION__FINDINGS_SUMMARY,
    first_value(ASSESSMENT_HEADER__ASSESSMENT_CHANNEL) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_HEADER__ASSESSMENT_CHANNEL,
    first_value(ASSESSMENT_HEADER__ASSESSMENT_STATUS) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_HEADER__ASSESSMENT_STATUS,
    first_value(ASSESSMENT_HEADER__ASSESSMENT_TYPE) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_HEADER__ASSESSMENT_TYPE,
    first_value(ASSESSMENT_HEADER__ASSESSOR_REFERENCE) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_HEADER__ASSESSOR_REFERENCE,
    first_value(ASSESSMENT_HEADER__CONDUCTED_DATE) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_HEADER__CONDUCTED_DATE,
    first_value(ASSESSMENT_HEADER__COST_OF_ASSESSMENT) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_HEADER__COST_OF_ASSESSMENT,
    first_value(ASSESSMENT_HEADER__REQUESTED_DATE) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_HEADER__REQUESTED_DATE,
    first_value(ASSESSMENT_SURVEY__FINAL_SURVEY_INDICATOR) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_SURVEY__FINAL_SURVEY_INDICATOR,
    first_value(ASSESSMENT_SURVEY__FINAL_VISIT_DATE) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_SURVEY__FINAL_VISIT_DATE,
    first_value(ASSESSMENT_SURVEY__NUMBER_OF_VISITS) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_SURVEY__NUMBER_OF_VISITS,
    first_value(ASSESSMENT_SURVEY__SPOT_SURVEY_INDICATOR) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_SURVEY__SPOT_SURVEY_INDICATOR,
    first_value(ASSESSMENT_SURVEY__SURVEY_ALLOCATION_DATE) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_SURVEY__SURVEY_ALLOCATION_DATE,
    first_value(ASSESSMENT_SURVEY__SURVEY_TYPE) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_SURVEY__SURVEY_TYPE,
    first_value(ASSESSMENT_SURVEY__WORK_APPROVAL_DATE) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_SURVEY__WORK_APPROVAL_DATE,
    first_value(AUG_ASSESSMENT_HEADER__AI_ASSESSMENT_STATUS) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_HEADER__AI_ASSESSMENT_STATUS,
    first_value(AUG_ASSESSMENT_HEADER__ASSESSMENT_END_TIME) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_HEADER__ASSESSMENT_END_TIME,
    first_value(AUG_ASSESSMENT_HEADER__ASSESSMENT_NATURE) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_HEADER__ASSESSMENT_NATURE,
    first_value(AUG_ASSESSMENT_HEADER__ASSESSMENT_REPORT_REFERENCE) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_HEADER__ASSESSMENT_REPORT_REFERENCE,
    first_value(AUG_ASSESSMENT_HEADER__ASSESSMENT_REVIEW_REMARKS) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_HEADER__ASSESSMENT_REVIEW_REMARKS,
    first_value(AUG_ASSESSMENT_HEADER__ASSESSMENT_SCALE) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_HEADER__ASSESSMENT_SCALE,
    first_value(AUG_ASSESSMENT_HEADER__ASSESSMENT_START_TIME) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_HEADER__ASSESSMENT_START_TIME,
    first_value(AUG_ASSESSMENT_HEADER__CDC_REFERENCE_NUMBER) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_HEADER__CDC_REFERENCE_NUMBER,
    first_value(AUG_ASSESSMENT_HEADER__CDC_STATUS) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_HEADER__CDC_STATUS,
    first_value(AUG_ASSESSMENT_HEADER__DEPUTATION_CONFIRMATION_DATE) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_HEADER__DEPUTATION_CONFIRMATION_DATE,
    first_value(AUG_ASSESSMENT_HEADER__INSPECTION_CONDUCTED_INDICATOR) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_HEADER__INSPECTION_CONDUCTED_INDICATOR,
    first_value(AUG_ASSESSMENT_HEADER__INSPECTION_OTHER_REMARKS) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_HEADER__INSPECTION_OTHER_REMARKS,
    first_value(AUG_ASSESSMENT_HEADER__PERSONAL_ACCIDENT_ASSESSMENT_ACTION) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_HEADER__PERSONAL_ACCIDENT_ASSESSMENT_ACTION,
    first_value(AUG_ASSESSMENT_PRE_INSPECTION__IMPOSED_EXCESS_AMOUNT) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_PRE_INSPECTION__IMPOSED_EXCESS_AMOUNT,
    first_value(AUG_ASSESSMENT_PRE_INSPECTION__IMPOSED_EXCESS_INDICATOR) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_PRE_INSPECTION__IMPOSED_EXCESS_INDICATOR,
    first_value(AUG_ASSESSMENT_PRE_INSPECTION__INSPECTION_DELAY_DAYS) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_PRE_INSPECTION__INSPECTION_DELAY_DAYS,
    first_value(AUG_ASSESSMENT_PRE_INSPECTION__OWN_DAMAGE_INSPECTION_LOCATION_ADDRESS) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_PRE_INSPECTION__OWN_DAMAGE_INSPECTION_LOCATION_ADDRESS,
    first_value(AUG_ASSESSMENT_SURVEY__FINAL_SURVEY_REMARKS) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_SURVEY__FINAL_SURVEY_REMARKS,
    first_value(AUG_ASSESSMENT_SURVEY__FINAL_VISIT_TIME) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_SURVEY__FINAL_VISIT_TIME,
    first_value(AUG_ASSESSMENT_SURVEY__LIVE_VIDEO_SURVEY_INDICATOR) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_SURVEY__LIVE_VIDEO_SURVEY_INDICATOR,
    first_value(AUG_ASSESSMENT_SURVEY__PRELIMINARY_SURVEY_REPORT_DELAY_DAYS) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_SURVEY__PRELIMINARY_SURVEY_REPORT_DELAY_DAYS,
    first_value(AUG_ASSESSMENT_SURVEY__PRELIMINARY_SURVEY_REPORT_DELAY_REASON) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_SURVEY__PRELIMINARY_SURVEY_REPORT_DELAY_REASON,
    first_value(AUG_ASSESSMENT_SURVEY__PRELIMINARY_SURVEY_REPORT_DELAY_REMARKS) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_SURVEY__PRELIMINARY_SURVEY_REPORT_DELAY_REMARKS,
    first_value(AUG_ASSESSMENT_SURVEY__SPOT_SURVEY_DATE) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_SURVEY__SPOT_SURVEY_DATE,
    first_value(AUG_ASSESSMENT_SURVEY__SPOT_SURVEY_DELAY_DAYS) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_SURVEY__SPOT_SURVEY_DELAY_DAYS,
    first_value(AUG_ASSESSMENT_SURVEY__SPOT_SURVEY_OTHER_REMARKS) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_SURVEY__SPOT_SURVEY_OTHER_REMARKS,
    first_value(AUG_ASSESSMENT_SURVEY__SPOT_SURVEY_REMARKS) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_SURVEY__SPOT_SURVEY_REMARKS,
    first_value(AUG_ASSESSMENT_SURVEY__SPOT_SURVEY_TIME) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_SURVEY__SPOT_SURVEY_TIME,
    first_value(AUG_ASSESSMENT_SURVEY__SURVEYOR_GENERAL_OBSERVATIONS) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_SURVEY__SURVEYOR_GENERAL_OBSERVATIONS,
    first_value(AUG_ASSESSMENT_SURVEY__SURVEYOR_SCREEN_SAVE_INDICATOR_IS) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_SURVEY__SURVEYOR_SCREEN_SAVE_INDICATOR_IS,
    first_value(AUG_ASSESSMENT_SURVEY__SURVEYOR_SCREEN_SAVE_INDICATOR_PA) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_SURVEY__SURVEYOR_SCREEN_SAVE_INDICATOR_PA,
    first_value(AUG_ASSESSMENT_SURVEY__SURVEYOR_TECHNICAL_OBSERVATIONS) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_SURVEY__SURVEYOR_TECHNICAL_OBSERVATIONS,
    first_value(AUG_ASSESSMENT_SURVEY__SURVEY_CONFIRMATION_DELAY_DAYS) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_SURVEY__SURVEY_CONFIRMATION_DELAY_DAYS,
    first_value(AUG_ASSESSMENT_SURVEY__SURVEY_CONFIRMATION_OTHER_REMARKS) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_SURVEY__SURVEY_CONFIRMATION_OTHER_REMARKS,
    first_value(AUG_ASSESSMENT_SURVEY__WORK_APPROVAL_DELAY_DAYS) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_SURVEY__WORK_APPROVAL_DELAY_DAYS,
    first_value(AUG_ASSESSMENT_SURVEY__WORK_APPROVAL_OTHER_REMARKS) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_SURVEY__WORK_APPROVAL_OTHER_REMARKS,
    first_value(AUG_ASSESSMENT_SURVEY__WORK_APPROVAL_REMARKS) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_SURVEY__WORK_APPROVAL_REMARKS,
    first_value(AUG_ASSESSMENT_SURVEY__WORK_APPROVAL_TIME) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_SURVEY__WORK_APPROVAL_TIME,
    first_value(AUG_CLAIM_COVER_SECTION_ASSESSMENT__ADVERSE_MEDICAL_HISTORY_FINDING) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_COVER_SECTION_ASSESSMENT__ADVERSE_MEDICAL_HISTORY_FINDING,
    first_value(AUG_CLAIM_COVER_SECTION_ASSESSMENT__CASE_MANAGEMENT_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_COVER_SECTION_ASSESSMENT__CASE_MANAGEMENT_INDICATOR,
    first_value(AUG_CLAIM_COVER_SECTION_ASSESSMENT__NON_DISCLOSURE_FINDING) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_COVER_SECTION_ASSESSMENT__NON_DISCLOSURE_FINDING,
    first_value(AUG_CLAIM_DEDUCTION_WAIVER__ADDITIONAL_EXCESS_WAIVED_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_DEDUCTION_WAIVER__ADDITIONAL_EXCESS_WAIVED_INDICATOR,
    first_value(AUG_CLAIM_DEDUCTION_WAIVER__COMPULSORY_EXCESS_WAIVED_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_DEDUCTION_WAIVER__COMPULSORY_EXCESS_WAIVED_INDICATOR,
    first_value(AUG_CLAIM_DEDUCTION_WAIVER__FRANCHISE_EXCESS_FOR_OWN_DAMAGE_WAIVED_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_DEDUCTION_WAIVER__FRANCHISE_EXCESS_FOR_OWN_DAMAGE_WAIVED_INDICATOR,
    first_value(AUG_CLAIM_DEDUCTION_WAIVER__VOLUNTARY_EXCESS_WAIVED_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_DEDUCTION_WAIVER__VOLUNTARY_EXCESS_WAIVED_INDICATOR,
    first_value(AUG_COVERAGE_CONDITIONS__CONDITIONAL_SECTION_REFERENCE) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_CONDITIONS__CONDITIONAL_SECTION_REFERENCE,
    first_value(AUG_COVERAGE_CONDITIONS__GEOGRAPHICAL_EXTENSION_CODE) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_CONDITIONS__GEOGRAPHICAL_EXTENSION_CODE,
    first_value(AUG_COVERAGE_CONDITIONS__MAXIMUM_AGE_ELIGIBLE) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_CONDITIONS__MAXIMUM_AGE_ELIGIBLE,
    first_value(AUG_COVERAGE_CONDITIONS__NIL_DEPRECIATION_APPLICABLE_FOR_ORGANISATION_INDICATOR) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_CONDITIONS__NIL_DEPRECIATION_APPLICABLE_FOR_ORGANISATION_INDICATOR,
    first_value(AUG_COVERAGE_LIMITS__BENEFIT_PERIOD) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_LIMITS__BENEFIT_PERIOD,
    first_value(AUG_COVERAGE_LIMITS__CLAIM_REGISTRATION_COUNT_LIMIT) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_LIMITS__CLAIM_REGISTRATION_COUNT_LIMIT,
    first_value(AUG_COVERAGE_LIMITS__CLAIM_REGISTRATION_LIMIT) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_LIMITS__CLAIM_REGISTRATION_LIMIT,
    first_value(AUG_COVERAGE_LIMITS__COVERAGE_SUM_INSURED) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_LIMITS__COVERAGE_SUM_INSURED,
    first_value(AUG_COVERAGE_LIMITS__COVERAGE_SUM_INSURED_CURRENCY) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_LIMITS__COVERAGE_SUM_INSURED_CURRENCY,
    first_value(AUG_COVERAGE_LIMITS__DAILY_ALLOWANCE_LIMIT) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_LIMITS__DAILY_ALLOWANCE_LIMIT,
    first_value(AUG_COVERAGE_LIMITS__LIMIT_AMOUNT_IN_USD) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_LIMITS__LIMIT_AMOUNT_IN_USD,
    AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
    AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK,
    first_value(AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_AVAILED_FROM_DATE) ignore nulls over (partition by POLICY_BK, AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_AVAILED_FROM_DATE,
    first_value(AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_AVAILED_TO_DATE) ignore nulls over (partition by POLICY_BK, AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_AVAILED_TO_DATE,
    first_value(AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_BASE_CURRENCY_CODE) ignore nulls over (partition by POLICY_BK, AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_BASE_CURRENCY_CODE,
    first_value(AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_DELETED_INDICATOR) ignore nulls over (partition by POLICY_BK, AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_DELETED_INDICATOR,
    first_value(AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_DURATION) ignore nulls over (partition by POLICY_BK, AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_DURATION,
    first_value(AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_NAME) ignore nulls over (partition by POLICY_BK, AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_NAME,
    first_value(AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_RECORD_EFFECTIVE_DATE) ignore nulls over (partition by POLICY_BK, AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_RECORD_EFFECTIVE_DATE,
    first_value(AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_RECORD_EXPIRY_DATE) ignore nulls over (partition by POLICY_BK, AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_RECORD_EXPIRY_DATE,
    first_value(AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_SUM_INSURED_CURRENCY_CODE) ignore nulls over (partition by POLICY_BK, AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_SUM_INSURED_CURRENCY_CODE,
    first_value(AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_TERM) ignore nulls over (partition by POLICY_BK, AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_TERM,
    first_value(AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_TERM_UNIT) ignore nulls over (partition by POLICY_BK, AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_TERM_UNIT,
    first_value(AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_TRANSACTION_CURRENCY_CODE) ignore nulls over (partition by POLICY_BK, AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_TRANSACTION_CURRENCY_CODE,
    first_value(AUG_POLICY_COVERAGE_SCHEDULE__DISCOUNT_PERCENTAGE_APPLIED) ignore nulls over (partition by POLICY_BK, AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_COVERAGE_SCHEDULE__DISCOUNT_PERCENTAGE_APPLIED,
    first_value(AUG_POLICY_COVERAGE_SCHEDULE__PLAN_REFERENCE) ignore nulls over (partition by POLICY_BK, AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_COVERAGE_SCHEDULE__PLAN_REFERENCE,
    first_value(AUG_POLICY_COVERAGE_SCHEDULE__PREMIUM_FOR_COVERAGE_IN_BASE_CURRENCY) ignore nulls over (partition by POLICY_BK, AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_COVERAGE_SCHEDULE__PREMIUM_FOR_COVERAGE_IN_BASE_CURRENCY,
    first_value(AUG_POLICY_COVERAGE_SCHEDULE__SUM_INSURED_IN_BASE_CURRENCY) ignore nulls over (partition by POLICY_BK, AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_COVERAGE_SCHEDULE__SUM_INSURED_IN_BASE_CURRENCY,
    first_value(AUG_POLICY_COVERAGE_SCHEDULE__SUM_INSURED_IN_TRANSACTION_CURRENCY) ignore nulls over (partition by POLICY_BK, AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_COVERAGE_SCHEDULE__SUM_INSURED_IN_TRANSACTION_CURRENCY,
    AUG_POLICY_PREMIUM_TENURE__TENURE_YEAR_CK,
    AUG_POLICY_PREMIUM_TENURE__PREMIUM_HEAD_CODE_CK,
    first_value(AUG_POLICY_PREMIUM_TENURE__EARNED_PREMIUM_AMOUNT) ignore nulls over (partition by POLICY_BK, AUG_POLICY_PREMIUM_TENURE__TENURE_YEAR_CK, AUG_POLICY_PREMIUM_TENURE__PREMIUM_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_TENURE__EARNED_PREMIUM_AMOUNT,
    first_value(AUG_POLICY_PREMIUM_TENURE__EARNED_PREMIUM_SUB_TOTAL_AMOUNT) ignore nulls over (partition by POLICY_BK, AUG_POLICY_PREMIUM_TENURE__TENURE_YEAR_CK, AUG_POLICY_PREMIUM_TENURE__PREMIUM_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_TENURE__EARNED_PREMIUM_SUB_TOTAL_AMOUNT,
    first_value(AUG_POLICY_PREMIUM_TENURE__HEAD_PREMIUM_AMOUNT) ignore nulls over (partition by POLICY_BK, AUG_POLICY_PREMIUM_TENURE__TENURE_YEAR_CK, AUG_POLICY_PREMIUM_TENURE__PREMIUM_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_TENURE__HEAD_PREMIUM_AMOUNT,
    AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
    AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK,
    first_value(AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_AVAILED_FROM_DATE) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_AVAILED_FROM_DATE,
    first_value(AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_AVAILED_TO_DATE) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_AVAILED_TO_DATE,
    first_value(AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_BASE_CURRENCY_CODE) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_BASE_CURRENCY_CODE,
    first_value(AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_DELETED_INDICATOR) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_DELETED_INDICATOR,
    first_value(AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_DURATION) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_DURATION,
    first_value(AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_END_DATE) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_END_DATE,
    first_value(AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_RECORD_EFFECTIVE_DATE) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_RECORD_EFFECTIVE_DATE,
    first_value(AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_RECORD_EXPIRY_DATE) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_RECORD_EXPIRY_DATE,
    first_value(AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_START_DATE) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_START_DATE,
    first_value(AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_STATUS) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_STATUS,
    first_value(AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_SUM_INSURED_CURRENCY_CODE) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_SUM_INSURED_CURRENCY_CODE,
    first_value(AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_TERM) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_TERM,
    first_value(AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_TERM_UNIT) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_TERM_UNIT,
    first_value(AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_TRANSACTION_CURRENCY_CODE) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_TRANSACTION_CURRENCY_CODE,
    first_value(AUG_QUOTE_COVERAGE_SCHEDULE__DISCOUNT_PERCENTAGE_APPLIED) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_COVERAGE_SCHEDULE__DISCOUNT_PERCENTAGE_APPLIED,
    first_value(AUG_QUOTE_COVERAGE_SCHEDULE__PREMIUM_FOR_COVERAGE) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_COVERAGE_SCHEDULE__PREMIUM_FOR_COVERAGE,
    first_value(AUG_QUOTE_COVERAGE_SCHEDULE__PREMIUM_FOR_COVERAGE_IN_BASE_CURRENCY) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_COVERAGE_SCHEDULE__PREMIUM_FOR_COVERAGE_IN_BASE_CURRENCY,
    first_value(AUG_QUOTE_COVERAGE_SCHEDULE__SUM_INSURED) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_COVERAGE_SCHEDULE__SUM_INSURED,
    first_value(AUG_QUOTE_COVERAGE_SCHEDULE__SUM_INSURED_IN_BASE_CURRENCY) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_COVERAGE_SCHEDULE__SUM_INSURED_IN_BASE_CURRENCY,
    first_value(AUG_QUOTE_COVERAGE_SCHEDULE__SUM_INSURED_IN_TRANSACTION_CURRENCY) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_COVERAGE_SCHEDULE__SUM_INSURED_IN_TRANSACTION_CURRENCY,
    AUG_QUOTE_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
    first_value(AUG_QUOTE_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
    first_value(AUG_QUOTE_DISCOUNT_LOADING_APPLIED__COMMISSION_DISCOUNT_AMOUNT) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_DISCOUNT_LOADING_APPLIED__COMMISSION_DISCOUNT_AMOUNT,
    first_value(AUG_QUOTE_DISCOUNT_LOADING_APPLIED__EXTRA_DISCOUNT_OPTED_INDICATOR) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_DISCOUNT_LOADING_APPLIED__EXTRA_DISCOUNT_OPTED_INDICATOR,
    first_value(AUG_QUOTE_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED,
    first_value(AUG_QUOTE_DISCOUNT_LOADING_APPLIED__RATING_FACTOR_VALUE) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_DISCOUNT_LOADING_APPLIED__RATING_FACTOR_VALUE,
    AUG_QUOTE_PREMIUM_HEAD__TENURE_YEAR_CK,
    AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
    AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
    AUG_QUOTE_PREMIUM_HEAD__SECTION_CK,
    AUG_QUOTE_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK,
    first_value(AUG_QUOTE_PREMIUM_HEAD__BASE_AMOUNT) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_PREMIUM_HEAD__TENURE_YEAR_CK, AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK, AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK, AUG_QUOTE_PREMIUM_HEAD__SECTION_CK, AUG_QUOTE_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_PREMIUM_HEAD__BASE_AMOUNT,
    first_value(AUG_QUOTE_PREMIUM_HEAD__DISCOUNT_AMOUNT) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_PREMIUM_HEAD__TENURE_YEAR_CK, AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK, AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK, AUG_QUOTE_PREMIUM_HEAD__SECTION_CK, AUG_QUOTE_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_PREMIUM_HEAD__DISCOUNT_AMOUNT,
    first_value(AUG_QUOTE_PREMIUM_HEAD__EARNED_HEAD_PREMIUM) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_PREMIUM_HEAD__TENURE_YEAR_CK, AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK, AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK, AUG_QUOTE_PREMIUM_HEAD__SECTION_CK, AUG_QUOTE_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_PREMIUM_HEAD__EARNED_HEAD_PREMIUM,
    first_value(AUG_QUOTE_PREMIUM_HEAD__EARNED_PREMIUM_AMOUNT) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_PREMIUM_HEAD__TENURE_YEAR_CK, AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK, AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK, AUG_QUOTE_PREMIUM_HEAD__SECTION_CK, AUG_QUOTE_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_PREMIUM_HEAD__EARNED_PREMIUM_AMOUNT,
    first_value(AUG_QUOTE_PREMIUM_HEAD__EARNED_PREMIUM_SUB_TOTAL_AMOUNT) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_PREMIUM_HEAD__TENURE_YEAR_CK, AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK, AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK, AUG_QUOTE_PREMIUM_HEAD__SECTION_CK, AUG_QUOTE_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_PREMIUM_HEAD__EARNED_PREMIUM_SUB_TOTAL_AMOUNT,
    first_value(AUG_QUOTE_PREMIUM_HEAD__EXCHANGE_RATE_APPLIED) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_PREMIUM_HEAD__TENURE_YEAR_CK, AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK, AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK, AUG_QUOTE_PREMIUM_HEAD__SECTION_CK, AUG_QUOTE_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_PREMIUM_HEAD__EXCHANGE_RATE_APPLIED,
    first_value(AUG_QUOTE_PREMIUM_HEAD__EXPIRING_PREMIUM_AMOUNT) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_PREMIUM_HEAD__TENURE_YEAR_CK, AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK, AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK, AUG_QUOTE_PREMIUM_HEAD__SECTION_CK, AUG_QUOTE_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_PREMIUM_HEAD__EXPIRING_PREMIUM_AMOUNT,
    first_value(AUG_QUOTE_PREMIUM_HEAD__FIXED_PREMIUM_SYSTEM_CODE) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_PREMIUM_HEAD__TENURE_YEAR_CK, AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK, AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK, AUG_QUOTE_PREMIUM_HEAD__SECTION_CK, AUG_QUOTE_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_PREMIUM_HEAD__FIXED_PREMIUM_SYSTEM_CODE,
    first_value(AUG_QUOTE_PREMIUM_HEAD__HEAD_PREMIUM_AMOUNT) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_PREMIUM_HEAD__TENURE_YEAR_CK, AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK, AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK, AUG_QUOTE_PREMIUM_HEAD__SECTION_CK, AUG_QUOTE_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_PREMIUM_HEAD__HEAD_PREMIUM_AMOUNT,
    first_value(AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_PREMIUM_HEAD__TENURE_YEAR_CK, AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK, AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK, AUG_QUOTE_PREMIUM_HEAD__SECTION_CK, AUG_QUOTE_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM,
    first_value(AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM_IN_BASE_CURRENCY) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_PREMIUM_HEAD__TENURE_YEAR_CK, AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK, AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK, AUG_QUOTE_PREMIUM_HEAD__SECTION_CK, AUG_QUOTE_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM_IN_BASE_CURRENCY,
    first_value(AUG_QUOTE_PREMIUM_HEAD__PREMIUM_RATE_APPLIED) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_PREMIUM_HEAD__TENURE_YEAR_CK, AUG_QUOTE_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK, AUG_QUOTE_PREMIUM_HEAD__COVERAGE_REFERENCE_CK, AUG_QUOTE_PREMIUM_HEAD__SECTION_CK, AUG_QUOTE_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_PREMIUM_HEAD__PREMIUM_RATE_APPLIED,
    AUG_QUOTE_SUM_INSURED_BREAKUP__SUM_INSURED_HEAD_CK,
    first_value(AUG_QUOTE_SUM_INSURED_BREAKUP__HEAD_DESCRIPTION) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_SUM_INSURED_BREAKUP__SUM_INSURED_HEAD_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_SUM_INSURED_BREAKUP__HEAD_DESCRIPTION,
    first_value(AUG_QUOTE_SUM_INSURED_BREAKUP__SUM_INSURED_AMOUNT) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_SUM_INSURED_BREAKUP__SUM_INSURED_HEAD_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_SUM_INSURED_BREAKUP__SUM_INSURED_AMOUNT,
    first_value(CLAIM_DEDUCTION_WAIVER__GOODWILL_AMOUNT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_DEDUCTION_WAIVER__GOODWILL_AMOUNT,
    first_value(CLAIM_DEDUCTION_WAIVER__GOODWILL_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_DEDUCTION_WAIVER__GOODWILL_INDICATOR,
    first_value(CLAIM_DEDUCTION_WAIVER__WAIVER_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_DEDUCTION_WAIVER__WAIVER_INDICATOR,
    first_value(CLAIM_PA_DETAIL__INJURY_TYPE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_PA_DETAIL__INJURY_TYPE,
    first_value(CLAIM_QUALITY_AUDIT__LEAKAGE_IDENTIFIED_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_QUALITY_AUDIT__LEAKAGE_IDENTIFIED_INDICATOR,
    first_value(COVERAGE_LIMITS__DEDUCTIBLE_AMOUNT) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COVERAGE_LIMITS__DEDUCTIBLE_AMOUNT,
    first_value(COVERAGE_LIMITS__EXCESS_AMOUNT) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COVERAGE_LIMITS__EXCESS_AMOUNT,
    first_value(COVERAGE_LIMITS__FRANCHISE_AMOUNT) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COVERAGE_LIMITS__FRANCHISE_AMOUNT,
    first_value(COVERAGE_LIMITS__INDEMNITY_PERIOD) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COVERAGE_LIMITS__INDEMNITY_PERIOD,
    first_value(COVERAGE_LIMITS__LIMIT_AMOUNT) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COVERAGE_LIMITS__LIMIT_AMOUNT,
    first_value(COVERAGE_LIMITS__PER_PERSON_LIMIT) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COVERAGE_LIMITS__PER_PERSON_LIMIT,
    first_value(COVERAGE_LIMITS__VOLUNTARY_DEDUCTIBLE_AMOUNT) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COVERAGE_LIMITS__VOLUNTARY_DEDUCTIBLE_AMOUNT,
    QUOTE_RATING_INPUT__FACTOR_CODE_CK,
    first_value(QUOTE_RATING_INPUT__FACTOR_VALUE) ignore nulls over (partition by QUOTE_BK, QUOTE_RATING_INPUT__FACTOR_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as QUOTE_RATING_INPUT__FACTOR_VALUE,
    first_value(RISK_MOTOR_CPA__COMPULSORY_PA_EFFECTIVE_DATE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_CPA__COMPULSORY_PA_EFFECTIVE_DATE,
    first_value(RISK_MOTOR_CPA__COMPULSORY_PA_EXPIRY_DATE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_CPA__COMPULSORY_PA_EXPIRY_DATE,
    first_value(RISK_MOTOR_CPA__COMPULSORY_PA_OWNER_DRIVER_INDICATOR) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_CPA__COMPULSORY_PA_OWNER_DRIVER_INDICATOR,
    first_value(RISK_MOTOR_CPA__COMPULSORY_PA_PREMIUM) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_CPA__COMPULSORY_PA_PREMIUM,
    first_value(RISK_MOTOR_CPA__COMPULSORY_PA_SUM_INSURED) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_CPA__COMPULSORY_PA_SUM_INSURED,
    first_value(RISK_MOTOR_CPA__COMPULSORY_PA_TENURE_YEARS) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_CPA__COMPULSORY_PA_TENURE_YEARS,
    first_value(RISK_MOTOR_CPA__HANDICAPPED_VEHICLE_INDICATOR) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_CPA__HANDICAPPED_VEHICLE_INDICATOR,
    first_value(RISK_MOTOR_CPA__OWNER_DRIVER_LICENCE_EXISTS_INDICATOR) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_CPA__OWNER_DRIVER_LICENCE_EXISTS_INDICATOR,
    RISK_MOTOR_FITMENTS__FITMENT_TYPE_CK,
    RISK_MOTOR_FITMENTS__SEQUENCE_CK,
    first_value(RISK_MOTOR_FITMENTS__FITMENT_DESCRIPTION) ignore nulls over (partition by RISK_OBJECT_BK, RISK_MOTOR_FITMENTS__FITMENT_TYPE_CK, RISK_MOTOR_FITMENTS__SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_FITMENTS__FITMENT_DESCRIPTION,
    RISK_MOTOR_IDV_TENURE__TENURE_YEAR_CK,
    RISK_MOTOR_IDV_TENURE__IDV_COMPONENT_CK,
    first_value(RISK_MOTOR_IDV_TENURE__AGREED_IDV) ignore nulls over (partition by RISK_OBJECT_BK, RISK_MOTOR_IDV_TENURE__TENURE_YEAR_CK, RISK_MOTOR_IDV_TENURE__IDV_COMPONENT_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_IDV_TENURE__AGREED_IDV,
    -- the row's own source time: LOAD_DATETIME for hubs, links and single-active satellites
    m.REC_REFRESH_AT,
    -- multi-active satellites on POLICY_BK (SAT_MOTOR_AUG_POLICY_COVERAGE_SCHEDULE, SAT_MOTOR_AUG_POLICY_PREMIUM_TENURE):
    -- one load time per POLICY_BK, the newest REC_REFRESH_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when coalesce(m.AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_AVAILED_FROM_DATE, m.AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_AVAILED_TO_DATE, m.AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_BASE_CURRENCY_CODE, m.AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_DELETED_INDICATOR, m.AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_DURATION, m.AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_NAME, m.AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_RECORD_EFFECTIVE_DATE, m.AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_RECORD_EXPIRY_DATE, m.AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_SUM_INSURED_CURRENCY_CODE, m.AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_TERM, m.AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_TERM_UNIT, m.AUG_POLICY_COVERAGE_SCHEDULE__COVERAGE_TRANSACTION_CURRENCY_CODE, m.AUG_POLICY_COVERAGE_SCHEDULE__DISCOUNT_PERCENTAGE_APPLIED, m.AUG_POLICY_COVERAGE_SCHEDULE__PLAN_REFERENCE, m.AUG_POLICY_COVERAGE_SCHEDULE__PREMIUM_FOR_COVERAGE_IN_BASE_CURRENCY, m.AUG_POLICY_COVERAGE_SCHEDULE__SUM_INSURED_IN_BASE_CURRENCY, m.AUG_POLICY_COVERAGE_SCHEDULE__SUM_INSURED_IN_TRANSACTION_CURRENCY, m.AUG_POLICY_PREMIUM_TENURE__EARNED_PREMIUM_AMOUNT, m.AUG_POLICY_PREMIUM_TENURE__EARNED_PREMIUM_SUB_TOTAL_AMOUNT, m.AUG_POLICY_PREMIUM_TENURE__HEAD_PREMIUM_AMOUNT) is not null
             then m.REC_REFRESH_AT end)
        over (partition by m.POLICY_BK) as POLICY_BK__MA_LOAD_DATETIME,
    -- multi-active satellites on QUOTE_BK (SAT_MOTOR_AUG_QUOTE_COVERAGE_SCHEDULE, SAT_MOTOR_AUG_QUOTE_DISCOUNT_LOADING_APPLIED, SAT_MOTOR_AUG_QUOTE_PREMIUM_HEAD, SAT_MOTOR_AUG_QUOTE_SUM_INSURED_BREAKUP, SAT_QUOTE_RATING_INPUT):
    -- one load time per QUOTE_BK, the newest REC_REFRESH_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when coalesce(m.AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_AVAILED_FROM_DATE, m.AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_AVAILED_TO_DATE, m.AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_BASE_CURRENCY_CODE, m.AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_DELETED_INDICATOR, m.AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_DURATION, m.AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_END_DATE, m.AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_RECORD_EFFECTIVE_DATE, m.AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_RECORD_EXPIRY_DATE, m.AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_START_DATE, m.AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_STATUS, m.AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_SUM_INSURED_CURRENCY_CODE, m.AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_TERM, m.AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_TERM_UNIT, m.AUG_QUOTE_COVERAGE_SCHEDULE__COVERAGE_TRANSACTION_CURRENCY_CODE, m.AUG_QUOTE_COVERAGE_SCHEDULE__DISCOUNT_PERCENTAGE_APPLIED, m.AUG_QUOTE_COVERAGE_SCHEDULE__PREMIUM_FOR_COVERAGE, m.AUG_QUOTE_COVERAGE_SCHEDULE__PREMIUM_FOR_COVERAGE_IN_BASE_CURRENCY, m.AUG_QUOTE_COVERAGE_SCHEDULE__SUM_INSURED, m.AUG_QUOTE_COVERAGE_SCHEDULE__SUM_INSURED_IN_BASE_CURRENCY, m.AUG_QUOTE_COVERAGE_SCHEDULE__SUM_INSURED_IN_TRANSACTION_CURRENCY, m.AUG_QUOTE_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED, m.AUG_QUOTE_DISCOUNT_LOADING_APPLIED__COMMISSION_DISCOUNT_AMOUNT, m.AUG_QUOTE_DISCOUNT_LOADING_APPLIED__EXTRA_DISCOUNT_OPTED_INDICATOR, m.AUG_QUOTE_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED, m.AUG_QUOTE_DISCOUNT_LOADING_APPLIED__RATING_FACTOR_VALUE, m.AUG_QUOTE_PREMIUM_HEAD__BASE_AMOUNT, m.AUG_QUOTE_PREMIUM_HEAD__DISCOUNT_AMOUNT, m.AUG_QUOTE_PREMIUM_HEAD__EARNED_HEAD_PREMIUM, m.AUG_QUOTE_PREMIUM_HEAD__EARNED_PREMIUM_AMOUNT, m.AUG_QUOTE_PREMIUM_HEAD__EARNED_PREMIUM_SUB_TOTAL_AMOUNT, m.AUG_QUOTE_PREMIUM_HEAD__EXCHANGE_RATE_APPLIED, m.AUG_QUOTE_PREMIUM_HEAD__EXPIRING_PREMIUM_AMOUNT, m.AUG_QUOTE_PREMIUM_HEAD__FIXED_PREMIUM_SYSTEM_CODE, m.AUG_QUOTE_PREMIUM_HEAD__HEAD_PREMIUM_AMOUNT, m.AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM, m.AUG_QUOTE_PREMIUM_HEAD__NET_HEAD_PREMIUM_IN_BASE_CURRENCY, m.AUG_QUOTE_PREMIUM_HEAD__PREMIUM_RATE_APPLIED, m.AUG_QUOTE_SUM_INSURED_BREAKUP__HEAD_DESCRIPTION, m.AUG_QUOTE_SUM_INSURED_BREAKUP__SUM_INSURED_AMOUNT, m.QUOTE_RATING_INPUT__FACTOR_VALUE) is not null
             then m.REC_REFRESH_AT end)
        over (partition by m.QUOTE_BK) as QUOTE_BK__MA_LOAD_DATETIME,
    -- multi-active satellites on RISK_OBJECT_BK (SAT_RISK_MOTOR_FITMENTS, SAT_RISK_MOTOR_IDV_TENURE):
    -- one load time per RISK_OBJECT_BK, the newest REC_REFRESH_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when coalesce(m.RISK_MOTOR_FITMENTS__FITMENT_DESCRIPTION, m.RISK_MOTOR_IDV_TENURE__AGREED_IDV) is not null
             then m.REC_REFRESH_AT end)
        over (partition by m.RISK_OBJECT_BK) as RISK_OBJECT_BK__MA_LOAD_DATETIME
from merged m
