{{ config(materialized='view') }}

-- MAXIMUS PARTNER AUGMENTED (unconfirmed) WIDE stage() for HUB_PARTY, view 'pd_prop_sp_pv'.
-- Serves 44 augmented satellite(s), one HASHDIFF each, from 371
-- column(s) with no faithful home in data_7. The KEY is the standard track's own
-- expression for HUB_PARTY on this view; the ATTRIBUTE GROUPING is the mapper's
-- proposal and is NOT canonical.

{%- set yaml_metadata -%}
source_model: 'stg_maximus__pd_prop_sp_pv'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF_AUG_COMMON_CLASSIFICATION:
    is_hashdiff: true
    columns:
      - 'CATEGORYVALUE'
      - 'HNIFLAG'
      - 'PRIVEFLAG'
      - 'PROFILECODE'
  HASHDIFF_AUG_COMMON_COMMUNICATION_PREFERENCE:
    is_hashdiff: true
    columns:
      - 'PREFERREDALERTMODE'
  HASHDIFF_AUG_COMMON_CONTACT:
    is_hashdiff: true
    columns:
      - 'CONTACTPERSONNAME'
      - 'CONTACTVERIFICATIONREQUIREDINDICATOR'
      - 'WEBSITEURL'
  HASHDIFF_AUG_LNK_PARTY_ROLE_CORE:
    is_hashdiff: true
    columns:
      - 'CANCELLATIONPORTION'
      - 'RESIGNATIONSUBMITTEDDATE'
  HASHDIFF_AUG_LNK_ROLE_AGENT:
    is_hashdiff: true
    columns:
      - 'AFFINITYPARTNEREMPLOYEEINDICATOR'
      - 'AUTHORISEDPERSONNUMBER'
      - 'DSAINDICATOR'
      - 'INTERMEDIARYLICENCENUMBER'
      - 'IRDAICATEGORY'
      - 'IRDAIPRIMARYPROFESSION'
      - 'IRDAIUNIQUEIDENTIFIER'
      - 'LICENCEDETAIL'
  HASHDIFF_AUG_LNK_ROLE_CUSTOMER:
    is_hashdiff: true
    columns:
      - 'INSUREDTYPE'
      - 'MEMBERTYPE'
      - 'PREMIUMPAYERTYPE'
  HASHDIFF_AUG_LNK_ROLE_NOMINEE_BENEFICIARY:
    is_hashdiff: true
    columns:
      - 'NOMINEEDETAIL'
      - 'RELATEDPARTYRELATIONSHIPTYPE'
      - 'RELATIONSHIPOTHERDETAIL'
  HASHDIFF_AUG_LNK_ROLE_PROVIDER:
    is_hashdiff: true
    columns:
      - 'ACTIVATIONDEACTIVATIONREASON'
      - 'ADDITIONALDETAILSREMARKS'
      - 'ASSESSMENTDATE'
      - 'AUTHORISINGMANUFACTURERNAME'
      - 'BLACKLISTREASON'
      - 'CONEXPERTISE'
      - 'CONTACTPERSONDESIGNATION'
      - 'CONTACTPERSONNAME'
      - 'COVEREDAREA'
      - 'DEALERCODE'
      - 'DEALERPROGRAMMETYPE'
      - 'DEALERTYPE'
      - 'DELISTINGREASON'
      - 'DOCTORTOBEDRATIO'
      - 'DOCTORTOPATIENTRATIO'
      - 'EMPANELLEDCOMPANIESCOUNT'
      - 'EMPANELLEDINSURERCOUNT'
      - 'EMPANELMENTREQUESTDATE'
      - 'EMPLOYEEPAINSURANCEINDICATOR'
      - 'EVALUATINGASSESSORNAME'
      - 'ICUDOCTORCOUNT'
      - 'ICUDOCTORTOBEDRATIO'
      - 'ICUNURSETOBEDRATIO'
      - 'INSURERVISITCONDUCTEDINDICATOR'
      - 'LKQPARTSACCEPTEDINDICATOR'
      - 'MANAGERCONFIDENTIALREPORT'
      - 'MANAGERRECOMMENDATIONONVENDOR'
      - 'MOUDETAIL'
      - 'MOUREVISIONDATE'
      - 'MOUTYPE'
      - 'MOUVALIDITYENDDATE'
      - 'MOUVALIDITYSTARTDATE'
      - 'NABHACCREDITATIONLEVEL'
      - 'NATIONALTIEUPINFORMATION'
      - 'NEARESTSERVICINGBRANCHREFERENCE'
      - 'NETWORKSTATUSREMARK'
      - 'NONDISCLOSUREAGREEMENTSTATUS'
      - 'NORMALOFFER'
      - 'OFFICEFIREINSURANCEINDICATOR'
      - 'OFFICEMANAGERNAME'
      - 'ONLINEPROVIDERREFERENCENUMBER'
      - 'OPERATINGHOURSDESCRIPTION'
      - 'OPERATINGLOCATIONRESTRICTION'
      - 'OPERATIONBASETYPE'
      - 'OPERATIONPLACE'
      - 'OPERATIONPLACEFORINSURERWORK'
      - 'ORIGINCOMP'
      - 'ORIGINCONT'
      - 'OTHERSERVICESDESCRIPTION'
      - 'PANELDOCTORDETAILS'
      - 'PARTNERDESCRIPTION'
      - 'PPNTYPE'
      - 'PREVIOUSPROVIDERREFERENCE'
      - 'PRIORITY'
      - 'PROFESSIONALINDEMNITYCOVERINDICATOR'
      - 'PROVIDERPROFILEDESCRIPTION'
      - 'REACTIVATIONDATE'
      - 'REACTIVATIONREASON'
      - 'SERVICEENGAGEMENTSTATUS'
      - 'SERVICELOCATORPROVIDERINDICATOR'
      - 'SERVICEREMARKS'
      - 'SINGLESPECIALITYINDICATOR'
      - 'SPECIALISEDREPAIRERMAKE'
      - 'SUPPLIERDETAILDESCRIPTION'
      - 'SUPPLIERLOCATIONDESCRIPTION'
      - 'SUPPLIERNAME'
      - 'TEACHINGINSTITUTIONINDICATOR'
      - 'TPACOORDINATOREMAILADDRESS'
      - 'TPACOORDINATORMOBILENUMBER'
      - 'TPACOORDINATORNAME'
      - 'TPADESKOPERATINGHOURSSUNDAY'
      - 'TPADESKOPERATINGHOURSWEEKDAY'
      - 'USEDCARDEALERINDICATOR'
      - 'VEHICLEMAKESHANDLED'
      - 'VENDOREVALUATIONOUTCOME'
      - 'VENDOREVALUATIONTEMPLATEREFERENCE'
      - 'VISITINGCONSULTANTCOUNT'
      - 'VISITINGSURGEONCOUNT'
      - 'WORKSHOPCATEGORY'
      - 'WORKSHOPCLASS'
  HASHDIFF_AUG_LNK_ROLE_SURVEYOR:
    is_hashdiff: true
    columns:
      - 'PERFORMANCEEVALUATIONFORMREFERENCE'
      - 'PERFORMANCEEVALUATIONOUTCOME'
      - 'REPORTTIMELINESSRATING'
      - 'SURVEYORTYPE'
  HASHDIFF_AUG_PARTY_AGENT_PRODUCTION:
    is_hashdiff: true
    columns:
      - 'MINIMUMSALESCOMMITMENT'
  HASHDIFF_AUG_PARTY_AMENDMENT_ENDORSEMENT:
    is_hashdiff: true
    columns:
      - 'ENDORSEMENTTYPE'
      - 'PARTYENDORSEMENTTYPE'
  HASHDIFF_AUG_PARTY_BANKING:
    is_hashdiff: true
    columns:
      - 'BANKINGDETAILSDESCRIPTION'
      - 'NEFTREGISTRATIONSTATUS'
      - 'REFUNDBENEFICIARYPARTYREFERENCE'
  HASHDIFF_AUG_PARTY_CLAIM_HISTORY:
    is_hashdiff: true
    columns:
      - 'CLAIMREMARKS'
  HASHDIFF_AUG_PARTY_CONTACT_ADDRESS_LINK:
    is_hashdiff: true
    columns:
      - 'SAMEASCORRESPONDENCEADDRESSINDICATOR'
  HASHDIFF_AUG_PARTY_CORRESPONDENCE:
    is_hashdiff: true
    columns:
      - 'PRINTZONECODE'
  HASHDIFF_AUG_PARTY_DIGITAL_IDENTITY:
    is_hashdiff: true
    columns:
      - 'DEVICEMAKEANDMODEL'
      - 'PORTALACCESSSTATUS'
      - 'USERTYPE'
  HASHDIFF_AUG_PARTY_DRIVING:
    is_hashdiff: true
    columns:
      - 'DRIVINGEXPERIENCEYEARS'
      - 'DRIVINGLICENCEDETAIL'
  HASHDIFF_AUG_PARTY_EMPLOYMENT:
    is_hashdiff: true
    columns:
      - 'EMPLOYERDETAILS'
      - 'INSURANCEINDUSTRYEXPERIENCEINDICATOR'
      - 'INSUREDOCCUPATIONDETAIL'
      - 'INVESTIGATIONFIELDEXPERIENCEYEARS'
      - 'OVERALLEXPERIENCEDESCRIPTION'
      - 'SKILLSETDESCRIPTION'
      - 'TOTALWORKEXPERIENCEYEARS'
      - 'TOTALYEARSOFEXPERIENCE'
  HASHDIFF_AUG_PARTY_FINANCIAL_PROFILE:
    is_hashdiff: true
    columns:
      - 'CHEQUERECEIPTINGBLOCKEDINDICATOR'
      - 'CHEQUERECEIPTINGBLOCKREASON'
      - 'DECLAREDINCOMEAMOUNT'
      - 'INCOMETAXRETURNFILEDLASTTWOYEARSINDICATOR'
  HASHDIFF_AUG_PARTY_FRAUD_PROFILE:
    is_hashdiff: true
    columns:
      - 'BLACKLISTDATE'
      - 'FRAUDSUSPICIONENDDATE'
      - 'FRAUDSUSPICIONREASON'
      - 'FRAUDSUSPICIONSTARTDATE'
  HASHDIFF_AUG_PARTY_GROUP_SCHEME:
    is_hashdiff: true
    columns:
      - 'GROUPBUFFERAMOUNT'
      - 'GROUPHEALTHUSERTYPE'
  HASHDIFF_AUG_PARTY_HEALTH_PROFILE:
    is_hashdiff: true
    columns:
      - 'DISABILITYBODYLOCATION'
  HASHDIFF_AUG_PARTY_HIERARCHY:
    is_hashdiff: true
    columns:
      - 'BRANCHMANAGERUSERIDENTIFIER'
      - 'DISTRIBUTIONCLASSIFICATION'
      - 'DISTRIBUTORCODE'
      - 'RELATIONSHIPASSOCIATEEMPLOYEECODE'
      - 'SELLINGDEALERREFERENCE'
      - 'SERVICINGAGENTREFERENCE'
      - 'TECHNICALSECTIONCODE'
      - 'TRANSFERCASEINDICATOR'
      - 'TRANSFERINDICATOR'
      - 'ZONECODE'
  HASHDIFF_AUG_PARTY_IDENTIFICATION:
    is_hashdiff: true
    columns:
      - 'ADDRESSPROOFTYPE'
      - 'EIAACCOUNTDETAILS'
      - 'EIAAVAILABLEINDICATOR'
      - 'EIACREDITREQUIREDINDICATOR'
      - 'EIALINKEDDATE'
      - 'EIAREQUIREDINDICATOR'
      - 'NAMEASPERIDENTIFICATION'
      - 'OVDCATEGORYOTHERDETAIL'
      - 'PASSPORTFILENUMBER'
      - 'PASSPORTISSUINGCOUNTRY'
  HASHDIFF_AUG_PARTY_IDENTITY:
    is_hashdiff: true
    columns:
      - 'BENEFICIARYNAMELIST'
      - 'BLOCKUNBLOCKSTATUS'
      - 'CLAIMAPPLICANTDATEOFBIRTH'
      - 'CLAIMAPPLICANTNAME'
      - 'CLAIMAPPLICANTSALUTATION'
      - 'COUNTRYOFCITIZENSHIP'
      - 'PARTYENDDATE'
      - 'PARTYREMARKS'
      - 'RECORDEFFECTIVEDATE'
      - 'RECORDENDDATE'
      - 'SOURCELASTMODIFIEDDATE'
      - 'STATUSREASONOTHERDETAIL'
  HASHDIFF_AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS:
    is_hashdiff: true
    columns:
      - 'BASICQUALIFICATIONDETAILS'
      - 'BASICQUALIFICATIONROLLNUMBER'
      - 'EDUCATIONINSTITUTENAME'
      - 'FATHERORSPOUSENAME'
      - 'INCOMEBANDLOWERBOUND'
      - 'INCOMEBANDUPPERBOUND'
      - 'MARRIAGEANNIVERSARYDATE'
      - 'MATRICULATIONQUALIFICATIONDETAIL'
      - 'MONTHLYGROSSINCOME'
      - 'MOTHERSMAIDENNAME'
      - 'NUMBEROFDAUGHTERS'
      - 'NUMBEROFSONS'
      - 'OCCUPATIONLIST'
      - 'OTHEROCCUPATION'
      - 'OTHERQUALIFICATION'
      - 'PERSONALDETAILSDESCRIPTION'
      - 'POSTGRADUATEQUALIFICATION'
      - 'PROFESSIONALQUALIFICATION'
      - 'QUALIFICATIONBOARDNAME'
      - 'QUALIFICATIONDETAIL'
      - 'QUALIFICATIONPASSINGMONTH'
      - 'UNDERGRADUATEQUALIFICATION'
      - 'YEAROFPASSINGQUALIFICATION'
  HASHDIFF_AUG_PARTY_INTERACTION:
    is_hashdiff: true
    columns:
      - 'APPRECIATIONDISPLAYCOUNTER'
  HASHDIFF_AUG_PARTY_KYC:
    is_hashdiff: true
    columns:
      - 'CKYCDETAILS'
      - 'CKYCNUMBERHELDINDICATOR'
      - 'HOSPITALDOCUMENTSAVAILABLEINDICATOR'
      - 'KYCDETAIL'
      - 'KYCRELATEDDETAIL'
      - 'OPTIONALPROOFOFPOSSESSIONTYPE'
      - 'PANAADHARLINKED'
      - 'PANAPPLIEDINDICATOR'
      - 'PANAPPNO'
      - 'PRIMARYPROOFOFPOSSESSIONTYPE'
      - 'PROOFOFADDRESSSTATUS'
      - 'PROOFOFIDENTITYSTATUS'
      - 'REQUIREDDOCUMENTSSUBMITTEDINDICATOR'
      - 'SERVICETAXCERTIFICATESUBMITTEDINDICATOR'
  HASHDIFF_AUG_PARTY_LEGAL_PANEL:
    is_hashdiff: true
    columns:
      - 'AVERAGEINSURERCASEALLOCATIONCOUNT'
      - 'AVERAGETOTALCASEALLOCATIONCOUNT'
      - 'COURTBENCHNAME'
      - 'COURTNAME'
      - 'ECOURTMAPPEDINDICATOR'
      - 'MACTCASESHANDLEDOTHERCOMPANYCOUNT'
      - 'NOOFBRIEFS'
  HASHDIFF_AUG_PARTY_MARKETING:
    is_hashdiff: true
    columns:
      - 'CASHBACKOFFER'
      - 'COUPONREBATEVALUE'
      - 'COUPONTYPE'
  HASHDIFF_AUG_PARTY_ONBOARDING_JOURNEY:
    is_hashdiff: true
    columns:
      - 'APPLICATIONREJECTIONREASON'
      - 'APPOINTMENTLETTERISSUEDATE'
      - 'APPROVEDBYREFERENCE'
      - 'ASSIGNEDTOILMINDICATOR'
      - 'CALCULATORURNNUMBER'
      - 'CANDIDATEBACKGROUNDDESCRIPTION'
      - 'CLAIMSTEAMRECOMMENDATION'
      - 'CLOSUREBYREFERENCE'
      - 'COMMUNICATIONSKILLSRATING'
      - 'DECLARATIONTEXT'
      - 'ENROLMENTFORMRECEIVEDINDICATOR'
      - 'GROUPCOMPANYSOURCEDINDICATOR'
      - 'INITIATEDBYREFERENCE'
      - 'INSURANCEBANKINGFINANCIALSERVICESEXPERIENCE'
      - 'MANDATORYDOCUMENTSUBMITTEDINDICATOR'
      - 'PREVIOUSEMPLOYERLOCATION'
      - 'PREVIOUSEMPLOYERPARENTINTERMEDIARYCODE'
      - 'PREVIOUSEMPLOYERPARENTSUBINTERMEDIARYCODE'
      - 'PREVIOUSENGAGEMENTDETAIL'
      - 'PREVIOUSNONGENERALINSURERNAME'
      - 'REASONFORLEAVINGPREVIOUSEMPLOYER'
      - 'REGISTEREDINDICATOR'
      - 'TRAINEDPRODUCTREFERENCE'
      - 'TRAININGREQUIREDINDICATOR'
  HASHDIFF_AUG_PARTY_ORGANISATION_PROFILE:
    is_hashdiff: true
    columns:
      - 'ALTERNATELOCATIONDETAILS'
      - 'BUSINESSDESCRIPTION'
      - 'BUSINESSSECTORCODE'
      - 'CLIENTGEOGRAPHY'
      - 'COORDINATINGOFFICEADDRESS'
      - 'CREDITLIMITCINNUMBER'
      - 'DEDICATEDSTAFFCOUNTFORINSURER'
      - 'DEDICATEDTEAMLEADERCOUNTFORINSURER'
      - 'GOVERNMENTBODYTYPE'
      - 'INFRASTRUCTURESUBSECTOR'
      - 'OTHERRELATEDENTITIES'
      - 'OWNERSHIPTYPE'
      - 'REGISTEREDBUSINESSTRUSTINDICATOR'
      - 'REGISTEREDCOMPANYINDICATOR'
      - 'REPRESENTEDBUSINESSNAME'
      - 'TOTALTEAMLEADERCOUNT'
      - 'TOTALTEAMSTRENGTH'
      - 'YEAROFESTABLISHMENT'
  HASHDIFF_AUG_PARTY_ORG_DIRECTORS:
    is_hashdiff: true
    columns:
      - 'DIRECTORANDPARTNERDETAIL'
  HASHDIFF_AUG_PARTY_PAYOUT_PROFILE:
    is_hashdiff: true
    columns:
      - 'DEFAULTCREDITGLACCOUNTCODE'
      - 'DEFAULTDEBITGLACCOUNTCODE'
      - 'FLOATACCOUNTACCESSINDICATOR'
      - 'FLOATREPLENISHMENTCONDITION'
      - 'INTERIMPAYMENTINDICATOR'
      - 'LOWERTDSCERTIFICATEREFERENCE'
      - 'PAYCLAIMSCANCELMONTHLYINDICATOR'
      - 'PAYEECODE'
      - 'PAYEENAME'
      - 'PAYEETYPE'
      - 'PAYMENTDETAILSDESCRIPTION'
      - 'PAYMENTMODE'
      - 'PAYMENTPLAN'
      - 'PAYMENTSCHEDULE'
      - 'REWARDSCHEMEAPPLICABLEINDICATOR'
      - 'SERVICETAXAPPLICABLEINDICATOR'
      - 'TDSCERTIFICATEISSUEDATE'
      - 'TDSCERTIFICATENUMBER'
      - 'TDSCERTIFICATETYPE'
      - 'TDSCODE'
      - 'TDSCODEDESCRIPTION'
      - 'TDSDETAILDESCRIPTION'
      - 'TDSSECTIONCODE'
  HASHDIFF_AUG_PARTY_PREFERENCE_PROFILE:
    is_hashdiff: true
    columns:
      - 'ELECTRONICPOLICYISSUANCEPREFERENCEINDICATOR'
      - 'PREFERREDLOCATION'
      - 'PROPAGATECONTACTUPDATETOALLPOLICIESINDICATOR'
  HASHDIFF_AUG_PARTY_PROVIDER_CAPABILITY:
    is_hashdiff: true
    columns:
      - 'DEDICATEDCAPACITY'
      - 'YEAROFPURCHASE'
  HASHDIFF_AUG_PARTY_RECORD_REMARKS:
    is_hashdiff: true
    columns:
      - 'GENERALREMARKS'
      - 'MANUALREMARK'
      - 'SPECIALREMARKS'
      - 'TEAMLEADERREMARK'
  HASHDIFF_AUG_PARTY_RELATIONSHIP_PROFILE:
    is_hashdiff: true
    columns:
      - 'EMPLOYEERELATIONSHIPDETAIL'
      - 'EXISTINGCUSTOMERINDICATOR'
      - 'GROUPCOMPANYRELATIONSHIPDECLARATION'
      - 'HNIRELATIONSHIPDETAIL'
      - 'PRIVERELATIONSHIPDETAIL'
      - 'REFERENCECODE'
      - 'REFERENCENAME'
      - 'RELATEDTOINSURERGROUPINDICATOR'
      - 'RELATIONSHIPOWNERMANAGERNAME'
      - 'TRANSACTSWITHOTHEROFFICEINDICATOR'
  HASHDIFF_AUG_PARTY_SERVICE_ENGAGEMENT_TERMS:
    is_hashdiff: true
    columns:
      - 'AGREEDREPORTSUBMISSIONTAT'
      - 'ALLOCATIONTHRESHOLDLEVEL'
      - 'EVIDENCERETENTIONTHREEYEARSINDICATOR'
      - 'OUTSOURCINGJUSTIFICATION'
      - 'TASKALLOCATIONTHRESHOLD'
      - 'TRAININGREQUIREDFORPROVIDEREMPLOYEESINDICATOR'
  HASHDIFF_AUG_PARTY_SUSPENSION_NEGATIVE_ACTION:
    is_hashdiff: true
    columns:
      - 'SUSPENSIONCATEGORY'
      - 'SUSPENSIONEFFECTIVEDATE'
      - 'SUSPENSIONEXPIRYDATE'
      - 'SUSPENSIONINDICATOR'
      - 'SUSPENSIONREASON'
  HASHDIFF_AUG_PARTY_VEHICLE_OWNER:
    is_hashdiff: true
    columns:
      - 'AUTOMOBILEASSOCIATIONMEMBERSHIPNUMBER'
  HASHDIFF_AUG_PROVIDER_BANKING:
    is_hashdiff: true
    columns:
      - 'ADVANCEAMOUNT'
      - 'ADVANCEPAYMENTAPPLICABLEINDICATOR'
      - 'ADVANCEPAYMENTENDDATE'
      - 'ADVANCEPAYMENTSTARTDATE'
      - 'BANKACCOUNTDETAILTEXT'
      - 'CHARGEFILEREFERENCE'
      - 'CREDITCARDACCEPTEDINDICATOR'
      - 'CREDITLIMITAMOUNT'
      - 'CREDITTERMSDETAIL'
      - 'DEDUCTCLAIMSINDICATOR'
      - 'ZEROCHARGEBACKPROGRAMMEENROLLEDINDICATOR'
  HASHDIFF_AUG_PROVIDER_QUALITY:
    is_hashdiff: true
    columns:
      - 'ASSESSMENTERRORDESCRIPTION'
      - 'ASSESSMENTREPORTQUALITYSCORE'
      - 'AVERAGEADMISSIONTIME'
      - 'AVERAGEDISCHARGETIME'
      - 'AVERAGELENGTHOFSTAYMEDICALCASES'
      - 'AVERAGELENGTHOFSTAYSURGICALCASES'
      - 'BEDOCCUPANCYRATE'
      - 'CERTIFICATIONNUMBER'
      - 'CERTIFICATIONTYPE'
      - 'CITYSCORE'
      - 'CSECTIONRATE'
      - 'DISCOUNTSCORE'
      - 'DISCREPANCYNOTED'
      - 'EMPANELMENTRECOMMENDATION'
      - 'EVALUATIONLOGINFORMATION'
      - 'EVALUATIONRECOMMENDATION'
      - 'EVALUATIONREPORTREFERENCE'
      - 'ILMREVIEWFEEDBACK'
      - 'ILMREVIEWREMARKS'
      - 'MEDICALRECORDSCODINGPROCEDURE'
      - 'MONTHLYCASEVOLUMEOTHERINDUSTRYDEDICATED'
      - 'MONTHLYCASEVOLUMEOTHERINDUSTRYTOTAL'
      - 'MONTHLYCASEVOLUMEOTHERINSURERDEDICATED'
      - 'MONTHLYCASEVOLUMEOTHERINSURERTOTAL'
      - 'PROACTIVEDECISIONMAKINGSCORE'
      - 'PROVIDERGRADE'
      - 'PROVIDERQUALIFIER'
      - 'QRSEVALUATIONDATE'
      - 'QRSSTATUS'
      - 'QRSTYPE'
      - 'QUALITYCHECKSTAFFCOUNTDEDICATED'
      - 'QUALITYCHECKSTAFFCOUNTTOTAL'
      - 'REGIONALCOORDINATORREMARK'
      - 'REGULARMEDICALAUDITINDICATOR'
      - 'REPAIRERCONDUCTFEEDBACK'
      - 'SITEVISITCONDUCTEDBY'
      - 'SITEVISITCONDUCTEDINDICATOR'
      - 'SITEVISITDATE'
  HASHDIFF_AUG_PROVIDER_TARIFF:
    is_hashdiff: true
    columns:
      - 'DELAYEDSUBMISSIONDISCOUNTAPPLICABLEINDICATOR'
      - 'DISCOUNTANDLOADINGTERMS'
      - 'DISCOUNTTYPE'
      - 'FLATRATEBASISINDICATOR'
      - 'HOSPITALSPECIFICBILLITEMCODE'
      - 'NEGOTIATIONENDDATE'
      - 'NEGOTIATIONREMARKS'
      - 'NEGOTIATIONSTARTDATE'
      - 'PACKAGEACCEPTANCEDATE'
      - 'PACKAGETYPE'
      - 'STEPDOWNAPPLICABLEINDICATOR'
      - 'SURCHARGEPERCENTAGE'
      - 'TARIFFDOCUMENTREFERENCE'
      - 'TARIFFDOCUMENTSAVAILABLEINDICATOR'
      - 'TARIFFLINEREMARKS'
      - 'TARIFFMASTERUPLOADEDINDICATOR'
      - 'TARIFFSTANDARDISEDINDICATOR'
derived_columns:
  PARTY_BK: "bagic_employee_code"
  PARTY_NK: "'HUB_PARTY|' || (bagic_employee_code)"
  ACTIVATIONDEACTIVATIONREASON: "reason_for_activationdeactivation"
  ADDITIONALDETAILSREMARKS: "other_details"
  ADDRESSPROOFTYPE: "address_proof"
  ADVANCEAMOUNT: "advance_amount"
  ADVANCEPAYMENTAPPLICABLEINDICATOR: "advance_payment_applicable"
  ADVANCEPAYMENTENDDATE: "advance_payment_end_date"
  ADVANCEPAYMENTSTARTDATE: "advance_payment_start_date"
  AFFINITYPARTNEREMPLOYEEINDICATOR: "affinity_partner_employee"
  AGREEDREPORTSUBMISSIONTAT: "tat_to_submit_report"
  ALLOCATIONTHRESHOLDLEVEL: "threshold_level"
  ALTERNATELOCATIONDETAILS: "alternate_location_details"
  APPLICATIONREJECTIONREASON: "rejected_reason"
  APPOINTMENTLETTERISSUEDATE: "date_of_issue_of_appointment"
  APPRECIATIONDISPLAYCOUNTER: "appreciation_display_counter"
  APPROVEDBYREFERENCE: "approved_by"
  ASSESSMENTDATE: "date_of_assessment"
  ASSESSMENTERRORDESCRIPTION: "error_committed_during_assessment"
  ASSESSMENTREPORTQUALITYSCORE: "quality_of_assessment_report"
  ASSIGNEDTOILMINDICATOR: "assign_to_ilm"
  AUTHORISEDPERSONNUMBER: "ap_number"
  AUTHORISINGMANUFACTURERNAME: "authorized_by_mfg_co_name"
  AUTOMOBILEASSOCIATIONMEMBERSHIPNUMBER: "automobile_association_membership_no"
  AVERAGEADMISSIONTIME: "average_admission_time"
  AVERAGEDISCHARGETIME: "average_discharge_time"
  AVERAGEINSURERCASEALLOCATIONCOUNT: "average_bagic_allocationfor_bagic"
  AVERAGELENGTHOFSTAYMEDICALCASES: "average_length_of_stay_for_medical_cases"
  AVERAGELENGTHOFSTAYSURGICALCASES: "average_length_of_stay_for_surgical_cases"
  AVERAGETOTALCASEALLOCATIONCOUNT: "average_bagic_allocationtotal"
  BANKACCOUNTDETAILTEXT: "provider_bank_details"
  BANKINGDETAILSDESCRIPTION: "banking_details"
  BASICQUALIFICATIONDETAILS: "basic_qualifications_details"
  BASICQUALIFICATIONROLLNUMBER: "roll_no_for_basic_qualification"
  BEDOCCUPANCYRATE: "bed_occupancy_rate_in_hospital"
  BENEFICIARYNAMELIST: "beneficiary_names"
  BLACKLISTDATE: "date_of_blacklisting"
  BLACKLISTREASON: "reason_for_blacklisting"
  BLOCKUNBLOCKSTATUS: "blockunblock_status"
  BRANCHMANAGERUSERIDENTIFIER: "bm_username"
  BUSINESSDESCRIPTION: "business_details"
  BUSINESSSECTORCODE: "sector_selection"
  CALCULATORURNNUMBER: "calculator_urn_number"
  CANCELLATIONPORTION: "cancel_portion"
  CANDIDATEBACKGROUNDDESCRIPTION: "background_of_candidate"
  CASHBACKOFFER: "cash_back_offer"
  CATEGORYVALUE: "category_value"
  CERTIFICATIONNUMBER: "certification_no"
  CERTIFICATIONTYPE: "certification"
  CHARGEFILEREFERENCE: "charge_file_details"
  CHEQUERECEIPTINGBLOCKEDINDICATOR: "cheque_receipting_blocked"
  CHEQUERECEIPTINGBLOCKREASON: "remarks_for_cheque_receipting_blocked"
  CITYSCORE: "score_of_city"
  CKYCDETAILS: "claim_ckyc_details"
  CKYCNUMBERHELDINDICATOR: "do_you_have_ckyc_number"
  CLAIMAPPLICANTDATEOFBIRTH: "claim_applicant_dob"
  CLAIMAPPLICANTNAME: "claim_applicant_name"
  CLAIMAPPLICANTSALUTATION: "claim_applicant_name_prefix"
  CLAIMREMARKS: "claim_remarks"
  CLAIMSTEAMRECOMMENDATION: "claims_team_recommendation"
  CLIENTGEOGRAPHY: "client_geography"
  CLOSUREBYREFERENCE: "closure_by"
  COMMUNICATIONSKILLSRATING: "communication_skills"
  CONEXPERTISE: "contractors_expertise_in_structureproject"
  CONTACTPERSONDESIGNATION: "designation_of_the_person"
  CONTACTPERSONNAME: "contact_person_name"
  CONTACTVERIFICATIONREQUIREDINDICATOR: "number_validation_required"
  COORDINATINGOFFICEADDRESS: "address_of_the_coordinating_office"
  COUNTRYOFCITIZENSHIP: "country_of_citizenship"
  COUPONREBATEVALUE: "coupon_rebate"
  COUPONTYPE: "coupon_type"
  COURTBENCHNAME: "court_bench_name"
  COURTNAME: "court_name"
  COVEREDAREA: "covered_area_in_kms"
  CREDITCARDACCEPTEDINDICATOR: "credit_card_accepted"
  CREDITLIMITAMOUNT: "credit_limit"
  CREDITLIMITCINNUMBER: "credit_limit_cin_no"
  CREDITTERMSDETAIL: "credit_details"
  CSECTIONRATE: "c_section_rate"
  DEALERCODE: "dealer_code"
  DEALERPROGRAMMETYPE: "dealer_on_program_type"
  DEALERTYPE: "dealer_type"
  DECLARATIONTEXT: "declaration"
  DECLAREDINCOMEAMOUNT: "income2"
  DEDICATEDCAPACITY: "office_yard_space_in_sq_ft_for_bagic"
  DEDICATEDSTAFFCOUNTFORINSURER: "staff_strength_for_bagic"
  DEDICATEDTEAMLEADERCOUNTFORINSURER: "team_leader_for_bagic"
  DEDUCTCLAIMSINDICATOR: "deduct_claims_flag"
  DEFAULTCREDITGLACCOUNTCODE: "cast(null as varchar)"
  DEFAULTDEBITGLACCOUNTCODE: "cast(null as varchar)"
  DELAYEDSUBMISSIONDISCOUNTAPPLICABLEINDICATOR: "delayed_submission_discount_applicable"
  DELISTINGREASON: "reason_for_delisting"
  DEVICEMAKEANDMODEL: "smart_phone_company_namemodel_name"
  DIRECTORANDPARTNERDETAIL: "director_and_partner_details"
  DISABILITYBODYLOCATION: "location_of_disability"
  DISCOUNTANDLOADINGTERMS: "discount_and_loading"
  DISCOUNTSCORE: "score_of_discount"
  DISCOUNTTYPE: "discount_type"
  DISCREPANCYNOTED: "discrepancy"
  DISTRIBUTIONCLASSIFICATION: "distribution"
  DISTRIBUTORCODE: "dstr"
  DOCTORTOBEDRATIO: "doctor_bed_ratio_no_of_medical_practitioners_with_mbbs_qualifications_as_proportion_of_beds"
  DOCTORTOPATIENTRATIO: "span_of_control_doctor_to_patient"
  DRIVINGEXPERIENCEYEARS: "driving_license_experience"
  DRIVINGLICENCEDETAIL: "driving_license_details"
  DSAINDICATOR: "dsa"
  ECOURTMAPPEDINDICATOR: "mapped_with_ecourt"
  EDUCATIONINSTITUTENAME: "institute_name"
  EIAACCOUNTDETAILS: "eia_details"
  EIAAVAILABLEINDICATOR: "eia_available"
  EIACREDITREQUIREDINDICATOR: "eia_credit_required"
  EIALINKEDDATE: "eia_when_linked"
  EIAREQUIREDINDICATOR: "eia_required"
  ELECTRONICPOLICYISSUANCEPREFERENCEINDICATOR: "issue_all_policies_in_electronic_format"
  EMPANELLEDCOMPANIESCOUNT: "no_of_companies_empanelled_with"
  EMPANELLEDINSURERCOUNT: "no_of_insurance_companies_empanelled_with"
  EMPANELMENTRECOMMENDATION: "recommendation"
  EMPANELMENTREQUESTDATE: "empanelment_request_date"
  EMPLOYEEPAINSURANCEINDICATOR: "does_the_service_provider_have_pa_insurance_for_employees"
  EMPLOYEERELATIONSHIPDETAIL: "relationship_with_employee"
  EMPLOYERDETAILS: "employers_details"
  ENDORSEMENTTYPE: "type_of_endorsement"
  ENROLMENTFORMRECEIVEDINDICATOR: "investigator_enrollment_form"
  EVALUATINGASSESSORNAME: "name_of_assessor"
  EVALUATIONLOGINFORMATION: "evaluation_log_information"
  EVALUATIONRECOMMENDATION: "final_rating_and_recommendation"
  EVALUATIONREPORTREFERENCE: "evaluation_report"
  EVIDENCERETENTIONTHREEYEARSINDICATOR: "storage_is_service_provider_ready_to_store_the_copy_of_investigation_reports_evidence_for_3_years"
  EXISTINGCUSTOMERINDICATOR: "are_you_an_existing_bajaj_allianz_customer"
  FATHERORSPOUSENAME: "fatherspouse_name"
  FLATRATEBASISINDICATOR: "flat_rate_basis"
  FLOATACCOUNTACCESSINDICATOR: "agent_float_access"
  FLOATREPLENISHMENTCONDITION: "nf_balance_will_be_replenished_after_clearance_of_receipts"
  FRAUDSUSPICIONENDDATE: "suspected_fraud_expiry_date"
  FRAUDSUSPICIONREASON: "reason_suspected_fraud"
  FRAUDSUSPICIONSTARTDATE: "suspected_fraud_effective_date"
  GENERALREMARKS: "remarks"
  GOVERNMENTBODYTYPE: "type_of_government"
  GROUPBUFFERAMOUNT: "group_buffer"
  GROUPCOMPANYRELATIONSHIPDECLARATION: "provide_a_declaration_to_confirm_that_the_service_provider_relationship_with_any_bajaj_group"
  GROUPCOMPANYSOURCEDINDICATOR: "search_from_gc"
  GROUPHEALTHUSERTYPE: "gh_type_of_user"
  HNIFLAG: "hni_flag"
  HNIRELATIONSHIPDETAIL: "relationship_with_hni"
  HOSPITALDOCUMENTSAVAILABLEINDICATOR: "view_hospital_docs"
  HOSPITALSPECIFICBILLITEMCODE: "hospital_speciific_item_codes_in_bill"
  ICUDOCTORCOUNT: "no_of_doctors_exclusively_available_for_icu"
  ICUDOCTORTOBEDRATIO: "doctorpatientbed_ratio_in_icu_no_of_medical_practitioners_exclusively_for_icu_as_proportion_of_beds_in_icu"
  ICUNURSETOBEDRATIO: "nursepatient_bed_ratio_in_icu_number_of_qualified_nurses_exclusively_for_icu_as_proportion_of_beds_in_icu"
  ILMREVIEWFEEDBACK: "ilm_feedback"
  ILMREVIEWREMARKS: "ilm_remarks"
  INCOMEBANDLOWERBOUND: "cast(null as varchar)"
  INCOMEBANDUPPERBOUND: "cast(null as varchar)"
  INCOMETAXRETURNFILEDLASTTWOYEARSINDICATOR: "filed_it_last_2_years"
  INFRASTRUCTURESUBSECTOR: "infrastructure_subsector"
  INITIATEDBYREFERENCE: "initiated_by"
  INSURANCEBANKINGFINANCIALSERVICESEXPERIENCE: "insurancebankingfinancial_experience"
  INSURANCEINDUSTRYEXPERIENCEINDICATOR: "whether_you_have_worked_with_insurance_or_not"
  INSUREDOCCUPATIONDETAIL: "insured_occupation_details"
  INSUREDTYPE: "type_of_insured"
  INSURERVISITCONDUCTEDINDICATOR: "visited_by_bagic_person"
  INTERIMPAYMENTINDICATOR: "interim_payment"
  INTERMEDIARYLICENCENUMBER: "license_number"
  INVESTIGATIONFIELDEXPERIENCEYEARS: "total_working_experience_in_investigation_field"
  IRDAICATEGORY: "irda_category"
  IRDAIPRIMARYPROFESSION: "irda_list_primary_profession"
  IRDAIUNIQUEIDENTIFIER: "irda_unique_id"
  KYCDETAIL: "kyc_details"
  KYCRELATEDDETAIL: "kyc_related_details"
  LICENCEDETAIL: "license_details"
  LKQPARTSACCEPTEDINDICATOR: "lkq_parts_accepted"
  LOWERTDSCERTIFICATEREFERENCE: "lower_tds_certificate"
  MACTCASESHANDLEDOTHERCOMPANYCOUNT: "no_of_mact_case_handled_other_company"
  MANAGERCONFIDENTIALREPORT: "manager_confidential_report"
  MANAGERRECOMMENDATIONONVENDOR: "manager_recommendation_on_vendor"
  MANDATORYDOCUMENTSUBMITTEDINDICATOR: "mandatory_document"
  MANUALREMARK: "manual_remark"
  MARRIAGEANNIVERSARYDATE: "date_of_marriage"
  MATRICULATIONQUALIFICATIONDETAIL: "matriculat"
  MEDICALRECORDSCODINGPROCEDURE: "coding_procedure_followed_by_medical_records_department"
  MEMBERTYPE: "member_type"
  MINIMUMSALESCOMMITMENT: "min_sales"
  MONTHLYCASEVOLUMEOTHERINDUSTRYDEDICATED: "volume_of_cases_from_other_industry_monthlyfor_bagic"
  MONTHLYCASEVOLUMEOTHERINDUSTRYTOTAL: "volume_of_cases_from_other_industry_monthly_total"
  MONTHLYCASEVOLUMEOTHERINSURERDEDICATED: "volume_of_cases_from_other_insurance_company_monthlyfor_bagic"
  MONTHLYCASEVOLUMEOTHERINSURERTOTAL: "volume_of_cases_from_other_insurance_company_monthlytotal"
  MONTHLYGROSSINCOME: "monthly_gross_income"
  MOTHERSMAIDENNAME: "mothers_maiden_name"
  MOUDETAIL: "mou_details"
  MOUREVISIONDATE: "date_of_mou_revision"
  MOUTYPE: "type_of_mou"
  MOUVALIDITYENDDATE: "mou_validity_end_date"
  MOUVALIDITYSTARTDATE: "mou_validity_start_date"
  NABHACCREDITATIONLEVEL: "nabh_accreditation_level"
  NAMEASPERIDENTIFICATION: "coalesce(name_as_per_aadhaar, name_as_per_ckyc, name_as_per_pan)"
  NATIONALTIEUPINFORMATION: "national_tieup_information"
  NEARESTSERVICINGBRANCHREFERENCE: "nearest_dm_branch"
  NEFTREGISTRATIONSTATUS: "cast(null as varchar)"
  NEGOTIATIONENDDATE: "hospital_tariff_under_negotiation_end_date"
  NEGOTIATIONREMARKS: "hospital_tariff_under_negotiation_remarks"
  NEGOTIATIONSTARTDATE: "hospital_tariff_under_negotiation_start_date"
  NETWORKSTATUSREMARK: "hospital_status_remark"
  NOMINEEDETAIL: "nominee_detail"
  NONDISCLOSUREAGREEMENTSTATUS: "nondisclosure_initiated"
  NOOFBRIEFS: "no_of_briefs"
  NORMALOFFER: "normal_offer"
  NUMBEROFDAUGHTERS: "number_of_daughters"
  NUMBEROFSONS: "number_of_son"
  OCCUPATIONLIST: "occupation_list"
  OFFICEFIREINSURANCEINDICATOR: "does_the_service_provider_have_fire_insurance_policy_for_his_office"
  OFFICEMANAGERNAME: "office_manager"
  ONLINEPROVIDERREFERENCENUMBER: "online_hospital_reference_number"
  OPERATINGHOURSDESCRIPTION: "operating_hrs"
  OPERATINGLOCATIONRESTRICTION: "location_restriction"
  OPERATIONBASETYPE: "operation_from_office_or_residence_or_office_cum_residence_total"
  OPERATIONPLACE: "place_of_operation"
  OPERATIONPLACEFORINSURERWORK: "operation_from_office_or_residence_or_office_cum_residence_for_bagic"
  OPTIONALPROOFOFPOSSESSIONTYPE: "pop_optional"
  ORIGINCOMP: "origin_of_the_company"
  ORIGINCONT: "origin_of_the_contractor"
  OTHEROCCUPATION: "other_occupation"
  OTHERQUALIFICATION: "other_qualification"
  OTHERRELATEDENTITIES: "other_entities"
  OTHERSERVICESDESCRIPTION: "other_services"
  OUTSOURCINGJUSTIFICATION: "why_the_investigation_to_be_outsourced_to_this_service_provider"
  OVDCATEGORYOTHERDETAIL: "proof_of_address_submitted_for_current_permanent_overseas_addressothers"
  OVERALLEXPERIENCEDESCRIPTION: "overall_experience"
  OWNERSHIPTYPE: "ownership"
  PACKAGEACCEPTANCEDATE: "package_acceptance_date"
  PACKAGETYPE: "package_type"
  PANAADHARLINKED: "pan_aadhaar_linked"
  PANAPPLIEDINDICATOR: "pan_applied_for"
  PANAPPNO: "pan_application_no"
  PANELDOCTORDETAILS: "provider_doctor_details"
  PARTNERDESCRIPTION: "partner_details"
  PARTYENDDATE: "cast(null as varchar)"
  PARTYENDORSEMENTTYPE: "type_of_endorsement_for_party"
  PARTYREMARKS: "additional_remarks"
  PASSPORTFILENUMBER: "passport_file_no"
  PASSPORTISSUINGCOUNTRY: "passport_issue_country"
  PAYCLAIMSCANCELMONTHLYINDICATOR: "pay_claims_cancel_monthly"
  PAYEECODE: "pay_code"
  PAYEENAME: "payee"
  PAYEETYPE: "cast(null as varchar)"
  PAYMENTDETAILSDESCRIPTION: "payment_details"
  PAYMENTMODE: "payment_mode"
  PAYMENTPLAN: "payment_plan"
  PAYMENTSCHEDULE: "payment_schedule"
  PERFORMANCEEVALUATIONFORMREFERENCE: "surveyor_performance_evaluation_form"
  PERFORMANCEEVALUATIONOUTCOME: "surveyor_performance_evaluation_report"
  PERSONALDETAILSDESCRIPTION: "personal_details"
  PORTALACCESSSTATUS: "repairer_portal_status"
  POSTGRADUATEQUALIFICATION: "postgrad"
  PPNTYPE: "ppn_types"
  PREFERREDALERTMODE: "preferred_mode_of_alert"
  PREFERREDLOCATION: "preferred_location"
  PREMIUMPAYERTYPE: "premium_payer"
  PREVIOUSEMPLOYERLOCATION: "previous_company_location"
  PREVIOUSEMPLOYERPARENTINTERMEDIARYCODE: "previous_company_parent_imd_code"
  PREVIOUSEMPLOYERPARENTSUBINTERMEDIARYCODE: "previous_company_parent_subimd_code"
  PREVIOUSENGAGEMENTDETAIL: "previous_details"
  PREVIOUSNONGENERALINSURERNAME: "name_of_nongeneral_insurer_worked_for"
  PREVIOUSPROVIDERREFERENCE: "previous_provider_reference"
  PRIMARYPROOFOFPOSSESSIONTYPE: "pop_primary"
  PRINTZONECODE: "print_zone"
  PRIORITY: "provider_priority"
  PRIVEFLAG: "prive_flag"
  PRIVERELATIONSHIPDETAIL: "relationship_with_prive"
  PROACTIVEDECISIONMAKINGSCORE: "proactive_approach_in_decision_making"
  PROFESSIONALINDEMNITYCOVERINDICATOR: "medical_establishment_indemnity_cover_present"
  PROFESSIONALQUALIFICATION: "professional_qualification"
  PROFILECODE: "profile"
  PROOFOFADDRESSSTATUS: "poa_status"
  PROOFOFIDENTITYSTATUS: "poi_status"
  PROPAGATECONTACTUPDATETOALLPOLICIESINDICATOR: "update_contact_details_in_all_policies"
  PROVIDERGRADE: "hospital_grade"
  PROVIDERPROFILEDESCRIPTION: "profile_of_the_service_provider"
  PROVIDERQUALIFIER: "hospital_qualifier"
  QRSEVALUATIONDATE: "qrs_date"
  QRSSTATUS: "qrs_status"
  QRSTYPE: "qrs_type"
  QUALIFICATIONBOARDNAME: "board_name_for_basic_qualification"
  QUALIFICATIONDETAIL: "qualification_details"
  QUALIFICATIONPASSINGMONTH: "month_of_passing"
  QUALITYCHECKSTAFFCOUNTDEDICATED: "quality_check_for_bagic"
  QUALITYCHECKSTAFFCOUNTTOTAL: "quality_check_total"
  REACTIVATIONDATE: "reactivation_date"
  REACTIVATIONREASON: "reason_for_reactivation"
  REASONFORLEAVINGPREVIOUSEMPLOYER: "reason_for_leaving_remarks"
  RECORDEFFECTIVEDATE: "effective_date"
  RECORDENDDATE: "end_date"
  REFERENCECODE: "reference_code"
  REFERENCENAME: "reference"
  REFUNDBENEFICIARYPARTYREFERENCE: "refund_to_pid_of_bg_holder_ac"
  REGIONALCOORDINATORREMARK: "rc_regional_coordinators_remark"
  REGISTEREDBUSINESSTRUSTINDICATOR: "is_the_organisation_a_registered_business_trust"
  REGISTEREDCOMPANYINDICATOR: "are_you_registered_company"
  REGISTEREDINDICATOR: "register_flag"
  REGULARMEDICALAUDITINDICATOR: "medical_audit_on_regular_basis"
  RELATEDPARTYRELATIONSHIPTYPE: "relationship"
  RELATEDTOINSURERGROUPINDICATOR: "any_relation_with_bajaj_group"
  RELATIONSHIPASSOCIATEEMPLOYEECODE: "ra_ecode"
  RELATIONSHIPOTHERDETAIL: "other_relationship"
  RELATIONSHIPOWNERMANAGERNAME: "name_of_the_zonal_or_national_manager"
  REPAIRERCONDUCTFEEDBACK: "feed_back_from_repairer_behavior"
  REPORTTIMELINESSRATING: "timely_submission_of_report"
  REPRESENTEDBUSINESSNAME: "business_company"
  REQUIREDDOCUMENTSSUBMITTEDINDICATOR: "submission_of_required_documents"
  RESIGNATIONSUBMITTEDDATE: "date_of_submitting_resignation"
  REWARDSCHEMEAPPLICABLEINDICATOR: "applicable_for_reward"
  SAMEASCORRESPONDENCEADDRESSINDICATOR: "flag_indicating_if_current_permanent_overseas_address_is_same_as_correspondence_local_address"
  SELLINGDEALERREFERENCE: "selling_dealer"
  SERVICEENGAGEMENTSTATUS: "service_status"
  SERVICELOCATORPROVIDERINDICATOR: "is_a_service_locator_provider"
  SERVICEREMARKS: "service_remarks"
  SERVICETAXAPPLICABLEINDICATOR: "service_tax"
  SERVICETAXCERTIFICATESUBMITTEDINDICATOR: "service_tax_copy"
  SERVICINGAGENTREFERENCE: "servicing_agent"
  SINGLESPECIALITYINDICATOR: "single_speciality"
  SITEVISITCONDUCTEDBY: "hospital_visited_by"
  SITEVISITCONDUCTEDINDICATOR: "hospital_visited"
  SITEVISITDATE: "hospital_visit_date"
  SKILLSETDESCRIPTION: "skills"
  SOURCELASTMODIFIEDDATE: "cast(null as varchar)"
  SPECIALISEDREPAIRERMAKE: "specialized_to_repairer_make"
  SPECIALREMARKS: "special_remarks"
  STATUSREASONOTHERDETAIL: "other_reasons"
  STEPDOWNAPPLICABLEINDICATOR: "step_down_applicable"
  SUPPLIERDETAILDESCRIPTION: "supplier_details"
  SUPPLIERLOCATIONDESCRIPTION: "supplier_location"
  SUPPLIERNAME: "supplier_name"
  SURCHARGEPERCENTAGE: "surcharge"
  SURVEYORTYPE: "type_of_surveyor"
  SUSPENSIONCATEGORY: "suspended_category"
  SUSPENSIONEFFECTIVEDATE: "suspended_effective_date"
  SUSPENSIONEXPIRYDATE: "suspended_expiry_date"
  SUSPENSIONINDICATOR: "suspended"
  SUSPENSIONREASON: "suspended_reason"
  TARIFFDOCUMENTREFERENCE: "hospital_tariff_docs"
  TARIFFDOCUMENTSAVAILABLEINDICATOR: "view_tariff_docs"
  TARIFFLINEREMARKS: "step_down_option_for_room_rent_remarks"
  TARIFFMASTERUPLOADEDINDICATOR: "tariff_master_upload"
  TARIFFSTANDARDISEDINDICATOR: "tariff_standardization"
  TASKALLOCATIONTHRESHOLD: "task_threshold"
  TDSCERTIFICATEISSUEDATE: "cast(null as varchar)"
  TDSCERTIFICATENUMBER: "cast(null as varchar)"
  TDSCERTIFICATETYPE: "cast(null as varchar)"
  TDSCODE: "tds_code"
  TDSCODEDESCRIPTION: "tds_code_desc"
  TDSDETAILDESCRIPTION: "tds_details"
  TDSSECTIONCODE: "cast(null as varchar)"
  TEACHINGINSTITUTIONINDICATOR: "teaching_or_training"
  TEAMLEADERREMARK: "tl_remark"
  TECHNICALSECTIONCODE: "technical_section"
  TOTALTEAMLEADERCOUNT: "team_leader_total"
  TOTALTEAMSTRENGTH: "total_team_strength"
  TOTALWORKEXPERIENCEYEARS: "no_of_years_of_work_experience"
  TOTALYEARSOFEXPERIENCE: "years_of_experience"
  TPACOORDINATOREMAILADDRESS: "tpa_coordinator_email_id"
  TPACOORDINATORMOBILENUMBER: "tpa_coordinator_mobile_no"
  TPACOORDINATORNAME: "tpa_coordinator_name"
  TPADESKOPERATINGHOURSSUNDAY: "tpa_timings_for_sun"
  TPADESKOPERATINGHOURSWEEKDAY: "tpa_timings_mon_to_sat"
  TRAINEDPRODUCTREFERENCE: "which_product_training"
  TRAININGREQUIREDFORPROVIDEREMPLOYEESINDICATOR: "training_is_required_to_be_given_to_the_employees_of_the_service_provider"
  TRAININGREQUIREDINDICATOR: "requirement_of_training"
  TRANSACTSWITHOTHEROFFICEINDICATOR: "transacts_business_with_other_bagic_office_also"
  TRANSFERCASEINDICATOR: "transfer_case"
  TRANSFERINDICATOR: "transfer"
  UNDERGRADUATEQUALIFICATION: "undergrad"
  USEDCARDEALERINDICATOR: "used_car_dealer"
  USERTYPE: "type_of_user"
  VEHICLEMAKESHANDLED: "makes_sold"
  VENDOREVALUATIONOUTCOME: "vendor_evaluation"
  VENDOREVALUATIONTEMPLATEREFERENCE: "vendor_evaluation_template"
  VISITINGCONSULTANTCOUNT: "no_of_consultant_who_are_not_on_rolls_of_the_hospital"
  VISITINGSURGEONCOUNT: "no_of_surgeons_or_interventionistsnot_on_full_time_roll_of_hospital"
  WEBSITEURL: "webaddress"
  WORKSHOPCATEGORY: "workshop_category"
  WORKSHOPCLASS: "workshop_class"
  YEAROFESTABLISHMENT: "year_of_establishment_of_contractors_firm"
  YEAROFPASSINGQUALIFICATION: "year_of_passing"
  YEAROFPURCHASE: "year_of_purchase"
  ZEROCHARGEBACKPROGRAMMEENROLLEDINDICATOR: "enrolled_in_zero_chargeback_pgrm"
  ZONECODE: "zone"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!pd_prop_sp_pv'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                     source_model=metadata_dict['source_model'],
                     hashed_columns=metadata_dict['hashed_columns'],
                     derived_columns=metadata_dict['derived_columns']) }}
