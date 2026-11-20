-- CENTRAL VIEW v14_risk_object -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
-- Walk tables, joined only to resolve spine keys (not counted):
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_ASSESSMENT_PRE_INSPECTION
--   SAT_MOTOR_AUG_COVERAGE_MONETARY_CONTEXT
--   SAT_MOTOR_AUG_COVERAGE_MOTOR_PA_OCCUPANT
--   SAT_MOTOR_AUG_COVERAGE_PACKAGE_RATING
--   SAT_MOTOR_AUG_FINTXN_HEADER
--   SAT_MOTOR_AUG_FINTXN_PREMIUM
--   SAT_MOTOR_AUG_ORG_UNIT_DEFINITION
--   SAT_MOTOR_AUG_PRODUCT_RATING_STRUCTURE
--   SAT_MOTOR_AUG_QUOTE_EXCESS_STRUCTURE
--   SAT_MOTOR_AUG_QUOTE_TAX_BREAKUP
--   SAT_MOTOR_AUG_QUOTE_UNDERWRITING_WORKFLOW
--   SAT_MOTOR_AUG_RISK_MOTOR_LOSS_EXPERIENCE
--   SAT_MOTOR_AUG_RISK_OBJECT_CORE
--   SAT_MOTOR_AUG_RISK_OBJECT_INSURABLE_INTEREST
--   SAT_MOTOR_AUG_RISK_OBJECT_VALUATION
--   SAT_MOTOR_AUG_RISK_TRAILER
--   SAT_COMMON_STATUS
--   SAT_COVERAGE_MOTOR_PA_OCCUPANT
--   SAT_POLICY_CERTIFICATE
--   SAT_POLICY_HEADER
--   SAT_POLICY_LONG_TERM_DETAIL
--   SAT_POLICY_RENEWAL
--   SAT_POLICY_TAX_INVOICE
--   SAT_PRODUCT_DEFINITION
--   SAT_PRODUCT_RATING_STRUCTURE
--   SAT_RISK_EXTENDED_WARRANTY
--   SAT_RISK_MOTOR_IDV
--   SAT_RISK_OBJECT_CORE
--   SAT_RISK_OBJECT_INSURABLE_INTEREST
--   SAT_RISK_OBJECT_OWNERSHIP_HISTORY
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_ASSESSMENT_PARTY
--   LNK_FINTXN_PARTY
--   LNK_PARTY_DOCUMENT
--   LNK_PARTY_LOCATION
--   LNK_POLICY_DOCUMENT
--   LNK_POLICY_LOCATION
--   LNK_POLICY_PARTY
--   LNK_POLICY_PRODUCT
--   LNK_POLICY_RISK_OBJECT
--   LNK_QUOTE_PARTY
--   LNK_QUOTE_PRODUCT
--   LNK_QUOTE_RISK_OBJECT
--   LNK_RISK_OBJECT_ASSESSMENT
--   LNK_RISK_OBJECT_DOCUMENT
--   LNK_RISK_OBJECT_LOCATION
--   LNK_RISK_OBJECT_PARTY
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
    select
        cast(null as varchar) as ASSESSMENT_BK,
        cast(null as varchar) as COVERAGE_BK,
        cast(null as varchar) as DOCUMENT_BK,
        cast(null as varchar) as FINANCIAL_TRANSACTION_BK,
        cast(null as varchar) as LOCATION_BK,
        cast(null as varchar) as ORG_UNIT_BK,
        cast(null as varchar) as PARTY_BK,
        nullif(nullif(trim(j3.policyno),''), '') as POLICY_BK,
        nullif(nullif(trim(t0.stored_product_code),''), '') as PRODUCT_BK,
        cast(null as varchar) as QUOTE_BK,
        nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), '') as RISK_OBJECT_BK,
        cast(null as number) as __LNK_ASSESSMENT_PARTY,
        cast(null as number) as __LNK_FINTXN_PARTY,
        cast(null as number) as __LNK_PARTY_DOCUMENT,
        cast(null as number) as __LNK_PARTY_LOCATION,
        cast(null as number) as __LNK_POLICY_DOCUMENT,
        cast(null as number) as __LNK_POLICY_LOCATION,
        cast(null as number) as __LNK_POLICY_PARTY,
        cast(null as number) as __LNK_POLICY_PRODUCT,
        cast(null as number) as __LNK_POLICY_RISK_OBJECT,
        cast(null as number) as __LNK_QUOTE_PARTY,
        cast(null as number) as __LNK_QUOTE_PRODUCT,
        cast(null as number) as __LNK_QUOTE_RISK_OBJECT,
        cast(null as number) as __LNK_RISK_OBJECT_ASSESSMENT,
        cast(null as number) as __LNK_RISK_OBJECT_DOCUMENT,
        cast(null as number) as __LNK_RISK_OBJECT_LOCATION,
        cast(null as number) as __LNK_RISK_OBJECT_PARTY,
        cast(null as varchar) as ASSESSMENT_PRE_INSPECTION__EXISTING_DAMAGE_DESCRIPTION,
        cast(null as varchar) as ASSESSMENT_PRE_INSPECTION__INSPECTION_DATE,
        cast(null as varchar) as ASSESSMENT_PRE_INSPECTION__INSPECTION_LOCATION_ADDRESS,
        cast(null as varchar) as ASSESSMENT_PRE_INSPECTION__INSPECTOR_REFERENCE,
        cast(null as varchar) as AUG_COVERAGE_MONETARY_CONTEXT__BASE_CURRENCY_CODE,
        cast(null as varchar) as AUG_COVERAGE_MONETARY_CONTEXT__EXCHANGE_RATE,
        cast(null as varchar) as AUG_COVERAGE_MONETARY_CONTEXT__SUM_INSURED_CURRENCY_CODE,
        cast(null as varchar) as AUG_COVERAGE_MONETARY_CONTEXT__TRANSACTION_CURRENCY_CODE,
        cast(null as varchar) as AUG_COVERAGE_MOTOR_PA_OCCUPANT__OCCUPANT_PERSON_DETAIL_TEXT,
        cast(null as varchar) as AUG_COVERAGE_PACKAGE_RATING__ADD_ON_PACKAGE_CODE,
        cast(null as varchar) as AUG_COVERAGE_PACKAGE_RATING__MAIN_PACKAGE_CODE,
        cast(null as varchar) as AUG_FINTXN_HEADER__PAYMENT_PURPOSE,
        cast(null as varchar) as AUG_FINTXN_PREMIUM__COLLECTED_PREMIUM_AMOUNT,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__CLUSTER_CODE,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__CLUSTER_NAME,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__OFFICE_NAME_AND_ADDRESS_TEXT,
        cast(null as varchar) as AUG_ORG_UNIT_DEFINITION__OPERATING_UNIT_LABEL,
        cast(null as varchar) as AUG_PRODUCT_RATING_STRUCTURE__MINIMUM_DEPOSIT_PREMIUM_TYPE,
        cast(null as varchar) as AUG_QUOTE_EXCESS_STRUCTURE__EXCESS_CODE_CK,
        cast(null as varchar) as AUG_QUOTE_EXCESS_STRUCTURE__EXCESS_AMOUNT,
        cast(null as varchar) as AUG_QUOTE_EXCESS_STRUCTURE__EXCESS_TYPE,
        cast(null as varchar) as AUG_QUOTE_TAX_BREAKUP__CGST_AMOUNT,
        cast(null as varchar) as AUG_QUOTE_TAX_BREAKUP__EXEMPTION_REASON,
        cast(null as varchar) as AUG_QUOTE_TAX_BREAKUP__PLACE_OF_SUPPLY,
        cast(null as varchar) as AUG_QUOTE_UNDERWRITING_WORKFLOW__ADDITIONAL_INFORMATION_TEXT,
        cast(null as varchar) as AUG_QUOTE_UNDERWRITING_WORKFLOW__DEFICIENCY_STATUS,
        cast(null as varchar) as AUG_QUOTE_UNDERWRITING_WORKFLOW__UNDERWRITER_ACCEPTANCE_DECISION,
        cast(null as varchar) as AUG_RISK_MOTOR_LOSS_EXPERIENCE__OWN_DAMAGE_CLAIM_FREQUENCY,
        cast(null as varchar) as AUG_RISK_MOTOR_LOSS_EXPERIENCE__OWN_DAMAGE_CLAIM_SEVERITY,
        cast(null as varchar) as AUG_RISK_MOTOR_LOSS_EXPERIENCE__OWN_DAMAGE_LOSS_RATIO,
        cast(null as varchar) as AUG_RISK_OBJECT_CORE__RISK_COVER_END_TIME,
        cast(null as varchar) as AUG_RISK_OBJECT_CORE__RISK_COVER_EXPIRY_DATE,
        cast(null as varchar) as AUG_RISK_OBJECT_CORE__RISK_COVER_INCEPTION_DATE,
        cast(null as varchar) as AUG_RISK_OBJECT_CORE__RISK_COVER_START_TIME,
        cast(null as varchar) as AUG_RISK_OBJECT_CORE__RISK_LINE_SERIAL_NUMBER,
        cast(null as varchar) as AUG_RISK_OBJECT_CORE__WEATHER_EXPOSURE_SCORE,
        cast(null as varchar) as AUG_RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE_CK,
        cast(null as varchar) as AUG_RISK_OBJECT_INSURABLE_INTEREST__INTEREST_HOLDER_REFERENCE_CK,
        cast(null as varchar) as AUG_RISK_OBJECT_INSURABLE_INTEREST__HYPOTHECATION_TYPE,
        cast(null as varchar) as AUG_RISK_OBJECT_INSURABLE_INTEREST__INTEREST_HOLDER_INSTITUTION_NAME,
        cast(null as varchar) as AUG_RISK_OBJECT_INSURABLE_INTEREST__LEASE_ARRANGEMENT_DETAIL,
        cast(null as varchar) as AUG_RISK_OBJECT_VALUATION__EXCHANGE_RATE,
        cast(null as varchar) as AUG_RISK_TRAILER__TRAILER_SEQUENCE_CK,
        cast(null as varchar) as AUG_RISK_TRAILER__TRAILER_REGISTRATION_NUMBER_CK,
        cast(null as varchar) as AUG_RISK_TRAILER__TOWING_VEHICLE_REFERENCE,
        cast(null as varchar) as AUG_RISK_TRAILER__TRAILER_DETAIL_TEXT,
        cast(null as varchar) as AUG_RISK_TRAILER__TRAILER_TOTAL_VALUE,
        cast(null as varchar) as COMMON_STATUS__STATUS_CODE,
        cast(null as varchar) as COMMON_STATUS__SUB_STATUS_CODE,
        cast(null as varchar) as COVERAGE_MOTOR_PA_OCCUPANT__NUMBER_OF_PERSONS_COVERED,
        cast(null as varchar) as POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK,
        cast(null as varchar) as POLICY_CERTIFICATE__CERTIFICATE_NUMBER,
        t0.oem_policy_number_or_cover_note_number as POLICY_HEADER__COVER_NOTE_REFERENCE,
        cast(null as varchar) as POLICY_HEADER__CO_INSURANCE_INDICATOR,
        cast(null as varchar) as POLICY_HEADER__CURRENCY_CODE,
        t0.stored_lob_code as POLICY_HEADER__LINE_OF_BUSINESS,
        t0.master_policy_number as POLICY_HEADER__MASTER_POLICY_REFERENCE,
        cast(null as varchar) as POLICY_HEADER__POLICYHOLDER_REFERENCE,
        t0.channel_name as POLICY_HEADER__POLICY_CHANNEL_TYPE,
        cast(null as varchar) as POLICY_HEADER__POLICY_NUMBER,
        cast(null as varchar) as POLICY_HEADER__POLICY_REFERENCE_NUMBER,
        cast(null as varchar) as POLICY_HEADER__POLICY_REMARKS,
        t0.policy_status as POLICY_HEADER__POLICY_STATUS,
        cast(null as varchar) as POLICY_HEADER__POLICY_SUB_STATUS,
        cast(null as varchar) as POLICY_HEADER__POLICY_TERM,
        t0.business_type as POLICY_HEADER__POLICY_TYPE,
        cast(null as varchar) as POLICY_HEADER__PREMIUM_FREQUENCY,
        cast(null as varchar) as POLICY_HEADER__PREMIUM_PAYER_REFERENCE,
        cast(null as varchar) as POLICY_HEADER__PRODUCT_REFERENCE,
        cast(null as varchar) as POLICY_HEADER__RISK_END_TIME,
        t0.policy_expiry_date as POLICY_HEADER__RISK_EXPIRY_DATE,
        t0.policy_inception_date as POLICY_HEADER__RISK_INCEPTION_DATE,
        cast(null as varchar) as POLICY_HEADER__RISK_START_TIME,
        t0.policy_branch as POLICY_HEADER__SERVICING_ORG_UNIT_CODE,
        cast(null as varchar) as POLICY_HEADER__SUM_INSURED_TOTAL,
        cast(null as varchar) as POLICY_LONG_TERM_DETAIL__POLICY_DURATION_YEARS,
        t0.break_in as POLICY_RENEWAL__BREAK_IN_INDICATOR,
        cast(null as varchar) as POLICY_RENEWAL__RENEWAL_BLOCK_REASON,
        t0.renewal_date as POLICY_RENEWAL__RENEWAL_DUE_DATE,
        cast(null as varchar) as POLICY_RENEWAL__RENEWAL_STATUS,
        cast(null as varchar) as POLICY_TAX_INVOICE__INVOICE_NUMBER_CK,
        cast(null as varchar) as POLICY_TAX_INVOICE__INVOICE_NUMBER,
        cast(null as varchar) as PRODUCT_DEFINITION__HSN_SAC_CODE,
        t0.productplan as PRODUCT_DEFINITION__PRODUCT_NAME,
        cast(null as varchar) as PRODUCT_RATING_STRUCTURE__DEPOSIT_PREMIUM_INDICATOR,
        cast(null as varchar) as PRODUCT_RATING_STRUCTURE__MINIMUM_PREMIUM,
        cast(null as varchar) as RISK_EXTENDED_WARRANTY__WARRANTY_TYPE,
        cast(null as varchar) as RISK_MOTOR_IDV__AGREED_IDV,
        cast(null as varchar) as RISK_MOTOR_IDV__CNG_KIT_IDV,
        cast(null as varchar) as RISK_MOTOR_IDV__COMPUTED_IDV,
        cast(null as varchar) as RISK_MOTOR_IDV__SIDE_CAR_IDV,
        cast(null as varchar) as RISK_MOTOR_IDV__TOTAL_IDV,
        cast(null as varchar) as RISK_MOTOR_IDV__VEHICLE_AGE,
        cast(null as varchar) as RISK_OBJECT_CORE__ACQUISITION_DATE,
        cast(null as varchar) as RISK_OBJECT_CORE__EXPOSURE_UNIT,
        cast(null as varchar) as RISK_OBJECT_CORE__NEW_OR_USED_INDICATOR,
        cast(null as varchar) as RISK_OBJECT_CORE__OWNERSHIP_TYPE,
        t0.risk_code as RISK_OBJECT_CORE__RISK_CLASS_CODE,
        t0.risk_description as RISK_OBJECT_CORE__RISK_OBJECT_DESCRIPTION,
        t0.risk_serial_no as RISK_OBJECT_CORE__RISK_OBJECT_REFERENCE_NUMBER,
        cast(null as varchar) as RISK_OBJECT_CORE__RISK_OBJECT_TYPE,
        cast(null as varchar) as RISK_OBJECT_CORE__USAGE_TYPE,
        cast(null as varchar) as RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE_CK,
        cast(null as varchar) as RISK_OBJECT_INSURABLE_INTEREST__INTEREST_HOLDER_REFERENCE_CK,
        cast(null as varchar) as RISK_OBJECT_INSURABLE_INTEREST__FINANCIER_NAME,
        cast(null as varchar) as RISK_OBJECT_INSURABLE_INTEREST__HYPOTHECATION_INDICATOR,
        cast(null as varchar) as RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE,
        cast(null as varchar) as RISK_OBJECT_INSURABLE_INTEREST__LEASE_INDICATOR,
        cast(null as varchar) as RISK_OBJECT_OWNERSHIP_HISTORY__OWNER_SEQUENCE_CK,
        cast(null as varchar) as RISK_OBJECT_OWNERSHIP_HISTORY__OWNERSHIP_FROM_DATE,
        cast(null as varchar) as RISK_OBJECT_OWNERSHIP_HISTORY__OWNER_SEQUENCE,
        t0.rec_refresh_at as REC_REFRESH_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_attr_properties_pv') }} t0
    left join {{ ref('stg_mxm__clm_cd_claim_attr_properties') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_attr') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (coalesce(nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), ''), nullif(nullif(trim(j3.policyno),''), ''), nullif(nullif(trim(t0.stored_product_code),''), ''))) is not null

    union all

    -- branch 1: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK
    select
        null, null, null, null, null, null, null, null, null, null,
        nullif(nullif(trim(t0.riskcode), ''), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.riskdesc as RISK_OBJECT_CORE__RISK_OBJECT_DESCRIPTION,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_risk') }} t0
    where (nullif(nullif(trim(t0.riskcode), ''), '')) is not null

    union all

    -- branch 2: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
    select
        null, null, null, null, null, null, null,
        nullif(nullif(trim(j6.policyno), ''), '') as POLICY_BK,
        null, null,
        nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.total_si_policy_currency as POLICY_HEADER__CURRENCY_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.term_end_date as POLICY_HEADER__RISK_EXPIRY_DATE,
        t0.term_start_date as POLICY_HEADER__RISK_INCEPTION_DATE,
        null, null,
        t0.total_si_amount_in_policy_si_currency as POLICY_HEADER__SUM_INSURED_TOTAL,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.vehicle_purchase_date as RISK_OBJECT_CORE__ACQUISITION_DATE,
        null, null, null, null, null, null, null, null,
        'HYPOTHECATION' as RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE_CK,
        null,
        t0.hypothecation as RISK_OBJECT_INSURABLE_INTEREST__FINANCIER_NAME,
        t0.hp_endorsement_on_rc as RISK_OBJECT_INSURABLE_INTEREST__HYPOTHECATION_INDICATOR,
        null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop_pv') }} t0
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd') }} j6 on j6.KEY_HASH = j5.PARENT_KEY_HASH
    where (coalesce(nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), ''), nullif(nullif(trim(j6.policyno), ''), ''))) is not null

    union all

    -- branch 3: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS
    select
        null, null, null, null, null, null, null,
        nullif(nullif(trim(t0.policy_number),''), '') as POLICY_BK,
        nullif(nullif(trim(t0.product_code),''), '') as PRODUCT_BK,
        nullif(nullif(trim(t0.quotation_number),''), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null,
        1 as __LNK_POLICY_PRODUCT,
        null, null,
        1 as __LNK_QUOTE_PRODUCT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.policy_status as POLICY_HEADER__POLICY_STATUS,
        null,
        t0.policy_duration as POLICY_HEADER__POLICY_TERM,
        null,
        t0.payment_frequency as POLICY_HEADER__PREMIUM_FREQUENCY,
        null,
        t0.product_code as POLICY_HEADER__PRODUCT_REFERENCE,
        null,
        t0.policy_expiry_date as POLICY_HEADER__RISK_EXPIRY_DATE,
        t0.policy_inception_date as POLICY_HEADER__RISK_INCEPTION_DATE,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.product_name as PRODUCT_DEFINITION__PRODUCT_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd') }} t0
    where (coalesce(nullif(nullif(trim(t0.policy_number),''), ''), nullif(nullif(trim(t0.product_code),''), ''), nullif(nullif(trim(t0.quotation_number),''), ''))) is not null

    union all

    -- branch 4: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS
    select
        null, null, null, null, null, null, null,
        nullif(nullif(trim(j1.policy_number), ''), '') as POLICY_BK,
        null, null,
        nullif(nullif(trim(t0.pol_risk_id), ''), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null,
        1 as __LNK_POLICY_RISK_OBJECT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.risk_serial_number as AUG_RISK_OBJECT_CORE__RISK_LINE_SERIAL_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.risk_code as RISK_OBJECT_CORE__RISK_CLASS_CODE,
        t0.risk_desc as RISK_OBJECT_CORE__RISK_OBJECT_DESCRIPTION,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls') }} t0
    left join {{ ref('stg_mxm__uwr_pd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (coalesce(nullif(nullif(trim(j1.policy_number), ''), ''), nullif(nullif(trim(t0.pol_risk_id), ''), ''))) is not null

    union all

    -- branch 5: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(t0.pre_inspection_number),''), '') as ASSESSMENT_BK,
        nullif(coalesce(nullif(trim(t0.cover_code), ''), nullif(trim(t0.covercode), '')), '') as COVERAGE_BK,
        null,
        nullif(nullif(trim(t0.parent_payment_cycle_ref_no),''), '') as FINANCIAL_TRANSACTION_BK,
        null,
        nullif(nullif(trim(t0.branch_code),''), '') as ORG_UNIT_BK,
        nullif(nullif(trim(j4.policy_holder_code), ''), '') as PARTY_BK,
        nullif(nullif(trim(j4.policy_number), ''), '') as POLICY_BK,
        nullif(nullif(trim(j4.product_code),''), '') as PRODUCT_BK,
        null,
        nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), '') as RISK_OBJECT_BK,
        1 as __LNK_ASSESSMENT_PARTY,
        1 as __LNK_FINTXN_PARTY,
        null, null, null, null, null, null, null, null, null, null,
        1 as __LNK_RISK_OBJECT_ASSESSMENT,
        null, null,
        1 as __LNK_RISK_OBJECT_PARTY,
        t0.pin_damage_details as ASSESSMENT_PRE_INSPECTION__EXISTING_DAMAGE_DESCRIPTION,
        t0.pre_inspection_date_and_time as ASSESSMENT_PRE_INSPECTION__INSPECTION_DATE,
        null,
        t0.pin_inspected_by as ASSESSMENT_PRE_INSPECTION__INSPECTOR_REFERENCE,
        t0.cover_level_base_currency as AUG_COVERAGE_MONETARY_CONTEXT__BASE_CURRENCY_CODE,
        t0.forex_rate_at_cover_level as AUG_COVERAGE_MONETARY_CONTEXT__EXCHANGE_RATE,
        t0.cover_level_transaction_currency_for_sum_insured as AUG_COVERAGE_MONETARY_CONTEXT__SUM_INSURED_CURRENCY_CODE,
        t0.cover_level_transaction_currency as AUG_COVERAGE_MONETARY_CONTEXT__TRANSACTION_CURRENCY_CODE,
        null, null, null,
        t0.parent_payment_purpose as AUG_FINTXN_HEADER__PAYMENT_PURPOSE,
        null,
        t0.cluster_code as AUG_ORG_UNIT_DEFINITION__CLUSTER_CODE,
        t0.cluster_name as AUG_ORG_UNIT_DEFINITION__CLUSTER_NAME,
        null, null,
        t0.minimum_deposit_premium_type as AUG_PRODUCT_RATING_STRUCTURE__MINIMUM_DEPOSIT_PREMIUM_TYPE,
        null, null, null, null, null, null, null, null, null,
        t0.od_frequency as AUG_RISK_MOTOR_LOSS_EXPERIENCE__OWN_DAMAGE_CLAIM_FREQUENCY,
        t0.od_severity as AUG_RISK_MOTOR_LOSS_EXPERIENCE__OWN_DAMAGE_CLAIM_SEVERITY,
        t0.od_lr as AUG_RISK_MOTOR_LOSS_EXPERIENCE__OWN_DAMAGE_LOSS_RATIO,
        t0.risk_expiry_time as AUG_RISK_OBJECT_CORE__RISK_COVER_END_TIME,
        t0.risk_expiry_date as AUG_RISK_OBJECT_CORE__RISK_COVER_EXPIRY_DATE,
        t0.risk_inception_date as AUG_RISK_OBJECT_CORE__RISK_COVER_INCEPTION_DATE,
        t0.risk_inception_time as AUG_RISK_OBJECT_CORE__RISK_COVER_START_TIME,
        t0.serial_no as AUG_RISK_OBJECT_CORE__RISK_LINE_SERIAL_NUMBER,
        t0.weather_score as AUG_RISK_OBJECT_CORE__WEATHER_EXPOSURE_SCORE,
        'HYPOTHECATION' as AUG_RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE_CK,
        nullif(trim(t0.hypothecation_institute),'') as AUG_RISK_OBJECT_INSURABLE_INTEREST__INTEREST_HOLDER_REFERENCE_CK,
        t0.hypothecation_type as AUG_RISK_OBJECT_INSURABLE_INTEREST__HYPOTHECATION_TYPE,
        t0.institute as AUG_RISK_OBJECT_INSURABLE_INTEREST__INTEREST_HOLDER_INSTITUTION_NAME,
        null,
        t0.forex_rate_at_risk_level as AUG_RISK_OBJECT_VALUATION__EXCHANGE_RATE,
        null,
        nullif(trim(t0.trailer_registration_no),'') as AUG_RISK_TRAILER__TRAILER_REGISTRATION_NUMBER_CK,
        t0.trailer_towed_by as AUG_RISK_TRAILER__TOWING_VEHICLE_REFERENCE,
        t0.trailer_detail as AUG_RISK_TRAILER__TRAILER_DETAIL_TEXT,
        t0.trailer_total_value as AUG_RISK_TRAILER__TRAILER_TOTAL_VALUE,
        t0.status as COMMON_STATUS__STATUS_CODE,
        t0.sub_status as COMMON_STATUS__SUB_STATUS_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.remarks as POLICY_HEADER__POLICY_REMARKS,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.total_sum_insured as POLICY_HEADER__SUM_INSURED_TOTAL,
        null, null,
        t0.reason_for_nonrenewal as POLICY_RENEWAL__RENEWAL_BLOCK_REASON,
        null,
        t0.renewal_status as POLICY_RENEWAL__RENEWAL_STATUS,
        nullif(trim(t0.tax_invoice_no),'') as POLICY_TAX_INVOICE__INVOICE_NUMBER_CK,
        t0.tax_invoice_no as POLICY_TAX_INVOICE__INVOICE_NUMBER,
        t0.hsnsac_code as PRODUCT_DEFINITION__HSN_SAC_CODE,
        null,
        t0.minimum_deposit_premium_applicable as PRODUCT_RATING_STRUCTURE__DEPOSIT_PREMIUM_INDICATOR,
        t0.minimum_premium as PRODUCT_RATING_STRUCTURE__MINIMUM_PREMIUM,
        t0.vehicle_warranty as RISK_EXTENDED_WARRANTY__WARRANTY_TYPE,
        t0.uw_approved_idv as RISK_MOTOR_IDV__AGREED_IDV,
        t0.cng_kit_idv as RISK_MOTOR_IDV__CNG_KIT_IDV,
        t0.vehicle_idv as RISK_MOTOR_IDV__COMPUTED_IDV,
        t0.side_car_idv as RISK_MOTOR_IDV__SIDE_CAR_IDV,
        t0.insureds_declared_value_idv as RISK_MOTOR_IDV__TOTAL_IDV,
        null, null,
        t0.unit as RISK_OBJECT_CORE__EXPOSURE_UNIT,
        null, null, null,
        t0.vehicle_details as RISK_OBJECT_CORE__RISK_OBJECT_DESCRIPTION,
        t0.uniqueid as RISK_OBJECT_CORE__RISK_OBJECT_REFERENCE_NUMBER,
        t0.risk_type as RISK_OBJECT_CORE__RISK_OBJECT_TYPE,
        t0.purpose_of_use as RISK_OBJECT_CORE__USAGE_TYPE,
        'HYPOTHECATION' as RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE_CK,
        nullif(trim(t0.hypothecation_institute),'') as RISK_OBJECT_INSURABLE_INTEREST__INTEREST_HOLDER_REFERENCE_CK,
        t0.hypothecation_institute as RISK_OBJECT_INSURABLE_INTEREST__FINANCIER_NAME,
        t0.hypothecation_applicable as RISK_OBJECT_INSURABLE_INTEREST__HYPOTHECATION_INDICATOR,
        t0.insured_interest as RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE,
        null,
        nullif(trim(t0.ownership_serial_no),'') as RISK_OBJECT_OWNERSHIP_HISTORY__OWNER_SEQUENCE_CK,
        null,
        t0.ownership_serial_no as RISK_OBJECT_OWNERSHIP_HISTORY__OWNER_SEQUENCE,
        t0.rec_refresh_at as REC_REFRESH_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (coalesce(nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), ''), nullif(coalesce(nullif(trim(t0.cover_code), ''), nullif(trim(t0.covercode), '')), ''), nullif(nullif(trim(j4.policy_holder_code), ''), ''), nullif(nullif(trim(j4.policy_number), ''), ''), nullif(nullif(trim(j4.product_code),''), ''), nullif(nullif(trim(t0.branch_code),''), ''), nullif(nullif(trim(t0.parent_payment_cycle_ref_no),''), ''), nullif(nullif(trim(t0.pre_inspection_number),''), ''))) is not null

    union all

    -- branch 6: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null,
        nullif(nullif(trim(t0.cover_code),''), '') as COVERAGE_BK,
        null, null, null, null, null,
        nullif(nullif(trim(j4.policy_number),''), '') as POLICY_BK,
        null, null,
        nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.person_detail as AUG_COVERAGE_MOTOR_PA_OCCUPANT__OCCUPANT_PERSON_DETAIL_TEXT,
        null,
        t0.main_packages as AUG_COVERAGE_PACKAGE_RATING__MAIN_PACKAGE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'LEASE' as AUG_RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE_CK,
        null, null, null,
        t0.lease_details as AUG_RISK_OBJECT_INSURABLE_INTEREST__LEASE_ARRANGEMENT_DETAIL,
        null, null, null, null, null, null, null, null,
        t0.no_of_persons as COVERAGE_MOTOR_PA_OCCUPANT__NUMBER_OF_PERSONS_COVERED,
        nullif(trim(t0.certificate_number),'') as POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK,
        t0.certificate_number as POLICY_CERTIFICATE__CERTIFICATE_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        'LEASE' as RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE_CK,
        null, null, null, null,
        t0.vehicle_is_leased as RISK_OBJECT_INSURABLE_INTEREST__LEASE_INDICATOR,
        null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (coalesce(nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), ''), nullif(nullif(trim(j4.policy_number),''), ''), nullif(nullif(trim(t0.cover_code),''), ''))) is not null

    union all

    -- branch 7: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_RISK_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null,
        nullif(nullif(trim(t0.cover_code), ''), '') as COVERAGE_BK,
        null, null, null, null, null,
        nullif(coalesce(nullif(trim(t0.policyquote_number),''), nullif(trim(j4.policy_number),'')), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        t0.top_up_packages as AUG_COVERAGE_PACKAGE_RATING__ADD_ON_PACKAGE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.policy_level_transaction_currency as POLICY_HEADER__CURRENCY_CODE,
        null, null, null,
        t0.issuance_source as POLICY_HEADER__POLICY_CHANNEL_TYPE,
        null, null, null, null, null,
        t0.policy_duration as POLICY_HEADER__POLICY_TERM,
        t0.policy_type as POLICY_HEADER__POLICY_TYPE,
        null, null, null,
        t0.policy_expiry_time as POLICY_HEADER__RISK_END_TIME,
        t0.policy_expiry_date as POLICY_HEADER__RISK_EXPIRY_DATE,
        t0.policy_inception_date as POLICY_HEADER__RISK_INCEPTION_DATE,
        t0.policy_inception_time as POLICY_HEADER__RISK_START_TIME,
        null, null,
        t0.policy_tenure as POLICY_LONG_TERM_DETAIL__POLICY_DURATION_YEARS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_ins_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (coalesce(nullif(coalesce(nullif(trim(t0.policyquote_number),''), nullif(trim(j4.policy_number),'')), ''), nullif(nullif(trim(t0.cover_code), ''), ''))) is not null

    union all

    -- branch 8: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(t0.pre_inspection_number), ''), '') as ASSESSMENT_BK,
        null, null, null, null,
        nullif(nullif(trim(t0.branch_code), ''), '') as ORG_UNIT_BK,
        null,
        nullif(nullif(trim(j3.policy_number), ''), '') as POLICY_BK,
        null, null,
        nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.pin_damage_details as ASSESSMENT_PRE_INSPECTION__EXISTING_DAMAGE_DESCRIPTION,
        t0.pre_inspection_date_and_time as ASSESSMENT_PRE_INSPECTION__INSPECTION_DATE,
        t0.select_inspection_address as ASSESSMENT_PRE_INSPECTION__INSPECTION_LOCATION_ADDRESS,
        t0.pin_inspected_by as ASSESSMENT_PRE_INSPECTION__INSPECTOR_REFERENCE,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.branch_address as AUG_ORG_UNIT_DEFINITION__OFFICE_NAME_AND_ADDRESS_TEXT,
        t0.unit as AUG_ORG_UNIT_DEFINITION__OPERATING_UNIT_LABEL,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.risk_serial_no as AUG_RISK_OBJECT_CORE__RISK_LINE_SERIAL_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.policy_level_transaction_currency as POLICY_HEADER__CURRENCY_CODE,
        null,
        t0.main_policy_id as POLICY_HEADER__MASTER_POLICY_REFERENCE,
        t0.policy_holder as POLICY_HEADER__POLICYHOLDER_REFERENCE,
        t0.issuance_source as POLICY_HEADER__POLICY_CHANNEL_TYPE,
        t0.policy_number as POLICY_HEADER__POLICY_NUMBER,
        t0.policy_id as POLICY_HEADER__POLICY_REFERENCE_NUMBER,
        t0.policy_details as POLICY_HEADER__POLICY_REMARKS,
        t0.policy_status as POLICY_HEADER__POLICY_STATUS,
        t0.policy_sub_status as POLICY_HEADER__POLICY_SUB_STATUS,
        t0.policy_duration as POLICY_HEADER__POLICY_TERM,
        t0.policy_type as POLICY_HEADER__POLICY_TYPE,
        t0.payment_frequency as POLICY_HEADER__PREMIUM_FREQUENCY,
        t0.bill_to as POLICY_HEADER__PREMIUM_PAYER_REFERENCE,
        null,
        t0.policy_expiry_time as POLICY_HEADER__RISK_END_TIME,
        t0.policy_expiry_date as POLICY_HEADER__RISK_EXPIRY_DATE,
        t0.policy_inception_date as POLICY_HEADER__RISK_INCEPTION_DATE,
        t0.policy_inception_time as POLICY_HEADER__RISK_START_TIME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.uw_approved_idv as RISK_MOTOR_IDV__AGREED_IDV,
        null, null, null, null,
        t0.vehicle_age_for_idv as RISK_MOTOR_IDV__VEHICLE_AGE,
        null, null,
        t0.new_vehicle as RISK_OBJECT_CORE__NEW_OR_USED_INDICATOR,
        t0.owner_type as RISK_OBJECT_CORE__OWNERSHIP_TYPE,
        t0.risk_code as RISK_OBJECT_CORE__RISK_CLASS_CODE,
        t0.risk_description as RISK_OBJECT_CORE__RISK_OBJECT_DESCRIPTION,
        null,
        t0.risk_type as RISK_OBJECT_CORE__RISK_OBJECT_TYPE,
        null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_policy_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_policy_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (coalesce(nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), ''), nullif(nullif(trim(j3.policy_number), ''), ''), nullif(nullif(trim(t0.branch_code), ''), ''), nullif(nullif(trim(t0.pre_inspection_number), ''), ''))) is not null

    union all

    -- branch 9: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null, null, null, null, null, null,
        nullif(nullif(trim(j3.policy_number), ''), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.coinsurance_applicable as POLICY_HEADER__CO_INSURANCE_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_policy_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_policy_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_number), ''), '')) is not null

    union all

    -- branch 10: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null, null, null, null, null, null,
        nullif(coalesce(nullif(trim(t0.policy_number), ''), nullif(trim(j3.policy_number), '')), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.sum_insured as POLICY_HEADER__SUM_INSURED_TOTAL,
        null, null,
        t0.reason_for_nonrenewal as POLICY_RENEWAL__RENEWAL_BLOCK_REASON,
        null,
        t0.renewal_status as POLICY_RENEWAL__RENEWAL_STATUS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_policy_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_policy_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(coalesce(nullif(trim(t0.policy_number), ''), nullif(trim(j3.policy_number), '')), '')) is not null

    union all

    -- branch 11: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | child-key literal(s): RISK_OBJECT_OWNERSHIP_HISTORY.Owner Sequence=CURRENT_OWNER
    select
        null, null, null, null, null, null, null, null, null, null,
        nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        'CURRENT_OWNER' as RISK_OBJECT_OWNERSHIP_HISTORY__OWNER_SEQUENCE_CK,
        t0.transfer_date as RISK_OBJECT_OWNERSHIP_HISTORY__OWNERSHIP_FROM_DATE,
        null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_policy_prop_sp_pv') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), '')) is not null

    union all

    -- branch 12: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        nullif(nullif(trim(t0.pre_inspection_number), ''), '') as ASSESSMENT_BK,
        null, null, null, null,
        nullif(nullif(trim(t0.branch_code), ''), '') as ORG_UNIT_BK,
        null, null, null,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.pin_damage_details as ASSESSMENT_PRE_INSPECTION__EXISTING_DAMAGE_DESCRIPTION,
        t0.pre_inspection_date_and_time as ASSESSMENT_PRE_INSPECTION__INSPECTION_DATE,
        t0.select_inspection_address as ASSESSMENT_PRE_INSPECTION__INSPECTION_LOCATION_ADDRESS,
        t0.pin_inspected_by as ASSESSMENT_PRE_INSPECTION__INSPECTOR_REFERENCE,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.branch_address as AUG_ORG_UNIT_DEFINITION__OFFICE_NAME_AND_ADDRESS_TEXT,
        t0.unit as AUG_ORG_UNIT_DEFINITION__OPERATING_UNIT_LABEL,
        null, null,
        coalesce(t0.partial_theft_excess, t0.pin_excess_amount, t0.preferred_garage_excess, t0.rally_excess) as AUG_QUOTE_EXCESS_STRUCTURE__EXCESS_AMOUNT,
        t0.pin_excess as AUG_QUOTE_EXCESS_STRUCTURE__EXCESS_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.risk_serial_no as AUG_RISK_OBJECT_CORE__RISK_LINE_SERIAL_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        t0.uw_approved_idv as RISK_MOTOR_IDV__AGREED_IDV,
        null, null, null, null,
        t0.vehicle_age_for_idv as RISK_MOTOR_IDV__VEHICLE_AGE,
        null, null,
        t0.new_vehicle as RISK_OBJECT_CORE__NEW_OR_USED_INDICATOR,
        t0.owner_type as RISK_OBJECT_CORE__OWNERSHIP_TYPE,
        t0.risk_code as RISK_OBJECT_CORE__RISK_CLASS_CODE,
        t0.risk_description as RISK_OBJECT_CORE__RISK_OBJECT_DESCRIPTION,
        null,
        t0.risk_type as RISK_OBJECT_CORE__RISK_OBJECT_TYPE,
        null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (coalesce(nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), ''), nullif(nullif(trim(j3.policy_quote_number), ''), ''), nullif(nullif(trim(t0.branch_code), ''), ''), nullif(nullif(trim(t0.pre_inspection_number), ''), ''))) is not null

    union all

    -- branch 13: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW | child-key literal(s): RISK_OBJECT_OWNERSHIP_HISTORY.Owner Sequence=CURRENT_OWNER
    select
        null, null, null, null, null, null, null, null, null, null,
        nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        'CURRENT_OWNER' as RISK_OBJECT_OWNERSHIP_HISTORY__OWNER_SEQUENCE_CK,
        t0.transfer_date as RISK_OBJECT_OWNERSHIP_HISTORY__OWNERSHIP_FROM_DATE,
        null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    where (nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), '')) is not null

    union all

    -- branch 14: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST
    select
        null, null,
        nullif(nullif(trim(t0.document_id),''), '') as DOCUMENT_BK,
        null,
        nullif(nullif(trim(regexp_replace(upper(nullif(trim(coalesce(t0.addr1,'') || '|' || coalesce(t0.addr2,'') || '|' || coalesce(t0.addr3,'') || '|' || coalesce(t0.city_code,'') || '|' || coalesce(t0.state_code,'') || '|' || coalesce(t0.postal_code,'') || '|' || coalesce(t0.country_code,'')), '||||||')), '[[:space:]]+', ' ')), ''), '') as LOCATION_BK,
        null,
        nullif(nullif(trim(t0.party_code),''), '') as PARTY_BK,
        nullif(nullif(trim(t0.policy_id),''), '') as POLICY_BK,
        null,
        nullif(nullif(trim(j1.policy_quote_number),''), '') as QUOTE_BK,
        nullif(nullif(trim(t0.pol_risk_id),''), '') as RISK_OBJECT_BK,
        null, null,
        1 as __LNK_PARTY_DOCUMENT,
        1 as __LNK_PARTY_LOCATION,
        1 as __LNK_POLICY_DOCUMENT,
        1 as __LNK_POLICY_LOCATION,
        1 as __LNK_POLICY_PARTY,
        null,
        1 as __LNK_POLICY_RISK_OBJECT,
        1 as __LNK_QUOTE_PARTY,
        null,
        1 as __LNK_QUOTE_RISK_OBJECT,
        null,
        1 as __LNK_RISK_OBJECT_DOCUMENT,
        1 as __LNK_RISK_OBJECT_LOCATION,
        1 as __LNK_RISK_OBJECT_PARTY,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        t0.risk_expiry_date as AUG_RISK_OBJECT_CORE__RISK_COVER_EXPIRY_DATE,
        t0.risk_inception_date as AUG_RISK_OBJECT_CORE__RISK_COVER_INCEPTION_DATE,
        null,
        t0.risk_serial_number as AUG_RISK_OBJECT_CORE__RISK_LINE_SERIAL_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.risk_code as RISK_OBJECT_CORE__RISK_CLASS_CODE,
        t0.risk_desc as RISK_OBJECT_CORE__RISK_OBJECT_DESCRIPTION,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    where (coalesce(nullif(nullif(trim(regexp_replace(upper(nullif(trim(coalesce(t0.addr1,'') || '|' || coalesce(t0.addr2,'') || '|' || coalesce(t0.addr3,'') || '|' || coalesce(t0.city_code,'') || '|' || coalesce(t0.state_code,'') || '|' || coalesce(t0.postal_code,'') || '|' || coalesce(t0.country_code,'')), '||||||')), '[[:space:]]+', ' ')), ''), ''), nullif(nullif(trim(j1.policy_quote_number),''), ''), nullif(nullif(trim(t0.document_id),''), ''), nullif(nullif(trim(t0.party_code),''), ''), nullif(nullif(trim(t0.pol_risk_id),''), ''), nullif(nullif(trim(t0.policy_id),''), ''))) is not null

    union all

    -- branch 15: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
    select
        nullif(nullif(trim(t0.pre_inspection_number),''), '') as ASSESSMENT_BK,
        nullif(coalesce(nullif(trim(t0.cover_code), ''), nullif(trim(t0.covercode), '')), '') as COVERAGE_BK,
        null,
        nullif(nullif(trim(t0.parent_payment_cycle_ref_no),''), '') as FINANCIAL_TRANSACTION_BK,
        null,
        nullif(nullif(trim(t0.branch_code),''), '') as ORG_UNIT_BK,
        null, null,
        nullif(nullif(trim(j4.product_code),''), '') as PRODUCT_BK,
        nullif(nullif(trim(j4.policy_quote_number),''), '') as QUOTE_BK,
        nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null,
        1 as __LNK_RISK_OBJECT_ASSESSMENT,
        null, null, null,
        t0.pin_damage_details as ASSESSMENT_PRE_INSPECTION__EXISTING_DAMAGE_DESCRIPTION,
        t0.pre_inspection_date_and_time as ASSESSMENT_PRE_INSPECTION__INSPECTION_DATE,
        null,
        t0.pin_inspected_by as ASSESSMENT_PRE_INSPECTION__INSPECTOR_REFERENCE,
        t0.cover_level_base_currency as AUG_COVERAGE_MONETARY_CONTEXT__BASE_CURRENCY_CODE,
        t0.forex_rate_at_cover_level as AUG_COVERAGE_MONETARY_CONTEXT__EXCHANGE_RATE,
        t0.cover_level_transaction_currency_for_sum_insured as AUG_COVERAGE_MONETARY_CONTEXT__SUM_INSURED_CURRENCY_CODE,
        t0.cover_level_transaction_currency as AUG_COVERAGE_MONETARY_CONTEXT__TRANSACTION_CURRENCY_CODE,
        null, null, null,
        t0.parent_payment_purpose as AUG_FINTXN_HEADER__PAYMENT_PURPOSE,
        t0.premium_collected as AUG_FINTXN_PREMIUM__COLLECTED_PREMIUM_AMOUNT,
        t0.cluster_code as AUG_ORG_UNIT_DEFINITION__CLUSTER_CODE,
        t0.cluster_name as AUG_ORG_UNIT_DEFINITION__CLUSTER_NAME,
        null, null,
        t0.minimum_deposit_premium_type as AUG_PRODUCT_RATING_STRUCTURE__MINIMUM_DEPOSIT_PREMIUM_TYPE,
        null,
        coalesce(t0.addon_excess, t0.battery_theft_excess, t0.compulsory_excess, t0.escalated_excess, t0.excess) as AUG_QUOTE_EXCESS_STRUCTURE__EXCESS_AMOUNT,
        t0.excess_type as AUG_QUOTE_EXCESS_STRUCTURE__EXCESS_TYPE,
        t0.cgst_amount as AUG_QUOTE_TAX_BREAKUP__CGST_AMOUNT,
        t0.exemption_reason as AUG_QUOTE_TAX_BREAKUP__EXEMPTION_REASON,
        t0.consumption_state as AUG_QUOTE_TAX_BREAKUP__PLACE_OF_SUPPLY,
        t0.additional_info_workflow as AUG_QUOTE_UNDERWRITING_WORKFLOW__ADDITIONAL_INFORMATION_TEXT,
        t0.deficiency_status as AUG_QUOTE_UNDERWRITING_WORKFLOW__DEFICIENCY_STATUS,
        t0.approvedrejected_by_uw as AUG_QUOTE_UNDERWRITING_WORKFLOW__UNDERWRITER_ACCEPTANCE_DECISION,
        t0.od_frequency as AUG_RISK_MOTOR_LOSS_EXPERIENCE__OWN_DAMAGE_CLAIM_FREQUENCY,
        t0.od_severity as AUG_RISK_MOTOR_LOSS_EXPERIENCE__OWN_DAMAGE_CLAIM_SEVERITY,
        t0.od_lr as AUG_RISK_MOTOR_LOSS_EXPERIENCE__OWN_DAMAGE_LOSS_RATIO,
        null, null,
        t0.risk_inception_date as AUG_RISK_OBJECT_CORE__RISK_COVER_INCEPTION_DATE,
        null,
        t0.serial_no as AUG_RISK_OBJECT_CORE__RISK_LINE_SERIAL_NUMBER,
        t0.weather_score as AUG_RISK_OBJECT_CORE__WEATHER_EXPOSURE_SCORE,
        'HYPOTHECATION' as AUG_RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE_CK,
        nullif(trim(t0.hypothecation_institute),'') as AUG_RISK_OBJECT_INSURABLE_INTEREST__INTEREST_HOLDER_REFERENCE_CK,
        t0.hypothecation_type as AUG_RISK_OBJECT_INSURABLE_INTEREST__HYPOTHECATION_TYPE,
        t0.institute as AUG_RISK_OBJECT_INSURABLE_INTEREST__INTEREST_HOLDER_INSTITUTION_NAME,
        null,
        t0.forex_rate_at_risk_level as AUG_RISK_OBJECT_VALUATION__EXCHANGE_RATE,
        null,
        nullif(trim(t0.trailer_registration_no),'') as AUG_RISK_TRAILER__TRAILER_REGISTRATION_NUMBER_CK,
        t0.trailer_towed_by as AUG_RISK_TRAILER__TOWING_VEHICLE_REFERENCE,
        t0.trailer_detail as AUG_RISK_TRAILER__TRAILER_DETAIL_TEXT,
        t0.trailer_total_value as AUG_RISK_TRAILER__TRAILER_TOTAL_VALUE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.hsnsac_code as PRODUCT_DEFINITION__HSN_SAC_CODE,
        null,
        t0.minimum_deposit_premium_applicable as PRODUCT_RATING_STRUCTURE__DEPOSIT_PREMIUM_INDICATOR,
        t0.minimum_premium as PRODUCT_RATING_STRUCTURE__MINIMUM_PREMIUM,
        t0.vehicle_warranty as RISK_EXTENDED_WARRANTY__WARRANTY_TYPE,
        t0.uw_approved_idv as RISK_MOTOR_IDV__AGREED_IDV,
        t0.cng_kit_idv as RISK_MOTOR_IDV__CNG_KIT_IDV,
        t0.vehicle_idv as RISK_MOTOR_IDV__COMPUTED_IDV,
        t0.side_car_idv as RISK_MOTOR_IDV__SIDE_CAR_IDV,
        t0.insureds_declared_value_idv as RISK_MOTOR_IDV__TOTAL_IDV,
        null, null,
        t0.unit as RISK_OBJECT_CORE__EXPOSURE_UNIT,
        null, null, null,
        t0.vehicle_details as RISK_OBJECT_CORE__RISK_OBJECT_DESCRIPTION,
        t0.uniqueid as RISK_OBJECT_CORE__RISK_OBJECT_REFERENCE_NUMBER,
        t0.risk_type as RISK_OBJECT_CORE__RISK_OBJECT_TYPE,
        t0.purpose_of_use as RISK_OBJECT_CORE__USAGE_TYPE,
        'HYPOTHECATION' as RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE_CK,
        nullif(trim(t0.hypothecation_institute),'') as RISK_OBJECT_INSURABLE_INTEREST__INTEREST_HOLDER_REFERENCE_CK,
        t0.hypothecation_institute as RISK_OBJECT_INSURABLE_INTEREST__FINANCIER_NAME,
        t0.hypothecation_applicable as RISK_OBJECT_INSURABLE_INTEREST__HYPOTHECATION_INDICATOR,
        t0.insured_interest as RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE,
        null,
        nullif(trim(t0.ownership_serial_no),'') as RISK_OBJECT_OWNERSHIP_HISTORY__OWNER_SEQUENCE_CK,
        null,
        t0.ownership_serial_no as RISK_OBJECT_OWNERSHIP_HISTORY__OWNER_SEQUENCE,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (coalesce(nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), ''), nullif(coalesce(nullif(trim(t0.cover_code), ''), nullif(trim(t0.covercode), '')), ''), nullif(nullif(trim(j4.policy_quote_number),''), ''), nullif(nullif(trim(j4.product_code),''), ''), nullif(nullif(trim(t0.branch_code),''), ''), nullif(nullif(trim(t0.parent_payment_cycle_ref_no),''), ''), nullif(nullif(trim(t0.pre_inspection_number),''), ''))) is not null

    union all

    -- branch 16: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null,
        nullif(nullif(trim(t0.cover_code),''), '') as COVERAGE_BK,
        null, null, null, null, null, null, null, null,
        nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), '') as RISK_OBJECT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.person_detail as AUG_COVERAGE_MOTOR_PA_OCCUPANT__OCCUPANT_PERSON_DETAIL_TEXT,
        null,
        t0.main_packages as AUG_COVERAGE_PACKAGE_RATING__MAIN_PACKAGE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'LEASE' as AUG_RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE_CK,
        null, null, null,
        t0.lease_details as AUG_RISK_OBJECT_INSURABLE_INTEREST__LEASE_ARRANGEMENT_DETAIL,
        null, null, null, null, null, null, null, null,
        t0.no_of_persons as COVERAGE_MOTOR_PA_OCCUPANT__NUMBER_OF_PERSONS_COVERED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        'LEASE' as RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE_CK,
        null, null, null, null,
        t0.vehicle_is_leased as RISK_OBJECT_INSURABLE_INTEREST__LEASE_INDICATOR,
        null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list_pv') }} t0
    where (coalesce(nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), ''), nullif(nullif(trim(t0.cover_code),''), ''))) is not null

    union all

    -- branch 17: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null,
        nullif(nullif(trim(t0.cover_code), ''), '') as COVERAGE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.top_up_packages as AUG_COVERAGE_PACKAGE_RATING__ADD_ON_PACKAGE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list_pv') }} t0
    where (nullif(nullif(trim(t0.cover_code), ''), '')) is not null

    union all

    -- branch 18: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW | child-key literal(s): AUG_QUOTE_EXCESS_STRUCTURE.Excess Code=IMPOSED
    select
        null, null, null, null, null, null, null, null, null,
        nullif(coalesce(nullif(trim(t0.policyquote_number),''), nullif(trim(j4.policy_quote_number),'')), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        'IMPOSED' as AUG_QUOTE_EXCESS_STRUCTURE__EXCESS_CODE_CK,
        t0.imposed_excess_rs as AUG_QUOTE_EXCESS_STRUCTURE__EXCESS_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(coalesce(nullif(trim(t0.policyquote_number),''), nullif(trim(j4.policy_quote_number),'')), '')) is not null

    union all

    -- branch 19: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW | child-key literal(s): AUG_QUOTE_EXCESS_STRUCTURE.Excess Code=PARTIAL_THEFT
    select
        null, null, null, null, null, null, null, null, null,
        nullif(coalesce(nullif(trim(t0.policyquote_number),''), nullif(trim(j4.policy_quote_number),'')), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        'PARTIAL_THEFT' as AUG_QUOTE_EXCESS_STRUCTURE__EXCESS_CODE_CK,
        t0.partial_theft_excess as AUG_QUOTE_EXCESS_STRUCTURE__EXCESS_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(coalesce(nullif(trim(t0.policyquote_number),''), nullif(trim(j4.policy_quote_number),'')), '')) is not null

    union all

    -- branch 20: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW | child-key literal(s): AUG_QUOTE_EXCESS_STRUCTURE.Excess Code=POLICY
    select
        null, null, null, null, null, null, null, null, null,
        nullif(coalesce(nullif(trim(t0.policyquote_number),''), nullif(trim(j4.policy_quote_number),'')), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        'POLICY' as AUG_QUOTE_EXCESS_STRUCTURE__EXCESS_CODE_CK,
        t0.policy_excess_rs as AUG_QUOTE_EXCESS_STRUCTURE__EXCESS_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(coalesce(nullif(trim(t0.policyquote_number),''), nullif(trim(j4.policy_quote_number),'')), '')) is not null

    union all

    -- branch 21: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW | child-key literal(s): AUG_QUOTE_EXCESS_STRUCTURE.Excess Code=PREFERRED_GARAGE
    select
        null, null, null, null, null, null, null, null, null,
        nullif(coalesce(nullif(trim(t0.policyquote_number),''), nullif(trim(j4.policy_quote_number),'')), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        'PREFERRED_GARAGE' as AUG_QUOTE_EXCESS_STRUCTURE__EXCESS_CODE_CK,
        t0.preferred_garage_excess as AUG_QUOTE_EXCESS_STRUCTURE__EXCESS_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(coalesce(nullif(trim(t0.policyquote_number),''), nullif(trim(j4.policy_quote_number),'')), '')) is not null

    union all

    -- branch 22: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_RISK_LIST_RISK_PROPERTY_RULE_LIST_PIVOT_VW | child-key literal(s): AUG_QUOTE_EXCESS_STRUCTURE.Excess Code=RALLY
    select
        null, null, null, null, null, null, null, null, null,
        nullif(coalesce(nullif(trim(t0.policyquote_number),''), nullif(trim(j4.policy_quote_number),'')), '') as QUOTE_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        'RALLY' as AUG_QUOTE_EXCESS_STRUCTURE__EXCESS_CODE_CK,
        t0.rally_excess as AUG_QUOTE_EXCESS_STRUCTURE__EXCESS_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list_risk_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_risk_list') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (nullif(coalesce(nullif(trim(t0.policyquote_number),''), nullif(trim(j4.policy_quote_number),'')), '')) is not null

)

select
    ASSESSMENT_BK,
    COVERAGE_BK,
    DOCUMENT_BK,
    FINANCIAL_TRANSACTION_BK,
    LOCATION_BK,
    ORG_UNIT_BK,
    PARTY_BK,
    POLICY_BK,
    PRODUCT_BK,
    QUOTE_BK,
    RISK_OBJECT_BK,
    __LNK_ASSESSMENT_PARTY,
    __LNK_FINTXN_PARTY,
    __LNK_PARTY_DOCUMENT,
    __LNK_PARTY_LOCATION,
    __LNK_POLICY_DOCUMENT,
    __LNK_POLICY_LOCATION,
    __LNK_POLICY_PARTY,
    __LNK_POLICY_PRODUCT,
    __LNK_POLICY_RISK_OBJECT,
    __LNK_QUOTE_PARTY,
    __LNK_QUOTE_PRODUCT,
    __LNK_QUOTE_RISK_OBJECT,
    __LNK_RISK_OBJECT_ASSESSMENT,
    __LNK_RISK_OBJECT_DOCUMENT,
    __LNK_RISK_OBJECT_LOCATION,
    __LNK_RISK_OBJECT_PARTY,
    first_value(ASSESSMENT_PRE_INSPECTION__EXISTING_DAMAGE_DESCRIPTION) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_PRE_INSPECTION__EXISTING_DAMAGE_DESCRIPTION,
    first_value(ASSESSMENT_PRE_INSPECTION__INSPECTION_DATE) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_PRE_INSPECTION__INSPECTION_DATE,
    first_value(ASSESSMENT_PRE_INSPECTION__INSPECTION_LOCATION_ADDRESS) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_PRE_INSPECTION__INSPECTION_LOCATION_ADDRESS,
    first_value(ASSESSMENT_PRE_INSPECTION__INSPECTOR_REFERENCE) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_PRE_INSPECTION__INSPECTOR_REFERENCE,
    first_value(AUG_COVERAGE_MONETARY_CONTEXT__BASE_CURRENCY_CODE) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_MONETARY_CONTEXT__BASE_CURRENCY_CODE,
    first_value(AUG_COVERAGE_MONETARY_CONTEXT__EXCHANGE_RATE) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_MONETARY_CONTEXT__EXCHANGE_RATE,
    first_value(AUG_COVERAGE_MONETARY_CONTEXT__SUM_INSURED_CURRENCY_CODE) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_MONETARY_CONTEXT__SUM_INSURED_CURRENCY_CODE,
    first_value(AUG_COVERAGE_MONETARY_CONTEXT__TRANSACTION_CURRENCY_CODE) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_MONETARY_CONTEXT__TRANSACTION_CURRENCY_CODE,
    first_value(AUG_COVERAGE_MOTOR_PA_OCCUPANT__OCCUPANT_PERSON_DETAIL_TEXT) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_MOTOR_PA_OCCUPANT__OCCUPANT_PERSON_DETAIL_TEXT,
    first_value(AUG_COVERAGE_PACKAGE_RATING__ADD_ON_PACKAGE_CODE) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_PACKAGE_RATING__ADD_ON_PACKAGE_CODE,
    first_value(AUG_COVERAGE_PACKAGE_RATING__MAIN_PACKAGE_CODE) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COVERAGE_PACKAGE_RATING__MAIN_PACKAGE_CODE,
    first_value(AUG_FINTXN_HEADER__PAYMENT_PURPOSE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_HEADER__PAYMENT_PURPOSE,
    first_value(AUG_FINTXN_PREMIUM__COLLECTED_PREMIUM_AMOUNT) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FINTXN_PREMIUM__COLLECTED_PREMIUM_AMOUNT,
    first_value(AUG_ORG_UNIT_DEFINITION__CLUSTER_CODE) ignore nulls over (partition by ORG_UNIT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ORG_UNIT_DEFINITION__CLUSTER_CODE,
    first_value(AUG_ORG_UNIT_DEFINITION__CLUSTER_NAME) ignore nulls over (partition by ORG_UNIT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ORG_UNIT_DEFINITION__CLUSTER_NAME,
    first_value(AUG_ORG_UNIT_DEFINITION__OFFICE_NAME_AND_ADDRESS_TEXT) ignore nulls over (partition by ORG_UNIT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ORG_UNIT_DEFINITION__OFFICE_NAME_AND_ADDRESS_TEXT,
    first_value(AUG_ORG_UNIT_DEFINITION__OPERATING_UNIT_LABEL) ignore nulls over (partition by ORG_UNIT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ORG_UNIT_DEFINITION__OPERATING_UNIT_LABEL,
    first_value(AUG_PRODUCT_RATING_STRUCTURE__MINIMUM_DEPOSIT_PREMIUM_TYPE) ignore nulls over (partition by PRODUCT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_RATING_STRUCTURE__MINIMUM_DEPOSIT_PREMIUM_TYPE,
    AUG_QUOTE_EXCESS_STRUCTURE__EXCESS_CODE_CK,
    first_value(AUG_QUOTE_EXCESS_STRUCTURE__EXCESS_AMOUNT) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_EXCESS_STRUCTURE__EXCESS_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_EXCESS_STRUCTURE__EXCESS_AMOUNT,
    first_value(AUG_QUOTE_EXCESS_STRUCTURE__EXCESS_TYPE) ignore nulls over (partition by QUOTE_BK, AUG_QUOTE_EXCESS_STRUCTURE__EXCESS_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_EXCESS_STRUCTURE__EXCESS_TYPE,
    first_value(AUG_QUOTE_TAX_BREAKUP__CGST_AMOUNT) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_TAX_BREAKUP__CGST_AMOUNT,
    first_value(AUG_QUOTE_TAX_BREAKUP__EXEMPTION_REASON) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_TAX_BREAKUP__EXEMPTION_REASON,
    first_value(AUG_QUOTE_TAX_BREAKUP__PLACE_OF_SUPPLY) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_TAX_BREAKUP__PLACE_OF_SUPPLY,
    first_value(AUG_QUOTE_UNDERWRITING_WORKFLOW__ADDITIONAL_INFORMATION_TEXT) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_UNDERWRITING_WORKFLOW__ADDITIONAL_INFORMATION_TEXT,
    first_value(AUG_QUOTE_UNDERWRITING_WORKFLOW__DEFICIENCY_STATUS) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_UNDERWRITING_WORKFLOW__DEFICIENCY_STATUS,
    first_value(AUG_QUOTE_UNDERWRITING_WORKFLOW__UNDERWRITER_ACCEPTANCE_DECISION) ignore nulls over (partition by QUOTE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_QUOTE_UNDERWRITING_WORKFLOW__UNDERWRITER_ACCEPTANCE_DECISION,
    first_value(AUG_RISK_MOTOR_LOSS_EXPERIENCE__OWN_DAMAGE_CLAIM_FREQUENCY) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_LOSS_EXPERIENCE__OWN_DAMAGE_CLAIM_FREQUENCY,
    first_value(AUG_RISK_MOTOR_LOSS_EXPERIENCE__OWN_DAMAGE_CLAIM_SEVERITY) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_LOSS_EXPERIENCE__OWN_DAMAGE_CLAIM_SEVERITY,
    first_value(AUG_RISK_MOTOR_LOSS_EXPERIENCE__OWN_DAMAGE_LOSS_RATIO) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_LOSS_EXPERIENCE__OWN_DAMAGE_LOSS_RATIO,
    first_value(AUG_RISK_OBJECT_CORE__RISK_COVER_END_TIME) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_OBJECT_CORE__RISK_COVER_END_TIME,
    first_value(AUG_RISK_OBJECT_CORE__RISK_COVER_EXPIRY_DATE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_OBJECT_CORE__RISK_COVER_EXPIRY_DATE,
    first_value(AUG_RISK_OBJECT_CORE__RISK_COVER_INCEPTION_DATE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_OBJECT_CORE__RISK_COVER_INCEPTION_DATE,
    first_value(AUG_RISK_OBJECT_CORE__RISK_COVER_START_TIME) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_OBJECT_CORE__RISK_COVER_START_TIME,
    first_value(AUG_RISK_OBJECT_CORE__RISK_LINE_SERIAL_NUMBER) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_OBJECT_CORE__RISK_LINE_SERIAL_NUMBER,
    first_value(AUG_RISK_OBJECT_CORE__WEATHER_EXPOSURE_SCORE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_OBJECT_CORE__WEATHER_EXPOSURE_SCORE,
    AUG_RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE_CK,
    AUG_RISK_OBJECT_INSURABLE_INTEREST__INTEREST_HOLDER_REFERENCE_CK,
    first_value(AUG_RISK_OBJECT_INSURABLE_INTEREST__HYPOTHECATION_TYPE) ignore nulls over (partition by RISK_OBJECT_BK, AUG_RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE_CK, AUG_RISK_OBJECT_INSURABLE_INTEREST__INTEREST_HOLDER_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_OBJECT_INSURABLE_INTEREST__HYPOTHECATION_TYPE,
    first_value(AUG_RISK_OBJECT_INSURABLE_INTEREST__INTEREST_HOLDER_INSTITUTION_NAME) ignore nulls over (partition by RISK_OBJECT_BK, AUG_RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE_CK, AUG_RISK_OBJECT_INSURABLE_INTEREST__INTEREST_HOLDER_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_OBJECT_INSURABLE_INTEREST__INTEREST_HOLDER_INSTITUTION_NAME,
    first_value(AUG_RISK_OBJECT_INSURABLE_INTEREST__LEASE_ARRANGEMENT_DETAIL) ignore nulls over (partition by RISK_OBJECT_BK, AUG_RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE_CK, AUG_RISK_OBJECT_INSURABLE_INTEREST__INTEREST_HOLDER_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_OBJECT_INSURABLE_INTEREST__LEASE_ARRANGEMENT_DETAIL,
    first_value(AUG_RISK_OBJECT_VALUATION__EXCHANGE_RATE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_OBJECT_VALUATION__EXCHANGE_RATE,
    AUG_RISK_TRAILER__TRAILER_SEQUENCE_CK,
    AUG_RISK_TRAILER__TRAILER_REGISTRATION_NUMBER_CK,
    first_value(AUG_RISK_TRAILER__TOWING_VEHICLE_REFERENCE) ignore nulls over (partition by RISK_OBJECT_BK, AUG_RISK_TRAILER__TRAILER_SEQUENCE_CK, AUG_RISK_TRAILER__TRAILER_REGISTRATION_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_TRAILER__TOWING_VEHICLE_REFERENCE,
    first_value(AUG_RISK_TRAILER__TRAILER_DETAIL_TEXT) ignore nulls over (partition by RISK_OBJECT_BK, AUG_RISK_TRAILER__TRAILER_SEQUENCE_CK, AUG_RISK_TRAILER__TRAILER_REGISTRATION_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_TRAILER__TRAILER_DETAIL_TEXT,
    first_value(AUG_RISK_TRAILER__TRAILER_TOTAL_VALUE) ignore nulls over (partition by RISK_OBJECT_BK, AUG_RISK_TRAILER__TRAILER_SEQUENCE_CK, AUG_RISK_TRAILER__TRAILER_REGISTRATION_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_TRAILER__TRAILER_TOTAL_VALUE,
    first_value(COMMON_STATUS__STATUS_CODE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_STATUS__STATUS_CODE,
    first_value(COMMON_STATUS__SUB_STATUS_CODE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_STATUS__SUB_STATUS_CODE,
    first_value(COVERAGE_MOTOR_PA_OCCUPANT__NUMBER_OF_PERSONS_COVERED) ignore nulls over (partition by COVERAGE_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COVERAGE_MOTOR_PA_OCCUPANT__NUMBER_OF_PERSONS_COVERED,
    POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK,
    first_value(POLICY_CERTIFICATE__CERTIFICATE_NUMBER) ignore nulls over (partition by POLICY_BK, POLICY_CERTIFICATE__CERTIFICATE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_CERTIFICATE__CERTIFICATE_NUMBER,
    first_value(POLICY_HEADER__COVER_NOTE_REFERENCE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__COVER_NOTE_REFERENCE,
    first_value(POLICY_HEADER__CO_INSURANCE_INDICATOR) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__CO_INSURANCE_INDICATOR,
    first_value(POLICY_HEADER__CURRENCY_CODE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__CURRENCY_CODE,
    first_value(POLICY_HEADER__LINE_OF_BUSINESS) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__LINE_OF_BUSINESS,
    first_value(POLICY_HEADER__MASTER_POLICY_REFERENCE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__MASTER_POLICY_REFERENCE,
    first_value(POLICY_HEADER__POLICYHOLDER_REFERENCE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__POLICYHOLDER_REFERENCE,
    first_value(POLICY_HEADER__POLICY_CHANNEL_TYPE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__POLICY_CHANNEL_TYPE,
    first_value(POLICY_HEADER__POLICY_NUMBER) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__POLICY_NUMBER,
    first_value(POLICY_HEADER__POLICY_REFERENCE_NUMBER) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__POLICY_REFERENCE_NUMBER,
    first_value(POLICY_HEADER__POLICY_REMARKS) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__POLICY_REMARKS,
    first_value(POLICY_HEADER__POLICY_STATUS) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__POLICY_STATUS,
    first_value(POLICY_HEADER__POLICY_SUB_STATUS) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__POLICY_SUB_STATUS,
    first_value(POLICY_HEADER__POLICY_TERM) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__POLICY_TERM,
    first_value(POLICY_HEADER__POLICY_TYPE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__POLICY_TYPE,
    first_value(POLICY_HEADER__PREMIUM_FREQUENCY) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__PREMIUM_FREQUENCY,
    first_value(POLICY_HEADER__PREMIUM_PAYER_REFERENCE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__PREMIUM_PAYER_REFERENCE,
    first_value(POLICY_HEADER__PRODUCT_REFERENCE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__PRODUCT_REFERENCE,
    first_value(POLICY_HEADER__RISK_END_TIME) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__RISK_END_TIME,
    first_value(POLICY_HEADER__RISK_EXPIRY_DATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__RISK_EXPIRY_DATE,
    first_value(POLICY_HEADER__RISK_INCEPTION_DATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__RISK_INCEPTION_DATE,
    first_value(POLICY_HEADER__RISK_START_TIME) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__RISK_START_TIME,
    first_value(POLICY_HEADER__SERVICING_ORG_UNIT_CODE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__SERVICING_ORG_UNIT_CODE,
    first_value(POLICY_HEADER__SUM_INSURED_TOTAL) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_HEADER__SUM_INSURED_TOTAL,
    first_value(POLICY_LONG_TERM_DETAIL__POLICY_DURATION_YEARS) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_LONG_TERM_DETAIL__POLICY_DURATION_YEARS,
    first_value(POLICY_RENEWAL__BREAK_IN_INDICATOR) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_RENEWAL__BREAK_IN_INDICATOR,
    first_value(POLICY_RENEWAL__RENEWAL_BLOCK_REASON) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_RENEWAL__RENEWAL_BLOCK_REASON,
    first_value(POLICY_RENEWAL__RENEWAL_DUE_DATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_RENEWAL__RENEWAL_DUE_DATE,
    first_value(POLICY_RENEWAL__RENEWAL_STATUS) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_RENEWAL__RENEWAL_STATUS,
    POLICY_TAX_INVOICE__INVOICE_NUMBER_CK,
    first_value(POLICY_TAX_INVOICE__INVOICE_NUMBER) ignore nulls over (partition by POLICY_BK, POLICY_TAX_INVOICE__INVOICE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_TAX_INVOICE__INVOICE_NUMBER,
    first_value(PRODUCT_DEFINITION__HSN_SAC_CODE) ignore nulls over (partition by PRODUCT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PRODUCT_DEFINITION__HSN_SAC_CODE,
    first_value(PRODUCT_DEFINITION__PRODUCT_NAME) ignore nulls over (partition by PRODUCT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PRODUCT_DEFINITION__PRODUCT_NAME,
    first_value(PRODUCT_RATING_STRUCTURE__DEPOSIT_PREMIUM_INDICATOR) ignore nulls over (partition by PRODUCT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PRODUCT_RATING_STRUCTURE__DEPOSIT_PREMIUM_INDICATOR,
    first_value(PRODUCT_RATING_STRUCTURE__MINIMUM_PREMIUM) ignore nulls over (partition by PRODUCT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PRODUCT_RATING_STRUCTURE__MINIMUM_PREMIUM,
    first_value(RISK_EXTENDED_WARRANTY__WARRANTY_TYPE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_EXTENDED_WARRANTY__WARRANTY_TYPE,
    first_value(RISK_MOTOR_IDV__AGREED_IDV) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_IDV__AGREED_IDV,
    first_value(RISK_MOTOR_IDV__CNG_KIT_IDV) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_IDV__CNG_KIT_IDV,
    first_value(RISK_MOTOR_IDV__COMPUTED_IDV) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_IDV__COMPUTED_IDV,
    first_value(RISK_MOTOR_IDV__SIDE_CAR_IDV) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_IDV__SIDE_CAR_IDV,
    first_value(RISK_MOTOR_IDV__TOTAL_IDV) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_IDV__TOTAL_IDV,
    first_value(RISK_MOTOR_IDV__VEHICLE_AGE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_IDV__VEHICLE_AGE,
    first_value(RISK_OBJECT_CORE__ACQUISITION_DATE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_OBJECT_CORE__ACQUISITION_DATE,
    first_value(RISK_OBJECT_CORE__EXPOSURE_UNIT) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_OBJECT_CORE__EXPOSURE_UNIT,
    first_value(RISK_OBJECT_CORE__NEW_OR_USED_INDICATOR) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_OBJECT_CORE__NEW_OR_USED_INDICATOR,
    first_value(RISK_OBJECT_CORE__OWNERSHIP_TYPE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_OBJECT_CORE__OWNERSHIP_TYPE,
    first_value(RISK_OBJECT_CORE__RISK_CLASS_CODE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_OBJECT_CORE__RISK_CLASS_CODE,
    first_value(RISK_OBJECT_CORE__RISK_OBJECT_DESCRIPTION) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_OBJECT_CORE__RISK_OBJECT_DESCRIPTION,
    first_value(RISK_OBJECT_CORE__RISK_OBJECT_REFERENCE_NUMBER) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_OBJECT_CORE__RISK_OBJECT_REFERENCE_NUMBER,
    first_value(RISK_OBJECT_CORE__RISK_OBJECT_TYPE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_OBJECT_CORE__RISK_OBJECT_TYPE,
    first_value(RISK_OBJECT_CORE__USAGE_TYPE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_OBJECT_CORE__USAGE_TYPE,
    RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE_CK,
    RISK_OBJECT_INSURABLE_INTEREST__INTEREST_HOLDER_REFERENCE_CK,
    first_value(RISK_OBJECT_INSURABLE_INTEREST__FINANCIER_NAME) ignore nulls over (partition by RISK_OBJECT_BK, RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE_CK, RISK_OBJECT_INSURABLE_INTEREST__INTEREST_HOLDER_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_OBJECT_INSURABLE_INTEREST__FINANCIER_NAME,
    first_value(RISK_OBJECT_INSURABLE_INTEREST__HYPOTHECATION_INDICATOR) ignore nulls over (partition by RISK_OBJECT_BK, RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE_CK, RISK_OBJECT_INSURABLE_INTEREST__INTEREST_HOLDER_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_OBJECT_INSURABLE_INTEREST__HYPOTHECATION_INDICATOR,
    first_value(RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE) ignore nulls over (partition by RISK_OBJECT_BK, RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE_CK, RISK_OBJECT_INSURABLE_INTEREST__INTEREST_HOLDER_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE,
    first_value(RISK_OBJECT_INSURABLE_INTEREST__LEASE_INDICATOR) ignore nulls over (partition by RISK_OBJECT_BK, RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE_CK, RISK_OBJECT_INSURABLE_INTEREST__INTEREST_HOLDER_REFERENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_OBJECT_INSURABLE_INTEREST__LEASE_INDICATOR,
    RISK_OBJECT_OWNERSHIP_HISTORY__OWNER_SEQUENCE_CK,
    first_value(RISK_OBJECT_OWNERSHIP_HISTORY__OWNERSHIP_FROM_DATE) ignore nulls over (partition by RISK_OBJECT_BK, RISK_OBJECT_OWNERSHIP_HISTORY__OWNER_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_OBJECT_OWNERSHIP_HISTORY__OWNERSHIP_FROM_DATE,
    first_value(RISK_OBJECT_OWNERSHIP_HISTORY__OWNER_SEQUENCE) ignore nulls over (partition by RISK_OBJECT_BK, RISK_OBJECT_OWNERSHIP_HISTORY__OWNER_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_OBJECT_OWNERSHIP_HISTORY__OWNER_SEQUENCE,
    -- the row's own source time: LOAD_DATETIME for hubs, links and single-active satellites
    m.REC_REFRESH_AT,
    -- multi-active satellites on POLICY_BK (SAT_POLICY_CERTIFICATE, SAT_POLICY_TAX_INVOICE):
    -- one load time per POLICY_BK, the newest REC_REFRESH_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when coalesce(m.POLICY_CERTIFICATE__CERTIFICATE_NUMBER, m.POLICY_TAX_INVOICE__INVOICE_NUMBER) is not null
             then m.REC_REFRESH_AT end)
        over (partition by m.POLICY_BK) as POLICY_BK__MA_LOAD_DATETIME,
    -- multi-active satellites on QUOTE_BK (SAT_MOTOR_AUG_QUOTE_EXCESS_STRUCTURE):
    -- one load time per QUOTE_BK, the newest REC_REFRESH_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when coalesce(m.AUG_QUOTE_EXCESS_STRUCTURE__EXCESS_AMOUNT, m.AUG_QUOTE_EXCESS_STRUCTURE__EXCESS_TYPE) is not null
             then m.REC_REFRESH_AT end)
        over (partition by m.QUOTE_BK) as QUOTE_BK__MA_LOAD_DATETIME,
    -- multi-active satellites on RISK_OBJECT_BK (SAT_MOTOR_AUG_RISK_OBJECT_INSURABLE_INTEREST, SAT_MOTOR_AUG_RISK_TRAILER, SAT_RISK_OBJECT_INSURABLE_INTEREST, SAT_RISK_OBJECT_OWNERSHIP_HISTORY):
    -- one load time per RISK_OBJECT_BK, the newest REC_REFRESH_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when coalesce(m.AUG_RISK_OBJECT_INSURABLE_INTEREST__HYPOTHECATION_TYPE, m.AUG_RISK_OBJECT_INSURABLE_INTEREST__INTEREST_HOLDER_INSTITUTION_NAME, m.AUG_RISK_OBJECT_INSURABLE_INTEREST__LEASE_ARRANGEMENT_DETAIL, m.AUG_RISK_TRAILER__TOWING_VEHICLE_REFERENCE, m.AUG_RISK_TRAILER__TRAILER_DETAIL_TEXT, m.AUG_RISK_TRAILER__TRAILER_TOTAL_VALUE, m.RISK_OBJECT_INSURABLE_INTEREST__FINANCIER_NAME, m.RISK_OBJECT_INSURABLE_INTEREST__HYPOTHECATION_INDICATOR, m.RISK_OBJECT_INSURABLE_INTEREST__INTEREST_TYPE, m.RISK_OBJECT_INSURABLE_INTEREST__LEASE_INDICATOR, m.RISK_OBJECT_OWNERSHIP_HISTORY__OWNERSHIP_FROM_DATE, m.RISK_OBJECT_OWNERSHIP_HISTORY__OWNER_SEQUENCE) is not null
             then m.REC_REFRESH_AT end)
        over (partition by m.RISK_OBJECT_BK) as RISK_OBJECT_BK__MA_LOAD_DATETIME
from merged m
