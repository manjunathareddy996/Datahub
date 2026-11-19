-- CENTRAL VIEW v09_party -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_PARTY
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_PAYMENT_PAYMENTPROPERTY_PIVOT_VW
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_PARTY
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PAYMENT_INFORMATION
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
-- Walk tables, joined only to resolve spine keys (not counted):
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_PAYMENT
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_PAYMENT_PAYMENTPROPERTY
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL
--   MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_MULTI_SET_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY
--   MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_ASSESSMENT_REINSPECTION
--   SAT_MOTOR_AUG_ASSESSMENT_REINSPECTION
--   SAT_MOTOR_AUG_CLAIM_EXCESS_HEAD
--   SAT_MOTOR_AUG_CLAIM_PAYMENT_TRANCHE
--   SAT_MOTOR_AUG_CLAIM_RECOVERY_EXPENSE_LINE
--   SAT_MOTOR_AUG_CLAIM_RECOVERY_SALVAGE
--   SAT_MOTOR_AUG_CLAIM_TAT_BREACH
--   SAT_MOTOR_AUG_CLAIM_THIRD_PARTY_MACT
--   SAT_MOTOR_AUG_COMMON_CLASSIFICATION
--   SAT_MOTOR_AUG_COMMON_COMMUNICATION_PREFERENCE
--   SAT_MOTOR_AUG_COMMON_CONSENT
--   SAT_MOTOR_AUG_FIN_RECEIPT
--   SAT_MOTOR_AUG_INSTRUMENT_DEFINITION
--   SAT_MOTOR_AUG_LNK_PARTY_ROLE_CORE
--   SAT_MOTOR_AUG_PARTY_BANKING
--   SAT_MOTOR_AUG_PARTY_CONSENT_MANDATE
--   SAT_MOTOR_AUG_PARTY_CONTACT_ADDRESS_LINK
--   SAT_MOTOR_AUG_PARTY_EMPLOYMENT
--   SAT_MOTOR_AUG_PARTY_FINANCIAL_PROFILE
--   SAT_MOTOR_AUG_PARTY_FRAUD_PROFILE
--   SAT_MOTOR_AUG_PARTY_GROUP_HOUSEHOLD
--   SAT_MOTOR_AUG_PARTY_HEALTH_PROFILE
--   SAT_MOTOR_AUG_PARTY_HIERARCHY
--   SAT_MOTOR_AUG_PARTY_IDENTIFICATION
--   SAT_MOTOR_AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS
--   SAT_MOTOR_AUG_PARTY_KYC
--   SAT_MOTOR_AUG_PARTY_ONBOARDING_JOURNEY
--   SAT_MOTOR_AUG_PARTY_PAYOUT_PROFILE
--   SAT_MOTOR_AUG_PARTY_PREFERENCE_PROFILE
--   SAT_MOTOR_AUG_PARTY_RELATIONSHIP_PROFILE
--   SAT_MOTOR_AUG_PARTY_VEHICLE_OWNER
--   SAT_MOTOR_AUG_PRODUCT_DEFINITION
--   SAT_MOTOR_AUG_RISK_MOTOR_VERIFICATION
--   SAT_CLAIM_CO_RI_SHARE
--   SAT_CLAIM_MACT_AWARD_HEAD
--   SAT_CLAIM_PAYMENT_TRANCHE
--   SAT_CLAIM_RESERVE
--   SAT_COMMON_ADMIN_GEOGRAPHY
--   SAT_COMMON_CLASSIFICATION
--   SAT_COMMON_COMMUNICATION_PREFERENCE
--   SAT_COMMON_CONSENT
--   SAT_FINTXN_ACCOUNTING
--   SAT_FINTXN_PREMIUM
--   SAT_FIN_RECEIPT
--   SAT_INSTRUMENT_DEFINITION
--   SAT_LNK_ROLE_AGENT
--   SAT_LNK_ROLE_CUSTOMER
--   SAT_LNK_ROLE_EMPLOYEE
--   SAT_LNK_ROLE_PROVIDER
--   SAT_PARTY_AML_SCREENING
--   SAT_PARTY_BANKING
--   SAT_PARTY_EMPLOYMENT
--   SAT_PARTY_FINANCIAL_PROFILE
--   SAT_PARTY_HEALTH_PROFILE
--   SAT_PARTY_HIERARCHY
--   SAT_PARTY_IDENTIFICATION
--   SAT_PARTY_KYC
--   SAT_PARTY_ONBOARDING_JOURNEY
--   SAT_POLICY_DELIVERY
--   SAT_POLICY_EXTERNAL_TP_LINK
--   SAT_POLICY_LIFECYCLE
--   SAT_QUOTE_COMPARISON
--   SAT_RISK_MOTOR_VERIFICATION
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_CHANNEL_ORG_UNIT
--   LNK_CLAIM_ASSESSMENT
--   LNK_CLAIM_POLICY
--   LNK_CLAIM_RISK_OBJECT
--   LNK_FINTXN_CLAIM
--   LNK_FINTXN_INSTRUMENT
--   LNK_PARTY_CHANNEL
--   LNK_PARTY_LOCATION
--   LNK_PARTY_ORG_UNIT
--   LNK_POLICY_CHANNEL
--   LNK_POLICY_ORG_UNIT
--   LNK_POLICY_PARTY
--   LNK_POLICY_PRODUCT
--   LNK_POLICY_RISK_OBJECT
--   LNK_PROPOSAL_ASSESSMENT
--   LNK_PROPOSAL_RISK_OBJECT
--   LNK_RISK_OBJECT_ASSESSMENT
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
    select
        cast(null as varchar) as ASSESSMENT_BK,
        nullif(nullif(trim(t0.claimno),''), '') as CLAIM_BK,
        cast(null as varchar) as DISTRIBUTION_CHANNEL_BK,
        cast(null as varchar) as FINANCIAL_TRANSACTION_BK,
        nullif(md5(normalise(upper(nullif(trim(coalesce(t0.customer_location_by_state,'') || '|' || coalesce(t0.customer_location_by_district,'') || '|' || coalesce(t0.customer_location_by_tehsil,'')),'||')))), '') as LOCATION_BK,
        cast(null as varchar) as ORG_UNIT_BK,
        nullif('DL:' || nullif(trim(t0.driver_license_number),''), '') as PARTY_BK,
        cast(null as varchar) as PAYMENT_INSTRUMENT_BK,
        cast(null as varchar) as POLICY_BK,
        cast(null as varchar) as PRODUCT_BK,
        cast(null as varchar) as PROPOSAL_BK,
        cast(null as varchar) as QUOTE_BK,
        nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), '') as RISK_OBJECT_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as number) as __LNK_CHANNEL_ORG_UNIT,
        cast(null as number) as __LNK_CLAIM_ASSESSMENT,
        cast(null as number) as __LNK_CLAIM_POLICY,
        cast(null as number) as __LNK_CLAIM_RISK_OBJECT,
        cast(null as number) as __LNK_FINTXN_CLAIM,
        cast(null as number) as __LNK_FINTXN_INSTRUMENT,
        cast(null as number) as __LNK_PARTY_CHANNEL,
        cast(null as number) as __LNK_PARTY_LOCATION,
        cast(null as number) as __LNK_PARTY_ORG_UNIT,
        cast(null as number) as __LNK_POLICY_CHANNEL,
        cast(null as number) as __LNK_POLICY_ORG_UNIT,
        cast(null as number) as __LNK_POLICY_PARTY,
        cast(null as number) as __LNK_POLICY_PRODUCT,
        cast(null as number) as __LNK_POLICY_RISK_OBJECT,
        cast(null as number) as __LNK_PROPOSAL_ASSESSMENT,
        cast(null as number) as __LNK_PROPOSAL_RISK_OBJECT,
        cast(null as number) as __LNK_RISK_OBJECT_ASSESSMENT,
        cast(null as varchar) as ASSESSMENT_REINSPECTION__RE_INSPECTION_DATE,
        cast(null as varchar) as ASSESSMENT_REINSPECTION__RE_INSPECTION_TIME,
        cast(null as varchar) as AUG_ASSESSMENT_REINSPECTION__RE_INSPECTION_CONDUCTED_INDICATOR,
        cast(null as varchar) as AUG_ASSESSMENT_REINSPECTION__RE_INSPECTION_DELAY_DAYS,
        cast(null as varchar) as AUG_ASSESSMENT_REINSPECTION__RE_INSPECTION_INDICATOR,
        cast(null as varchar) as AUG_ASSESSMENT_REINSPECTION__RE_INSPECTION_OTHER_REMARKS,
        cast(null as varchar) as AUG_ASSESSMENT_REINSPECTION__RE_INSPECTION_REMARKS,
        cast(null as varchar) as AUG_ASSESSMENT_REINSPECTION__RE_INSPECTION_REQUESTED_INDICATOR,
        cast(null as varchar) as AUG_ASSESSMENT_REINSPECTION__RE_INSPECTION_REQUEST_DATE,
        cast(null as varchar) as AUG_ASSESSMENT_REINSPECTION__RE_INSPECTION_STATUS,
        cast(null as varchar) as AUG_ASSESSMENT_REINSPECTION__RE_INSPECTION_SURVEY_DATE,
        cast(null as varchar) as AUG_ASSESSMENT_REINSPECTION__RE_INSPECTION_SURVEY_REMARKS,
        cast(null as varchar) as AUG_ASSESSMENT_REINSPECTION__RE_INSPECTION_SURVEY_TIME,
        cast(null as varchar) as AUG_CLAIM_EXCESS_HEAD__EXCESS_TYPE_CODE_CK,
        cast(null as varchar) as AUG_CLAIM_EXCESS_HEAD__EXCESS_AMOUNT,
        cast(null as varchar) as AUG_CLAIM_EXCESS_HEAD__EXCESS_WAIVED_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_EXCESS_HEAD__EXCESS_WAIVER_REASON,
        cast(null as varchar) as AUG_CLAIM_PAYMENT_TRANCHE__TRANCHE_NUMBER_CK,
        cast(null as varchar) as AUG_CLAIM_PAYMENT_TRANCHE__PAYMENT_CONFIRMED_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_HEAD_CODE_CK,
        cast(null as varchar) as AUG_CLAIM_RECOVERY_EXPENSE_LINE__CONVEYANCE_AMOUNT,
        cast(null as varchar) as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_AMOUNT,
        cast(null as varchar) as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_CURRENCY_CODE,
        cast(null as varchar) as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_HEAD_CODE,
        cast(null as varchar) as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_HEAD_NAME,
        cast(null as varchar) as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_PAYMENT_AMOUNT,
        cast(null as varchar) as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_PAYMENT_APPROVED_BY_USER_REFERENCE,
        cast(null as varchar) as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_PAYMENT_DATE,
        cast(null as varchar) as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_PAYMENT_REFERENCE_NUMBER,
        cast(null as varchar) as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_PAYMENT_TYPE,
        cast(null as varchar) as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_PORTAL_PAYMENT_REFERENCE_NUMBER,
        cast(null as varchar) as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_QUANTITY,
        cast(null as varchar) as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_RATE,
        cast(null as varchar) as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_REFERENCE_TEXT,
        cast(null as varchar) as AUG_CLAIM_RECOVERY_EXPENSE_LINE__FLAT_RATE_AMOUNT,
        cast(null as varchar) as AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_AUCTION_REFERRAL_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_TAT_BREACH__PROCESS_STEP_CODE_CK,
        cast(null as varchar) as AUG_CLAIM_TAT_BREACH__TAT_BREACH_INDICATOR,
        cast(null as varchar) as AUG_CLAIM_THIRD_PARTY_MACT__FIXED_DEPOSIT_RECEIPT_FAVOURING_NAME,
        cast(null as varchar) as AUG_CLAIM_THIRD_PARTY_MACT__FIXED_DEPOSIT_RECEIPT_TENURE,
        cast(null as varchar) as AUG_CLAIM_THIRD_PARTY_MACT__INTEREST_APPLICABLE_INDICATOR,
        cast(null as varchar) as AUG_COMMON_CLASSIFICATION__OVERALL_RATING_GRADE,
        cast(null as varchar) as AUG_COMMON_CLASSIFICATION__PROFILE_CODE,
        cast(null as varchar) as AUG_COMMON_CLASSIFICATION__REFERENCE_CODE,
        cast(null as varchar) as AUG_COMMON_CLASSIFICATION__USER_TYPE_CODE,
        cast(null as varchar) as AUG_COMMON_COMMUNICATION_PREFERENCE__COMMUNICATION_AND_LANGUAGE_PREFERENCE_TEXT,
        cast(null as varchar) as AUG_COMMON_COMMUNICATION_PREFERENCE__PREFERRED_ALERT_CHANNEL_CODE,
        cast(null as varchar) as AUG_COMMON_CONSENT__DECLARATION_TEXT,
        cast(null as varchar) as AUG_FIN_RECEIPT__COLLECTION_DATE,
        cast(null as varchar) as AUG_FIN_RECEIPT__COLLECTION_SOURCE,
        cast(null as varchar) as AUG_FIN_RECEIPT__COLLECTION_SUB_CODE,
        cast(null as varchar) as AUG_INSTRUMENT_DEFINITION__INSTRUMENT_ISSUE_DATE,
        cast(null as varchar) as AUG_LNK_PARTY_ROLE_CORE__ROLE_CODE_CK,
        cast(null as varchar) as AUG_LNK_PARTY_ROLE_CORE__ROLE_SEQUENCE_CK,
        cast(null as varchar) as AUG_LNK_PARTY_ROLE_CORE__OTHER_RELATIONSHIP_DESCRIPTION,
        cast(null as varchar) as AUG_LNK_PARTY_ROLE_CORE__RELATIONSHIP_TO_HIGH_NET_WORTH_CUSTOMER,
        cast(null as varchar) as AUG_LNK_PARTY_ROLE_CORE__RELATIONSHIP_TO_INSURED,
        cast(null as varchar) as AUG_LNK_PARTY_ROLE_CORE__RELATIONSHIP_TO_INSURER_EMPLOYEE,
        cast(null as varchar) as AUG_LNK_PARTY_ROLE_CORE__RELATIONSHIP_TO_PRIVE_CUSTOMER,
        cast(null as varchar) as AUG_PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK,
        cast(null as varchar) as AUG_PARTY_BANKING__ACCOUNT_CATEGORY_CODE,
        cast(null as varchar) as AUG_PARTY_BANKING__ACCOUNT_NUMBER,
        cast(null as varchar) as AUG_PARTY_BANKING__APPROVED_OR_REJECTED_BY_USER_REFERENCE,
        cast(null as varchar) as AUG_PARTY_BANKING__APPROVED_OR_REJECTED_DATE,
        cast(null as varchar) as AUG_PARTY_BANKING__BANK_BRANCH_CODE,
        cast(null as varchar) as AUG_PARTY_BANKING__BANK_RECORD_REMARKS,
        cast(null as varchar) as AUG_PARTY_BANKING__NEFT_VALIDATION_STATUS,
        cast(null as varchar) as AUG_PARTY_BANKING__PAYEE_NAME_AS_PER_BANK_RECORD,
        cast(null as varchar) as AUG_PARTY_BANKING__PENNY_DROP_SKIPPED_INDICATOR,
        cast(null as varchar) as AUG_PARTY_BANKING__PENNY_DROP_VERIFICATION_SCORE,
        cast(null as varchar) as AUG_PARTY_CONSENT_MANDATE__MANDATE_DETAIL_TEXT,
        cast(null as varchar) as AUG_PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE_CK,
        cast(null as varchar) as AUG_PARTY_CONTACT_ADDRESS_LINK__ADDRESS_PROOF_EFFECTIVE_DATE,
        cast(null as varchar) as AUG_PARTY_CONTACT_ADDRESS_LINK__OTHER_ADDRESS_PROOF_TYPE,
        cast(null as varchar) as AUG_PARTY_CONTACT_ADDRESS_LINK__SAME_AS_CORRESPONDENCE_ADDRESS_INDICATOR,
        cast(null as varchar) as AUG_PARTY_CONTACT_ADDRESS_LINK__SAME_AS_PRIMARY_ADDRESS_INDICATOR,
        cast(null as varchar) as AUG_PARTY_EMPLOYMENT__EMPLOYER_DETAIL_TEXT,
        cast(null as varchar) as AUG_PARTY_FINANCIAL_PROFILE__BANKING_DETAIL_TEXT,
        cast(null as varchar) as AUG_PARTY_FINANCIAL_PROFILE__CREDIT_CARD_DETAIL_TEXT,
        cast(null as varchar) as AUG_PARTY_FINANCIAL_PROFILE__CREDIT_LIMIT_REFERENCE_TEXT,
        cast(null as varchar) as AUG_PARTY_FINANCIAL_PROFILE__INCOME_TAX_RETURN_FILED_TWO_YEARS_INDICATOR,
        cast(null as varchar) as AUG_PARTY_FINANCIAL_PROFILE__MONTHLY_GROSS_INCOME,
        cast(null as varchar) as AUG_PARTY_FINANCIAL_PROFILE__MONTHLY_INCOME,
        cast(null as varchar) as AUG_PARTY_FRAUD_PROFILE__NON_DISCLOSURE_ACTION_INITIATED_INDICATOR,
        cast(null as varchar) as AUG_PARTY_GROUP_HOUSEHOLD__MEMBER_TYPE,
        cast(null as varchar) as AUG_PARTY_HEALTH_PROFILE__DISABILITY_BODY_LOCATION,
        cast(null as varchar) as AUG_PARTY_HEALTH_PROFILE__MEDICAL_CONDITION_ICD_CODE,
        cast(null as varchar) as AUG_PARTY_HEALTH_PROFILE__SURGERY_DETAIL_TEXT,
        cast(null as varchar) as AUG_PARTY_HIERARCHY__BRANCH_REFERENCE,
        cast(null as varchar) as AUG_PARTY_HIERARCHY__MULTI_OFFICE_BUSINESS_INDICATOR,
        cast(null as varchar) as AUG_PARTY_HIERARCHY__PRIMARY_BRANCH_REFERENCE,
        cast(null as varchar) as AUG_PARTY_HIERARCHY__SECONDARY_BRANCH_REFERENCE,
        cast(null as varchar) as AUG_PARTY_HIERARCHY__TRANSFER_CASE_REFERENCE,
        cast(null as varchar) as AUG_PARTY_HIERARCHY__TRANSFER_INDICATOR,
        'DRIVING_LICENCE' as AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        cast(null as varchar) as AUG_PARTY_IDENTIFICATION__AADHAAR_ENROLMENT_NUMBER,
        cast(null as varchar) as AUG_PARTY_IDENTIFICATION__AADHAAR_VIRTUAL_IDENTIFIER,
        cast(null as varchar) as AUG_PARTY_IDENTIFICATION__ABHA_NUMBER,
        cast(null as varchar) as AUG_PARTY_IDENTIFICATION__DRIVING_LICENCE_DETAIL_TEXT,
        t0.driver_license_type as AUG_PARTY_IDENTIFICATION__DRIVING_LICENCE_TYPE,
        cast(null as varchar) as AUG_PARTY_IDENTIFICATION__EIA_AVAILABLE_INDICATOR,
        cast(null as varchar) as AUG_PARTY_IDENTIFICATION__EIA_DETAIL_TEXT,
        cast(null as varchar) as AUG_PARTY_IDENTIFICATION__EIA_LINKAGE_DATE,
        cast(null as varchar) as AUG_PARTY_IDENTIFICATION__EIA_POLICY_CREDIT_REQUIRED_INDICATOR,
        cast(null as varchar) as AUG_PARTY_IDENTIFICATION__EIA_REQUIRED_INDICATOR,
        cast(null as varchar) as AUG_PARTY_IDENTIFICATION__GST_COMPOSITION_SCHEME_INDICATOR,
        cast(null as varchar) as AUG_PARTY_IDENTIFICATION__GST_PAYABLE_INDICATOR,
        cast(null as varchar) as AUG_PARTY_IDENTIFICATION__IDENTIFICATION_ISSUING_COUNTRY,
        t0.driver_license_place_of_issue as AUG_PARTY_IDENTIFICATION__IDENTIFICATION_PLACE_OF_ISSUE,
        cast(null as varchar) as AUG_PARTY_IDENTIFICATION__IDENTIFICATION_VALID_FROM_DATE,
        cast(null as varchar) as AUG_PARTY_IDENTIFICATION__NAME_AS_PER_IDENTIFICATION_DOCUMENT,
        cast(null as varchar) as AUG_PARTY_IDENTIFICATION__PAN_AADHAAR_LINKED_INDICATOR,
        cast(null as varchar) as AUG_PARTY_IDENTIFICATION__PASSPORT_DETAIL_TEXT,
        cast(null as varchar) as AUG_PARTY_IDENTIFICATION__PASSPORT_FILE_NUMBER,
        cast(null as varchar) as AUG_PARTY_IDENTIFICATION__PROOF_OF_ADDRESS_STATUS,
        cast(null as varchar) as AUG_PARTY_IDENTIFICATION__PROOF_OF_IDENTITY_STATUS,
        cast(null as varchar) as AUG_PARTY_IDENTIFICATION__STATE_WISE_GSTIN_DETAIL_TEXT,
        cast(null as varchar) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__BASIC_QUALIFICATION_BOARD_NAME,
        cast(null as varchar) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__BASIC_QUALIFICATION_DETAIL_TEXT,
        cast(null as varchar) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__BASIC_QUALIFICATION_ROLL_NUMBER,
        cast(null as varchar) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__DATE_OF_MARRIAGE,
        cast(null as varchar) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__FATHER_OR_SPOUSE_NAME,
        cast(null as varchar) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__IRDAI_LISTED_PRIMARY_PROFESSION,
        cast(null as varchar) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__MOTHER_MAIDEN_NAME,
        cast(null as varchar) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__NUMBER_OF_DAUGHTERS,
        cast(null as varchar) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__NUMBER_OF_SONS,
        cast(null as varchar) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__OTHER_OCCUPATION_DESCRIPTION,
        cast(null as varchar) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__OTHER_QUALIFICATION,
        cast(null as varchar) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__PRIMARY_PROFESSION,
        cast(null as varchar) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__PROFESSIONAL_QUALIFICATION,
        cast(null as varchar) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__QUALIFICATION_DETAIL_TEXT,
        cast(null as varchar) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__QUALIFICATION_PASSING_MONTH,
        cast(null as varchar) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__QUALIFICATION_PASSING_YEAR,
        cast(null as varchar) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__UNDERGRADUATE_QUALIFICATION,
        cast(null as varchar) as AUG_PARTY_KYC__CKYC_DETAIL_TEXT,
        cast(null as varchar) as AUG_PARTY_KYC__CKYC_NUMBER_HELD_INDICATOR,
        cast(null as varchar) as AUG_PARTY_KYC__KYC_DETAIL_TEXT,
        cast(null as varchar) as AUG_PARTY_KYC__OPTIONAL_SUPPORTING_PROOF_DOCUMENT_TYPE,
        cast(null as varchar) as AUG_PARTY_KYC__PRIMARY_SUPPORTING_PROOF_DOCUMENT_TYPE,
        cast(null as varchar) as AUG_PARTY_KYC__PROOF_OF_ADDRESS_DOCUMENT_TYPE,
        cast(null as varchar) as AUG_PARTY_KYC__PROOF_OF_ADDRESS_STATUS,
        cast(null as varchar) as AUG_PARTY_KYC__PROOF_OF_ADDRESS_VERIFICATION_STATUS,
        cast(null as varchar) as AUG_PARTY_KYC__PROOF_OF_IDENTITY_DOCUMENT_TYPE,
        cast(null as varchar) as AUG_PARTY_KYC__PROOF_OF_IDENTITY_STATUS,
        cast(null as varchar) as AUG_PARTY_KYC__PROOF_OF_IDENTITY_VERIFICATION_STATUS,
        cast(null as varchar) as AUG_PARTY_ONBOARDING_JOURNEY__CANDIDATE_BACKGROUND_DESCRIPTION,
        cast(null as varchar) as AUG_PARTY_ONBOARDING_JOURNEY__INSURANCE_BANKING_FINANCE_EXPERIENCE_YEARS,
        cast(null as varchar) as AUG_PARTY_ONBOARDING_JOURNEY__LICENCE_EXAMINATION_DETAIL_TEXT,
        cast(null as varchar) as AUG_PARTY_ONBOARDING_JOURNEY__PREVIOUS_EMPLOYER_LOCATION,
        cast(null as varchar) as AUG_PARTY_ONBOARDING_JOURNEY__PREVIOUS_EMPLOYER_PARENT_INTERMEDIARY_CODE,
        cast(null as varchar) as AUG_PARTY_ONBOARDING_JOURNEY__PREVIOUS_EMPLOYER_PARENT_SUB_INTERMEDIARY_CODE,
        cast(null as varchar) as AUG_PARTY_ONBOARDING_JOURNEY__PREVIOUS_EMPLOYMENT_LEAVING_REASON,
        cast(null as varchar) as AUG_PARTY_ONBOARDING_JOURNEY__PREVIOUS_NON_GENERAL_INSURER_NAME,
        cast(null as varchar) as AUG_PARTY_ONBOARDING_JOURNEY__REJECTION_REASON,
        cast(null as varchar) as AUG_PARTY_PAYOUT_PROFILE__LOWER_TDS_CERTIFICATE_REFERENCE,
        cast(null as varchar) as AUG_PARTY_PAYOUT_PROFILE__REFUND_BENEFICIARY_PARTY_REFERENCE,
        cast(null as varchar) as AUG_PARTY_PAYOUT_PROFILE__TDS_CODE,
        cast(null as varchar) as AUG_PARTY_PAYOUT_PROFILE__TDS_CODE_DESCRIPTION,
        cast(null as varchar) as AUG_PARTY_PAYOUT_PROFILE__TDS_DETAIL_TEXT,
        cast(null as varchar) as AUG_PARTY_PREFERENCE_PROFILE__ELECTRONIC_POLICY_ISSUANCE_PREFERENCE_INDICATOR,
        cast(null as varchar) as AUG_PARTY_PREFERENCE_PROFILE__PROPAGATE_CONTACT_UPDATE_TO_ALL_POLICIES_INDICATOR,
        cast(null as varchar) as AUG_PARTY_RELATIONSHIP_PROFILE__EXISTING_CUSTOMER_DECLARED_INDICATOR,
        cast(null as varchar) as AUG_PARTY_RELATIONSHIP_PROFILE__FINAL_LOYALTY_SEVERITY,
        cast(null as varchar) as AUG_PARTY_RELATIONSHIP_PROFILE__LOYALTY_BUCKET_BY_SEVERITY,
        cast(null as varchar) as AUG_PARTY_RELATIONSHIP_PROFILE__NOMINEE_DETAIL_TEXT,
        cast(null as varchar) as AUG_PARTY_VEHICLE_OWNER__DRIVING_EXPERIENCE_YEARS,
        cast(null as varchar) as AUG_PRODUCT_DEFINITION__PARTNER_PRODUCT_NAME,
        cast(null as varchar) as AUG_PRODUCT_DEFINITION__PRODUCT_DETAIL_TEXT,
        t0.vahan_registration_number as AUG_RISK_MOTOR_VERIFICATION__REGISTRATION_NUMBER_AS_VERIFIED,
        t0.vaahan_registration_source as AUG_RISK_MOTOR_VERIFICATION__VERIFICATION_DATA_SOURCE,
        t0.coinsurance_contribution as CLAIM_CO_RI_SHARE__CO_INSURANCE_OUR_SHARE_PERCENTAGE,
        cast(null as varchar) as CLAIM_CO_RI_SHARE__EXPENSE_SHARE_AMOUNT,
        t0.leaderfollower as CLAIM_CO_RI_SHARE__LEADER_INDICATOR,
        cast(null as varchar) as CLAIM_MACT_AWARD_HEAD__AWARD_HEAD_CODE_CK,
        cast(null as varchar) as CLAIM_MACT_AWARD_HEAD__AWARDED_AMOUNT,
        cast(null as varchar) as CLAIM_MACT_AWARD_HEAD__INTEREST_AMOUNT,
        cast(null as varchar) as CLAIM_PAYMENT_TRANCHE__TRANCHE_NUMBER_CK,
        cast(null as varchar) as CLAIM_PAYMENT_TRANCHE__GROSS_AMOUNT,
        cast(null as varchar) as CLAIM_PAYMENT_TRANCHE__STATUS,
        cast(null as varchar) as CLAIM_RESERVE__RESERVE_HEAD_CK,
        cast(null as varchar) as CLAIM_RESERVE__CURRENT_RESERVE_AMOUNT,
        cast(null as varchar) as CLAIM_RESERVE__INITIAL_RESERVE_AMOUNT,
        cast(null as varchar) as CLAIM_RESERVE__RESERVE_TYPE,
        cast(null as varchar) as COMMON_ADMIN_GEOGRAPHY__COUNTRY_CODE,
        t0.customer_location_by_district as COMMON_ADMIN_GEOGRAPHY__DISTRICT_NAME,
        cast(null as varchar) as COMMON_ADMIN_GEOGRAPHY__PIN_CODE,
        cast(null as varchar) as COMMON_ADMIN_GEOGRAPHY__STATE_CODE,
        t0.customer_location_by_state as COMMON_ADMIN_GEOGRAPHY__STATE_NAME,
        t0.customer_location_by_tehsil as COMMON_ADMIN_GEOGRAPHY__TALUKA_NAME,
        cast(null as varchar) as COMMON_CLASSIFICATION__CATEGORY_CODE,
        cast(null as varchar) as COMMON_CLASSIFICATION__SEGMENT_NAME,
        cast(null as varchar) as COMMON_COMMUNICATION_PREFERENCE__GO_GREEN_OPT_IN_INDICATOR,
        cast(null as varchar) as COMMON_COMMUNICATION_PREFERENCE__PREFERRED_CHANNEL_CODE,
        cast(null as varchar) as COMMON_COMMUNICATION_PREFERENCE__PREFERRED_LANGUAGE_CODE,
        cast(null as varchar) as COMMON_CONSENT__CONSENT_GIVEN_INDICATOR,
        cast(null as varchar) as FINTXN_ACCOUNTING__VOUCHER_NUMBER,
        cast(null as varchar) as FINTXN_PREMIUM__COLLECTION_MODE,
        cast(null as varchar) as FIN_RECEIPT__AMOUNT_RECEIVED,
        cast(null as varchar) as FIN_RECEIPT__REALISATION_DATE,
        cast(null as varchar) as FIN_RECEIPT__RECEIPT_DATE,
        cast(null as varchar) as FIN_RECEIPT__RECEIPT_NUMBER,
        cast(null as varchar) as FIN_RECEIPT__RECEIPT_TYPE,
        cast(null as varchar) as INSTRUMENT_DEFINITION__ACCOUNT_TYPE,
        cast(null as varchar) as INSTRUMENT_DEFINITION__BANK_NAME,
        cast(null as varchar) as INSTRUMENT_DEFINITION__CARD_TYPE,
        cast(null as varchar) as INSTRUMENT_DEFINITION__IFSC_CODE,
        cast(null as varchar) as INSTRUMENT_DEFINITION__INSTRUMENT_STATUS,
        cast(null as varchar) as INSTRUMENT_DEFINITION__VALID_TO_DATE,
        cast(null as varchar) as LNK_ROLE_AGENT__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_AGENT__AGENCY_TYPE,
        cast(null as varchar) as LNK_ROLE_AGENT__APPOINTMENT_DATE,
        cast(null as varchar) as LNK_ROLE_AGENT__IRDAI_AGENT_LICENCE_NUMBER,
        cast(null as varchar) as LNK_ROLE_AGENT__LICENCE_CATEGORY,
        cast(null as varchar) as LNK_ROLE_AGENT__LICENCE_EXPIRY_DATE,
        cast(null as varchar) as LNK_ROLE_AGENT__LICENCE_ISSUE_DATE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__BLACKLIST_INDICATOR,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__BLACKLIST_REASON,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__CONSENT_FOR_DATA_SHARING_INDICATOR,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as LNK_ROLE_EMPLOYEE__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_EMPLOYEE__DEPARTMENT,
        cast(null as varchar) as LNK_ROLE_EMPLOYEE__EMPLOYEE_CODE,
        cast(null as varchar) as LNK_ROLE_EMPLOYEE__FUNCTION,
        cast(null as varchar) as LNK_ROLE_PROVIDER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_PROVIDER__SERVICE_REGION,
        cast(null as varchar) as LNK_ROLE_PROVIDER__SERVICE_SCOPE_DESCRIPTION,
        cast(null as varchar) as PARTY_AML_SCREENING__SCREENING_STATUS,
        cast(null as varchar) as PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK,
        cast(null as varchar) as PARTY_BANKING__ACCOUNT_HOLDER_NAME,
        cast(null as varchar) as PARTY_BANKING__ACCOUNT_NUMBER_MASKED,
        cast(null as varchar) as PARTY_BANKING__ACCOUNT_TYPE,
        cast(null as varchar) as PARTY_BANKING__BANK_NAME,
        cast(null as varchar) as PARTY_BANKING__BRANCH_NAME,
        cast(null as varchar) as PARTY_BANKING__IFSC_CODE,
        cast(null as varchar) as PARTY_BANKING__MICR_CODE,
        cast(null as varchar) as PARTY_BANKING__PRIMARY_ACCOUNT_INDICATOR,
        cast(null as varchar) as PARTY_EMPLOYMENT__EMPLOYER_NAME,
        cast(null as varchar) as PARTY_EMPLOYMENT__EMPLOYMENT_STATUS,
        cast(null as varchar) as PARTY_FINANCIAL_PROFILE__CREDIT_SCORE,
        cast(null as varchar) as PARTY_FINANCIAL_PROFILE__INCOME_SOURCE,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__CURRENT_MEDICATION_DETAIL,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__DISABILITY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__DISABILITY_PERCENTAGE,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__HEIGHT,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__WEIGHT,
        cast(null as varchar) as PARTY_HIERARCHY__HIERARCHY_LEVEL,
        cast(null as varchar) as PARTY_HIERARCHY__REPORTING_PARENT_REFERENCE,
        cast(null as varchar) as PARTY_HIERARCHY__TERRITORY_CODE,
        'DRIVING_LICENCE' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        cast(null as varchar) as PARTY_IDENTIFICATION__AADHAAR_NUMBER,
        cast(null as varchar) as PARTY_IDENTIFICATION__AGE_PROOF_TYPE,
        cast(null as varchar) as PARTY_IDENTIFICATION__CKYC_NUMBER,
        t0.license_expiry_date as PARTY_IDENTIFICATION__DRIVING_LICENCE_EXPIRY_DATE,
        cast(null as varchar) as PARTY_IDENTIFICATION__DRIVING_LICENCE_NUMBER,
        cast(null as varchar) as PARTY_IDENTIFICATION__EIA_NUMBER,
        cast(null as varchar) as PARTY_IDENTIFICATION__GSTIN,
        cast(null as varchar) as PARTY_IDENTIFICATION__GST_REGISTRATION_STATUS,
        cast(null as varchar) as PARTY_IDENTIFICATION__GST_TAXPAYER_TYPE,
        cast(null as varchar) as PARTY_IDENTIFICATION__IDENTIFICATION_EXPIRY_DATE,
        cast(null as varchar) as PARTY_IDENTIFICATION__IDENTIFICATION_ISSUE_DATE,
        cast(null as varchar) as PARTY_IDENTIFICATION__IDENTIFICATION_ISSUING_AUTHORITY,
        cast(null as varchar) as PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER,
        cast(null as varchar) as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE,
        cast(null as varchar) as PARTY_IDENTIFICATION__IDENTIFICATION_VERIFIED_INDICATOR,
        cast(null as varchar) as PARTY_IDENTIFICATION__INSURANCE_REPOSITORY_NAME,
        cast(null as varchar) as PARTY_IDENTIFICATION__NREGA_CARD_NUMBER,
        cast(null as varchar) as PARTY_IDENTIFICATION__PAN_NUMBER,
        cast(null as varchar) as PARTY_IDENTIFICATION__PASSPORT_EXPIRY_DATE,
        cast(null as varchar) as PARTY_IDENTIFICATION__PASSPORT_NUMBER,
        cast(null as varchar) as PARTY_IDENTIFICATION__TAN_NUMBER,
        cast(null as varchar) as PARTY_IDENTIFICATION__VAT_REGISTRATION_NUMBER,
        cast(null as varchar) as PARTY_IDENTIFICATION__VOTER_ID_NUMBER,
        cast(null as varchar) as PARTY_KYC__CKYC_NUMBER,
        cast(null as varchar) as PARTY_KYC__CKYC_REGISTRATION_STATUS,
        cast(null as varchar) as PARTY_KYC__KYC_COMPLETION_DATE,
        cast(null as varchar) as PARTY_KYC__KYC_STATUS,
        cast(null as varchar) as PARTY_ONBOARDING_JOURNEY__ONBOARDING_START_DATE,
        cast(null as varchar) as PARTY_ONBOARDING_JOURNEY__PREVIOUS_EMPLOYER_NAME,
        cast(null as varchar) as PARTY_ONBOARDING_JOURNEY__PRIOR_WORK_EXPERIENCE_YEARS,
        cast(null as varchar) as POLICY_DELIVERY__DELIVERY_MODE,
        cast(null as varchar) as POLICY_DELIVERY__DISPATCH_DATE,
        cast(null as varchar) as POLICY_DELIVERY__EDELIVERY_INDICATOR,
        cast(null as varchar) as POLICY_DELIVERY__TRACKING_REFERENCE,
        cast(null as varchar) as POLICY_EXTERNAL_TP_LINK__EXTERNAL_TP_POLICY_INDICATOR,
        cast(null as varchar) as POLICY_EXTERNAL_TP_LINK__TP_INSURER_NAME,
        cast(null as varchar) as POLICY_EXTERNAL_TP_LINK__TP_POLICY_END_DATE,
        cast(null as varchar) as POLICY_EXTERNAL_TP_LINK__TP_POLICY_NUMBER,
        cast(null as varchar) as POLICY_EXTERNAL_TP_LINK__TP_POLICY_START_DATE,
        cast(null as varchar) as POLICY_EXTERNAL_TP_LINK__TP_TENURE_YEARS,
        cast(null as varchar) as POLICY_LIFECYCLE__LIFECYCLE_STAGE,
        cast(null as varchar) as QUOTE_COMPARISON__OPTION_CODE_CK,
        cast(null as varchar) as QUOTE_COMPARISON__SELECTED_INDICATOR,
        cast(null as varchar) as RISK_MOTOR_VERIFICATION__RC_VERIFICATION_STATUS,
        t0.rec_refresh_at as REC_REFRESH_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_attr_properties_pv') }} t0
    where (coalesce(nullif('DL:' || nullif(trim(t0.driver_license_number),''), ''), nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), ''), nullif(md5(normalise(upper(nullif(trim(coalesce(t0.customer_location_by_state,'') || '|' || coalesce(t0.customer_location_by_district,'') || '|' || coalesce(t0.customer_location_by_tehsil,'')),'||')))), ''), nullif(nullif(trim(t0.claimno),''), ''))) is not null

    union all

    -- branch 1: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
    select
        null, null, null, null,
        nullif(md5(normalise(upper(nullif(trim(coalesce(t0.stored_country_code,'') || '|' || coalesce(t0.stored_state_code,'')),'|')))), '') as LOCATION_BK,
        null,
        nullif('CUST:' || coalesce(nullif(trim(t0.unique_customer_id),''), nullif(trim(t0.customerid),'')), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.loyaltyseverityfinal as AUG_PARTY_RELATIONSHIP_PROFILE__FINAL_LOYALTY_SEVERITY,
        t0.loyality_bucket_by_severity as AUG_PARTY_RELATIONSHIP_PROFILE__LOYALTY_BUCKET_BY_SEVERITY,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.stored_country_code as COMMON_ADMIN_GEOGRAPHY__COUNTRY_CODE,
        null, null,
        t0.stored_state_code as COMMON_ADMIN_GEOGRAPHY__STATE_CODE,
        null, null, null,
        t0.bucket_description as COMMON_CLASSIFICATION__SEGMENT_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        nullif(trim(t0.account_number),'') as PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK,
        t0.name_on_bank_ac as PARTY_BANKING__ACCOUNT_HOLDER_NAME,
        t0.account_number as PARTY_BANKING__ACCOUNT_NUMBER_MASKED,
        t0.account_type as PARTY_BANKING__ACCOUNT_TYPE,
        t0.bank_name as PARTY_BANKING__BANK_NAME,
        t0.bank_branch as PARTY_BANKING__BRANCH_NAME,
        t0.ifsc as PARTY_BANKING__IFSC_CODE,
        t0.micr_code as PARTY_BANKING__MICR_CODE,
        null, null, null,
        t0.creditscore as PARTY_FINANCIAL_PROFILE__CREDIT_SCORE,
        null, null, null, null, null, null, null, null, null, null,
        'CKYC' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null,
        t0.enter_ckyc_no as PARTY_IDENTIFICATION__CKYC_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_attr_properties_pv') }} t0
    where (coalesce(nullif('CUST:' || coalesce(nullif(trim(t0.unique_customer_id),''), nullif(trim(t0.customerid),'')), ''), nullif(md5(normalise(upper(nullif(trim(coalesce(t0.stored_country_code,'') || '|' || coalesce(t0.stored_state_code,'')),'|')))), ''))) is not null

    union all

    -- branch 2: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
    select
        null, null, null, null, null, null,
        nullif('SUPPLIER:' || nullif(trim(t0.workshop_supplier_id),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.workshop_category as COMMON_CLASSIFICATION__CATEGORY_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_attr_properties_pv') }} t0
    where (nullif('SUPPLIER:' || nullif(trim(t0.workshop_supplier_id),''), '')) is not null

    union all

    -- branch 3: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
    select
        null, null, null, null, null, null,
        nullif('CUST:' || coalesce(nullif(trim(t0.unique_customer_id),''), nullif(trim(t0.customerid),'')), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        'VOTER_ID' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.enter_voter_id as PARTY_IDENTIFICATION__VOTER_ID_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_attr_properties_pv') }} t0
    where (nullif('CUST:' || coalesce(nullif(trim(t0.unique_customer_id),''), nullif(trim(t0.customerid),'')), '')) is not null

    union all

    -- branch 4: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
    select
        null, null, null, null, null, null,
        nullif('CUST:' || coalesce(nullif(trim(t0.unique_customer_id),''), nullif(trim(t0.customerid),'')), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        'AADHAAR' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        t0.insured_aadhar_number as PARTY_IDENTIFICATION__AADHAAR_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_attr_properties_pv') }} t0
    where (nullif('CUST:' || coalesce(nullif(trim(t0.unique_customer_id),''), nullif(trim(t0.customerid),'')), '')) is not null

    union all

    -- branch 5: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
    select
        null, null, null, null, null, null,
        nullif('CUST:' || coalesce(nullif(trim(t0.unique_customer_id),''), nullif(trim(t0.customerid),'')), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        'PAN' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.pan_number as PARTY_IDENTIFICATION__PAN_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_attr_properties_pv') }} t0
    where (nullif('CUST:' || coalesce(nullif(trim(t0.unique_customer_id),''), nullif(trim(t0.customerid),'')), '')) is not null

    union all

    -- branch 6: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
    select
        null, null, null, null, null, null,
        nullif('CUST:' || coalesce(nullif(trim(t0.unique_customer_id),''), nullif(trim(t0.customerid),'')), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        'PASSPORT' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.passport_number as PARTY_IDENTIFICATION__PASSPORT_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_attr_properties_pv') }} t0
    where (nullif('CUST:' || coalesce(nullif(trim(t0.unique_customer_id),''), nullif(trim(t0.customerid),'')), '')) is not null

    union all

    -- branch 7: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_PARTY
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(t0.partycode),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        'NIF' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.nif as PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_party') }} t0
    where (nullif(nullif(trim(t0.partycode),''), '')) is not null

    union all

    -- branch 8: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_PAYMENT_PAYMENTPROPERTY_PIVOT_VW
    select
        null,
        nullif(nullif(trim(j3.claimno),''), '') as CLAIM_BK,
        null,
        nullif(nullif(trim(j2.claimpaymentid),''), '') as FINANCIAL_TRANSACTION_BK,
        null, null,
        nullif(nullif(trim(j2.paymentpartycode),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null,
        1 as __LNK_FINTXN_CLAIM,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        nullif(trim(t0.account_number),'') as AUG_PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK,
        t0.account_category_code as AUG_PARTY_BANKING__ACCOUNT_CATEGORY_CODE,
        t0.account_number as AUG_PARTY_BANKING__ACCOUNT_NUMBER,
        null, null,
        t0.branch_code as AUG_PARTY_BANKING__BANK_BRANCH_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.final_reserve as CLAIM_RESERVE__CURRENT_RESERVE_AMOUNT,
        t0.initial_reserve as CLAIM_RESERVE__INITIAL_RESERVE_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.claim_payment_voucher as FINTXN_ACCOUNTING__VOUCHER_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        nullif(trim(t0.account_number),'') as PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK,
        null, null,
        t0.account_type as PARTY_BANKING__ACCOUNT_TYPE,
        t0.bank_name as PARTY_BANKING__BANK_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'VAT' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.vat_number as PARTY_IDENTIFICATION__VAT_REGISTRATION_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_payment_paymentprop_pv') }} t0
    left join {{ ref('stg_mxm__clm_cd_claim_payment_paymentprop') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_payment') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (coalesce(nullif(nullif(trim(j2.claimpaymentid),''), ''), nullif(nullif(trim(j2.paymentpartycode),''), ''), nullif(nullif(trim(j3.claimno),''), ''))) is not null

    union all

    -- branch 9: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_PARTY
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(t0.partycode),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        'NIF' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.nif as PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_risk_party') }} t0
    where (nullif(nullif(trim(t0.partycode),''), '')) is not null

    union all

    -- branch 10: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(t0.assessment_no), ''), '') as ASSESSMENT_BK,
        nullif(nullif(trim(j6.claimno), ''), '') as CLAIM_BK,
        null, null, null,
        nullif(nullif(trim(t0.branch_code), ''), '') as ORG_UNIT_BK,
        null,
        nullif('CHEQUE:' || nullif(trim(t0.cheque_number), ''), '') as PAYMENT_INSTRUMENT_BK,
        nullif(nullif(trim(j6.policyno), ''), '') as POLICY_BK,
        null, null, null,
        nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), '') as RISK_OBJECT_BK,
        null, null,
        1 as __LNK_CLAIM_ASSESSMENT,
        1 as __LNK_CLAIM_POLICY,
        1 as __LNK_CLAIM_RISK_OBJECT,
        null, null, null, null, null, null,
        1 as __LNK_POLICY_ORG_UNIT,
        null, null,
        1 as __LNK_POLICY_RISK_OBJECT,
        null, null,
        1 as __LNK_RISK_OBJECT_ASSESSMENT,
        t0.reinspection_date as ASSESSMENT_REINSPECTION__RE_INSPECTION_DATE,
        t0.reinspection_time as ASSESSMENT_REINSPECTION__RE_INSPECTION_TIME,
        t0.reinspection_conducted_od as AUG_ASSESSMENT_REINSPECTION__RE_INSPECTION_CONDUCTED_INDICATOR,
        t0.delay_in_reinspection as AUG_ASSESSMENT_REINSPECTION__RE_INSPECTION_DELAY_DAYS,
        t0.reinspection as AUG_ASSESSMENT_REINSPECTION__RE_INSPECTION_INDICATOR,
        t0.other_remarks_reinspection as AUG_ASSESSMENT_REINSPECTION__RE_INSPECTION_OTHER_REMARKS,
        t0.reinspection_remarks as AUG_ASSESSMENT_REINSPECTION__RE_INSPECTION_REMARKS,
        t0.reinspection_request as AUG_ASSESSMENT_REINSPECTION__RE_INSPECTION_REQUESTED_INDICATOR,
        t0.reinspection_request_date as AUG_ASSESSMENT_REINSPECTION__RE_INSPECTION_REQUEST_DATE,
        t0.reinspection_status as AUG_ASSESSMENT_REINSPECTION__RE_INSPECTION_STATUS,
        t0.reinspection_survey_date as AUG_ASSESSMENT_REINSPECTION__RE_INSPECTION_SURVEY_DATE,
        t0.reinspection_survey_remarks as AUG_ASSESSMENT_REINSPECTION__RE_INSPECTION_SURVEY_REMARKS,
        t0.reinspection_survey_time as AUG_ASSESSMENT_REINSPECTION__RE_INSPECTION_SURVEY_TIME,
        null, null,
        t0.is_franchise_excess_for_od_waived_off as AUG_CLAIM_EXCESS_HEAD__EXCESS_WAIVED_INDICATOR,
        t0.franchise_excess_for_od_waived_off_reason as AUG_CLAIM_EXCESS_HEAD__EXCESS_WAIVER_REASON,
        null,
        t0.confirm_payment as AUG_CLAIM_PAYMENT_TRANCHE__PAYMENT_CONFIRMED_INDICATOR,
        t0.expense_fee_head_code as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_HEAD_CODE_CK,
        t0.conveyance_amount as AUG_CLAIM_RECOVERY_EXPENSE_LINE__CONVEYANCE_AMOUNT,
        t0.expense_amount as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_AMOUNT,
        null,
        t0.expense_fee_head_code as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_HEAD_CODE,
        t0.expense_fee_head as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_HEAD_NAME,
        t0.expense_payment_amount as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_PAYMENT_AMOUNT,
        t0.expense_payment_approved_by as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_PAYMENT_APPROVED_BY_USER_REFERENCE,
        t0.expense_payment_date as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_PAYMENT_DATE,
        t0.expense_payment_reference_no as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_PAYMENT_REFERENCE_NUMBER,
        t0.expense_payment_type as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_PAYMENT_TYPE,
        t0.expense_portal_payment_reference_number as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_PORTAL_PAYMENT_REFERENCE_NUMBER,
        null, null,
        t0.expense_reference_text as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_REFERENCE_TEXT,
        t0.flat_rate_amount as AUG_CLAIM_RECOVERY_EXPENSE_LINE__FLAT_RATE_AMOUNT,
        t0.refer_for_salvage_auction as AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_AUCTION_REFERRAL_INDICATOR,
        null, null,
        t0.fdr_favoring as AUG_CLAIM_THIRD_PARTY_MACT__FIXED_DEPOSIT_RECEIPT_FAVOURING_NAME,
        t0.fdr_period as AUG_CLAIM_THIRD_PARTY_MACT__FIXED_DEPOSIT_RECEIPT_TENURE,
        t0.is_interest_applicable as AUG_CLAIM_THIRD_PARTY_MACT__INTEREST_APPLICABLE_INDICATOR,
        null, null, null, null, null, null, null, null, null, null,
        t0.cheque_date as AUG_INSTRUMENT_DEFINITION__INSTRUMENT_ISSUE_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.source_of_rc as AUG_RISK_MOTOR_VERIFICATION__VERIFICATION_DATA_SOURCE,
        null,
        t0.coinsurance_expense_amount as CLAIM_CO_RI_SHARE__EXPENSE_SHARE_AMOUNT,
        null, null,
        t0.award_amount as CLAIM_MACT_AWARD_HEAD__AWARDED_AMOUNT,
        t0.interest_amount as CLAIM_MACT_AWARD_HEAD__INTEREST_AMOUNT,
        null,
        t0.current_payment as CLAIM_PAYMENT_TRANCHE__GROSS_AMOUNT,
        t0.claim_payment_status as CLAIM_PAYMENT_TRANCHE__STATUS,
        nullif(trim(t0.reserve_type),'') as CLAIM_RESERVE__RESERVE_HEAD_CK,
        null, null,
        t0.reserve_type as CLAIM_RESERVE__RESERVE_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rc_verification_status as RISK_MOTOR_VERIFICATION__RC_VERIFICATION_STATUS,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop_pv') }} t0
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd') }} j6 on j6.KEY_HASH = j5.PARENT_KEY_HASH
    where (coalesce(nullif('CHEQUE:' || nullif(trim(t0.cheque_number), ''), ''), nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), ''), nullif(nullif(trim(j6.claimno), ''), ''), nullif(nullif(trim(j6.policyno), ''), ''), nullif(nullif(trim(t0.assessment_no), ''), ''), nullif(nullif(trim(t0.branch_code), ''), ''))) is not null

    union all

    -- branch 11: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW | child-key literal(s): AUG_CLAIM_EXCESS_HEAD.Excess Type Code=ADDITIONAL
    select
        null,
        nullif(nullif(trim(j6.claimno), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ADDITIONAL' as AUG_CLAIM_EXCESS_HEAD__EXCESS_TYPE_CODE_CK,
        t0.additional_excess as AUG_CLAIM_EXCESS_HEAD__EXCESS_AMOUNT,
        t0.is_additional_excess_waived_off as AUG_CLAIM_EXCESS_HEAD__EXCESS_WAIVED_INDICATOR,
        t0.additional_excess_waived_off_reason as AUG_CLAIM_EXCESS_HEAD__EXCESS_WAIVER_REASON,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop_pv') }} t0
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd') }} j6 on j6.KEY_HASH = j5.PARENT_KEY_HASH
    where (nullif(nullif(trim(j6.claimno), ''), '')) is not null

    union all

    -- branch 12: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW | child-key literal(s): AUG_CLAIM_EXCESS_HEAD.Excess Type Code=ADDON
    select
        null,
        nullif(nullif(trim(j6.claimno), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ADDON' as AUG_CLAIM_EXCESS_HEAD__EXCESS_TYPE_CODE_CK,
        t0.addon_excess as AUG_CLAIM_EXCESS_HEAD__EXCESS_AMOUNT,
        t0.is_addon_excess_waived_off as AUG_CLAIM_EXCESS_HEAD__EXCESS_WAIVED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop_pv') }} t0
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd') }} j6 on j6.KEY_HASH = j5.PARENT_KEY_HASH
    where (nullif(nullif(trim(j6.claimno), ''), '')) is not null

    union all

    -- branch 13: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW | child-key literal(s): AUG_CLAIM_EXCESS_HEAD.Excess Type Code=BATTERY_THEFT
    select
        null,
        nullif(nullif(trim(j6.claimno), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'BATTERY_THEFT' as AUG_CLAIM_EXCESS_HEAD__EXCESS_TYPE_CODE_CK,
        t0.battery_theft_excess as AUG_CLAIM_EXCESS_HEAD__EXCESS_AMOUNT,
        t0.is_battery_theft_excess_waived_off as AUG_CLAIM_EXCESS_HEAD__EXCESS_WAIVED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop_pv') }} t0
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd') }} j6 on j6.KEY_HASH = j5.PARENT_KEY_HASH
    where (nullif(nullif(trim(j6.claimno), ''), '')) is not null

    union all

    -- branch 14: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW | child-key literal(s): AUG_CLAIM_EXCESS_HEAD.Excess Type Code=COMPULSORY
    select
        null,
        nullif(nullif(trim(j6.claimno), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'COMPULSORY' as AUG_CLAIM_EXCESS_HEAD__EXCESS_TYPE_CODE_CK,
        t0.compulsory_excess as AUG_CLAIM_EXCESS_HEAD__EXCESS_AMOUNT,
        t0.is_compulsory_excess_waived_off as AUG_CLAIM_EXCESS_HEAD__EXCESS_WAIVED_INDICATOR,
        t0.compulsory_excess_waived_off_reason as AUG_CLAIM_EXCESS_HEAD__EXCESS_WAIVER_REASON,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop_pv') }} t0
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd') }} j6 on j6.KEY_HASH = j5.PARENT_KEY_HASH
    where (nullif(nullif(trim(j6.claimno), ''), '')) is not null

    union all

    -- branch 15: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW | child-key literal(s): AUG_CLAIM_EXCESS_HEAD.Excess Type Code=ESCALATED
    select
        null,
        nullif(nullif(trim(j6.claimno), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ESCALATED' as AUG_CLAIM_EXCESS_HEAD__EXCESS_TYPE_CODE_CK,
        t0.escalated_excess as AUG_CLAIM_EXCESS_HEAD__EXCESS_AMOUNT,
        t0.is_escalated_excess_waived_off as AUG_CLAIM_EXCESS_HEAD__EXCESS_WAIVED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop_pv') }} t0
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd') }} j6 on j6.KEY_HASH = j5.PARENT_KEY_HASH
    where (nullif(nullif(trim(j6.claimno), ''), '')) is not null

    union all

    -- branch 16: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW | child-key literal(s): AUG_CLAIM_EXCESS_HEAD.Excess Type Code=FRANCHISE
    select
        null,
        nullif(nullif(trim(j6.claimno), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'FRANCHISE' as AUG_CLAIM_EXCESS_HEAD__EXCESS_TYPE_CODE_CK,
        t0.franchise_excess as AUG_CLAIM_EXCESS_HEAD__EXCESS_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop_pv') }} t0
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd') }} j6 on j6.KEY_HASH = j5.PARENT_KEY_HASH
    where (nullif(nullif(trim(j6.claimno), ''), '')) is not null

    union all

    -- branch 17: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW | child-key literal(s): AUG_CLAIM_EXCESS_HEAD.Excess Type Code=PARTIAL_THEFT
    select
        null,
        nullif(nullif(trim(j6.claimno), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PARTIAL_THEFT' as AUG_CLAIM_EXCESS_HEAD__EXCESS_TYPE_CODE_CK,
        t0.partial_theft_excess as AUG_CLAIM_EXCESS_HEAD__EXCESS_AMOUNT,
        t0.is_partial_theft_excess_waived_off as AUG_CLAIM_EXCESS_HEAD__EXCESS_WAIVED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop_pv') }} t0
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd') }} j6 on j6.KEY_HASH = j5.PARENT_KEY_HASH
    where (nullif(nullif(trim(j6.claimno), ''), '')) is not null

    union all

    -- branch 18: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW | child-key literal(s): AUG_CLAIM_EXCESS_HEAD.Excess Type Code=PIN
    select
        null,
        nullif(nullif(trim(j6.claimno), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PIN' as AUG_CLAIM_EXCESS_HEAD__EXCESS_TYPE_CODE_CK,
        t0.pin_excess as AUG_CLAIM_EXCESS_HEAD__EXCESS_AMOUNT,
        t0.is_pin_excess_waived_off as AUG_CLAIM_EXCESS_HEAD__EXCESS_WAIVED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop_pv') }} t0
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd') }} j6 on j6.KEY_HASH = j5.PARENT_KEY_HASH
    where (nullif(nullif(trim(j6.claimno), ''), '')) is not null

    union all

    -- branch 19: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW | child-key literal(s): AUG_CLAIM_EXCESS_HEAD.Excess Type Code=RALLY
    select
        null,
        nullif(nullif(trim(j6.claimno), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'RALLY' as AUG_CLAIM_EXCESS_HEAD__EXCESS_TYPE_CODE_CK,
        t0.rally_excess as AUG_CLAIM_EXCESS_HEAD__EXCESS_AMOUNT,
        t0.is_rally_excess_waived_off as AUG_CLAIM_EXCESS_HEAD__EXCESS_WAIVED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop_pv') }} t0
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd') }} j6 on j6.KEY_HASH = j5.PARENT_KEY_HASH
    where (nullif(nullif(trim(j6.claimno), ''), '')) is not null

    union all

    -- branch 20: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW | child-key literal(s): AUG_CLAIM_EXCESS_HEAD.Excess Type Code=THEFT
    select
        null,
        nullif(nullif(trim(j6.claimno), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'THEFT' as AUG_CLAIM_EXCESS_HEAD__EXCESS_TYPE_CODE_CK,
        t0.theft_excess as AUG_CLAIM_EXCESS_HEAD__EXCESS_AMOUNT,
        t0.is_theft_excess_waived_off as AUG_CLAIM_EXCESS_HEAD__EXCESS_WAIVED_INDICATOR,
        t0.theft_excess_waived_off_reason as AUG_CLAIM_EXCESS_HEAD__EXCESS_WAIVER_REASON,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop_pv') }} t0
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd') }} j6 on j6.KEY_HASH = j5.PARENT_KEY_HASH
    where (nullif(nullif(trim(j6.claimno), ''), '')) is not null

    union all

    -- branch 21: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW | child-key literal(s): AUG_CLAIM_EXCESS_HEAD.Excess Type Code=TOTAL_THEFT
    select
        null,
        nullif(nullif(trim(j6.claimno), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'TOTAL_THEFT' as AUG_CLAIM_EXCESS_HEAD__EXCESS_TYPE_CODE_CK,
        t0.total_theft_excess as AUG_CLAIM_EXCESS_HEAD__EXCESS_AMOUNT,
        t0.is_total_theft_excess_waived_off as AUG_CLAIM_EXCESS_HEAD__EXCESS_WAIVED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop_pv') }} t0
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd') }} j6 on j6.KEY_HASH = j5.PARENT_KEY_HASH
    where (nullif(nullif(trim(j6.claimno), ''), '')) is not null

    union all

    -- branch 22: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW | child-key literal(s): AUG_CLAIM_EXCESS_HEAD.Excess Type Code=UNDERWRITER
    select
        null,
        nullif(nullif(trim(j6.claimno), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'UNDERWRITER' as AUG_CLAIM_EXCESS_HEAD__EXCESS_TYPE_CODE_CK,
        t0.underwriter_excess as AUG_CLAIM_EXCESS_HEAD__EXCESS_AMOUNT,
        t0.is_underwriter_excess_waived_off as AUG_CLAIM_EXCESS_HEAD__EXCESS_WAIVED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop_pv') }} t0
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd') }} j6 on j6.KEY_HASH = j5.PARENT_KEY_HASH
    where (nullif(nullif(trim(j6.claimno), ''), '')) is not null

    union all

    -- branch 23: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW | child-key literal(s): AUG_CLAIM_EXCESS_HEAD.Excess Type Code=VOLUNTARY
    select
        null,
        nullif(nullif(trim(j6.claimno), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'VOLUNTARY' as AUG_CLAIM_EXCESS_HEAD__EXCESS_TYPE_CODE_CK,
        null,
        t0.is_voluntary_excess_waived_off as AUG_CLAIM_EXCESS_HEAD__EXCESS_WAIVED_INDICATOR,
        t0.voluntary_excess_waived_off_reason as AUG_CLAIM_EXCESS_HEAD__EXCESS_WAIVER_REASON,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop_pv') }} t0
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd') }} j6 on j6.KEY_HASH = j5.PARENT_KEY_HASH
    where (nullif(nullif(trim(j6.claimno), ''), '')) is not null

    union all

    -- branch 24: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW | child-key literal(s): AUG_CLAIM_EXCESS_HEAD.Excess Type Code=SALVAGE_OR_OTHER
    select
        null,
        nullif(nullif(trim(j6.claimno), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SALVAGE_OR_OTHER' as AUG_CLAIM_EXCESS_HEAD__EXCESS_TYPE_CODE_CK,
        t0.salvage_or_other_deductible as AUG_CLAIM_EXCESS_HEAD__EXCESS_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop_pv') }} t0
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd') }} j6 on j6.KEY_HASH = j5.PARENT_KEY_HASH
    where (nullif(nullif(trim(j6.claimno), ''), '')) is not null

    union all

    -- branch 25: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW | child-key literal(s): AUG_CLAIM_EXCESS_HEAD.Excess Type Code=VOLUNTARY_2
    select
        null,
        nullif(nullif(trim(j6.claimno), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'VOLUNTARY_2' as AUG_CLAIM_EXCESS_HEAD__EXCESS_TYPE_CODE_CK,
        t0.voluntary_excess_2 as AUG_CLAIM_EXCESS_HEAD__EXCESS_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop_pv') }} t0
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd') }} j6 on j6.KEY_HASH = j5.PARENT_KEY_HASH
    where (nullif(nullif(trim(j6.claimno), ''), '')) is not null

    union all

    -- branch 26: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW | child-key literal(s): AUG_CLAIM_RECOVERY_EXPENSE_LINE.Expense Head Code=CONVEYANCE
    select
        null,
        nullif(nullif(trim(j6.claimno), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CONVEYANCE' as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_HEAD_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.km_travelled as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_QUANTITY,
        t0.rate_per_km as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_RATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop_pv') }} t0
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd') }} j6 on j6.KEY_HASH = j5.PARENT_KEY_HASH
    where (nullif(nullif(trim(j6.claimno), ''), '')) is not null

    union all

    -- branch 27: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW | child-key literal(s): AUG_CLAIM_RECOVERY_EXPENSE_LINE.Expense Head Code=MISCELLANEOUS
    select
        null,
        nullif(nullif(trim(j6.claimno), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'MISCELLANEOUS' as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_HEAD_CODE_CK,
        null,
        t0.misc_expenses as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop_pv') }} t0
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd') }} j6 on j6.KEY_HASH = j5.PARENT_KEY_HASH
    where (nullif(nullif(trim(j6.claimno), ''), '')) is not null

    union all

    -- branch 28: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW | child-key literal(s): AUG_CLAIM_RECOVERY_EXPENSE_LINE.Expense Head Code=PHOTOGRAPH_CD
    select
        null,
        nullif(nullif(trim(j6.claimno), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PHOTOGRAPH_CD' as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_HEAD_CODE_CK,
        null,
        t0.photogrphcd_charges as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop_pv') }} t0
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd') }} j6 on j6.KEY_HASH = j5.PARENT_KEY_HASH
    where (nullif(nullif(trim(j6.claimno), ''), '')) is not null

    union all

    -- branch 29: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW | child-key literal(s): AUG_CLAIM_RECOVERY_EXPENSE_LINE.Expense Head Code=PROFESSIONAL
    select
        null,
        nullif(nullif(trim(j6.claimno), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PROFESSIONAL' as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_HEAD_CODE_CK,
        null,
        t0.professional_charge as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop_pv') }} t0
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd') }} j6 on j6.KEY_HASH = j5.PARENT_KEY_HASH
    where (nullif(nullif(trim(j6.claimno), ''), '')) is not null

    union all

    -- branch 30: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW | child-key literal(s): AUG_CLAIM_RECOVERY_EXPENSE_LINE.Expense Head Code=TPA_FEE
    select
        null,
        nullif(nullif(trim(j6.claimno), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'TPA_FEE' as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_HEAD_CODE_CK,
        null,
        t0.tpa_fee as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_AMOUNT,
        t0.tpa_fee_currency as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_CURRENCY_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop_pv') }} t0
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd') }} j6 on j6.KEY_HASH = j5.PARENT_KEY_HASH
    where (nullif(nullif(trim(j6.claimno), ''), '')) is not null

    union all

    -- branch 31: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
    select
        null,
        nullif(nullif(trim(j6.claimno), ''), '') as CLAIM_BK,
        null, null, null, null, null,
        nullif('BANKACCT:' || nullif(trim(t0.account_number), ''), '') as PAYMENT_INSTRUMENT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.type_of_expenses as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_HEAD_CODE_CK,
        null, null, null, null,
        t0.type_of_expenses as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_HEAD_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.account_type as INSTRUMENT_DEFINITION__ACCOUNT_TYPE,
        t0.bank_name as INSTRUMENT_DEFINITION__BANK_NAME,
        null,
        t0.ifsc as INSTRUMENT_DEFINITION__IFSC_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop_pv') }} t0
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd') }} j6 on j6.KEY_HASH = j5.PARENT_KEY_HASH
    where (coalesce(nullif('BANKACCT:' || nullif(trim(t0.account_number), ''), ''), nullif(nullif(trim(j6.claimno), ''), ''))) is not null

    union all

    -- branch 32: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW | child-key literal(s): AUG_CLAIM_TAT_BREACH.Process Step Code=KO_INSPECTION
    select
        null,
        nullif(nullif(trim(j6.claimno), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'KO_INSPECTION' as AUG_CLAIM_TAT_BREACH__PROCESS_STEP_CODE_CK,
        t0.tat_exceeded_for_delay_in_ko_inspection as AUG_CLAIM_TAT_BREACH__TAT_BREACH_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop_pv') }} t0
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd') }} j6 on j6.KEY_HASH = j5.PARENT_KEY_HASH
    where (nullif(nullif(trim(j6.claimno), ''), '')) is not null

    union all

    -- branch 33: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW | child-key literal(s): AUG_CLAIM_TAT_BREACH.Process Step Code=PRELIMINARY_SURVEY_REPORT
    select
        null,
        nullif(nullif(trim(j6.claimno), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PRELIMINARY_SURVEY_REPORT' as AUG_CLAIM_TAT_BREACH__PROCESS_STEP_CODE_CK,
        t0.tat_exceeded_for_delay_in_preliminary_survey_report_psr as AUG_CLAIM_TAT_BREACH__TAT_BREACH_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop_pv') }} t0
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd') }} j6 on j6.KEY_HASH = j5.PARENT_KEY_HASH
    where (nullif(nullif(trim(j6.claimno), ''), '')) is not null

    union all

    -- branch 34: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW | child-key literal(s): AUG_CLAIM_TAT_BREACH.Process Step Code=RE_INSPECTION
    select
        null,
        nullif(nullif(trim(j6.claimno), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'RE_INSPECTION' as AUG_CLAIM_TAT_BREACH__PROCESS_STEP_CODE_CK,
        t0.tat_exceeded_for_delay_in_re_inspection as AUG_CLAIM_TAT_BREACH__TAT_BREACH_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop_pv') }} t0
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd') }} j6 on j6.KEY_HASH = j5.PARENT_KEY_HASH
    where (nullif(nullif(trim(j6.claimno), ''), '')) is not null

    union all

    -- branch 35: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW | child-key literal(s): AUG_CLAIM_TAT_BREACH.Process Step Code=SPOT_SURVEY
    select
        null,
        nullif(nullif(trim(j6.claimno), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SPOT_SURVEY' as AUG_CLAIM_TAT_BREACH__PROCESS_STEP_CODE_CK,
        t0.tat_exceeded_for_delay_in_spot_survey as AUG_CLAIM_TAT_BREACH__TAT_BREACH_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop_pv') }} t0
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd') }} j6 on j6.KEY_HASH = j5.PARENT_KEY_HASH
    where (nullif(nullif(trim(j6.claimno), ''), '')) is not null

    union all

    -- branch 36: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW | child-key literal(s): AUG_CLAIM_TAT_BREACH.Process Step Code=SURVEY_CONFIRMATION
    select
        null,
        nullif(nullif(trim(j6.claimno), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SURVEY_CONFIRMATION' as AUG_CLAIM_TAT_BREACH__PROCESS_STEP_CODE_CK,
        t0.tat_exceeded_for_delay_in_survey_confirmation as AUG_CLAIM_TAT_BREACH__TAT_BREACH_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop_pv') }} t0
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd') }} j6 on j6.KEY_HASH = j5.PARENT_KEY_HASH
    where (nullif(nullif(trim(j6.claimno), ''), '')) is not null

    union all

    -- branch 37: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW | child-key literal(s): AUG_CLAIM_TAT_BREACH.Process Step Code=WORK_APPROVAL
    select
        null,
        nullif(nullif(trim(j6.claimno), ''), '') as CLAIM_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'WORK_APPROVAL' as AUG_CLAIM_TAT_BREACH__PROCESS_STEP_CODE_CK,
        t0.tat_exceeded_for_delay_in_work_approval as AUG_CLAIM_TAT_BREACH__TAT_BREACH_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop_pv') }} t0
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd_claim_risk') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__clm_cd') }} j6 on j6.KEY_HASH = j5.PARENT_KEY_HASH
    where (nullif(nullif(trim(j6.claimno), ''), '')) is not null

    union all

    -- branch 38: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW | child-key literal(s): AUG_PARTY_IDENTIFICATION.Identification Type Code=PAN
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(t0.party_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PAN' as AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.name_as_per_pan as AUG_PARTY_IDENTIFICATION__NAME_AS_PER_IDENTIFICATION_DOCUMENT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop_pv') }} t0
    where (nullif(nullif(trim(t0.party_code), ''), '')) is not null

    union all

    -- branch 39: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=PAN
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(t0.party_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        'PAN' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.pan_no as PARTY_IDENTIFICATION__PAN_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop_pv') }} t0
    where (nullif(nullif(trim(t0.party_code), ''), '')) is not null

    union all

    -- branch 40: MAXI_MOTOR_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=PAN
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(t0.tds_claimant_party_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        'PAN' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.tds_pan_number as PARTY_IDENTIFICATION__PAN_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__clm_cd_claim_risk_risk_attr_msp_msd_prop_pv') }} t0
    where (nullif(nullif(trim(t0.tds_claimant_party_code), ''), '')) is not null

    union all

    -- branch 41: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PAYMENT_INFORMATION
    select
        null, null, null,
        nullif(nullif(trim(t0.transaction_id),''), '') as FINANCIAL_TRANSACTION_BK,
        null, null, null,
        nullif(nullif(trim(t0.cheque_number),''), '') as PAYMENT_INSTRUMENT_BK,
        null, null, null, null, null, null, null, null, null, null, null,
        1 as __LNK_FINTXN_INSTRUMENT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.collection_date as AUG_FIN_RECEIPT__COLLECTION_DATE,
        t0.collection_source as AUG_FIN_RECEIPT__COLLECTION_SOURCE,
        t0.sub_code as AUG_FIN_RECEIPT__COLLECTION_SUB_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.collection_mode as FINTXN_PREMIUM__COLLECTION_MODE,
        t0.collection_amount as FIN_RECEIPT__AMOUNT_RECEIVED,
        t0.cheque_realisation_date as FIN_RECEIPT__REALISATION_DATE,
        t0.receipt_generation_date as FIN_RECEIPT__RECEIPT_DATE,
        t0.receipt_number as FIN_RECEIPT__RECEIPT_NUMBER,
        t0.collection_type as FIN_RECEIPT__RECEIPT_TYPE,
        null, null, null, null,
        t0.cheque_status as INSTRUMENT_DEFINITION__INSTRUMENT_STATUS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_policy_payment_info') }} t0
    where (coalesce(nullif(nullif(trim(t0.cheque_number),''), ''), nullif(nullif(trim(t0.transaction_id),''), ''))) is not null

    union all

    -- branch 42: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        nullif(nullif(trim(t0.pre_inspection_number), ''), '') as ASSESSMENT_BK,
        null,
        nullif(nullif(trim(t0.imd_code), ''), '') as DISTRIBUTION_CHANNEL_BK,
        null,
        nullif(nullif(trim(t0.rta_code), ''), '') as LOCATION_BK,
        nullif(nullif(trim(t0.branch_code), ''), '') as ORG_UNIT_BK,
        nullif(nullif(trim(j3.policy_holder_code), ''), '') as PARTY_BK,
        nullif(nullif(trim(t0.payment_card_no), ''), '') as PAYMENT_INSTRUMENT_BK,
        nullif(nullif(trim(j3.policy_number), ''), '') as POLICY_BK,
        nullif(nullif(trim(j3.product_code), ''), '') as PRODUCT_BK,
        nullif(nullif(trim(t0.app_no), ''), '') as PROPOSAL_BK,
        null,
        nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), '') as RISK_OBJECT_BK,
        null,
        1 as __LNK_CHANNEL_ORG_UNIT,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        1 as __LNK_PROPOSAL_ASSESSMENT,
        1 as __LNK_PROPOSAL_RISK_OBJECT,
        1 as __LNK_RISK_OBJECT_ASSESSMENT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.banca_product_name as AUG_PRODUCT_DEFINITION__PARTNER_PRODUCT_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rta_district as COMMON_ADMIN_GEOGRAPHY__DISTRICT_NAME,
        t0.rta_pincode as COMMON_ADMIN_GEOGRAPHY__PIN_CODE,
        null,
        t0.rta_state as COMMON_ADMIN_GEOGRAPHY__STATE_NAME,
        null, null, null,
        t0.go_green as COMMON_COMMUNICATION_PREFERENCE__GO_GREEN_OPT_IN_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.payment_card_type as INSTRUMENT_DEFINITION__CARD_TYPE,
        null, null,
        t0.payment_card_expiry as INSTRUMENT_DEFINITION__VALID_TO_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PASSPORT' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.passport_number as PARTY_IDENTIFICATION__PASSPORT_NUMBER,
        null, null, null, null, null, null, null, null, null, null,
        t0.despatch_type as POLICY_DELIVERY__DELIVERY_MODE,
        t0.despatch_date as POLICY_DELIVERY__DISPATCH_DATE,
        null,
        t0.despatch_number as POLICY_DELIVERY__TRACKING_REFERENCE,
        t0.active_tp_flag as POLICY_EXTERNAL_TP_LINK__EXTERNAL_TP_POLICY_INDICATOR,
        t0.active_tp_insurance_company_name as POLICY_EXTERNAL_TP_LINK__TP_INSURER_NAME,
        t0.active_tp_policy_expiry_date as POLICY_EXTERNAL_TP_LINK__TP_POLICY_END_DATE,
        t0.active_tp_policy_number as POLICY_EXTERNAL_TP_LINK__TP_POLICY_NUMBER,
        t0.active_tp_policy_inception_date as POLICY_EXTERNAL_TP_LINK__TP_POLICY_START_DATE,
        t0.active_tp_policy_term as POLICY_EXTERNAL_TP_LINK__TP_TENURE_YEARS,
        null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_policy_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_policy_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (coalesce(nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), ''), nullif(nullif(trim(j3.policy_holder_code), ''), ''), nullif(nullif(trim(j3.policy_number), ''), ''), nullif(nullif(trim(j3.product_code), ''), ''), nullif(nullif(trim(t0.app_no), ''), ''), nullif(nullif(trim(t0.branch_code), ''), ''), nullif(nullif(trim(t0.imd_code), ''), ''), nullif(nullif(trim(t0.payment_card_no), ''), ''), nullif(nullif(trim(t0.pre_inspection_number), ''), ''), nullif(nullif(trim(t0.rta_code), ''), ''))) is not null

    union all

    -- branch 43: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(j3.policy_holder_code), ''), '') as PARTY_BK,
        null,
        nullif(coalesce(nullif(trim(t0.policy_number), ''), nullif(trim(j3.policy_number), '')), '') as POLICY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        'BANK_CUSTOMER_ID' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.bank_customer_id as PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        t0.stage as POLICY_LIFECYCLE__LIFECYCLE_STAGE,
        null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_policy_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_policy_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (coalesce(nullif(coalesce(nullif(trim(t0.policy_number), ''), nullif(trim(j3.policy_number), '')), ''), nullif(nullif(trim(j3.policy_holder_code), ''), ''))) is not null

    union all

    -- branch 44: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(j3.policy_holder_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        'CRN' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.crn_no as PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_policy_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_policy_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_holder_code), ''), '')) is not null

    union all

    -- branch 45: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_POLICY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(j3.policy_holder_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        'EIA' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null,
        t0.eia_number as PARTY_IDENTIFICATION__EIA_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_policy_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_policy_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_holder_code), ''), '')) is not null

    union all

    -- branch 46: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(j5.party_code),''), '') as PARTY_BK,
        nullif(nullif(trim(t0.credit_card_number),''), '') as PAYMENT_INSTRUMENT_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        nullif(trim(t0.bank_account_number),'') as AUG_PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK,
        null, null,
        t0.approvedrejected_by as AUG_PARTY_BANKING__APPROVED_OR_REJECTED_BY_USER_REFERENCE,
        t0.approvedrejected_date as AUG_PARTY_BANKING__APPROVED_OR_REJECTED_DATE,
        null,
        t0.remarks as AUG_PARTY_BANKING__BANK_RECORD_REMARKS,
        t0.neft_status as AUG_PARTY_BANKING__NEFT_VALIDATION_STATUS,
        t0.payee_name_as_per_bank_record as AUG_PARTY_BANKING__PAYEE_NAME_AS_PER_BANK_RECORD,
        t0.pennydropless_flag as AUG_PARTY_BANKING__PENNY_DROP_SKIPPED_INDICATOR,
        t0.penny_score as AUG_PARTY_BANKING__PENNY_DROP_VERIFICATION_SCORE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PASSPORT' as AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.passport_issue_country as AUG_PARTY_IDENTIFICATION__IDENTIFICATION_ISSUING_COUNTRY,
        null, null, null, null, null,
        t0.passport_file_no as AUG_PARTY_IDENTIFICATION__PASSPORT_FILE_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.credit_card_type as INSTRUMENT_DEFINITION__CARD_TYPE,
        null, null,
        t0.expiry_date as INSTRUMENT_DEFINITION__VALID_TO_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        nullif(trim(t0.bank_account_number),'') as PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK,
        t0.name_as_per_bank_ac as PARTY_BANKING__ACCOUNT_HOLDER_NAME,
        t0.bank_account_number as PARTY_BANKING__ACCOUNT_NUMBER_MASKED,
        t0.account_type as PARTY_BANKING__ACCOUNT_TYPE,
        t0.bank_name as PARTY_BANKING__BANK_NAME,
        t0.bank_branch_name as PARTY_BANKING__BRANCH_NAME,
        t0.ifsc as PARTY_BANKING__IFSC_CODE,
        t0.micr as PARTY_BANKING__MICR_CODE,
        t0.primary_secondary as PARTY_BANKING__PRIMARY_ACCOUNT_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PASSPORT' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.passport_issue_date as PARTY_IDENTIFICATION__IDENTIFICATION_ISSUE_DATE,
        null, null, null, null, null, null, null,
        t0.passport_expiry_date as PARTY_IDENTIFICATION__PASSPORT_EXPIRY_DATE,
        t0.passport_number as PARTY_IDENTIFICATION__PASSPORT_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_msp_msd_prop_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_msp_msd_prop') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_msp_msd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_msp') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls') }} j5 on j5.KEY_HASH = j4.PARENT_KEY_HASH
    where (coalesce(nullif(nullif(trim(j5.party_code),''), ''), nullif(nullif(trim(t0.credit_card_number),''), ''))) is not null

    union all

    -- branch 47: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null,
        nullif(nullif(trim(t0.agent_channel), ''), '') as DISTRIBUTION_CHANNEL_BK,
        null,
        nullif(md5(normalise(upper(nullif(trim(coalesce(t0.correspondence_local_address_line_1,'') || ' ' || coalesce(t0.correspondence_local_address_line_2,'') || ' ' || coalesce(t0.correspondence_local_address_line_3,'') || ' ' || coalesce(t0.correspondence_local_address_city_town_village,'') || ' ' || coalesce(t0.correspondence_local_address_district,'') || ' ' || coalesce(t0.correspondence_local_address_state,'') || ' ' || coalesce(t0.correspondence_local_address_country,'') || ' ' || coalesce(t0.local_address_pin_code,'')), '')))), '') as LOCATION_BK,
        nullif(nullif(trim(t0.location_code), ''), '') as ORG_UNIT_BK,
        nullif(nullif(trim(j3.party_code), ''), '') as PARTY_BK,
        null,
        nullif(nullif(trim(j4.policy_number), ''), '') as POLICY_BK,
        nullif(nullif(trim(t0.product_code), ''), '') as PRODUCT_BK,
        null, null, null, null,
        1 as __LNK_CHANNEL_ORG_UNIT,
        null, null, null, null, null,
        1 as __LNK_PARTY_CHANNEL,
        1 as __LNK_PARTY_LOCATION,
        1 as __LNK_PARTY_ORG_UNIT,
        1 as __LNK_POLICY_CHANNEL,
        1 as __LNK_POLICY_ORG_UNIT,
        1 as __LNK_POLICY_PARTY,
        1 as __LNK_POLICY_PRODUCT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.overall_rating as AUG_COMMON_CLASSIFICATION__OVERALL_RATING_GRADE,
        t0.profile as AUG_COMMON_CLASSIFICATION__PROFILE_CODE,
        t0.reference_code as AUG_COMMON_CLASSIFICATION__REFERENCE_CODE,
        t0.gh_type_of_user as AUG_COMMON_CLASSIFICATION__USER_TYPE_CODE,
        t0.communication_and_preferred_language as AUG_COMMON_COMMUNICATION_PREFERENCE__COMMUNICATION_AND_LANGUAGE_PREFERENCE_TEXT,
        t0.preferred_mode_of_alert as AUG_COMMON_COMMUNICATION_PREFERENCE__PREFERRED_ALERT_CHANNEL_CODE,
        t0.declaration as AUG_COMMON_CONSENT__DECLARATION_TEXT,
        null, null, null, null, null, null,
        t0.other_relationship as AUG_LNK_PARTY_ROLE_CORE__OTHER_RELATIONSHIP_DESCRIPTION,
        t0.relationship_with_hni as AUG_LNK_PARTY_ROLE_CORE__RELATIONSHIP_TO_HIGH_NET_WORTH_CUSTOMER,
        t0.relationship as AUG_LNK_PARTY_ROLE_CORE__RELATIONSHIP_TO_INSURED,
        t0.relationship_with_employee as AUG_LNK_PARTY_ROLE_CORE__RELATIONSHIP_TO_INSURER_EMPLOYEE,
        t0.relationship_with_prive as AUG_LNK_PARTY_ROLE_CORE__RELATIONSHIP_TO_PRIVE_CUSTOMER,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.emandate_details as AUG_PARTY_CONSENT_MANDATE__MANDATE_DETAIL_TEXT,
        'CORRESPONDENCE' as AUG_PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE_CK,
        t0.address_proof_effective_date as AUG_PARTY_CONTACT_ADDRESS_LINK__ADDRESS_PROOF_EFFECTIVE_DATE,
        null, null,
        t0.is_the_mailingcommunication_address_same_as_the_primary_address as AUG_PARTY_CONTACT_ADDRESS_LINK__SAME_AS_PRIMARY_ADDRESS_INDICATOR,
        t0.employers_details as AUG_PARTY_EMPLOYMENT__EMPLOYER_DETAIL_TEXT,
        t0.banking_details as AUG_PARTY_FINANCIAL_PROFILE__BANKING_DETAIL_TEXT,
        t0.credit_card_details as AUG_PARTY_FINANCIAL_PROFILE__CREDIT_CARD_DETAIL_TEXT,
        t0.credit_limit_cin_no as AUG_PARTY_FINANCIAL_PROFILE__CREDIT_LIMIT_REFERENCE_TEXT,
        t0.filed_it_last_2_years as AUG_PARTY_FINANCIAL_PROFILE__INCOME_TAX_RETURN_FILED_TWO_YEARS_INDICATOR,
        t0.monthly_gross_income as AUG_PARTY_FINANCIAL_PROFILE__MONTHLY_GROSS_INCOME,
        t0.monthly_income as AUG_PARTY_FINANCIAL_PROFILE__MONTHLY_INCOME,
        t0.nondisclosure_initiated as AUG_PARTY_FRAUD_PROFILE__NON_DISCLOSURE_ACTION_INITIATED_INDICATOR,
        t0.member_type as AUG_PARTY_GROUP_HOUSEHOLD__MEMBER_TYPE,
        t0.location_of_disability as AUG_PARTY_HEALTH_PROFILE__DISABILITY_BODY_LOCATION,
        t0.icd as AUG_PARTY_HEALTH_PROFILE__MEDICAL_CONDITION_ICD_CODE,
        t0.surgery_details as AUG_PARTY_HEALTH_PROFILE__SURGERY_DETAIL_TEXT,
        t0.branch as AUG_PARTY_HIERARCHY__BRANCH_REFERENCE,
        t0.transacts_business_with_other_bagic_office_also as AUG_PARTY_HIERARCHY__MULTI_OFFICE_BUSINESS_INDICATOR,
        t0.primary_branch as AUG_PARTY_HIERARCHY__PRIMARY_BRANCH_REFERENCE,
        t0.secondary_branch as AUG_PARTY_HIERARCHY__SECONDARY_BRANCH_REFERENCE,
        t0.transfer_case as AUG_PARTY_HIERARCHY__TRANSFER_CASE_REFERENCE,
        t0.transfer as AUG_PARTY_HIERARCHY__TRANSFER_INDICATOR,
        nullif(trim(t0.id_type),'') as AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.identification_proof_effective_date as AUG_PARTY_IDENTIFICATION__IDENTIFICATION_VALID_FROM_DATE,
        null, null, null, null, null, null, null,
        t0.board_name_for_basic_qualification as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__BASIC_QUALIFICATION_BOARD_NAME,
        t0.basic_qualifications_details as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__BASIC_QUALIFICATION_DETAIL_TEXT,
        t0.roll_no_for_basic_qualification as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__BASIC_QUALIFICATION_ROLL_NUMBER,
        t0.date_of_marriage as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__DATE_OF_MARRIAGE,
        t0.fatherspouse_name as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__FATHER_OR_SPOUSE_NAME,
        t0.irda_list_primary_profession as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__IRDAI_LISTED_PRIMARY_PROFESSION,
        t0.mothers_maiden_name as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__MOTHER_MAIDEN_NAME,
        t0.number_of_daughters as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__NUMBER_OF_DAUGHTERS,
        t0.number_of_son as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__NUMBER_OF_SONS,
        t0.other_occupation as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__OTHER_OCCUPATION_DESCRIPTION,
        t0.other_qualification as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__OTHER_QUALIFICATION,
        t0.primary_profession as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__PRIMARY_PROFESSION,
        t0.professional_qualification as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__PROFESSIONAL_QUALIFICATION,
        t0.qualifications_details as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__QUALIFICATION_DETAIL_TEXT,
        t0.month_of_passing as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__QUALIFICATION_PASSING_MONTH,
        t0.year_of_passing as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__QUALIFICATION_PASSING_YEAR,
        t0.undergrad as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__UNDERGRADUATE_QUALIFICATION,
        t0.ckyc_details as AUG_PARTY_KYC__CKYC_DETAIL_TEXT,
        t0.do_you_have_ckyc_number as AUG_PARTY_KYC__CKYC_NUMBER_HELD_INDICATOR,
        t0.kyc_details as AUG_PARTY_KYC__KYC_DETAIL_TEXT,
        t0.pop_optional as AUG_PARTY_KYC__OPTIONAL_SUPPORTING_PROOF_DOCUMENT_TYPE,
        t0.pop_primary as AUG_PARTY_KYC__PRIMARY_SUPPORTING_PROOF_DOCUMENT_TYPE,
        t0.poa_documents as AUG_PARTY_KYC__PROOF_OF_ADDRESS_DOCUMENT_TYPE,
        t0.poa_status as AUG_PARTY_KYC__PROOF_OF_ADDRESS_STATUS,
        t0.poa_document_status as AUG_PARTY_KYC__PROOF_OF_ADDRESS_VERIFICATION_STATUS,
        t0.poi_documents as AUG_PARTY_KYC__PROOF_OF_IDENTITY_DOCUMENT_TYPE,
        t0.poi_status as AUG_PARTY_KYC__PROOF_OF_IDENTITY_STATUS,
        t0.poi_document_status as AUG_PARTY_KYC__PROOF_OF_IDENTITY_VERIFICATION_STATUS,
        t0.background_of_candidate as AUG_PARTY_ONBOARDING_JOURNEY__CANDIDATE_BACKGROUND_DESCRIPTION,
        t0.insurancebankingfinancial_experience as AUG_PARTY_ONBOARDING_JOURNEY__INSURANCE_BANKING_FINANCE_EXPERIENCE_YEARS,
        t0.examinations_details_for_irda_code as AUG_PARTY_ONBOARDING_JOURNEY__LICENCE_EXAMINATION_DETAIL_TEXT,
        t0.previous_company_location as AUG_PARTY_ONBOARDING_JOURNEY__PREVIOUS_EMPLOYER_LOCATION,
        t0.previous_company_parent_imd_code as AUG_PARTY_ONBOARDING_JOURNEY__PREVIOUS_EMPLOYER_PARENT_INTERMEDIARY_CODE,
        t0.previous_company_parent_subimd_code as AUG_PARTY_ONBOARDING_JOURNEY__PREVIOUS_EMPLOYER_PARENT_SUB_INTERMEDIARY_CODE,
        t0.reason_for_leaving_remarks as AUG_PARTY_ONBOARDING_JOURNEY__PREVIOUS_EMPLOYMENT_LEAVING_REASON,
        t0.name_of_nongeneral_insurer_worked_for as AUG_PARTY_ONBOARDING_JOURNEY__PREVIOUS_NON_GENERAL_INSURER_NAME,
        t0.rejected_reason as AUG_PARTY_ONBOARDING_JOURNEY__REJECTION_REASON,
        t0.lower_tds_certificate as AUG_PARTY_PAYOUT_PROFILE__LOWER_TDS_CERTIFICATE_REFERENCE,
        t0.refund_to_pid_of_bg_holder_ac as AUG_PARTY_PAYOUT_PROFILE__REFUND_BENEFICIARY_PARTY_REFERENCE,
        t0.tds_code as AUG_PARTY_PAYOUT_PROFILE__TDS_CODE,
        t0.tds_code_desc as AUG_PARTY_PAYOUT_PROFILE__TDS_CODE_DESCRIPTION,
        t0.tds_details as AUG_PARTY_PAYOUT_PROFILE__TDS_DETAIL_TEXT,
        t0.issue_all_policies_in_electronic_format as AUG_PARTY_PREFERENCE_PROFILE__ELECTRONIC_POLICY_ISSUANCE_PREFERENCE_INDICATOR,
        t0.update_contact_details_in_all_policies as AUG_PARTY_PREFERENCE_PROFILE__PROPAGATE_CONTACT_UPDATE_TO_ALL_POLICIES_INDICATOR,
        t0.are_you_an_existing_bajaj_allianz_customer as AUG_PARTY_RELATIONSHIP_PROFILE__EXISTING_CUSTOMER_DECLARED_INDICATOR,
        null, null,
        t0.nominee_details as AUG_PARTY_RELATIONSHIP_PROFILE__NOMINEE_DETAIL_TEXT,
        t0.driving_license_experience as AUG_PARTY_VEHICLE_OWNER__DRIVING_EXPERIENCE_YEARS,
        null,
        t0.product_details as AUG_PRODUCT_DEFINITION__PRODUCT_DETAIL_TEXT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.category as COMMON_CLASSIFICATION__CATEGORY_CODE,
        null, null,
        t0.preferred_mode_of_communication as COMMON_COMMUNICATION_PREFERENCE__PREFERRED_CHANNEL_CODE,
        t0.languages_preferred as COMMON_COMMUNICATION_PREFERENCE__PREFERRED_LANGUAGE_CODE,
        t0.customer_consent as COMMON_CONSENT__CONSENT_GIVEN_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        t0.aml_verification_status as PARTY_AML_SCREENING__SCREENING_STATUS,
        null, null, null, null, null, null, null, null, null,
        t0.employer_name as PARTY_EMPLOYMENT__EMPLOYER_NAME,
        t0.employee_status as PARTY_EMPLOYMENT__EMPLOYMENT_STATUS,
        null,
        t0.income_source as PARTY_FINANCIAL_PROFILE__INCOME_SOURCE,
        t0.medicine_name as PARTY_HEALTH_PROFILE__CURRENT_MEDICATION_DETAIL,
        t0.physically_challenged as PARTY_HEALTH_PROFILE__DISABILITY_INDICATOR,
        t0.disability_percentage as PARTY_HEALTH_PROFILE__DISABILITY_PERCENTAGE,
        t0.height as PARTY_HEALTH_PROFILE__HEIGHT,
        t0.disease_name as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        t0.weight as PARTY_HEALTH_PROFILE__WEIGHT,
        t0.level as PARTY_HIERARCHY__HIERARCHY_LEVEL,
        t0.existing_partner_id as PARTY_HIERARCHY__REPORTING_PARENT_REFERENCE,
        t0.client_geography as PARTY_HIERARCHY__TERRITORY_CODE,
        'AADHAAR' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        t0.aadhaar_number as PARTY_IDENTIFICATION__AADHAAR_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.ckyc_number as PARTY_KYC__CKYC_NUMBER,
        t0.ckyc_status as PARTY_KYC__CKYC_REGISTRATION_STATUS,
        t0.kyc_timestamp as PARTY_KYC__KYC_COMPLETION_DATE,
        t0.kyc_verification as PARTY_KYC__KYC_STATUS,
        t0.application_date as PARTY_ONBOARDING_JOURNEY__ONBOARDING_START_DATE,
        t0.previous_company_name as PARTY_ONBOARDING_JOURNEY__PREVIOUS_EMPLOYER_NAME,
        t0.no_of_years_of_work_experience as PARTY_ONBOARDING_JOURNEY__PRIOR_WORK_EXPERIENCE_YEARS,
        null, null,
        t0.epolicy_required as POLICY_DELIVERY__EDELIVERY_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd') }} j4 on j4.KEY_HASH = j3.PARENT_KEY_HASH
    where (coalesce(nullif(md5(normalise(upper(nullif(trim(coalesce(t0.correspondence_local_address_line_1,'') || ' ' || coalesce(t0.correspondence_local_address_line_2,'') || ' ' || coalesce(t0.correspondence_local_address_line_3,'') || ' ' || coalesce(t0.correspondence_local_address_city_town_village,'') || ' ' || coalesce(t0.correspondence_local_address_district,'') || ' ' || coalesce(t0.correspondence_local_address_state,'') || ' ' || coalesce(t0.correspondence_local_address_country,'') || ' ' || coalesce(t0.local_address_pin_code,'')), '')))), ''), nullif(nullif(trim(j3.party_code), ''), ''), nullif(nullif(trim(j4.policy_number), ''), ''), nullif(nullif(trim(t0.agent_channel), ''), ''), nullif(nullif(trim(t0.location_code), ''), ''), nullif(nullif(trim(t0.product_code), ''), ''))) is not null

    union all

    -- branch 48: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null, null, null,
        nullif(md5(normalise(upper(nullif(trim(coalesce(t0.current_permanent_overseas_address_line_1,'') || ' ' || coalesce(t0.current_permanent_overseas_address_line_2,'') || ' ' || coalesce(t0.current_permanent_overseas_address_line_3,'') || ' ' || coalesce(t0.current_permanent_overseas_address_city_town_village,'') || ' ' || coalesce(t0.current_permanent_overseas_address_state_ut,'') || ' ' || coalesce(t0.current_permanent_overseas_address_country,'') || ' ' || coalesce(t0.current_permanent_overseas_address_pin_code,'')), '')))), '') as LOCATION_BK,
        null,
        nullif(nullif(trim(j3.party_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        1 as __LNK_PARTY_LOCATION,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        'CORRESPONDENCE' as AUG_PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE_CK,
        null, null,
        t0.flag_indicating_if_current_permanent_overseas_address_is_same_as_correspondence_local_address as AUG_PARTY_CONTACT_ADDRESS_LINK__SAME_AS_CORRESPONDENCE_ADDRESS_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        'AGE_PROOF' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null,
        t0.dob_proof as PARTY_IDENTIFICATION__AGE_PROOF_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (coalesce(nullif(md5(normalise(upper(nullif(trim(coalesce(t0.current_permanent_overseas_address_line_1,'') || ' ' || coalesce(t0.current_permanent_overseas_address_line_2,'') || ' ' || coalesce(t0.current_permanent_overseas_address_line_3,'') || ' ' || coalesce(t0.current_permanent_overseas_address_city_town_village,'') || ' ' || coalesce(t0.current_permanent_overseas_address_state_ut,'') || ' ' || coalesce(t0.current_permanent_overseas_address_country,'') || ' ' || coalesce(t0.current_permanent_overseas_address_pin_code,'')), '')))), ''), nullif(nullif(trim(j3.party_code), ''), ''))) is not null

    union all

    -- branch 49: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null, null, null,
        nullif(md5(normalise(upper(nullif(trim(coalesce(t0.current_permanent_overseas_address_line_1,'') || ' ' || coalesce(t0.current_permanent_overseas_address_line_2,'') || ' ' || coalesce(t0.current_permanent_overseas_address_line_3,'') || ' ' || coalesce(t0.current_permanent_overseas_address_city_town_village,'') || ' ' || coalesce(t0.current_permanent_overseas_address_state_ut,'') || ' ' || coalesce(t0.current_permanent_overseas_address_country,'') || ' ' || coalesce(t0.current_permanent_overseas_address_pin_code,'')), '')))), '') as LOCATION_BK,
        null,
        nullif(nullif(trim(j3.party_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        1 as __LNK_PARTY_LOCATION,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        'PERMANENT' as AUG_PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE_CK,
        null,
        t0.proof_of_address_submitted_for_current_permanent_overseas_addressothers as AUG_PARTY_CONTACT_ADDRESS_LINK__OTHER_ADDRESS_PROOF_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        'DRIVING_LICENCE' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null,
        t0.driving_license_expiry_date as PARTY_IDENTIFICATION__DRIVING_LICENCE_EXPIRY_DATE,
        t0.driving_license_number as PARTY_IDENTIFICATION__DRIVING_LICENCE_NUMBER,
        null, null, null, null, null,
        t0.driving_license_issue_date as PARTY_IDENTIFICATION__IDENTIFICATION_ISSUE_DATE,
        t0.driving_license_place_of_issue as PARTY_IDENTIFICATION__IDENTIFICATION_ISSUING_AUTHORITY,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (coalesce(nullif(md5(normalise(upper(nullif(trim(coalesce(t0.current_permanent_overseas_address_line_1,'') || ' ' || coalesce(t0.current_permanent_overseas_address_line_2,'') || ' ' || coalesce(t0.current_permanent_overseas_address_line_3,'') || ' ' || coalesce(t0.current_permanent_overseas_address_city_town_village,'') || ' ' || coalesce(t0.current_permanent_overseas_address_state_ut,'') || ' ' || coalesce(t0.current_permanent_overseas_address_country,'') || ' ' || coalesce(t0.current_permanent_overseas_address_pin_code,'')), '')))), ''), nullif(nullif(trim(j3.party_code), ''), ''))) is not null

    union all

    -- branch 50: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | child-key literal(s): AUG_PARTY_IDENTIFICATION.Identification Type Code=AADHAAR_EID
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(j3.party_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'AADHAAR_EID' as AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        t0.aadhaar_enrollment_no as AUG_PARTY_IDENTIFICATION__AADHAAR_ENROLMENT_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.party_code), ''), '')) is not null

    union all

    -- branch 51: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | child-key literal(s): AUG_PARTY_IDENTIFICATION.Identification Type Code=ABHA
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(j3.party_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ABHA' as AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null,
        t0.abha_id as AUG_PARTY_IDENTIFICATION__ABHA_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.party_code), ''), '')) is not null

    union all

    -- branch 52: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | child-key literal(s): AUG_PARTY_IDENTIFICATION.Identification Type Code=GSTIN
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(j3.party_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'GSTIN' as AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.composition_scheme as AUG_PARTY_IDENTIFICATION__GST_COMPOSITION_SCHEME_INDICATOR,
        t0.gst_payment_flag as AUG_PARTY_IDENTIFICATION__GST_PAYABLE_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.party_code), ''), '')) is not null

    union all

    -- branch 53: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | child-key literal(s): AUG_PARTY_IDENTIFICATION.Identification Type Code=DRIVING_LICENCE
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(j3.party_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'DRIVING_LICENCE' as AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null,
        t0.driving_license_details as AUG_PARTY_IDENTIFICATION__DRIVING_LICENCE_DETAIL_TEXT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.poa_driving_license_status as AUG_PARTY_IDENTIFICATION__PROOF_OF_ADDRESS_STATUS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.party_code), ''), '')) is not null

    union all

    -- branch 54: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | child-key literal(s): AUG_PARTY_IDENTIFICATION.Identification Type Code=EIA
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(j3.party_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EIA' as AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null,
        t0.eia_available as AUG_PARTY_IDENTIFICATION__EIA_AVAILABLE_INDICATOR,
        t0.eia_details as AUG_PARTY_IDENTIFICATION__EIA_DETAIL_TEXT,
        t0.eia_when_linked as AUG_PARTY_IDENTIFICATION__EIA_LINKAGE_DATE,
        t0.eia_credit_required as AUG_PARTY_IDENTIFICATION__EIA_POLICY_CREDIT_REQUIRED_INDICATOR,
        t0.eia_required as AUG_PARTY_IDENTIFICATION__EIA_REQUIRED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.party_code), ''), '')) is not null

    union all

    -- branch 55: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | child-key literal(s): AUG_PARTY_IDENTIFICATION.Identification Type Code=AADHAAR
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(j3.party_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'AADHAAR' as AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.name_as_per_aadhaar as AUG_PARTY_IDENTIFICATION__NAME_AS_PER_IDENTIFICATION_DOCUMENT,
        null, null, null,
        t0.poa_aadhar_card_status as AUG_PARTY_IDENTIFICATION__PROOF_OF_ADDRESS_STATUS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.party_code), ''), '')) is not null

    union all

    -- branch 56: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | child-key literal(s): AUG_PARTY_IDENTIFICATION.Identification Type Code=CKYC
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(j3.party_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CKYC' as AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.name_as_per_ckyc as AUG_PARTY_IDENTIFICATION__NAME_AS_PER_IDENTIFICATION_DOCUMENT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.party_code), ''), '')) is not null

    union all

    -- branch 57: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | child-key literal(s): AUG_PARTY_IDENTIFICATION.Identification Type Code=PAN
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(j3.party_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PAN' as AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.name_as_per_pan as AUG_PARTY_IDENTIFICATION__NAME_AS_PER_IDENTIFICATION_DOCUMENT,
        t0.pan_aadhaar_linked as AUG_PARTY_IDENTIFICATION__PAN_AADHAAR_LINKED_INDICATOR,
        null, null, null,
        t0.poi_pan_card_status as AUG_PARTY_IDENTIFICATION__PROOF_OF_IDENTITY_STATUS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.party_code), ''), '')) is not null

    union all

    -- branch 58: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | child-key literal(s): AUG_PARTY_IDENTIFICATION.Identification Type Code=PASSPORT
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(j3.party_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PASSPORT' as AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.passport_details as AUG_PARTY_IDENTIFICATION__PASSPORT_DETAIL_TEXT,
        t0.passport_file_no as AUG_PARTY_IDENTIFICATION__PASSPORT_FILE_NUMBER,
        t0.poa_passport_status as AUG_PARTY_IDENTIFICATION__PROOF_OF_ADDRESS_STATUS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.party_code), ''), '')) is not null

    union all

    -- branch 59: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | child-key literal(s): AUG_PARTY_IDENTIFICATION.Identification Type Code=NREGA
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(j3.party_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NREGA' as AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.poa_nrega_job_card_status as AUG_PARTY_IDENTIFICATION__PROOF_OF_ADDRESS_STATUS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.party_code), ''), '')) is not null

    union all

    -- branch 60: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | child-key literal(s): AUG_PARTY_IDENTIFICATION.Identification Type Code=FORM60
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(j3.party_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'FORM60' as AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.poi_form_60_status as AUG_PARTY_IDENTIFICATION__PROOF_OF_IDENTITY_STATUS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.party_code), ''), '')) is not null

    union all

    -- branch 61: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | child-key literal(s): AUG_PARTY_IDENTIFICATION.Identification Type Code=GSTIN_STATEWISE
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(j3.party_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'GSTIN_STATEWISE' as AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.statewise_gstin_details as AUG_PARTY_IDENTIFICATION__STATE_WISE_GSTIN_DETAIL_TEXT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.party_code), ''), '')) is not null

    union all

    -- branch 62: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | child-key literal(s): AUG_PARTY_IDENTIFICATION.Identification Type Code=AADHAAR_VID
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(j3.party_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'AADHAAR_VID' as AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null,
        t0.vid as AUG_PARTY_IDENTIFICATION__AADHAAR_VIRTUAL_IDENTIFIER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.party_code), ''), '')) is not null

    union all

    -- branch 63: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | child-key literal(s): LNK_ROLE_AGENT.Role Type=AGENT
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(j3.party_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null,
        'AGENT' as ROLE_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'AGENT' as LNK_ROLE_AGENT__ROLE_TYPE_CK,
        t0.intermediary_type as LNK_ROLE_AGENT__AGENCY_TYPE,
        t0.date_of_issue_of_appointment as LNK_ROLE_AGENT__APPOINTMENT_DATE,
        t0.irda_code as LNK_ROLE_AGENT__IRDAI_AGENT_LICENCE_NUMBER,
        t0.license_type as LNK_ROLE_AGENT__LICENCE_CATEGORY,
        t0.license_expiry_date as LNK_ROLE_AGENT__LICENCE_EXPIRY_DATE,
        t0.license_issue_date as LNK_ROLE_AGENT__LICENCE_ISSUE_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.party_code), ''), '')) is not null

    union all

    -- branch 64: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | child-key literal(s): LNK_ROLE_CUSTOMER.Role Type=CUSTOMER
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(j3.party_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null,
        'CUSTOMER' as ROLE_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CUSTOMER' as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        t0.blacklisted as LNK_ROLE_CUSTOMER__BLACKLIST_INDICATOR,
        t0.reason_for_blacklisting as LNK_ROLE_CUSTOMER__BLACKLIST_REASON,
        t0.customer_consent_for_data_sharing as LNK_ROLE_CUSTOMER__CONSENT_FOR_DATA_SHARING_INDICATOR,
        t0.hni_flag as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.party_code), ''), '')) is not null

    union all

    -- branch 65: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | child-key literal(s): LNK_ROLE_EMPLOYEE.Role Type=EMPLOYEE
    select
        null, null, null, null, null, null,
        nullif('EMP:' || nullif(trim(t0.bagic_employee_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null,
        'EMPLOYEE' as ROLE_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EMPLOYEE' as LNK_ROLE_EMPLOYEE__ROLE_TYPE_CK,
        null,
        t0.bagic_employee_code as LNK_ROLE_EMPLOYEE__EMPLOYEE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp_pv') }} t0
    where (nullif('EMP:' || nullif(trim(t0.bagic_employee_code), ''), '')) is not null

    union all

    -- branch 66: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | child-key literal(s): LNK_ROLE_EMPLOYEE.Role Type=EMPLOYEE
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(j3.party_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null,
        'EMPLOYEE' as ROLE_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EMPLOYEE' as LNK_ROLE_EMPLOYEE__ROLE_TYPE_CK,
        t0.department as LNK_ROLE_EMPLOYEE__DEPARTMENT,
        t0.employee_code as LNK_ROLE_EMPLOYEE__EMPLOYEE_CODE,
        t0.function as LNK_ROLE_EMPLOYEE__FUNCTION,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.party_code), ''), '')) is not null

    union all

    -- branch 67: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW | child-key literal(s): LNK_ROLE_PROVIDER.Role Type=PROVIDER
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(j3.party_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null,
        'PROVIDER' as ROLE_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        'PROVIDER' as LNK_ROLE_PROVIDER__ROLE_TYPE_CK,
        t0.supplier_location as LNK_ROLE_PROVIDER__SERVICE_REGION,
        t0.scope_of_supplier as LNK_ROLE_PROVIDER__SERVICE_SCOPE_DESCRIPTION,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.party_code), ''), '')) is not null

    union all

    -- branch 68: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(j3.party_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        'EIA' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null,
        t0.eia_number as PARTY_IDENTIFICATION__EIA_NUMBER,
        null, null, null, null, null, null, null, null,
        t0.e_insurance_demat_account_verified as PARTY_IDENTIFICATION__IDENTIFICATION_VERIFIED_INDICATOR,
        t0.insurance_repository_code as PARTY_IDENTIFICATION__INSURANCE_REPOSITORY_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.party_code), ''), '')) is not null

    union all

    -- branch 69: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(j3.party_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        nullif(trim(t0.id_type),'') as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null,
        t0.expiry_date as PARTY_IDENTIFICATION__IDENTIFICATION_EXPIRY_DATE,
        null, null,
        t0.id_number as PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER,
        t0.id_type as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.party_code), ''), '')) is not null

    union all

    -- branch 70: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(j3.party_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        'GSTIN' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null,
        t0.gstinuin as PARTY_IDENTIFICATION__GSTIN,
        t0.gstn_regn_status as PARTY_IDENTIFICATION__GST_REGISTRATION_STATUS,
        t0.gstn_taxpayer_type as PARTY_IDENTIFICATION__GST_TAXPAYER_TYPE,
        null,
        t0.gstin_issuance_dt as PARTY_IDENTIFICATION__IDENTIFICATION_ISSUE_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.party_code), ''), '')) is not null

    union all

    -- branch 71: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(j3.party_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        'NREGA' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.nrega_job_card as PARTY_IDENTIFICATION__NREGA_CARD_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.party_code), ''), '')) is not null

    union all

    -- branch 72: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(j3.party_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        'PAN' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.pan_no as PARTY_IDENTIFICATION__PAN_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.party_code), ''), '')) is not null

    union all

    -- branch 73: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(j3.party_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        'PASSPORT' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.passport_number as PARTY_IDENTIFICATION__PASSPORT_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.party_code), ''), '')) is not null

    union all

    -- branch 74: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(j3.party_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        'TAN' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.tan_number as PARTY_IDENTIFICATION__TAN_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.party_code), ''), '')) is not null

    union all

    -- branch 75: MAXI_MOTOR_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(j3.party_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        'VOTER_ID' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.voter_id as PARTY_IDENTIFICATION__VOTER_ID_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp_pv') }} t0
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop_sp') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls_party_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_pd_proposer_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.party_code), ''), '')) is not null

    union all

    -- branch 76: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        nullif(nullif(trim(t0.pre_inspection_number), ''), '') as ASSESSMENT_BK,
        null,
        nullif(nullif(trim(t0.imd_code), ''), '') as DISTRIBUTION_CHANNEL_BK,
        null,
        nullif(nullif(trim(t0.rta_code), ''), '') as LOCATION_BK,
        nullif(nullif(trim(t0.branch_code), ''), '') as ORG_UNIT_BK,
        nullif(nullif(trim(j3.policy_holder_code), ''), '') as PARTY_BK,
        nullif(nullif(trim(t0.payment_card_no), ''), '') as PAYMENT_INSTRUMENT_BK,
        null,
        nullif(nullif(trim(j3.product_code), ''), '') as PRODUCT_BK,
        nullif(nullif(trim(t0.app_no), ''), '') as PROPOSAL_BK,
        nullif(nullif(trim(j3.policy_quote_number), ''), '') as QUOTE_BK,
        nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), '') as RISK_OBJECT_BK,
        null,
        1 as __LNK_CHANNEL_ORG_UNIT,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        1 as __LNK_PROPOSAL_ASSESSMENT,
        1 as __LNK_PROPOSAL_RISK_OBJECT,
        1 as __LNK_RISK_OBJECT_ASSESSMENT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.banca_product_name as AUG_PRODUCT_DEFINITION__PARTNER_PRODUCT_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rta_district as COMMON_ADMIN_GEOGRAPHY__DISTRICT_NAME,
        t0.rta_pincode as COMMON_ADMIN_GEOGRAPHY__PIN_CODE,
        null,
        t0.rta_state as COMMON_ADMIN_GEOGRAPHY__STATE_NAME,
        null, null, null,
        t0.go_green as COMMON_COMMUNICATION_PREFERENCE__GO_GREEN_OPT_IN_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.payment_card_type as INSTRUMENT_DEFINITION__CARD_TYPE,
        null, null,
        t0.payment_card_expiry as INSTRUMENT_DEFINITION__VALID_TO_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PASSPORT' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.passport_number as PARTY_IDENTIFICATION__PASSPORT_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        nullif(trim(t0.plan_code),'') as QUOTE_COMPARISON__OPTION_CODE_CK,
        t0.isselected as QUOTE_COMPARISON__SELECTED_INDICATOR,
        null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (coalesce(nullif(coalesce(nullif(trim(t0.chassis_number),''), nullif(trim(t0.engine_number),''), nullif(trim(t0.registration_number),'')), ''), nullif(nullif(trim(j3.policy_holder_code), ''), ''), nullif(nullif(trim(j3.policy_quote_number), ''), ''), nullif(nullif(trim(j3.product_code), ''), ''), nullif(nullif(trim(t0.app_no), ''), ''), nullif(nullif(trim(t0.branch_code), ''), ''), nullif(nullif(trim(t0.imd_code), ''), ''), nullif(nullif(trim(t0.payment_card_no), ''), ''), nullif(nullif(trim(t0.pre_inspection_number), ''), ''), nullif(nullif(trim(t0.rta_code), ''), ''))) is not null

    union all

    -- branch 77: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(j3.policy_holder_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        'BANK_CUSTOMER_ID' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.bank_customer_id as PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_holder_code), ''), '')) is not null

    union all

    -- branch 78: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(j3.policy_holder_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        'CRN' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.crn_no as PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_holder_code), ''), '')) is not null

    union all

    -- branch 79: MAXI_MOTOR_UWR_VW_DATA_QUOTE_PARAM_DETAILS_POLICY_PROPERTY_RULE_LIST_PIVOT_VW
    select
        null, null, null, null, null, null,
        nullif(nullif(trim(j3.policy_holder_code), ''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        'EIA' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null,
        t0.eia_number as PARTY_IDENTIFICATION__EIA_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rec_refresh_at as REC_REFRESH_AT,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list_pv') }} t0
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop_rule_list') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls_policy_prop') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxm__uwr_quote_param_dtls') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(nullif(trim(j3.policy_holder_code), ''), '')) is not null

)

select
    ASSESSMENT_BK,
    CLAIM_BK,
    DISTRIBUTION_CHANNEL_BK,
    FINANCIAL_TRANSACTION_BK,
    LOCATION_BK,
    ORG_UNIT_BK,
    PARTY_BK,
    PAYMENT_INSTRUMENT_BK,
    POLICY_BK,
    PRODUCT_BK,
    PROPOSAL_BK,
    QUOTE_BK,
    RISK_OBJECT_BK,
    ROLE_TYPE_CODE,
    __LNK_CHANNEL_ORG_UNIT,
    __LNK_CLAIM_ASSESSMENT,
    __LNK_CLAIM_POLICY,
    __LNK_CLAIM_RISK_OBJECT,
    __LNK_FINTXN_CLAIM,
    __LNK_FINTXN_INSTRUMENT,
    __LNK_PARTY_CHANNEL,
    __LNK_PARTY_LOCATION,
    __LNK_PARTY_ORG_UNIT,
    __LNK_POLICY_CHANNEL,
    __LNK_POLICY_ORG_UNIT,
    __LNK_POLICY_PARTY,
    __LNK_POLICY_PRODUCT,
    __LNK_POLICY_RISK_OBJECT,
    __LNK_PROPOSAL_ASSESSMENT,
    __LNK_PROPOSAL_RISK_OBJECT,
    __LNK_RISK_OBJECT_ASSESSMENT,
    first_value(ASSESSMENT_REINSPECTION__RE_INSPECTION_DATE) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_REINSPECTION__RE_INSPECTION_DATE,
    first_value(ASSESSMENT_REINSPECTION__RE_INSPECTION_TIME) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as ASSESSMENT_REINSPECTION__RE_INSPECTION_TIME,
    first_value(AUG_ASSESSMENT_REINSPECTION__RE_INSPECTION_CONDUCTED_INDICATOR) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_REINSPECTION__RE_INSPECTION_CONDUCTED_INDICATOR,
    first_value(AUG_ASSESSMENT_REINSPECTION__RE_INSPECTION_DELAY_DAYS) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_REINSPECTION__RE_INSPECTION_DELAY_DAYS,
    first_value(AUG_ASSESSMENT_REINSPECTION__RE_INSPECTION_INDICATOR) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_REINSPECTION__RE_INSPECTION_INDICATOR,
    first_value(AUG_ASSESSMENT_REINSPECTION__RE_INSPECTION_OTHER_REMARKS) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_REINSPECTION__RE_INSPECTION_OTHER_REMARKS,
    first_value(AUG_ASSESSMENT_REINSPECTION__RE_INSPECTION_REMARKS) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_REINSPECTION__RE_INSPECTION_REMARKS,
    first_value(AUG_ASSESSMENT_REINSPECTION__RE_INSPECTION_REQUESTED_INDICATOR) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_REINSPECTION__RE_INSPECTION_REQUESTED_INDICATOR,
    first_value(AUG_ASSESSMENT_REINSPECTION__RE_INSPECTION_REQUEST_DATE) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_REINSPECTION__RE_INSPECTION_REQUEST_DATE,
    first_value(AUG_ASSESSMENT_REINSPECTION__RE_INSPECTION_STATUS) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_REINSPECTION__RE_INSPECTION_STATUS,
    first_value(AUG_ASSESSMENT_REINSPECTION__RE_INSPECTION_SURVEY_DATE) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_REINSPECTION__RE_INSPECTION_SURVEY_DATE,
    first_value(AUG_ASSESSMENT_REINSPECTION__RE_INSPECTION_SURVEY_REMARKS) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_REINSPECTION__RE_INSPECTION_SURVEY_REMARKS,
    first_value(AUG_ASSESSMENT_REINSPECTION__RE_INSPECTION_SURVEY_TIME) ignore nulls over (partition by ASSESSMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_ASSESSMENT_REINSPECTION__RE_INSPECTION_SURVEY_TIME,
    AUG_CLAIM_EXCESS_HEAD__EXCESS_TYPE_CODE_CK,
    first_value(AUG_CLAIM_EXCESS_HEAD__EXCESS_AMOUNT) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_EXCESS_HEAD__EXCESS_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_EXCESS_HEAD__EXCESS_AMOUNT,
    first_value(AUG_CLAIM_EXCESS_HEAD__EXCESS_WAIVED_INDICATOR) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_EXCESS_HEAD__EXCESS_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_EXCESS_HEAD__EXCESS_WAIVED_INDICATOR,
    first_value(AUG_CLAIM_EXCESS_HEAD__EXCESS_WAIVER_REASON) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_EXCESS_HEAD__EXCESS_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_EXCESS_HEAD__EXCESS_WAIVER_REASON,
    AUG_CLAIM_PAYMENT_TRANCHE__TRANCHE_NUMBER_CK,
    first_value(AUG_CLAIM_PAYMENT_TRANCHE__PAYMENT_CONFIRMED_INDICATOR) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_PAYMENT_TRANCHE__TRANCHE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_PAYMENT_TRANCHE__PAYMENT_CONFIRMED_INDICATOR,
    AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_HEAD_CODE_CK,
    first_value(AUG_CLAIM_RECOVERY_EXPENSE_LINE__CONVEYANCE_AMOUNT) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_RECOVERY_EXPENSE_LINE__CONVEYANCE_AMOUNT,
    first_value(AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_AMOUNT) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_AMOUNT,
    first_value(AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_CURRENCY_CODE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_CURRENCY_CODE,
    first_value(AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_HEAD_CODE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_HEAD_CODE,
    first_value(AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_HEAD_NAME) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_HEAD_NAME,
    first_value(AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_PAYMENT_AMOUNT) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_PAYMENT_AMOUNT,
    first_value(AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_PAYMENT_APPROVED_BY_USER_REFERENCE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_PAYMENT_APPROVED_BY_USER_REFERENCE,
    first_value(AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_PAYMENT_DATE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_PAYMENT_DATE,
    first_value(AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_PAYMENT_REFERENCE_NUMBER) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_PAYMENT_REFERENCE_NUMBER,
    first_value(AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_PAYMENT_TYPE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_PAYMENT_TYPE,
    first_value(AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_PORTAL_PAYMENT_REFERENCE_NUMBER) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_PORTAL_PAYMENT_REFERENCE_NUMBER,
    first_value(AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_QUANTITY) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_QUANTITY,
    first_value(AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_RATE) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_RATE,
    first_value(AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_REFERENCE_TEXT) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_REFERENCE_TEXT,
    first_value(AUG_CLAIM_RECOVERY_EXPENSE_LINE__FLAT_RATE_AMOUNT) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_RECOVERY_EXPENSE_LINE__FLAT_RATE_AMOUNT,
    first_value(AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_AUCTION_REFERRAL_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_RECOVERY_SALVAGE__SALVAGE_AUCTION_REFERRAL_INDICATOR,
    AUG_CLAIM_TAT_BREACH__PROCESS_STEP_CODE_CK,
    first_value(AUG_CLAIM_TAT_BREACH__TAT_BREACH_INDICATOR) ignore nulls over (partition by CLAIM_BK, AUG_CLAIM_TAT_BREACH__PROCESS_STEP_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_TAT_BREACH__TAT_BREACH_INDICATOR,
    first_value(AUG_CLAIM_THIRD_PARTY_MACT__FIXED_DEPOSIT_RECEIPT_FAVOURING_NAME) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_THIRD_PARTY_MACT__FIXED_DEPOSIT_RECEIPT_FAVOURING_NAME,
    first_value(AUG_CLAIM_THIRD_PARTY_MACT__FIXED_DEPOSIT_RECEIPT_TENURE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_THIRD_PARTY_MACT__FIXED_DEPOSIT_RECEIPT_TENURE,
    first_value(AUG_CLAIM_THIRD_PARTY_MACT__INTEREST_APPLICABLE_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_CLAIM_THIRD_PARTY_MACT__INTEREST_APPLICABLE_INDICATOR,
    first_value(AUG_COMMON_CLASSIFICATION__OVERALL_RATING_GRADE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COMMON_CLASSIFICATION__OVERALL_RATING_GRADE,
    first_value(AUG_COMMON_CLASSIFICATION__PROFILE_CODE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COMMON_CLASSIFICATION__PROFILE_CODE,
    first_value(AUG_COMMON_CLASSIFICATION__REFERENCE_CODE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COMMON_CLASSIFICATION__REFERENCE_CODE,
    first_value(AUG_COMMON_CLASSIFICATION__USER_TYPE_CODE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COMMON_CLASSIFICATION__USER_TYPE_CODE,
    first_value(AUG_COMMON_COMMUNICATION_PREFERENCE__COMMUNICATION_AND_LANGUAGE_PREFERENCE_TEXT) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COMMON_COMMUNICATION_PREFERENCE__COMMUNICATION_AND_LANGUAGE_PREFERENCE_TEXT,
    first_value(AUG_COMMON_COMMUNICATION_PREFERENCE__PREFERRED_ALERT_CHANNEL_CODE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COMMON_COMMUNICATION_PREFERENCE__PREFERRED_ALERT_CHANNEL_CODE,
    first_value(AUG_COMMON_CONSENT__DECLARATION_TEXT) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COMMON_CONSENT__DECLARATION_TEXT,
    first_value(AUG_FIN_RECEIPT__COLLECTION_DATE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FIN_RECEIPT__COLLECTION_DATE,
    first_value(AUG_FIN_RECEIPT__COLLECTION_SOURCE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FIN_RECEIPT__COLLECTION_SOURCE,
    first_value(AUG_FIN_RECEIPT__COLLECTION_SUB_CODE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_FIN_RECEIPT__COLLECTION_SUB_CODE,
    first_value(AUG_INSTRUMENT_DEFINITION__INSTRUMENT_ISSUE_DATE) ignore nulls over (partition by PAYMENT_INSTRUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_INSTRUMENT_DEFINITION__INSTRUMENT_ISSUE_DATE,
    AUG_LNK_PARTY_ROLE_CORE__ROLE_CODE_CK,
    AUG_LNK_PARTY_ROLE_CORE__ROLE_SEQUENCE_CK,
    first_value(AUG_LNK_PARTY_ROLE_CORE__OTHER_RELATIONSHIP_DESCRIPTION) ignore nulls over (partition by PARTY_BK, AUG_LNK_PARTY_ROLE_CORE__ROLE_CODE_CK, AUG_LNK_PARTY_ROLE_CORE__ROLE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_LNK_PARTY_ROLE_CORE__OTHER_RELATIONSHIP_DESCRIPTION,
    first_value(AUG_LNK_PARTY_ROLE_CORE__RELATIONSHIP_TO_HIGH_NET_WORTH_CUSTOMER) ignore nulls over (partition by PARTY_BK, AUG_LNK_PARTY_ROLE_CORE__ROLE_CODE_CK, AUG_LNK_PARTY_ROLE_CORE__ROLE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_LNK_PARTY_ROLE_CORE__RELATIONSHIP_TO_HIGH_NET_WORTH_CUSTOMER,
    first_value(AUG_LNK_PARTY_ROLE_CORE__RELATIONSHIP_TO_INSURED) ignore nulls over (partition by PARTY_BK, AUG_LNK_PARTY_ROLE_CORE__ROLE_CODE_CK, AUG_LNK_PARTY_ROLE_CORE__ROLE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_LNK_PARTY_ROLE_CORE__RELATIONSHIP_TO_INSURED,
    first_value(AUG_LNK_PARTY_ROLE_CORE__RELATIONSHIP_TO_INSURER_EMPLOYEE) ignore nulls over (partition by PARTY_BK, AUG_LNK_PARTY_ROLE_CORE__ROLE_CODE_CK, AUG_LNK_PARTY_ROLE_CORE__ROLE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_LNK_PARTY_ROLE_CORE__RELATIONSHIP_TO_INSURER_EMPLOYEE,
    first_value(AUG_LNK_PARTY_ROLE_CORE__RELATIONSHIP_TO_PRIVE_CUSTOMER) ignore nulls over (partition by PARTY_BK, AUG_LNK_PARTY_ROLE_CORE__ROLE_CODE_CK, AUG_LNK_PARTY_ROLE_CORE__ROLE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_LNK_PARTY_ROLE_CORE__RELATIONSHIP_TO_PRIVE_CUSTOMER,
    AUG_PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK,
    first_value(AUG_PARTY_BANKING__ACCOUNT_CATEGORY_CODE) ignore nulls over (partition by PARTY_BK, AUG_PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_BANKING__ACCOUNT_CATEGORY_CODE,
    first_value(AUG_PARTY_BANKING__ACCOUNT_NUMBER) ignore nulls over (partition by PARTY_BK, AUG_PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_BANKING__ACCOUNT_NUMBER,
    first_value(AUG_PARTY_BANKING__APPROVED_OR_REJECTED_BY_USER_REFERENCE) ignore nulls over (partition by PARTY_BK, AUG_PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_BANKING__APPROVED_OR_REJECTED_BY_USER_REFERENCE,
    first_value(AUG_PARTY_BANKING__APPROVED_OR_REJECTED_DATE) ignore nulls over (partition by PARTY_BK, AUG_PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_BANKING__APPROVED_OR_REJECTED_DATE,
    first_value(AUG_PARTY_BANKING__BANK_BRANCH_CODE) ignore nulls over (partition by PARTY_BK, AUG_PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_BANKING__BANK_BRANCH_CODE,
    first_value(AUG_PARTY_BANKING__BANK_RECORD_REMARKS) ignore nulls over (partition by PARTY_BK, AUG_PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_BANKING__BANK_RECORD_REMARKS,
    first_value(AUG_PARTY_BANKING__NEFT_VALIDATION_STATUS) ignore nulls over (partition by PARTY_BK, AUG_PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_BANKING__NEFT_VALIDATION_STATUS,
    first_value(AUG_PARTY_BANKING__PAYEE_NAME_AS_PER_BANK_RECORD) ignore nulls over (partition by PARTY_BK, AUG_PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_BANKING__PAYEE_NAME_AS_PER_BANK_RECORD,
    first_value(AUG_PARTY_BANKING__PENNY_DROP_SKIPPED_INDICATOR) ignore nulls over (partition by PARTY_BK, AUG_PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_BANKING__PENNY_DROP_SKIPPED_INDICATOR,
    first_value(AUG_PARTY_BANKING__PENNY_DROP_VERIFICATION_SCORE) ignore nulls over (partition by PARTY_BK, AUG_PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_BANKING__PENNY_DROP_VERIFICATION_SCORE,
    first_value(AUG_PARTY_CONSENT_MANDATE__MANDATE_DETAIL_TEXT) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_CONSENT_MANDATE__MANDATE_DETAIL_TEXT,
    AUG_PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE_CK,
    first_value(AUG_PARTY_CONTACT_ADDRESS_LINK__ADDRESS_PROOF_EFFECTIVE_DATE) ignore nulls over (partition by LOCATION_BK, PARTY_BK, AUG_PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_CONTACT_ADDRESS_LINK__ADDRESS_PROOF_EFFECTIVE_DATE,
    first_value(AUG_PARTY_CONTACT_ADDRESS_LINK__OTHER_ADDRESS_PROOF_TYPE) ignore nulls over (partition by LOCATION_BK, PARTY_BK, AUG_PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_CONTACT_ADDRESS_LINK__OTHER_ADDRESS_PROOF_TYPE,
    first_value(AUG_PARTY_CONTACT_ADDRESS_LINK__SAME_AS_CORRESPONDENCE_ADDRESS_INDICATOR) ignore nulls over (partition by LOCATION_BK, PARTY_BK, AUG_PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_CONTACT_ADDRESS_LINK__SAME_AS_CORRESPONDENCE_ADDRESS_INDICATOR,
    first_value(AUG_PARTY_CONTACT_ADDRESS_LINK__SAME_AS_PRIMARY_ADDRESS_INDICATOR) ignore nulls over (partition by LOCATION_BK, PARTY_BK, AUG_PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_CONTACT_ADDRESS_LINK__SAME_AS_PRIMARY_ADDRESS_INDICATOR,
    first_value(AUG_PARTY_EMPLOYMENT__EMPLOYER_DETAIL_TEXT) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_EMPLOYMENT__EMPLOYER_DETAIL_TEXT,
    first_value(AUG_PARTY_FINANCIAL_PROFILE__BANKING_DETAIL_TEXT) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_FINANCIAL_PROFILE__BANKING_DETAIL_TEXT,
    first_value(AUG_PARTY_FINANCIAL_PROFILE__CREDIT_CARD_DETAIL_TEXT) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_FINANCIAL_PROFILE__CREDIT_CARD_DETAIL_TEXT,
    first_value(AUG_PARTY_FINANCIAL_PROFILE__CREDIT_LIMIT_REFERENCE_TEXT) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_FINANCIAL_PROFILE__CREDIT_LIMIT_REFERENCE_TEXT,
    first_value(AUG_PARTY_FINANCIAL_PROFILE__INCOME_TAX_RETURN_FILED_TWO_YEARS_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_FINANCIAL_PROFILE__INCOME_TAX_RETURN_FILED_TWO_YEARS_INDICATOR,
    first_value(AUG_PARTY_FINANCIAL_PROFILE__MONTHLY_GROSS_INCOME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_FINANCIAL_PROFILE__MONTHLY_GROSS_INCOME,
    first_value(AUG_PARTY_FINANCIAL_PROFILE__MONTHLY_INCOME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_FINANCIAL_PROFILE__MONTHLY_INCOME,
    first_value(AUG_PARTY_FRAUD_PROFILE__NON_DISCLOSURE_ACTION_INITIATED_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_FRAUD_PROFILE__NON_DISCLOSURE_ACTION_INITIATED_INDICATOR,
    first_value(AUG_PARTY_GROUP_HOUSEHOLD__MEMBER_TYPE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_GROUP_HOUSEHOLD__MEMBER_TYPE,
    first_value(AUG_PARTY_HEALTH_PROFILE__DISABILITY_BODY_LOCATION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_HEALTH_PROFILE__DISABILITY_BODY_LOCATION,
    first_value(AUG_PARTY_HEALTH_PROFILE__MEDICAL_CONDITION_ICD_CODE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_HEALTH_PROFILE__MEDICAL_CONDITION_ICD_CODE,
    first_value(AUG_PARTY_HEALTH_PROFILE__SURGERY_DETAIL_TEXT) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_HEALTH_PROFILE__SURGERY_DETAIL_TEXT,
    first_value(AUG_PARTY_HIERARCHY__BRANCH_REFERENCE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_HIERARCHY__BRANCH_REFERENCE,
    first_value(AUG_PARTY_HIERARCHY__MULTI_OFFICE_BUSINESS_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_HIERARCHY__MULTI_OFFICE_BUSINESS_INDICATOR,
    first_value(AUG_PARTY_HIERARCHY__PRIMARY_BRANCH_REFERENCE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_HIERARCHY__PRIMARY_BRANCH_REFERENCE,
    first_value(AUG_PARTY_HIERARCHY__SECONDARY_BRANCH_REFERENCE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_HIERARCHY__SECONDARY_BRANCH_REFERENCE,
    first_value(AUG_PARTY_HIERARCHY__TRANSFER_CASE_REFERENCE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_HIERARCHY__TRANSFER_CASE_REFERENCE,
    first_value(AUG_PARTY_HIERARCHY__TRANSFER_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_HIERARCHY__TRANSFER_INDICATOR,
    AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
    first_value(AUG_PARTY_IDENTIFICATION__AADHAAR_ENROLMENT_NUMBER) ignore nulls over (partition by PARTY_BK, AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_IDENTIFICATION__AADHAAR_ENROLMENT_NUMBER,
    first_value(AUG_PARTY_IDENTIFICATION__AADHAAR_VIRTUAL_IDENTIFIER) ignore nulls over (partition by PARTY_BK, AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_IDENTIFICATION__AADHAAR_VIRTUAL_IDENTIFIER,
    first_value(AUG_PARTY_IDENTIFICATION__ABHA_NUMBER) ignore nulls over (partition by PARTY_BK, AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_IDENTIFICATION__ABHA_NUMBER,
    first_value(AUG_PARTY_IDENTIFICATION__DRIVING_LICENCE_DETAIL_TEXT) ignore nulls over (partition by PARTY_BK, AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_IDENTIFICATION__DRIVING_LICENCE_DETAIL_TEXT,
    first_value(AUG_PARTY_IDENTIFICATION__DRIVING_LICENCE_TYPE) ignore nulls over (partition by PARTY_BK, AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_IDENTIFICATION__DRIVING_LICENCE_TYPE,
    first_value(AUG_PARTY_IDENTIFICATION__EIA_AVAILABLE_INDICATOR) ignore nulls over (partition by PARTY_BK, AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_IDENTIFICATION__EIA_AVAILABLE_INDICATOR,
    first_value(AUG_PARTY_IDENTIFICATION__EIA_DETAIL_TEXT) ignore nulls over (partition by PARTY_BK, AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_IDENTIFICATION__EIA_DETAIL_TEXT,
    first_value(AUG_PARTY_IDENTIFICATION__EIA_LINKAGE_DATE) ignore nulls over (partition by PARTY_BK, AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_IDENTIFICATION__EIA_LINKAGE_DATE,
    first_value(AUG_PARTY_IDENTIFICATION__EIA_POLICY_CREDIT_REQUIRED_INDICATOR) ignore nulls over (partition by PARTY_BK, AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_IDENTIFICATION__EIA_POLICY_CREDIT_REQUIRED_INDICATOR,
    first_value(AUG_PARTY_IDENTIFICATION__EIA_REQUIRED_INDICATOR) ignore nulls over (partition by PARTY_BK, AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_IDENTIFICATION__EIA_REQUIRED_INDICATOR,
    first_value(AUG_PARTY_IDENTIFICATION__GST_COMPOSITION_SCHEME_INDICATOR) ignore nulls over (partition by PARTY_BK, AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_IDENTIFICATION__GST_COMPOSITION_SCHEME_INDICATOR,
    first_value(AUG_PARTY_IDENTIFICATION__GST_PAYABLE_INDICATOR) ignore nulls over (partition by PARTY_BK, AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_IDENTIFICATION__GST_PAYABLE_INDICATOR,
    first_value(AUG_PARTY_IDENTIFICATION__IDENTIFICATION_ISSUING_COUNTRY) ignore nulls over (partition by PARTY_BK, AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_IDENTIFICATION__IDENTIFICATION_ISSUING_COUNTRY,
    first_value(AUG_PARTY_IDENTIFICATION__IDENTIFICATION_PLACE_OF_ISSUE) ignore nulls over (partition by PARTY_BK, AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_IDENTIFICATION__IDENTIFICATION_PLACE_OF_ISSUE,
    first_value(AUG_PARTY_IDENTIFICATION__IDENTIFICATION_VALID_FROM_DATE) ignore nulls over (partition by PARTY_BK, AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_IDENTIFICATION__IDENTIFICATION_VALID_FROM_DATE,
    first_value(AUG_PARTY_IDENTIFICATION__NAME_AS_PER_IDENTIFICATION_DOCUMENT) ignore nulls over (partition by PARTY_BK, AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_IDENTIFICATION__NAME_AS_PER_IDENTIFICATION_DOCUMENT,
    first_value(AUG_PARTY_IDENTIFICATION__PAN_AADHAAR_LINKED_INDICATOR) ignore nulls over (partition by PARTY_BK, AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_IDENTIFICATION__PAN_AADHAAR_LINKED_INDICATOR,
    first_value(AUG_PARTY_IDENTIFICATION__PASSPORT_DETAIL_TEXT) ignore nulls over (partition by PARTY_BK, AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_IDENTIFICATION__PASSPORT_DETAIL_TEXT,
    first_value(AUG_PARTY_IDENTIFICATION__PASSPORT_FILE_NUMBER) ignore nulls over (partition by PARTY_BK, AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_IDENTIFICATION__PASSPORT_FILE_NUMBER,
    first_value(AUG_PARTY_IDENTIFICATION__PROOF_OF_ADDRESS_STATUS) ignore nulls over (partition by PARTY_BK, AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_IDENTIFICATION__PROOF_OF_ADDRESS_STATUS,
    first_value(AUG_PARTY_IDENTIFICATION__PROOF_OF_IDENTITY_STATUS) ignore nulls over (partition by PARTY_BK, AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_IDENTIFICATION__PROOF_OF_IDENTITY_STATUS,
    first_value(AUG_PARTY_IDENTIFICATION__STATE_WISE_GSTIN_DETAIL_TEXT) ignore nulls over (partition by PARTY_BK, AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_IDENTIFICATION__STATE_WISE_GSTIN_DETAIL_TEXT,
    first_value(AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__BASIC_QUALIFICATION_BOARD_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__BASIC_QUALIFICATION_BOARD_NAME,
    first_value(AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__BASIC_QUALIFICATION_DETAIL_TEXT) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__BASIC_QUALIFICATION_DETAIL_TEXT,
    first_value(AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__BASIC_QUALIFICATION_ROLL_NUMBER) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__BASIC_QUALIFICATION_ROLL_NUMBER,
    first_value(AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__DATE_OF_MARRIAGE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__DATE_OF_MARRIAGE,
    first_value(AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__FATHER_OR_SPOUSE_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__FATHER_OR_SPOUSE_NAME,
    first_value(AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__IRDAI_LISTED_PRIMARY_PROFESSION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__IRDAI_LISTED_PRIMARY_PROFESSION,
    first_value(AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__MOTHER_MAIDEN_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__MOTHER_MAIDEN_NAME,
    first_value(AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__NUMBER_OF_DAUGHTERS) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__NUMBER_OF_DAUGHTERS,
    first_value(AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__NUMBER_OF_SONS) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__NUMBER_OF_SONS,
    first_value(AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__OTHER_OCCUPATION_DESCRIPTION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__OTHER_OCCUPATION_DESCRIPTION,
    first_value(AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__OTHER_QUALIFICATION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__OTHER_QUALIFICATION,
    first_value(AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__PRIMARY_PROFESSION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__PRIMARY_PROFESSION,
    first_value(AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__PROFESSIONAL_QUALIFICATION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__PROFESSIONAL_QUALIFICATION,
    first_value(AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__QUALIFICATION_DETAIL_TEXT) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__QUALIFICATION_DETAIL_TEXT,
    first_value(AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__QUALIFICATION_PASSING_MONTH) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__QUALIFICATION_PASSING_MONTH,
    first_value(AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__QUALIFICATION_PASSING_YEAR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__QUALIFICATION_PASSING_YEAR,
    first_value(AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__UNDERGRADUATE_QUALIFICATION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__UNDERGRADUATE_QUALIFICATION,
    first_value(AUG_PARTY_KYC__CKYC_DETAIL_TEXT) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_KYC__CKYC_DETAIL_TEXT,
    first_value(AUG_PARTY_KYC__CKYC_NUMBER_HELD_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_KYC__CKYC_NUMBER_HELD_INDICATOR,
    first_value(AUG_PARTY_KYC__KYC_DETAIL_TEXT) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_KYC__KYC_DETAIL_TEXT,
    first_value(AUG_PARTY_KYC__OPTIONAL_SUPPORTING_PROOF_DOCUMENT_TYPE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_KYC__OPTIONAL_SUPPORTING_PROOF_DOCUMENT_TYPE,
    first_value(AUG_PARTY_KYC__PRIMARY_SUPPORTING_PROOF_DOCUMENT_TYPE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_KYC__PRIMARY_SUPPORTING_PROOF_DOCUMENT_TYPE,
    first_value(AUG_PARTY_KYC__PROOF_OF_ADDRESS_DOCUMENT_TYPE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_KYC__PROOF_OF_ADDRESS_DOCUMENT_TYPE,
    first_value(AUG_PARTY_KYC__PROOF_OF_ADDRESS_STATUS) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_KYC__PROOF_OF_ADDRESS_STATUS,
    first_value(AUG_PARTY_KYC__PROOF_OF_ADDRESS_VERIFICATION_STATUS) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_KYC__PROOF_OF_ADDRESS_VERIFICATION_STATUS,
    first_value(AUG_PARTY_KYC__PROOF_OF_IDENTITY_DOCUMENT_TYPE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_KYC__PROOF_OF_IDENTITY_DOCUMENT_TYPE,
    first_value(AUG_PARTY_KYC__PROOF_OF_IDENTITY_STATUS) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_KYC__PROOF_OF_IDENTITY_STATUS,
    first_value(AUG_PARTY_KYC__PROOF_OF_IDENTITY_VERIFICATION_STATUS) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_KYC__PROOF_OF_IDENTITY_VERIFICATION_STATUS,
    first_value(AUG_PARTY_ONBOARDING_JOURNEY__CANDIDATE_BACKGROUND_DESCRIPTION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_ONBOARDING_JOURNEY__CANDIDATE_BACKGROUND_DESCRIPTION,
    first_value(AUG_PARTY_ONBOARDING_JOURNEY__INSURANCE_BANKING_FINANCE_EXPERIENCE_YEARS) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_ONBOARDING_JOURNEY__INSURANCE_BANKING_FINANCE_EXPERIENCE_YEARS,
    first_value(AUG_PARTY_ONBOARDING_JOURNEY__LICENCE_EXAMINATION_DETAIL_TEXT) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_ONBOARDING_JOURNEY__LICENCE_EXAMINATION_DETAIL_TEXT,
    first_value(AUG_PARTY_ONBOARDING_JOURNEY__PREVIOUS_EMPLOYER_LOCATION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_ONBOARDING_JOURNEY__PREVIOUS_EMPLOYER_LOCATION,
    first_value(AUG_PARTY_ONBOARDING_JOURNEY__PREVIOUS_EMPLOYER_PARENT_INTERMEDIARY_CODE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_ONBOARDING_JOURNEY__PREVIOUS_EMPLOYER_PARENT_INTERMEDIARY_CODE,
    first_value(AUG_PARTY_ONBOARDING_JOURNEY__PREVIOUS_EMPLOYER_PARENT_SUB_INTERMEDIARY_CODE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_ONBOARDING_JOURNEY__PREVIOUS_EMPLOYER_PARENT_SUB_INTERMEDIARY_CODE,
    first_value(AUG_PARTY_ONBOARDING_JOURNEY__PREVIOUS_EMPLOYMENT_LEAVING_REASON) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_ONBOARDING_JOURNEY__PREVIOUS_EMPLOYMENT_LEAVING_REASON,
    first_value(AUG_PARTY_ONBOARDING_JOURNEY__PREVIOUS_NON_GENERAL_INSURER_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_ONBOARDING_JOURNEY__PREVIOUS_NON_GENERAL_INSURER_NAME,
    first_value(AUG_PARTY_ONBOARDING_JOURNEY__REJECTION_REASON) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_ONBOARDING_JOURNEY__REJECTION_REASON,
    first_value(AUG_PARTY_PAYOUT_PROFILE__LOWER_TDS_CERTIFICATE_REFERENCE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_PAYOUT_PROFILE__LOWER_TDS_CERTIFICATE_REFERENCE,
    first_value(AUG_PARTY_PAYOUT_PROFILE__REFUND_BENEFICIARY_PARTY_REFERENCE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_PAYOUT_PROFILE__REFUND_BENEFICIARY_PARTY_REFERENCE,
    first_value(AUG_PARTY_PAYOUT_PROFILE__TDS_CODE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_PAYOUT_PROFILE__TDS_CODE,
    first_value(AUG_PARTY_PAYOUT_PROFILE__TDS_CODE_DESCRIPTION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_PAYOUT_PROFILE__TDS_CODE_DESCRIPTION,
    first_value(AUG_PARTY_PAYOUT_PROFILE__TDS_DETAIL_TEXT) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_PAYOUT_PROFILE__TDS_DETAIL_TEXT,
    first_value(AUG_PARTY_PREFERENCE_PROFILE__ELECTRONIC_POLICY_ISSUANCE_PREFERENCE_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_PREFERENCE_PROFILE__ELECTRONIC_POLICY_ISSUANCE_PREFERENCE_INDICATOR,
    first_value(AUG_PARTY_PREFERENCE_PROFILE__PROPAGATE_CONTACT_UPDATE_TO_ALL_POLICIES_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_PREFERENCE_PROFILE__PROPAGATE_CONTACT_UPDATE_TO_ALL_POLICIES_INDICATOR,
    first_value(AUG_PARTY_RELATIONSHIP_PROFILE__EXISTING_CUSTOMER_DECLARED_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_RELATIONSHIP_PROFILE__EXISTING_CUSTOMER_DECLARED_INDICATOR,
    first_value(AUG_PARTY_RELATIONSHIP_PROFILE__FINAL_LOYALTY_SEVERITY) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_RELATIONSHIP_PROFILE__FINAL_LOYALTY_SEVERITY,
    first_value(AUG_PARTY_RELATIONSHIP_PROFILE__LOYALTY_BUCKET_BY_SEVERITY) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_RELATIONSHIP_PROFILE__LOYALTY_BUCKET_BY_SEVERITY,
    first_value(AUG_PARTY_RELATIONSHIP_PROFILE__NOMINEE_DETAIL_TEXT) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_RELATIONSHIP_PROFILE__NOMINEE_DETAIL_TEXT,
    first_value(AUG_PARTY_VEHICLE_OWNER__DRIVING_EXPERIENCE_YEARS) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_VEHICLE_OWNER__DRIVING_EXPERIENCE_YEARS,
    first_value(AUG_PRODUCT_DEFINITION__PARTNER_PRODUCT_NAME) ignore nulls over (partition by PRODUCT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_DEFINITION__PARTNER_PRODUCT_NAME,
    first_value(AUG_PRODUCT_DEFINITION__PRODUCT_DETAIL_TEXT) ignore nulls over (partition by PRODUCT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PRODUCT_DEFINITION__PRODUCT_DETAIL_TEXT,
    first_value(AUG_RISK_MOTOR_VERIFICATION__REGISTRATION_NUMBER_AS_VERIFIED) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_VERIFICATION__REGISTRATION_NUMBER_AS_VERIFIED,
    first_value(AUG_RISK_MOTOR_VERIFICATION__VERIFICATION_DATA_SOURCE) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_RISK_MOTOR_VERIFICATION__VERIFICATION_DATA_SOURCE,
    first_value(CLAIM_CO_RI_SHARE__CO_INSURANCE_OUR_SHARE_PERCENTAGE) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_CO_RI_SHARE__CO_INSURANCE_OUR_SHARE_PERCENTAGE,
    first_value(CLAIM_CO_RI_SHARE__EXPENSE_SHARE_AMOUNT) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_CO_RI_SHARE__EXPENSE_SHARE_AMOUNT,
    first_value(CLAIM_CO_RI_SHARE__LEADER_INDICATOR) ignore nulls over (partition by CLAIM_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_CO_RI_SHARE__LEADER_INDICATOR,
    CLAIM_MACT_AWARD_HEAD__AWARD_HEAD_CODE_CK,
    first_value(CLAIM_MACT_AWARD_HEAD__AWARDED_AMOUNT) ignore nulls over (partition by CLAIM_BK, CLAIM_MACT_AWARD_HEAD__AWARD_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_MACT_AWARD_HEAD__AWARDED_AMOUNT,
    first_value(CLAIM_MACT_AWARD_HEAD__INTEREST_AMOUNT) ignore nulls over (partition by CLAIM_BK, CLAIM_MACT_AWARD_HEAD__AWARD_HEAD_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_MACT_AWARD_HEAD__INTEREST_AMOUNT,
    CLAIM_PAYMENT_TRANCHE__TRANCHE_NUMBER_CK,
    first_value(CLAIM_PAYMENT_TRANCHE__GROSS_AMOUNT) ignore nulls over (partition by CLAIM_BK, CLAIM_PAYMENT_TRANCHE__TRANCHE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_PAYMENT_TRANCHE__GROSS_AMOUNT,
    first_value(CLAIM_PAYMENT_TRANCHE__STATUS) ignore nulls over (partition by CLAIM_BK, CLAIM_PAYMENT_TRANCHE__TRANCHE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_PAYMENT_TRANCHE__STATUS,
    CLAIM_RESERVE__RESERVE_HEAD_CK,
    first_value(CLAIM_RESERVE__CURRENT_RESERVE_AMOUNT) ignore nulls over (partition by CLAIM_BK, CLAIM_RESERVE__RESERVE_HEAD_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_RESERVE__CURRENT_RESERVE_AMOUNT,
    first_value(CLAIM_RESERVE__INITIAL_RESERVE_AMOUNT) ignore nulls over (partition by CLAIM_BK, CLAIM_RESERVE__RESERVE_HEAD_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_RESERVE__INITIAL_RESERVE_AMOUNT,
    first_value(CLAIM_RESERVE__RESERVE_TYPE) ignore nulls over (partition by CLAIM_BK, CLAIM_RESERVE__RESERVE_HEAD_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as CLAIM_RESERVE__RESERVE_TYPE,
    first_value(COMMON_ADMIN_GEOGRAPHY__COUNTRY_CODE) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADMIN_GEOGRAPHY__COUNTRY_CODE,
    first_value(COMMON_ADMIN_GEOGRAPHY__DISTRICT_NAME) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADMIN_GEOGRAPHY__DISTRICT_NAME,
    first_value(COMMON_ADMIN_GEOGRAPHY__PIN_CODE) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADMIN_GEOGRAPHY__PIN_CODE,
    first_value(COMMON_ADMIN_GEOGRAPHY__STATE_CODE) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADMIN_GEOGRAPHY__STATE_CODE,
    first_value(COMMON_ADMIN_GEOGRAPHY__STATE_NAME) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADMIN_GEOGRAPHY__STATE_NAME,
    first_value(COMMON_ADMIN_GEOGRAPHY__TALUKA_NAME) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_ADMIN_GEOGRAPHY__TALUKA_NAME,
    first_value(COMMON_CLASSIFICATION__CATEGORY_CODE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_CLASSIFICATION__CATEGORY_CODE,
    first_value(COMMON_CLASSIFICATION__SEGMENT_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_CLASSIFICATION__SEGMENT_NAME,
    first_value(COMMON_COMMUNICATION_PREFERENCE__GO_GREEN_OPT_IN_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_COMMUNICATION_PREFERENCE__GO_GREEN_OPT_IN_INDICATOR,
    first_value(COMMON_COMMUNICATION_PREFERENCE__PREFERRED_CHANNEL_CODE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_COMMUNICATION_PREFERENCE__PREFERRED_CHANNEL_CODE,
    first_value(COMMON_COMMUNICATION_PREFERENCE__PREFERRED_LANGUAGE_CODE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_COMMUNICATION_PREFERENCE__PREFERRED_LANGUAGE_CODE,
    first_value(COMMON_CONSENT__CONSENT_GIVEN_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_CONSENT__CONSENT_GIVEN_INDICATOR,
    first_value(FINTXN_ACCOUNTING__VOUCHER_NUMBER) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_ACCOUNTING__VOUCHER_NUMBER,
    first_value(FINTXN_PREMIUM__COLLECTION_MODE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_PREMIUM__COLLECTION_MODE,
    first_value(FIN_RECEIPT__AMOUNT_RECEIVED) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FIN_RECEIPT__AMOUNT_RECEIVED,
    first_value(FIN_RECEIPT__REALISATION_DATE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FIN_RECEIPT__REALISATION_DATE,
    first_value(FIN_RECEIPT__RECEIPT_DATE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FIN_RECEIPT__RECEIPT_DATE,
    first_value(FIN_RECEIPT__RECEIPT_NUMBER) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FIN_RECEIPT__RECEIPT_NUMBER,
    first_value(FIN_RECEIPT__RECEIPT_TYPE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FIN_RECEIPT__RECEIPT_TYPE,
    first_value(INSTRUMENT_DEFINITION__ACCOUNT_TYPE) ignore nulls over (partition by PAYMENT_INSTRUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as INSTRUMENT_DEFINITION__ACCOUNT_TYPE,
    first_value(INSTRUMENT_DEFINITION__BANK_NAME) ignore nulls over (partition by PAYMENT_INSTRUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as INSTRUMENT_DEFINITION__BANK_NAME,
    first_value(INSTRUMENT_DEFINITION__CARD_TYPE) ignore nulls over (partition by PAYMENT_INSTRUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as INSTRUMENT_DEFINITION__CARD_TYPE,
    first_value(INSTRUMENT_DEFINITION__IFSC_CODE) ignore nulls over (partition by PAYMENT_INSTRUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as INSTRUMENT_DEFINITION__IFSC_CODE,
    first_value(INSTRUMENT_DEFINITION__INSTRUMENT_STATUS) ignore nulls over (partition by PAYMENT_INSTRUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as INSTRUMENT_DEFINITION__INSTRUMENT_STATUS,
    first_value(INSTRUMENT_DEFINITION__VALID_TO_DATE) ignore nulls over (partition by PAYMENT_INSTRUMENT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as INSTRUMENT_DEFINITION__VALID_TO_DATE,
    LNK_ROLE_AGENT__ROLE_TYPE_CK,
    first_value(LNK_ROLE_AGENT__AGENCY_TYPE) ignore nulls over (partition by PARTY_BK, LNK_ROLE_AGENT__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_AGENT__AGENCY_TYPE,
    first_value(LNK_ROLE_AGENT__APPOINTMENT_DATE) ignore nulls over (partition by PARTY_BK, LNK_ROLE_AGENT__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_AGENT__APPOINTMENT_DATE,
    first_value(LNK_ROLE_AGENT__IRDAI_AGENT_LICENCE_NUMBER) ignore nulls over (partition by PARTY_BK, LNK_ROLE_AGENT__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_AGENT__IRDAI_AGENT_LICENCE_NUMBER,
    first_value(LNK_ROLE_AGENT__LICENCE_CATEGORY) ignore nulls over (partition by PARTY_BK, LNK_ROLE_AGENT__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_AGENT__LICENCE_CATEGORY,
    first_value(LNK_ROLE_AGENT__LICENCE_EXPIRY_DATE) ignore nulls over (partition by PARTY_BK, LNK_ROLE_AGENT__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_AGENT__LICENCE_EXPIRY_DATE,
    first_value(LNK_ROLE_AGENT__LICENCE_ISSUE_DATE) ignore nulls over (partition by PARTY_BK, LNK_ROLE_AGENT__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_AGENT__LICENCE_ISSUE_DATE,
    LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
    first_value(LNK_ROLE_CUSTOMER__BLACKLIST_INDICATOR) ignore nulls over (partition by PARTY_BK, LNK_ROLE_CUSTOMER__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_CUSTOMER__BLACKLIST_INDICATOR,
    first_value(LNK_ROLE_CUSTOMER__BLACKLIST_REASON) ignore nulls over (partition by PARTY_BK, LNK_ROLE_CUSTOMER__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_CUSTOMER__BLACKLIST_REASON,
    first_value(LNK_ROLE_CUSTOMER__CONSENT_FOR_DATA_SHARING_INDICATOR) ignore nulls over (partition by PARTY_BK, LNK_ROLE_CUSTOMER__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_CUSTOMER__CONSENT_FOR_DATA_SHARING_INDICATOR,
    first_value(LNK_ROLE_CUSTOMER__VIP_INDICATOR) ignore nulls over (partition by PARTY_BK, LNK_ROLE_CUSTOMER__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
    LNK_ROLE_EMPLOYEE__ROLE_TYPE_CK,
    first_value(LNK_ROLE_EMPLOYEE__DEPARTMENT) ignore nulls over (partition by PARTY_BK, LNK_ROLE_EMPLOYEE__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_EMPLOYEE__DEPARTMENT,
    first_value(LNK_ROLE_EMPLOYEE__EMPLOYEE_CODE) ignore nulls over (partition by PARTY_BK, LNK_ROLE_EMPLOYEE__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_EMPLOYEE__EMPLOYEE_CODE,
    first_value(LNK_ROLE_EMPLOYEE__FUNCTION) ignore nulls over (partition by PARTY_BK, LNK_ROLE_EMPLOYEE__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_EMPLOYEE__FUNCTION,
    LNK_ROLE_PROVIDER__ROLE_TYPE_CK,
    first_value(LNK_ROLE_PROVIDER__SERVICE_REGION) ignore nulls over (partition by PARTY_BK, LNK_ROLE_PROVIDER__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_PROVIDER__SERVICE_REGION,
    first_value(LNK_ROLE_PROVIDER__SERVICE_SCOPE_DESCRIPTION) ignore nulls over (partition by PARTY_BK, LNK_ROLE_PROVIDER__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_PROVIDER__SERVICE_SCOPE_DESCRIPTION,
    first_value(PARTY_AML_SCREENING__SCREENING_STATUS) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_AML_SCREENING__SCREENING_STATUS,
    PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK,
    first_value(PARTY_BANKING__ACCOUNT_HOLDER_NAME) ignore nulls over (partition by PARTY_BK, PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_BANKING__ACCOUNT_HOLDER_NAME,
    first_value(PARTY_BANKING__ACCOUNT_NUMBER_MASKED) ignore nulls over (partition by PARTY_BK, PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_BANKING__ACCOUNT_NUMBER_MASKED,
    first_value(PARTY_BANKING__ACCOUNT_TYPE) ignore nulls over (partition by PARTY_BK, PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_BANKING__ACCOUNT_TYPE,
    first_value(PARTY_BANKING__BANK_NAME) ignore nulls over (partition by PARTY_BK, PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_BANKING__BANK_NAME,
    first_value(PARTY_BANKING__BRANCH_NAME) ignore nulls over (partition by PARTY_BK, PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_BANKING__BRANCH_NAME,
    first_value(PARTY_BANKING__IFSC_CODE) ignore nulls over (partition by PARTY_BK, PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_BANKING__IFSC_CODE,
    first_value(PARTY_BANKING__MICR_CODE) ignore nulls over (partition by PARTY_BK, PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_BANKING__MICR_CODE,
    first_value(PARTY_BANKING__PRIMARY_ACCOUNT_INDICATOR) ignore nulls over (partition by PARTY_BK, PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_BANKING__PRIMARY_ACCOUNT_INDICATOR,
    first_value(PARTY_EMPLOYMENT__EMPLOYER_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_EMPLOYMENT__EMPLOYER_NAME,
    first_value(PARTY_EMPLOYMENT__EMPLOYMENT_STATUS) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_EMPLOYMENT__EMPLOYMENT_STATUS,
    first_value(PARTY_FINANCIAL_PROFILE__CREDIT_SCORE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_FINANCIAL_PROFILE__CREDIT_SCORE,
    first_value(PARTY_FINANCIAL_PROFILE__INCOME_SOURCE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_FINANCIAL_PROFILE__INCOME_SOURCE,
    first_value(PARTY_HEALTH_PROFILE__CURRENT_MEDICATION_DETAIL) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_HEALTH_PROFILE__CURRENT_MEDICATION_DETAIL,
    first_value(PARTY_HEALTH_PROFILE__DISABILITY_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_HEALTH_PROFILE__DISABILITY_INDICATOR,
    first_value(PARTY_HEALTH_PROFILE__DISABILITY_PERCENTAGE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_HEALTH_PROFILE__DISABILITY_PERCENTAGE,
    first_value(PARTY_HEALTH_PROFILE__HEIGHT) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_HEALTH_PROFILE__HEIGHT,
    first_value(PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
    first_value(PARTY_HEALTH_PROFILE__WEIGHT) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_HEALTH_PROFILE__WEIGHT,
    first_value(PARTY_HIERARCHY__HIERARCHY_LEVEL) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_HIERARCHY__HIERARCHY_LEVEL,
    first_value(PARTY_HIERARCHY__REPORTING_PARENT_REFERENCE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_HIERARCHY__REPORTING_PARENT_REFERENCE,
    first_value(PARTY_HIERARCHY__TERRITORY_CODE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_HIERARCHY__TERRITORY_CODE,
    PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
    first_value(PARTY_IDENTIFICATION__AADHAAR_NUMBER) ignore nulls over (partition by PARTY_BK, PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTIFICATION__AADHAAR_NUMBER,
    first_value(PARTY_IDENTIFICATION__AGE_PROOF_TYPE) ignore nulls over (partition by PARTY_BK, PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTIFICATION__AGE_PROOF_TYPE,
    first_value(PARTY_IDENTIFICATION__CKYC_NUMBER) ignore nulls over (partition by PARTY_BK, PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTIFICATION__CKYC_NUMBER,
    first_value(PARTY_IDENTIFICATION__DRIVING_LICENCE_EXPIRY_DATE) ignore nulls over (partition by PARTY_BK, PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTIFICATION__DRIVING_LICENCE_EXPIRY_DATE,
    first_value(PARTY_IDENTIFICATION__DRIVING_LICENCE_NUMBER) ignore nulls over (partition by PARTY_BK, PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTIFICATION__DRIVING_LICENCE_NUMBER,
    first_value(PARTY_IDENTIFICATION__EIA_NUMBER) ignore nulls over (partition by PARTY_BK, PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTIFICATION__EIA_NUMBER,
    first_value(PARTY_IDENTIFICATION__GSTIN) ignore nulls over (partition by PARTY_BK, PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTIFICATION__GSTIN,
    first_value(PARTY_IDENTIFICATION__GST_REGISTRATION_STATUS) ignore nulls over (partition by PARTY_BK, PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTIFICATION__GST_REGISTRATION_STATUS,
    first_value(PARTY_IDENTIFICATION__GST_TAXPAYER_TYPE) ignore nulls over (partition by PARTY_BK, PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTIFICATION__GST_TAXPAYER_TYPE,
    first_value(PARTY_IDENTIFICATION__IDENTIFICATION_EXPIRY_DATE) ignore nulls over (partition by PARTY_BK, PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTIFICATION__IDENTIFICATION_EXPIRY_DATE,
    first_value(PARTY_IDENTIFICATION__IDENTIFICATION_ISSUE_DATE) ignore nulls over (partition by PARTY_BK, PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTIFICATION__IDENTIFICATION_ISSUE_DATE,
    first_value(PARTY_IDENTIFICATION__IDENTIFICATION_ISSUING_AUTHORITY) ignore nulls over (partition by PARTY_BK, PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTIFICATION__IDENTIFICATION_ISSUING_AUTHORITY,
    first_value(PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER) ignore nulls over (partition by PARTY_BK, PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER,
    first_value(PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE) ignore nulls over (partition by PARTY_BK, PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE,
    first_value(PARTY_IDENTIFICATION__IDENTIFICATION_VERIFIED_INDICATOR) ignore nulls over (partition by PARTY_BK, PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTIFICATION__IDENTIFICATION_VERIFIED_INDICATOR,
    first_value(PARTY_IDENTIFICATION__INSURANCE_REPOSITORY_NAME) ignore nulls over (partition by PARTY_BK, PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTIFICATION__INSURANCE_REPOSITORY_NAME,
    first_value(PARTY_IDENTIFICATION__NREGA_CARD_NUMBER) ignore nulls over (partition by PARTY_BK, PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTIFICATION__NREGA_CARD_NUMBER,
    first_value(PARTY_IDENTIFICATION__PAN_NUMBER) ignore nulls over (partition by PARTY_BK, PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTIFICATION__PAN_NUMBER,
    first_value(PARTY_IDENTIFICATION__PASSPORT_EXPIRY_DATE) ignore nulls over (partition by PARTY_BK, PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTIFICATION__PASSPORT_EXPIRY_DATE,
    first_value(PARTY_IDENTIFICATION__PASSPORT_NUMBER) ignore nulls over (partition by PARTY_BK, PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTIFICATION__PASSPORT_NUMBER,
    first_value(PARTY_IDENTIFICATION__TAN_NUMBER) ignore nulls over (partition by PARTY_BK, PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTIFICATION__TAN_NUMBER,
    first_value(PARTY_IDENTIFICATION__VAT_REGISTRATION_NUMBER) ignore nulls over (partition by PARTY_BK, PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTIFICATION__VAT_REGISTRATION_NUMBER,
    first_value(PARTY_IDENTIFICATION__VOTER_ID_NUMBER) ignore nulls over (partition by PARTY_BK, PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTIFICATION__VOTER_ID_NUMBER,
    first_value(PARTY_KYC__CKYC_NUMBER) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_KYC__CKYC_NUMBER,
    first_value(PARTY_KYC__CKYC_REGISTRATION_STATUS) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_KYC__CKYC_REGISTRATION_STATUS,
    first_value(PARTY_KYC__KYC_COMPLETION_DATE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_KYC__KYC_COMPLETION_DATE,
    first_value(PARTY_KYC__KYC_STATUS) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_KYC__KYC_STATUS,
    first_value(PARTY_ONBOARDING_JOURNEY__ONBOARDING_START_DATE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_ONBOARDING_JOURNEY__ONBOARDING_START_DATE,
    first_value(PARTY_ONBOARDING_JOURNEY__PREVIOUS_EMPLOYER_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_ONBOARDING_JOURNEY__PREVIOUS_EMPLOYER_NAME,
    first_value(PARTY_ONBOARDING_JOURNEY__PRIOR_WORK_EXPERIENCE_YEARS) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_ONBOARDING_JOURNEY__PRIOR_WORK_EXPERIENCE_YEARS,
    first_value(POLICY_DELIVERY__DELIVERY_MODE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_DELIVERY__DELIVERY_MODE,
    first_value(POLICY_DELIVERY__DISPATCH_DATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_DELIVERY__DISPATCH_DATE,
    first_value(POLICY_DELIVERY__EDELIVERY_INDICATOR) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_DELIVERY__EDELIVERY_INDICATOR,
    first_value(POLICY_DELIVERY__TRACKING_REFERENCE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_DELIVERY__TRACKING_REFERENCE,
    first_value(POLICY_EXTERNAL_TP_LINK__EXTERNAL_TP_POLICY_INDICATOR) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_EXTERNAL_TP_LINK__EXTERNAL_TP_POLICY_INDICATOR,
    first_value(POLICY_EXTERNAL_TP_LINK__TP_INSURER_NAME) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_EXTERNAL_TP_LINK__TP_INSURER_NAME,
    first_value(POLICY_EXTERNAL_TP_LINK__TP_POLICY_END_DATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_EXTERNAL_TP_LINK__TP_POLICY_END_DATE,
    first_value(POLICY_EXTERNAL_TP_LINK__TP_POLICY_NUMBER) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_EXTERNAL_TP_LINK__TP_POLICY_NUMBER,
    first_value(POLICY_EXTERNAL_TP_LINK__TP_POLICY_START_DATE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_EXTERNAL_TP_LINK__TP_POLICY_START_DATE,
    first_value(POLICY_EXTERNAL_TP_LINK__TP_TENURE_YEARS) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_EXTERNAL_TP_LINK__TP_TENURE_YEARS,
    first_value(POLICY_LIFECYCLE__LIFECYCLE_STAGE) ignore nulls over (partition by POLICY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as POLICY_LIFECYCLE__LIFECYCLE_STAGE,
    QUOTE_COMPARISON__OPTION_CODE_CK,
    first_value(QUOTE_COMPARISON__SELECTED_INDICATOR) ignore nulls over (partition by QUOTE_BK, QUOTE_COMPARISON__OPTION_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as QUOTE_COMPARISON__SELECTED_INDICATOR,
    first_value(RISK_MOTOR_VERIFICATION__RC_VERIFICATION_STATUS) ignore nulls over (partition by RISK_OBJECT_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as RISK_MOTOR_VERIFICATION__RC_VERIFICATION_STATUS,
    -- the row's own source time: LOAD_DATETIME for hubs, links and single-active satellites
    m.REC_REFRESH_AT,
    -- multi-active satellites on CLAIM_BK (SAT_MOTOR_AUG_CLAIM_EXCESS_HEAD, SAT_MOTOR_AUG_CLAIM_PAYMENT_TRANCHE, SAT_MOTOR_AUG_CLAIM_RECOVERY_EXPENSE_LINE, SAT_MOTOR_AUG_CLAIM_TAT_BREACH, SAT_CLAIM_MACT_AWARD_HEAD, SAT_CLAIM_PAYMENT_TRANCHE, SAT_CLAIM_RESERVE):
    -- one load time per CLAIM_BK, the newest REC_REFRESH_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when coalesce(m.AUG_CLAIM_EXCESS_HEAD__EXCESS_AMOUNT, m.AUG_CLAIM_EXCESS_HEAD__EXCESS_WAIVED_INDICATOR, m.AUG_CLAIM_EXCESS_HEAD__EXCESS_WAIVER_REASON, m.AUG_CLAIM_PAYMENT_TRANCHE__PAYMENT_CONFIRMED_INDICATOR, m.AUG_CLAIM_RECOVERY_EXPENSE_LINE__CONVEYANCE_AMOUNT, m.AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_AMOUNT, m.AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_CURRENCY_CODE, m.AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_HEAD_CODE, m.AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_HEAD_NAME, m.AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_PAYMENT_AMOUNT, m.AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_PAYMENT_APPROVED_BY_USER_REFERENCE, m.AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_PAYMENT_DATE, m.AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_PAYMENT_REFERENCE_NUMBER, m.AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_PAYMENT_TYPE, m.AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_PORTAL_PAYMENT_REFERENCE_NUMBER, m.AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_QUANTITY, m.AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_RATE, m.AUG_CLAIM_RECOVERY_EXPENSE_LINE__EXPENSE_REFERENCE_TEXT, m.AUG_CLAIM_RECOVERY_EXPENSE_LINE__FLAT_RATE_AMOUNT, m.AUG_CLAIM_TAT_BREACH__TAT_BREACH_INDICATOR, m.CLAIM_MACT_AWARD_HEAD__AWARDED_AMOUNT, m.CLAIM_MACT_AWARD_HEAD__INTEREST_AMOUNT, m.CLAIM_PAYMENT_TRANCHE__GROSS_AMOUNT, m.CLAIM_PAYMENT_TRANCHE__STATUS, m.CLAIM_RESERVE__CURRENT_RESERVE_AMOUNT, m.CLAIM_RESERVE__INITIAL_RESERVE_AMOUNT, m.CLAIM_RESERVE__RESERVE_TYPE) is not null
             then m.REC_REFRESH_AT end)
        over (partition by m.CLAIM_BK) as CLAIM_BK__MA_LOAD_DATETIME,
    -- multi-active satellites on LOCATION_BK (SAT_MOTOR_AUG_PARTY_CONTACT_ADDRESS_LINK):
    -- one load time per LOCATION_BK, the newest REC_REFRESH_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when coalesce(m.AUG_PARTY_CONTACT_ADDRESS_LINK__ADDRESS_PROOF_EFFECTIVE_DATE, m.AUG_PARTY_CONTACT_ADDRESS_LINK__OTHER_ADDRESS_PROOF_TYPE, m.AUG_PARTY_CONTACT_ADDRESS_LINK__SAME_AS_CORRESPONDENCE_ADDRESS_INDICATOR, m.AUG_PARTY_CONTACT_ADDRESS_LINK__SAME_AS_PRIMARY_ADDRESS_INDICATOR) is not null
             then m.REC_REFRESH_AT end)
        over (partition by m.LOCATION_BK) as LOCATION_BK__MA_LOAD_DATETIME,
    -- multi-active satellites on PARTY_BK (SAT_MOTOR_AUG_LNK_PARTY_ROLE_CORE, SAT_MOTOR_AUG_PARTY_BANKING, SAT_MOTOR_AUG_PARTY_IDENTIFICATION, SAT_LNK_ROLE_AGENT, SAT_LNK_ROLE_CUSTOMER, SAT_LNK_ROLE_EMPLOYEE, SAT_LNK_ROLE_PROVIDER, SAT_PARTY_BANKING, SAT_PARTY_IDENTIFICATION):
    -- one load time per PARTY_BK, the newest REC_REFRESH_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when coalesce(m.AUG_LNK_PARTY_ROLE_CORE__OTHER_RELATIONSHIP_DESCRIPTION, m.AUG_LNK_PARTY_ROLE_CORE__RELATIONSHIP_TO_HIGH_NET_WORTH_CUSTOMER, m.AUG_LNK_PARTY_ROLE_CORE__RELATIONSHIP_TO_INSURED, m.AUG_LNK_PARTY_ROLE_CORE__RELATIONSHIP_TO_INSURER_EMPLOYEE, m.AUG_LNK_PARTY_ROLE_CORE__RELATIONSHIP_TO_PRIVE_CUSTOMER, m.AUG_PARTY_BANKING__ACCOUNT_CATEGORY_CODE, m.AUG_PARTY_BANKING__ACCOUNT_NUMBER, m.AUG_PARTY_BANKING__APPROVED_OR_REJECTED_BY_USER_REFERENCE, m.AUG_PARTY_BANKING__APPROVED_OR_REJECTED_DATE, m.AUG_PARTY_BANKING__BANK_BRANCH_CODE, m.AUG_PARTY_BANKING__BANK_RECORD_REMARKS, m.AUG_PARTY_BANKING__NEFT_VALIDATION_STATUS, m.AUG_PARTY_BANKING__PAYEE_NAME_AS_PER_BANK_RECORD, m.AUG_PARTY_BANKING__PENNY_DROP_SKIPPED_INDICATOR, m.AUG_PARTY_BANKING__PENNY_DROP_VERIFICATION_SCORE, m.AUG_PARTY_IDENTIFICATION__AADHAAR_ENROLMENT_NUMBER, m.AUG_PARTY_IDENTIFICATION__AADHAAR_VIRTUAL_IDENTIFIER, m.AUG_PARTY_IDENTIFICATION__ABHA_NUMBER, m.AUG_PARTY_IDENTIFICATION__DRIVING_LICENCE_DETAIL_TEXT, m.AUG_PARTY_IDENTIFICATION__DRIVING_LICENCE_TYPE, m.AUG_PARTY_IDENTIFICATION__EIA_AVAILABLE_INDICATOR, m.AUG_PARTY_IDENTIFICATION__EIA_DETAIL_TEXT, m.AUG_PARTY_IDENTIFICATION__EIA_LINKAGE_DATE, m.AUG_PARTY_IDENTIFICATION__EIA_POLICY_CREDIT_REQUIRED_INDICATOR, m.AUG_PARTY_IDENTIFICATION__EIA_REQUIRED_INDICATOR, m.AUG_PARTY_IDENTIFICATION__GST_COMPOSITION_SCHEME_INDICATOR, m.AUG_PARTY_IDENTIFICATION__GST_PAYABLE_INDICATOR, m.AUG_PARTY_IDENTIFICATION__IDENTIFICATION_ISSUING_COUNTRY, m.AUG_PARTY_IDENTIFICATION__IDENTIFICATION_PLACE_OF_ISSUE, m.AUG_PARTY_IDENTIFICATION__IDENTIFICATION_VALID_FROM_DATE, m.AUG_PARTY_IDENTIFICATION__NAME_AS_PER_IDENTIFICATION_DOCUMENT, m.AUG_PARTY_IDENTIFICATION__PAN_AADHAAR_LINKED_INDICATOR, m.AUG_PARTY_IDENTIFICATION__PASSPORT_DETAIL_TEXT, m.AUG_PARTY_IDENTIFICATION__PASSPORT_FILE_NUMBER, m.AUG_PARTY_IDENTIFICATION__PROOF_OF_ADDRESS_STATUS, m.AUG_PARTY_IDENTIFICATION__PROOF_OF_IDENTITY_STATUS, m.AUG_PARTY_IDENTIFICATION__STATE_WISE_GSTIN_DETAIL_TEXT, m.LNK_ROLE_AGENT__AGENCY_TYPE, m.LNK_ROLE_AGENT__APPOINTMENT_DATE, m.LNK_ROLE_AGENT__IRDAI_AGENT_LICENCE_NUMBER, m.LNK_ROLE_AGENT__LICENCE_CATEGORY, m.LNK_ROLE_AGENT__LICENCE_EXPIRY_DATE, m.LNK_ROLE_AGENT__LICENCE_ISSUE_DATE, m.LNK_ROLE_CUSTOMER__BLACKLIST_INDICATOR, m.LNK_ROLE_CUSTOMER__BLACKLIST_REASON, m.LNK_ROLE_CUSTOMER__CONSENT_FOR_DATA_SHARING_INDICATOR, m.LNK_ROLE_CUSTOMER__VIP_INDICATOR, m.LNK_ROLE_EMPLOYEE__DEPARTMENT, m.LNK_ROLE_EMPLOYEE__EMPLOYEE_CODE, m.LNK_ROLE_EMPLOYEE__FUNCTION, m.LNK_ROLE_PROVIDER__SERVICE_REGION, m.LNK_ROLE_PROVIDER__SERVICE_SCOPE_DESCRIPTION, m.PARTY_BANKING__ACCOUNT_HOLDER_NAME, m.PARTY_BANKING__ACCOUNT_NUMBER_MASKED, m.PARTY_BANKING__ACCOUNT_TYPE, m.PARTY_BANKING__BANK_NAME, m.PARTY_BANKING__BRANCH_NAME, m.PARTY_BANKING__IFSC_CODE, m.PARTY_BANKING__MICR_CODE, m.PARTY_BANKING__PRIMARY_ACCOUNT_INDICATOR, m.PARTY_IDENTIFICATION__AADHAAR_NUMBER, m.PARTY_IDENTIFICATION__AGE_PROOF_TYPE, m.PARTY_IDENTIFICATION__CKYC_NUMBER, m.PARTY_IDENTIFICATION__DRIVING_LICENCE_EXPIRY_DATE, m.PARTY_IDENTIFICATION__DRIVING_LICENCE_NUMBER, m.PARTY_IDENTIFICATION__EIA_NUMBER, m.PARTY_IDENTIFICATION__GSTIN, m.PARTY_IDENTIFICATION__GST_REGISTRATION_STATUS, m.PARTY_IDENTIFICATION__GST_TAXPAYER_TYPE, m.PARTY_IDENTIFICATION__IDENTIFICATION_EXPIRY_DATE, m.PARTY_IDENTIFICATION__IDENTIFICATION_ISSUE_DATE, m.PARTY_IDENTIFICATION__IDENTIFICATION_ISSUING_AUTHORITY, m.PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER, m.PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE, m.PARTY_IDENTIFICATION__IDENTIFICATION_VERIFIED_INDICATOR, m.PARTY_IDENTIFICATION__INSURANCE_REPOSITORY_NAME, m.PARTY_IDENTIFICATION__NREGA_CARD_NUMBER, m.PARTY_IDENTIFICATION__PAN_NUMBER, m.PARTY_IDENTIFICATION__PASSPORT_EXPIRY_DATE, m.PARTY_IDENTIFICATION__PASSPORT_NUMBER, m.PARTY_IDENTIFICATION__TAN_NUMBER, m.PARTY_IDENTIFICATION__VAT_REGISTRATION_NUMBER, m.PARTY_IDENTIFICATION__VOTER_ID_NUMBER) is not null
             then m.REC_REFRESH_AT end)
        over (partition by m.PARTY_BK) as PARTY_BK__MA_LOAD_DATETIME,
    -- multi-active satellites on QUOTE_BK (SAT_QUOTE_COMPARISON):
    -- one load time per QUOTE_BK, the newest REC_REFRESH_AT of the rows carrying any of their data;
    -- all child rows of a parent share it (ma_sat finds its latest set by time).
    max(case when m.QUOTE_COMPARISON__SELECTED_INDICATOR is not null
             then m.REC_REFRESH_AT end)
        over (partition by m.QUOTE_BK) as QUOTE_BK__MA_LOAD_DATETIME
from merged m
