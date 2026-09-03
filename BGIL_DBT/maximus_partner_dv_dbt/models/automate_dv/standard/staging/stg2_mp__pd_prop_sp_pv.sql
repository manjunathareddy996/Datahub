{{ config(materialized='view') }}

-- MAXIMUS PARTNER wide stage() for BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW_2_1.
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
      - 'SUBCHANNELCODE'
      - 'SUBCHANNELEFFECTIVEDATE'
  HASHDIFF_COMMON_ADDRESS:
    is_hashdiff: true
    columns:
      - 'ADDRESSLINE1'
      - 'ADDRESSLINE2'
      - 'ADDRESSLINE3'
      - 'CAREOFNAME'
      - 'CITY'
      - 'COUNTRYNAME'
      - 'DISTRICT'
      - 'LANDMARK'
      - 'LOCALITY'
      - 'POSTALCODE'
      - 'POSTOFFICENAME'
      - 'STATENAME'
  HASHDIFF_COMMON_ADMIN_GEOGRAPHY:
    is_hashdiff: true
    columns:
      - 'CITYCLASSCODE'
  HASHDIFF_COMMON_CLASSIFICATION:
    is_hashdiff: true
    columns:
      - 'CATEGORYCODE'
      - 'TIERCODE'
  HASHDIFF_COMMON_COMMUNICATION_PREFERENCE:
    is_hashdiff: true
    columns:
      - 'CORRESPONDENCELANGUAGE'
      - 'GOGREENOPTININDICATOR'
      - 'PREFERREDCHANNELCODE'
      - 'PREFERREDLANGUAGECODE'
  HASHDIFF_COMMON_CONSENT:
    is_hashdiff: true
    columns:
      - 'CONSENTGIVENINDICATOR'
  HASHDIFF_COMMON_CONTACT:
    is_hashdiff: true
    columns:
      - 'ALTERNATEEMAILADDRESS'
      - 'ALTERNATEMOBILENUMBER'
      - 'EMAILADDRESS'
      - 'FAXNUMBER'
      - 'LANDLINENUMBER'
      - 'MOBILENUMBER'
      - 'SOCIALMEDIAHANDLE'
      - 'STDCODE'
  HASHDIFF_COMMON_GEO:
    is_hashdiff: true
    columns:
      - 'LATITUDE'
      - 'LONGITUDE'
      - 'REGIONCODE'
      - 'REGIONNAME'
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
      - 'EMPLOYEECODE'
      - 'FUNCTION'
  HASHDIFF_LNK_ROLE_INVESTIGATOR:
    is_hashdiff: true
    columns:
      - 'SPECIALISATIONAREA'
  HASHDIFF_LNK_ROLE_NOMINEE_BENEFICIARY:
    is_hashdiff: true
    columns:
      - 'RELATIONSHIPTOINSURED'
  HASHDIFF_LNK_ROLE_PROVIDER:
    is_hashdiff: true
    columns:
      - 'DEEMPANELMENTDATE'
      - 'DELISTINGDATE'
      - 'DELISTINGINDICATOR'
      - 'EMPANELMENTDATE'
      - 'EVALUATIONDATE'
      - 'ICUNURSECOUNT'
      - 'MOUREFERENCE'
      - 'MOUSTATUS'
      - 'NABHACCREDITEDINDICATOR'
      - 'NURSETOBEDRATIO'
      - 'NURSETOPATIENTRATIO'
      - 'PROVIDERCATEGORY'
      - 'PROVIDERCODE'
      - 'PROVIDERTYPE'
      - 'SERVICESCOPEDESCRIPTION'
      - 'SPECIALISATION'
  HASHDIFF_LNK_ROLE_SURVEYOR:
    is_hashdiff: true
    columns:
      - 'DEPARTMENTAUTHORISED'
      - 'IRDAISURVEYORLICENCENUMBER'
      - 'LICENCECATEGORY'
  HASHDIFF_LOCATION_PROFILE:
    is_hashdiff: true
    columns:
      - 'LOCATIONNAME'
      - 'LOCATIONTYPE'
  HASHDIFF_ORG_UNIT_DEFINITION:
    is_hashdiff: true
    columns:
      - 'BRANCHTYPE'
      - 'ORGUNITNAME'
  HASHDIFF_ORG_UNIT_LICENCE:
    is_hashdiff: true
    columns:
      - 'GSTREGISTRATIONNUMBER'
  HASHDIFF_PARTY_AGENT_LICENCE_LINE:
    is_hashdiff: true
    columns:
      - 'AUTHORISEDINDICATOR'
      - 'EXAMINATIONREFERENCE'
  HASHDIFF_PARTY_AML_SCREENING:
    is_hashdiff: true
    columns:
      - 'SCREENINGSTATUS'
  HASHDIFF_PARTY_BANKING:
    is_hashdiff: true
    columns:
      - 'ACCOUNTHOLDERNAME'
      - 'ACCOUNTNUMBERMASKED'
      - 'ACCOUNTTYPE'
      - 'BANKNAME'
      - 'BRANCHNAME'
      - 'IFSCCODE'
      - 'MICRCODE'
      - 'PENNYDROPVERIFIEDINDICATOR'
      - 'PRIMARYACCOUNTINDICATOR'
  HASHDIFF_PARTY_CONSENT_MANDATE:
    is_hashdiff: true
    columns:
      - 'BANKREFERENCE'
      - 'FREQUENCY'
      - 'MANDATEREFERENCE'
      - 'MANDATESTARTDATE'
      - 'MANDATETYPE'
      - 'MAXIMUMAMOUNT'
  HASHDIFF_PARTY_EMPLOYMENT:
    is_hashdiff: true
    columns:
      - 'EMPLOYERNAME'
      - 'EMPLOYMENTSTATUS'
  HASHDIFF_PARTY_FINANCIAL_PROFILE:
    is_hashdiff: true
    columns:
      - 'INCOMESOURCE'
  HASHDIFF_PARTY_FRAUD_PROFILE:
    is_hashdiff: true
    columns:
      - 'FRAUDSUSPICIONINDICATOR'
      - 'NEGATIVELISTINDICATOR'
      - 'NEGATIVELISTREASON'
      - 'WATCHENDDATE'
      - 'WATCHSTARTDATE'
  HASHDIFF_PARTY_HEALTH_PROFILE:
    is_hashdiff: true
    columns:
      - 'DISABILITYINDICATOR'
      - 'DISABILITYPERCENTAGE'
      - 'HEIGHT'
      - 'PREEXISTINGDISEASEDESCRIPTION'
      - 'WEIGHT'
  HASHDIFF_PARTY_HIERARCHY:
    is_hashdiff: true
    columns:
      - 'HIERARCHYLEVEL'
      - 'REPORTINGPARENTREFERENCE'
  HASHDIFF_PARTY_IDENTIFICATION:
    is_hashdiff: true
    columns:
      - 'AADHAARNUMBER'
      - 'AADHAARVERIFICATIONSTATUS'
      - 'AGEPROOFTYPE'
      - 'CINNUMBER'
      - 'DRIVINGLICENCEEXPIRYDATE'
      - 'DRIVINGLICENCENUMBER'
      - 'EIANUMBER'
      - 'FORM60INDICATOR'
      - 'GSTIN'
      - 'GSTREGISTRATIONSTATUS'
      - 'GSTTAXPAYERTYPE'
      - 'IDENTIFICATIONEXPIRYDATE'
      - 'IDENTIFICATIONISSUEDATE'
      - 'IDENTIFICATIONISSUINGAUTHORITY'
      - 'IDENTIFICATIONNUMBER'
      - 'IDENTIFICATIONTYPECODE'
      - 'IDENTIFICATIONVERIFIEDINDICATOR'
      - 'INSURANCEREPOSITORYNAME'
      - 'NREGACARDNUMBER'
      - 'OVDCATEGORY'
      - 'PANNUMBER'
      - 'PANVERIFICATIONSTATUS'
      - 'PASSPORTEXPIRYDATE'
      - 'PASSPORTNUMBER'
      - 'TANNUMBER'
      - 'VOTERIDNUMBER'
  HASHDIFF_PARTY_IDENTITY:
    is_hashdiff: true
    columns:
      - 'AGE'
      - 'COUNTRYOFBIRTH'
      - 'COUNTRYOFRESIDENCE'
      - 'DATEOFBIRTH'
      - 'DATEOFDEATH'
      - 'FIRSTNAME'
      - 'GENDERCODE'
      - 'LASTNAME'
      - 'MIDDLENAME'
      - 'NATIONALITY'
      - 'PARTYFULLNAME'
      - 'PARTYLEGALNAME'
      - 'PARTYORIGINATIONDATE'
      - 'PARTYSTATUS'
      - 'PARTYSUBTYPECODE'
      - 'PARTYTYPECODE'
      - 'SALUTATION'
  HASHDIFF_PARTY_INDIVIDUAL_DEMOGRAPHICS:
    is_hashdiff: true
    columns:
      - 'ANNUALINCOME'
      - 'DESIGNATION'
      - 'EDUCATIONALQUALIFICATION'
      - 'FATHERNAME'
      - 'HIGHESTDEGREE'
      - 'MARITALSTATUS'
      - 'OCCUPATIONCODE'
      - 'OCCUPATIONDESCRIPTION'
      - 'SPOUSENAME'
      - 'VEHICLEOWNEDINDICATOR'
      - 'YEARSINCITY'
  HASHDIFF_PARTY_KYC:
    is_hashdiff: true
    columns:
      - 'CKYCNUMBER'
      - 'CKYCREGISTRATIONSTATUS'
  HASHDIFF_PARTY_LEGAL_PANEL:
    is_hashdiff: true
    columns:
      - 'ADVOCATETYPE'
      - 'BARCOUNCILNAME'
      - 'BARENROLMENTNUMBER'
      - 'JUNIORSCOUNT'
      - 'PANELCATEGORY'
      - 'PENDINGCASESCOUNT'
  HASHDIFF_PARTY_ONBOARDING_JOURNEY:
    is_hashdiff: true
    columns:
      - 'ONBOARDINGSTARTDATE'
      - 'PREVIOUSEMPLOYERNAME'
      - 'PRIORWORKEXPERIENCEYEARS'
  HASHDIFF_PARTY_ORGANISATION_PROFILE:
    is_hashdiff: true
    columns:
      - 'ANNUALTURNOVER'
      - 'BUSINESSREGISTRATIONNUMBER'
      - 'DATEOFINCORPORATION'
      - 'GROUPNAME'
      - 'INDUSTRYCODE'
      - 'INDUSTRYDESCRIPTION'
      - 'LEGALCONSTITUTIONTYPE'
      - 'MSMECATEGORY'
      - 'MSMEINDICATOR'
      - 'NATUREOFBUSINESS'
      - 'NUMBEROFEMPLOYEES'
      - 'PAIDUPCAPITAL'
      - 'PARENTENTITYNAME'
  HASHDIFF_PARTY_PAYOUT_PROFILE:
    is_hashdiff: true
    columns:
      - 'GSTAPPLICABLEINDICATOR'
      - 'PAYOUTHOLDREASON'
      - 'TDSAPPLICABLEINDICATOR'
      - 'TDSRATE'
  HASHDIFF_PARTY_RELATIONSHIP_PROFILE:
    is_hashdiff: true
    columns:
      - 'REFERREDBYREFERENCE'
  HASHDIFF_PRODUCT_DEFINITION:
    is_hashdiff: true
    columns:
      - 'PRODUCTDESCRIPTION'
  HASHDIFF_PROVIDER_BANKING:
    is_hashdiff: true
    columns:
      - 'CREDITPERIOD'
  HASHDIFF_PROVIDER_QUALITY:
    is_hashdiff: true
    columns:
      - 'AVERAGECLAIMAMOUNT'
      - 'CLAIMVOLUME'
      - 'QUALITYRATING'
  HASHDIFF_PROVIDER_TARIFF:
    is_hashdiff: true
    columns:
      - 'DISCOUNTPERCENTAGE'
      - 'EFFECTIVEDATE'
      - 'EXPIRYDATE'
      - 'NEGOTIATEDINDICATOR'
      - 'PACKAGERATE'
      - 'ROOMCATEGORY'
      - 'SERVICEDESCRIPTION'
      - 'TARIFFRATE'
      - 'TARIFFTIER'
derived_columns:
  DISTRIBUTION_CHANNEL_BK: "agent_channel"
  DISTRIBUTION_CHANNEL_NK: "'HUB_DISTRIBUTION_CHANNEL|' || (agent_channel)"
  LOCATION_BK: "md5(concat_ws('|', upper(trim(to_varchar(our_office_address))), upper(trim(to_varchar(current_permanent_overseas_address_line_2))), upper(trim(to_varchar(current_permanent_overseas_address_line_3))), upper(trim(to_varchar(current_permanent_overseas_address_city_town_village))), upper(trim(to_varchar(correspondence_local_address_district))), upper(trim(to_varchar(current_permanent_overseas_address_state_ut))), upper(trim(to_varchar(local_address_pin_code))), upper(trim(to_varchar(current_permanent_overseas_address_country)))))"
  LOCATION_NK: "'HUB_LOCATION|' || (md5(concat_ws('|', upper(trim(to_varchar(our_office_address))), upper(trim(to_varchar(current_permanent_overseas_address_line_2))), upper(trim(to_varchar(current_permanent_overseas_address_line_3))), upper(trim(to_varchar(current_permanent_overseas_address_city_town_village))), upper(trim(to_varchar(correspondence_local_address_district))), upper(trim(to_varchar(current_permanent_overseas_address_state_ut))), upper(trim(to_varchar(local_address_pin_code))), upper(trim(to_varchar(current_permanent_overseas_address_country))))))"
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
  SUBCHANNELCODE: "sub_channel"
  SUBCHANNELEFFECTIVEDATE: "sub_channel_effective_date"
  CAREOFNAME: "addressee"
  CITY: "coalesce(correspondence_local_address_city_town_village, current_permanent_overseas_address_city_town_village)"
  COUNTRYNAME: "coalesce(correspondence_local_address_country, country, current_permanent_overseas_address_country)"
  DISTRICT: "correspondence_local_address_district"
  ADDRESSLINE1: "coalesce(correspondence_local_address_line_1, current_permanent_overseas_address_line_1, our_office_address)"
  ADDRESSLINE2: "coalesce(correspondence_local_address_line_2, current_permanent_overseas_address_line_2)"
  ADDRESSLINE3: "coalesce(correspondence_local_address_line_3, current_permanent_overseas_address_line_3)"
  STATENAME: "coalesce(correspondence_local_address_state, current_permanent_overseas_address_state_ut)"
  POSTALCODE: "coalesce(current_permanent_overseas_address_pin_code, local_address_pin_code)"
  POSTOFFICENAME: "cast(null as varchar)"
  LOCALITY: "cast(null as varchar)"
  LANDMARK: "cast(null as varchar)"
  CITYCLASSCODE: "city_class"
  CATEGORYCODE: "category"
  TIERCODE: "tier_level"
  CORRESPONDENCELANGUAGE: "communication_and_preferred_language"
  GOGREENOPTININDICATOR: "epolicy_required"
  PREFERREDLANGUAGECODE: "party_language"
  PREFERREDCHANNELCODE: "preferred_mode_of_communication"
  CONSENTGIVENINDICATOR: "customer_consent"
  EMAILADDRESS: "coalesce(administrator_email_id, billing_persons_email_id, ceo_email_id, finance_officer_email_id, marketing_head_email_id, medical_director_email_id, medical_superintendent_email_id)"
  MOBILENUMBER: "coalesce(administrator_mobile_no, billing_persons_mobile_no, ceo_mobile_no, claim_mobile_number, contact_person_mobile_no_1, contact_person_mobile_no_2, finance_officer_mobile_number, marketing_head_mobile_no, medical_director_mobile_no, medical_superintendent_mobile_no, registered_mobile_number)"
  ALTERNATEMOBILENUMBER: "alternate_mob_numberlandline_number"
  LANDLINENUMBER: "coalesce(company_contact, emergency_phone_number_val, landline_no, phone_detailsdfadvocate, phone_detailshcadvocate, phone_detailslawyer, phone_detailsretainer, phone_detailsstadvocate, phone_detailstradvocate, phone_no_1, phone_no_2)"
  STDCODE: "std_code"
  SOCIALMEDIAHANDLE: "cast(null as varchar)"
  FAXNUMBER: "cast(null as varchar)"
  ALTERNATEEMAILADDRESS: "cast(null as varchar)"
  REGIONNAME: "area"
  LATITUDE: "latitude"
  LONGITUDE: "longitude"
  REGIONCODE: "region"
  AGENTCODE: "irda_code"
  LICENCEEXPIRYDATE: "license_expiry_date"
  LICENCEISSUEDATE: "license_issue_date"
  LICENCECATEGORY: "sur_license_type"
  CONSENTFORDATASHARINGINDICATOR: "customer_consent_for_data_sharing"
  PREFERREDCUSTOMERINDICATOR: "priority_customer"
  DEPARTMENT: "department"
  EMPLOYEECODE: "employee_code"
  FUNCTION: "function"
  SPECIALISATIONAREA: "investigation_skills"
  RELATIONSHIPTOINSURED: "nominee_relationship"
  DEEMPANELMENTDATE: "deempanel_date"
  DELISTINGINDICATOR: "delisted"
  DELISTINGDATE: "delisted_date"
  EMPANELMENTDATE: "empanel_date"
  EVALUATIONDATE: "evaluation_date"
  SPECIALISATION: "medical_speciality"
  MOUREFERENCE: "mou_documents"
  MOUSTATUS: "mou_status"
  NABHACCREDITEDINDICATOR: "nabh_certified"
  ICUNURSECOUNT: "no_of_qualified_nurses_available_exclusively_in_icu_taking_all_the_shifts_together"
  NURSETOBEDRATIO: "nursebed_ratio_no_of_qualified_and_registered_nurses_gnm_post_bsc_bsc_msc_nursing_as_proportion_of_occupied_beds"
  PROVIDERCATEGORY: "provider_category"
  SERVICESCOPEDESCRIPTION: "scope_of_supplier"
  NURSETOPATIENTRATIO: "span_of_control_nurse_to_patient"
  PROVIDERCODE: "supplier_id"
  PROVIDERTYPE: "type_of_provider"
  DEPARTMENTAUTHORISED: "surveyor_department"
  IRDAISURVEYORLICENCENUMBER: "sur_license_no"
  LOCATIONNAME: "location"
  LOCATIONTYPE: "cast(null as varchar)"
  ORGUNITNAME: "branch_name"
  BRANCHTYPE: "branch_type"
  GSTREGISTRATIONNUMBER: "bagic_gstin"
  EXAMINATIONREFERENCE: "examinations_details_for_irda_code"
  AUTHORISEDINDICATOR: "cast(null as varchar)"
  SCREENINGSTATUS: "aml_verification_status"
  ACCOUNTTYPE: "account_category_code"
  ACCOUNTNUMBERMASKED: "coalesce(account_no, owner_acct)"
  BANKNAME: "cast(null as varchar)"
  BRANCHNAME: "cast(null as varchar)"
  PENNYDROPVERIFIEDINDICATOR: "cast(null as varchar)"
  ACCOUNTHOLDERNAME: "cast(null as varchar)"
  PRIMARYACCOUNTINDICATOR: "cast(null as varchar)"
  MICRCODE: "cast(null as varchar)"
  IFSCCODE: "cast(null as varchar)"
  FREQUENCY: "frequency"
  BANKREFERENCE: "cast(null as varchar)"
  MANDATETYPE: "cast(null as varchar)"
  MAXIMUMAMOUNT: "cast(null as varchar)"
  MANDATEREFERENCE: "cast(null as varchar)"
  MANDATESTARTDATE: "cast(null as varchar)"
  EMPLOYMENTSTATUS: "employee_status"
  EMPLOYERNAME: "employer_name"
  INCOMESOURCE: "income_source"
  NEGATIVELISTINDICATOR: "blacklisted"
  WATCHSTARTDATE: "blacklisted_effective_date"
  WATCHENDDATE: "blacklisted_expiry_date"
  NEGATIVELISTREASON: "blacklist_details"
  FRAUDSUSPICIONINDICATOR: "suspected_fraud"
  DISABILITYPERCENTAGE: "disability_percentage"
  PREEXISTINGDISEASEDESCRIPTION: "disease_name"
  HEIGHT: "height"
  DISABILITYINDICATOR: "physically_challenged"
  WEIGHT: "weight"
  HIERARCHYLEVEL: "level"
  REPORTINGPARENTREFERENCE: "parent_party_code"
  IDENTIFICATIONNUMBER: "coalesce(aadhaar_enrollment_no, abha_id, existing_partner_id, hospital_id, identifier, id_number, partner_ref, registration_no, sepz_registration_no, sez_registration_no, service_tax_no, rohini_code, vid)"
  AADHAARNUMBER: "aadhaar_number"
  IDENTIFICATIONISSUEDATE: "coalesce(address_proof_effective_date, driving_license_issue_date, gstin_issuance_dt, identification_proof_effective_date, passport_issue_date, sepz_registration_date, sez_registration_date)"
  CINNUMBER: "cin_number"
  IDENTIFICATIONVERIFIEDINDICATOR: "coalesce(claim_poa_status, claim_poi_status, e_insurance_demat_account_verified, poa_driving_license_status, poa_nrega_job_card_status, poa_passport_status)"
  GSTTAXPAYERTYPE: "taxpayer_type"
  IDENTIFICATIONEXPIRYDATE: "coalesce(date_of_expiry, expiry_date, sez_expiry_date)"
  AGEPROOFTYPE: "dob_proof"
  DRIVINGLICENCEEXPIRYDATE: "driving_license_expiry_date"
  DRIVINGLICENCENUMBER: "driving_license_number"
  IDENTIFICATIONISSUINGAUTHORITY: "driving_license_place_of_issue"
  EIANUMBER: "eia_number"
  GSTIN: "gstinuin"
  GSTREGISTRATIONSTATUS: "gstn_regn_status"
  IDENTIFICATIONTYPECODE: "coalesce(identification_proof, id_type, id_type1)"
  INSURANCEREPOSITORYNAME: "insurance_repository_code"
  PANNUMBER: "pan_no"
  NREGACARDNUMBER: "nrega_job_card"
  PASSPORTEXPIRYDATE: "passport_expiry_date"
  PASSPORTNUMBER: "passport_number"
  AADHAARVERIFICATIONSTATUS: "poa_aadhar_card_status"
  PANVERIFICATIONSTATUS: "poi_pan_card_status"
  FORM60INDICATOR: "poi_form_60_status"
  OVDCATEGORY: "proof_of_address_submitted_for_current_permanent_overseas_address"
  TANNUMBER: "tan_number"
  VOTERIDNUMBER: "voter_id"
  AGE: "age"
  PARTYFULLNAME: "coalesce(bagic_employee_name, beneficiary_name, hospital_name)"
  COUNTRYOFBIRTH: "country_of_birth"
  COUNTRYOFRESIDENCE: "country_of_residence"
  PARTYORIGINATIONDATE: "creation_date"
  DATEOFBIRTH: "date_of_birth"
  DATEOFDEATH: "date_of_death"
  PARTYLEGALNAME: "firms_name"
  FIRSTNAME: "first_name"
  GENDERCODE: "gender"
  LASTNAME: "last_name"
  MIDDLENAME: "middle_name"
  NATIONALITY: "nationality"
  PARTYSUBTYPECODE: "partner_type"
  PARTYSTATUS: "status"
  PARTYTYPECODE: "cast(null as varchar)"
  SALUTATION: "cast(null as varchar)"
  EDUCATIONALQUALIFICATION: "educational_qualification"
  DESIGNATION: "designation"
  VEHICLEOWNEDINDICATOR: "do_you_have_2_wheeler4_wheeler"
  FATHERNAME: "father_name"
  HIGHESTDEGREE: "highest_qualification_details"
  MARITALSTATUS: "marital_status"
  ANNUALINCOME: "monthly_income"
  YEARSINCITY: "number_of_years_residing_in_the_city_of_residence"
  OCCUPATIONCODE: "occupation"
  OCCUPATIONDESCRIPTION: "primary_profession"
  SPOUSENAME: "spouse_name"
  CKYCNUMBER: "ckyc_number"
  CKYCREGISTRATIONSTATUS: "ckyc_status"
  PANELCATEGORY: "category_of_appointment"
  BARCOUNCILNAME: "enrolled_with_name_of_state_bar_association"
  BARENROLMENTNUMBER: "enrollment_id"
  PENDINGCASESCOUNT: "no_of_current_cases"
  JUNIORSCOUNT: "no_of_juniors"
  ADVOCATETYPE: "type_of_lawyer"
  ONBOARDINGSTARTDATE: "application_date"
  PRIORWORKEXPERIENCEYEARS: "experiencein_yrs"
  PREVIOUSEMPLOYERNAME: "previous_company_name"
  ANNUALTURNOVER: "annual_turnover"
  NATUREOFBUSINESS: "business_type"
  BUSINESSREGISTRATIONNUMBER: "company_no"
  DATEOFINCORPORATION: "date_of_registration_or_incorporation"
  GROUPNAME: "global_co_name"
  INDUSTRYCODE: "industry_code"
  INDUSTRYDESCRIPTION: "industry_type"
  LEGALCONSTITUTIONTYPE: "legal_constitution"
  NUMBEROFEMPLOYEES: "staff_strength_total"
  MSMEINDICATOR: "msme_applicable"
  MSMECATEGORY: "msme_classification"
  PAIDUPCAPITAL: "paid_up_capital"
  PARENTENTITYNAME: "parent_co"
  GSTAPPLICABLEINDICATOR: "gst_payment_flag"
  PAYOUTHOLDREASON: "hold_payment_info"
  TDSRATE: "cast(null as varchar)"
  TDSAPPLICABLEINDICATOR: "cast(null as varchar)"
  REFERREDBYREFERENCE: "referral_by"
  PRODUCTDESCRIPTION: "product_details"
  CREDITPERIOD: "credit_days"
  CLAIMVOLUME: "average_claims"
  AVERAGECLAIMAMOUNT: "claims_size"
  QUALITYRATING: "overall_rating"
  TARIFFTIER: "coalesce(bagic_package_class, package_class)"
  TARIFFRATE: "coalesce(cd_or_photo_charges, labor_ot, labor_rate, neuro_icu_charges, parts_rate, per_visit_charges_outside_city_limit, per_visit_charges_within_city_limit, private, semi_private_room_ac, semi_private_room_non_ac, singleprivate_room_ac, singleprivate_room_non_ac, rate_per_km, service_charge, single_deluxe_room, special_rate, special_tariff, suite, triple_sharing_ac, triple_sharing_non_ac)"
  NEGOTIATEDINDICATOR: "coalesce(cost_negotiation, special_rate_applicable, special_tariff_applicable)"
  EXPIRYDATE: "coalesce(cost_negotiation_end_date, package_expiry_date, step_down_option_for_room_rent_end_date)"
  EFFECTIVEDATE: "coalesce(cost_negotiation_start_date, step_down_option_for_room_rent_start_date)"
  DISCOUNTPERCENTAGE: "coalesce(discount_on_services, discount_percentage, early_payment_offer, msrp_less_)"
  ROOMCATEGORY: "coalesce(hospital_room_master, other_room, rooms_allowed_for_step_down, type_of_room_applicable)"
  SERVICEDESCRIPTION: "coalesce(medicine_name, service_name)"
  PACKAGERATE: "package_rate"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW_2_1'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                     source_model=metadata_dict['source_model'],
                     hashed_columns=metadata_dict['hashed_columns'],
                     derived_columns=metadata_dict['derived_columns']) }}
