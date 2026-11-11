-- CENTRAL VIEW v10_party -- the layer the governing central-view rule is about.
-- Feeding tables (rule 1 counts these):
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_PARTYDETAILS_PIVOT_VW
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_PAYMENT_CLAIM_PAYMENT_DETAIL_ATTRIBUTES_PIVOT_VW
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_LIST_OF_COVERS_ENTITY_HEADS_ENTITY_GRID_ROWS_ROW_ATTRIBUTES_PIVOT_VW
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_PARTY
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_RELATION_ATTRIBUTE_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_PAYMENT_INFO_PIVOT_VW
--   MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY
--   MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW
-- Walk tables, joined only to resolve spine keys (not counted):
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_PARTYDETAILS
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS
--   MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_RELATION_ATTRIBUTE
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS
--   MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS
--   MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_COMMON_ADDRESS
--   SAT_AUG_COMMON_COMMUNICATION_PREFERENCE
--   SAT_AUG_PARTY_BANKING
--   SAT_AUG_PARTY_CONSENT_MANDATE
--   SAT_AUG_PARTY_CONTACT_ADDRESS_LINK
--   SAT_AUG_PARTY_DIGITAL_IDENTITY
--   SAT_AUG_PARTY_EMPLOYMENT
--   SAT_AUG_PARTY_FRAUD_PROFILE
--   SAT_AUG_PARTY_GROUP_SCHEME
--   SAT_AUG_PARTY_HIERARCHY
--   SAT_AUG_PARTY_IDENTIFICATION
--   SAT_AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS
--   SAT_AUG_PARTY_KYC
--   SAT_AUG_PARTY_LEGAL_PANEL
--   SAT_AUG_PARTY_ONBOARDING_JOURNEY
--   SAT_AUG_PARTY_ORGANISATION_PROFILE
--   SAT_AUG_PARTY_PAYOUT_PROFILE
--   SAT_AUG_PARTY_PREFERENCE_PROFILE
--   SAT_AUG_PARTY_RELATIONSHIP_PROFILE
--   SAT_COMMON_CLASSIFICATION
--   SAT_COMMON_COMMUNICATION_PREFERENCE
--   SAT_COMMON_CONSENT
--   SAT_COMMON_GEO
--   SAT_FINTXN_CLAIM_PAYMENT
--   SAT_FINTXN_TAX
--   SAT_LNK_PARTY_ROLE_CORE
--   SAT_LNK_ROLE_AGENT
--   SAT_LNK_ROLE_CUSTOMER
--   SAT_LNK_ROLE_EMPLOYEE
--   SAT_LNK_ROLE_PROVIDER
--   SAT_PARTY_AGENT_LICENCE_LINE
--   SAT_PARTY_AML_SCREENING
--   SAT_PARTY_BANKING
--   SAT_PARTY_EMPLOYMENT
--   SAT_PARTY_FRAUD_PROFILE
--   SAT_PARTY_HEALTH_PROFILE
--   SAT_PARTY_HIERARCHY
--   SAT_PARTY_IDENTIFICATION
--   SAT_PARTY_INDIVIDUAL_DEMOGRAPHICS
--   SAT_PARTY_KYC
--   SAT_PARTY_LEGAL_PANEL
--   SAT_PARTY_ORGANISATION_PROFILE
--   SAT_PARTY_ORG_DIRECTORS
--   SAT_PARTY_PAYOUT_PROFILE
--   SAT_PARTY_PROVIDER_CAPABILITY
--   SAT_PROVIDER_QUALITY
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_ORG_UNIT_LOCATION
--   LNK_PARTY_LOCATION
--   LNK_PARTY_ORG_UNIT
--   LNK_QUOTE_PARTY
--   LNK_QUOTE_PRODUCT
-- OVER the table limit by rule 3: one satellite on this view needs every feeding table.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
{{ config(materialized='view') }}

with merged as (

    -- branch 0: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW
    select
        cast(null as varchar) as FINANCIAL_TRANSACTION_BK,
        cast(null as varchar) as LOCATION_BK,
        cast(null as varchar) as ORG_UNIT_BK,
        nullif('MEMBER:' || coalesce( nullif(trim(t0.insured_member_code),'') , nullif(trim(t0.health_card_number),'') ), '') as PARTY_BK,
        cast(null as varchar) as PRODUCT_BK,
        cast(null as varchar) as QUOTE_BK,
        cast(null as varchar) as ROLE_TYPE_CODE,
        cast(null as number) as __LNK_ORG_UNIT_LOCATION,
        cast(null as number) as __LNK_PARTY_LOCATION,
        cast(null as number) as __LNK_PARTY_ORG_UNIT,
        cast(null as number) as __LNK_QUOTE_PARTY,
        cast(null as number) as __LNK_QUOTE_PRODUCT,
        cast(null as varchar) as AUG_COMMON_ADDRESS__FULL_ADDRESS_TEXT,
        cast(null as varchar) as AUG_COMMON_COMMUNICATION_PREFERENCE__PREFERRED_ALERT_CHANNEL,
        cast(null as varchar) as AUG_PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK,
        cast(null as varchar) as AUG_PARTY_BANKING__BANK_DETAIL_TEXT,
        cast(null as varchar) as AUG_PARTY_CONSENT_MANDATE__MANDATE_DETAIL_DESCRIPTION,
        cast(null as varchar) as AUG_PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE_CK,
        cast(null as varchar) as AUG_PARTY_CONTACT_ADDRESS_LINK__SAME_AS_CORRESPONDENCE_ADDRESS_INDICATOR,
        cast(null as varchar) as AUG_PARTY_CONTACT_ADDRESS_LINK__SAME_AS_POLICYHOLDER_ADDRESS_INDICATOR,
        cast(null as varchar) as AUG_PARTY_CONTACT_ADDRESS_LINK__SAME_AS_PRIMARY_ADDRESS_INDICATOR,
        cast(null as varchar) as AUG_PARTY_DIGITAL_IDENTITY__ACTIVE_SEQUENCE_NUMBER_CK,
        cast(null as varchar) as AUG_PARTY_DIGITAL_IDENTITY__DEVICE_MAKE_AND_MODEL,
        cast(null as varchar) as AUG_PARTY_DIGITAL_IDENTITY__USER_TYPE,
        cast(null as varchar) as AUG_PARTY_EMPLOYMENT__EMPLOYER_DETAIL_DESCRIPTION,
        cast(null as varchar) as AUG_PARTY_EMPLOYMENT__OTHER_OCCUPATION,
        cast(null as varchar) as AUG_PARTY_EMPLOYMENT__PRIMARY_PROFESSION,
        cast(null as varchar) as AUG_PARTY_EMPLOYMENT__TOTAL_YEARS_OF_EXPERIENCE,
        cast(null as varchar) as AUG_PARTY_EMPLOYMENT__USED_CAR_DEALER_OCCUPATION_INDICATOR,
        cast(null as varchar) as AUG_PARTY_FRAUD_PROFILE__NEGATIVE_LIST_DETAILS,
        cast(null as varchar) as AUG_PARTY_FRAUD_PROFILE__NON_DISCLOSURE_ACTION_INITIATED_INDICATOR,
        cast(null as varchar) as AUG_PARTY_FRAUD_PROFILE__PARTY_BLOCK_STATUS,
        cast(null as varchar) as AUG_PARTY_GROUP_SCHEME__AFFINITY_PARTNER_EMPLOYEE_INDICATOR,
        cast(null as varchar) as AUG_PARTY_GROUP_SCHEME__GROUP_HEALTH_USER_TYPE,
        cast(null as varchar) as AUG_PARTY_HIERARCHY__RELATIONSHIP_ASSOCIATE_EMPLOYEE_CODE,
        cast(null as varchar) as AUG_PARTY_HIERARCHY__TRANSFER_CASE_REFERENCE,
        cast(null as varchar) as AUG_PARTY_HIERARCHY__TRANSFER_INDICATOR,
        cast(null as varchar) as AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        cast(null as varchar) as AUG_PARTY_IDENTIFICATION__CLAIM_CONTEXT_IDENTIFICATION_VERIFIED_INDICATOR,
        cast(null as varchar) as AUG_PARTY_IDENTIFICATION__EIA_AVAILABLE_INDICATOR,
        cast(null as varchar) as AUG_PARTY_IDENTIFICATION__EIA_CREDIT_REQUIRED_INDICATOR,
        cast(null as varchar) as AUG_PARTY_IDENTIFICATION__EIA_DETAILS_DESCRIPTION,
        cast(null as varchar) as AUG_PARTY_IDENTIFICATION__EIA_REQUIRED_INDICATOR,
        cast(null as varchar) as AUG_PARTY_IDENTIFICATION__NAME_AS_PER_IDENTIFICATION_DOCUMENT,
        cast(null as varchar) as AUG_PARTY_IDENTIFICATION__PAN_AADHAAR_LINKED_INDICATOR,
        cast(null as varchar) as AUG_PARTY_IDENTIFICATION__PAN_APPLICATION_NUMBER,
        cast(null as varchar) as AUG_PARTY_IDENTIFICATION__PAN_APPLIED_INDICATOR,
        cast(null as varchar) as AUG_PARTY_IDENTIFICATION__PASSPORT_DETAIL_DESCRIPTION,
        cast(null as varchar) as AUG_PARTY_IDENTIFICATION__PASSPORT_FILE_NUMBER,
        cast(null as varchar) as AUG_PARTY_IDENTIFICATION__PROOF_OF_ADDRESS_OTHER_DESCRIPTION,
        cast(null as varchar) as AUG_PARTY_IDENTIFICATION__STATE_WISE_GSTIN_REGISTRATION_DETAILS,
        cast(null as varchar) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__BASIC_QUALIFICATION_DESCRIPTION,
        cast(null as varchar) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__BASIC_QUALIFICATION_ROLL_NUMBER,
        cast(null as varchar) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__MARRIAGE_ANNIVERSARY_DATE,
        cast(null as varchar) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__MATRICULATION_QUALIFICATION_INDICATOR,
        cast(null as varchar) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__MOTHER_MAIDEN_NAME,
        cast(null as varchar) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__NUMBER_OF_DAUGHTERS,
        cast(null as varchar) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__NUMBER_OF_SONS,
        cast(null as varchar) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__OTHER_RELATIONSHIP_DESCRIPTION,
        cast(null as varchar) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__PERSONAL_DETAILS_DESCRIPTION,
        cast(null as varchar) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__POSTGRADUATE_QUALIFICATION,
        cast(null as varchar) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__PROFESSIONAL_QUALIFICATION,
        cast(null as varchar) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__QUALIFICATION_BOARD_NAME,
        cast(null as varchar) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__QUALIFICATION_DETAILS,
        cast(null as varchar) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__RELATIONSHIP_TO_PRIMARY_INSURED,
        cast(null as varchar) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__UNDERGRADUATE_QUALIFICATION,
        cast(null as varchar) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__YEAR_OF_PASSING_QUALIFICATION,
        cast(null as varchar) as AUG_PARTY_KYC__CKYC_DETAILS_DESCRIPTION,
        cast(null as varchar) as AUG_PARTY_KYC__KYC_DETAIL_DESCRIPTION,
        cast(null as varchar) as AUG_PARTY_KYC__OPTIONAL_PROOF_OF_POSSESSION_TYPE,
        cast(null as varchar) as AUG_PARTY_KYC__PRIMARY_PROOF_OF_POSSESSION_TYPE,
        cast(null as varchar) as AUG_PARTY_LEGAL_PANEL__CONSUMER_CASES_HANDLED_COUNT,
        cast(null as varchar) as AUG_PARTY_LEGAL_PANEL__COVERED_COURT_LOCATIONS,
        cast(null as varchar) as AUG_PARTY_LEGAL_PANEL__EMPANELLED_COMPANIES_COUNT,
        cast(null as varchar) as AUG_PARTY_LEGAL_PANEL__FIRM_NAME,
        cast(null as varchar) as AUG_PARTY_LEGAL_PANEL__HIGH_COURT_PRACTICE_INDICATOR,
        cast(null as varchar) as AUG_PARTY_LEGAL_PANEL__MACT_CASES_HANDLED_COUNT,
        cast(null as varchar) as AUG_PARTY_LEGAL_PANEL__MACT_CASES_HANDLED_OTHER_COMPANY_COUNT,
        cast(null as varchar) as AUG_PARTY_LEGAL_PANEL__PRACTISING_WITH_HIGH_COURT_INDICATOR,
        cast(null as varchar) as AUG_PARTY_LEGAL_PANEL__SERVICING_INSURER_OFFICE_ADDRESS,
        cast(null as varchar) as AUG_PARTY_LEGAL_PANEL__WC_CASES_HANDLED_COUNT,
        cast(null as varchar) as AUG_PARTY_ONBOARDING_JOURNEY__APPLICATION_REJECTION_REASON,
        cast(null as varchar) as AUG_PARTY_ONBOARDING_JOURNEY__CANDIDATE_BACKGROUND_DESCRIPTION,
        cast(null as varchar) as AUG_PARTY_ONBOARDING_JOURNEY__EXISTING_PARTY_SEARCH_INDICATOR,
        cast(null as varchar) as AUG_PARTY_ONBOARDING_JOURNEY__PREVIOUS_EMPLOYER_LOCATION,
        cast(null as varchar) as AUG_PARTY_ONBOARDING_JOURNEY__PREVIOUS_EMPLOYER_PARENT_INTERMEDIARY_CODE,
        cast(null as varchar) as AUG_PARTY_ONBOARDING_JOURNEY__PREVIOUS_EMPLOYER_PARENT_SUB_INTERMEDIARY_CODE,
        cast(null as varchar) as AUG_PARTY_ONBOARDING_JOURNEY__PREVIOUS_NON_GENERAL_INSURER_NAME,
        cast(null as varchar) as AUG_PARTY_ONBOARDING_JOURNEY__REASON_FOR_LEAVING_PREVIOUS_EMPLOYER,
        cast(null as varchar) as AUG_PARTY_ORGANISATION_PROFILE__BUSINESS_DESCRIPTION,
        cast(null as varchar) as AUG_PARTY_ORGANISATION_PROFILE__CLIENT_GEOGRAPHY_CLASSIFICATION,
        cast(null as varchar) as AUG_PARTY_ORGANISATION_PROFILE__CONTACT_PERSON_NAME,
        cast(null as varchar) as AUG_PARTY_ORGANISATION_PROFILE__INFRASTRUCTURE_SUB_SECTOR,
        cast(null as varchar) as AUG_PARTY_ORGANISATION_PROFILE__PRACTISING_FIRM_NAME,
        cast(null as varchar) as AUG_PARTY_ORGANISATION_PROFILE__REGISTERED_BUSINESS_TRUST_INDICATOR,
        cast(null as varchar) as AUG_PARTY_ORGANISATION_PROFILE__REGISTERED_COMPANY_INDICATOR,
        cast(null as varchar) as AUG_PARTY_ORGANISATION_PROFILE__REPRESENTED_BUSINESS_NAME,
        cast(null as varchar) as AUG_PARTY_ORGANISATION_PROFILE__STATE_WISE_GSTIN_DETAILS,
        cast(null as varchar) as AUG_PARTY_ORGANISATION_PROFILE__TRADE_NAME,
        cast(null as varchar) as AUG_PARTY_ORGANISATION_PROFILE__TRUST_TYPE,
        cast(null as varchar) as AUG_PARTY_PAYOUT_PROFILE__FLOAT_ACCOUNT_ACCESS_INDICATOR,
        cast(null as varchar) as AUG_PARTY_PAYOUT_PROFILE__PAYMENT_MODE,
        cast(null as varchar) as AUG_PARTY_PAYOUT_PROFILE__REWARD_SCHEME_APPLICABLE_INDICATOR,
        cast(null as varchar) as AUG_PARTY_PAYOUT_PROFILE__TDS_CODE,
        cast(null as varchar) as AUG_PARTY_PAYOUT_PROFILE__TDS_CODE_DESCRIPTION,
        cast(null as varchar) as AUG_PARTY_PAYOUT_PROFILE__TDS_DETAILS,
        cast(null as varchar) as AUG_PARTY_PAYOUT_PROFILE__TDS_DETAILS_DESCRIPTION,
        cast(null as varchar) as AUG_PARTY_PREFERENCE_PROFILE__ELECTRONIC_POLICY_ISSUANCE_PREFERENCE_INDICATOR,
        cast(null as varchar) as AUG_PARTY_PREFERENCE_PROFILE__PREFERRED_REIMBURSEMENT_METHOD,
        cast(null as varchar) as AUG_PARTY_PREFERENCE_PROFILE__PROPAGATE_CONTACT_UPDATE_TO_ALL_POLICIES_INDICATOR,
        cast(null as varchar) as AUG_PARTY_PREFERENCE_PROFILE__REIMBURSEMENT_PREFERENCE,
        cast(null as varchar) as AUG_PARTY_RELATIONSHIP_PROFILE__RELATIONSHIP_WITH_EMPLOYEE,
        cast(null as varchar) as AUG_PARTY_RELATIONSHIP_PROFILE__RELATIONSHIP_WITH_HNI_CUSTOMER,
        cast(null as varchar) as AUG_PARTY_RELATIONSHIP_PROFILE__RELATIONSHIP_WITH_PRIVE_CUSTOMER,
        cast(null as varchar) as COMMON_CLASSIFICATION__CATEGORY_CODE,
        t0.customer_segment as COMMON_CLASSIFICATION__SEGMENT_CODE,
        cast(null as varchar) as COMMON_CLASSIFICATION__SEGMENT_NAME,
        cast(null as varchar) as COMMON_CLASSIFICATION__TIER_CODE,
        t0.hni_flag as COMMON_CLASSIFICATION__VALUE_BAND,
        cast(null as varchar) as COMMON_COMMUNICATION_PREFERENCE__CORRESPONDENCE_LANGUAGE,
        cast(null as varchar) as COMMON_COMMUNICATION_PREFERENCE__GO_GREEN_OPT_IN_INDICATOR,
        cast(null as varchar) as COMMON_COMMUNICATION_PREFERENCE__PREFERRED_CHANNEL_CODE,
        cast(null as varchar) as COMMON_COMMUNICATION_PREFERENCE__PREFERRED_LANGUAGE_CODE,
        cast(null as varchar) as COMMON_CONSENT__CONSENT_GIVEN_INDICATOR,
        cast(null as varchar) as COMMON_GEO__REGION_NAME,
        cast(null as varchar) as COMMON_GEO__URBAN_RURAL_CLASSIFICATION,
        cast(null as varchar) as COMMON_GEO__ZONE_CODE,
        cast(null as varchar) as FINTXN_CLAIM_PAYMENT__CHEQUE_DISPATCH_DATE,
        cast(null as varchar) as FINTXN_CLAIM_PAYMENT__NET_PAID_AMOUNT,
        cast(null as varchar) as FINTXN_CLAIM_PAYMENT__PAYMENT_DATE,
        cast(null as varchar) as FINTXN_CLAIM_PAYMENT__PAYMENT_MODE,
        cast(null as varchar) as FINTXN_CLAIM_PAYMENT__PAYMENT_STATUS,
        cast(null as varchar) as FINTXN_CLAIM_PAYMENT__PAYMENT_TYPE,
        cast(null as varchar) as FINTXN_CLAIM_PAYMENT__TDS_ON_CLAIM_AMOUNT,
        cast(null as varchar) as FINTXN_CLAIM_PAYMENT__UTR_NUMBER,
        cast(null as varchar) as FINTXN_TAX__TAX_TYPE_CK,
        cast(null as varchar) as FINTXN_TAX__COMPONENT_TAX_AMOUNT,
        cast(null as varchar) as FINTXN_TAX__GSTIN,
        cast(null as varchar) as FINTXN_TAX__HSN_SAC_CODE,
        cast(null as varchar) as FINTXN_TAX__SERVICE_TAX_APPLICABLE_INDICATOR,
        cast(null as varchar) as FINTXN_TAX__SERVICE_TAX_REGISTRATION_NUMBER,
        cast(null as varchar) as FINTXN_TAX__TAX_APPLICABLE_INDICATOR,
        cast(null as varchar) as FINTXN_TAX__TAX_RATE,
        cast(null as varchar) as FINTXN_TAX__TDS_SECTION,
        cast(null as varchar) as LNK_PARTY_ROLE_CORE__ROLE_CODE_CK,
        cast(null as varchar) as LNK_PARTY_ROLE_CORE__ROLE_SEQUENCE_CK,
        cast(null as varchar) as LNK_PARTY_ROLE_CORE__ROLE_CODE,
        cast(null as varchar) as LNK_PARTY_ROLE_CORE__ROLE_END_DATE,
        cast(null as varchar) as LNK_PARTY_ROLE_CORE__ROLE_TYPE,
        cast(null as varchar) as LNK_ROLE_AGENT__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_AGENT__AGENCY_TYPE,
        cast(null as varchar) as LNK_ROLE_AGENT__AGENT_CODE,
        cast(null as varchar) as LNK_ROLE_AGENT__APPOINTMENT_DATE,
        cast(null as varchar) as LNK_ROLE_AGENT__IRDAI_AGENT_LICENCE_NUMBER,
        cast(null as varchar) as LNK_ROLE_AGENT__LICENCE_CATEGORY,
        cast(null as varchar) as LNK_ROLE_AGENT__LICENCE_EXPIRY_DATE,
        cast(null as varchar) as LNK_ROLE_AGENT__LICENCE_ISSUE_DATE,
        cast(null as varchar) as LNK_ROLE_AGENT__POSP_INDICATOR,
        cast(null as varchar) as LNK_ROLE_AGENT__TERMINATION_DATE,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__CONSENT_FOR_DATA_SHARING_INDICATOR,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__CUSTOMER_CATEGORY,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__CUSTOMER_SEGMENT,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__PREFERRED_CUSTOMER_INDICATOR,
        cast(null as varchar) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        cast(null as varchar) as LNK_ROLE_EMPLOYEE__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_EMPLOYEE__ACTIVE_INDICATOR,
        cast(null as varchar) as LNK_ROLE_EMPLOYEE__DEPARTMENT,
        cast(null as varchar) as LNK_ROLE_EMPLOYEE__DESIGNATION,
        cast(null as varchar) as LNK_ROLE_EMPLOYEE__EMPLOYEE_CODE,
        cast(null as varchar) as LNK_ROLE_EMPLOYEE__FUNCTION,
        cast(null as varchar) as LNK_ROLE_PROVIDER__ROLE_TYPE_CK,
        cast(null as varchar) as LNK_ROLE_PROVIDER__BED_COUNT,
        cast(null as varchar) as LNK_ROLE_PROVIDER__EMPANELMENT_STATUS,
        cast(null as varchar) as LNK_ROLE_PROVIDER__MOU_STATUS,
        cast(null as varchar) as LNK_ROLE_PROVIDER__PROVIDER_TYPE,
        cast(null as varchar) as LNK_ROLE_PROVIDER__SERVICE_REGION,
        cast(null as varchar) as LNK_ROLE_PROVIDER__SUSPENSION_INDICATOR,
        cast(null as varchar) as PARTY_AGENT_LICENCE_LINE__LINE_OF_BUSINESS_CK,
        cast(null as varchar) as PARTY_AGENT_LICENCE_LINE__EXAMINATION_REFERENCE,
        cast(null as varchar) as PARTY_AML_SCREENING__SCREENING_STATUS,
        cast(null as varchar) as PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK,
        cast(null as varchar) as PARTY_BANKING__ACCOUNT_HOLDER_NAME,
        cast(null as varchar) as PARTY_BANKING__ACCOUNT_NUMBER_MASKED,
        cast(null as varchar) as PARTY_BANKING__ACCOUNT_TYPE,
        cast(null as varchar) as PARTY_BANKING__BANK_CODE,
        cast(null as varchar) as PARTY_BANKING__BANK_NAME,
        cast(null as varchar) as PARTY_BANKING__BRANCH_NAME,
        cast(null as varchar) as PARTY_BANKING__IFSC_CODE,
        cast(null as varchar) as PARTY_BANKING__MICR_CODE,
        cast(null as varchar) as PARTY_EMPLOYMENT__DESIGNATION,
        cast(null as varchar) as PARTY_EMPLOYMENT__EMPLOYER_NAME,
        cast(null as varchar) as PARTY_EMPLOYMENT__EMPLOYMENT_STATUS,
        cast(null as varchar) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        t0.occupation as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        cast(null as varchar) as PARTY_EMPLOYMENT__PROFESSIONAL_REGISTRATION_NUMBER,
        cast(null as varchar) as PARTY_EMPLOYMENT__WORK_NATURE,
        cast(null as varchar) as PARTY_FRAUD_PROFILE__NEGATIVE_LIST_INDICATOR,
        cast(null as varchar) as PARTY_FRAUD_PROFILE__NEGATIVE_LIST_REASON,
        cast(null as varchar) as PARTY_FRAUD_PROFILE__WATCH_START_DATE,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__ALCOHOL_UNITS_PER_WEEK,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__BODY_MASS_INDEX,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__CIGARETTES_PER_DAY,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__CURRENT_MEDICATION_DETAIL,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__DISABILITY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__DISABILITY_PERCENTAGE,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__HEIGHT,
        t0.personal_habits as PARTY_HEALTH_PROFILE__LIFESTYLE_RISK_INDICATOR,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        cast(null as varchar) as PARTY_HEALTH_PROFILE__WEIGHT,
        cast(null as varchar) as PARTY_HIERARCHY__HIERARCHY_LEVEL,
        cast(null as varchar) as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        cast(null as varchar) as PARTY_IDENTIFICATION__AADHAAR_NUMBER,
        cast(null as varchar) as PARTY_IDENTIFICATION__AADHAAR_VERIFICATION_STATUS,
        cast(null as varchar) as PARTY_IDENTIFICATION__AGE_PROOF_TYPE,
        cast(null as varchar) as PARTY_IDENTIFICATION__CIN_NUMBER,
        cast(null as varchar) as PARTY_IDENTIFICATION__DRIVING_LICENCE_EXPIRY_DATE,
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
        cast(null as varchar) as PARTY_IDENTIFICATION__NREGA_CARD_NUMBER,
        cast(null as varchar) as PARTY_IDENTIFICATION__OVD_CATEGORY,
        cast(null as varchar) as PARTY_IDENTIFICATION__PAN_NUMBER,
        cast(null as varchar) as PARTY_IDENTIFICATION__PAN_VERIFICATION_STATUS,
        cast(null as varchar) as PARTY_IDENTIFICATION__PASSPORT_NUMBER,
        cast(null as varchar) as PARTY_IDENTIFICATION__TAN_NUMBER,
        cast(null as varchar) as PARTY_IDENTIFICATION__VOTER_ID_NUMBER,
        cast(null as varchar) as PARTY_INDIVIDUAL_DEMOGRAPHICS__ANNUAL_HOUSEHOLD_INCOME,
        cast(null as varchar) as PARTY_INDIVIDUAL_DEMOGRAPHICS__EDUCATIONAL_QUALIFICATION,
        cast(null as varchar) as PARTY_INDIVIDUAL_DEMOGRAPHICS__EMPLOYMENT_TYPE,
        cast(null as varchar) as PARTY_INDIVIDUAL_DEMOGRAPHICS__FATHER_NAME,
        cast(null as varchar) as PARTY_INDIVIDUAL_DEMOGRAPHICS__HIGHEST_DEGREE,
        cast(null as varchar) as PARTY_INDIVIDUAL_DEMOGRAPHICS__MARITAL_STATUS,
        cast(null as varchar) as PARTY_INDIVIDUAL_DEMOGRAPHICS__SPOUSE_NAME,
        cast(null as varchar) as PARTY_INDIVIDUAL_DEMOGRAPHICS__VEHICLE_OWNED_INDICATOR,
        cast(null as varchar) as PARTY_INDIVIDUAL_DEMOGRAPHICS__YEARS_IN_CITY,
        t0.ckyc_number as PARTY_KYC__CKYC_NUMBER,
        t0.ckyc_status as PARTY_KYC__CKYC_REGISTRATION_STATUS,
        cast(null as varchar) as PARTY_KYC__KYC_COMPLETED_INDICATOR,
        t0.ckyc_bypass as PARTY_KYC__KYC_WAIVER_INDICATOR,
        cast(null as varchar) as PARTY_LEGAL_PANEL__ADVOCATE_TYPE,
        cast(null as varchar) as PARTY_LEGAL_PANEL__AGREEMENT_STATUS,
        cast(null as varchar) as PARTY_LEGAL_PANEL__BAR_COUNCIL_NAME,
        cast(null as varchar) as PARTY_LEGAL_PANEL__BAR_ENROLMENT_NUMBER,
        cast(null as varchar) as PARTY_LEGAL_PANEL__CASES_HANDLED_COUNT,
        cast(null as varchar) as PARTY_LEGAL_PANEL__EMPANELMENT_DATE,
        cast(null as varchar) as PARTY_LEGAL_PANEL__JUNIORS_COUNT,
        cast(null as varchar) as PARTY_LEGAL_PANEL__PANEL_CATEGORY,
        cast(null as varchar) as PARTY_LEGAL_PANEL__YEARS_OF_PRACTICE,
        cast(null as varchar) as PARTY_ORGANISATION_PROFILE__ANNUAL_TURNOVER,
        cast(null as varchar) as PARTY_ORGANISATION_PROFILE__BUSINESS_REGISTRATION_NUMBER,
        cast(null as varchar) as PARTY_ORGANISATION_PROFILE__DATE_OF_INCORPORATION,
        cast(null as varchar) as PARTY_ORGANISATION_PROFILE__GROUP_NAME,
        cast(null as varchar) as PARTY_ORGANISATION_PROFILE__INDUSTRY_CODE,
        cast(null as varchar) as PARTY_ORGANISATION_PROFILE__INDUSTRY_DESCRIPTION,
        cast(null as varchar) as PARTY_ORGANISATION_PROFILE__LEGAL_CONSTITUTION_TYPE,
        cast(null as varchar) as PARTY_ORGANISATION_PROFILE__MSME_CATEGORY,
        cast(null as varchar) as PARTY_ORGANISATION_PROFILE__MSME_INDICATOR,
        cast(null as varchar) as PARTY_ORGANISATION_PROFILE__NATURE_OF_BUSINESS,
        cast(null as varchar) as PARTY_ORGANISATION_PROFILE__NIC_CODE,
        cast(null as varchar) as PARTY_ORGANISATION_PROFILE__PAID_UP_CAPITAL,
        cast(null as varchar) as PARTY_ORGANISATION_PROFILE__PARENT_ENTITY_NAME,
        cast(null as varchar) as PARTY_ORG_DIRECTORS__DIN_NUMBER_CK,
        cast(null as varchar) as PARTY_ORG_DIRECTORS__DIRECTOR_NAME,
        cast(null as varchar) as PARTY_PAYOUT_PROFILE__GST_APPLICABLE_INDICATOR,
        cast(null as varchar) as PARTY_PAYOUT_PROFILE__TDS_RATE,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        cast(null as varchar) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        cast(null as varchar) as PROVIDER_QUALITY__QUALITY_RATING,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif('MEMBER:' || coalesce( nullif(trim(t0.insured_member_code),'') , nullif(trim(t0.health_card_number),'') ), '')) is not null

    union all

    -- branch 1: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): FINTXN_TAX.Tax Type=GST
    select
        nullif('CLAIM_TAX:' || nullif(trim(t0.claim_number),''), '') as FINANCIAL_TRANSACTION_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'GST' as FINTXN_TAX__TAX_TYPE_CK,
        null,
        t0.gst_number as FINTXN_TAX__GSTIN,
        t0.hsnsac_code as FINTXN_TAX__HSN_SAC_CODE,
        null, null,
        t0.gst_applicable as FINTXN_TAX__TAX_APPLICABLE_INDICATOR,
        t0.gst_percentage as FINTXN_TAX__TAX_RATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif('CLAIM_TAX:' || nullif(trim(t0.claim_number),''), '')) is not null

    union all

    -- branch 2: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): LNK_ROLE_PROVIDER.Role Type=PROVIDER
    select
        null, null, null,
        nullif('PROVIDER:' || nullif(trim(t0.hospital_code),''), '') as PARTY_BK,
        null, null,
        'PROVIDER' as ROLE_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PROVIDER' as LNK_ROLE_PROVIDER__ROLE_TYPE_CK,
        t0.total_beds as LNK_ROLE_PROVIDER__BED_COUNT,
        t0.vendor_status as LNK_ROLE_PROVIDER__EMPANELMENT_STATUS,
        null,
        t0.type_of_provider as LNK_ROLE_PROVIDER__PROVIDER_TYPE,
        null,
        t0.suspended as LNK_ROLE_PROVIDER__SUSPENSION_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif('PROVIDER:' || nullif(trim(t0.hospital_code),''), '')) is not null

    union all

    -- branch 3: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW
    select
        null, null, null,
        nullif('EMPLOYEE:' || nullif(trim(t0.employee_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.employee_designation as PARTY_EMPLOYMENT__DESIGNATION,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.employee_type as PARTY_INDIVIDUAL_DEMOGRAPHICS__EMPLOYMENT_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif('EMPLOYEE:' || nullif(trim(t0.employee_code),''), '')) is not null

    union all

    -- branch 4: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW
    select
        null, null, null,
        nullif('PROVIDER:' || nullif(trim(t0.hospital_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.blacklisted as PARTY_FRAUD_PROFILE__NEGATIVE_LIST_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        t0.hospital_grade as PROVIDER_QUALITY__QUALITY_RATING,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif('PROVIDER:' || nullif(trim(t0.hospital_code),''), '')) is not null

    union all

    -- branch 5: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=ROHINI
    select
        null, null, null,
        nullif('PROVIDER:' || nullif(trim(t0.hospital_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ROHINI' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.rohini_id as PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif('PROVIDER:' || nullif(trim(t0.hospital_code),''), '')) is not null

    union all

    -- branch 6: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=PAN
    select
        null, null, null,
        nullif('DOCTOR:' || nullif(trim(t0.doctor_id),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PAN' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.treating_doctor_pan_card as PARTY_IDENTIFICATION__PAN_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif('DOCTOR:' || nullif(trim(t0.doctor_id),''), '')) is not null

    union all

    -- branch 7: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=VOTER_ID
    select
        null, null, null,
        nullif('MEMBER:' || coalesce( nullif(trim(t0.insured_member_code),'') , nullif(trim(t0.health_card_number),'') ), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'VOTER_ID' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.voter_id as PARTY_IDENTIFICATION__VOTER_ID_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif('MEMBER:' || coalesce( nullif(trim(t0.insured_member_code),'') , nullif(trim(t0.health_card_number),'') ), '')) is not null

    union all

    -- branch 8: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=AADHAAR
    select
        null, null, null,
        nullif('MEMBER:' || coalesce( nullif(trim(t0.insured_member_code),'') , nullif(trim(t0.health_card_number),'') ), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'AADHAAR' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        t0.aadhaar_no as PARTY_IDENTIFICATION__AADHAAR_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif('MEMBER:' || coalesce( nullif(trim(t0.insured_member_code),'') , nullif(trim(t0.health_card_number),'') ), '')) is not null

    union all

    -- branch 9: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=MEDICAL_COUNCIL_REGISTRATION
    select
        null, null, null,
        nullif('DOCTOR:' || nullif(trim(t0.doctor_id),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'MEDICAL_COUNCIL_REGISTRATION' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.doctor_registration_number as PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif('DOCTOR:' || nullif(trim(t0.doctor_id),''), '')) is not null

    union all

    -- branch 10: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=DRIVING_LICENCE
    select
        null, null, null,
        nullif('MEMBER:' || coalesce( nullif(trim(t0.insured_member_code),'') , nullif(trim(t0.health_card_number),'') ), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'DRIVING_LICENCE' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null,
        t0.driving_license_number as PARTY_IDENTIFICATION__DRIVING_LICENCE_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif('MEMBER:' || coalesce( nullif(trim(t0.insured_member_code),'') , nullif(trim(t0.health_card_number),'') ), '')) is not null

    union all

    -- branch 11: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=GSTIN
    select
        null, null, null,
        nullif('PROVIDER:' || nullif(trim(t0.hospital_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'GSTIN' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null,
        t0.gstinuin as PARTY_IDENTIFICATION__GSTIN,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif('PROVIDER:' || nullif(trim(t0.hospital_code),''), '')) is not null

    union all

    -- branch 12: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=NREGA_JOB_CARD
    select
        null, null, null,
        nullif('MEMBER:' || coalesce( nullif(trim(t0.insured_member_code),'') , nullif(trim(t0.health_card_number),'') ), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NREGA_JOB_CARD' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.nrega_job_card as PARTY_IDENTIFICATION__NREGA_CARD_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif('MEMBER:' || coalesce( nullif(trim(t0.insured_member_code),'') , nullif(trim(t0.health_card_number),'') ), '')) is not null

    union all

    -- branch 13: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=PAN
    select
        null, null, null,
        nullif('MEMBER:' || coalesce( nullif(trim(t0.insured_member_code),'') , nullif(trim(t0.health_card_number),'') ), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PAN' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.pan_number as PARTY_IDENTIFICATION__PAN_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif('MEMBER:' || coalesce( nullif(trim(t0.insured_member_code),'') , nullif(trim(t0.health_card_number),'') ), '')) is not null

    union all

    -- branch 14: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=PASSPORT
    select
        null, null, null,
        nullif('MEMBER:' || coalesce( nullif(trim(t0.insured_member_code),'') , nullif(trim(t0.health_card_number),'') ), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PASSPORT' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.passport_number as PARTY_IDENTIFICATION__PASSPORT_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif('MEMBER:' || coalesce( nullif(trim(t0.insured_member_code),'') , nullif(trim(t0.health_card_number),'') ), '')) is not null

    union all

    -- branch 15: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIMDETAIL_ATTRIBUTE_PIVOT_VW
    select
        null, null, null,
        nullif('DOCTOR:' || nullif(trim(t0.doctor_id),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.doctor_qualifications as PARTY_INDIVIDUAL_DEMOGRAPHICS__EDUCATIONAL_QUALIFICATION,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        0 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claimdetail_attr_pv') }} t0
    where (nullif('DOCTOR:' || nullif(trim(t0.doctor_id),''), '')) is not null

    union all

    -- branch 16: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_PARTYDETAILS_PIVOT_VW
    select
        nullif(md5(normalise(nullif(trim('CLAIM-PAYMENT|' || coalesce(nullif(trim(j2.claim_number),''),'') || '|' || coalesce(t0.account_number,'')), 'CLAIM-PAYMENT||'))), '') as FINANCIAL_TRANSACTION_BK,
        null, null,
        nullif(md5(normalise(nullif(trim(coalesce(t0.pan_number,'') || '|' || coalesce(t0.account_number,'') || '|' || coalesce(t0.mobile_no,'') || '|' || coalesce(t0.email_id,'')), '|||'))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null,
        t0.account_number as AUG_PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK,
        t0.bank_details1 as AUG_PARTY_BANKING__BANK_DETAIL_TEXT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.reimbursement_preferences as AUG_PARTY_PREFERENCE_PROFILE__PREFERRED_REIMBURSEMENT_METHOD,
        null, null, null, null, null,
        t0.irda_category as COMMON_CLASSIFICATION__CATEGORY_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.type_of_payment as FINTXN_CLAIM_PAYMENT__PAYMENT_MODE,
        t0.neft_status as FINTXN_CLAIM_PAYMENT__PAYMENT_STATUS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.account_number as PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK,
        null,
        t0.account_number as PARTY_BANKING__ACCOUNT_NUMBER_MASKED,
        t0.account_type as PARTY_BANKING__ACCOUNT_TYPE,
        null,
        t0.bank_name as PARTY_BANKING__BANK_NAME,
        t0.branch_name1 as PARTY_BANKING__BRANCH_NAME,
        t0.ifsc_code as PARTY_BANKING__IFSC_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.claim_kyc_compliance_done as PARTY_KYC__KYC_COMPLETED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claim_partydtls_pv') }} t0
    left join {{ ref('stg_mxh__clm_cd_claim_partydtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (coalesce(nullif(md5(normalise(nullif(trim('CLAIM-PAYMENT|' || coalesce(nullif(trim(j2.claim_number),''),'') || '|' || coalesce(t0.account_number,'')), 'CLAIM-PAYMENT||'))), ''), nullif(md5(normalise(nullif(trim(coalesce(t0.pan_number,'') || '|' || coalesce(t0.account_number,'') || '|' || coalesce(t0.mobile_no,'') || '|' || coalesce(t0.email_id,'')), '|||'))), ''))) is not null

    union all

    -- branch 17: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_PARTYDETAILS_PIVOT_VW | child-key literal(s): AUG_PARTY_CONTACT_ADDRESS_LINK.Address Usage Type=COMMUNICATION
    select
        null,
        nullif(md5(normalise(nullif(trim(coalesce(t0.address_line_1,'') || '|' || coalesce(t0.address_line_2,'') || '|' || coalesce(t0.address_line_3,'') || '|' || coalesce(t0.pincode1,'') || '|' || coalesce(t0.emiratesstatep,'')), '||||'))), '') as LOCATION_BK,
        null,
        nullif(md5(normalise(nullif(trim(coalesce(t0.pan_number,'') || '|' || coalesce(t0.account_number,'') || '|' || coalesce(t0.mobile_no,'') || '|' || coalesce(t0.email_id,'')), '|||'))), '') as PARTY_BK,
        null, null, null, null,
        1 as __LNK_PARTY_LOCATION,
        null, null, null, null, null, null, null, null,
        'COMMUNICATION' as AUG_PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE_CK,
        null,
        t0.address_same_as_policy_holder as AUG_PARTY_CONTACT_ADDRESS_LINK__SAME_AS_POLICYHOLDER_ADDRESS_INDICATOR,
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
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claim_partydtls_pv') }} t0
    where (coalesce(nullif(md5(normalise(nullif(trim(coalesce(t0.address_line_1,'') || '|' || coalesce(t0.address_line_2,'') || '|' || coalesce(t0.address_line_3,'') || '|' || coalesce(t0.pincode1,'') || '|' || coalesce(t0.emiratesstatep,'')), '||||'))), ''), nullif(md5(normalise(nullif(trim(coalesce(t0.pan_number,'') || '|' || coalesce(t0.account_number,'') || '|' || coalesce(t0.mobile_no,'') || '|' || coalesce(t0.email_id,'')), '|||'))), ''))) is not null

    union all

    -- branch 18: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_PARTYDETAILS_PIVOT_VW | child-key literal(s): FINTXN_TAX.Tax Type=SERVICE_TAX
    select
        nullif(md5(normalise(nullif(trim('CLAIM-PAYMENT|' || coalesce(nullif(trim(j2.claim_number),''),'') || '|' || coalesce(t0.account_number,'')), 'CLAIM-PAYMENT||'))), '') as FINANCIAL_TRANSACTION_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SERVICE_TAX' as FINTXN_TAX__TAX_TYPE_CK,
        null, null, null,
        t0.service_tax_applicable as FINTXN_TAX__SERVICE_TAX_APPLICABLE_INDICATOR,
        t0.service_tax_registration_number as FINTXN_TAX__SERVICE_TAX_REGISTRATION_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claim_partydtls_pv') }} t0
    left join {{ ref('stg_mxh__clm_cd_claim_partydtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(md5(normalise(nullif(trim('CLAIM-PAYMENT|' || coalesce(nullif(trim(j2.claim_number),''),'') || '|' || coalesce(t0.account_number,'')), 'CLAIM-PAYMENT||'))), '')) is not null

    union all

    -- branch 19: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_PARTYDETAILS_PIVOT_VW | child-key literal(s): FINTXN_TAX.Tax Type=TDS
    select
        nullif(md5(normalise(nullif(trim('CLAIM-PAYMENT|' || coalesce(nullif(trim(j2.claim_number),''),'') || '|' || coalesce(t0.account_number,'')), 'CLAIM-PAYMENT||'))), '') as FINANCIAL_TRANSACTION_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'TDS' as FINTXN_TAX__TAX_TYPE_CK,
        null, null, null, null, null, null, null,
        t0.tds_type as FINTXN_TAX__TDS_SECTION,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claim_partydtls_pv') }} t0
    left join {{ ref('stg_mxh__clm_cd_claim_partydtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(md5(normalise(nullif(trim('CLAIM-PAYMENT|' || coalesce(nullif(trim(j2.claim_number),''),'') || '|' || coalesce(t0.account_number,'')), 'CLAIM-PAYMENT||'))), '')) is not null

    union all

    -- branch 20: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_PARTYDETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=LICENCE
    select
        null, null, null,
        nullif(md5(normalise(nullif(trim(coalesce(t0.pan_number,'') || '|' || coalesce(t0.account_number,'') || '|' || coalesce(t0.mobile_no,'') || '|' || coalesce(t0.email_id,'')), '|||'))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'LICENCE' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.license_expiry_date as PARTY_IDENTIFICATION__IDENTIFICATION_EXPIRY_DATE,
        t0.license_registration_date as PARTY_IDENTIFICATION__IDENTIFICATION_ISSUE_DATE,
        null,
        t0.license_number as PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claim_partydtls_pv') }} t0
    where (nullif(md5(normalise(nullif(trim(coalesce(t0.pan_number,'') || '|' || coalesce(t0.account_number,'') || '|' || coalesce(t0.mobile_no,'') || '|' || coalesce(t0.email_id,'')), '|||'))), '')) is not null

    union all

    -- branch 21: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_PARTYDETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=PAN
    select
        null, null, null,
        nullif(md5(normalise(nullif(trim(coalesce(t0.pan_number,'') || '|' || coalesce(t0.account_number,'') || '|' || coalesce(t0.mobile_no,'') || '|' || coalesce(t0.email_id,'')), '|||'))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PAN' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.pan_number as PARTY_IDENTIFICATION__PAN_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        1 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claim_partydtls_pv') }} t0
    where (nullif(md5(normalise(nullif(trim(coalesce(t0.pan_number,'') || '|' || coalesce(t0.account_number,'') || '|' || coalesce(t0.mobile_no,'') || '|' || coalesce(t0.email_id,'')), '|||'))), '')) is not null

    union all

    -- branch 22: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_PAYMENT_CLAIM_PAYMENT_DETAIL_ATTRIBUTES_PIVOT_VW
    select
        nullif('CLMPAY:' || coalesce( nullif(trim(t0.reference_no),'') , nullif(trim(t0.utr_number),'') , nullif(trim(t0.ddcheque_reference),'') ), '') as FINANCIAL_TRANSACTION_BK,
        nullif(md5(normalise(nullif(trim(coalesce(t0.address_line_1,'') || '|' || coalesce(t0.address_line_2,'') || '|' || coalesce(t0.address_line_3,'') || '|' || coalesce(t0.pincode1,'') || '|' || coalesce(t0.emiratesstatep,'')), '||||'))), '') as LOCATION_BK,
        null,
        nullif(md5(normalise(nullif(trim(coalesce(t0.involving_party,'') || '|' || coalesce(t0.account_number,'')), '|'))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null,
        t0.payee_address as AUG_COMMON_ADDRESS__FULL_ADDRESS_TEXT,
        null,
        t0.account_number as AUG_PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK,
        t0.bank_details1 as AUG_PARTY_BANKING__BANK_DETAIL_TEXT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.reimbursement_preferences as AUG_PARTY_PREFERENCE_PROFILE__REIMBURSEMENT_PREFERENCE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.cheque_dd_release_date as FINTXN_CLAIM_PAYMENT__CHEQUE_DISPATCH_DATE,
        t0.payment_amount as FINTXN_CLAIM_PAYMENT__NET_PAID_AMOUNT,
        t0.payment_date1 as FINTXN_CLAIM_PAYMENT__PAYMENT_DATE,
        t0.type_of_payment as FINTXN_CLAIM_PAYMENT__PAYMENT_MODE,
        t0.status_code as FINTXN_CLAIM_PAYMENT__PAYMENT_STATUS,
        t0.payment_purpose as FINTXN_CLAIM_PAYMENT__PAYMENT_TYPE,
        t0.tds_1 as FINTXN_CLAIM_PAYMENT__TDS_ON_CLAIM_AMOUNT,
        t0.utr_number as FINTXN_CLAIM_PAYMENT__UTR_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.account_number as PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK,
        null,
        t0.account_number as PARTY_BANKING__ACCOUNT_NUMBER_MASKED,
        t0.account_type as PARTY_BANKING__ACCOUNT_TYPE,
        null,
        t0.bank_name as PARTY_BANKING__BANK_NAME,
        t0.branch_name1 as PARTY_BANKING__BRANCH_NAME,
        t0.ifsc_code as PARTY_BANKING__IFSC_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claim_payment_claim_payment_detail_attrs_pv') }} t0
    where (coalesce(nullif('CLMPAY:' || coalesce( nullif(trim(t0.reference_no),'') , nullif(trim(t0.utr_number),'') , nullif(trim(t0.ddcheque_reference),'') ), ''), nullif(md5(normalise(nullif(trim(coalesce(t0.address_line_1,'') || '|' || coalesce(t0.address_line_2,'') || '|' || coalesce(t0.address_line_3,'') || '|' || coalesce(t0.pincode1,'') || '|' || coalesce(t0.emiratesstatep,'')), '||||'))), ''), nullif(md5(normalise(nullif(trim(coalesce(t0.involving_party,'') || '|' || coalesce(t0.account_number,'')), '|'))), ''))) is not null

    union all

    -- branch 23: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_PAYMENT_CLAIM_PAYMENT_DETAIL_ATTRIBUTES_PIVOT_VW | child-key literal(s): FINTXN_TAX.Tax Type=GST
    select
        nullif('CLMPAY:' || coalesce( nullif(trim(t0.reference_no),'') , nullif(trim(t0.utr_number),'') , nullif(trim(t0.ddcheque_reference),'') ), '') as FINANCIAL_TRANSACTION_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'GST' as FINTXN_TAX__TAX_TYPE_CK,
        t0.gst_amount as FINTXN_TAX__COMPONENT_TAX_AMOUNT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claim_payment_claim_payment_detail_attrs_pv') }} t0
    where (nullif('CLMPAY:' || coalesce( nullif(trim(t0.reference_no),'') , nullif(trim(t0.utr_number),'') , nullif(trim(t0.ddcheque_reference),'') ), '')) is not null

    union all

    -- branch 24: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_CLAIM_PAYMENT_CLAIM_PAYMENT_DETAIL_ATTRIBUTES_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=PAN
    select
        null, null, null,
        nullif(md5(normalise(nullif(trim(coalesce(t0.involving_party,'') || '|' || coalesce(t0.account_number,'')), '|'))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PAN' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.pan_no as PARTY_IDENTIFICATION__PAN_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        2 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_claim_payment_claim_payment_detail_attrs_pv') }} t0
    where (nullif(md5(normalise(nullif(trim(coalesce(t0.involving_party,'') || '|' || coalesce(t0.account_number,'')), '|'))), '')) is not null

    union all

    -- branch 25: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_LIST_OF_COVERS_ENTITY_HEADS_ENTITY_GRID_ROWS_ROW_ATTRIBUTES_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=GSTIN
    select
        null, null, null,
        nullif('GSTIN:' || upper(nullif(trim(t0.gst_number),'')), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'GSTIN' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null,
        t0.gst_number as PARTY_IDENTIFICATION__GSTIN,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        3 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_list_of_covers_entity_heads_entity_grid_rows_d3003ace') }} t0
    where (nullif('GSTIN:' || upper(nullif(trim(t0.gst_number),'')), '')) is not null

    union all

    -- branch 26: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_PARTY
    select
        null, null, null,
        nullif(nullif(trim(t0.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.company as PARTY_EMPLOYMENT__EMPLOYER_NAME,
        null, null,
        t0.occupation as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_relations_party') }} t0
    where (nullif(nullif(trim(t0.party_code),''), '')) is not null

    union all

    -- branch 27: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_PARTY | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=CITIZENSHIP
    select
        null, null, null,
        nullif(nullif(trim(t0.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CITIZENSHIP' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.citizenship_id as PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        4 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_relations_party') }} t0
    where (nullif(nullif(trim(t0.party_code),''), '')) is not null

    union all

    -- branch 28: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_RELATION_ATTRIBUTE_PIVOT_VW
    select
        nullif(md5(normalise(nullif(trim('CLAIM-PAYMENT|' || coalesce(nullif(trim(j3.claim_number),''),'') || '|' || coalesce(t0.account_number,'')), 'CLAIM-PAYMENT||'))), '') as FINANCIAL_TRANSACTION_BK,
        null, null,
        nullif(nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null,
        t0.account_number as AUG_PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK,
        t0.bank_details1 as AUG_PARTY_BANKING__BANK_DETAIL_TEXT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.reimbursement_preferences as AUG_PARTY_PREFERENCE_PROFILE__PREFERRED_REIMBURSEMENT_METHOD,
        null, null, null, null, null,
        t0.irda_category as COMMON_CLASSIFICATION__CATEGORY_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.type_of_payment as FINTXN_CLAIM_PAYMENT__PAYMENT_MODE,
        t0.neft_status as FINTXN_CLAIM_PAYMENT__PAYMENT_STATUS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.account_number as PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK,
        null,
        t0.account_number as PARTY_BANKING__ACCOUNT_NUMBER_MASKED,
        t0.account_type as PARTY_BANKING__ACCOUNT_TYPE,
        null,
        t0.bank_name as PARTY_BANKING__BANK_NAME,
        t0.branch_name1 as PARTY_BANKING__BRANCH_NAME,
        t0.ifsc_code as PARTY_BANKING__IFSC_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.claim_kyc_compliance_done as PARTY_KYC__KYC_COMPLETED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_relations_relation_attr_pv') }} t0
    left join {{ ref('stg_mxh__clm_cd_relations_relation_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd_relations') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__clm_cd_relations_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    left join {{ ref('stg_mxh__clm_cd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (coalesce(nullif(md5(normalise(nullif(trim('CLAIM-PAYMENT|' || coalesce(nullif(trim(j3.claim_number),''),'') || '|' || coalesce(t0.account_number,'')), 'CLAIM-PAYMENT||'))), ''), nullif(nullif(trim((case when x1._N = 1 then x1._V end)),''), ''))) is not null

    union all

    -- branch 29: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_RELATION_ATTRIBUTE_PIVOT_VW | child-key literal(s): AUG_PARTY_CONTACT_ADDRESS_LINK.Address Usage Type=COMMUNICATION
    select
        null,
        nullif(md5(normalise(nullif(trim(coalesce(t0.address_line_1,'') || '|' || coalesce(t0.address_line_2,'') || '|' || coalesce(t0.address_line_3,'') || '|' || coalesce(t0.pincode1,'') || '|' || coalesce(t0.emiratesstatep,'')), '||||'))), '') as LOCATION_BK,
        null,
        nullif(nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as PARTY_BK,
        null, null, null, null,
        1 as __LNK_PARTY_LOCATION,
        null, null, null, null, null, null, null, null,
        'COMMUNICATION' as AUG_PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE_CK,
        null,
        t0.address_same_as_policy_holder as AUG_PARTY_CONTACT_ADDRESS_LINK__SAME_AS_POLICYHOLDER_ADDRESS_INDICATOR,
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
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_relations_relation_attr_pv') }} t0
    left join {{ ref('stg_mxh__clm_cd_relations_relation_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd_relations') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__clm_cd_relations_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (coalesce(nullif(md5(normalise(nullif(trim(coalesce(t0.address_line_1,'') || '|' || coalesce(t0.address_line_2,'') || '|' || coalesce(t0.address_line_3,'') || '|' || coalesce(t0.pincode1,'') || '|' || coalesce(t0.emiratesstatep,'')), '||||'))), ''), nullif(nullif(trim((case when x1._N = 1 then x1._V end)),''), ''))) is not null

    union all

    -- branch 30: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_RELATION_ATTRIBUTE_PIVOT_VW | child-key literal(s): FINTXN_TAX.Tax Type=SERVICE_TAX
    select
        nullif(md5(normalise(nullif(trim('CLAIM-PAYMENT|' || coalesce(nullif(trim(j3.claim_number),''),'') || '|' || coalesce(t0.account_number,'')), 'CLAIM-PAYMENT||'))), '') as FINANCIAL_TRANSACTION_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SERVICE_TAX' as FINTXN_TAX__TAX_TYPE_CK,
        null, null, null,
        t0.service_tax_applicable as FINTXN_TAX__SERVICE_TAX_APPLICABLE_INDICATOR,
        t0.service_tax_registration_number as FINTXN_TAX__SERVICE_TAX_REGISTRATION_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_relations_relation_attr_pv') }} t0
    left join {{ ref('stg_mxh__clm_cd_relations_relation_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd_relations') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(md5(normalise(nullif(trim('CLAIM-PAYMENT|' || coalesce(nullif(trim(j3.claim_number),''),'') || '|' || coalesce(t0.account_number,'')), 'CLAIM-PAYMENT||'))), '')) is not null

    union all

    -- branch 31: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_RELATION_ATTRIBUTE_PIVOT_VW | child-key literal(s): FINTXN_TAX.Tax Type=TDS
    select
        nullif(md5(normalise(nullif(trim('CLAIM-PAYMENT|' || coalesce(nullif(trim(j3.claim_number),''),'') || '|' || coalesce(t0.account_number,'')), 'CLAIM-PAYMENT||'))), '') as FINANCIAL_TRANSACTION_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'TDS' as FINTXN_TAX__TAX_TYPE_CK,
        null, null, null, null, null, null, null,
        t0.tds_type as FINTXN_TAX__TDS_SECTION,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_relations_relation_attr_pv') }} t0
    left join {{ ref('stg_mxh__clm_cd_relations_relation_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd_relations') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd') }} j3 on j3.KEY_HASH = j2.PARENT_KEY_HASH
    where (nullif(md5(normalise(nullif(trim('CLAIM-PAYMENT|' || coalesce(nullif(trim(j3.claim_number),''),'') || '|' || coalesce(t0.account_number,'')), 'CLAIM-PAYMENT||'))), '')) is not null

    union all

    -- branch 32: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_RELATION_ATTRIBUTE_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=LICENCE
    select
        null, null, null,
        nullif(nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'LICENCE' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.license_expiry_date as PARTY_IDENTIFICATION__IDENTIFICATION_EXPIRY_DATE,
        t0.license_registration_date as PARTY_IDENTIFICATION__IDENTIFICATION_ISSUE_DATE,
        null,
        t0.license_number as PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_relations_relation_attr_pv') }} t0
    left join {{ ref('stg_mxh__clm_cd_relations_relation_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd_relations') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__clm_cd_relations_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (nullif(nullif(trim((case when x1._N = 1 then x1._V end)),''), '')) is not null

    union all

    -- branch 33: MAXI_HLTH_CLM_VW_DATA_CLAIM_DETAIL_RELATIONS_RELATION_ATTRIBUTE_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=PAN
    select
        null, null, null,
        nullif(nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PAN' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.pan_number as PARTY_IDENTIFICATION__PAN_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        5 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__clm_cd_relations_relation_attr_pv') }} t0
    left join {{ ref('stg_mxh__clm_cd_relations_relation_attr') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__clm_cd_relations') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__clm_cd_relations_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (nullif(nullif(trim((case when x1._N = 1 then x1._V end)),''), '')) is not null

    union all

    -- branch 34: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW
    select
        null,
        nullif(md5(normalise(nullif(trim(coalesce(t0.policyholder_door,'') || '#' || coalesce(t0.policyholder_floor,'') || '#' || coalesce(t0.policyholder_stair,'') || '#' || coalesce(t0.policyholder_road,'') || '#' || coalesce(t0.policyholder_additional_space_for_road,'') || '#' || coalesce(t0.policyholder_city,'') || '#' || coalesce(t0.policyholder_province,'') || '#' || coalesce(t0.policyholder_zip_code,'') || '#' || coalesce(t0.policyholder_country,'')), '########'))), '') as LOCATION_BK,
        null,
        nullif(t0.proposer_code, '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.category as COMMON_CLASSIFICATION__CATEGORY_CODE,
        null, null, null, null, null,
        t0.go_green as COMMON_COMMUNICATION_PREFERENCE__GO_GREEN_OPT_IN_INDICATOR,
        null, null, null, null,
        t0.rural_nonrural as COMMON_GEO__URBAN_RURAL_CLASSIFICATION,
        t0.zone as COMMON_GEO__ZONE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        t0.account_number as PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK,
        t0.name_of_account_holder as PARTY_BANKING__ACCOUNT_HOLDER_NAME,
        t0.account_number as PARTY_BANKING__ACCOUNT_NUMBER_MASKED,
        t0.account_type as PARTY_BANKING__ACCOUNT_TYPE,
        t0.bank_code as PARTY_BANKING__BANK_CODE,
        t0.bank_name as PARTY_BANKING__BANK_NAME,
        t0.branch_name_out as PARTY_BANKING__BRANCH_NAME,
        t0.ifsc as PARTY_BANKING__IFSC_CODE,
        t0.micr as PARTY_BANKING__MICR_CODE,
        null, null, null, null,
        t0.insured_occupation_details as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        null, null, null, null, null,
        t0.mediusalcohol_per_week as PARTY_HEALTH_PROFILE__ALCOHOL_UNITS_PER_WEEK,
        null, null,
        t0.mediusmedications as PARTY_HEALTH_PROFILE__CURRENT_MEDICATION_DETAIL,
        null, null, null, null, null,
        t0.ped_details as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        null, null, null,
        t0.id_type as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.id_number as PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER,
        t0.id_type as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE,
        null, null, null, null, null, null, null, null,
        t0.family_monthly_income as PARTY_INDIVIDUAL_DEMOGRAPHICS__ANNUAL_HOUSEHOLD_INCOME,
        t0.educational_qualification as PARTY_INDIVIDUAL_DEMOGRAPHICS__EDUCATIONAL_QUALIFICATION,
        null, null, null,
        t0.marital_status as PARTY_INDIVIDUAL_DEMOGRAPHICS__MARITAL_STATUS,
        null, null, null,
        t0.ckyc_number as PARTY_KYC__CKYC_NUMBER,
        t0.ckyc_status as PARTY_KYC__CKYC_REGISTRATION_STATUS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.industry_type as PARTY_ORGANISATION_PROFILE__INDUSTRY_DESCRIPTION,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (coalesce(nullif(md5(normalise(nullif(trim(coalesce(t0.policyholder_door,'') || '#' || coalesce(t0.policyholder_floor,'') || '#' || coalesce(t0.policyholder_stair,'') || '#' || coalesce(t0.policyholder_road,'') || '#' || coalesce(t0.policyholder_additional_space_for_road,'') || '#' || coalesce(t0.policyholder_city,'') || '#' || coalesce(t0.policyholder_province,'') || '#' || coalesce(t0.policyholder_zip_code,'') || '#' || coalesce(t0.policyholder_country,'')), '########'))), ''), nullif(t0.proposer_code, ''))) is not null

    union all

    -- branch 35: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): LNK_ROLE_AGENT.Role Type=AGENT
    select
        null, null, null,
        nullif('SPECIFIED_PERSON:' || nullif(trim(t0.specified_person_code),''), '') as PARTY_BK,
        null, null,
        'AGENT' as ROLE_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'AGENT' as LNK_ROLE_AGENT__ROLE_TYPE_CK,
        null,
        t0.specified_person_code as LNK_ROLE_AGENT__AGENT_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif('SPECIFIED_PERSON:' || nullif(trim(t0.specified_person_code),''), '')) is not null

    union all

    -- branch 36: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): LNK_ROLE_AGENT.Role Type=AGENT
    select
        null, null, null,
        nullif('POSP:' || nullif(trim(t0.sp_posp_code),''), '') as PARTY_BK,
        null, null,
        'AGENT' as ROLE_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'AGENT' as LNK_ROLE_AGENT__ROLE_TYPE_CK,
        t0.spposp_user_type as LNK_ROLE_AGENT__AGENCY_TYPE,
        null, null, null, null, null, null,
        t0.spposp_flag as LNK_ROLE_AGENT__POSP_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif('POSP:' || nullif(trim(t0.sp_posp_code),''), '')) is not null

    union all

    -- branch 37: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): LNK_ROLE_CUSTOMER.Role Type=CUSTOMER
    select
        null, null, null,
        nullif(coalesce( nullif(trim(t0.policyholder_code),'') , nullif(trim(t0.policyholder_codenew),'') ), '') as PARTY_BK,
        null, null,
        'CUSTOMER' as ROLE_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        'CUSTOMER' as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        null,
        t0.client_type as LNK_ROLE_CUSTOMER__CUSTOMER_CATEGORY,
        t0.customer_segment as LNK_ROLE_CUSTOMER__CUSTOMER_SEGMENT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif(coalesce( nullif(trim(t0.policyholder_code),'') , nullif(trim(t0.policyholder_codenew),'') ), '')) is not null

    union all

    -- branch 38: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): LNK_ROLE_CUSTOMER.Role Type=CUSTOMER
    select
        null, null, null,
        nullif(nullif(trim(t0.policyholder_code),''), '') as PARTY_BK,
        null, null,
        'CUSTOMER' as ROLE_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        'CUSTOMER' as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        null, null, null, null,
        t0.hni_flag as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif(nullif(trim(t0.policyholder_code),''), '')) is not null

    union all

    -- branch 39: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): LNK_ROLE_EMPLOYEE.Role Type=EMPLOYEE
    select
        null, null, null,
        nullif('EMP:' || nullif(trim(t0.agreemnetmanager_code),''), '') as PARTY_BK,
        null, null,
        'EMPLOYEE' as ROLE_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EMPLOYEE' as LNK_ROLE_EMPLOYEE__ROLE_TYPE_CK,
        null, null, null,
        t0.agreemnetmanager_code as LNK_ROLE_EMPLOYEE__EMPLOYEE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif('EMP:' || nullif(trim(t0.agreemnetmanager_code),''), '')) is not null

    union all

    -- branch 40: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): LNK_ROLE_EMPLOYEE.Role Type=EMPLOYEE
    select
        null, null, null,
        nullif('EMP:' || nullif(trim(t0.alternate_person_responsible_other_than_requestor_emp_code),''), '') as PARTY_BK,
        null, null,
        'EMPLOYEE' as ROLE_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EMPLOYEE' as LNK_ROLE_EMPLOYEE__ROLE_TYPE_CK,
        null, null, null,
        t0.alternate_person_responsible_other_than_requestor_emp_code as LNK_ROLE_EMPLOYEE__EMPLOYEE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif('EMP:' || nullif(trim(t0.alternate_person_responsible_other_than_requestor_emp_code),''), '')) is not null

    union all

    -- branch 41: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): LNK_ROLE_EMPLOYEE.Role Type=EMPLOYEE
    select
        null, null, null,
        nullif('EMP:' || nullif(trim(t0.bagic_rm_e_code),''), '') as PARTY_BK,
        null, null,
        'EMPLOYEE' as ROLE_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EMPLOYEE' as LNK_ROLE_EMPLOYEE__ROLE_TYPE_CK,
        null, null, null,
        t0.bagic_rm_e_code as LNK_ROLE_EMPLOYEE__EMPLOYEE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif('EMP:' || nullif(trim(t0.bagic_rm_e_code),''), '')) is not null

    union all

    -- branch 42: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): LNK_ROLE_EMPLOYEE.Role Type=EMPLOYEE
    select
        null, null, null,
        nullif('EMP:' || nullif(trim(t0.bank_emp_code),''), '') as PARTY_BK,
        null, null,
        'EMPLOYEE' as ROLE_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EMPLOYEE' as LNK_ROLE_EMPLOYEE__ROLE_TYPE_CK,
        null, null, null,
        t0.bank_emp_code as LNK_ROLE_EMPLOYEE__EMPLOYEE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif('EMP:' || nullif(trim(t0.bank_emp_code),''), '')) is not null

    union all

    -- branch 43: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): LNK_ROLE_EMPLOYEE.Role Type=EMPLOYEE
    select
        null, null, null,
        nullif('EMP:' || nullif(trim(t0.cbm_code),''), '') as PARTY_BK,
        null, null,
        'EMPLOYEE' as ROLE_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EMPLOYEE' as LNK_ROLE_EMPLOYEE__ROLE_TYPE_CK,
        null, null, null,
        t0.cbm_code as LNK_ROLE_EMPLOYEE__EMPLOYEE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif('EMP:' || nullif(trim(t0.cbm_code),''), '')) is not null

    union all

    -- branch 44: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): LNK_ROLE_EMPLOYEE.Role Type=EMPLOYEE
    select
        null, null, null,
        nullif('EMP:' || nullif(trim(t0.employee_code),''), '') as PARTY_BK,
        null, null,
        'EMPLOYEE' as ROLE_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EMPLOYEE' as LNK_ROLE_EMPLOYEE__ROLE_TYPE_CK,
        null, null, null,
        t0.employee_code as LNK_ROLE_EMPLOYEE__EMPLOYEE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif('EMP:' || nullif(trim(t0.employee_code),''), '')) is not null

    union all

    -- branch 45: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW
    select
        null, null, null,
        nullif(t0.proposer_code, '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.account_number1 as PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK,
        null,
        t0.account_number1 as PARTY_BANKING__ACCOUNT_NUMBER_MASKED,
        null,
        t0.bank_code1 as PARTY_BANKING__BANK_CODE,
        null, null,
        t0.ifsc1 as PARTY_BANKING__IFSC_CODE,
        t0.micr1 as PARTY_BANKING__MICR_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif(t0.proposer_code, '')) is not null

    union all

    -- branch 46: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW
    select
        null, null, null,
        nullif(t0.proposer_code, '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.account_number2 as PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK,
        null,
        t0.account_number2 as PARTY_BANKING__ACCOUNT_NUMBER_MASKED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif(t0.proposer_code, '')) is not null

    union all

    -- branch 47: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=AADHAAR
    select
        null, null, null,
        nullif(t0.proposer_code, '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'AADHAAR' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        t0.aadhaar_number as PARTY_IDENTIFICATION__AADHAAR_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif(t0.proposer_code, '')) is not null

    union all

    -- branch 48: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=ABHA
    select
        null, null, null,
        nullif(t0.proposer_code, '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ABHA' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.abha_id as PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif(t0.proposer_code, '')) is not null

    union all

    -- branch 49: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=BANK_CUSTOMER_ID
    select
        null, null, null,
        nullif(t0.proposer_code, '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'BANK_CUSTOMER_ID' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.bank_customer_id as PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif(t0.proposer_code, '')) is not null

    union all

    -- branch 50: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=BANK_REFERENCE_NUMBER_2
    select
        null, null, null,
        nullif(t0.proposer_code, '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'BANK_REFERENCE_NUMBER_2' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.bank_reference_number_2 as PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif(t0.proposer_code, '')) is not null

    union all

    -- branch 51: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=DRIVING_LICENCE
    select
        null, null, null,
        nullif(t0.proposer_code, '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'DRIVING_LICENCE' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null,
        t0.driving_license_number as PARTY_IDENTIFICATION__DRIVING_LICENCE_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif(t0.proposer_code, '')) is not null

    union all

    -- branch 52: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=GSTIN
    select
        null, null, null,
        nullif(t0.proposer_code, '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'GSTIN' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null,
        t0.gstinuin as PARTY_IDENTIFICATION__GSTIN,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif(t0.proposer_code, '')) is not null

    union all

    -- branch 53: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=PAN
    select
        null, null, null,
        nullif(t0.proposer_code, '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PAN' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.pan_number as PARTY_IDENTIFICATION__PAN_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif(t0.proposer_code, '')) is not null

    union all

    -- branch 54: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=PARTNER_ID
    select
        null, null, null,
        nullif(t0.proposer_code, '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PARTNER_ID' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.partner_cust_id as PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif(t0.proposer_code, '')) is not null

    union all

    -- branch 55: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=PARTNER_ID_2
    select
        null, null, null,
        nullif(t0.proposer_code, '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PARTNER_ID_2' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.partner_cust_id1 as PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif(t0.proposer_code, '')) is not null

    union all

    -- branch 56: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=POLICYHOLDER_NUMBER
    select
        null, null, null,
        nullif(nullif(trim(t0.policyholder_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'POLICYHOLDER_NUMBER' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.policyholder_number as PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif(nullif(trim(t0.policyholder_code),''), '')) is not null

    union all

    -- branch 57: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=VOTER_ID
    select
        null, null, null,
        nullif(t0.proposer_code, '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'VOTER_ID' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.voter_id as PARTY_IDENTIFICATION__VOTER_ID_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif(t0.proposer_code, '')) is not null

    union all

    -- branch 58: MAXI_HLTH_UWR_VW_DATA_BASIC_DETAIL_ATTRIBUTE_PIVOT_VW
    select
        null, null, null,
        nullif(nullif(trim(t0.policyholder_code),''), '') as PARTY_BK,
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
        t0.policyholder_marital_status as PARTY_INDIVIDUAL_DEMOGRAPHICS__MARITAL_STATUS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.registration_number as PARTY_ORGANISATION_PROFILE__BUSINESS_REGISTRATION_NUMBER,
        null, null, null, null,
        t0.type_of_entity as PARTY_ORGANISATION_PROFILE__LEGAL_CONSTITUTION_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        6 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_basic_detail_attr_pv') }} t0
    where (nullif(nullif(trim(t0.policyholder_code),''), '')) is not null

    union all

    -- branch 59: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW
    select
        null, null, null,
        nullif(nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.hni_flag as COMMON_CLASSIFICATION__VALUE_BAND,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.company as PARTY_EMPLOYMENT__EMPLOYER_NAME,
        t0.earning_type as PARTY_EMPLOYMENT__EMPLOYMENT_STATUS,
        null,
        coalesce(t0.insured_occupation_details, t0.occupation) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        null, null, null, null, null,
        t0.mediusalcohol_per_week as PARTY_HEALTH_PROFILE__ALCOHOL_UNITS_PER_WEEK,
        t0.bmi as PARTY_HEALTH_PROFILE__BODY_MASS_INDEX,
        t0.mediussmoking_status_per_day as PARTY_HEALTH_PROFILE__CIGARETTES_PER_DAY,
        t0.mediusmedications as PARTY_HEALTH_PROFILE__CURRENT_MEDICATION_DETAIL,
        null, null,
        t0.mediusfamily_history as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
        t0.height_of_the_insured_in_cms as PARTY_HEALTH_PROFILE__HEIGHT,
        null,
        t0.mediusexisting_illness as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        t0.mediuspan_masala as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
        t0.weight_in_kgs as PARTY_HEALTH_PROFILE__WEIGHT,
        null,
        t0.id_type as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.id_number as PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER,
        t0.id_type as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE,
        null, null, null, null, null, null, null, null, null,
        t0.educational_qualification as PARTY_INDIVIDUAL_DEMOGRAPHICS__EDUCATIONAL_QUALIFICATION,
        null, null, null,
        t0.marital_status as PARTY_INDIVIDUAL_DEMOGRAPHICS__MARITAL_STATUS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (nullif(nullif(trim((case when x1._N = 1 then x1._V end)),''), '')) is not null

    union all

    -- branch 60: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=AADHAAR
    select
        null, null, null,
        nullif(nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'AADHAAR' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        coalesce(t0.aadhaar_number, t0.uid) as PARTY_IDENTIFICATION__AADHAAR_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (nullif(nullif(trim((case when x1._N = 1 then x1._V end)),''), '')) is not null

    union all

    -- branch 61: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=ABHA
    select
        null, null, null,
        nullif(nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ABHA' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.abha_id as PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (nullif(nullif(trim((case when x1._N = 1 then x1._V end)),''), '')) is not null

    union all

    -- branch 62: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=DRIVING_LICENCE
    select
        null, null, null,
        nullif(nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'DRIVING_LICENCE' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null,
        t0.driving_license_number as PARTY_IDENTIFICATION__DRIVING_LICENCE_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (nullif(nullif(trim((case when x1._N = 1 then x1._V end)),''), '')) is not null

    union all

    -- branch 63: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=MEDIUS_MEMBER_ID
    select
        null, null, null,
        nullif(nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'MEDIUS_MEMBER_ID' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.mediusmember_id as PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (nullif(nullif(trim((case when x1._N = 1 then x1._V end)),''), '')) is not null

    union all

    -- branch 64: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=PAN
    select
        null, null, null,
        nullif(nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PAN' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.pan_number as PARTY_IDENTIFICATION__PAN_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (nullif(nullif(trim((case when x1._N = 1 then x1._V end)),''), '')) is not null

    union all

    -- branch 65: MAXI_HLTH_UWR_VW_DATA_MEMBERS_MEMBER_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=PASSPORT
    select
        null, null, null,
        nullif(nullif(trim((case when x1._N = 1 then x1._V end)),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PASSPORT' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.passport_number as PARTY_IDENTIFICATION__PASSPORT_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        7 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_memd_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_memd') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    left join (
            select d0.PARENT_KEY_HASH as _K, max(d0.party_code) as _V, count(distinct d0.party_code) as _N
            from {{ ref('stg_mxh__uwr_members_party') }} d0
            group by d0.PARENT_KEY_HASH
        ) x1 on x1._K = j2.KEY_HASH
    where (nullif(nullif(trim((case when x1._N = 1 then x1._V end)),''), '')) is not null

    union all

    -- branch 66: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY
    select
        null, null, null,
        nullif(nullif(trim(t0.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.company as PARTY_EMPLOYMENT__EMPLOYER_NAME,
        null, null,
        t0.occupation as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party') }} t0
    where (nullif(nullif(trim(t0.party_code),''), '')) is not null

    union all

    -- branch 67: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=CITIZENSHIP
    select
        null, null, null,
        nullif(nullif(trim(t0.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CITIZENSHIP' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.citizenship_id as PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        8 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party') }} t0
    where (nullif(nullif(trim(t0.party_code),''), '')) is not null

    union all

    -- branch 68: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW
    select
        null,
        nullif(md5(normalise(nullif(trim(coalesce(t0.client_geography,'')), ''))), '') as LOCATION_BK,
        nullif(nullif(trim(t0.branch),''), '') as ORG_UNIT_BK,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        nullif(t0.product_code, '') as PRODUCT_BK,
        nullif(t0.calculator_urn_number, '') as QUOTE_BK,
        null, null, null,
        1 as __LNK_PARTY_ORG_UNIT,
        1 as __LNK_QUOTE_PARTY,
        1 as __LNK_QUOTE_PRODUCT,
        null,
        t0.preferred_mode_of_alert as AUG_COMMON_COMMUNICATION_PREFERENCE__PREFERRED_ALERT_CHANNEL,
        null, null,
        t0.emandate_details as AUG_PARTY_CONSENT_MANDATE__MANDATE_DETAIL_DESCRIPTION,
        null, null, null, null, null, null, null,
        t0.employers_details as AUG_PARTY_EMPLOYMENT__EMPLOYER_DETAIL_DESCRIPTION,
        t0.other_occupation as AUG_PARTY_EMPLOYMENT__OTHER_OCCUPATION,
        null,
        t0.years_of_experience as AUG_PARTY_EMPLOYMENT__TOTAL_YEARS_OF_EXPERIENCE,
        null, null,
        t0.nondisclosure_initiated as AUG_PARTY_FRAUD_PROFILE__NON_DISCLOSURE_ACTION_INITIATED_INDICATOR,
        null, null,
        t0.gh_type_of_user as AUG_PARTY_GROUP_SCHEME__GROUP_HEALTH_USER_TYPE,
        t0.ra_ecode as AUG_PARTY_HIERARCHY__RELATIONSHIP_ASSOCIATE_EMPLOYEE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.mrg_anniversarylawyer as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__MARRIAGE_ANNIVERSARY_DATE,
        t0.matriculat as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__MATRICULATION_QUALIFICATION_INDICATOR,
        t0.mother_maiden_name as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__MOTHER_MAIDEN_NAME,
        t0.number_of_daughters as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__NUMBER_OF_DAUGHTERS,
        t0.number_of_son as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__NUMBER_OF_SONS,
        t0.other_relationship as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__OTHER_RELATIONSHIP_DESCRIPTION,
        t0.personal_details as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__PERSONAL_DETAILS_DESCRIPTION,
        t0.postgrad as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__POSTGRADUATE_QUALIFICATION,
        t0.profquali as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__PROFESSIONAL_QUALIFICATION,
        null, null,
        t0.relationship as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__RELATIONSHIP_TO_PRIMARY_INSURED,
        t0.undergrad as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__UNDERGRADUATE_QUALIFICATION,
        t0.year_of_passing as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__YEAR_OF_PASSING_QUALIFICATION,
        null,
        t0.kyc_details as AUG_PARTY_KYC__KYC_DETAIL_DESCRIPTION,
        t0.pop_optional as AUG_PARTY_KYC__OPTIONAL_PROOF_OF_POSSESSION_TYPE,
        t0.pop_primary as AUG_PARTY_KYC__PRIMARY_PROOF_OF_POSSESSION_TYPE,
        t0.no_of_consumer_cases_handled_if_any as AUG_PARTY_LEGAL_PANEL__CONSUMER_CASES_HANDLED_COUNT,
        null,
        t0.no_of_companies_empanelled_with as AUG_PARTY_LEGAL_PANEL__EMPANELLED_COMPANIES_COUNT,
        t0.firms_name as AUG_PARTY_LEGAL_PANEL__FIRM_NAME,
        t0.whether_practicing_with_hc as AUG_PARTY_LEGAL_PANEL__HIGH_COURT_PRACTICE_INDICATOR,
        t0.no_of_mactlawyer as AUG_PARTY_LEGAL_PANEL__MACT_CASES_HANDLED_COUNT,
        t0.no_of_mact_case_handled_other_company as AUG_PARTY_LEGAL_PANEL__MACT_CASES_HANDLED_OTHER_COMPANY_COUNT,
        null, null,
        t0.no_of_wc_cases_handled_if_any as AUG_PARTY_LEGAL_PANEL__WC_CASES_HANDLED_COUNT,
        t0.rejected_reason as AUG_PARTY_ONBOARDING_JOURNEY__APPLICATION_REJECTION_REASON,
        null, null, null, null, null, null, null, null, null, null,
        t0.infrastructure_subsector as AUG_PARTY_ORGANISATION_PROFILE__INFRASTRUCTURE_SUB_SECTOR,
        null,
        t0.is_the_organisation_a_registered_business_trust as AUG_PARTY_ORGANISATION_PROFILE__REGISTERED_BUSINESS_TRUST_INDICATOR,
        null, null, null,
        t0.trade_name as AUG_PARTY_ORGANISATION_PROFILE__TRADE_NAME,
        null, null,
        t0.payment_mode as AUG_PARTY_PAYOUT_PROFILE__PAYMENT_MODE,
        null,
        t0.tds_code as AUG_PARTY_PAYOUT_PROFILE__TDS_CODE,
        t0.tds_code_desc as AUG_PARTY_PAYOUT_PROFILE__TDS_CODE_DESCRIPTION,
        null,
        t0.tds_details as AUG_PARTY_PAYOUT_PROFILE__TDS_DETAILS_DESCRIPTION,
        t0.issue_all_policies_in_electronic_format as AUG_PARTY_PREFERENCE_PROFILE__ELECTRONIC_POLICY_ISSUANCE_PREFERENCE_INDICATOR,
        null,
        t0.update_contact_details_in_all_policies as AUG_PARTY_PREFERENCE_PROFILE__PROPAGATE_CONTACT_UPDATE_TO_ALL_POLICIES_INDICATOR,
        null,
        t0.relationship_with_employee as AUG_PARTY_RELATIONSHIP_PROFILE__RELATIONSHIP_WITH_EMPLOYEE,
        t0.relationship_with_hni as AUG_PARTY_RELATIONSHIP_PROFILE__RELATIONSHIP_WITH_HNI_CUSTOMER,
        t0.relationship_with_prive as AUG_PARTY_RELATIONSHIP_PROFILE__RELATIONSHIP_WITH_PRIVE_CUSTOMER,
        t0.category as COMMON_CLASSIFICATION__CATEGORY_CODE,
        null,
        t0.profile as COMMON_CLASSIFICATION__SEGMENT_NAME,
        null,
        t0.hni_flag as COMMON_CLASSIFICATION__VALUE_BAND,
        t0.party_language as COMMON_COMMUNICATION_PREFERENCE__CORRESPONDENCE_LANGUAGE,
        t0.epolicy_required as COMMON_COMMUNICATION_PREFERENCE__GO_GREEN_OPT_IN_INDICATOR,
        t0.preferred_mode_of_communication as COMMON_COMMUNICATION_PREFERENCE__PREFERRED_CHANNEL_CODE,
        t0.languages_preferred as COMMON_COMMUNICATION_PREFERENCE__PREFERRED_LANGUAGE_CODE,
        t0.customer_consent as COMMON_CONSENT__CONSENT_GIVEN_INDICATOR,
        t0.client_geography as COMMON_GEO__REGION_NAME,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        t0.aml_verification_status as PARTY_AML_SCREENING__SCREENING_STATUS,
        null, null, null, null, null, null, null, null, null, null,
        t0.employer_name as PARTY_EMPLOYMENT__EMPLOYER_NAME,
        null, null,
        t0.occupation as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        null,
        t0.insured_occupation_details as PARTY_EMPLOYMENT__WORK_NATURE,
        t0.blacklisted as PARTY_FRAUD_PROFILE__NEGATIVE_LIST_INDICATOR,
        t0.reason_for_blacklisting as PARTY_FRAUD_PROFILE__NEGATIVE_LIST_REASON,
        t0.date_of_blacklisting as PARTY_FRAUD_PROFILE__WATCH_START_DATE,
        null, null, null,
        t0.medicine_name as PARTY_HEALTH_PROFILE__CURRENT_MEDICATION_DETAIL,
        t0.physically_challenged as PARTY_HEALTH_PROFILE__DISABILITY_INDICATOR,
        t0.disability_percentage as PARTY_HEALTH_PROFILE__DISABILITY_PERCENTAGE,
        null,
        t0.height as PARTY_HEALTH_PROFILE__HEIGHT,
        null,
        t0.disease_name as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        null,
        t0.weight as PARTY_HEALTH_PROFILE__WEIGHT,
        t0.level as PARTY_HIERARCHY__HIERARCHY_LEVEL,
        t0.identification_proof as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.identification_proof_effective_date as PARTY_IDENTIFICATION__IDENTIFICATION_ISSUE_DATE,
        null, null,
        t0.identification_proof as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE,
        null, null, null, null, null, null, null, null, null,
        t0.educational_qualification as PARTY_INDIVIDUAL_DEMOGRAPHICS__EDUCATIONAL_QUALIFICATION,
        null,
        t0.father_name as PARTY_INDIVIDUAL_DEMOGRAPHICS__FATHER_NAME,
        null,
        t0.marital_status as PARTY_INDIVIDUAL_DEMOGRAPHICS__MARITAL_STATUS,
        t0.spouse_name as PARTY_INDIVIDUAL_DEMOGRAPHICS__SPOUSE_NAME,
        null, null,
        t0.ckyc_number as PARTY_KYC__CKYC_NUMBER,
        t0.ckyc_status as PARTY_KYC__CKYC_REGISTRATION_STATUS,
        null, null,
        t0.type_of_lawyer as PARTY_LEGAL_PANEL__ADVOCATE_TYPE,
        null,
        t0.enrolled_with_name_of_state_bar_association as PARTY_LEGAL_PANEL__BAR_COUNCIL_NAME,
        t0.enrollment_id as PARTY_LEGAL_PANEL__BAR_ENROLMENT_NUMBER,
        t0.no_of_briefs as PARTY_LEGAL_PANEL__CASES_HANDLED_COUNT,
        t0.date_of_joininglawyer as PARTY_LEGAL_PANEL__EMPANELMENT_DATE,
        t0.no_of_juniors as PARTY_LEGAL_PANEL__JUNIORS_COUNT,
        null,
        t0.yr_experiencelawyer as PARTY_LEGAL_PANEL__YEARS_OF_PRACTICE,
        t0.annual_turnover as PARTY_ORGANISATION_PROFILE__ANNUAL_TURNOVER,
        t0.company_no as PARTY_ORGANISATION_PROFILE__BUSINESS_REGISTRATION_NUMBER,
        t0.date_of_registration as PARTY_ORGANISATION_PROFILE__DATE_OF_INCORPORATION,
        t0.global_co_name as PARTY_ORGANISATION_PROFILE__GROUP_NAME,
        t0.industry_code as PARTY_ORGANISATION_PROFILE__INDUSTRY_CODE,
        null,
        t0.constitution_of_business as PARTY_ORGANISATION_PROFILE__LEGAL_CONSTITUTION_TYPE,
        t0.msme_classification as PARTY_ORGANISATION_PROFILE__MSME_CATEGORY,
        t0.msme_applicable as PARTY_ORGANISATION_PROFILE__MSME_INDICATOR,
        t0.business_type as PARTY_ORGANISATION_PROFILE__NATURE_OF_BUSINESS,
        null,
        t0.paid_up_capital as PARTY_ORGANISATION_PROFILE__PAID_UP_CAPITAL,
        null, null, null, null,
        t0.special_rate as PARTY_PAYOUT_PROFILE__TDS_RATE,
        null, null,
        t0.overall_rating as PROVIDER_QUALITY__QUALITY_RATING,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (coalesce(nullif(md5(normalise(nullif(trim(coalesce(t0.client_geography,'')), ''))), ''), nullif(nullif(trim(j2.party_code),''), ''), nullif(nullif(trim(t0.branch),''), ''), nullif(t0.calculator_urn_number, ''), nullif(t0.product_code, ''))) is not null

    union all

    -- branch 69: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): AUG_PARTY_CONTACT_ADDRESS_LINK.Address Usage Type=OVERSEAS_PERMANENT
    select
        null,
        nullif(md5(normalise(nullif(trim(coalesce(t0.correspondence_local_address_line_1,'') || '|' || coalesce(t0.correspondence_local_address_line_2,'') || '|' || coalesce(t0.correspondence_local_address_line_3,'') || '|' || coalesce(t0.correspondence_local_address_city_town_village,'') || '|' || coalesce(t0.correspondence_local_address_district,'') || '|' || coalesce(t0.correspondence_local_address_state,'') || '|' || coalesce(t0.correspondence_local_address_country,'') || '|' || coalesce(t0.local_address_pin_code,'')), '|||||||'))), '') as LOCATION_BK,
        null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null,
        1 as __LNK_PARTY_LOCATION,
        null, null, null, null, null, null, null, null,
        'OVERSEAS_PERMANENT' as AUG_PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE_CK,
        t0.flag_indicating_if_current_permanent_overseas_address_is_same_as_correspondence_local_address as AUG_PARTY_CONTACT_ADDRESS_LINK__SAME_AS_CORRESPONDENCE_ADDRESS_INDICATOR,
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
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (coalesce(nullif(md5(normalise(nullif(trim(coalesce(t0.correspondence_local_address_line_1,'') || '|' || coalesce(t0.correspondence_local_address_line_2,'') || '|' || coalesce(t0.correspondence_local_address_line_3,'') || '|' || coalesce(t0.correspondence_local_address_city_town_village,'') || '|' || coalesce(t0.correspondence_local_address_district,'') || '|' || coalesce(t0.correspondence_local_address_state,'') || '|' || coalesce(t0.correspondence_local_address_country,'') || '|' || coalesce(t0.local_address_pin_code,'')), '|||||||'))), ''), nullif(nullif(trim(j2.party_code),''), ''))) is not null

    union all

    -- branch 70: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): AUG_PARTY_CONTACT_ADDRESS_LINK.Address Usage Type=MAILING
    select
        null,
        nullif(md5(normalise(nullif(trim(coalesce(t0.correspondence_local_address_line_1,'') || '|' || coalesce(t0.correspondence_local_address_line_2,'') || '|' || coalesce(t0.correspondence_local_address_line_3,'') || '|' || coalesce(t0.correspondence_local_address_city_town_village,'') || '|' || coalesce(t0.correspondence_local_address_district,'') || '|' || coalesce(t0.correspondence_local_address_state,'') || '|' || coalesce(t0.correspondence_local_address_country,'') || '|' || coalesce(t0.local_address_pin_code,'')), '|||||||'))), '') as LOCATION_BK,
        null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null,
        1 as __LNK_PARTY_LOCATION,
        null, null, null, null, null, null, null, null,
        'MAILING' as AUG_PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE_CK,
        null, null,
        t0.is_the_mailingcommunication_address_same_as_the_primary_address as AUG_PARTY_CONTACT_ADDRESS_LINK__SAME_AS_PRIMARY_ADDRESS_INDICATOR,
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
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (coalesce(nullif(md5(normalise(nullif(trim(coalesce(t0.correspondence_local_address_line_1,'') || '|' || coalesce(t0.correspondence_local_address_line_2,'') || '|' || coalesce(t0.correspondence_local_address_line_3,'') || '|' || coalesce(t0.correspondence_local_address_city_town_village,'') || '|' || coalesce(t0.correspondence_local_address_district,'') || '|' || coalesce(t0.correspondence_local_address_state,'') || '|' || coalesce(t0.correspondence_local_address_country,'') || '|' || coalesce(t0.local_address_pin_code,'')), '|||||||'))), ''), nullif(nullif(trim(j2.party_code),''), ''))) is not null

    union all

    -- branch 71: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): AUG_PARTY_DIGITAL_IDENTITY.Active Sequence Number=SMART_PHONE
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SMART_PHONE' as AUG_PARTY_DIGITAL_IDENTITY__ACTIVE_SEQUENCE_NUMBER_CK,
        t0.smart_phone_company_namemodel_name as AUG_PARTY_DIGITAL_IDENTITY__DEVICE_MAKE_AND_MODEL,
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
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 72: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): AUG_PARTY_IDENTIFICATION.Identification Type Code=PROOF_OF_ADDRESS
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'PROOF_OF_ADDRESS' as AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        t0.claim_poa_status as AUG_PARTY_IDENTIFICATION__CLAIM_CONTEXT_IDENTIFICATION_VERIFIED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null,
        t0.proof_of_address_submitted_for_current_permanent_overseas_addressothers as AUG_PARTY_IDENTIFICATION__PROOF_OF_ADDRESS_OTHER_DESCRIPTION,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 73: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): AUG_PARTY_IDENTIFICATION.Identification Type Code=PROOF_OF_IDENTITY
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'PROOF_OF_IDENTITY' as AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        t0.claim_poi_status as AUG_PARTY_IDENTIFICATION__CLAIM_CONTEXT_IDENTIFICATION_VERIFIED_INDICATOR,
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
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 74: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): AUG_PARTY_IDENTIFICATION.Identification Type Code=EIA
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'EIA' as AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null,
        t0.eia_available as AUG_PARTY_IDENTIFICATION__EIA_AVAILABLE_INDICATOR,
        t0.eia_credit_required as AUG_PARTY_IDENTIFICATION__EIA_CREDIT_REQUIRED_INDICATOR,
        t0.eia_details as AUG_PARTY_IDENTIFICATION__EIA_DETAILS_DESCRIPTION,
        t0.eia_required as AUG_PARTY_IDENTIFICATION__EIA_REQUIRED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 75: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): AUG_PARTY_IDENTIFICATION.Identification Type Code=AADHAAR
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'AADHAAR' as AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null,
        t0.name_as_per_aadhaar as AUG_PARTY_IDENTIFICATION__NAME_AS_PER_IDENTIFICATION_DOCUMENT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 76: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): AUG_PARTY_IDENTIFICATION.Identification Type Code=CKYC
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'CKYC' as AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null,
        t0.name_as_per_ckyc as AUG_PARTY_IDENTIFICATION__NAME_AS_PER_IDENTIFICATION_DOCUMENT,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 77: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): AUG_PARTY_IDENTIFICATION.Identification Type Code=PAN
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'PAN' as AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null,
        t0.name_as_per_pan as AUG_PARTY_IDENTIFICATION__NAME_AS_PER_IDENTIFICATION_DOCUMENT,
        t0.pan_aadhaar_linked as AUG_PARTY_IDENTIFICATION__PAN_AADHAAR_LINKED_INDICATOR,
        t0.pan_application_no as AUG_PARTY_IDENTIFICATION__PAN_APPLICATION_NUMBER,
        t0.pan_applied_for as AUG_PARTY_IDENTIFICATION__PAN_APPLIED_INDICATOR,
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
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 78: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): AUG_PARTY_IDENTIFICATION.Identification Type Code=PASSPORT
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'PASSPORT' as AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null,
        t0.passport_details as AUG_PARTY_IDENTIFICATION__PASSPORT_DETAIL_DESCRIPTION,
        t0.passport_file_no as AUG_PARTY_IDENTIFICATION__PASSPORT_FILE_NUMBER,
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
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 79: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): AUG_PARTY_IDENTIFICATION.Identification Type Code=GSTIN
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        'GSTIN' as AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.statewise_gstin_details as AUG_PARTY_IDENTIFICATION__STATE_WISE_GSTIN_REGISTRATION_DETAILS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 80: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): LNK_PARTY_ROLE_CORE.Role Sequence=1
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.default_role as LNK_PARTY_ROLE_CORE__ROLE_CODE_CK,
        '1' as LNK_PARTY_ROLE_CORE__ROLE_SEQUENCE_CK,
        t0.default_role as LNK_PARTY_ROLE_CORE__ROLE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 81: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): LNK_PARTY_ROLE_CORE.Role Sequence=1
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.party_function as LNK_PARTY_ROLE_CORE__ROLE_CODE_CK,
        '1' as LNK_PARTY_ROLE_CORE__ROLE_SEQUENCE_CK,
        t0.party_function as LNK_PARTY_ROLE_CORE__ROLE_CODE,
        null,
        t0.type_of_insured as LNK_PARTY_ROLE_CORE__ROLE_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 82: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): LNK_ROLE_AGENT.Role Type=AGENT
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null,
        'AGENT' as ROLE_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'AGENT' as LNK_ROLE_AGENT__ROLE_TYPE_CK,
        null, null, null,
        t0.irda_code as LNK_ROLE_AGENT__IRDAI_AGENT_LICENCE_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 83: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): LNK_ROLE_CUSTOMER.Role Type=CUSTOMER
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null,
        'CUSTOMER' as ROLE_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        'CUSTOMER' as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        null, null, null,
        t0.priority_customer as LNK_ROLE_CUSTOMER__PREFERRED_CUSTOMER_INDICATOR,
        t0.prive_flag as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 84: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): LNK_ROLE_EMPLOYEE.Role Type=EMPLOYEE
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null,
        'EMPLOYEE' as ROLE_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EMPLOYEE' as LNK_ROLE_EMPLOYEE__ROLE_TYPE_CK,
        t0.employee_status as LNK_ROLE_EMPLOYEE__ACTIVE_INDICATOR,
        t0.department as LNK_ROLE_EMPLOYEE__DEPARTMENT,
        t0.employee_role as LNK_ROLE_EMPLOYEE__DESIGNATION,
        t0.employee_code as LNK_ROLE_EMPLOYEE__EMPLOYEE_CODE,
        t0.function as LNK_ROLE_EMPLOYEE__FUNCTION,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 85: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): LNK_ROLE_PROVIDER.Role Type=PROVIDER
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null,
        'PROVIDER' as ROLE_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PROVIDER' as LNK_ROLE_PROVIDER__ROLE_TYPE_CK,
        null, null,
        t0.mou_status as LNK_ROLE_PROVIDER__MOU_STATUS,
        null,
        t0.supplier_location as LNK_ROLE_PROVIDER__SERVICE_REGION,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 86: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_AGENT_LICENCE_LINE.Line Of Business=HEALTH
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null,
        'HEALTH' as PARTY_AGENT_LICENCE_LINE__LINE_OF_BUSINESS_CK,
        t0.exam_details as PARTY_AGENT_LICENCE_LINE__EXAMINATION_REFERENCE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 87: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=AADHAAR_ENROLMENT
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'AADHAAR_ENROLMENT' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.aadhaar_enrollment_no as PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 88: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=AADHAAR
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'AADHAAR' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        t0.aadhaar_number as PARTY_IDENTIFICATION__AADHAAR_NUMBER,
        t0.poa_aadhar_card_status as PARTY_IDENTIFICATION__AADHAAR_VERIFICATION_STATUS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 89: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=ABHA
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ABHA' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.abha_id as PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 90: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=PROOF_OF_ADDRESS
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PROOF_OF_ADDRESS' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.address_proof_effective_date as PARTY_IDENTIFICATION__IDENTIFICATION_ISSUE_DATE,
        null, null, null,
        t0.poa_status as PARTY_IDENTIFICATION__IDENTIFICATION_VERIFIED_INDICATOR,
        null,
        t0.address_proof as PARTY_IDENTIFICATION__OVD_CATEGORY,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 91: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=CERTIFICATION
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CERTIFICATION' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.certification_no as PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 92: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=CIN
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CIN' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null,
        t0.cin_number as PARTY_IDENTIFICATION__CIN_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 93: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=AGE_PROOF
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'AGE_PROOF' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null,
        t0.dob_proof as PARTY_IDENTIFICATION__AGE_PROOF_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 94: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=DRIVING_LICENCE
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'DRIVING_LICENCE' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null,
        t0.driving_license_expiry_date as PARTY_IDENTIFICATION__DRIVING_LICENCE_EXPIRY_DATE,
        t0.driving_license_number as PARTY_IDENTIFICATION__DRIVING_LICENCE_NUMBER,
        null, null, null, null, null,
        t0.driving_license_issue_date as PARTY_IDENTIFICATION__IDENTIFICATION_ISSUE_DATE,
        t0.driving_license_place_of_issue as PARTY_IDENTIFICATION__IDENTIFICATION_ISSUING_AUTHORITY,
        null, null,
        t0.poa_driving_license_status as PARTY_IDENTIFICATION__IDENTIFICATION_VERIFIED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 95: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=EIA
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EIA' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null,
        t0.eia_number as PARTY_IDENTIFICATION__EIA_NUMBER,
        null, null, null, null,
        t0.eia_when_linked as PARTY_IDENTIFICATION__IDENTIFICATION_ISSUE_DATE,
        null, null, null,
        t0.e_insurance_demat_account_verified as PARTY_IDENTIFICATION__IDENTIFICATION_VERIFIED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 96: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=GSTIN
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'GSTIN' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null,
        t0.gstinuin as PARTY_IDENTIFICATION__GSTIN,
        t0.gstn_regn_status as PARTY_IDENTIFICATION__GST_REGISTRATION_STATUS,
        t0.gstn_taxpayer_type as PARTY_IDENTIFICATION__GST_TAXPAYER_TYPE,
        null,
        t0.gstin_issuance_dt as PARTY_IDENTIFICATION__IDENTIFICATION_ISSUE_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 97: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW
    select
        null,
        nullif('LOC:' || nullif(trim(t0.location_code),''), '') as LOCATION_BK,
        nullif(nullif(trim(t0.branch),''), '') as ORG_UNIT_BK,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null,
        1 as __LNK_ORG_UNIT_LOCATION,
        1 as __LNK_PARTY_LOCATION,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        t0.id_proof as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.id_proof as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (coalesce(nullif('LOC:' || nullif(trim(t0.location_code),''), ''), nullif(nullif(trim(j2.party_code),''), ''), nullif(nullif(trim(t0.branch),''), ''))) is not null

    union all

    -- branch 98: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.id_type as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.id_number as PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER,
        t0.id_type as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 99: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=GENERIC_DECLARED_ID
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'GENERIC_DECLARED_ID' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.identifier as PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 100: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=NREGA_JOB_CARD
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NREGA_JOB_CARD' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.poa_nrega_job_card_status as PARTY_IDENTIFICATION__IDENTIFICATION_VERIFIED_INDICATOR,
        t0.nrega_job_card as PARTY_IDENTIFICATION__NREGA_CARD_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 101: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=PAN
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PAN' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.pan_number as PARTY_IDENTIFICATION__PAN_NUMBER,
        t0.poi_pan_card_status as PARTY_IDENTIFICATION__PAN_VERIFICATION_STATUS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 102: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=PASSPORT
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PASSPORT' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.poa_passport_status as PARTY_IDENTIFICATION__IDENTIFICATION_VERIFIED_INDICATOR,
        null, null, null, null,
        t0.passport_number as PARTY_IDENTIFICATION__PASSPORT_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 103: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=TAN
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'TAN' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.tan_number as PARTY_IDENTIFICATION__TAN_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 104: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=AADHAAR_VID
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'AADHAAR_VID' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.vid as PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 105: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=VOTER_ID
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'VOTER_ID' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.voter_id as PARTY_IDENTIFICATION__VOTER_ID_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 106: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=SEPZ_REGISTRATION
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SEPZ_REGISTRATION' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.sepz_registration_date as PARTY_IDENTIFICATION__IDENTIFICATION_ISSUE_DATE,
        null,
        t0.sepz_registration_no as PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 107: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=PROOF_OF_IDENTITY
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PROOF_OF_IDENTITY' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.poi_status as PARTY_IDENTIFICATION__IDENTIFICATION_VERIFIED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 108: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=FORM_60
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'FORM_60' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.poi_form_60_status as PARTY_IDENTIFICATION__IDENTIFICATION_VERIFIED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 109: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_ORG_DIRECTORS.DIN Number=DIRECTOR
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
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
        null, null, null, null,
        'DIRECTOR' as PARTY_ORG_DIRECTORS__DIN_NUMBER_CK,
        t0.director_and_partner_details as PARTY_ORG_DIRECTORS__DIRECTOR_NAME,
        null, null, null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 110: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_ORG_DIRECTORS.DIN Number=OWNER
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
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
        null, null, null, null,
        'OWNER' as PARTY_ORG_DIRECTORS__DIN_NUMBER_CK,
        t0.owners_full_name as PARTY_ORG_DIRECTORS__DIRECTOR_NAME,
        null, null, null, null, null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 111: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=ONLINE_JOURNAL_ACCESS@LAWYER
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
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
        'ONLINE_JOURNAL_ACCESS@LAWYER' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        t0.access_online_journallawyer as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 112: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=ONLINE_JOURNAL_ACCESS
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
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
        'ONLINE_JOURNAL_ACCESS' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        t0.access_to_online_journal as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 113: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=LIBRARY@LAWYER
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
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
        'LIBRARY@LAWYER' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        t0.availability_librarylawyer as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 114: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=LIBRARY
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
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
        'LIBRARY' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        t0.availability_of_library as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 115: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=INTERNET_ACCESS
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
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
        'INTERNET_ACCESS' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        t0.internet_access as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 116: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=INTERNET_ACCESS@LAWYER
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
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
        'INTERNET_ACCESS@LAWYER' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        t0.internet_accesslawyer as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 117: MAXI_HLTH_UWR_VW_DATA_MEMBERS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=EW_WHITE_GOODS_REPAIRERS
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
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
        'EW_WHITE_GOODS_REPAIRERS' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        t0.ew_white_goods_repairers as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        null,
        9 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_members_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_members_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_members_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 118: MAXI_HLTH_UWR_VW_DATA_PAYMENT_INFO_PIVOT_VW
    select
        null, null, null,
        nullif(coalesce('PARTNER_CUST:' || nullif(trim(t0.partner_cust_id),'') ,'PAYER:' || md5(normalise(nullif(trim(coalesce(t0.name_of_the_premium_payer,'') || '|' || coalesce(t0.account_number,'')), '|')))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null,
        t0.ispaymentpartysearch as AUG_PARTY_ONBOARDING_JOURNEY__EXISTING_PARTY_SEARCH_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        t0.account_number as PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK,
        t0.name_of_account_holder as PARTY_BANKING__ACCOUNT_HOLDER_NAME,
        t0.account_number as PARTY_BANKING__ACCOUNT_NUMBER_MASKED,
        t0.account_type as PARTY_BANKING__ACCOUNT_TYPE,
        t0.bank_code as PARTY_BANKING__BANK_CODE,
        t0.name_of_the_bank as PARTY_BANKING__BANK_NAME,
        t0.branch_name_out as PARTY_BANKING__BRANCH_NAME,
        t0.bank_ifsc_code as PARTY_BANKING__IFSC_CODE,
        t0.micr_code as PARTY_BANKING__MICR_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        10 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_payment_info_pv') }} t0
    where (nullif(coalesce('PARTNER_CUST:' || nullif(trim(t0.partner_cust_id),'') ,'PAYER:' || md5(normalise(nullif(trim(coalesce(t0.name_of_the_premium_payer,'') || '|' || coalesce(t0.account_number,'')), '|')))), '')) is not null

    union all

    -- branch 119: MAXI_HLTH_UWR_VW_DATA_PAYMENT_INFO_PIVOT_VW
    select
        null, null, null,
        nullif(coalesce('PARTNER_CUST:' || nullif(trim(t0.partner_cust_id),'') ,'PAYER:' || md5(normalise(nullif(trim(coalesce(t0.name_of_the_premium_payer,'') || '|' || coalesce(t0.account_number,'')), '|')))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.account_number1 as PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK,
        null,
        t0.account_number1 as PARTY_BANKING__ACCOUNT_NUMBER_MASKED,
        null,
        t0.bank_code1 as PARTY_BANKING__BANK_CODE,
        t0.with_bank1 as PARTY_BANKING__BANK_NAME,
        null,
        t0.ifsc1 as PARTY_BANKING__IFSC_CODE,
        t0.micr1 as PARTY_BANKING__MICR_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        10 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_payment_info_pv') }} t0
    where (nullif(coalesce('PARTNER_CUST:' || nullif(trim(t0.partner_cust_id),'') ,'PAYER:' || md5(normalise(nullif(trim(coalesce(t0.name_of_the_premium_payer,'') || '|' || coalesce(t0.account_number,'')), '|')))), '')) is not null

    union all

    -- branch 120: MAXI_HLTH_UWR_VW_DATA_PAYMENT_INFO_PIVOT_VW
    select
        null, null, null,
        nullif(coalesce('PARTNER_CUST:' || nullif(trim(t0.partner_cust_id),'') ,'PAYER:' || md5(normalise(nullif(trim(coalesce(t0.name_of_the_premium_payer,'') || '|' || coalesce(t0.account_number,'')), '|')))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null,
        t0.account_number2 as PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK,
        null,
        t0.account_number2 as PARTY_BANKING__ACCOUNT_NUMBER_MASKED,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        10 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_payment_info_pv') }} t0
    where (nullif(coalesce('PARTNER_CUST:' || nullif(trim(t0.partner_cust_id),'') ,'PAYER:' || md5(normalise(nullif(trim(coalesce(t0.name_of_the_premium_payer,'') || '|' || coalesce(t0.account_number,'')), '|')))), '')) is not null

    union all

    -- branch 121: MAXI_HLTH_UWR_VW_DATA_PAYMENT_INFO_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=PARTNER_ID
    select
        null, null, null,
        nullif(coalesce('PARTNER_CUST:' || nullif(trim(t0.partner_cust_id),'') ,'PAYER:' || md5(normalise(nullif(trim(coalesce(t0.name_of_the_premium_payer,'') || '|' || coalesce(t0.account_number,'')), '|')))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PARTNER_ID' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.partner_cust_id as PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        10 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_payment_info_pv') }} t0
    where (nullif(coalesce('PARTNER_CUST:' || nullif(trim(t0.partner_cust_id),'') ,'PAYER:' || md5(normalise(nullif(trim(coalesce(t0.name_of_the_premium_payer,'') || '|' || coalesce(t0.account_number,'')), '|')))), '')) is not null

    union all

    -- branch 122: MAXI_HLTH_UWR_VW_DATA_PAYMENT_INFO_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=PARTNER_ID_2
    select
        null, null, null,
        nullif(coalesce('PARTNER_CUST:' || nullif(trim(t0.partner_cust_id),'') ,'PAYER:' || md5(normalise(nullif(trim(coalesce(t0.name_of_the_premium_payer,'') || '|' || coalesce(t0.account_number,'')), '|')))), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PARTNER_ID_2' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.partner_cust_id1 as PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        10 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_payment_info_pv') }} t0
    where (nullif(coalesce('PARTNER_CUST:' || nullif(trim(t0.partner_cust_id),'') ,'PAYER:' || md5(normalise(nullif(trim(coalesce(t0.name_of_the_premium_payer,'') || '|' || coalesce(t0.account_number,'')), '|')))), '')) is not null

    union all

    -- branch 123: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY
    select
        null, null, null,
        nullif(nullif(trim(t0.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.company as PARTY_EMPLOYMENT__EMPLOYER_NAME,
        null, null,
        t0.occupation as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        11 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party') }} t0
    where (nullif(nullif(trim(t0.party_code),''), '')) is not null

    union all

    -- branch 124: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=CITIZENSHIP
    select
        null, null, null,
        nullif(nullif(trim(t0.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CITIZENSHIP' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.citizenship_id as PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        11 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party') }} t0
    where (nullif(nullif(trim(t0.party_code),''), '')) is not null

    union all

    -- branch 125: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW
    select
        null,
        nullif(md5(normalise(nullif(trim(coalesce(t0.current_permanent_overseas_address_line_1,'') || '|' || coalesce(t0.current_permanent_overseas_address_line_2,'') || '|' || coalesce(t0.current_permanent_overseas_address_line_3,'') || '|' || coalesce(t0.current_permanent_overseas_address_city_town_village,'') || '|' || coalesce(t0.current_permanent_overseas_address_state_ut,'') || '|' || coalesce(t0.current_permanent_overseas_address_country,'') || '|' || coalesce(t0.current_permanent_overseas_address_pin_code,'')), '||||||'))), '') as LOCATION_BK,
        null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null,
        t0.current_permanent_overseas_address as AUG_COMMON_ADDRESS__FULL_ADDRESS_TEXT,
        t0.preferred_mode_of_alert as AUG_COMMON_COMMUNICATION_PREFERENCE__PREFERRED_ALERT_CHANNEL,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.other_occupation as AUG_PARTY_EMPLOYMENT__OTHER_OCCUPATION,
        t0.primary_profession as AUG_PARTY_EMPLOYMENT__PRIMARY_PROFESSION,
        t0.years_of_experience as AUG_PARTY_EMPLOYMENT__TOTAL_YEARS_OF_EXPERIENCE,
        t0.used_car_dealer as AUG_PARTY_EMPLOYMENT__USED_CAR_DEALER_OCCUPATION_INDICATOR,
        t0.blacklist_details as AUG_PARTY_FRAUD_PROFILE__NEGATIVE_LIST_DETAILS,
        null,
        t0.blockunblock_status as AUG_PARTY_FRAUD_PROFILE__PARTY_BLOCK_STATUS,
        t0.affinity_partner_employee as AUG_PARTY_GROUP_SCHEME__AFFINITY_PARTNER_EMPLOYEE_INDICATOR,
        null,
        t0.ra_ecode as AUG_PARTY_HIERARCHY__RELATIONSHIP_ASSOCIATE_EMPLOYEE_CODE,
        t0.transfer_case as AUG_PARTY_HIERARCHY__TRANSFER_CASE_REFERENCE,
        t0.transfer as AUG_PARTY_HIERARCHY__TRANSFER_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.basic_qualifications_details as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__BASIC_QUALIFICATION_DESCRIPTION,
        t0.roll_no_for_basic_qualification as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__BASIC_QUALIFICATION_ROLL_NUMBER,
        null, null, null, null, null, null, null,
        t0.postgrad as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__POSTGRADUATE_QUALIFICATION,
        t0.professional_qualification as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__PROFESSIONAL_QUALIFICATION,
        t0.board_name_for_basic_qualification as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__QUALIFICATION_BOARD_NAME,
        t0.qualifications_details as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__QUALIFICATION_DETAILS,
        null,
        t0.undergrad as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__UNDERGRADUATE_QUALIFICATION,
        t0.year_of_passing as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__YEAR_OF_PASSING_QUALIFICATION,
        t0.ckyc_details as AUG_PARTY_KYC__CKYC_DETAILS_DESCRIPTION,
        null, null, null, null,
        t0.covered_court_locations as AUG_PARTY_LEGAL_PANEL__COVERED_COURT_LOCATIONS,
        null, null, null, null, null,
        t0.whether_practicing_with_hc as AUG_PARTY_LEGAL_PANEL__PRACTISING_WITH_HIGH_COURT_INDICATOR,
        t0.bagic_office_addresslawyer as AUG_PARTY_LEGAL_PANEL__SERVICING_INSURER_OFFICE_ADDRESS,
        null,
        t0.rejected_reason as AUG_PARTY_ONBOARDING_JOURNEY__APPLICATION_REJECTION_REASON,
        t0.background_of_candidate as AUG_PARTY_ONBOARDING_JOURNEY__CANDIDATE_BACKGROUND_DESCRIPTION,
        null,
        t0.previous_company_location as AUG_PARTY_ONBOARDING_JOURNEY__PREVIOUS_EMPLOYER_LOCATION,
        t0.previous_company_parent_imd_code as AUG_PARTY_ONBOARDING_JOURNEY__PREVIOUS_EMPLOYER_PARENT_INTERMEDIARY_CODE,
        t0.previous_company_parent_subimd_code as AUG_PARTY_ONBOARDING_JOURNEY__PREVIOUS_EMPLOYER_PARENT_SUB_INTERMEDIARY_CODE,
        t0.name_of_nongeneral_insurer_worked_for as AUG_PARTY_ONBOARDING_JOURNEY__PREVIOUS_NON_GENERAL_INSURER_NAME,
        t0.reason_for_leaving_remarks as AUG_PARTY_ONBOARDING_JOURNEY__REASON_FOR_LEAVING_PREVIOUS_EMPLOYER,
        t0.business_details as AUG_PARTY_ORGANISATION_PROFILE__BUSINESS_DESCRIPTION,
        t0.client_geography as AUG_PARTY_ORGANISATION_PROFILE__CLIENT_GEOGRAPHY_CLASSIFICATION,
        t0.contact_person_name as AUG_PARTY_ORGANISATION_PROFILE__CONTACT_PERSON_NAME,
        null,
        t0.firms_name as AUG_PARTY_ORGANISATION_PROFILE__PRACTISING_FIRM_NAME,
        null,
        t0.are_you_registered_company as AUG_PARTY_ORGANISATION_PROFILE__REGISTERED_COMPANY_INDICATOR,
        t0.business_company as AUG_PARTY_ORGANISATION_PROFILE__REPRESENTED_BUSINESS_NAME,
        t0.statewise_gstin_details as AUG_PARTY_ORGANISATION_PROFILE__STATE_WISE_GSTIN_DETAILS,
        t0.trade_name as AUG_PARTY_ORGANISATION_PROFILE__TRADE_NAME,
        t0.type_of_trust as AUG_PARTY_ORGANISATION_PROFILE__TRUST_TYPE,
        t0.agent_float_access as AUG_PARTY_PAYOUT_PROFILE__FLOAT_ACCOUNT_ACCESS_INDICATOR,
        null,
        t0.applicable_for_reward as AUG_PARTY_PAYOUT_PROFILE__REWARD_SCHEME_APPLICABLE_INDICATOR,
        t0.tds_code as AUG_PARTY_PAYOUT_PROFILE__TDS_CODE,
        t0.tds_code_desc as AUG_PARTY_PAYOUT_PROFILE__TDS_CODE_DESCRIPTION,
        t0.tds_details as AUG_PARTY_PAYOUT_PROFILE__TDS_DETAILS,
        null, null, null,
        t0.update_contact_details_in_all_policies as AUG_PARTY_PREFERENCE_PROFILE__PROPAGATE_CONTACT_UPDATE_TO_ALL_POLICIES_INDICATOR,
        null,
        t0.relationship_with_employee as AUG_PARTY_RELATIONSHIP_PROFILE__RELATIONSHIP_WITH_EMPLOYEE,
        t0.relationship_with_hni as AUG_PARTY_RELATIONSHIP_PROFILE__RELATIONSHIP_WITH_HNI_CUSTOMER,
        t0.relationship_with_prive as AUG_PARTY_RELATIONSHIP_PROFILE__RELATIONSHIP_WITH_PRIVE_CUSTOMER,
        t0.category as COMMON_CLASSIFICATION__CATEGORY_CODE,
        null,
        t0.profile as COMMON_CLASSIFICATION__SEGMENT_NAME,
        t0.prive_flag as COMMON_CLASSIFICATION__TIER_CODE,
        null,
        t0.party_language as COMMON_COMMUNICATION_PREFERENCE__CORRESPONDENCE_LANGUAGE,
        t0.epolicy_required as COMMON_COMMUNICATION_PREFERENCE__GO_GREEN_OPT_IN_INDICATOR,
        t0.preferred_mode_of_communication as COMMON_COMMUNICATION_PREFERENCE__PREFERRED_CHANNEL_CODE,
        t0.languages_preferred as COMMON_COMMUNICATION_PREFERENCE__PREFERRED_LANGUAGE_CODE,
        t0.customer_consent as COMMON_CONSENT__CONSENT_GIVEN_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        t0.aml_verification_status as PARTY_AML_SCREENING__SCREENING_STATUS,
        null, null, null, null, null, null, null, null, null, null,
        t0.employer_name as PARTY_EMPLOYMENT__EMPLOYER_NAME,
        t0.employee_status as PARTY_EMPLOYMENT__EMPLOYMENT_STATUS,
        t0.occupation_list as PARTY_EMPLOYMENT__OCCUPATION_CODE,
        t0.occupation as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
        t0.certification_no as PARTY_EMPLOYMENT__PROFESSIONAL_REGISTRATION_NUMBER,
        t0.insured_occupation_details as PARTY_EMPLOYMENT__WORK_NATURE,
        t0.blacklisted as PARTY_FRAUD_PROFILE__NEGATIVE_LIST_INDICATOR,
        t0.reason_for_blacklisting as PARTY_FRAUD_PROFILE__NEGATIVE_LIST_REASON,
        t0.date_of_blacklisting as PARTY_FRAUD_PROFILE__WATCH_START_DATE,
        null, null, null,
        t0.medicine_name as PARTY_HEALTH_PROFILE__CURRENT_MEDICATION_DETAIL,
        t0.physically_challenged as PARTY_HEALTH_PROFILE__DISABILITY_INDICATOR,
        t0.disability_percentage as PARTY_HEALTH_PROFILE__DISABILITY_PERCENTAGE,
        null,
        t0.height as PARTY_HEALTH_PROFILE__HEIGHT,
        null,
        t0.disease_name as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
        null,
        t0.weight as PARTY_HEALTH_PROFILE__WEIGHT,
        t0.level as PARTY_HIERARCHY__HIERARCHY_LEVEL,
        t0.dob_proof as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null,
        t0.dob_proof as PARTY_IDENTIFICATION__AGE_PROOF_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.educational_qualification as PARTY_INDIVIDUAL_DEMOGRAPHICS__EDUCATIONAL_QUALIFICATION,
        null,
        t0.father_name as PARTY_INDIVIDUAL_DEMOGRAPHICS__FATHER_NAME,
        t0.highest_qualification_details as PARTY_INDIVIDUAL_DEMOGRAPHICS__HIGHEST_DEGREE,
        t0.marital_status as PARTY_INDIVIDUAL_DEMOGRAPHICS__MARITAL_STATUS,
        t0.spouse_name as PARTY_INDIVIDUAL_DEMOGRAPHICS__SPOUSE_NAME,
        t0.do_you_have_2_wheeler4_wheeler as PARTY_INDIVIDUAL_DEMOGRAPHICS__VEHICLE_OWNED_INDICATOR,
        t0.number_of_years_residing_in_the_city_of_residence as PARTY_INDIVIDUAL_DEMOGRAPHICS__YEARS_IN_CITY,
        t0.ckyc_number as PARTY_KYC__CKYC_NUMBER,
        t0.ckyc_status as PARTY_KYC__CKYC_REGISTRATION_STATUS,
        null, null,
        t0.type_of_lawyer as PARTY_LEGAL_PANEL__ADVOCATE_TYPE,
        t0.mou_statuslawyer as PARTY_LEGAL_PANEL__AGREEMENT_STATUS,
        t0.enrolled_with_name_of_state_bar_association as PARTY_LEGAL_PANEL__BAR_COUNCIL_NAME,
        t0.enrollment_id as PARTY_LEGAL_PANEL__BAR_ENROLMENT_NUMBER,
        t0.no_of_briefs as PARTY_LEGAL_PANEL__CASES_HANDLED_COUNT,
        t0.date_of_joininglawyer as PARTY_LEGAL_PANEL__EMPANELMENT_DATE,
        t0.no_of_juniors as PARTY_LEGAL_PANEL__JUNIORS_COUNT,
        t0.category_of_appointment as PARTY_LEGAL_PANEL__PANEL_CATEGORY,
        t0.yr_experiencelawyer as PARTY_LEGAL_PANEL__YEARS_OF_PRACTICE,
        t0.annual_turnover as PARTY_ORGANISATION_PROFILE__ANNUAL_TURNOVER,
        t0.company_no as PARTY_ORGANISATION_PROFILE__BUSINESS_REGISTRATION_NUMBER,
        t0.date_of_registration_or_incorporation as PARTY_ORGANISATION_PROFILE__DATE_OF_INCORPORATION,
        t0.global_co_name as PARTY_ORGANISATION_PROFILE__GROUP_NAME,
        t0.industry_code as PARTY_ORGANISATION_PROFILE__INDUSTRY_CODE,
        t0.industry_type as PARTY_ORGANISATION_PROFILE__INDUSTRY_DESCRIPTION,
        t0.constitution_of_business as PARTY_ORGANISATION_PROFILE__LEGAL_CONSTITUTION_TYPE,
        t0.msme_classification as PARTY_ORGANISATION_PROFILE__MSME_CATEGORY,
        t0.msme_applicable as PARTY_ORGANISATION_PROFILE__MSME_INDICATOR,
        t0.business_type as PARTY_ORGANISATION_PROFILE__NATURE_OF_BUSINESS,
        t0.sector_selection as PARTY_ORGANISATION_PROFILE__NIC_CODE,
        t0.paid_up_capital as PARTY_ORGANISATION_PROFILE__PAID_UP_CAPITAL,
        t0.parent_co as PARTY_ORGANISATION_PROFILE__PARENT_ENTITY_NAME,
        null, null,
        t0.gst_payment_flag as PARTY_PAYOUT_PROFILE__GST_APPLICABLE_INDICATOR,
        null, null, null,
        t0.overall_rating as PROVIDER_QUALITY__QUALITY_RATING,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (coalesce(nullif(md5(normalise(nullif(trim(coalesce(t0.current_permanent_overseas_address_line_1,'') || '|' || coalesce(t0.current_permanent_overseas_address_line_2,'') || '|' || coalesce(t0.current_permanent_overseas_address_line_3,'') || '|' || coalesce(t0.current_permanent_overseas_address_city_town_village,'') || '|' || coalesce(t0.current_permanent_overseas_address_state_ut,'') || '|' || coalesce(t0.current_permanent_overseas_address_country,'') || '|' || coalesce(t0.current_permanent_overseas_address_pin_code,'')), '||||||'))), ''), nullif(nullif(trim(j2.party_code),''), ''))) is not null

    union all

    -- branch 126: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): AUG_PARTY_DIGITAL_IDENTITY.Active Sequence Number=SMART_PHONE
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SMART_PHONE' as AUG_PARTY_DIGITAL_IDENTITY__ACTIVE_SEQUENCE_NUMBER_CK,
        t0.smart_phone_company_namemodel_name as AUG_PARTY_DIGITAL_IDENTITY__DEVICE_MAKE_AND_MODEL,
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
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 127: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): AUG_PARTY_DIGITAL_IDENTITY.Active Sequence Number=USER_CODE
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'USER_CODE' as AUG_PARTY_DIGITAL_IDENTITY__ACTIVE_SEQUENCE_NUMBER_CK,
        null,
        t0.type_of_user as AUG_PARTY_DIGITAL_IDENTITY__USER_TYPE,
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
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 128: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): LNK_PARTY_ROLE_CORE.Role Sequence=1
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.default_role as LNK_PARTY_ROLE_CORE__ROLE_CODE_CK,
        '1' as LNK_PARTY_ROLE_CORE__ROLE_SEQUENCE_CK,
        t0.default_role as LNK_PARTY_ROLE_CORE__ROLE_CODE,
        t0.end_date as LNK_PARTY_ROLE_CORE__ROLE_END_DATE,
        t0.intermediary_type as LNK_PARTY_ROLE_CORE__ROLE_TYPE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 129: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): LNK_PARTY_ROLE_CORE.Role Sequence=1
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.party_function as LNK_PARTY_ROLE_CORE__ROLE_CODE_CK,
        '1' as LNK_PARTY_ROLE_CORE__ROLE_SEQUENCE_CK,
        t0.party_function as LNK_PARTY_ROLE_CORE__ROLE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 130: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): LNK_ROLE_AGENT.Role Type=AGENT
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null,
        'AGENT' as ROLE_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'AGENT' as LNK_ROLE_AGENT__ROLE_TYPE_CK,
        null, null,
        t0.date_of_issue_of_appointment as LNK_ROLE_AGENT__APPOINTMENT_DATE,
        null, null, null, null, null,
        t0.date_of_acceptance_of_resignation as LNK_ROLE_AGENT__TERMINATION_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 131: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): LNK_ROLE_AGENT.Role Type=AGENT
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null,
        'AGENT' as ROLE_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'AGENT' as LNK_ROLE_AGENT__ROLE_TYPE_CK,
        null,
        t0.irda_code as LNK_ROLE_AGENT__AGENT_CODE,
        null,
        t0.license_number as LNK_ROLE_AGENT__IRDAI_AGENT_LICENCE_NUMBER,
        t0.license_type as LNK_ROLE_AGENT__LICENCE_CATEGORY,
        t0.license_expiry_date as LNK_ROLE_AGENT__LICENCE_EXPIRY_DATE,
        t0.license_issue_date as LNK_ROLE_AGENT__LICENCE_ISSUE_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 132: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): LNK_ROLE_CUSTOMER.Role Type=CUSTOMER
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null,
        'CUSTOMER' as ROLE_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        'CUSTOMER' as LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
        t0.customer_consent_for_data_sharing as LNK_ROLE_CUSTOMER__CONSENT_FOR_DATA_SHARING_INDICATOR,
        null, null, null,
        t0.hni_flag as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 133: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): LNK_ROLE_EMPLOYEE.Role Type=EMPLOYEE
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null,
        'EMPLOYEE' as ROLE_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EMPLOYEE' as LNK_ROLE_EMPLOYEE__ROLE_TYPE_CK,
        null,
        t0.department as LNK_ROLE_EMPLOYEE__DEPARTMENT,
        t0.employee_role as LNK_ROLE_EMPLOYEE__DESIGNATION,
        t0.employee_code as LNK_ROLE_EMPLOYEE__EMPLOYEE_CODE,
        t0.function as LNK_ROLE_EMPLOYEE__FUNCTION,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 134: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): LNK_ROLE_PROVIDER.Role Type=PROVIDER
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null,
        'PROVIDER' as ROLE_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PROVIDER' as LNK_ROLE_PROVIDER__ROLE_TYPE_CK,
        null, null,
        t0.mou_status as LNK_ROLE_PROVIDER__MOU_STATUS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 135: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=AADHAAR_ENROLMENT
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'AADHAAR_ENROLMENT' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.aadhaar_enrollment_no as PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 136: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=AADHAAR
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'AADHAAR' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        t0.aadhaar_number as PARTY_IDENTIFICATION__AADHAAR_NUMBER,
        t0.poa_aadhar_card_status as PARTY_IDENTIFICATION__AADHAAR_VERIFICATION_STATUS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 137: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=ABHA
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'ABHA' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.abha_id as PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 138: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=PROOF_OF_ADDRESS
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PROOF_OF_ADDRESS' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.address_proof_effective_date as PARTY_IDENTIFICATION__IDENTIFICATION_ISSUE_DATE,
        null, null,
        t0.address_proof as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE,
        t0.poa_status as PARTY_IDENTIFICATION__IDENTIFICATION_VERIFIED_INDICATOR,
        null,
        t0.proof_of_address_submitted_for_current_permanent_overseas_address as PARTY_IDENTIFICATION__OVD_CATEGORY,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 139: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=AUTOMOBILE_ASSOCIATION_MEMBERSHIP
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'AUTOMOBILE_ASSOCIATION_MEMBERSHIP' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.automobile_association_membership_no as PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 140: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=CIN
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'CIN' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null,
        t0.cin_number as PARTY_IDENTIFICATION__CIN_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 141: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=PROOF_OF_ADDRESS@CLAIM
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PROOF_OF_ADDRESS@CLAIM' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.claim_poa_status as PARTY_IDENTIFICATION__IDENTIFICATION_VERIFIED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 142: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=PROOF_OF_IDENTITY@CLAIM
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PROOF_OF_IDENTITY@CLAIM' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.claim_poi_status as PARTY_IDENTIFICATION__IDENTIFICATION_VERIFIED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 143: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=DRIVING_LICENCE
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'DRIVING_LICENCE' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null,
        t0.driving_license_expiry_date as PARTY_IDENTIFICATION__DRIVING_LICENCE_EXPIRY_DATE,
        t0.driving_license_number as PARTY_IDENTIFICATION__DRIVING_LICENCE_NUMBER,
        null, null, null, null, null,
        t0.driving_license_issue_date as PARTY_IDENTIFICATION__IDENTIFICATION_ISSUE_DATE,
        t0.driving_license_place_of_issue as PARTY_IDENTIFICATION__IDENTIFICATION_ISSUING_AUTHORITY,
        null, null,
        t0.poa_driving_license_status as PARTY_IDENTIFICATION__IDENTIFICATION_VERIFIED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 144: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=EIA
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'EIA' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null,
        t0.eia_number as PARTY_IDENTIFICATION__EIA_NUMBER,
        null, null, null, null,
        t0.eia_when_linked as PARTY_IDENTIFICATION__IDENTIFICATION_ISSUE_DATE,
        null, null, null,
        t0.e_insurance_demat_account_verified as PARTY_IDENTIFICATION__IDENTIFICATION_VERIFIED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 145: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=GSTIN
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'GSTIN' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null,
        t0.gstinuin as PARTY_IDENTIFICATION__GSTIN,
        t0.gstn_regn_status as PARTY_IDENTIFICATION__GST_REGISTRATION_STATUS,
        t0.taxpayer_type as PARTY_IDENTIFICATION__GST_TAXPAYER_TYPE,
        null,
        t0.gstin_issuance_dt as PARTY_IDENTIFICATION__IDENTIFICATION_ISSUE_DATE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 146: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.identification_proof as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.identification_proof_effective_date as PARTY_IDENTIFICATION__IDENTIFICATION_ISSUE_DATE,
        null, null,
        t0.identification_proof as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 147: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=GENERIC_DECLARED_ID
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'GENERIC_DECLARED_ID' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.identifier as PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 148: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.id_type as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.id_number as PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER,
        t0.id_type as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 149: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.id_type1 as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.id_type1 as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 150: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=NREGA_JOB_CARD
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'NREGA_JOB_CARD' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.poa_nrega_job_card_status as PARTY_IDENTIFICATION__IDENTIFICATION_VERIFIED_INDICATOR,
        t0.nrega_job_card as PARTY_IDENTIFICATION__NREGA_CARD_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 151: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=PAN
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PAN' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.pan_number as PARTY_IDENTIFICATION__PAN_NUMBER,
        t0.poi_pan_card_status as PARTY_IDENTIFICATION__PAN_VERIFICATION_STATUS,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 152: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=PASSPORT
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PASSPORT' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.poa_passport_status as PARTY_IDENTIFICATION__IDENTIFICATION_VERIFIED_INDICATOR,
        null, null, null, null,
        t0.passport_number as PARTY_IDENTIFICATION__PASSPORT_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 153: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=FORM_60
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'FORM_60' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.poi_form_60_status as PARTY_IDENTIFICATION__IDENTIFICATION_VERIFIED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 154: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=PROOF_OF_IDENTITY
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PROOF_OF_IDENTITY' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.poi_status as PARTY_IDENTIFICATION__IDENTIFICATION_VERIFIED_INDICATOR,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 155: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=PROOF_OF_POSSESSION_PRIMARY
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PROOF_OF_POSSESSION_PRIMARY' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.pop_primary as PARTY_IDENTIFICATION__OVD_CATEGORY,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 156: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=PROOF_OF_POSSESSION_OPTIONAL
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PROOF_OF_POSSESSION_OPTIONAL' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.pop_optional as PARTY_IDENTIFICATION__OVD_CATEGORY,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 157: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=PROOF_OF_ADDRESS_OTHER
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'PROOF_OF_ADDRESS_OTHER' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.proof_of_address_submitted_for_current_permanent_overseas_addressothers as PARTY_IDENTIFICATION__OVD_CATEGORY,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 158: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=SEPZ_REGISTRATION
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SEPZ_REGISTRATION' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null,
        t0.sepz_registration_date as PARTY_IDENTIFICATION__IDENTIFICATION_ISSUE_DATE,
        null,
        t0.sepz_registration_no as PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 159: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=SEZ_REGISTRATION
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SEZ_REGISTRATION' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null,
        t0.sez_expiry_date as PARTY_IDENTIFICATION__IDENTIFICATION_EXPIRY_DATE,
        t0.sez_registration_date as PARTY_IDENTIFICATION__IDENTIFICATION_ISSUE_DATE,
        null,
        t0.sez_registration_no as PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 160: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=SERVICE_TAX_REGISTRATION
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'SERVICE_TAX_REGISTRATION' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.service_tax as PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 161: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=TAN
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'TAN' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.tan_number as PARTY_IDENTIFICATION__TAN_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 162: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=AADHAAR_VID
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'AADHAAR_VID' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.vid as PARTY_IDENTIFICATION__IDENTIFICATION_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 163: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_IDENTIFICATION.Identification Type Code=VOTER_ID
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        'VOTER_ID' as PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        t0.voter_id as PARTY_IDENTIFICATION__VOTER_ID_NUMBER,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null, null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 164: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_ORG_DIRECTORS.DIN Number=OWNER
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
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
        null, null, null, null,
        'OWNER' as PARTY_ORG_DIRECTORS__DIN_NUMBER_CK,
        t0.owners_full_name as PARTY_ORG_DIRECTORS__DIRECTOR_NAME,
        null, null, null, null, null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 165: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=ONLINE_JOURNAL_ACCESS@LAWYER
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
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
        'ONLINE_JOURNAL_ACCESS@LAWYER' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        t0.access_online_journallawyer as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 166: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=ONLINE_JOURNAL_ACCESS
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
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
        'ONLINE_JOURNAL_ACCESS' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        t0.access_to_online_journal as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 167: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=LIBRARY@LAWYER
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
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
        'LIBRARY@LAWYER' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        t0.availability_librarylawyer as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 168: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=LIBRARY
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
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
        'LIBRARY' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        t0.availability_of_library as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 169: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=EW_WHITE_GOODS_REPAIRERS
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
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
        'EW_WHITE_GOODS_REPAIRERS' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        t0.ew_white_goods_repairers as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 170: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=INTERNET_ACCESS
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
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
        'INTERNET_ACCESS' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        t0.internet_access as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

    union all

    -- branch 171: MAXI_HLTH_UWR_VW_DATA_RELATIONS_PARTY_PARTY_DETAILS_PIVOT_VW | child-key literal(s): PARTY_PROVIDER_CAPABILITY.Facility Code=INTERNET_ACCESS@LAWYER
    select
        null, null, null,
        nullif(nullif(trim(j2.party_code),''), '') as PARTY_BK,
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
        'INTERNET_ACCESS@LAWYER' as PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
        t0.internet_accesslawyer as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
        null,
        12 as __PREC,
        hash(t0.*) as __RID
    from {{ ref('stg_mxh__uwr_relations_party_party_dtls_pv') }} t0
    left join {{ ref('stg_mxh__uwr_relations_party_party_dtls') }} j1 on j1.KEY_HASH = t0.PARENT_KEY_HASH
    left join {{ ref('stg_mxh__uwr_relations_party') }} j2 on j2.KEY_HASH = j1.PARENT_KEY_HASH
    where (nullif(nullif(trim(j2.party_code),''), '')) is not null

)

select
    FINANCIAL_TRANSACTION_BK,
    LOCATION_BK,
    ORG_UNIT_BK,
    PARTY_BK,
    PRODUCT_BK,
    QUOTE_BK,
    ROLE_TYPE_CODE,
    __LNK_ORG_UNIT_LOCATION,
    __LNK_PARTY_LOCATION,
    __LNK_PARTY_ORG_UNIT,
    __LNK_QUOTE_PARTY,
    __LNK_QUOTE_PRODUCT,
    first_value(AUG_COMMON_ADDRESS__FULL_ADDRESS_TEXT) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COMMON_ADDRESS__FULL_ADDRESS_TEXT,
    first_value(AUG_COMMON_COMMUNICATION_PREFERENCE__PREFERRED_ALERT_CHANNEL) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_COMMON_COMMUNICATION_PREFERENCE__PREFERRED_ALERT_CHANNEL,
    AUG_PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK,
    first_value(AUG_PARTY_BANKING__BANK_DETAIL_TEXT) ignore nulls over (partition by PARTY_BK, AUG_PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_BANKING__BANK_DETAIL_TEXT,
    first_value(AUG_PARTY_CONSENT_MANDATE__MANDATE_DETAIL_DESCRIPTION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_CONSENT_MANDATE__MANDATE_DETAIL_DESCRIPTION,
    AUG_PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE_CK,
    first_value(AUG_PARTY_CONTACT_ADDRESS_LINK__SAME_AS_CORRESPONDENCE_ADDRESS_INDICATOR) ignore nulls over (partition by LOCATION_BK, PARTY_BK, AUG_PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_CONTACT_ADDRESS_LINK__SAME_AS_CORRESPONDENCE_ADDRESS_INDICATOR,
    first_value(AUG_PARTY_CONTACT_ADDRESS_LINK__SAME_AS_POLICYHOLDER_ADDRESS_INDICATOR) ignore nulls over (partition by LOCATION_BK, PARTY_BK, AUG_PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_CONTACT_ADDRESS_LINK__SAME_AS_POLICYHOLDER_ADDRESS_INDICATOR,
    first_value(AUG_PARTY_CONTACT_ADDRESS_LINK__SAME_AS_PRIMARY_ADDRESS_INDICATOR) ignore nulls over (partition by LOCATION_BK, PARTY_BK, AUG_PARTY_CONTACT_ADDRESS_LINK__ADDRESS_USAGE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_CONTACT_ADDRESS_LINK__SAME_AS_PRIMARY_ADDRESS_INDICATOR,
    AUG_PARTY_DIGITAL_IDENTITY__ACTIVE_SEQUENCE_NUMBER_CK,
    first_value(AUG_PARTY_DIGITAL_IDENTITY__DEVICE_MAKE_AND_MODEL) ignore nulls over (partition by PARTY_BK, AUG_PARTY_DIGITAL_IDENTITY__ACTIVE_SEQUENCE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_DIGITAL_IDENTITY__DEVICE_MAKE_AND_MODEL,
    first_value(AUG_PARTY_DIGITAL_IDENTITY__USER_TYPE) ignore nulls over (partition by PARTY_BK, AUG_PARTY_DIGITAL_IDENTITY__ACTIVE_SEQUENCE_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_DIGITAL_IDENTITY__USER_TYPE,
    first_value(AUG_PARTY_EMPLOYMENT__EMPLOYER_DETAIL_DESCRIPTION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_EMPLOYMENT__EMPLOYER_DETAIL_DESCRIPTION,
    first_value(AUG_PARTY_EMPLOYMENT__OTHER_OCCUPATION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_EMPLOYMENT__OTHER_OCCUPATION,
    first_value(AUG_PARTY_EMPLOYMENT__PRIMARY_PROFESSION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_EMPLOYMENT__PRIMARY_PROFESSION,
    first_value(AUG_PARTY_EMPLOYMENT__TOTAL_YEARS_OF_EXPERIENCE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_EMPLOYMENT__TOTAL_YEARS_OF_EXPERIENCE,
    first_value(AUG_PARTY_EMPLOYMENT__USED_CAR_DEALER_OCCUPATION_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_EMPLOYMENT__USED_CAR_DEALER_OCCUPATION_INDICATOR,
    first_value(AUG_PARTY_FRAUD_PROFILE__NEGATIVE_LIST_DETAILS) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_FRAUD_PROFILE__NEGATIVE_LIST_DETAILS,
    first_value(AUG_PARTY_FRAUD_PROFILE__NON_DISCLOSURE_ACTION_INITIATED_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_FRAUD_PROFILE__NON_DISCLOSURE_ACTION_INITIATED_INDICATOR,
    first_value(AUG_PARTY_FRAUD_PROFILE__PARTY_BLOCK_STATUS) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_FRAUD_PROFILE__PARTY_BLOCK_STATUS,
    first_value(AUG_PARTY_GROUP_SCHEME__AFFINITY_PARTNER_EMPLOYEE_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_GROUP_SCHEME__AFFINITY_PARTNER_EMPLOYEE_INDICATOR,
    first_value(AUG_PARTY_GROUP_SCHEME__GROUP_HEALTH_USER_TYPE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_GROUP_SCHEME__GROUP_HEALTH_USER_TYPE,
    first_value(AUG_PARTY_HIERARCHY__RELATIONSHIP_ASSOCIATE_EMPLOYEE_CODE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_HIERARCHY__RELATIONSHIP_ASSOCIATE_EMPLOYEE_CODE,
    first_value(AUG_PARTY_HIERARCHY__TRANSFER_CASE_REFERENCE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_HIERARCHY__TRANSFER_CASE_REFERENCE,
    first_value(AUG_PARTY_HIERARCHY__TRANSFER_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_HIERARCHY__TRANSFER_INDICATOR,
    AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
    first_value(AUG_PARTY_IDENTIFICATION__CLAIM_CONTEXT_IDENTIFICATION_VERIFIED_INDICATOR) ignore nulls over (partition by PARTY_BK, AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_IDENTIFICATION__CLAIM_CONTEXT_IDENTIFICATION_VERIFIED_INDICATOR,
    first_value(AUG_PARTY_IDENTIFICATION__EIA_AVAILABLE_INDICATOR) ignore nulls over (partition by PARTY_BK, AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_IDENTIFICATION__EIA_AVAILABLE_INDICATOR,
    first_value(AUG_PARTY_IDENTIFICATION__EIA_CREDIT_REQUIRED_INDICATOR) ignore nulls over (partition by PARTY_BK, AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_IDENTIFICATION__EIA_CREDIT_REQUIRED_INDICATOR,
    first_value(AUG_PARTY_IDENTIFICATION__EIA_DETAILS_DESCRIPTION) ignore nulls over (partition by PARTY_BK, AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_IDENTIFICATION__EIA_DETAILS_DESCRIPTION,
    first_value(AUG_PARTY_IDENTIFICATION__EIA_REQUIRED_INDICATOR) ignore nulls over (partition by PARTY_BK, AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_IDENTIFICATION__EIA_REQUIRED_INDICATOR,
    first_value(AUG_PARTY_IDENTIFICATION__NAME_AS_PER_IDENTIFICATION_DOCUMENT) ignore nulls over (partition by PARTY_BK, AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_IDENTIFICATION__NAME_AS_PER_IDENTIFICATION_DOCUMENT,
    first_value(AUG_PARTY_IDENTIFICATION__PAN_AADHAAR_LINKED_INDICATOR) ignore nulls over (partition by PARTY_BK, AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_IDENTIFICATION__PAN_AADHAAR_LINKED_INDICATOR,
    first_value(AUG_PARTY_IDENTIFICATION__PAN_APPLICATION_NUMBER) ignore nulls over (partition by PARTY_BK, AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_IDENTIFICATION__PAN_APPLICATION_NUMBER,
    first_value(AUG_PARTY_IDENTIFICATION__PAN_APPLIED_INDICATOR) ignore nulls over (partition by PARTY_BK, AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_IDENTIFICATION__PAN_APPLIED_INDICATOR,
    first_value(AUG_PARTY_IDENTIFICATION__PASSPORT_DETAIL_DESCRIPTION) ignore nulls over (partition by PARTY_BK, AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_IDENTIFICATION__PASSPORT_DETAIL_DESCRIPTION,
    first_value(AUG_PARTY_IDENTIFICATION__PASSPORT_FILE_NUMBER) ignore nulls over (partition by PARTY_BK, AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_IDENTIFICATION__PASSPORT_FILE_NUMBER,
    first_value(AUG_PARTY_IDENTIFICATION__PROOF_OF_ADDRESS_OTHER_DESCRIPTION) ignore nulls over (partition by PARTY_BK, AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_IDENTIFICATION__PROOF_OF_ADDRESS_OTHER_DESCRIPTION,
    first_value(AUG_PARTY_IDENTIFICATION__STATE_WISE_GSTIN_REGISTRATION_DETAILS) ignore nulls over (partition by PARTY_BK, AUG_PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_IDENTIFICATION__STATE_WISE_GSTIN_REGISTRATION_DETAILS,
    first_value(AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__BASIC_QUALIFICATION_DESCRIPTION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__BASIC_QUALIFICATION_DESCRIPTION,
    first_value(AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__BASIC_QUALIFICATION_ROLL_NUMBER) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__BASIC_QUALIFICATION_ROLL_NUMBER,
    first_value(AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__MARRIAGE_ANNIVERSARY_DATE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__MARRIAGE_ANNIVERSARY_DATE,
    first_value(AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__MATRICULATION_QUALIFICATION_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__MATRICULATION_QUALIFICATION_INDICATOR,
    first_value(AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__MOTHER_MAIDEN_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__MOTHER_MAIDEN_NAME,
    first_value(AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__NUMBER_OF_DAUGHTERS) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__NUMBER_OF_DAUGHTERS,
    first_value(AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__NUMBER_OF_SONS) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__NUMBER_OF_SONS,
    first_value(AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__OTHER_RELATIONSHIP_DESCRIPTION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__OTHER_RELATIONSHIP_DESCRIPTION,
    first_value(AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__PERSONAL_DETAILS_DESCRIPTION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__PERSONAL_DETAILS_DESCRIPTION,
    first_value(AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__POSTGRADUATE_QUALIFICATION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__POSTGRADUATE_QUALIFICATION,
    first_value(AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__PROFESSIONAL_QUALIFICATION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__PROFESSIONAL_QUALIFICATION,
    first_value(AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__QUALIFICATION_BOARD_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__QUALIFICATION_BOARD_NAME,
    first_value(AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__QUALIFICATION_DETAILS) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__QUALIFICATION_DETAILS,
    first_value(AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__RELATIONSHIP_TO_PRIMARY_INSURED) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__RELATIONSHIP_TO_PRIMARY_INSURED,
    first_value(AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__UNDERGRADUATE_QUALIFICATION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__UNDERGRADUATE_QUALIFICATION,
    first_value(AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__YEAR_OF_PASSING_QUALIFICATION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS__YEAR_OF_PASSING_QUALIFICATION,
    first_value(AUG_PARTY_KYC__CKYC_DETAILS_DESCRIPTION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_KYC__CKYC_DETAILS_DESCRIPTION,
    first_value(AUG_PARTY_KYC__KYC_DETAIL_DESCRIPTION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_KYC__KYC_DETAIL_DESCRIPTION,
    first_value(AUG_PARTY_KYC__OPTIONAL_PROOF_OF_POSSESSION_TYPE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_KYC__OPTIONAL_PROOF_OF_POSSESSION_TYPE,
    first_value(AUG_PARTY_KYC__PRIMARY_PROOF_OF_POSSESSION_TYPE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_KYC__PRIMARY_PROOF_OF_POSSESSION_TYPE,
    first_value(AUG_PARTY_LEGAL_PANEL__CONSUMER_CASES_HANDLED_COUNT) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_LEGAL_PANEL__CONSUMER_CASES_HANDLED_COUNT,
    first_value(AUG_PARTY_LEGAL_PANEL__COVERED_COURT_LOCATIONS) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_LEGAL_PANEL__COVERED_COURT_LOCATIONS,
    first_value(AUG_PARTY_LEGAL_PANEL__EMPANELLED_COMPANIES_COUNT) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_LEGAL_PANEL__EMPANELLED_COMPANIES_COUNT,
    first_value(AUG_PARTY_LEGAL_PANEL__FIRM_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_LEGAL_PANEL__FIRM_NAME,
    first_value(AUG_PARTY_LEGAL_PANEL__HIGH_COURT_PRACTICE_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_LEGAL_PANEL__HIGH_COURT_PRACTICE_INDICATOR,
    first_value(AUG_PARTY_LEGAL_PANEL__MACT_CASES_HANDLED_COUNT) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_LEGAL_PANEL__MACT_CASES_HANDLED_COUNT,
    first_value(AUG_PARTY_LEGAL_PANEL__MACT_CASES_HANDLED_OTHER_COMPANY_COUNT) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_LEGAL_PANEL__MACT_CASES_HANDLED_OTHER_COMPANY_COUNT,
    first_value(AUG_PARTY_LEGAL_PANEL__PRACTISING_WITH_HIGH_COURT_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_LEGAL_PANEL__PRACTISING_WITH_HIGH_COURT_INDICATOR,
    first_value(AUG_PARTY_LEGAL_PANEL__SERVICING_INSURER_OFFICE_ADDRESS) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_LEGAL_PANEL__SERVICING_INSURER_OFFICE_ADDRESS,
    first_value(AUG_PARTY_LEGAL_PANEL__WC_CASES_HANDLED_COUNT) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_LEGAL_PANEL__WC_CASES_HANDLED_COUNT,
    first_value(AUG_PARTY_ONBOARDING_JOURNEY__APPLICATION_REJECTION_REASON) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_ONBOARDING_JOURNEY__APPLICATION_REJECTION_REASON,
    first_value(AUG_PARTY_ONBOARDING_JOURNEY__CANDIDATE_BACKGROUND_DESCRIPTION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_ONBOARDING_JOURNEY__CANDIDATE_BACKGROUND_DESCRIPTION,
    first_value(AUG_PARTY_ONBOARDING_JOURNEY__EXISTING_PARTY_SEARCH_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_ONBOARDING_JOURNEY__EXISTING_PARTY_SEARCH_INDICATOR,
    first_value(AUG_PARTY_ONBOARDING_JOURNEY__PREVIOUS_EMPLOYER_LOCATION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_ONBOARDING_JOURNEY__PREVIOUS_EMPLOYER_LOCATION,
    first_value(AUG_PARTY_ONBOARDING_JOURNEY__PREVIOUS_EMPLOYER_PARENT_INTERMEDIARY_CODE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_ONBOARDING_JOURNEY__PREVIOUS_EMPLOYER_PARENT_INTERMEDIARY_CODE,
    first_value(AUG_PARTY_ONBOARDING_JOURNEY__PREVIOUS_EMPLOYER_PARENT_SUB_INTERMEDIARY_CODE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_ONBOARDING_JOURNEY__PREVIOUS_EMPLOYER_PARENT_SUB_INTERMEDIARY_CODE,
    first_value(AUG_PARTY_ONBOARDING_JOURNEY__PREVIOUS_NON_GENERAL_INSURER_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_ONBOARDING_JOURNEY__PREVIOUS_NON_GENERAL_INSURER_NAME,
    first_value(AUG_PARTY_ONBOARDING_JOURNEY__REASON_FOR_LEAVING_PREVIOUS_EMPLOYER) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_ONBOARDING_JOURNEY__REASON_FOR_LEAVING_PREVIOUS_EMPLOYER,
    first_value(AUG_PARTY_ORGANISATION_PROFILE__BUSINESS_DESCRIPTION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_ORGANISATION_PROFILE__BUSINESS_DESCRIPTION,
    first_value(AUG_PARTY_ORGANISATION_PROFILE__CLIENT_GEOGRAPHY_CLASSIFICATION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_ORGANISATION_PROFILE__CLIENT_GEOGRAPHY_CLASSIFICATION,
    first_value(AUG_PARTY_ORGANISATION_PROFILE__CONTACT_PERSON_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_ORGANISATION_PROFILE__CONTACT_PERSON_NAME,
    first_value(AUG_PARTY_ORGANISATION_PROFILE__INFRASTRUCTURE_SUB_SECTOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_ORGANISATION_PROFILE__INFRASTRUCTURE_SUB_SECTOR,
    first_value(AUG_PARTY_ORGANISATION_PROFILE__PRACTISING_FIRM_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_ORGANISATION_PROFILE__PRACTISING_FIRM_NAME,
    first_value(AUG_PARTY_ORGANISATION_PROFILE__REGISTERED_BUSINESS_TRUST_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_ORGANISATION_PROFILE__REGISTERED_BUSINESS_TRUST_INDICATOR,
    first_value(AUG_PARTY_ORGANISATION_PROFILE__REGISTERED_COMPANY_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_ORGANISATION_PROFILE__REGISTERED_COMPANY_INDICATOR,
    first_value(AUG_PARTY_ORGANISATION_PROFILE__REPRESENTED_BUSINESS_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_ORGANISATION_PROFILE__REPRESENTED_BUSINESS_NAME,
    first_value(AUG_PARTY_ORGANISATION_PROFILE__STATE_WISE_GSTIN_DETAILS) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_ORGANISATION_PROFILE__STATE_WISE_GSTIN_DETAILS,
    first_value(AUG_PARTY_ORGANISATION_PROFILE__TRADE_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_ORGANISATION_PROFILE__TRADE_NAME,
    first_value(AUG_PARTY_ORGANISATION_PROFILE__TRUST_TYPE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_ORGANISATION_PROFILE__TRUST_TYPE,
    first_value(AUG_PARTY_PAYOUT_PROFILE__FLOAT_ACCOUNT_ACCESS_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_PAYOUT_PROFILE__FLOAT_ACCOUNT_ACCESS_INDICATOR,
    first_value(AUG_PARTY_PAYOUT_PROFILE__PAYMENT_MODE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_PAYOUT_PROFILE__PAYMENT_MODE,
    first_value(AUG_PARTY_PAYOUT_PROFILE__REWARD_SCHEME_APPLICABLE_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_PAYOUT_PROFILE__REWARD_SCHEME_APPLICABLE_INDICATOR,
    first_value(AUG_PARTY_PAYOUT_PROFILE__TDS_CODE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_PAYOUT_PROFILE__TDS_CODE,
    first_value(AUG_PARTY_PAYOUT_PROFILE__TDS_CODE_DESCRIPTION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_PAYOUT_PROFILE__TDS_CODE_DESCRIPTION,
    first_value(AUG_PARTY_PAYOUT_PROFILE__TDS_DETAILS) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_PAYOUT_PROFILE__TDS_DETAILS,
    first_value(AUG_PARTY_PAYOUT_PROFILE__TDS_DETAILS_DESCRIPTION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_PAYOUT_PROFILE__TDS_DETAILS_DESCRIPTION,
    first_value(AUG_PARTY_PREFERENCE_PROFILE__ELECTRONIC_POLICY_ISSUANCE_PREFERENCE_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_PREFERENCE_PROFILE__ELECTRONIC_POLICY_ISSUANCE_PREFERENCE_INDICATOR,
    first_value(AUG_PARTY_PREFERENCE_PROFILE__PREFERRED_REIMBURSEMENT_METHOD) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_PREFERENCE_PROFILE__PREFERRED_REIMBURSEMENT_METHOD,
    first_value(AUG_PARTY_PREFERENCE_PROFILE__PROPAGATE_CONTACT_UPDATE_TO_ALL_POLICIES_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_PREFERENCE_PROFILE__PROPAGATE_CONTACT_UPDATE_TO_ALL_POLICIES_INDICATOR,
    first_value(AUG_PARTY_PREFERENCE_PROFILE__REIMBURSEMENT_PREFERENCE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_PREFERENCE_PROFILE__REIMBURSEMENT_PREFERENCE,
    first_value(AUG_PARTY_RELATIONSHIP_PROFILE__RELATIONSHIP_WITH_EMPLOYEE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_RELATIONSHIP_PROFILE__RELATIONSHIP_WITH_EMPLOYEE,
    first_value(AUG_PARTY_RELATIONSHIP_PROFILE__RELATIONSHIP_WITH_HNI_CUSTOMER) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_RELATIONSHIP_PROFILE__RELATIONSHIP_WITH_HNI_CUSTOMER,
    first_value(AUG_PARTY_RELATIONSHIP_PROFILE__RELATIONSHIP_WITH_PRIVE_CUSTOMER) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as AUG_PARTY_RELATIONSHIP_PROFILE__RELATIONSHIP_WITH_PRIVE_CUSTOMER,
    first_value(COMMON_CLASSIFICATION__CATEGORY_CODE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_CLASSIFICATION__CATEGORY_CODE,
    first_value(COMMON_CLASSIFICATION__SEGMENT_CODE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_CLASSIFICATION__SEGMENT_CODE,
    first_value(COMMON_CLASSIFICATION__SEGMENT_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_CLASSIFICATION__SEGMENT_NAME,
    first_value(COMMON_CLASSIFICATION__TIER_CODE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_CLASSIFICATION__TIER_CODE,
    first_value(COMMON_CLASSIFICATION__VALUE_BAND) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_CLASSIFICATION__VALUE_BAND,
    first_value(COMMON_COMMUNICATION_PREFERENCE__CORRESPONDENCE_LANGUAGE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_COMMUNICATION_PREFERENCE__CORRESPONDENCE_LANGUAGE,
    first_value(COMMON_COMMUNICATION_PREFERENCE__GO_GREEN_OPT_IN_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_COMMUNICATION_PREFERENCE__GO_GREEN_OPT_IN_INDICATOR,
    first_value(COMMON_COMMUNICATION_PREFERENCE__PREFERRED_CHANNEL_CODE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_COMMUNICATION_PREFERENCE__PREFERRED_CHANNEL_CODE,
    first_value(COMMON_COMMUNICATION_PREFERENCE__PREFERRED_LANGUAGE_CODE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_COMMUNICATION_PREFERENCE__PREFERRED_LANGUAGE_CODE,
    first_value(COMMON_CONSENT__CONSENT_GIVEN_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_CONSENT__CONSENT_GIVEN_INDICATOR,
    first_value(COMMON_GEO__REGION_NAME) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_GEO__REGION_NAME,
    first_value(COMMON_GEO__URBAN_RURAL_CLASSIFICATION) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_GEO__URBAN_RURAL_CLASSIFICATION,
    first_value(COMMON_GEO__ZONE_CODE) ignore nulls over (partition by LOCATION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as COMMON_GEO__ZONE_CODE,
    first_value(FINTXN_CLAIM_PAYMENT__CHEQUE_DISPATCH_DATE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_CLAIM_PAYMENT__CHEQUE_DISPATCH_DATE,
    first_value(FINTXN_CLAIM_PAYMENT__NET_PAID_AMOUNT) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_CLAIM_PAYMENT__NET_PAID_AMOUNT,
    first_value(FINTXN_CLAIM_PAYMENT__PAYMENT_DATE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_CLAIM_PAYMENT__PAYMENT_DATE,
    first_value(FINTXN_CLAIM_PAYMENT__PAYMENT_MODE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_CLAIM_PAYMENT__PAYMENT_MODE,
    first_value(FINTXN_CLAIM_PAYMENT__PAYMENT_STATUS) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_CLAIM_PAYMENT__PAYMENT_STATUS,
    first_value(FINTXN_CLAIM_PAYMENT__PAYMENT_TYPE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_CLAIM_PAYMENT__PAYMENT_TYPE,
    first_value(FINTXN_CLAIM_PAYMENT__TDS_ON_CLAIM_AMOUNT) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_CLAIM_PAYMENT__TDS_ON_CLAIM_AMOUNT,
    first_value(FINTXN_CLAIM_PAYMENT__UTR_NUMBER) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_CLAIM_PAYMENT__UTR_NUMBER,
    FINTXN_TAX__TAX_TYPE_CK,
    first_value(FINTXN_TAX__COMPONENT_TAX_AMOUNT) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK, FINTXN_TAX__TAX_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_TAX__COMPONENT_TAX_AMOUNT,
    first_value(FINTXN_TAX__GSTIN) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK, FINTXN_TAX__TAX_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_TAX__GSTIN,
    first_value(FINTXN_TAX__HSN_SAC_CODE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK, FINTXN_TAX__TAX_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_TAX__HSN_SAC_CODE,
    first_value(FINTXN_TAX__SERVICE_TAX_APPLICABLE_INDICATOR) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK, FINTXN_TAX__TAX_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_TAX__SERVICE_TAX_APPLICABLE_INDICATOR,
    first_value(FINTXN_TAX__SERVICE_TAX_REGISTRATION_NUMBER) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK, FINTXN_TAX__TAX_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_TAX__SERVICE_TAX_REGISTRATION_NUMBER,
    first_value(FINTXN_TAX__TAX_APPLICABLE_INDICATOR) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK, FINTXN_TAX__TAX_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_TAX__TAX_APPLICABLE_INDICATOR,
    first_value(FINTXN_TAX__TAX_RATE) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK, FINTXN_TAX__TAX_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_TAX__TAX_RATE,
    first_value(FINTXN_TAX__TDS_SECTION) ignore nulls over (partition by FINANCIAL_TRANSACTION_BK, FINTXN_TAX__TAX_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as FINTXN_TAX__TDS_SECTION,
    LNK_PARTY_ROLE_CORE__ROLE_CODE_CK,
    LNK_PARTY_ROLE_CORE__ROLE_SEQUENCE_CK,
    first_value(LNK_PARTY_ROLE_CORE__ROLE_CODE) ignore nulls over (partition by PARTY_BK, LNK_PARTY_ROLE_CORE__ROLE_CODE_CK, LNK_PARTY_ROLE_CORE__ROLE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_PARTY_ROLE_CORE__ROLE_CODE,
    first_value(LNK_PARTY_ROLE_CORE__ROLE_END_DATE) ignore nulls over (partition by PARTY_BK, LNK_PARTY_ROLE_CORE__ROLE_CODE_CK, LNK_PARTY_ROLE_CORE__ROLE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_PARTY_ROLE_CORE__ROLE_END_DATE,
    first_value(LNK_PARTY_ROLE_CORE__ROLE_TYPE) ignore nulls over (partition by PARTY_BK, LNK_PARTY_ROLE_CORE__ROLE_CODE_CK, LNK_PARTY_ROLE_CORE__ROLE_SEQUENCE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_PARTY_ROLE_CORE__ROLE_TYPE,
    LNK_ROLE_AGENT__ROLE_TYPE_CK,
    first_value(LNK_ROLE_AGENT__AGENCY_TYPE) ignore nulls over (partition by PARTY_BK, LNK_ROLE_AGENT__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_AGENT__AGENCY_TYPE,
    first_value(LNK_ROLE_AGENT__AGENT_CODE) ignore nulls over (partition by PARTY_BK, LNK_ROLE_AGENT__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_AGENT__AGENT_CODE,
    first_value(LNK_ROLE_AGENT__APPOINTMENT_DATE) ignore nulls over (partition by PARTY_BK, LNK_ROLE_AGENT__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_AGENT__APPOINTMENT_DATE,
    first_value(LNK_ROLE_AGENT__IRDAI_AGENT_LICENCE_NUMBER) ignore nulls over (partition by PARTY_BK, LNK_ROLE_AGENT__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_AGENT__IRDAI_AGENT_LICENCE_NUMBER,
    first_value(LNK_ROLE_AGENT__LICENCE_CATEGORY) ignore nulls over (partition by PARTY_BK, LNK_ROLE_AGENT__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_AGENT__LICENCE_CATEGORY,
    first_value(LNK_ROLE_AGENT__LICENCE_EXPIRY_DATE) ignore nulls over (partition by PARTY_BK, LNK_ROLE_AGENT__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_AGENT__LICENCE_EXPIRY_DATE,
    first_value(LNK_ROLE_AGENT__LICENCE_ISSUE_DATE) ignore nulls over (partition by PARTY_BK, LNK_ROLE_AGENT__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_AGENT__LICENCE_ISSUE_DATE,
    first_value(LNK_ROLE_AGENT__POSP_INDICATOR) ignore nulls over (partition by PARTY_BK, LNK_ROLE_AGENT__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_AGENT__POSP_INDICATOR,
    first_value(LNK_ROLE_AGENT__TERMINATION_DATE) ignore nulls over (partition by PARTY_BK, LNK_ROLE_AGENT__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_AGENT__TERMINATION_DATE,
    LNK_ROLE_CUSTOMER__ROLE_TYPE_CK,
    first_value(LNK_ROLE_CUSTOMER__CONSENT_FOR_DATA_SHARING_INDICATOR) ignore nulls over (partition by PARTY_BK, LNK_ROLE_CUSTOMER__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_CUSTOMER__CONSENT_FOR_DATA_SHARING_INDICATOR,
    first_value(LNK_ROLE_CUSTOMER__CUSTOMER_CATEGORY) ignore nulls over (partition by PARTY_BK, LNK_ROLE_CUSTOMER__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_CUSTOMER__CUSTOMER_CATEGORY,
    first_value(LNK_ROLE_CUSTOMER__CUSTOMER_SEGMENT) ignore nulls over (partition by PARTY_BK, LNK_ROLE_CUSTOMER__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_CUSTOMER__CUSTOMER_SEGMENT,
    first_value(LNK_ROLE_CUSTOMER__PREFERRED_CUSTOMER_INDICATOR) ignore nulls over (partition by PARTY_BK, LNK_ROLE_CUSTOMER__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_CUSTOMER__PREFERRED_CUSTOMER_INDICATOR,
    first_value(LNK_ROLE_CUSTOMER__VIP_INDICATOR) ignore nulls over (partition by PARTY_BK, LNK_ROLE_CUSTOMER__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_CUSTOMER__VIP_INDICATOR,
    LNK_ROLE_EMPLOYEE__ROLE_TYPE_CK,
    first_value(LNK_ROLE_EMPLOYEE__ACTIVE_INDICATOR) ignore nulls over (partition by PARTY_BK, LNK_ROLE_EMPLOYEE__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_EMPLOYEE__ACTIVE_INDICATOR,
    first_value(LNK_ROLE_EMPLOYEE__DEPARTMENT) ignore nulls over (partition by PARTY_BK, LNK_ROLE_EMPLOYEE__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_EMPLOYEE__DEPARTMENT,
    first_value(LNK_ROLE_EMPLOYEE__DESIGNATION) ignore nulls over (partition by PARTY_BK, LNK_ROLE_EMPLOYEE__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_EMPLOYEE__DESIGNATION,
    first_value(LNK_ROLE_EMPLOYEE__EMPLOYEE_CODE) ignore nulls over (partition by PARTY_BK, LNK_ROLE_EMPLOYEE__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_EMPLOYEE__EMPLOYEE_CODE,
    first_value(LNK_ROLE_EMPLOYEE__FUNCTION) ignore nulls over (partition by PARTY_BK, LNK_ROLE_EMPLOYEE__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_EMPLOYEE__FUNCTION,
    LNK_ROLE_PROVIDER__ROLE_TYPE_CK,
    first_value(LNK_ROLE_PROVIDER__BED_COUNT) ignore nulls over (partition by PARTY_BK, LNK_ROLE_PROVIDER__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_PROVIDER__BED_COUNT,
    first_value(LNK_ROLE_PROVIDER__EMPANELMENT_STATUS) ignore nulls over (partition by PARTY_BK, LNK_ROLE_PROVIDER__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_PROVIDER__EMPANELMENT_STATUS,
    first_value(LNK_ROLE_PROVIDER__MOU_STATUS) ignore nulls over (partition by PARTY_BK, LNK_ROLE_PROVIDER__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_PROVIDER__MOU_STATUS,
    first_value(LNK_ROLE_PROVIDER__PROVIDER_TYPE) ignore nulls over (partition by PARTY_BK, LNK_ROLE_PROVIDER__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_PROVIDER__PROVIDER_TYPE,
    first_value(LNK_ROLE_PROVIDER__SERVICE_REGION) ignore nulls over (partition by PARTY_BK, LNK_ROLE_PROVIDER__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_PROVIDER__SERVICE_REGION,
    first_value(LNK_ROLE_PROVIDER__SUSPENSION_INDICATOR) ignore nulls over (partition by PARTY_BK, LNK_ROLE_PROVIDER__ROLE_TYPE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as LNK_ROLE_PROVIDER__SUSPENSION_INDICATOR,
    PARTY_AGENT_LICENCE_LINE__LINE_OF_BUSINESS_CK,
    first_value(PARTY_AGENT_LICENCE_LINE__EXAMINATION_REFERENCE) ignore nulls over (partition by PARTY_BK, PARTY_AGENT_LICENCE_LINE__LINE_OF_BUSINESS_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_AGENT_LICENCE_LINE__EXAMINATION_REFERENCE,
    first_value(PARTY_AML_SCREENING__SCREENING_STATUS) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_AML_SCREENING__SCREENING_STATUS,
    PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK,
    first_value(PARTY_BANKING__ACCOUNT_HOLDER_NAME) ignore nulls over (partition by PARTY_BK, PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_BANKING__ACCOUNT_HOLDER_NAME,
    first_value(PARTY_BANKING__ACCOUNT_NUMBER_MASKED) ignore nulls over (partition by PARTY_BK, PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_BANKING__ACCOUNT_NUMBER_MASKED,
    first_value(PARTY_BANKING__ACCOUNT_TYPE) ignore nulls over (partition by PARTY_BK, PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_BANKING__ACCOUNT_TYPE,
    first_value(PARTY_BANKING__BANK_CODE) ignore nulls over (partition by PARTY_BK, PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_BANKING__BANK_CODE,
    first_value(PARTY_BANKING__BANK_NAME) ignore nulls over (partition by PARTY_BK, PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_BANKING__BANK_NAME,
    first_value(PARTY_BANKING__BRANCH_NAME) ignore nulls over (partition by PARTY_BK, PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_BANKING__BRANCH_NAME,
    first_value(PARTY_BANKING__IFSC_CODE) ignore nulls over (partition by PARTY_BK, PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_BANKING__IFSC_CODE,
    first_value(PARTY_BANKING__MICR_CODE) ignore nulls over (partition by PARTY_BK, PARTY_BANKING__ACCOUNT_NUMBER_MASKED_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_BANKING__MICR_CODE,
    first_value(PARTY_EMPLOYMENT__DESIGNATION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_EMPLOYMENT__DESIGNATION,
    first_value(PARTY_EMPLOYMENT__EMPLOYER_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_EMPLOYMENT__EMPLOYER_NAME,
    first_value(PARTY_EMPLOYMENT__EMPLOYMENT_STATUS) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_EMPLOYMENT__EMPLOYMENT_STATUS,
    first_value(PARTY_EMPLOYMENT__OCCUPATION_CODE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_EMPLOYMENT__OCCUPATION_CODE,
    first_value(PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_EMPLOYMENT__OCCUPATION_DESCRIPTION,
    first_value(PARTY_EMPLOYMENT__PROFESSIONAL_REGISTRATION_NUMBER) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_EMPLOYMENT__PROFESSIONAL_REGISTRATION_NUMBER,
    first_value(PARTY_EMPLOYMENT__WORK_NATURE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_EMPLOYMENT__WORK_NATURE,
    first_value(PARTY_FRAUD_PROFILE__NEGATIVE_LIST_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_FRAUD_PROFILE__NEGATIVE_LIST_INDICATOR,
    first_value(PARTY_FRAUD_PROFILE__NEGATIVE_LIST_REASON) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_FRAUD_PROFILE__NEGATIVE_LIST_REASON,
    first_value(PARTY_FRAUD_PROFILE__WATCH_START_DATE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_FRAUD_PROFILE__WATCH_START_DATE,
    first_value(PARTY_HEALTH_PROFILE__ALCOHOL_UNITS_PER_WEEK) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_HEALTH_PROFILE__ALCOHOL_UNITS_PER_WEEK,
    first_value(PARTY_HEALTH_PROFILE__BODY_MASS_INDEX) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_HEALTH_PROFILE__BODY_MASS_INDEX,
    first_value(PARTY_HEALTH_PROFILE__CIGARETTES_PER_DAY) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_HEALTH_PROFILE__CIGARETTES_PER_DAY,
    first_value(PARTY_HEALTH_PROFILE__CURRENT_MEDICATION_DETAIL) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_HEALTH_PROFILE__CURRENT_MEDICATION_DETAIL,
    first_value(PARTY_HEALTH_PROFILE__DISABILITY_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_HEALTH_PROFILE__DISABILITY_INDICATOR,
    first_value(PARTY_HEALTH_PROFILE__DISABILITY_PERCENTAGE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_HEALTH_PROFILE__DISABILITY_PERCENTAGE,
    first_value(PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_HEALTH_PROFILE__FAMILY_MEDICAL_HISTORY_INDICATOR,
    first_value(PARTY_HEALTH_PROFILE__HEIGHT) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_HEALTH_PROFILE__HEIGHT,
    first_value(PARTY_HEALTH_PROFILE__LIFESTYLE_RISK_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_HEALTH_PROFILE__LIFESTYLE_RISK_INDICATOR,
    first_value(PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_HEALTH_PROFILE__PRE_EXISTING_DISEASE_DESCRIPTION,
    first_value(PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_HEALTH_PROFILE__TOBACCO_CONSUMPTION_DETAIL,
    first_value(PARTY_HEALTH_PROFILE__WEIGHT) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_HEALTH_PROFILE__WEIGHT,
    first_value(PARTY_HIERARCHY__HIERARCHY_LEVEL) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_HIERARCHY__HIERARCHY_LEVEL,
    PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK,
    first_value(PARTY_IDENTIFICATION__AADHAAR_NUMBER) ignore nulls over (partition by PARTY_BK, PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTIFICATION__AADHAAR_NUMBER,
    first_value(PARTY_IDENTIFICATION__AADHAAR_VERIFICATION_STATUS) ignore nulls over (partition by PARTY_BK, PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTIFICATION__AADHAAR_VERIFICATION_STATUS,
    first_value(PARTY_IDENTIFICATION__AGE_PROOF_TYPE) ignore nulls over (partition by PARTY_BK, PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTIFICATION__AGE_PROOF_TYPE,
    first_value(PARTY_IDENTIFICATION__CIN_NUMBER) ignore nulls over (partition by PARTY_BK, PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTIFICATION__CIN_NUMBER,
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
    first_value(PARTY_IDENTIFICATION__NREGA_CARD_NUMBER) ignore nulls over (partition by PARTY_BK, PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTIFICATION__NREGA_CARD_NUMBER,
    first_value(PARTY_IDENTIFICATION__OVD_CATEGORY) ignore nulls over (partition by PARTY_BK, PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTIFICATION__OVD_CATEGORY,
    first_value(PARTY_IDENTIFICATION__PAN_NUMBER) ignore nulls over (partition by PARTY_BK, PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTIFICATION__PAN_NUMBER,
    first_value(PARTY_IDENTIFICATION__PAN_VERIFICATION_STATUS) ignore nulls over (partition by PARTY_BK, PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTIFICATION__PAN_VERIFICATION_STATUS,
    first_value(PARTY_IDENTIFICATION__PASSPORT_NUMBER) ignore nulls over (partition by PARTY_BK, PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTIFICATION__PASSPORT_NUMBER,
    first_value(PARTY_IDENTIFICATION__TAN_NUMBER) ignore nulls over (partition by PARTY_BK, PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTIFICATION__TAN_NUMBER,
    first_value(PARTY_IDENTIFICATION__VOTER_ID_NUMBER) ignore nulls over (partition by PARTY_BK, PARTY_IDENTIFICATION__IDENTIFICATION_TYPE_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_IDENTIFICATION__VOTER_ID_NUMBER,
    first_value(PARTY_INDIVIDUAL_DEMOGRAPHICS__ANNUAL_HOUSEHOLD_INCOME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_INDIVIDUAL_DEMOGRAPHICS__ANNUAL_HOUSEHOLD_INCOME,
    first_value(PARTY_INDIVIDUAL_DEMOGRAPHICS__EDUCATIONAL_QUALIFICATION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_INDIVIDUAL_DEMOGRAPHICS__EDUCATIONAL_QUALIFICATION,
    first_value(PARTY_INDIVIDUAL_DEMOGRAPHICS__EMPLOYMENT_TYPE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_INDIVIDUAL_DEMOGRAPHICS__EMPLOYMENT_TYPE,
    first_value(PARTY_INDIVIDUAL_DEMOGRAPHICS__FATHER_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_INDIVIDUAL_DEMOGRAPHICS__FATHER_NAME,
    first_value(PARTY_INDIVIDUAL_DEMOGRAPHICS__HIGHEST_DEGREE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_INDIVIDUAL_DEMOGRAPHICS__HIGHEST_DEGREE,
    first_value(PARTY_INDIVIDUAL_DEMOGRAPHICS__MARITAL_STATUS) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_INDIVIDUAL_DEMOGRAPHICS__MARITAL_STATUS,
    first_value(PARTY_INDIVIDUAL_DEMOGRAPHICS__SPOUSE_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_INDIVIDUAL_DEMOGRAPHICS__SPOUSE_NAME,
    first_value(PARTY_INDIVIDUAL_DEMOGRAPHICS__VEHICLE_OWNED_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_INDIVIDUAL_DEMOGRAPHICS__VEHICLE_OWNED_INDICATOR,
    first_value(PARTY_INDIVIDUAL_DEMOGRAPHICS__YEARS_IN_CITY) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_INDIVIDUAL_DEMOGRAPHICS__YEARS_IN_CITY,
    first_value(PARTY_KYC__CKYC_NUMBER) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_KYC__CKYC_NUMBER,
    first_value(PARTY_KYC__CKYC_REGISTRATION_STATUS) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_KYC__CKYC_REGISTRATION_STATUS,
    first_value(PARTY_KYC__KYC_COMPLETED_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_KYC__KYC_COMPLETED_INDICATOR,
    first_value(PARTY_KYC__KYC_WAIVER_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_KYC__KYC_WAIVER_INDICATOR,
    first_value(PARTY_LEGAL_PANEL__ADVOCATE_TYPE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_LEGAL_PANEL__ADVOCATE_TYPE,
    first_value(PARTY_LEGAL_PANEL__AGREEMENT_STATUS) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_LEGAL_PANEL__AGREEMENT_STATUS,
    first_value(PARTY_LEGAL_PANEL__BAR_COUNCIL_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_LEGAL_PANEL__BAR_COUNCIL_NAME,
    first_value(PARTY_LEGAL_PANEL__BAR_ENROLMENT_NUMBER) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_LEGAL_PANEL__BAR_ENROLMENT_NUMBER,
    first_value(PARTY_LEGAL_PANEL__CASES_HANDLED_COUNT) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_LEGAL_PANEL__CASES_HANDLED_COUNT,
    first_value(PARTY_LEGAL_PANEL__EMPANELMENT_DATE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_LEGAL_PANEL__EMPANELMENT_DATE,
    first_value(PARTY_LEGAL_PANEL__JUNIORS_COUNT) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_LEGAL_PANEL__JUNIORS_COUNT,
    first_value(PARTY_LEGAL_PANEL__PANEL_CATEGORY) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_LEGAL_PANEL__PANEL_CATEGORY,
    first_value(PARTY_LEGAL_PANEL__YEARS_OF_PRACTICE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_LEGAL_PANEL__YEARS_OF_PRACTICE,
    first_value(PARTY_ORGANISATION_PROFILE__ANNUAL_TURNOVER) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_ORGANISATION_PROFILE__ANNUAL_TURNOVER,
    first_value(PARTY_ORGANISATION_PROFILE__BUSINESS_REGISTRATION_NUMBER) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_ORGANISATION_PROFILE__BUSINESS_REGISTRATION_NUMBER,
    first_value(PARTY_ORGANISATION_PROFILE__DATE_OF_INCORPORATION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_ORGANISATION_PROFILE__DATE_OF_INCORPORATION,
    first_value(PARTY_ORGANISATION_PROFILE__GROUP_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_ORGANISATION_PROFILE__GROUP_NAME,
    first_value(PARTY_ORGANISATION_PROFILE__INDUSTRY_CODE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_ORGANISATION_PROFILE__INDUSTRY_CODE,
    first_value(PARTY_ORGANISATION_PROFILE__INDUSTRY_DESCRIPTION) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_ORGANISATION_PROFILE__INDUSTRY_DESCRIPTION,
    first_value(PARTY_ORGANISATION_PROFILE__LEGAL_CONSTITUTION_TYPE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_ORGANISATION_PROFILE__LEGAL_CONSTITUTION_TYPE,
    first_value(PARTY_ORGANISATION_PROFILE__MSME_CATEGORY) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_ORGANISATION_PROFILE__MSME_CATEGORY,
    first_value(PARTY_ORGANISATION_PROFILE__MSME_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_ORGANISATION_PROFILE__MSME_INDICATOR,
    first_value(PARTY_ORGANISATION_PROFILE__NATURE_OF_BUSINESS) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_ORGANISATION_PROFILE__NATURE_OF_BUSINESS,
    first_value(PARTY_ORGANISATION_PROFILE__NIC_CODE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_ORGANISATION_PROFILE__NIC_CODE,
    first_value(PARTY_ORGANISATION_PROFILE__PAID_UP_CAPITAL) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_ORGANISATION_PROFILE__PAID_UP_CAPITAL,
    first_value(PARTY_ORGANISATION_PROFILE__PARENT_ENTITY_NAME) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_ORGANISATION_PROFILE__PARENT_ENTITY_NAME,
    PARTY_ORG_DIRECTORS__DIN_NUMBER_CK,
    first_value(PARTY_ORG_DIRECTORS__DIRECTOR_NAME) ignore nulls over (partition by PARTY_BK, PARTY_ORG_DIRECTORS__DIN_NUMBER_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_ORG_DIRECTORS__DIRECTOR_NAME,
    first_value(PARTY_PAYOUT_PROFILE__GST_APPLICABLE_INDICATOR) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_PAYOUT_PROFILE__GST_APPLICABLE_INDICATOR,
    first_value(PARTY_PAYOUT_PROFILE__TDS_RATE) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_PAYOUT_PROFILE__TDS_RATE,
    PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK,
    first_value(PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR) ignore nulls over (partition by PARTY_BK, PARTY_PROVIDER_CAPABILITY__FACILITY_CODE_CK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PARTY_PROVIDER_CAPABILITY__AVAILABLE_INDICATOR,
    first_value(PROVIDER_QUALITY__QUALITY_RATING) ignore nulls over (partition by PARTY_BK order by __PREC, __RID rows between unbounded preceding and unbounded following) as PROVIDER_QUALITY__QUALITY_RATING
from merged
