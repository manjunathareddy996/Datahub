-- CENTRAL VIEW v13_policy -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_ENDORSEMENT_DETAILS
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
-- Walk tables, joined only to resolve spine keys (not counted):
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_MULTI_SET_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_MOTOR_AUG_POLICY_DISCOUNT_LOADING_APPLIED
--   SAT_MOTOR_AUG_POLICY_ENDORSEMENT
--   SAT_MOTOR_AUG_POLICY_HEADER
--   SAT_MOTOR_AUG_POLICY_PA_NAMED_PERSON
--   SAT_MOTOR_AUG_POLICY_PREMIUM_SUMMARY
--   SAT_POLICY_CLASSIFICATION
--   SAT_POLICY_COVERAGE_SCHEDULE
--   SAT_POLICY_DISCOUNT_LOADING_APPLIED
--   SAT_POLICY_ENDORSEMENT
--   SAT_POLICY_PREMIUM_HEAD
--   SAT_POLICY_SUM_INSURED_BREAKUP
--   SAT_POLICY_TAX_HEAD
--   SAT_POLICY_TERMS
-- Links whose legs come from one source row on this view (rule 6):
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
    select
        nullif(nullif(trim(j3.policyno),''), '') as POLICY_BK,
        cast(null as varchar) as AUG_POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        cast(null as varchar) as AUG_POLICY_DISCOUNT_LOADING_APPLIED__EMPLOYEE_RELATIONSHIP_TO_INSURED,
        cast(null as varchar) as AUG_POLICY_DISCOUNT_LOADING_APPLIED__ITEM_APPLIED_INDICATOR,
        cast(null as varchar) as AUG_POLICY_DISCOUNT_LOADING_APPLIED__RATING_FACTOR_VALUE,
        cast(null as varchar) as AUG_POLICY_DISCOUNT_LOADING_APPLIED__SPECIAL_RATE_APPLICABLE_INDICATOR,
        cast(null as varchar) as AUG_POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER_CK,
        cast(null as varchar) as AUG_POLICY_ENDORSEMENT__ENDORSEMENT_APPROVED_DATE,
        cast(null as varchar) as AUG_POLICY_ENDORSEMENT__ENDORSEMENT_REMARKS,
        cast(null as varchar) as AUG_POLICY_ENDORSEMENT__REVISED_SUM_INSURED_AMOUNT,
        cast(null as varchar) as AUG_POLICY_HEADER__ADDITIONAL_REMARKS,
        cast(null as varchar) as AUG_POLICY_HEADER__APPLICATION_SUBMISSION_DATE,
        cast(null as varchar) as AUG_POLICY_HEADER__APPLICATION_SUBMISSION_TIME,
        cast(null as varchar) as AUG_POLICY_HEADER__ATTACHED_COVER_CODE_LIST,
        cast(null as varchar) as AUG_POLICY_HEADER__BASE_CURRENCY_CODE,
        cast(null as varchar) as AUG_POLICY_HEADER__BUSINESS_TYPE,
        cast(null as varchar) as AUG_POLICY_HEADER__CHILD_DETAIL_TYPE_SELECTED,
        cast(null as varchar) as AUG_POLICY_HEADER__CLAIM_INTIMATION_REFERENCE,
        cast(null as varchar) as AUG_POLICY_HEADER__COR_INDICATOR,
        cast(null as varchar) as AUG_POLICY_HEADER__COVER_PACKAGE_CODE,
        t0.destination_policy_number as AUG_POLICY_HEADER__DESTINATION_POLICY_NUMBER,
        cast(null as varchar) as AUG_POLICY_HEADER__ENDORSEMENT_APPLICABLE_INDICATOR,
        cast(null as varchar) as AUG_POLICY_HEADER__EXPENSE_PAYMENT_MODE,
        cast(null as varchar) as AUG_POLICY_HEADER__FINANCIAL_YEAR,
        cast(null as varchar) as AUG_POLICY_HEADER__FIRST_EXECUTION_INDICATOR,
        cast(null as varchar) as AUG_POLICY_HEADER__INSURER_NAME,
        cast(null as varchar) as AUG_POLICY_HEADER__LEAD_REFERENCE,
        cast(null as varchar) as AUG_POLICY_HEADER__LG_CODE,
        cast(null as varchar) as AUG_POLICY_HEADER__LINKED_PLAN_REFERENCE,
        cast(null as varchar) as AUG_POLICY_HEADER__LOSS_INTIMATED_BY_ROLE,
        cast(null as varchar) as AUG_POLICY_HEADER__MANDATORY_QUESTIONNAIRE_INDICATOR,
        cast(null as varchar) as AUG_POLICY_HEADER__MASTER_QUOTE_REFERENCE,
        cast(null as varchar) as AUG_POLICY_HEADER__NOT_TAKEN_UP_INDICATOR,
        cast(null as varchar) as AUG_POLICY_HEADER__ODS_REQUIRED_FOR,
        cast(null as varchar) as AUG_POLICY_HEADER__OEM_POLICY_REFERENCE,
        cast(null as varchar) as AUG_POLICY_HEADER__PIN_CODE_VALIDATION_PATTERN,
        cast(null as varchar) as AUG_POLICY_HEADER__PLAN_CATEGORY,
        cast(null as varchar) as AUG_POLICY_HEADER__PLAN_INSURED_CATEGORY,
        cast(null as varchar) as AUG_POLICY_HEADER__PLAN_REFERENCE,
        cast(null as varchar) as AUG_POLICY_HEADER__POLICY_INTIMATION_DATE,
        cast(null as varchar) as AUG_POLICY_HEADER__POLICY_LEVEL_EXCHANGE_RATE,
        cast(null as varchar) as AUG_POLICY_HEADER__POLICY_PLAN_NAME,
        cast(null as varchar) as AUG_POLICY_HEADER__POLICY_TENURE_YEARS,
        cast(null as varchar) as AUG_POLICY_HEADER__POLICY_TERM_UNIT,
        cast(null as varchar) as AUG_POLICY_HEADER__POLICY_TRANSACTION_TYPE,
        cast(null as varchar) as AUG_POLICY_HEADER__PORTAL_PAYMENT_MODE,
        cast(null as varchar) as AUG_POLICY_HEADER__PREMIUM_CALCULATION_MODE,
        cast(null as varchar) as AUG_POLICY_HEADER__PREMIUM_CURRENCY_CODE,
        cast(null as varchar) as AUG_POLICY_HEADER__PREMIUM_CURRENCY_EXCHANGE_RATE,
        cast(null as varchar) as AUG_POLICY_HEADER__PREMIUM_PAYER_SAME_AS_POLICYHOLDER_INDICATOR,
        cast(null as varchar) as AUG_POLICY_HEADER__PREMIUM_PAYMENT_SCHEDULE_REFERENCE,
        cast(null as varchar) as AUG_POLICY_HEADER__PREVIOUS_PRODUCT_REFERENCE,
        cast(null as varchar) as AUG_POLICY_HEADER__PRE_BOOKED_POLICY_NUMBER,
        cast(null as varchar) as AUG_POLICY_HEADER__PRIVILEGED_CUSTOMER_SEGMENT_INDICATOR,
        cast(null as varchar) as AUG_POLICY_HEADER__QUESTIONNAIRE_PACKAGE_REFERENCE,
        cast(null as varchar) as AUG_POLICY_HEADER__REINSURANCE_PLACEMENT_PENDING_INDICATOR,
        cast(null as varchar) as AUG_POLICY_HEADER__RISK_LEVEL_BASE_CURRENCY_CODE,
        cast(null as varchar) as AUG_POLICY_HEADER__RISK_LEVEL_SUM_INSURED_TRANSACTION_CURRENCY_CODE,
        cast(null as varchar) as AUG_POLICY_HEADER__RISK_LEVEL_TRANSACTION_CURRENCY_CODE,
        cast(null as varchar) as AUG_POLICY_HEADER__SCIP_SCHEME_REFERENCE_NUMBER,
        cast(null as varchar) as AUG_POLICY_HEADER__SCRUTINY_STATUS,
        cast(null as varchar) as AUG_POLICY_HEADER__SELECTED_COVER_CODE_LIST,
        cast(null as varchar) as AUG_POLICY_HEADER__SELECTED_OPTION_INDICATOR,
        cast(null as varchar) as AUG_POLICY_HEADER__SERVICING_BRANCH_NAME,
        cast(null as varchar) as AUG_POLICY_HEADER__STANDALONE_CPA_POLICY_NUMBER,
        cast(null as varchar) as AUG_POLICY_HEADER__STRAIGHT_THROUGH_PROCESSING_REASON,
        t0.subchannel_name as AUG_POLICY_HEADER__SUB_CHANNEL_NAME,
        cast(null as varchar) as AUG_POLICY_HEADER__SUM_INSURED_CURRENCY_CODE,
        cast(null as varchar) as AUG_POLICY_HEADER__SUM_INSURED_CURRENCY_EXCHANGE_RATE,
        cast(null as varchar) as AUG_POLICY_HEADER__SUM_INSURED_TOTAL_IN_BASE_CURRENCY,
        cast(null as varchar) as AUG_POLICY_HEADER__SUM_INSURED_TOTAL_IN_TRANSACTION_CURRENCY,
        cast(null as varchar) as AUG_POLICY_HEADER__TAGGED_POLICY_REFERENCE,
        cast(null as varchar) as AUG_POLICY_HEADER__TRANSACTION_CURRENCY_CODE,
        cast(null as varchar) as AUG_POLICY_HEADER__TRANSACTION_LINE_SERIAL_NUMBER,
        cast(null as varchar) as AUG_POLICY_HEADER__TRANSACTION_REFERENCE_DETAIL,
        cast(null as varchar) as AUG_POLICY_HEADER__UNDERWRITING_REMARKS,
        cast(null as varchar) as AUG_POLICY_HEADER__VALIDATION_ERROR_DESCRIPTION,
        cast(null as varchar) as AUG_POLICY_PA_NAMED_PERSON__NAMED_PERSON_NAME_CK,
        cast(null as varchar) as AUG_POLICY_PA_NAMED_PERSON__NAMED_PERSON_SEQUENCE_CK,
        cast(null as varchar) as AUG_POLICY_PA_NAMED_PERSON__BENEFIT_ALLOCATION_PERCENTAGE,
        cast(null as varchar) as AUG_POLICY_PA_NAMED_PERSON__NAMED_PERSON_AGE,
        cast(null as varchar) as AUG_POLICY_PA_NAMED_PERSON__NAMED_PERSON_GENDER,
        cast(null as varchar) as AUG_POLICY_PA_NAMED_PERSON__NAMED_PERSON_NAME,
        cast(null as varchar) as AUG_POLICY_PA_NAMED_PERSON__NAMED_PERSON_RELATIONSHIP,
        cast(null as varchar) as AUG_POLICY_PA_NAMED_PERSON__NOMINEE_NAME,
        cast(null as varchar) as AUG_POLICY_PA_NAMED_PERSON__NOMINEE_RELATIONSHIP_TO_INSURED,
        cast(null as varchar) as AUG_POLICY_PREMIUM_SUMMARY__ADMINISTRATION_CHARGE_AMOUNT,
        cast(null as varchar) as AUG_POLICY_PREMIUM_SUMMARY__ADMINISTRATION_FEE_DESCRIPTION,
        cast(null as varchar) as AUG_POLICY_PREMIUM_SUMMARY__ADMINISTRATIVE_FEE_AMOUNT,
        cast(null as varchar) as AUG_POLICY_PREMIUM_SUMMARY__ADMINISTRATIVE_FEE_WAIVED_INDICATOR,
        cast(null as varchar) as AUG_POLICY_PREMIUM_SUMMARY__BANK_CHARGE_AMOUNT,
        cast(null as varchar) as AUG_POLICY_PREMIUM_SUMMARY__DISCOUNT_PERCENTAGE,
        cast(null as varchar) as AUG_POLICY_PREMIUM_SUMMARY__EXCHANGE_RATE,
        cast(null as varchar) as AUG_POLICY_PREMIUM_SUMMARY__FIXED_CASH_DEPOSIT_SETTLEMENT_INDICATOR,
        cast(null as varchar) as AUG_POLICY_PREMIUM_SUMMARY__LOADED_PREMIUM_AMOUNT,
        cast(null as varchar) as AUG_POLICY_PREMIUM_SUMMARY__LOADING_PERCENTAGE,
        cast(null as varchar) as AUG_POLICY_PREMIUM_SUMMARY__MANUAL_REFUND_AMOUNT,
        cast(null as varchar) as AUG_POLICY_PREMIUM_SUMMARY__MINIMUM_GROSS_PREMIUM,
        cast(null as varchar) as AUG_POLICY_PREMIUM_SUMMARY__NET_PREMIUM_IN_PREMIUM_CURRENCY,
        cast(null as varchar) as AUG_POLICY_PREMIUM_SUMMARY__POLICY_PREMIUM_IN_BASE_CURRENCY,
        cast(null as varchar) as AUG_POLICY_PREMIUM_SUMMARY__POLICY_PREMIUM_IN_TRANSACTION_CURRENCY,
        cast(null as varchar) as AUG_POLICY_PREMIUM_SUMMARY__POLICY_PREMIUM_VALUE,
        cast(null as varchar) as AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_AMOUNT,
        cast(null as varchar) as AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_BEFORE_LOADING_AMOUNT,
        cast(null as varchar) as AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_CALCULATION_BASIS,
        cast(null as varchar) as AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_COLLECTION_AMOUNT,
        cast(null as varchar) as AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_CURRENCY_CODE,
        cast(null as varchar) as AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_CURRENCY_EXCHANGE_RATE,
        cast(null as varchar) as AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_IN_BAHRAINI_DINAR,
        cast(null as varchar) as AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_PAYMENT_MODE,
        cast(null as varchar) as AUG_POLICY_PREMIUM_SUMMARY__THIRD_PARTY_TARIFF_RATE,
        cast(null as varchar) as AUG_POLICY_PREMIUM_SUMMARY__TOTAL_FEES_AMOUNT,
        cast(null as varchar) as AUG_POLICY_PREMIUM_SUMMARY__USER_ENTERED_PREMIUM_AMOUNT,
        cast(null as varchar) as AUG_POLICY_PREMIUM_SUMMARY__USER_OVERRIDDEN_PREMIUM_AMOUNT,
        cast(null as varchar) as AUG_POLICY_PREMIUM_SUMMARY__WRITE_OFF_WAIVER_INDICATOR,
        cast(null as varchar) as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        cast(null as varchar) as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        'OD' as POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
        cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK,
        t0.od_cover_expiry_date as POLICY_COVERAGE_SCHEDULE__COVERAGE_END_DATE,
        cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE,
        t0.od_cover_inception_date as POLICY_COVERAGE_SCHEDULE__COVERAGE_START_DATE,
        cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__COVERAGE_STATUS,
        cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__LIMIT_AMOUNT,
        cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__PREMIUM_FOR_COVERAGE,
        cast(null as varchar) as POLICY_COVERAGE_SCHEDULE__SUM_INSURED,
        cast(null as varchar) as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        cast(null as varchar) as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        cast(null as varchar) as POLICY_DISCOUNT_LOADING_APPLIED__EXTRA_DISCOUNT_OPTED_INDICATOR,
        cast(null as varchar) as POLICY_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED,
        cast(null as varchar) as POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER_CK,
        cast(null as varchar) as POLICY_ENDORSEMENT__EFFECTIVE_DATE,
        cast(null as varchar) as POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER,
        cast(null as varchar) as POLICY_ENDORSEMENT__ENDORSEMENT_REASON,
        cast(null as varchar) as POLICY_ENDORSEMENT__ENDORSEMENT_TYPE,
        cast(null as varchar) as POLICY_ENDORSEMENT__PREMIUM_IMPACT_AMOUNT,
        cast(null as varchar) as POLICY_ENDORSEMENT__SUM_INSURED_IMPACT_AMOUNT,
        cast(null as varchar) as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        cast(null as varchar) as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        cast(null as varchar) as POLICY_PREMIUM_HEAD__SECTION_CK,
        cast(null as varchar) as POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK,
        cast(null as varchar) as POLICY_PREMIUM_HEAD__BASE_AMOUNT,
        cast(null as varchar) as POLICY_PREMIUM_HEAD__DISCOUNT_AMOUNT,
        cast(null as varchar) as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        'PURCHASE_PRICE' as POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_HEAD_CK,
        cast(null as varchar) as POLICY_SUM_INSURED_BREAKUP__HEAD_DESCRIPTION,
        t0.sum_assured_purchase_priceusd as POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_AMOUNT,
        cast(null as varchar) as POLICY_TAX_HEAD__TAX_HEAD_CODE_CK,
        cast(null as varchar) as POLICY_TAX_HEAD__TAX_AMOUNT,
        cast(null as varchar) as POLICY_TAX_HEAD__TAX_HEAD_CODE,
        cast(null as varchar) as POLICY_TAX_HEAD__TAX_RATE,
        cast(null as varchar) as POLICY_TERMS__FREE_LOOK_PERIOD,
        cast(null as varchar) as POLICY_TERMS__GEOGRAPHICAL_SCOPE,
        t0.rec_refresh_at as REC_REFRESH_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_attr_properties_pv') }} t0
    left join {{ ref('stg_mxm__clm_cd_claim_attr_properties') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_attr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policyno),''), '')) is not null

    union all

    -- branch 1: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
    select
        nullif(nullif(trim(j3.policyno),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PA' as POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
        null,
        t0.pa_cover_expiry_date as POLICY_COVERAGE_SCHEDULE__COVERAGE_END_DATE,
        null,
        t0.pa_cover_inception_date as POLICY_COVERAGE_SCHEDULE__COVERAGE_START_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_attr_properties_pv') }} t0
    left join {{ ref('stg_mxm__clm_cd_claim_attr_properties') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_attr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policyno),''), '')) is not null

    union all

    -- branch 2: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
    select
        nullif(nullif(trim(j3.policyno),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'TP' as POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
        null,
        t0.tp_cover_expiry_date as POLICY_COVERAGE_SCHEDULE__COVERAGE_END_DATE,
        null,
        t0.tp_cover_inception_date as POLICY_COVERAGE_SCHEDULE__COVERAGE_START_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_attr_properties_pv') }} t0
    left join {{ ref('stg_mxm__clm_cd_claim_attr_properties') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_attr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policyno),''), '')) is not null

    union all

    -- branch 3: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS
    select
        nullif(nullif(trim(t0.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.policy_intimation_date as AUG_POLICY_HEADER__POLICY_INTIMATION_DATE,
        null, null, null,
        t0.policy_durationunit as AUG_POLICY_HEADER__POLICY_TERM_UNIT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.policy_branch_name as AUG_POLICY_HEADER__SERVICING_BRANCH_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.premium_mode as AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_PAYMENT_MODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd') }} t0
    where (nullif(nullif(trim(t0.policy_number),''), '')) is not null

    union all

    -- branch 4: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_ENDORSEMENT_DETAILS
    select
        nullif(nullif(trim(j1.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null,
        nullif(trim(t0.endorsement_number),'') as AUG_POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER_CK,
        t0.endorsement_approved_date as AUG_POLICY_ENDORSEMENT__ENDORSEMENT_APPROVED_DATE,
        t0.remarks as AUG_POLICY_ENDORSEMENT__ENDORSEMENT_REMARKS,
        t0.endorsement_revised_sum_insured as AUG_POLICY_ENDORSEMENT__REVISED_SUM_INSURED_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        nullif(trim(t0.endorsement_number),'') as POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER_CK,
        t0.endorsement_effective_date as POLICY_ENDORSEMENT__EFFECTIVE_DATE,
        t0.endorsement_number as POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER,
        null,
        t0.typeof_endorsement as POLICY_ENDORSEMENT__ENDORSEMENT_TYPE,
        t0.endorsement_premium as POLICY_ENDORSEMENT__PREMIUM_IMPACT_AMOUNT,
        t0.endorsement_sum_insured as POLICY_ENDORSEMENT__SUM_INSURED_IMPACT_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_endorsement_dtls') }} t0
    left join {{ ref('stg_mxm__uwr_pd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (nullif(nullif(trim(j1.policy_number),''), '')) is not null

    union all

    -- branch 5: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS
    select
        nullif(nullif(trim(j2.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        nullif(trim(t0.cover_code),'') as POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
        null,
        t0.cover_expiry_date as POLICY_COVERAGE_SCHEDULE__COVERAGE_END_DATE,
        null,
        t0.cover_inception_date as POLICY_COVERAGE_SCHEDULE__COVERAGE_START_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NET' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(t0.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.net_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.policy_number),''), '')) is not null

    union all

    -- branch 6: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j7.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        t0.allocation_percentage as AUG_POLICY_PA_NAMED_PERSON__BENEFIT_ALLOCATION_PERCENTAGE,
        null, null,
        t0.name_of_person as AUG_POLICY_PA_NAMED_PERSON__NAMED_PERSON_NAME,
        null,
        t0.nominee_name as AUG_POLICY_PA_NAMED_PERSON__NOMINEE_NAME,
        t0.nominee_relation as AUG_POLICY_PA_NAMED_PERSON__NOMINEE_RELATIONSHIP_TO_INSURED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        'RISK_TOTAL' as POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_HEAD_CK,
        null,
        t0.sum_insured as POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_AMOUNT,
        null, null, null, null, null,
        t0.geographical_extension as POLICY_TERMS__GEOGRAPHICAL_SCOPE,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_msp_msd_prop_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_msp_msd_prop') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_msp_msd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop_msp') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls_cover_prop') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_cover_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j6 on j6.KEY_HASH = j5.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j7 on j7.KEY_HASH = j6.PARENT_KEY_HASH
    where (nullif(nullif(trim(j7.policy_number),''), '')) is not null

    union all

    -- branch 7: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        'PMM_ADJ_FACTOR_FOR_PRD_ELAPSED' as AUG_POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        null, null,
        t0.pmm_adj_factor_for_prd_elapsed as AUG_POLICY_DISCOUNT_LOADING_APPLIED__RATING_FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'FURTHER_DISCOUNT' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        null,
        t0.further_discount_applicable as POLICY_DISCOUNT_LOADING_APPLIED__EXTRA_DISCOUNT_OPTED_INDICATOR,
        t0.further_discount_percentage as POLICY_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED,
        null, null, null, null, null, null, null,
        'EXTENDED_STP_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.extended_stp_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 8: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        'PMM_ADJ_FACTOR_FOR_PRD_REMAIN' as AUG_POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        null, null,
        t0.pmm_adj_factor_for_prd_remain as AUG_POLICY_DISCOUNT_LOADING_APPLIED__RATING_FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'HANDICAPPED_DISCOUNT_Y1' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        t0.handicapped_discount_premium_1st_year as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        null, null, null, null, null, null, null, null, null,
        'FIBRE_GLASS_FUEL_TANK_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.fibre_glass_fuel_tank_premium_1st_yr as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 9: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        'PMM_ADJ_FACTOR_FOR_PRODUCT_REMAIN' as AUG_POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        null, null,
        t0.pmm_adj_factor_for_product_remain as AUG_POLICY_DISCOUNT_LOADING_APPLIED__RATING_FACTOR_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'LOADING' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        null, null,
        t0.loading_percentage as POLICY_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED,
        null, null, null, null, null, null, null,
        'FINAL_COVER_AFTER_FD_B' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.final_cover_premium_after_fd_b as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 10: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        nullif(trim(j3.cover_code),'') as POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
        null,
        t0.cover_expiry_date as POLICY_COVERAGE_SCHEDULE__COVERAGE_END_DATE,
        null,
        t0.cover_inception_date as POLICY_COVERAGE_SCHEDULE__COVERAGE_START_DATE,
        null, null,
        t0.cover_premium_in_transaction_currency as POLICY_COVERAGE_SCHEDULE__PREMIUM_FOR_COVERAGE,
        t0.cover_sum_insured as POLICY_COVERAGE_SCHEDULE__SUM_INSURED,
        null, null, null, null, null, null, null, null, null, null, null,
        'LAID_UP_BALANCE_VEHICLE' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.balance_vehicle_laid_off_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        'RISK_TOTAL' as POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_HEAD_CK,
        null,
        t0.sum_insured as POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_AMOUNT,
        null, null, null, null, null, null,
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
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        'LT_DISCOUNT_Y1' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        t0.lt_discount_1st_year as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        null, null, null, null, null, null, null, null, null,
        'FINAL_COVER_AFTER_FD_B_Y2' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.final_cover_premium_after_fd_b_2nd_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 12: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        'NCB_DISCOUNT' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        null, null,
        t0.ncb_discount_percentage as POLICY_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED,
        null, null, null, null, null, null, null,
        'FINAL_COVER_AFTER_FD_B_Y3' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.final_cover_premium_after_fd_b_3rd_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 13: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        'NCB_DISCOUNT_Y2' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        null, null,
        t0.ncb_discount_percentage_2nd_year as POLICY_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED,
        null, null, null, null, null, null, null,
        'FINAL_COVER_AFTER_FD_B_Y4' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.final_cover_premium_after_fd_b_4th_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 14: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        'NCB_DISCOUNT_Y3' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        null, null,
        t0.ncb_discount_percentage_3rd_year as POLICY_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED,
        null, null, null, null, null, null, null,
        'FINAL_COVER_AFTER_FD_B_Y5' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.final_cover_premium_after_fd_b_5th_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 15: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        'NCB_DISCOUNT_Y4' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        null, null,
        t0.ncb_discount_percentage_4th_year as POLICY_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED,
        null, null, null, null, null, null, null,
        'FINAL_OD_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.final_od_premium_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 16: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        'NCB_DISCOUNT_Y5' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        null, null,
        t0.ncb_discount_percentage_5th_year as POLICY_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED,
        null, null, null, null, null, null, null,
        'FINAL_SUB_TOTAL_1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.final_sub_total_1 as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 17: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        'NO_CLAIM_BONUS_Y1' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        t0.no_claim_bonus_premium_1st_year as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        null, null, null, null, null, null, null, null, null,
        'FINAL_SUB_TOTAL_10' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.final_sub_total_10 as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 18: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        'OEM_LOADING_DISCOUNT' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        t0.oem_loading_discount as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        null, null, null, null, null, null, null, null, null,
        'FINAL_SUB_TOTAL_11' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.final_sub_total_11 as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 19: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        'REV_CD_Y1' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        t0.rev_cd_1st_year as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        null, null, null, null, null, null, null, null, null,
        'FINAL_SUB_TOTAL_12' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.final_sub_total_12 as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 20: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        'SIDE_CAR_DISCOUNT_Y1' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        t0.side_car_discount_1st_year as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        null, null, null, null, null, null, null, null, null,
        'FINAL_SUB_TOTAL_13' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.final_sub_total_13 as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 21: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'BASE_AMOUNT_CURRENT_PMM_SLAB' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null,
        t0.base_amt_on_current_pmm_slab as POLICY_PREMIUM_HEAD__BASE_AMOUNT,
        null, null,
        'TOTAL' as POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_HEAD_CK,
        t0.sum_insured_details as POLICY_SUM_INSURED_BREAKUP__HEAD_DESCRIPTION,
        t0.total_sum_insured as POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_AMOUNT,
        null, null, null, null, null, null,
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
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'COMMERCIAL_USE' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.commercial_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        'PER_PERSON' as POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_HEAD_CK,
        null,
        t0.sum_insured_per_person as POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_AMOUNT,
        null, null, null, null, null, null,
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
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'FINAL_SUB_TOTAL_14' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.final_sub_total_14 as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 24: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'FINAL_SUB_TOTAL_15' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.final_sub_total_15 as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 25: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'FINAL_SUB_TOTAL_1_TP' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.final_sub_total_1_tp as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 26: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'FINAL_SUB_TOTAL_2' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.final_sub_total_2 as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 27: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'FINAL_SUB_TOTAL_3' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.final_sub_total_3 as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 28: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'FINAL_SUB_TOTAL_4' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.final_sub_total_4 as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 29: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'FINAL_SUB_TOTAL_5' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.final_sub_total_5 as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'FINAL_SUB_TOTAL_6' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.final_sub_total_6 as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 31: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'FINAL_SUB_TOTAL_7' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.final_sub_total_7 as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 32: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'FINAL_SUB_TOTAL_8' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.final_sub_total_8 as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 33: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'FINAL_SUB_TOTAL_9' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.final_sub_total_9 as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 34: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'FINAL_OD' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.final_total_od_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 35: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'GEOGRAPHICAL_EXTENSION_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.geog_extn_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 36: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'GEOGRAPHICAL_EXTENSION_Y2' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.geog_extn_2nd_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 37: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'GEOGRAPHICAL_EXTENSION_Y3' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.geog_extn_3rd_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 38: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'GEOGRAPHICAL_EXTENSION_Y4' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.geog_extn_4th_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 39: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'GEOGRAPHICAL_EXTENSION_Y5' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.geog_extn_5th_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 40: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'IMPORTED_VEHICLE_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.imported_vehicle_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 41: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'IMT14_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.imt14_premium_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 42: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'IMT23_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.imt23_premium_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 43: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'IMT34_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.imt34_premium_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 44: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'IMT43_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.imt43_premium_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 45: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'IMT44_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.imt44_premium_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 46: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'IMT45_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.imt45_premium_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 47: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'IMT47_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.imt47_premium_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 48: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'IMT53_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.imt53_premium_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 49: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'INDEMNITY_TO_HIRER_IMT_44_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.indemnity_to_hirer_imt_44_premium_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 50: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'INDEMNITY_TO_HIRER_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.indemnity_to_hirer_premium_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 51: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'INDEMNITY_TO_HIRER_Y2' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.indemnity_to_hirer_premium_2nd_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 52: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'INDEMNITY_TO_HIRER_Y3' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.indemnity_to_hirer_premium_3rd_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 53: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'INDEMNITY_TO_HIRER_Y4' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.indemnity_to_hirer_premium_4th_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 54: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'INDEMNITY_TO_HIRER_Y5' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.indemnity_to_hirer_premium_5th_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 55: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'LL_FOR_EMPLOYEES_OTHER_THAN_DRIVER_AND_CLEANER_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.ll_for_employees_other_than_driver_and_cleaner_premium_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 56: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'LL_FOR_EMPLOYEES_OTHER_THAN_DRIVER_AND_CLEANER_Y2' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.ll_for_employees_other_than_driver_and_cleaner_premium_2nd_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 57: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'LL_FOR_EMPLOYEES_OTHER_THAN_DRIVER_AND_CLEANER_Y3' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.ll_for_employees_other_than_driver_and_cleaner_premium_3rd_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 58: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'LL_FOR_EMPLOYEES_OTHER_THAN_DRIVER_AND_CLEANER_Y4' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.ll_for_employees_other_than_driver_and_cleaner_premium_4th_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 59: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'LL_FOR_EMPLOYEES_OTHER_THAN_DRIVER_AND_CLEANER_Y5' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.ll_for_employees_other_than_driver_and_cleaner_premium_5th_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 60: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'LL_INSURED_CARRYING_VEHICLE_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.ll_insured_carrying_vehicle_premium_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 61: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'LL_OPERATION_MAINTENANCE_ABOVE_6_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.ll_operation_maintenance_above_6_premium_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 62: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'LL_OPERATION_MAINTENANCE_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.ll_operation_maintenance_premium_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 63: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'LL_TO_EMPLOYEE_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.ll_to_employee_premium_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 64: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'LL_TO_EMPLOYEE_Y2' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.ll_to_employee_premium_2nd_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 65: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'LL_TO_EMPLOYEE_Y3' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.ll_to_employee_premium_3rd_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 66: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'LL_TO_EMPLOYEE_Y4' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.ll_to_employee_premium_4th_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 67: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'LL_TO_EMPLOYEE_Y5' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.ll_to_employee_premium_5th_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 68: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'LL_TO_FARE_PAYING_PASSENGER_EMPLOYEES_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.ll_to_fare_paying_passenger_employees_premium_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 69: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'LL_TO_PASSENGER_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.ll_to_passenger_premium_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 70: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'LOSS_OF_ACCESSORIES_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.loss_of_accessories_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 71: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NAMED_PASSENGER_PA_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.named_passenger_pa_premium_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 72: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NAMED_PASSENGER_PA_Y2' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.named_passenger_pa_premium_2nd_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 73: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NAMED_PASSENGER_PA_Y3' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.named_passenger_pa_premium_3rd_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 74: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NAMED_PASSENGER_PA_Y4' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.named_passenger_pa_premium_4th_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 75: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NAMED_PASSENGER_PA_Y5' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.named_passenger_pa_premium_5th_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 76: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NET' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.net_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 77: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NET_WITHOUT_LOADING_DISCOUNT' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.net_premium_without_loading_discount as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 78: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NET_TP' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.net_tp_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 79: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NON_ELECTRICAL_ACCESSORY_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.nonelectrical_accessories_premium_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 80: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NON_FARE_PAYING_EMPLOYEE_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.non_fare_paying_employee_premium_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 81: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NON_FARE_PAYING_PASSENGER_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.non_fare_paying_passenger_premium_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 82: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NORMAL_RALLY_COVER_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.normal_rally_cover_premium_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 83: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NORMAL_RALLY_COVER_Y2' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.normal_rally_cover_premium_2nd_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 84: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NORMAL_RALLY_COVER_Y3' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.normal_rally_cover_premium_3rd_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 85: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NORMAL_RALLY_COVER_Y4' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.normal_rally_cover_premium_4th_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 86: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NORMAL_RALLY_COVER_Y5' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.normal_rally_cover_premium_5th_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 87: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'OD_VEHICLE_LAID_OFF' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.od_vehicle_laid_off_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 88: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PA_FOR_DRIVER_AND_CLEANER_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'PA' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.pa_for_driver_and_cleaner_premium_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 89: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PA_FOR_DRIVER_AND_CLEANER_Y2' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'PA' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.pa_for_driver_and_cleaner_premium_2nd_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 90: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PA_FOR_DRIVER_AND_CLEANER_Y3' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'PA' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.pa_for_driver_and_cleaner_premium_3rd_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 91: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PA_FOR_DRIVER_AND_CLEANER_Y4' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'PA' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.pa_for_driver_and_cleaner_premium_4th_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 92: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PA_FOR_DRIVER_AND_CLEANER_Y5' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'PA' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.pa_for_driver_and_cleaner_premium_5th_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 93: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PA_FOR_PILLION_RIDER_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'PA' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.pa_for_pillion_rider_premium_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 94: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PA_FOR_PILLION_RIDER_Y2' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'PA' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.pa_for_pillion_rider_premium_2nd_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 95: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PA_FOR_PILLION_RIDER_Y3' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'PA' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.pa_for_pillion_rider_premium_3rd_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 96: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PA_FOR_PILLION_RIDER_Y4' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'PA' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.pa_for_pillion_rider_premium_4th_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 97: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PA_FOR_PILLION_RIDER_Y5' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'PA' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.pa_for_pillion_rider_premium_5th_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 98: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PA_TO_UNNAMED_HIRER_AND_PILLION_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'PA' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.pa_to_unnamed_hirer_and_pillion_premium_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 99: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'REVISED_FINAL_SUB_TOTAL_16' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.rev_final_sub_total_16 as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 100: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'REVISED_SUB_TOTAL_14_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.rev_sub_total_14_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 101: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'REVISED_SUB_TOTAL_15_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.rev_sub_total_15_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 102: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'REVISED_SUB_TOTAL_16_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.rev_sub_total_16_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 103: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'REVISED_TOTAL_OD_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.rev_total_od_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 104: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SIDE_CAR_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.side_car_premium_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 105: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SPEED_RALLY_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.speed_rally_premium_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 106: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SPEED_RALLY_Y2' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.speed_rally_premium_2nd_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 107: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SPEED_RALLY_Y3' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.speed_rally_premium_3rd_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 108: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SPEED_RALLY_Y4' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.speed_rally_premium_4th_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 109: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SPEED_RALLY_Y5' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.speed_rally_premium_5th_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 110: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SUB_TOTAL_10_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.sub_total_10_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 111: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SUB_TOTAL_11_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.sub_total_11_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 112: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SUB_TOTAL_12_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.sub_total_12_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 113: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SUB_TOTAL_13_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.sub_total_13_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 114: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SUB_TOTAL_14_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.sub_total_14_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 115: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SUB_TOTAL_15_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.sub_total_15_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 116: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SUB_TOTAL_16_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.sub_total_16_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 117: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SUB_TOTAL_16_Y2' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.sub_total_16_2nd_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 118: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SUB_TOTAL_16_Y3' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.sub_total_16_3rd_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 119: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SUB_TOTAL_16_Y4' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.sub_total_16_4th_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 120: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SUB_TOTAL_16_Y5' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.sub_total_16_5th_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 121: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SUB_TOTAL_1_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.sub_total_1_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 122: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SUB_TOTAL_1_TP_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.sub_total_1_tp_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 123: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SUB_TOTAL_1_TP_Y2' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.sub_total_1_tp_2nd_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 124: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SUB_TOTAL_1_TP_Y3' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.sub_total_1_tp_3rd_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 125: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SUB_TOTAL_1_TP_Y4' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.sub_total_1_tp_4th_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 126: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SUB_TOTAL_1_TP_Y5' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.sub_total_1_tp_5th_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 127: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SUB_TOTAL_2_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.sub_total_2_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 128: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SUB_TOTAL_3_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.sub_total_3_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 129: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SUB_TOTAL_4_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.sub_total_4_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 130: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SUB_TOTAL_5_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.sub_total_5_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 131: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SUB_TOTAL_6_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.sub_total_6_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 132: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SUB_TOTAL_7_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.sub_total_7_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 133: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SUB_TOTAL_8_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.sub_total_8_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 134: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SUB_TOTAL_9_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.sub_total_9_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 135: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ACCIDENTS_TP' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_accidents_tp_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 136: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ANTI_THEFT_DISCOUNT' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.total_antitheft_device_discount_premium as POLICY_PREMIUM_HEAD__DISCOUNT_AMOUNT,
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

    -- branch 137: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ATTACHED_TRAILERS' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_attached_trailers_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 138: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'TRAILER' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_attached_trailer_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 139: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'AUTOMOBILE_ASSOCIATION_MEMBER' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_automobile_association_member_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 140: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'BASIC_OD' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null,
        t0.total_basic_od_premium as POLICY_PREMIUM_HEAD__BASE_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null,
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

    -- branch 141: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'BASIC_TP' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null,
        t0.total_basic_tp_premium as POLICY_PREMIUM_HEAD__BASE_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null,
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

    -- branch 142: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CD_DISCOUNT' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.total_cd_discount as POLICY_PREMIUM_HEAD__DISCOUNT_AMOUNT,
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

    -- branch 143: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CNG_KIT' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_cng_kit_fittings_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 144: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ADDON_COURTESY_CAR' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'ADDON' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_courtesy_car_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 145: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'COMPULSORY_PA' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'PA' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_cpa_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 146: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'DEMONSTRATION_EXTENSION' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_demonstration_extension_cover_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 147: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'DEMO_CAR_APPORTION' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_demo_car_apportion as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 148: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'DRIVING_TUITION_APPORTION' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_driving_tuition_apportion as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 149: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'DRIVING_TUITION' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_driving_tuition_extension_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 150: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EARNED_TOTAL' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.total_earned_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 151: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EARNED_TOTAL_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.total_earned_premium_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 152: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EARNED_ANTI_THEFT_DISCOUNT' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.total_earned_premium_antitheft_device_discount as POLICY_PREMIUM_HEAD__DISCOUNT_AMOUNT,
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

    -- branch 153: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EARNED_TRAILER' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_earned_premium_attached_trailer as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 154: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EARNED_AUTOMOBILE_ASSOCIATION_MEMBER' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_earned_premium_automobile_association_member as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 155: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EARNED_BASIC_OD' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null,
        t0.total_earned_premium_basic_od as POLICY_PREMIUM_HEAD__BASE_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null,
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

    -- branch 156: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EARNED_CD_DISCOUNT' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.total_earned_premium_cd as POLICY_PREMIUM_HEAD__DISCOUNT_AMOUNT,
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

    -- branch 157: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EARNED_CNG_KIT' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_earned_premium_cng_kit as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 158: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EARNED_ADDON_COURTESY_CAR' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'ADDON' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_earned_premium_courtesy_car as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 159: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EARNED_DEMONSTRATION_EXTENSION' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_earned_premium_demo_extn_cover as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 160: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EARNED_DRIVING_TUITION' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_earned_premium_driving_tuition as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 161: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EARNED_ELECTRICAL_ACCESSORY' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_earned_premium_electrical_accessories as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 162: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EARNED_EXTENDED_STP' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_earned_premium_extended_stp as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 163: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EARNED_FIBRE_GLASS_FUEL_TANK' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_earned_premium_fibre_glass_fuel_tank as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 164: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EARNED_GEOGRAPHICAL_EXTENSION' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_earned_premium_geog_extension as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 165: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EARNED_HANDICAPPED_DISCOUNT' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.total_earned_premium_handicapped_discount as POLICY_PREMIUM_HEAD__DISCOUNT_AMOUNT,
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

    -- branch 166: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EARNED_IMPORTED_VEHICLE' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_earned_premium_imported_vehicle as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 167: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EARNED_IMT14' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_earned_premium_imt14 as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 168: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EARNED_IMT23' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_earned_premium_imt23 as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 169: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EARNED_IMT34' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_earned_premium_imt34 as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 170: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EARNED_IMT43' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_earned_premium_imt43 as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 171: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EARNED_IMT44' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_earned_premium_imt44 as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 172: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EARNED_IMT45' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_earned_premium_imt45 as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 173: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EARNED_IMT47' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_earned_premium_imt47 as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 174: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EARNED_IMT53' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_earned_premium_imt53 as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 175: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EARNED_LOSS_OF_ACCESSORIES' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_earned_premium_loss_of_accessories as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 176: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EARNED_LONG_TERM_DISCOUNT' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.total_earned_premium_ltd as POLICY_PREMIUM_HEAD__DISCOUNT_AMOUNT,
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

    -- branch 177: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EARNED_NO_CLAIM_BONUS' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.total_earned_premium_ncb as POLICY_PREMIUM_HEAD__DISCOUNT_AMOUNT,
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

    -- branch 178: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EARNED_NON_ELECTRICAL_ACCESSORY' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_earned_premium_nonelectrical_accessories as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 179: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EARNED_NORMAL_RALLY' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_earned_premium_normal_rally as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 180: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EARNED_SIDE_CAR' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_earned_premium_side_car as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 181: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EARNED_SIDE_CAR_DISCOUNT' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.total_earned_premium_side_car_discount as POLICY_PREMIUM_HEAD__DISCOUNT_AMOUNT,
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

    -- branch 182: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EARNED_SPEED_RALLY' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_earned_premium_speed_rally as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 183: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EARNED_SUB_TOTAL_16' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.total_earned_premium_sub_total_16 as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 184: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EARNED_USE_WITHIN_OWN_PREMISES' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_earned_premium_use_within_own_premises as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 185: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EARNED_VOLUNTARY_DEDUCTIBLE' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.total_earned_premium_voluntary_deductible as POLICY_PREMIUM_HEAD__DISCOUNT_AMOUNT,
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

    -- branch 186: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ELECTRICAL_ACCESSORY' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_electrical_accessories_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 187: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EXTENDED_STP' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_extended_stp as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 188: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'FIBRE_GLASS_FUEL_TANK' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_fibre_glass_fuel_tank_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 189: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'GEOGRAPHICAL_EXTENSION' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_geographical_extension_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 190: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'HANDICAPPED_DISCOUNT' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.total_handicapped_discount_premium as POLICY_PREMIUM_HEAD__DISCOUNT_AMOUNT,
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

    -- branch 191: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'IMPORTED_VEHICLE_WITHOUT_CUSTOMS_DUTY' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_imported_vehicle_without_customs_duty_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 192: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'IMT14' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_imt14_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 193: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'IMT23' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_imt23_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 194: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'IMT34' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_imt34_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 195: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'IMT43' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_imt43_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 196: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'IMT45' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_imt45_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 197: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'IMT47' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_imt47_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 198: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'IMT53' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_imt53_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 199: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'IMT44' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_indemnity_to_hirer_imt_44_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 200: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'INDEMNITY_TO_HIRER' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_indemnity_to_hirer_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 201: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'LL_OTHER_EMPLOYEE' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_ll_for_employees_other_than_driver_and_cleaner_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 202: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'LL_INSURED_CARRYING_VEHICLE' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_ll_insured_carrying_vehicle_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 203: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'LL_OPERATION_MAINTENANCE_ABOVE_6' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_ll_operation_maintenance_above_6_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 204: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'LL_OPERATION_MAINTENANCE' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_ll_operation_maintenance_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 205: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'LL_EMPLOYEE' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_ll_to_employee_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 206: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'LL_FARE_PAYING_PASSENGER_EMPLOYEE' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_ll_to_fare_paying_passenger_employees_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 207: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'LL_PASSENGER' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_ll_to_passenger_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 208: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'LOB_COMM' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.total_lob_comm_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 209: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'LOB_COMM_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.total_lob_comm_premium_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 210: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'LOSS_OF_ACCESSORIES' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_loss_of_accessories_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 211: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'LONG_TERM_DISCOUNT' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.total_lt_discount as POLICY_PREMIUM_HEAD__DISCOUNT_AMOUNT,
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

    -- branch 212: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PA_NAMED_PASSENGER' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'PA' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_named_passenger_pa_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 213: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NON_ELECTRICAL_ACCESSORY' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_nonelectrical_accessories_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 214: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'LL_NON_FARE_PAYING_EMPLOYEE' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_non_fare_paying_employee_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 215: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'LL_NON_FARE_PAYING_PASSENGER' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_non_fare_paying_passenger_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 216: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NORMAL_RALLY' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_normal_rally_cover_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 217: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NO_CLAIM_BONUS' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.total_no_claim_bonus_premium as POLICY_PREMIUM_HEAD__DISCOUNT_AMOUNT,
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

    -- branch 218: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NET_OD' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_od_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 219: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NET_OD_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_od_premium_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 220: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PA_DRIVER_AND_CLEANER' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'PA' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_pa_for_driver_and_cleaner_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 221: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PA_PILLION_RIDER' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'PA' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_pa_for_pillion_rider_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 222: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PA_UNNAMED_HIRER_AND_PILLION' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'PA' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_pa_to_unnamed_hirer_and_pillion_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 223: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SIDE_CAR_DISCOUNT' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.total_side_car_discount_premium as POLICY_PREMIUM_HEAD__DISCOUNT_AMOUNT,
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

    -- branch 224: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SIDE_CAR' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_side_car_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 225: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SPEED_RALLY' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_speed_rally_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 226: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SUB_TOTAL_16' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.total_sub_total_16 as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 227: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'TPPD_RESTRICTION' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_tppd_restriction_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 228: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'TOTAL_TP' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_tp_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 229: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NET_TP_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_tp_premium_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 230: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NET_TP_Y2' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_tp_premium_2nd_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 231: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NET_TP_Y3' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_tp_premium_3rd_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 232: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NET_TP_Y4' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_tp_premium_4th_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 233: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NET_TP_Y5' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_tp_premium_5th_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 234: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PA_UNNAMED_PASSENGER' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'PA' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_unnamed_passenger_pa_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 235: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'USE_OF_COMMERCIAL_VEHICLE' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_use_of_commercial_vehicle_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 236: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'USE_WITHIN_OWN_PREMISES' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.total_use_within_own_premises_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 237: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'VINTAGE_CAR_DISCOUNT' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.total_vintage_car_discount_premium as POLICY_PREMIUM_HEAD__DISCOUNT_AMOUNT,
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

    -- branch 238: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'VOLUNTARY_DEDUCTIBLE' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.total_voluntary_deductible_premium as POLICY_PREMIUM_HEAD__DISCOUNT_AMOUNT,
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

    -- branch 239: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'TPPD_RESTRICTION_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.tppd_restriction_premium_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 240: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'TPPD_RESTRICTION_Y2' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.tppd_restriction_premium_2nd_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 241: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'TPPD_RESTRICTION_Y3' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.tppd_restriction_premium_3rd_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 242: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'TPPD_RESTRICTION_Y4' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.tppd_restriction_premium_4th_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 243: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'TPPD_RESTRICTION_Y5' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.tppd_restriction_premium_5th_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 244: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'TP_VEHICLE_LAID_OFF' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.tp_vehicle_laid_off_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 245: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PA_UNNAMED_PASSENGER_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'PA' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.unnamed_passenger_pa_premium_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 246: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PA_UNNAMED_PASSENGER_Y2' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'PA' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.unnamed_passenger_pa_premium_2nd_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 247: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PA_UNNAMED_PASSENGER_Y3' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'PA' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.unnamed_passenger_pa_premium_3rd_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 248: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PA_UNNAMED_PASSENGER_Y4' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'PA' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.unnamed_passenger_pa_premium_4th_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 249: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PA_UNNAMED_PASSENGER_Y5' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'PA' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.unnamed_passenger_pa_premium_5th_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 250: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'USE_OF_COMMERCIAL_VEHICLE_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.use_of_commercial_vehicle_premium_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 251: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'USE_OF_COMMERCIAL_VEHICLE_Y2' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.use_of_commercial_vehicle_premium_2nd_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 252: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'USE_OF_COMMERCIAL_VEHICLE_Y3' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.use_of_commercial_vehicle_premium_3rd_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 253: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'USE_OF_COMMERCIAL_VEHICLE_Y4' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.use_of_commercial_vehicle_premium_4th_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 254: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'USE_OF_COMMERCIAL_VEHICLE_Y5' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.use_of_commercial_vehicle_premium_5th_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 255: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'USE_WITHIN_OWN_PREMISES_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.use_within_own_premises_1st_year as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
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

    -- branch 256: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'VINTAGE_CAR_DISCOUNT_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.vintage_car_discount_premium_1st_year as POLICY_PREMIUM_HEAD__DISCOUNT_AMOUNT,
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

    -- branch 257: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'VINTAGE_CAR_DISCOUNT_Y2' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.vintage_car_discount_premium_2nd_year as POLICY_PREMIUM_HEAD__DISCOUNT_AMOUNT,
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

    -- branch 258: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'VINTAGE_CAR_DISCOUNT_Y3' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.vintage_car_discount_premium_3rd_year as POLICY_PREMIUM_HEAD__DISCOUNT_AMOUNT,
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

    -- branch 259: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'VINTAGE_CAR_DISCOUNT_Y4' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.vintage_car_discount_premium_4th_year as POLICY_PREMIUM_HEAD__DISCOUNT_AMOUNT,
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

    -- branch 260: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'VINTAGE_CAR_DISCOUNT_Y5' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.vintage_car_discount_premium_5th_year as POLICY_PREMIUM_HEAD__DISCOUNT_AMOUNT,
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

    -- branch 261: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'VOLUNTARY_DEDUCTIBLE_Y1' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.voluntary_deductible_premium_1st_year as POLICY_PREMIUM_HEAD__DISCOUNT_AMOUNT,
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

    -- branch 262: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'VOLUNTARY_DEDUCTIBLE_Y2' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.voluntary_deductible_premium_2nd_year as POLICY_PREMIUM_HEAD__DISCOUNT_AMOUNT,
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

    -- branch 263: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'VOLUNTARY_DEDUCTIBLE_Y3' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.voluntary_deductible_premium_3rd_year as POLICY_PREMIUM_HEAD__DISCOUNT_AMOUNT,
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

    -- branch 264: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'VOLUNTARY_DEDUCTIBLE_Y4' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.voluntary_deductible_premium_4th_year as POLICY_PREMIUM_HEAD__DISCOUNT_AMOUNT,
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

    -- branch 265: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_COVER_DETAILS_COVER_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'VOLUNTARY_DEDUCTIBLE_Y5' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(j3.cover_code), '') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null,
        t0.voluntary_deductible_premium_5th_year as POLICY_PREMIUM_HEAD__DISCOUNT_AMOUNT,
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

    -- branch 266: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(coalesce(nullif(trim(t0.policyquote_number),''), nullif(trim(j4.policy_number),'')), '') as POLICY_BK,
        null, null,
        coalesce(t0.further_discount_applicable, t0.is_consumer_loading_applicable) as AUG_POLICY_DISCOUNT_LOADING_APPLIED__ITEM_APPLIED_INDICATOR,
        null, null, null, null, null, null,
        t0.more_info_details as AUG_POLICY_HEADER__ADDITIONAL_REMARKS,
        null, null, null,
        t0.policy_level_base_currency as AUG_POLICY_HEADER__BASE_CURRENCY_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.plan_category as AUG_POLICY_HEADER__PLAN_CATEGORY,
        t0.policy_plan_insured_category as AUG_POLICY_HEADER__PLAN_INSURED_CATEGORY,
        t0.policy_plan as AUG_POLICY_HEADER__PLAN_REFERENCE,
        null, null, null, null, null, null, null, null,
        t0.premium_currency as AUG_POLICY_HEADER__PREMIUM_CURRENCY_CODE,
        t0.premium_currency_exchange_rate as AUG_POLICY_HEADER__PREMIUM_CURRENCY_EXCHANGE_RATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.policy_level_transaction_currency_for_sum_insured as AUG_POLICY_HEADER__SUM_INSURED_CURRENCY_CODE,
        null,
        t0.policy_sum_insured_in_base_currency as AUG_POLICY_HEADER__SUM_INSURED_TOTAL_IN_BASE_CURRENCY,
        t0.policy_sum_insured_in_transaction_currency as AUG_POLICY_HEADER__SUM_INSURED_TOTAL_IN_TRANSACTION_CURRENCY,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        t0.policy_premium_in_base_currency as AUG_POLICY_PREMIUM_SUMMARY__POLICY_PREMIUM_IN_BASE_CURRENCY,
        t0.policy_premium_in_transaction_currency as AUG_POLICY_PREMIUM_SUMMARY__POLICY_PREMIUM_IN_TRANSACTION_CURRENCY,
        null, null, null,
        t0.mode_of_premium_calculation as AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_CALCULATION_BASIS,
        null, null, null,
        t0.premium_in_bhd as AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_IN_BAHRAINI_DINAR,
        null, null, null, null, null, null, null, null,
        nullif(trim(t0.cover_code),'') as POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
        null, null, null,
        t0.inception_date as POLICY_COVERAGE_SCHEDULE__COVERAGE_START_DATE,
        null, null, null, null,
        'FURTHER_DISCOUNT' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        null, null,
        t0.further_discount_percentage as POLICY_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED,
        null, null, null, null, null, null, null,
        'PREMIUM' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(t0.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null,
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

    -- branch 267: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j4.policy_number),''), '') as POLICY_BK,
        'EMPLOYEE_DISCOUNT' as AUG_POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        t0.relation_with_employee as AUG_POLICY_DISCOUNT_LOADING_APPLIED__EMPLOYEE_RELATIONSHIP_TO_INSURED,
        null, null, null, null, null, null, null, null,
        t0.entry_date as AUG_POLICY_HEADER__APPLICATION_SUBMISSION_DATE,
        t0.entry_time as AUG_POLICY_HEADER__APPLICATION_SUBMISSION_TIME,
        null, null, null, null, null, null, null, null, null, null,
        t0.financial_year as AUG_POLICY_HEADER__FINANCIAL_YEAR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.forex_rate_at_policy_level as AUG_POLICY_PREMIUM_SUMMARY__EXCHANGE_RATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'BANCA_POLICY' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        t0.banca_policy as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        nullif(trim(t0.cover_code),'') as POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
        null,
        t0.cover_end_date as POLICY_COVERAGE_SCHEDULE__COVERAGE_END_DATE,
        null,
        t0.cover_start_date as POLICY_COVERAGE_SCHEDULE__COVERAGE_START_DATE,
        t0.cover_status as POLICY_COVERAGE_SCHEDULE__COVERAGE_STATUS,
        null, null,
        t0.cover_sum_insured_in_transaction_currency as POLICY_COVERAGE_SCHEDULE__SUM_INSURED,
        'ADMIN_FEE' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        t0.admin_fee_details as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        null, null,
        nullif(trim(t0.endorsement_no),'') as POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER_CK,
        null,
        t0.endorsement_no as POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER,
        null, null,
        t0.endorsement_premium as POLICY_ENDORSEMENT__PREMIUM_IMPACT_AMOUNT,
        null,
        'COVER_PREMIUM_TRANSACTION_CURRENCY' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(t0.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.cover_premium_in_transaction_currency as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null,
        t0.free_cancellation_period as POLICY_TERMS__FREE_LOOK_PERIOD,
        null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_number),''), '')) is not null

    union all

    -- branch 268: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j4.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.transaction_event as AUG_POLICY_HEADER__POLICY_TRANSACTION_TYPE,
        null, null, null, null, null, null, null, null, null, null,
        t0.reins_pending_indicator as AUG_POLICY_HEADER__REINSURANCE_PLACEMENT_PENDING_INDICATOR,
        t0.risk_level_base_currency as AUG_POLICY_HEADER__RISK_LEVEL_BASE_CURRENCY_CODE,
        t0.risk_level_transaction_currency_for_sum_insured as AUG_POLICY_HEADER__RISK_LEVEL_SUM_INSURED_TRANSACTION_CURRENCY_CODE,
        t0.risk_level_transaction_currency as AUG_POLICY_HEADER__RISK_LEVEL_TRANSACTION_CURRENCY_CODE,
        null, null, null, null, null, null, null, null,
        t0.sum_insured_currency as AUG_POLICY_HEADER__SUM_INSURED_CURRENCY_CODE,
        t0.sum_insured_currency_exchange_rate as AUG_POLICY_HEADER__SUM_INSURED_CURRENCY_EXCHANGE_RATE,
        null, null, null,
        t0.transaction_currency as AUG_POLICY_HEADER__TRANSACTION_CURRENCY_CODE,
        null, null,
        t0.uw_explanatory_notes as AUG_POLICY_HEADER__UNDERWRITING_REMARKS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.tp_premium_rate as AUG_POLICY_PREMIUM_SUMMARY__THIRD_PARTY_TARIFF_RATE,
        t0.total_fees as AUG_POLICY_PREMIUM_SUMMARY__TOTAL_FEES_AMOUNT,
        null,
        t0.user_premium as AUG_POLICY_PREMIUM_SUMMARY__USER_OVERRIDDEN_PREMIUM_AMOUNT,
        null,
        'SUB1' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        t0.sub1 as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        null, null, null, null, null, null, null, null, null,
        'RENEWAL_CASH_DISCOUNT' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        t0.renewal_cd_amount as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        null,
        t0.renewal_cd_ as POLICY_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED,
        null, null, null, null, null, null, null,
        'RISK_IN_BASE_CURRENCY' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(t0.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.risk_premium_in_base_currency as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        'BASE_CURRENCY' as POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_HEAD_CK,
        null,
        t0.risk_sum_insured_in_base_currency as POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_AMOUNT,
        nullif(trim(t0.tax_type),'') as POLICY_TAX_HEAD__TAX_HEAD_CODE_CK,
        t0.tax_amount as POLICY_TAX_HEAD__TAX_AMOUNT,
        t0.tax_type as POLICY_TAX_HEAD__TAX_HEAD_CODE,
        t0.tax_rate as POLICY_TAX_HEAD__TAX_RATE,
        null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_number), ''), '')) is not null

    union all

    -- branch 269: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j4.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'BUSINESS_TYPE' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        t0.business_type as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        null, null, null, null, null, null, null, null, null,
        'AUTO_ADJUSTED' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        t0.auto_adjusted_amount as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        null, null, null, null, null, null, null, null, null,
        'CUMULATIVE_MINIMUM' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(t0.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.cumulative_minimum_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_number),''), '')) is not null

    union all

    -- branch 270: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j4.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SYSTEM_CD1' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        t0.system_cd1 as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        null, null, null, null, null, null, null, null, null,
        'RENEWAL_LOADING' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        t0.renewal_loading_amount as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        null,
        t0.renewal_loading_ as POLICY_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED,
        null, null, null, null, null, null, null,
        'RISK_IN_TRANSACTION_CURRENCY' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(t0.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.risk_premium_in_transaction_currency as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        'TRANSACTION_CURRENCY' as POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_HEAD_CK,
        null,
        t0.risk_sum_insured_in_transaction_currency as POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_AMOUNT,
        null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_number), ''), '')) is not null

    union all

    -- branch 271: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j4.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SYSTEM_CD2' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        t0.system_cd2 as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        null, null, null, null, null, null, null, null, null,
        'UNDERWRITER_APPROVED_CASH_DISCOUNT' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        null, null,
        t0.uw_approved_cd as POLICY_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED,
        null, null, null, null, null, null, null,
        'WRITTEN_OD' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(t0.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.written_od as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        'TOTAL' as POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_HEAD_CK,
        null,
        t0.sum_insured as POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_AMOUNT,
        null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_number), ''), '')) is not null

    union all

    -- branch 272: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j4.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SYSTEM_CD3' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        t0.system_cd3 as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'WRITTEN_TP' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(t0.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.written_tp as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        'SUM_INSURED_DETAILS' as POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_HEAD_CK,
        t0.sum_insured_details as POLICY_SUM_INSURED_BREAKUP__HEAD_DESCRIPTION,
        null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_number), ''), '')) is not null

    union all

    -- branch 273: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j4.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SYSTEM_CD4' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        t0.system_cd4 as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        'SI_CURRENCY' as POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_HEAD_CK,
        null,
        t0.sum_insured_in_si_currency as POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_AMOUNT,
        null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_number), ''), '')) is not null

    union all

    -- branch 274: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j4.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SYSTEM_CD5' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        t0.system_cd5 as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_number), ''), '')) is not null

    union all

    -- branch 275: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j4.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'USER_CD' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        t0.user_cd as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_number), ''), '')) is not null

    union all

    -- branch 276: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j4.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        'AVG_CD' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        t0.avg_cd as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        null, null, null, null, null, null, null, null, null,
        'EARNED_BASIC_OD' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(t0.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.earned_od_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_number),''), '')) is not null

    union all

    -- branch 277: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j4.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        'CLU_DISCOUNT' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        t0.clu_discount as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        null, null, null, null, null, null, null, null, null,
        'EARNED_TOTAL' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(t0.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        null, null, null, null,
        t0.earned_policy as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_number),''), '')) is not null

    union all

    -- branch 278: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j4.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        'CROSS_SELL_DISCOUNT' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        t0.cross_sell_discount as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        null, null, null, null, null, null, null, null, null,
        'EARNED_BASIC_TP' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        nullif(trim(t0.cover_code),'') as POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
        'TP' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.earned_tp_premium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_number),''), '')) is not null

    union all

    -- branch 279: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j4.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        'CSD' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        t0.csd as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_number),''), '')) is not null

    union all

    -- branch 280: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j4.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        'DISCOUNT_IN' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        t0.discount_in_premium as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_number),''), '')) is not null

    union all

    -- branch 281: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j4.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        'DISCOUNT' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        null, null,
        t0.discount_percentage as POLICY_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_number),''), '')) is not null

    union all

    -- branch 282: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j4.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        'EMPLOYEE_DISCOUNT' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        null,
        t0.employee_discount_applicable as POLICY_DISCOUNT_LOADING_APPLIED__EXTRA_DISCOUNT_OPTED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_number),''), '')) is not null

    union all

    -- branch 283: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j4.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        'EMPLOYEE_OR_VIP_DISCOUNT' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        null,
        t0.employee_or_vip_flag_discount_applicable as POLICY_DISCOUNT_LOADING_APPLIED__EXTRA_DISCOUNT_OPTED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_number),''), '')) is not null

    union all

    -- branch 284: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(coalesce(nullif(trim(t0.policyquote_number),''), nullif(trim(j4.policy_number),'')), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        'LOADING_AMOUNT_FOR_OD' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        t0.loading_amount_for_od as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
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

    -- branch 285: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(coalesce(nullif(trim(t0.policyquote_number),''), nullif(trim(j4.policy_number),'')), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        'LOADING_AMOUNT_FOR_TP' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        t0.loading_amount_for_tp as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
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

    -- branch 286: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(coalesce(nullif(trim(t0.policyquote_number),''), nullif(trim(j4.policy_number),'')), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        'LOADING' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        null, null,
        t0.loading_percentage as POLICY_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
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

    -- branch 287: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(coalesce(nullif(trim(t0.policyquote_number),''), nullif(trim(j4.policy_number),'')), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        'PERCENTAGE_DISCOUNT_' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        null, null,
        t0.percentage_discount_ as POLICY_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
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

    -- branch 288: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.package_id as AUG_POLICY_HEADER__COVER_PACKAGE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.cover_list as AUG_POLICY_HEADER__SELECTED_COVER_CODE_LIST,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.age as AUG_POLICY_PA_NAMED_PERSON__NAMED_PERSON_AGE,
        t0.gender as AUG_POLICY_PA_NAMED_PERSON__NAMED_PERSON_GENDER,
        t0.name_of_person as AUG_POLICY_PA_NAMED_PERSON__NAMED_PERSON_NAME,
        t0.relationship as AUG_POLICY_PA_NAMED_PERSON__NAMED_PERSON_RELATIONSHIP,
        null, null, null, null,
        t0.admin_fee as AUG_POLICY_PREMIUM_SUMMARY__ADMINISTRATIVE_FEE_AMOUNT,
        t0.waived as AUG_POLICY_PREMIUM_SUMMARY__ADMINISTRATIVE_FEE_WAIVED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.endorsement_type as POLICY_ENDORSEMENT__ENDORSEMENT_TYPE,
        null, null, null, null, null, null, null, null, null,
        'TOTAL' as POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_HEAD_CK,
        null,
        t0.sum_insured as POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_AMOUNT,
        'CGST' as POLICY_TAX_HEAD__TAX_HEAD_CODE_CK,
        t0.cgst_amount as POLICY_TAX_HEAD__TAX_AMOUNT,
        null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_policy_prop_msp_msd_prop_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_policy_prop_msp_msd_prop') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_policy_prop_msp_msd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_policy_prop_msp') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_policy_prop') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_number),''), '')) is not null

    union all

    -- branch 289: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        'IGST' as POLICY_TAX_HEAD__TAX_HEAD_CODE_CK,
        t0.igst_amount as POLICY_TAX_HEAD__TAX_AMOUNT,
        null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_policy_prop_msp_msd_prop_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_policy_prop_msp_msd_prop') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_policy_prop_msp_msd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_policy_prop_msp') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_policy_prop') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_number),''), '')) is not null

    union all

    -- branch 290: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        'SGST' as POLICY_TAX_HEAD__TAX_HEAD_CODE_CK,
        t0.sgst_amount as POLICY_TAX_HEAD__TAX_AMOUNT,
        null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_policy_prop_msp_msd_prop_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_policy_prop_msp_msd_prop') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_policy_prop_msp_msd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_policy_prop_msp') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_policy_prop') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_number),''), '')) is not null

    union all

    -- branch 291: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j5.policy_number),''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        'UTGST' as POLICY_TAX_HEAD__TAX_HEAD_CODE_CK,
        t0.utgst_amount as POLICY_TAX_HEAD__TAX_AMOUNT,
        null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_policy_prop_msp_msd_prop_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_policy_prop_msp_msd_prop') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_policy_prop_msp_msd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_policy_prop_msp') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_policy_prop') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (nullif(nullif(trim(j5.policy_number),''), '')) is not null

    union all

    -- branch 292: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j3.policy_number), ''), '') as POLICY_BK,
        null, null,
        coalesce(t0.employee_discount_applicable, t0.employee_or_vip_flag_discount_applicable) as AUG_POLICY_DISCOUNT_LOADING_APPLIED__ITEM_APPLIED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.cor_flag as AUG_POLICY_HEADER__COR_INDICATOR,
        null, null,
        t0.endorsement_applicable as AUG_POLICY_HEADER__ENDORSEMENT_APPLICABLE_INDICATOR,
        null, null,
        t0.first_time_executed as AUG_POLICY_HEADER__FIRST_EXECUTION_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        t0.fla_error_desc as AUG_POLICY_HEADER__VALIDATION_ERROR_DESCRIPTION,
        null, null, null, null, null, null, null, null, null,
        t0.admin_charges as AUG_POLICY_PREMIUM_SUMMARY__ADMINISTRATION_CHARGE_AMOUNT,
        t0.admin_fee_details as AUG_POLICY_PREMIUM_SUMMARY__ADMINISTRATION_FEE_DESCRIPTION,
        null, null,
        t0.bank_charges as AUG_POLICY_PREMIUM_SUMMARY__BANK_CHARGE_AMOUNT,
        null, null,
        t0.fixedcdflag as AUG_POLICY_PREMIUM_SUMMARY__FIXED_CASH_DEPOSIT_SETTLEMENT_INDICATOR,
        null, null, null,
        t0.cumulative_minimum_premium as AUG_POLICY_PREMIUM_SUMMARY__MINIMUM_GROSS_PREMIUM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'BUCKET_DESCRIPTION' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        t0.bucket_description as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        nullif(trim(t0.cover_name),'') as POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
        null, null,
        t0.coverage as POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE,
        null, null, null, null, null,
        'CLU_DISCOUNT' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        t0.clu_discount as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        null, null, null, null, null, null, null,
        t0.endorsement_premium as POLICY_ENDORSEMENT__PREMIUM_IMPACT_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_policy_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_policy_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_number), ''), '')) is not null

    union all

    -- branch 293: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(coalesce(nullif(trim(t0.policy_number), ''), nullif(trim(j3.policy_number), '')), '') as POLICY_BK,
        null,
        t0.relation_with_employee as AUG_POLICY_DISCOUNT_LOADING_APPLIED__EMPLOYEE_RELATIONSHIP_TO_INSURED,
        null, null, null, null, null, null, null,
        t0.remarks as AUG_POLICY_HEADER__ADDITIONAL_REMARKS,
        null, null, null, null,
        t0.type_of_business as AUG_POLICY_HEADER__BUSINESS_TYPE,
        t0.show_child_detail_type as AUG_POLICY_HEADER__CHILD_DETAIL_TYPE_SELECTED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.scip_number as AUG_POLICY_HEADER__SCIP_SCHEME_REFERENCE_NUMBER,
        t0.scrutiny_status as AUG_POLICY_HEADER__SCRUTINY_STATUS,
        null, null, null,
        t0.scpa_policy_no as AUG_POLICY_HEADER__STANDALONE_CPA_POLICY_NUMBER,
        t0.stp_reason as AUG_POLICY_HEADER__STRAIGHT_THROUGH_PROCESSING_REASON,
        null, null, null, null, null,
        t0.tagged_policy_number as AUG_POLICY_HEADER__TAGGED_POLICY_REFERENCE,
        t0.transaction_currency as AUG_POLICY_HEADER__TRANSACTION_CURRENCY_CODE,
        t0.serial_no as AUG_POLICY_HEADER__TRANSACTION_LINE_SERIAL_NUMBER,
        t0.reference_detail as AUG_POLICY_HEADER__TRANSACTION_REFERENCE_DETAIL,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.refund_amount_manual as AUG_POLICY_PREMIUM_SUMMARY__MANUAL_REFUND_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.total_fees as AUG_POLICY_PREMIUM_SUMMARY__TOTAL_FEES_AMOUNT,
        t0.user_premium as AUG_POLICY_PREMIUM_SUMMARY__USER_ENTERED_PREMIUM_AMOUNT,
        null,
        t0.writeoff_waiver_flag as AUG_POLICY_PREMIUM_SUMMARY__WRITE_OFF_WAIVER_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null,
        coalesce(t0.renewal_cd_amount, t0.renewal_loading_amount, t0.total_stp_discount) as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        null,
        coalesce(t0.renewal_cd_, t0.renewal_loading_, t0.rid_applicability_factor, t0.system_cd1, t0.system_cd2, t0.system_cd3, t0.system_cd4, t0.system_cd5, t0.user_cd, t0.uw_approved_cd) as POLICY_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED,
        null, null, null,
        t0.reason_for_initiating_this_action as POLICY_ENDORSEMENT__ENDORSEMENT_REASON,
        t0.type_of_endorsement as POLICY_ENDORSEMENT__ENDORSEMENT_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        coalesce(t0.sgst_amount, t0.utgst_amount) as POLICY_TAX_HEAD__TAX_AMOUNT,
        null,
        coalesce(t0.sgst_percentage, t0.ugst_percentage) as POLICY_TAX_HEAD__TAX_RATE,
        null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_policy_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_policy_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(coalesce(nullif(trim(t0.policy_number), ''), nullif(trim(j3.policy_number), '')), '')) is not null

    union all

    -- branch 294: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j3.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null,
        t0.reason as AUG_POLICY_HEADER__ADDITIONAL_REMARKS,
        null, null,
        t0.policy_risk_cover_list as AUG_POLICY_HEADER__ATTACHED_COVER_CODE_LIST,
        t0.policy_level_base_currency as AUG_POLICY_HEADER__BASE_CURRENCY_CODE,
        null, null,
        t0.intimation_id_number as AUG_POLICY_HEADER__CLAIM_INTIMATION_REFERENCE,
        null, null, null, null,
        t0.mode_of_expense_payment as AUG_POLICY_HEADER__EXPENSE_PAYMENT_MODE,
        null, null,
        t0.insurer_name as AUG_POLICY_HEADER__INSURER_NAME,
        t0.lms_no as AUG_POLICY_HEADER__LEAD_REFERENCE,
        t0.lg_code as AUG_POLICY_HEADER__LG_CODE,
        t0.linked_plan as AUG_POLICY_HEADER__LINKED_PLAN_REFERENCE,
        t0.notified_by as AUG_POLICY_HEADER__LOSS_INTIMATED_BY_ROLE,
        t0.mandatory_questionnaire as AUG_POLICY_HEADER__MANDATORY_QUESTIONNAIRE_INDICATOR,
        t0.master_quote as AUG_POLICY_HEADER__MASTER_QUOTE_REFERENCE,
        t0.ntu_indicator as AUG_POLICY_HEADER__NOT_TAKEN_UP_INDICATOR,
        t0.ods_required_for as AUG_POLICY_HEADER__ODS_REQUIRED_FOR,
        t0.oem_policy_number_or_cover_note_number as AUG_POLICY_HEADER__OEM_POLICY_REFERENCE,
        t0.pin_validation_pattern as AUG_POLICY_HEADER__PIN_CODE_VALIDATION_PATTERN,
        null,
        t0.policy_plan_insured_category as AUG_POLICY_HEADER__PLAN_INSURED_CATEGORY,
        t0.plan_code as AUG_POLICY_HEADER__PLAN_REFERENCE,
        null,
        t0.forex_rate_at_policy_level as AUG_POLICY_HEADER__POLICY_LEVEL_EXCHANGE_RATE,
        t0.policy_plan as AUG_POLICY_HEADER__POLICY_PLAN_NAME,
        t0.policy_tenure as AUG_POLICY_HEADER__POLICY_TENURE_YEARS,
        null,
        t0.process_type as AUG_POLICY_HEADER__POLICY_TRANSACTION_TYPE,
        t0.portal_payment_mode as AUG_POLICY_HEADER__PORTAL_PAYMENT_MODE,
        t0.premium_calculation_mode as AUG_POLICY_HEADER__PREMIUM_CALCULATION_MODE,
        null, null,
        t0.is_the_customer_id_same_as_premium_payer_id as AUG_POLICY_HEADER__PREMIUM_PAYER_SAME_AS_POLICYHOLDER_INDICATOR,
        t0.payment_schedule as AUG_POLICY_HEADER__PREMIUM_PAYMENT_SCHEDULE_REFERENCE,
        t0.old_product_code as AUG_POLICY_HEADER__PREVIOUS_PRODUCT_REFERENCE,
        t0.prebookpolicynumber as AUG_POLICY_HEADER__PRE_BOOKED_POLICY_NUMBER,
        t0.prive_flag as AUG_POLICY_HEADER__PRIVILEGED_CUSTOMER_SEGMENT_INDICATOR,
        t0.questionnaire_packages as AUG_POLICY_HEADER__QUESTIONNAIRE_PACKAGE_REFERENCE,
        null, null, null, null, null, null, null,
        t0.isselected as AUG_POLICY_HEADER__SELECTED_OPTION_INDICATOR,
        null, null, null, null,
        t0.policy_level_transaction_currency_for_sum_insured as AUG_POLICY_HEADER__SUM_INSURED_CURRENCY_CODE,
        null,
        t0.policy_sum_insured_in_base_currency as AUG_POLICY_HEADER__SUM_INSURED_TOTAL_IN_BASE_CURRENCY,
        t0.policy_sum_insured_in_transaction_currency as AUG_POLICY_HEADER__SUM_INSURED_TOTAL_IN_TRANSACTION_CURRENCY,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.percentage_discount_ as AUG_POLICY_PREMIUM_SUMMARY__DISCOUNT_PERCENTAGE,
        null, null,
        t0.loaded_premium as AUG_POLICY_PREMIUM_SUMMARY__LOADED_PREMIUM_AMOUNT,
        t0.loading_percentage as AUG_POLICY_PREMIUM_SUMMARY__LOADING_PERCENTAGE,
        null, null,
        t0.net_premium_in_premium_currency as AUG_POLICY_PREMIUM_SUMMARY__NET_PREMIUM_IN_PREMIUM_CURRENCY,
        t0.policy_premium_in_base_currency as AUG_POLICY_PREMIUM_SUMMARY__POLICY_PREMIUM_IN_BASE_CURRENCY,
        t0.policy_premium_in_transaction_currency as AUG_POLICY_PREMIUM_SUMMARY__POLICY_PREMIUM_IN_TRANSACTION_CURRENCY,
        t0.policy_premium_value as AUG_POLICY_PREMIUM_SUMMARY__POLICY_PREMIUM_VALUE,
        t0.premium as AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_AMOUNT,
        t0.policy_premium_without_loading as AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_BEFORE_LOADING_AMOUNT,
        null,
        t0.premium_collection as AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_COLLECTION_AMOUNT,
        t0.premium_currency as AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_CURRENCY_CODE,
        t0.premium_currency_exchange_rate as AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_CURRENCY_EXCHANGE_RATE,
        t0.premium_in_bhd as AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_IN_BAHRAINI_DINAR,
        t0.mode_of_payment as AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_PAYMENT_MODE,
        null, null, null, null, null, null, null,
        nullif(trim(t0.cover_name),'') as POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
        null, null, null, null, null,
        t0.limit as POLICY_COVERAGE_SCHEDULE__LIMIT_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        'OEM' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.oempremium as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null,
        'GST_TDS' as POLICY_TAX_HEAD__TAX_HEAD_CODE_CK,
        t0.gst_tds as POLICY_TAX_HEAD__TAX_AMOUNT,
        null, null,
        t0.free_cancellation_period as POLICY_TERMS__FREE_LOOK_PERIOD,
        null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_policy_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_policy_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_number), ''), '')) is not null

    union all

    -- branch 295: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j3.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'BUSINESS_TYPE' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        t0.business_type as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        null, null, null, null, null, null, null, null, null,
        'CROSS_SELL_DISCOUNT' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        t0.cross_sell_discount as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_policy_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_policy_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_number), ''), '')) is not null

    union all

    -- branch 296: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j3.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CATEGORY' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        t0.category as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        null, null, null, null, null, null, null, null, null,
        'EST11_PROFESSION_DISCOUNT' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        t0.est11_profession_discount as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_policy_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_policy_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_number), ''), '')) is not null

    union all

    -- branch 297: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j3.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CSD' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        t0.csd as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        null, null, null, null, null, null, null, null, null,
        'EST1A_TP_CLAIMS_TAKEN_IN_POLICY_DISCOUNT' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        t0.est1a_tp_claims_taken_in_policy_discount as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_policy_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_policy_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_number), ''), '')) is not null

    union all

    -- branch 298: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j3.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        'EST1_OD_CLAIMS_TAKEN_IN_POLICY_DISCOUNT' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        t0.est1_od_claims_taken_in_policy_discount as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_policy_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_policy_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_number), ''), '')) is not null

    union all

    -- branch 299: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j3.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        'EST21_PURPOSE_OF_USE_DISCOUNT' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        t0.est21_purpose_of_use_discount as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_policy_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_policy_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_number), ''), '')) is not null

    union all

    -- branch 300: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j3.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        'EXTENDED_STP_DISCOUNT' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        t0.extended_stp_discount as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_policy_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_policy_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_number), ''), '')) is not null

    union all

    -- branch 301: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j3.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'LAID_UP_ADJUSTMENT_POST' as POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
        null,
        'OD' as POLICY_PREMIUM_HEAD__SECTION_CK,
        null, null, null,
        t0.post_laid_up_adjustment as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
        null, null, null,
        'IGST' as POLICY_TAX_HEAD__TAX_HEAD_CODE_CK,
        t0.igst_amount as POLICY_TAX_HEAD__TAX_AMOUNT,
        null,
        t0.igst_percentage as POLICY_TAX_HEAD__TAX_RATE,
        null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_policy_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_policy_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_number), ''), '')) is not null

    union all

    -- branch 302: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | child-key literal(s): POLICY_SUM_INSURED_BREAKUP.Sum Insured Head=TOTAL_IN_SUM_INSURED_CURRENCY
    select
        nullif(coalesce(nullif(trim(t0.policy_number), ''), nullif(trim(j3.policy_number), '')), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'TOTAL_IN_SUM_INSURED_CURRENCY' as POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_HEAD_CK,
        null,
        t0.sum_insured_in_si_currency as POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_AMOUNT,
        null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_policy_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_policy_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(coalesce(nullif(trim(t0.policy_number), ''), nullif(trim(j3.policy_number), '')), '')) is not null

    union all

    -- branch 303: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j4.policy_number), ''), '') as POLICY_BK,
        'SPECIAL_RATE' as AUG_POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        null, null, null,
        t0.special_rate_applicable as AUG_POLICY_DISCOUNT_LOADING_APPLIED__SPECIAL_RATE_APPLICABLE_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        t0.payment_mode as AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_PAYMENT_MODE,
        null, null, null, null, null,
        'BUSINESS_TYPE' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        t0.business_type as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        null, null, null, null, null, null, null, null, null,
        'SPECIAL_RATE' as POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
        null, null,
        t0.special_rate as POLICY_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED,
        null, null, null, null,
        t0.type_of_endorsement as POLICY_ENDORSEMENT__ENDORSEMENT_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_number), ''), '')) is not null

    union all

    -- branch 304: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(j4.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'TYPE' as POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
        t0.type as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(nullif(trim(j4.policy_number), ''), '')) is not null

)

select
    POLICY_BK,
    AUG_POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
    first_value(AUG_POLICY_DISCOUNT_LOADING_APPLIED__EMPLOYEE_RELATIONSHIP_TO_INSURED) ignore nulls over (partition by POLICY_BK, AUG_POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_DISCOUNT_LOADING_APPLIED__EMPLOYEE_RELATIONSHIP_TO_INSURED,
    first_value(AUG_POLICY_DISCOUNT_LOADING_APPLIED__ITEM_APPLIED_INDICATOR) ignore nulls over (partition by POLICY_BK, AUG_POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_DISCOUNT_LOADING_APPLIED__ITEM_APPLIED_INDICATOR,
    first_value(AUG_POLICY_DISCOUNT_LOADING_APPLIED__RATING_FACTOR_VALUE) ignore nulls over (partition by POLICY_BK, AUG_POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_DISCOUNT_LOADING_APPLIED__RATING_FACTOR_VALUE,
    first_value(AUG_POLICY_DISCOUNT_LOADING_APPLIED__SPECIAL_RATE_APPLICABLE_INDICATOR) ignore nulls over (partition by POLICY_BK, AUG_POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_DISCOUNT_LOADING_APPLIED__SPECIAL_RATE_APPLICABLE_INDICATOR,
    AUG_POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER_CK,
    first_value(AUG_POLICY_ENDORSEMENT__ENDORSEMENT_APPROVED_DATE) ignore nulls over (partition by POLICY_BK, AUG_POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_ENDORSEMENT__ENDORSEMENT_APPROVED_DATE,
    first_value(AUG_POLICY_ENDORSEMENT__ENDORSEMENT_REMARKS) ignore nulls over (partition by POLICY_BK, AUG_POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_ENDORSEMENT__ENDORSEMENT_REMARKS,
    first_value(AUG_POLICY_ENDORSEMENT__REVISED_SUM_INSURED_AMOUNT) ignore nulls over (partition by POLICY_BK, AUG_POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_ENDORSEMENT__REVISED_SUM_INSURED_AMOUNT,
    first_value(AUG_POLICY_HEADER__ADDITIONAL_REMARKS) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__ADDITIONAL_REMARKS,
    first_value(AUG_POLICY_HEADER__APPLICATION_SUBMISSION_DATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__APPLICATION_SUBMISSION_DATE,
    first_value(AUG_POLICY_HEADER__APPLICATION_SUBMISSION_TIME) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__APPLICATION_SUBMISSION_TIME,
    first_value(AUG_POLICY_HEADER__ATTACHED_COVER_CODE_LIST) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__ATTACHED_COVER_CODE_LIST,
    first_value(AUG_POLICY_HEADER__BASE_CURRENCY_CODE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__BASE_CURRENCY_CODE,
    first_value(AUG_POLICY_HEADER__BUSINESS_TYPE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__BUSINESS_TYPE,
    first_value(AUG_POLICY_HEADER__CHILD_DETAIL_TYPE_SELECTED) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__CHILD_DETAIL_TYPE_SELECTED,
    first_value(AUG_POLICY_HEADER__CLAIM_INTIMATION_REFERENCE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__CLAIM_INTIMATION_REFERENCE,
    first_value(AUG_POLICY_HEADER__COR_INDICATOR) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__COR_INDICATOR,
    first_value(AUG_POLICY_HEADER__COVER_PACKAGE_CODE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__COVER_PACKAGE_CODE,
    first_value(AUG_POLICY_HEADER__DESTINATION_POLICY_NUMBER) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__DESTINATION_POLICY_NUMBER,
    first_value(AUG_POLICY_HEADER__ENDORSEMENT_APPLICABLE_INDICATOR) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__ENDORSEMENT_APPLICABLE_INDICATOR,
    first_value(AUG_POLICY_HEADER__EXPENSE_PAYMENT_MODE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__EXPENSE_PAYMENT_MODE,
    first_value(AUG_POLICY_HEADER__FINANCIAL_YEAR) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__FINANCIAL_YEAR,
    first_value(AUG_POLICY_HEADER__FIRST_EXECUTION_INDICATOR) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__FIRST_EXECUTION_INDICATOR,
    first_value(AUG_POLICY_HEADER__INSURER_NAME) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__INSURER_NAME,
    first_value(AUG_POLICY_HEADER__LEAD_REFERENCE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__LEAD_REFERENCE,
    first_value(AUG_POLICY_HEADER__LG_CODE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__LG_CODE,
    first_value(AUG_POLICY_HEADER__LINKED_PLAN_REFERENCE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__LINKED_PLAN_REFERENCE,
    first_value(AUG_POLICY_HEADER__LOSS_INTIMATED_BY_ROLE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__LOSS_INTIMATED_BY_ROLE,
    first_value(AUG_POLICY_HEADER__MANDATORY_QUESTIONNAIRE_INDICATOR) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__MANDATORY_QUESTIONNAIRE_INDICATOR,
    first_value(AUG_POLICY_HEADER__MASTER_QUOTE_REFERENCE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__MASTER_QUOTE_REFERENCE,
    first_value(AUG_POLICY_HEADER__NOT_TAKEN_UP_INDICATOR) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__NOT_TAKEN_UP_INDICATOR,
    first_value(AUG_POLICY_HEADER__ODS_REQUIRED_FOR) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__ODS_REQUIRED_FOR,
    first_value(AUG_POLICY_HEADER__OEM_POLICY_REFERENCE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__OEM_POLICY_REFERENCE,
    first_value(AUG_POLICY_HEADER__PIN_CODE_VALIDATION_PATTERN) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__PIN_CODE_VALIDATION_PATTERN,
    first_value(AUG_POLICY_HEADER__PLAN_CATEGORY) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__PLAN_CATEGORY,
    first_value(AUG_POLICY_HEADER__PLAN_INSURED_CATEGORY) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__PLAN_INSURED_CATEGORY,
    first_value(AUG_POLICY_HEADER__PLAN_REFERENCE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__PLAN_REFERENCE,
    first_value(AUG_POLICY_HEADER__POLICY_INTIMATION_DATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__POLICY_INTIMATION_DATE,
    first_value(AUG_POLICY_HEADER__POLICY_LEVEL_EXCHANGE_RATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__POLICY_LEVEL_EXCHANGE_RATE,
    first_value(AUG_POLICY_HEADER__POLICY_PLAN_NAME) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__POLICY_PLAN_NAME,
    first_value(AUG_POLICY_HEADER__POLICY_TENURE_YEARS) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__POLICY_TENURE_YEARS,
    first_value(AUG_POLICY_HEADER__POLICY_TERM_UNIT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__POLICY_TERM_UNIT,
    first_value(AUG_POLICY_HEADER__POLICY_TRANSACTION_TYPE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__POLICY_TRANSACTION_TYPE,
    first_value(AUG_POLICY_HEADER__PORTAL_PAYMENT_MODE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__PORTAL_PAYMENT_MODE,
    first_value(AUG_POLICY_HEADER__PREMIUM_CALCULATION_MODE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__PREMIUM_CALCULATION_MODE,
    first_value(AUG_POLICY_HEADER__PREMIUM_CURRENCY_CODE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__PREMIUM_CURRENCY_CODE,
    first_value(AUG_POLICY_HEADER__PREMIUM_CURRENCY_EXCHANGE_RATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__PREMIUM_CURRENCY_EXCHANGE_RATE,
    first_value(AUG_POLICY_HEADER__PREMIUM_PAYER_SAME_AS_POLICYHOLDER_INDICATOR) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__PREMIUM_PAYER_SAME_AS_POLICYHOLDER_INDICATOR,
    first_value(AUG_POLICY_HEADER__PREMIUM_PAYMENT_SCHEDULE_REFERENCE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__PREMIUM_PAYMENT_SCHEDULE_REFERENCE,
    first_value(AUG_POLICY_HEADER__PREVIOUS_PRODUCT_REFERENCE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__PREVIOUS_PRODUCT_REFERENCE,
    first_value(AUG_POLICY_HEADER__PRE_BOOKED_POLICY_NUMBER) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__PRE_BOOKED_POLICY_NUMBER,
    first_value(AUG_POLICY_HEADER__PRIVILEGED_CUSTOMER_SEGMENT_INDICATOR) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__PRIVILEGED_CUSTOMER_SEGMENT_INDICATOR,
    first_value(AUG_POLICY_HEADER__QUESTIONNAIRE_PACKAGE_REFERENCE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__QUESTIONNAIRE_PACKAGE_REFERENCE,
    first_value(AUG_POLICY_HEADER__REINSURANCE_PLACEMENT_PENDING_INDICATOR) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__REINSURANCE_PLACEMENT_PENDING_INDICATOR,
    first_value(AUG_POLICY_HEADER__RISK_LEVEL_BASE_CURRENCY_CODE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__RISK_LEVEL_BASE_CURRENCY_CODE,
    first_value(AUG_POLICY_HEADER__RISK_LEVEL_SUM_INSURED_TRANSACTION_CURRENCY_CODE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__RISK_LEVEL_SUM_INSURED_TRANSACTION_CURRENCY_CODE,
    first_value(AUG_POLICY_HEADER__RISK_LEVEL_TRANSACTION_CURRENCY_CODE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__RISK_LEVEL_TRANSACTION_CURRENCY_CODE,
    first_value(AUG_POLICY_HEADER__SCIP_SCHEME_REFERENCE_NUMBER) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__SCIP_SCHEME_REFERENCE_NUMBER,
    first_value(AUG_POLICY_HEADER__SCRUTINY_STATUS) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__SCRUTINY_STATUS,
    first_value(AUG_POLICY_HEADER__SELECTED_COVER_CODE_LIST) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__SELECTED_COVER_CODE_LIST,
    first_value(AUG_POLICY_HEADER__SELECTED_OPTION_INDICATOR) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__SELECTED_OPTION_INDICATOR,
    first_value(AUG_POLICY_HEADER__SERVICING_BRANCH_NAME) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__SERVICING_BRANCH_NAME,
    first_value(AUG_POLICY_HEADER__STANDALONE_CPA_POLICY_NUMBER) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__STANDALONE_CPA_POLICY_NUMBER,
    first_value(AUG_POLICY_HEADER__STRAIGHT_THROUGH_PROCESSING_REASON) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__STRAIGHT_THROUGH_PROCESSING_REASON,
    first_value(AUG_POLICY_HEADER__SUB_CHANNEL_NAME) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__SUB_CHANNEL_NAME,
    first_value(AUG_POLICY_HEADER__SUM_INSURED_CURRENCY_CODE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__SUM_INSURED_CURRENCY_CODE,
    first_value(AUG_POLICY_HEADER__SUM_INSURED_CURRENCY_EXCHANGE_RATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__SUM_INSURED_CURRENCY_EXCHANGE_RATE,
    first_value(AUG_POLICY_HEADER__SUM_INSURED_TOTAL_IN_BASE_CURRENCY) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__SUM_INSURED_TOTAL_IN_BASE_CURRENCY,
    first_value(AUG_POLICY_HEADER__SUM_INSURED_TOTAL_IN_TRANSACTION_CURRENCY) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__SUM_INSURED_TOTAL_IN_TRANSACTION_CURRENCY,
    first_value(AUG_POLICY_HEADER__TAGGED_POLICY_REFERENCE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__TAGGED_POLICY_REFERENCE,
    first_value(AUG_POLICY_HEADER__TRANSACTION_CURRENCY_CODE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__TRANSACTION_CURRENCY_CODE,
    first_value(AUG_POLICY_HEADER__TRANSACTION_LINE_SERIAL_NUMBER) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__TRANSACTION_LINE_SERIAL_NUMBER,
    first_value(AUG_POLICY_HEADER__TRANSACTION_REFERENCE_DETAIL) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__TRANSACTION_REFERENCE_DETAIL,
    first_value(AUG_POLICY_HEADER__UNDERWRITING_REMARKS) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__UNDERWRITING_REMARKS,
    first_value(AUG_POLICY_HEADER__VALIDATION_ERROR_DESCRIPTION) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_HEADER__VALIDATION_ERROR_DESCRIPTION,
    AUG_POLICY_PA_NAMED_PERSON__NAMED_PERSON_NAME_CK,
    AUG_POLICY_PA_NAMED_PERSON__NAMED_PERSON_SEQUENCE_CK,
    first_value(AUG_POLICY_PA_NAMED_PERSON__BENEFIT_ALLOCATION_PERCENTAGE) ignore nulls over (partition by POLICY_BK, AUG_POLICY_PA_NAMED_PERSON__NAMED_PERSON_NAME_CK, AUG_POLICY_PA_NAMED_PERSON__NAMED_PERSON_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PA_NAMED_PERSON__BENEFIT_ALLOCATION_PERCENTAGE,
    first_value(AUG_POLICY_PA_NAMED_PERSON__NAMED_PERSON_AGE) ignore nulls over (partition by POLICY_BK, AUG_POLICY_PA_NAMED_PERSON__NAMED_PERSON_NAME_CK, AUG_POLICY_PA_NAMED_PERSON__NAMED_PERSON_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PA_NAMED_PERSON__NAMED_PERSON_AGE,
    first_value(AUG_POLICY_PA_NAMED_PERSON__NAMED_PERSON_GENDER) ignore nulls over (partition by POLICY_BK, AUG_POLICY_PA_NAMED_PERSON__NAMED_PERSON_NAME_CK, AUG_POLICY_PA_NAMED_PERSON__NAMED_PERSON_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PA_NAMED_PERSON__NAMED_PERSON_GENDER,
    first_value(AUG_POLICY_PA_NAMED_PERSON__NAMED_PERSON_NAME) ignore nulls over (partition by POLICY_BK, AUG_POLICY_PA_NAMED_PERSON__NAMED_PERSON_NAME_CK, AUG_POLICY_PA_NAMED_PERSON__NAMED_PERSON_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PA_NAMED_PERSON__NAMED_PERSON_NAME,
    first_value(AUG_POLICY_PA_NAMED_PERSON__NAMED_PERSON_RELATIONSHIP) ignore nulls over (partition by POLICY_BK, AUG_POLICY_PA_NAMED_PERSON__NAMED_PERSON_NAME_CK, AUG_POLICY_PA_NAMED_PERSON__NAMED_PERSON_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PA_NAMED_PERSON__NAMED_PERSON_RELATIONSHIP,
    first_value(AUG_POLICY_PA_NAMED_PERSON__NOMINEE_NAME) ignore nulls over (partition by POLICY_BK, AUG_POLICY_PA_NAMED_PERSON__NAMED_PERSON_NAME_CK, AUG_POLICY_PA_NAMED_PERSON__NAMED_PERSON_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PA_NAMED_PERSON__NOMINEE_NAME,
    first_value(AUG_POLICY_PA_NAMED_PERSON__NOMINEE_RELATIONSHIP_TO_INSURED) ignore nulls over (partition by POLICY_BK, AUG_POLICY_PA_NAMED_PERSON__NAMED_PERSON_NAME_CK, AUG_POLICY_PA_NAMED_PERSON__NAMED_PERSON_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PA_NAMED_PERSON__NOMINEE_RELATIONSHIP_TO_INSURED,
    first_value(AUG_POLICY_PREMIUM_SUMMARY__ADMINISTRATION_CHARGE_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_SUMMARY__ADMINISTRATION_CHARGE_AMOUNT,
    first_value(AUG_POLICY_PREMIUM_SUMMARY__ADMINISTRATION_FEE_DESCRIPTION) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_SUMMARY__ADMINISTRATION_FEE_DESCRIPTION,
    first_value(AUG_POLICY_PREMIUM_SUMMARY__ADMINISTRATIVE_FEE_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_SUMMARY__ADMINISTRATIVE_FEE_AMOUNT,
    first_value(AUG_POLICY_PREMIUM_SUMMARY__ADMINISTRATIVE_FEE_WAIVED_INDICATOR) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_SUMMARY__ADMINISTRATIVE_FEE_WAIVED_INDICATOR,
    first_value(AUG_POLICY_PREMIUM_SUMMARY__BANK_CHARGE_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_SUMMARY__BANK_CHARGE_AMOUNT,
    first_value(AUG_POLICY_PREMIUM_SUMMARY__DISCOUNT_PERCENTAGE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_SUMMARY__DISCOUNT_PERCENTAGE,
    first_value(AUG_POLICY_PREMIUM_SUMMARY__EXCHANGE_RATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_SUMMARY__EXCHANGE_RATE,
    first_value(AUG_POLICY_PREMIUM_SUMMARY__FIXED_CASH_DEPOSIT_SETTLEMENT_INDICATOR) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_SUMMARY__FIXED_CASH_DEPOSIT_SETTLEMENT_INDICATOR,
    first_value(AUG_POLICY_PREMIUM_SUMMARY__LOADED_PREMIUM_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_SUMMARY__LOADED_PREMIUM_AMOUNT,
    first_value(AUG_POLICY_PREMIUM_SUMMARY__LOADING_PERCENTAGE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_SUMMARY__LOADING_PERCENTAGE,
    first_value(AUG_POLICY_PREMIUM_SUMMARY__MANUAL_REFUND_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_SUMMARY__MANUAL_REFUND_AMOUNT,
    first_value(AUG_POLICY_PREMIUM_SUMMARY__MINIMUM_GROSS_PREMIUM) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_SUMMARY__MINIMUM_GROSS_PREMIUM,
    first_value(AUG_POLICY_PREMIUM_SUMMARY__NET_PREMIUM_IN_PREMIUM_CURRENCY) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_SUMMARY__NET_PREMIUM_IN_PREMIUM_CURRENCY,
    first_value(AUG_POLICY_PREMIUM_SUMMARY__POLICY_PREMIUM_IN_BASE_CURRENCY) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_SUMMARY__POLICY_PREMIUM_IN_BASE_CURRENCY,
    first_value(AUG_POLICY_PREMIUM_SUMMARY__POLICY_PREMIUM_IN_TRANSACTION_CURRENCY) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_SUMMARY__POLICY_PREMIUM_IN_TRANSACTION_CURRENCY,
    first_value(AUG_POLICY_PREMIUM_SUMMARY__POLICY_PREMIUM_VALUE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_SUMMARY__POLICY_PREMIUM_VALUE,
    first_value(AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_AMOUNT,
    first_value(AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_BEFORE_LOADING_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_BEFORE_LOADING_AMOUNT,
    first_value(AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_CALCULATION_BASIS) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_CALCULATION_BASIS,
    first_value(AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_COLLECTION_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_COLLECTION_AMOUNT,
    first_value(AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_CURRENCY_CODE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_CURRENCY_CODE,
    first_value(AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_CURRENCY_EXCHANGE_RATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_CURRENCY_EXCHANGE_RATE,
    first_value(AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_IN_BAHRAINI_DINAR) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_IN_BAHRAINI_DINAR,
    first_value(AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_PAYMENT_MODE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_SUMMARY__PREMIUM_PAYMENT_MODE,
    first_value(AUG_POLICY_PREMIUM_SUMMARY__THIRD_PARTY_TARIFF_RATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_SUMMARY__THIRD_PARTY_TARIFF_RATE,
    first_value(AUG_POLICY_PREMIUM_SUMMARY__TOTAL_FEES_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_SUMMARY__TOTAL_FEES_AMOUNT,
    first_value(AUG_POLICY_PREMIUM_SUMMARY__USER_ENTERED_PREMIUM_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_SUMMARY__USER_ENTERED_PREMIUM_AMOUNT,
    first_value(AUG_POLICY_PREMIUM_SUMMARY__USER_OVERRIDDEN_PREMIUM_AMOUNT) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_SUMMARY__USER_OVERRIDDEN_PREMIUM_AMOUNT,
    first_value(AUG_POLICY_PREMIUM_SUMMARY__WRITE_OFF_WAIVER_INDICATOR) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_POLICY_PREMIUM_SUMMARY__WRITE_OFF_WAIVER_INDICATOR,
    POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK,
    first_value(POLICY_CLASSIFICATION__CLASSIFICATION_VALUE) ignore nulls over (partition by POLICY_BK, POLICY_CLASSIFICATION__CLASSIFICATION_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_CLASSIFICATION__CLASSIFICATION_VALUE,
    POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK,
    POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK,
    first_value(POLICY_COVERAGE_SCHEDULE__COVERAGE_END_DATE) ignore nulls over (partition by POLICY_BK, POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_COVERAGE_SCHEDULE__COVERAGE_END_DATE,
    first_value(POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE) ignore nulls over (partition by POLICY_BK, POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE,
    first_value(POLICY_COVERAGE_SCHEDULE__COVERAGE_START_DATE) ignore nulls over (partition by POLICY_BK, POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_COVERAGE_SCHEDULE__COVERAGE_START_DATE,
    first_value(POLICY_COVERAGE_SCHEDULE__COVERAGE_STATUS) ignore nulls over (partition by POLICY_BK, POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_COVERAGE_SCHEDULE__COVERAGE_STATUS,
    first_value(POLICY_COVERAGE_SCHEDULE__LIMIT_AMOUNT) ignore nulls over (partition by POLICY_BK, POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_COVERAGE_SCHEDULE__LIMIT_AMOUNT,
    first_value(POLICY_COVERAGE_SCHEDULE__PREMIUM_FOR_COVERAGE) ignore nulls over (partition by POLICY_BK, POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_COVERAGE_SCHEDULE__PREMIUM_FOR_COVERAGE,
    first_value(POLICY_COVERAGE_SCHEDULE__SUM_INSURED) ignore nulls over (partition by POLICY_BK, POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE_CK, POLICY_COVERAGE_SCHEDULE__COVERAGE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_COVERAGE_SCHEDULE__SUM_INSURED,
    POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK,
    first_value(POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED) ignore nulls over (partition by POLICY_BK, POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED,
    first_value(POLICY_DISCOUNT_LOADING_APPLIED__EXTRA_DISCOUNT_OPTED_INDICATOR) ignore nulls over (partition by POLICY_BK, POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_DISCOUNT_LOADING_APPLIED__EXTRA_DISCOUNT_OPTED_INDICATOR,
    first_value(POLICY_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED) ignore nulls over (partition by POLICY_BK, POLICY_DISCOUNT_LOADING_APPLIED__ITEM_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED,
    POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER_CK,
    first_value(POLICY_ENDORSEMENT__EFFECTIVE_DATE) ignore nulls over (partition by POLICY_BK, POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_ENDORSEMENT__EFFECTIVE_DATE,
    first_value(POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER) ignore nulls over (partition by POLICY_BK, POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER,
    first_value(POLICY_ENDORSEMENT__ENDORSEMENT_REASON) ignore nulls over (partition by POLICY_BK, POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_ENDORSEMENT__ENDORSEMENT_REASON,
    first_value(POLICY_ENDORSEMENT__ENDORSEMENT_TYPE) ignore nulls over (partition by POLICY_BK, POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_ENDORSEMENT__ENDORSEMENT_TYPE,
    first_value(POLICY_ENDORSEMENT__PREMIUM_IMPACT_AMOUNT) ignore nulls over (partition by POLICY_BK, POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_ENDORSEMENT__PREMIUM_IMPACT_AMOUNT,
    first_value(POLICY_ENDORSEMENT__SUM_INSURED_IMPACT_AMOUNT) ignore nulls over (partition by POLICY_BK, POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_ENDORSEMENT__SUM_INSURED_IMPACT_AMOUNT,
    POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK,
    POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK,
    POLICY_PREMIUM_HEAD__SECTION_CK,
    POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK,
    first_value(POLICY_PREMIUM_HEAD__BASE_AMOUNT) ignore nulls over (partition by POLICY_BK, POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK, POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK, POLICY_PREMIUM_HEAD__SECTION_CK, POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PREMIUM_HEAD__BASE_AMOUNT,
    first_value(POLICY_PREMIUM_HEAD__DISCOUNT_AMOUNT) ignore nulls over (partition by POLICY_BK, POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK, POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK, POLICY_PREMIUM_HEAD__SECTION_CK, POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PREMIUM_HEAD__DISCOUNT_AMOUNT,
    first_value(POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM) ignore nulls over (partition by POLICY_BK, POLICY_PREMIUM_HEAD__PREMIUM_HEAD_CODE_CK, POLICY_PREMIUM_HEAD__COVERAGE_REFERENCE_CK, POLICY_PREMIUM_HEAD__SECTION_CK, POLICY_PREMIUM_HEAD__ADJUSTED_INDICATOR_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM,
    POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_HEAD_CK,
    first_value(POLICY_SUM_INSURED_BREAKUP__HEAD_DESCRIPTION) ignore nulls over (partition by POLICY_BK, POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_HEAD_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_SUM_INSURED_BREAKUP__HEAD_DESCRIPTION,
    first_value(POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_AMOUNT) ignore nulls over (partition by POLICY_BK, POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_HEAD_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_AMOUNT,
    POLICY_TAX_HEAD__TAX_HEAD_CODE_CK,
    first_value(POLICY_TAX_HEAD__TAX_AMOUNT) ignore nulls over (partition by POLICY_BK, POLICY_TAX_HEAD__TAX_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_TAX_HEAD__TAX_AMOUNT,
    first_value(POLICY_TAX_HEAD__TAX_HEAD_CODE) ignore nulls over (partition by POLICY_BK, POLICY_TAX_HEAD__TAX_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_TAX_HEAD__TAX_HEAD_CODE,
    first_value(POLICY_TAX_HEAD__TAX_RATE) ignore nulls over (partition by POLICY_BK, POLICY_TAX_HEAD__TAX_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_TAX_HEAD__TAX_RATE,
    first_value(POLICY_TERMS__FREE_LOOK_PERIOD) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_TERMS__FREE_LOOK_PERIOD,
    first_value(POLICY_TERMS__GEOGRAPHICAL_SCOPE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_TERMS__GEOGRAPHICAL_SCOPE,
    -- the row's own source time: LOAD_DATETIME for hubs, links and single-active satellites
    m.REC_REFRESH_AT,
    -- multi-active satellites on POLICY_BK (SAT_MOTOR_AUG_POLICY_DISCOUNT_LOADING_APPLIED, SAT_MOTOR_AUG_POLICY_ENDORSEMENT, SAT_MOTOR_AUG_POLICY_PA_NAMED_PERSON, SAT_POLICY_CLASSIFICATION, SAT_POLICY_COVERAGE_SCHEDULE, SAT_POLICY_DISCOUNT_LOADING_APPLIED, SAT_POLICY_ENDORSEMENT, SAT_POLICY_PREMIUM_HEAD, SAT_POLICY_SUM_INSURED_BREAKUP, SAT_POLICY_TAX_HEAD):
    -- one load time per POLICY_BK, the newest REC_REFRESH_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when coalesce(m.AUG_POLICY_DISCOUNT_LOADING_APPLIED__EMPLOYEE_RELATIONSHIP_TO_INSURED, m.AUG_POLICY_DISCOUNT_LOADING_APPLIED__ITEM_APPLIED_INDICATOR, m.AUG_POLICY_DISCOUNT_LOADING_APPLIED__RATING_FACTOR_VALUE, m.AUG_POLICY_DISCOUNT_LOADING_APPLIED__SPECIAL_RATE_APPLICABLE_INDICATOR, m.AUG_POLICY_ENDORSEMENT__ENDORSEMENT_APPROVED_DATE, m.AUG_POLICY_ENDORSEMENT__ENDORSEMENT_REMARKS, m.AUG_POLICY_ENDORSEMENT__REVISED_SUM_INSURED_AMOUNT, m.AUG_POLICY_PA_NAMED_PERSON__BENEFIT_ALLOCATION_PERCENTAGE, m.AUG_POLICY_PA_NAMED_PERSON__NAMED_PERSON_AGE, m.AUG_POLICY_PA_NAMED_PERSON__NAMED_PERSON_GENDER, m.AUG_POLICY_PA_NAMED_PERSON__NAMED_PERSON_NAME, m.AUG_POLICY_PA_NAMED_PERSON__NAMED_PERSON_RELATIONSHIP, m.AUG_POLICY_PA_NAMED_PERSON__NOMINEE_NAME, m.AUG_POLICY_PA_NAMED_PERSON__NOMINEE_RELATIONSHIP_TO_INSURED, m.POLICY_CLASSIFICATION__CLASSIFICATION_VALUE, m.POLICY_COVERAGE_SCHEDULE__COVERAGE_END_DATE, m.POLICY_COVERAGE_SCHEDULE__COVERAGE_REFERENCE, m.POLICY_COVERAGE_SCHEDULE__COVERAGE_START_DATE, m.POLICY_COVERAGE_SCHEDULE__COVERAGE_STATUS, m.POLICY_COVERAGE_SCHEDULE__LIMIT_AMOUNT, m.POLICY_COVERAGE_SCHEDULE__PREMIUM_FOR_COVERAGE, m.POLICY_COVERAGE_SCHEDULE__SUM_INSURED, m.POLICY_DISCOUNT_LOADING_APPLIED__AMOUNT_APPLIED, m.POLICY_DISCOUNT_LOADING_APPLIED__EXTRA_DISCOUNT_OPTED_INDICATOR, m.POLICY_DISCOUNT_LOADING_APPLIED__PERCENTAGE_APPLIED, m.POLICY_ENDORSEMENT__EFFECTIVE_DATE, m.POLICY_ENDORSEMENT__ENDORSEMENT_NUMBER, m.POLICY_ENDORSEMENT__ENDORSEMENT_REASON, m.POLICY_ENDORSEMENT__ENDORSEMENT_TYPE, m.POLICY_ENDORSEMENT__PREMIUM_IMPACT_AMOUNT, m.POLICY_ENDORSEMENT__SUM_INSURED_IMPACT_AMOUNT, m.POLICY_PREMIUM_HEAD__BASE_AMOUNT, m.POLICY_PREMIUM_HEAD__DISCOUNT_AMOUNT, m.POLICY_PREMIUM_HEAD__NET_HEAD_PREMIUM, m.POLICY_SUM_INSURED_BREAKUP__HEAD_DESCRIPTION, m.POLICY_SUM_INSURED_BREAKUP__SUM_INSURED_AMOUNT, m.POLICY_TAX_HEAD__TAX_AMOUNT, m.POLICY_TAX_HEAD__TAX_HEAD_CODE, m.POLICY_TAX_HEAD__TAX_RATE) is not null
             then m.REC_REFRESH_AT end)
        over (partition by m.POLICY_BK) as POLICY_BK__MA_LOAD_DATETIME
from merged m
