{{ config(materialized='view') }}

-- MAXIMUS PARTNER wide stage() for BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW.
-- 8 key(s), 40 single-active satellite(s).

{%- set yaml_metadata -%}
source_model: 'stg_maximus__pd_prop_sp_pv'
hashed_columns:
  DISTRIBUTION_CHANNEL_HKEY: 'DISTRIBUTION_CHANNEL_NK'
  LOCATION_HKEY: 'LOCATION_NK'
  ORG_UNIT_HKEY: 'ORG_UNIT_NK'
  PARTY_HKEY: 'PARTY_NK'
  POLICY_HKEY: 'POLICY_NK'
  PRODUCT_HKEY: 'PRODUCT_NK'
  PARTY_LOCATION_HKEY: 'PARTY_LOCATION_NK'
  PARTY_ROLE_HKEY: 'PARTY_ROLE_NK'
  HASHDIFF_CHANNEL_DEFINITION:
    is_hashdiff: true
    columns:
      - 'SUB_CHANNEL_CODE'
      - 'SUB_CHANNEL_EFFECTIVE_DATE'
  HASHDIFF_COMMON_ADDRESS:
    is_hashdiff: true
    columns:
      - 'ADDRESS_LINE_1'
      - 'ADDRESS_LINE_2'
      - 'ADDRESS_LINE_3'
      - 'CARE_OF_NAME'
      - 'CITY'
      - 'COUNTRY_NAME'
      - 'DISTRICT'
      - 'LANDMARK'
      - 'LOCALITY'
      - 'POSTAL_CODE'
      - 'POST_OFFICE_NAME'
      - 'STATE_NAME'
  HASHDIFF_COMMON_ADMIN_GEOGRAPHY:
    is_hashdiff: true
    columns:
      - 'CITYCLASSCODE'
  HASHDIFF_COMMON_CLASSIFICATION:
    is_hashdiff: true
    columns:
      - 'CATEGORY_CODE'
      - 'TIER_CODE'
  HASHDIFF_COMMON_COMMUNICATION_PREFERENCE:
    is_hashdiff: true
    columns:
      - 'CORRESPONDENCE_LANGUAGE'
      - 'GO_GREEN_OPT_IN_INDICATOR'
      - 'PREFERRED_CHANNEL_CODE'
      - 'PREFERRED_LANGUAGE_CODE'
  HASHDIFF_COMMON_CONSENT:
    is_hashdiff: true
    columns:
      - 'CONSENT_GIVEN_INDICATOR'
  HASHDIFF_COMMON_CONTACT:
    is_hashdiff: true
    columns:
      - 'ALTERNATE_EMAIL_ADDRESS'
      - 'ALTERNATE_MOBILE_NUMBER'
      - 'EMAIL_ADDRESS'
      - 'FAX_NUMBER'
      - 'LANDLINE_NUMBER'
      - 'MOBILE_NUMBER'
      - 'SOCIALMEDIAHANDLE'
      - 'STD_CODE'
  HASHDIFF_COMMON_GEO:
    is_hashdiff: true
    columns:
      - 'LATITUDE'
      - 'LONGITUDE'
      - 'REGIONCODE'
      - 'REGION_NAME'
  HASHDIFF_LNK_ROLE_AGENT:
    is_hashdiff: true
    columns:
      - 'AGENTCODE'
      - 'LICENCECATEGORY'
      - 'LICENCEEXPIRYDATE'
      - 'LICENCEISSUEDATE'
  HASHDIFF_LNK_ROLE_CUSTOMER:
    is_hashdiff: true
    columns:
      - 'CONSENTFORDATASHARINGINDICATOR'
      - 'PREFERREDCUSTOMERINDICATOR'
  HASHDIFF_LNK_ROLE_EMPLOYEE:
    is_hashdiff: true
    columns:
      - 'DEPARTMENT'
      - 'EMPLOYEE_CODE'
      - 'FUNCTION'
  HASHDIFF_LNK_ROLE_INVESTIGATOR:
    is_hashdiff: true
    columns:
      - 'SPECIALISATIONAREA'
  HASHDIFF_LNK_ROLE_NOMINEE_BENEFICIARY:
    is_hashdiff: true
    columns:
      - 'RELATIONSHIP_TO_INSURED'
  HASHDIFF_LNK_ROLE_PROVIDER:
    is_hashdiff: true
    columns:
      - 'DEEMPANELMENTDATE'
      - 'DELISTINGDATE'
      - 'DELISTINGINDICATOR'
      - 'EMPANELMENT_DATE'
      - 'EVALUATIONDATE'
      - 'ICUNURSECOUNT'
      - 'MOUREFERENCE'
      - 'MOU_STATUS'
      - 'NABHACCREDITEDINDICATOR'
      - 'NURSETOBEDRATIO'
      - 'NURSE_TO_PATIENT_RATIO'
      - 'PROVIDERCATEGORY'
      - 'PROVIDER_CODE'
      - 'PROVIDER_TYPE'
      - 'SERVICESCOPEDESCRIPTION'
      - 'SPECIALISATION'
  HASHDIFF_LNK_ROLE_SURVEYOR:
    is_hashdiff: true
    columns:
      - 'DEPARTMENTAUTHORISED'
      - 'IRDAI_SURVEYOR_LICENCE_NUMBER'
      - 'LICENCE_CATEGORY'
  HASHDIFF_LOCATION_PROFILE:
    is_hashdiff: true
    columns:
      - 'LOCATION_NAME'
      - 'LOCATIONTYPE'
  HASHDIFF_ORG_UNIT_DEFINITION:
    is_hashdiff: true
    columns:
      - 'BRANCH_TYPE'
      - 'ORG_UNIT_NAME'
  HASHDIFF_ORG_UNIT_LICENCE:
    is_hashdiff: true
    columns:
      - 'GST_REGISTRATION_NUMBER'
  HASHDIFF_PARTY_AGENT_LICENCE_LINE:
    is_hashdiff: true
    columns:
      - 'AUTHORISEDINDICATOR'
      - 'EXAMINATION_REFERENCE'
  HASHDIFF_PARTY_AML_SCREENING:
    is_hashdiff: true
    columns:
      - 'SCREENING_STATUS'
  HASHDIFF_PARTY_BANKING:
    is_hashdiff: true
    columns:
      - 'ACCOUNT_HOLDER_NAME'
      - 'ACCOUNT_NUMBER_MASKED'
      - 'ACCOUNT_TYPE'
      - 'BANK_NAME'
      - 'BRANCH_NAME'
      - 'IFSC_CODE'
      - 'MICR_CODE'
      - 'PENNYDROPVERIFIEDINDICATOR'
      - 'PRIMARYACCOUNTINDICATOR'
  HASHDIFF_PARTY_CONSENT_MANDATE:
    is_hashdiff: true
    columns:
      - 'BANKREFERENCE'
      - 'FREQUENCY'
      - 'MANDATEREFERENCE'
      - 'MANDATESTARTDATE'
      - 'MANDATE_TYPE'
      - 'MAXIMUMAMOUNT'
  HASHDIFF_PARTY_EMPLOYMENT:
    is_hashdiff: true
    columns:
      - 'EMPLOYER_NAME'
      - 'EMPLOYMENT_STATUS'
  HASHDIFF_PARTY_FINANCIAL_PROFILE:
    is_hashdiff: true
    columns:
      - 'INCOME_SOURCE'
  HASHDIFF_PARTY_FRAUD_PROFILE:
    is_hashdiff: true
    columns:
      - 'FRAUD_SUSPICION_INDICATOR'
      - 'NEGATIVE_LIST_INDICATOR'
      - 'NEGATIVE_LIST_REASON'
      - 'WATCHENDDATE'
      - 'WATCH_START_DATE'
  HASHDIFF_PARTY_HEALTH_PROFILE:
    is_hashdiff: true
    columns:
      - 'DISABILITY_INDICATOR'
      - 'DISABILITY_PERCENTAGE'
      - 'HEIGHT'
      - 'PRE_EXISTING_DISEASE_DESCRIPTION'
      - 'WEIGHT'
  HASHDIFF_PARTY_HIERARCHY:
    is_hashdiff: true
    columns:
      - 'HIERARCHY_LEVEL'
      - 'REPORTING_PARENT_REFERENCE'
  HASHDIFF_PARTY_IDENTIFICATION:
    is_hashdiff: true
    columns:
      - 'AADHAAR_NUMBER'
      - 'AADHAAR_VERIFICATION_STATUS'
      - 'AGE_PROOF_TYPE'
      - 'CIN_NUMBER'
      - 'DRIVING_LICENCE_EXPIRY_DATE'
      - 'DRIVING_LICENCE_NUMBER'
      - 'EIA_NUMBER'
      - 'FORM60INDICATOR'
      - 'GSTIN'
      - 'GST_REGISTRATION_STATUS'
      - 'GST_TAXPAYER_TYPE'
      - 'IDENTIFICATION_EXPIRY_DATE'
      - 'IDENTIFICATION_ISSUE_DATE'
      - 'IDENTIFICATION_ISSUING_AUTHORITY'
      - 'IDENTIFICATION_NUMBER'
      - 'IDENTIFICATION_TYPE_CODE'
      - 'IDENTIFICATION_VERIFIED_INDICATOR'
      - 'INSURANCEREPOSITORYNAME'
      - 'NREGA_CARD_NUMBER'
      - 'OVD_CATEGORY'
      - 'PAN_NUMBER'
      - 'PAN_VERIFICATION_STATUS'
      - 'PASSPORTEXPIRYDATE'
      - 'PASSPORT_NUMBER'
      - 'TAN_NUMBER'
      - 'VOTER_ID_NUMBER'
  HASHDIFF_PARTY_IDENTITY:
    is_hashdiff: true
    columns:
      - 'AGE'
      - 'COUNTRY_OF_BIRTH'
      - 'COUNTRY_OF_RESIDENCE'
      - 'DATE_OF_BIRTH'
      - 'DATE_OF_DEATH'
      - 'FIRST_NAME'
      - 'GENDER_CODE'
      - 'LAST_NAME'
      - 'MIDDLE_NAME'
      - 'NATIONALITY'
      - 'PARTY_FULL_NAME'
      - 'PARTY_LEGAL_NAME'
      - 'PARTY_ORIGINATION_DATE'
      - 'PARTY_STATUS'
      - 'PARTY_SUB_TYPE_CODE'
      - 'PARTY_TYPE_CODE'
      - 'SALUTATION'
  HASHDIFF_PARTY_INDIVIDUAL_DEMOGRAPHICS:
    is_hashdiff: true
    columns:
      - 'ANNUAL_INCOME'
      - 'DESIGNATION'
      - 'EDUCATIONAL_QUALIFICATION'
      - 'FATHER_NAME'
      - 'HIGHEST_DEGREE'
      - 'MARITAL_STATUS'
      - 'OCCUPATIONCODE'
      - 'OCCUPATION_DESCRIPTION'
      - 'SPOUSE_NAME'
      - 'VEHICLE_OWNED_INDICATOR'
      - 'YEARS_IN_CITY'
  HASHDIFF_PARTY_KYC:
    is_hashdiff: true
    columns:
      - 'CKYC_NUMBER'
      - 'CKYC_REGISTRATION_STATUS'
  HASHDIFF_PARTY_LEGAL_PANEL:
    is_hashdiff: true
    columns:
      - 'ADVOCATE_TYPE'
      - 'BAR_COUNCIL_NAME'
      - 'BAR_ENROLMENT_NUMBER'
      - 'JUNIORS_COUNT'
      - 'PANEL_CATEGORY'
      - 'PENDINGCASESCOUNT'
  HASHDIFF_PARTY_ONBOARDING_JOURNEY:
    is_hashdiff: true
    columns:
      - 'ONBOARDING_START_DATE'
      - 'PREVIOUS_EMPLOYER_NAME'
      - 'PRIOR_WORK_EXPERIENCE_YEARS'
  HASHDIFF_PARTY_ORGANISATION_PROFILE:
    is_hashdiff: true
    columns:
      - 'ANNUAL_TURNOVER'
      - 'BUSINESS_REGISTRATION_NUMBER'
      - 'DATE_OF_INCORPORATION'
      - 'GROUP_NAME'
      - 'INDUSTRY_CODE'
      - 'INDUSTRY_DESCRIPTION'
      - 'LEGAL_CONSTITUTION_TYPE'
      - 'MSME_CATEGORY'
      - 'MSME_INDICATOR'
      - 'NATURE_OF_BUSINESS'
      - 'NUMBEROFEMPLOYEES'
      - 'PAID_UP_CAPITAL'
      - 'PARENT_ENTITY_NAME'
  HASHDIFF_PARTY_PAYOUT_PROFILE:
    is_hashdiff: true
    columns:
      - 'GST_APPLICABLE_INDICATOR'
      - 'PAYOUTHOLDREASON'
      - 'TDSAPPLICABLEINDICATOR'
      - 'TDS_RATE'
  HASHDIFF_PARTY_RELATIONSHIP_PROFILE:
    is_hashdiff: true
    columns:
      - 'REFERREDBYREFERENCE'
  HASHDIFF_PRODUCT_DEFINITION:
    is_hashdiff: true
    columns:
      - 'PRODUCT_DESCRIPTION'
  HASHDIFF_PROVIDER_BANKING:
    is_hashdiff: true
    columns:
      - 'CREDITPERIOD'
  HASHDIFF_PROVIDER_QUALITY:
    is_hashdiff: true
    columns:
      - 'AVERAGECLAIMAMOUNT'
      - 'CLAIMVOLUME'
      - 'QUALITY_RATING'
  HASHDIFF_PROVIDER_TARIFF:
    is_hashdiff: true
    columns:
      - 'DISCOUNT_PERCENTAGE'
      - 'EFFECTIVE_DATE'
      - 'EXPIRY_DATE'
      - 'NEGOTIATEDINDICATOR'
      - 'PACKAGE_RATE'
      - 'ROOMCATEGORY'
      - 'SERVICE_DESCRIPTION'
      - 'TARIFF_RATE'
      - 'TARIFFTIER'
derived_columns:
  DISTRIBUTION_CHANNEL_BK: "agent_channel"
  DISTRIBUTION_CHANNEL_NK: "'HUB_DISTRIBUTION_CHANNEL|' || (agent_channel)"
  LOCATION_BK: "case when coalesce(upper(trim(to_varchar(our_office_address))), upper(trim(to_varchar(current_permanent_overseas_address_line_2))), upper(trim(to_varchar(current_permanent_overseas_address_line_3))), upper(trim(to_varchar(current_permanent_overseas_address_city_town_village))), upper(trim(to_varchar(correspondence_local_address_district))), upper(trim(to_varchar(current_permanent_overseas_address_state_ut))), upper(trim(to_varchar(local_address_pin_code))), upper(trim(to_varchar(current_permanent_overseas_address_country)))) is null then null else md5(concat_ws('|', coalesce(upper(trim(to_varchar(our_office_address))), ''), coalesce(upper(trim(to_varchar(current_permanent_overseas_address_line_2))), ''), coalesce(upper(trim(to_varchar(current_permanent_overseas_address_line_3))), ''), coalesce(upper(trim(to_varchar(current_permanent_overseas_address_city_town_village))), ''), coalesce(upper(trim(to_varchar(correspondence_local_address_district))), ''), coalesce(upper(trim(to_varchar(current_permanent_overseas_address_state_ut))), ''), coalesce(upper(trim(to_varchar(local_address_pin_code))), ''), coalesce(upper(trim(to_varchar(current_permanent_overseas_address_country))), ''))) end"
  LOCATION_NK: "'HUB_LOCATION|' || (case when coalesce(upper(trim(to_varchar(our_office_address))), upper(trim(to_varchar(current_permanent_overseas_address_line_2))), upper(trim(to_varchar(current_permanent_overseas_address_line_3))), upper(trim(to_varchar(current_permanent_overseas_address_city_town_village))), upper(trim(to_varchar(correspondence_local_address_district))), upper(trim(to_varchar(current_permanent_overseas_address_state_ut))), upper(trim(to_varchar(local_address_pin_code))), upper(trim(to_varchar(current_permanent_overseas_address_country)))) is null then null else md5(concat_ws('|', coalesce(upper(trim(to_varchar(our_office_address))), ''), coalesce(upper(trim(to_varchar(current_permanent_overseas_address_line_2))), ''), coalesce(upper(trim(to_varchar(current_permanent_overseas_address_line_3))), ''), coalesce(upper(trim(to_varchar(current_permanent_overseas_address_city_town_village))), ''), coalesce(upper(trim(to_varchar(correspondence_local_address_district))), ''), coalesce(upper(trim(to_varchar(current_permanent_overseas_address_state_ut))), ''), coalesce(upper(trim(to_varchar(local_address_pin_code))), ''), coalesce(upper(trim(to_varchar(current_permanent_overseas_address_country))), ''))) end)"
  ORG_UNIT_BK: "branch_code"
  ORG_UNIT_NK: "'HUB_ORG_UNIT|' || (branch_code)"
  PARTY_BK: "bagic_employee_code"
  PARTY_NK: "'HUB_PARTY|' || (bagic_employee_code)"
  POLICY_BK: "pa_policy"
  POLICY_NK: "'HUB_POLICY|' || (pa_policy)"
  PRODUCT_BK: "product_code"
  PRODUCT_NK: "'HUB_PRODUCT|' || (product_code)"
  PARTY_LOCATION_BK: "foreign_key"
  PARTY_LOCATION_NK: "'LNK_PARTY_LOCATION|' || (foreign_key)"
  PARTY_ROLE_BK: "foreign_key"
  PARTY_ROLE_NK: "'LNK_PARTY_ROLE|' || (foreign_key)"
  SUB_CHANNEL_CODE: "sub_channel"
  SUB_CHANNEL_EFFECTIVE_DATE: "sub_channel_effective_date"
  CARE_OF_NAME: "addressee"
  CITY: "coalesce(correspondence_local_address_city_town_village, current_permanent_overseas_address_city_town_village)"
  COUNTRY_NAME: "coalesce(correspondence_local_address_country, country, current_permanent_overseas_address_country)"
  DISTRICT: "correspondence_local_address_district"
  ADDRESS_LINE_1: "coalesce(correspondence_local_address_line_1, current_permanent_overseas_address_line_1, our_office_address)"
  ADDRESS_LINE_2: "coalesce(correspondence_local_address_line_2, current_permanent_overseas_address_line_2)"
  ADDRESS_LINE_3: "coalesce(correspondence_local_address_line_3, current_permanent_overseas_address_line_3)"
  STATE_NAME: "coalesce(correspondence_local_address_state, current_permanent_overseas_address_state_ut)"
  POSTAL_CODE: "coalesce(current_permanent_overseas_address_pin_code, local_address_pin_code)"
  POST_OFFICE_NAME: "cast(null as varchar)"
  LOCALITY: "cast(null as varchar)"
  LANDMARK: "cast(null as varchar)"
  CITYCLASSCODE: "city_class"
  CATEGORY_CODE: "category"
  TIER_CODE: "tier_level"
  CORRESPONDENCE_LANGUAGE: "communication_and_preferred_language"
  GO_GREEN_OPT_IN_INDICATOR: "epolicy_required"
  PREFERRED_LANGUAGE_CODE: "party_language"
  PREFERRED_CHANNEL_CODE: "preferred_mode_of_communication"
  CONSENT_GIVEN_INDICATOR: "customer_consent"
  EMAIL_ADDRESS: "coalesce(administrator_email_id, billing_persons_email_id, ceo_email_id, finance_officer_email_id, marketing_head_email_id, medical_director_email_id, medical_superintendent_email_id)"
  MOBILE_NUMBER: "coalesce(administrator_mobile_no, billing_persons_mobile_no, ceo_mobile_no, claim_mobile_number, contact_person_mobile_no_1, contact_person_mobile_no_2, finance_officer_mobile_number, marketing_head_mobile_no, medical_director_mobile_no, medical_superintendent_mobile_no, registered_mobile_number)"
  ALTERNATE_MOBILE_NUMBER: "alternate_mob_numberlandline_number"
  LANDLINE_NUMBER: "coalesce(company_contact, emergency_phone_number_val, landline_no, phone_detailsdfadvocate, phone_detailshcadvocate, phone_detailslawyer, phone_detailsretainer, phone_detailsstadvocate, phone_detailstradvocate, phone_no_1, phone_no_2)"
  STD_CODE: "std_code"
  SOCIALMEDIAHANDLE: "cast(null as varchar)"
  FAX_NUMBER: "cast(null as varchar)"
  ALTERNATE_EMAIL_ADDRESS: "cast(null as varchar)"
  REGION_NAME: "area"
  LATITUDE: "latitude"
  LONGITUDE: "longitude"
  REGIONCODE: "region"
  AGENTCODE: "irda_code"
  LICENCEEXPIRYDATE: "license_expiry_date"
  LICENCEISSUEDATE: "license_issue_date"
  LICENCECATEGORY: "sur_license_type"
  LICENCE_CATEGORY: "sur_license_type"
  CONSENTFORDATASHARINGINDICATOR: "customer_consent_for_data_sharing"
  PREFERREDCUSTOMERINDICATOR: "priority_customer"
  DEPARTMENT: "department"
  EMPLOYEE_CODE: "employee_code"
  FUNCTION: "function"
  SPECIALISATIONAREA: "investigation_skills"
  RELATIONSHIP_TO_INSURED: "nominee_relationship"
  DEEMPANELMENTDATE: "deempanel_date"
  DELISTINGINDICATOR: "delisted"
  DELISTINGDATE: "delisted_date"
  EMPANELMENT_DATE: "empanel_date"
  EVALUATIONDATE: "evaluation_date"
  SPECIALISATION: "medical_speciality"
  MOUREFERENCE: "mou_documents"
  MOU_STATUS: "mou_status"
  NABHACCREDITEDINDICATOR: "nabh_certified"
  ICUNURSECOUNT: "no_of_qualified_nurses_available_exclusively_in_icu_taking_all_the_shifts_together"
  NURSETOBEDRATIO: "nursebed_ratio_no_of_qualified_and_registered_nurses_gnm_post_bsc_bsc_msc_nursing_as_proportion_of_occupied_beds"
  PROVIDERCATEGORY: "provider_category"
  SERVICESCOPEDESCRIPTION: "scope_of_supplier"
  NURSE_TO_PATIENT_RATIO: "span_of_control_nurse_to_patient"
  PROVIDER_CODE: "supplier_id"
  PROVIDER_TYPE: "type_of_provider"
  DEPARTMENTAUTHORISED: "surveyor_department"
  IRDAI_SURVEYOR_LICENCE_NUMBER: "sur_license_no"
  LOCATION_NAME: "location"
  LOCATIONTYPE: "cast(null as varchar)"
  ORG_UNIT_NAME: "branch_name"
  BRANCH_TYPE: "branch_type"
  GST_REGISTRATION_NUMBER: "bagic_gstin"
  EXAMINATION_REFERENCE: "examinations_details_for_irda_code"
  AUTHORISEDINDICATOR: "cast(null as varchar)"
  SCREENING_STATUS: "aml_verification_status"
  ACCOUNT_TYPE: "account_category_code"
  ACCOUNT_NUMBER_MASKED: "coalesce(account_no, owner_acct)"
  BANK_NAME: "cast(null as varchar)"
  BRANCH_NAME: "cast(null as varchar)"
  PENNYDROPVERIFIEDINDICATOR: "cast(null as varchar)"
  ACCOUNT_HOLDER_NAME: "cast(null as varchar)"
  PRIMARYACCOUNTINDICATOR: "cast(null as varchar)"
  MICR_CODE: "cast(null as varchar)"
  IFSC_CODE: "cast(null as varchar)"
  FREQUENCY: "frequency"
  BANKREFERENCE: "cast(null as varchar)"
  MANDATE_TYPE: "cast(null as varchar)"
  MAXIMUMAMOUNT: "cast(null as varchar)"
  MANDATEREFERENCE: "cast(null as varchar)"
  MANDATESTARTDATE: "cast(null as varchar)"
  EMPLOYMENT_STATUS: "employee_status"
  EMPLOYER_NAME: "employer_name"
  INCOME_SOURCE: "income_source"
  NEGATIVE_LIST_INDICATOR: "blacklisted"
  WATCH_START_DATE: "blacklisted_effective_date"
  WATCHENDDATE: "blacklisted_expiry_date"
  NEGATIVE_LIST_REASON: "blacklist_details"
  FRAUD_SUSPICION_INDICATOR: "suspected_fraud"
  DISABILITY_PERCENTAGE: "disability_percentage"
  PRE_EXISTING_DISEASE_DESCRIPTION: "disease_name"
  HEIGHT: "height"
  DISABILITY_INDICATOR: "physically_challenged"
  WEIGHT: "weight"
  HIERARCHY_LEVEL: "level"
  REPORTING_PARENT_REFERENCE: "parent_party_code"
  IDENTIFICATION_NUMBER: "coalesce(aadhaar_enrollment_no, abha_id, existing_partner_id, hospital_id, identifier, id_number, partner_ref, registration_no, sepz_registration_no, sez_registration_no, service_tax_no, rohini_code, vid)"
  AADHAAR_NUMBER: "aadhaar_number"
  IDENTIFICATION_ISSUE_DATE: "coalesce(address_proof_effective_date, driving_license_issue_date, gstin_issuance_dt, identification_proof_effective_date, passport_issue_date, sepz_registration_date, sez_registration_date)"
  CIN_NUMBER: "cin_number"
  IDENTIFICATION_VERIFIED_INDICATOR: "coalesce(claim_poa_status, claim_poi_status, e_insurance_demat_account_verified, poa_driving_license_status, poa_nrega_job_card_status, poa_passport_status)"
  GST_TAXPAYER_TYPE: "taxpayer_type"
  IDENTIFICATION_EXPIRY_DATE: "coalesce(date_of_expiry, expiry_date, sez_expiry_date)"
  AGE_PROOF_TYPE: "dob_proof"
  DRIVING_LICENCE_EXPIRY_DATE: "driving_license_expiry_date"
  DRIVING_LICENCE_NUMBER: "driving_license_number"
  IDENTIFICATION_ISSUING_AUTHORITY: "driving_license_place_of_issue"
  EIA_NUMBER: "eia_number"
  GSTIN: "gstinuin"
  GST_REGISTRATION_STATUS: "gstn_regn_status"
  IDENTIFICATION_TYPE_CODE: "coalesce(identification_proof, id_type, id_type1)"
  INSURANCEREPOSITORYNAME: "insurance_repository_code"
  PAN_NUMBER: "pan_no"
  NREGA_CARD_NUMBER: "nrega_job_card"
  PASSPORTEXPIRYDATE: "passport_expiry_date"
  PASSPORT_NUMBER: "passport_number"
  AADHAAR_VERIFICATION_STATUS: "poa_aadhar_card_status"
  PAN_VERIFICATION_STATUS: "poi_pan_card_status"
  FORM60INDICATOR: "poi_form_60_status"
  OVD_CATEGORY: "proof_of_address_submitted_for_current_permanent_overseas_address"
  TAN_NUMBER: "tan_number"
  VOTER_ID_NUMBER: "voter_id"
  AGE: "age"
  PARTY_FULL_NAME: "coalesce(bagic_employee_name, beneficiary_name, hospital_name)"
  COUNTRY_OF_BIRTH: "country_of_birth"
  COUNTRY_OF_RESIDENCE: "country_of_residence"
  PARTY_ORIGINATION_DATE: "creation_date"
  DATE_OF_BIRTH: "date_of_birth"
  DATE_OF_DEATH: "date_of_death"
  PARTY_LEGAL_NAME: "firms_name"
  FIRST_NAME: "first_name"
  GENDER_CODE: "gender"
  LAST_NAME: "last_name"
  MIDDLE_NAME: "middle_name"
  NATIONALITY: "nationality"
  PARTY_SUB_TYPE_CODE: "partner_type"
  PARTY_STATUS: "status"
  PARTY_TYPE_CODE: "cast(null as varchar)"
  SALUTATION: "cast(null as varchar)"
  EDUCATIONAL_QUALIFICATION: "educational_qualification"
  DESIGNATION: "designation"
  VEHICLE_OWNED_INDICATOR: "do_you_have_2_wheeler4_wheeler"
  FATHER_NAME: "father_name"
  HIGHEST_DEGREE: "highest_qualification_details"
  MARITAL_STATUS: "marital_status"
  ANNUAL_INCOME: "monthly_income"
  YEARS_IN_CITY: "number_of_years_residing_in_the_city_of_residence"
  OCCUPATIONCODE: "occupation"
  OCCUPATION_DESCRIPTION: "primary_profession"
  SPOUSE_NAME: "spouse_name"
  CKYCNUMBER: "ckyc_number"
  CKYC_NUMBER: "ckyc_number"
  CKYC_REGISTRATION_STATUS: "ckyc_status"
  PANEL_CATEGORY: "category_of_appointment"
  BAR_COUNCIL_NAME: "enrolled_with_name_of_state_bar_association"
  BAR_ENROLMENT_NUMBER: "enrollment_id"
  PENDINGCASESCOUNT: "no_of_current_cases"
  JUNIORS_COUNT: "no_of_juniors"
  ADVOCATE_TYPE: "type_of_lawyer"
  ONBOARDING_START_DATE: "application_date"
  PRIOR_WORK_EXPERIENCE_YEARS: "experiencein_yrs"
  PREVIOUS_EMPLOYER_NAME: "previous_company_name"
  ANNUAL_TURNOVER: "annual_turnover"
  NATURE_OF_BUSINESS: "business_type"
  BUSINESS_REGISTRATION_NUMBER: "company_no"
  DATE_OF_INCORPORATION: "date_of_registration_or_incorporation"
  GROUP_NAME: "global_co_name"
  INDUSTRY_CODE: "industry_code"
  INDUSTRY_DESCRIPTION: "industry_type"
  LEGAL_CONSTITUTION_TYPE: "legal_constitution"
  NUMBEROFEMPLOYEES: "staff_strength_total"
  MSME_INDICATOR: "msme_applicable"
  MSME_CATEGORY: "msme_classification"
  PAID_UP_CAPITAL: "paid_up_capital"
  PARENT_ENTITY_NAME: "parent_co"
  GST_APPLICABLE_INDICATOR: "gst_payment_flag"
  PAYOUTHOLDREASON: "hold_payment_info"
  TDS_RATE: "cast(null as varchar)"
  TDSAPPLICABLEINDICATOR: "cast(null as varchar)"
  REFERREDBYREFERENCE: "referral_by"
  PRODUCT_DESCRIPTION: "product_details"
  CREDITPERIOD: "credit_days"
  CLAIMVOLUME: "average_claims"
  AVERAGECLAIMAMOUNT: "claims_size"
  QUALITY_RATING: "overall_rating"
  TARIFFTIER: "coalesce(bagic_package_class, package_class)"
  TARIFF_RATE: "coalesce(cd_or_photo_charges, labor_ot, labor_rate, neuro_icu_charges, parts_rate, per_visit_charges_outside_city_limit, per_visit_charges_within_city_limit, private, semi_private_room_ac, semi_private_room_non_ac, singleprivate_room_ac, singleprivate_room_non_ac, rate_per_km, service_charge, single_deluxe_room, special_rate, special_tariff, suite, triple_sharing_ac, triple_sharing_non_ac)"
  NEGOTIATEDINDICATOR: "coalesce(cost_negotiation, special_rate_applicable, special_tariff_applicable)"
  EXPIRY_DATE: "coalesce(cost_negotiation_end_date, package_expiry_date, step_down_option_for_room_rent_end_date)"
  EFFECTIVE_DATE: "coalesce(cost_negotiation_start_date, step_down_option_for_room_rent_start_date)"
  DISCOUNT_PERCENTAGE: "coalesce(discount_on_services, discount_percentage, early_payment_offer, msrp_less_)"
  ROOMCATEGORY: "coalesce(hospital_room_master, other_room, rooms_allowed_for_step_down, type_of_room_applicable)"
  SERVICE_DESCRIPTION: "coalesce(medicine_name, service_name)"
  PACKAGE_RATE: "package_rate"
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                     source_model=metadata_dict['source_model'],
                     hashed_columns=metadata_dict['hashed_columns'],
                     derived_columns=metadata_dict['derived_columns']) }}
