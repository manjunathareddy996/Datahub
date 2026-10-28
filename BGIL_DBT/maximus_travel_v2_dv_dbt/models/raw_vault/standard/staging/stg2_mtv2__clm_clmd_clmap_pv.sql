{{ config(materialized='view') }}

-- WIDE stage() for Maximus Travel V2 view
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
-- Covers this view's 32 key slot(s) and its 33 1:1 satellite target(s) in one pass,
-- with a separately-named hashdiff per satellite so each is scoped to its own payload.
-- The bare HASHDIFF the sibling contract requires is produced by the satfeed layer,
-- which is the only place one name can serve one satellite (BD7).
--
-- Fan-in families on this view, if any, are handled by the unpivot layer instead: one
-- row per instance cannot be expressed as columns of one row here.
--
-- Every BK is the guarded rendering. When every non-literal operand is blank the key is
-- NULL, the hub feed drops it, and audit_mtv2_key_rejections counts the drop per hub per
-- feeder -- so a zero is a measured zero (directive D-REJECT).
--
--   CLAIM_HKEY                         HUB_CLAIM  (107 row(s) in the map)
--   CLAIM_HKEY__CLAIM_COURT_COUNTERPARTY HUB_CLAIM / claim-court-counterparty  (1 row(s) in the map)
--   CLAIM_HKEY__LINKED_CLAIM           HUB_CLAIM / linked-claim  (1 row(s) in the map)
--   CLAIM_PARTY_HKEY__CLAIM_COURT_COUNTERPARTY LNK_CLAIM_PARTY / claim-court-counterparty  LINK
--   DISTRIBUTION_CHANNEL_HKEY__DEALER  HUB_DISTRIBUTION_CHANNEL / dealer  (1 row(s) in the map)
--   DISTRIBUTION_CHANNEL_HKEY__INTERMEDIARY HUB_DISTRIBUTION_CHANNEL / intermediary  (2 row(s) in the map)
--   DOCUMENT_HKEY__CLAIM_INWARD        HUB_DOCUMENT / claim-inward  (2 row(s) in the map)
--   DOCUMENT_HKEY__CLAIM_INWARD_DOCUMENT_SET HUB_DOCUMENT / claim-inward-document-set  (7 row(s) in the map)
--   LOCATION_HKEY__CLAIMANT_CORRESPONDENCE_ADDRESS HUB_LOCATION / claimant-correspondence-address  (4 row(s) in the map)
--   LOCATION_HKEY__CLAIM_CORRESPONDENCE_ADDRESS HUB_LOCATION / claim-correspondence-address  (4 row(s) in the map)
--   LOCATION_HKEY__CLAIM_LOSS_LOCATION HUB_LOCATION / claim-loss-location  (1 row(s) in the map)
--   LOCATION_HKEY__CLAIM_REFERENCE_ADDRESS HUB_LOCATION / claim-reference-address  (1 row(s) in the map)
--   LOCATION_HKEY__CUSTOMER_ANALYTICS_LOCATION HUB_LOCATION / customer-analytics-location  (3 row(s) in the map)
--   LOCATION_HKEY__INSPECTION_ADDRESS  HUB_LOCATION / inspection-address  (1 row(s) in the map)
--   LOCATION_HKEY__STORED_COUNTRY      HUB_LOCATION / stored-country  (1 row(s) in the map)
--   LOCATION_HKEY__STORED_STATE        HUB_LOCATION / stored-state  (1 row(s) in the map)
--   LOSS_EVENT_HKEY                    HUB_LOSS_EVENT  (4 row(s) in the map)
--   LOSS_EVENT_HKEY__V2                HUB_LOSS_EVENT  (12 row(s) in the map)
--   ORG_UNIT_HKEY__COMPANY             HUB_ORG_UNIT / company  (1 row(s) in the map)
--   ORG_UNIT_HKEY__OPERATING_HUB       HUB_ORG_UNIT / operating-hub  (1 row(s) in the map)
--   PARTY_HKEY__CLAIMANT_CORRESPONDENCE_ADDRESS HUB_PARTY / claimant-correspondence-address  (1 row(s) in the map)
--   PARTY_HKEY__CLAIMANT_CUSTOMER      HUB_PARTY / claimant-customer  (34 row(s) in the map)
--   PARTY_HKEY__CLAIM_COURT_COUNTERPARTY HUB_PARTY / claim-court-counterparty  (1 row(s) in the map)
--   PARTY_HKEY__INSURED_CUSTOMER       HUB_PARTY / insured-customer  (24 row(s) in the map)
--   PARTY_HKEY__INSURED_MEMBER         HUB_PARTY / insured-member  (2 row(s) in the map)
--   PARTY_HKEY__SERVICE_PARTNER        HUB_PARTY / service-partner  (1 row(s) in the map)
--   PARTY_HKEY__SUB_INTERMEDIARY       HUB_PARTY / sub-intermediary  (2 row(s) in the map)
--   PARTY_LOCATION_HKEY__CLAIMANT_CORRESPONDENCE_ADDRESS LNK_PARTY_LOCATION / claimant-correspondence-address  LINK
--   POLICY_HKEY                        HUB_POLICY  (12 row(s) in the map)
--   POLICY_HKEY__MASTER_POLICY         HUB_POLICY / master-policy  (1 row(s) in the map)
--   PRODUCT_HKEY                       HUB_PRODUCT  (3 row(s) in the map)
--   RISK_OBJECT_HKEY__CLAIMED_RISK_ITEM HUB_RISK_OBJECT / claimed-risk-item  (3 row(s) in the map)
--   HASHDIFF_CHANNEL_DEFINITION        SAT_CHANNEL_DEFINITION payload 1 of 5 live here
--   HASHDIFF_CLAIM_BENEFIT_HEAD        SAT_CLAIM_BENEFIT_HEAD payload 1 of 7 live here
--   HASHDIFF_CLAIM_CO_RI_SHARE         SAT_CLAIM_CO_RI_SHARE payload 2 of 3 live here
--   HASHDIFF_CLAIM_FNOL                SAT_CLAIM_FNOL payload 7 of 7 live here
--   HASHDIFF_CLAIM_FRAUD               SAT_CLAIM_FRAUD payload 5 of 6 live here
--   HASHDIFF_CLAIM_HEADER              SAT_CLAIM_HEADER payload 11 of 14 live here
--   HASHDIFF_CLAIM_HEALTH_DETAIL       SAT_CLAIM_HEALTH_DETAIL payload 2 of 9 live here
--   HASHDIFF_CLAIM_LITIGATION          SAT_CLAIM_LITIGATION payload 2 of 3 live here
--   HASHDIFF_CLAIM_REPUDIATION         SAT_CLAIM_REPUDIATION payload 1 of 1 live here
--   HASHDIFF_CLAIM_TRAVEL_DETAIL       SAT_CLAIM_TRAVEL_DETAIL payload 1 of 6 live here
--   HASHDIFF_COMMON_ADDRESS            SAT_COMMON_ADDRESS payload 7 of 16 live here
--   HASHDIFF_COMMON_ADMIN_GEOGRAPHY    SAT_COMMON_ADMIN_GEOGRAPHY payload 5 of 5 live here
--   HASHDIFF_COMMON_CLASSIFICATION     SAT_COMMON_CLASSIFICATION payload 1 of 4 live here
--   HASHDIFF_COMMON_CONSENT            SAT_COMMON_CONSENT payload 1 of 1 live here
--   HASHDIFF_DOCUMENT_DEFINITION       SAT_DOCUMENT_DEFINITION payload 3 of 6 live here
--   HASHDIFF_LOSS_EVENT_DETAIL         SAT_LOSS_EVENT_DETAIL payload 7 of 7 live here
--   HASHDIFF_LOSS_EVENT_NOTIFICATION   SAT_LOSS_EVENT_NOTIFICATION payload 1 of 1 live here
--   HASHDIFF_LOSS_LOCATION_ADDRESS     SAT_LOSS_LOCATION_ADDRESS payload 4 of 4 live here
--   HASHDIFF_PARTY_BANKING             SAT_PARTY_BANKING payload 6 of 7 live here
--   HASHDIFF_PARTY_CLAIM_HISTORY       SAT_PARTY_CLAIM_HISTORY payload 1 of 1 live here
--   HASHDIFF_PARTY_CORRESPONDENCE      SAT_PARTY_CORRESPONDENCE payload 0 of 0 live here
--   HASHDIFF_PARTY_FINANCIAL_PROFILE   SAT_PARTY_FINANCIAL_PROFILE payload 1 of 2 live here
--   HASHDIFF_PARTY_IDENTITY            SAT_PARTY_IDENTITY payload 2 of 15 live here
--   HASHDIFF_PARTY_POLICY_HISTORY      SAT_PARTY_POLICY_HISTORY payload 1 of 1 live here
--   HASHDIFF_PARTY_PORTFOLIO_SUMMARY   SAT_PARTY_PORTFOLIO_SUMMARY payload 1 of 1 live here
--   HASHDIFF_PARTY_RELATIONSHIP_PROFILE SAT_PARTY_RELATIONSHIP_PROFILE payload 1 of 1 live here
--   HASHDIFF_POLICY_CLASSIFICATION     SAT_POLICY_CLASSIFICATION payload 1 of 1 live here
--   HASHDIFF_POLICY_COVERAGE_SCHEDULE  SAT_POLICY_COVERAGE_SCHEDULE payload 2 of 8 live here
--   HASHDIFF_POLICY_HEADER             SAT_POLICY_HEADER payload 3 of 19 live here
--   HASHDIFF_POLICY_RENEWAL            SAT_POLICY_RENEWAL payload 2 of 2 live here
--   HASHDIFF_POLICY_SERVICING_SUMMARY  SAT_POLICY_SERVICING_SUMMARY payload 1 of 1 live here
--   HASHDIFF_PRODUCT_DEFINITION        SAT_PRODUCT_DEFINITION payload 2 of 4 live here
--   HASHDIFF_RISK_OBJECT_CORE          SAT_RISK_OBJECT_CORE payload 2 of 6 live here

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__clm_clmd_clmap_pv'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  CLAIM_HKEY__CLAIM_COURT_COUNTERPARTY: 'CLAIM_NK__CLAIM_COURT_COUNTERPARTY'
  CLAIM_HKEY__LINKED_CLAIM: 'CLAIM_NK__LINKED_CLAIM'
  CLAIM_PARTY_HKEY__CLAIM_COURT_COUNTERPARTY: 'CLAIM_PARTY_NK__CLAIM_COURT_COUNTERPARTY'
  DISTRIBUTION_CHANNEL_HKEY__DEALER: 'DISTRIBUTION_CHANNEL_NK__DEALER'
  DISTRIBUTION_CHANNEL_HKEY__INTERMEDIARY: 'DISTRIBUTION_CHANNEL_NK__INTERMEDIARY'
  DOCUMENT_HKEY__CLAIM_INWARD: 'DOCUMENT_NK__CLAIM_INWARD'
  DOCUMENT_HKEY__CLAIM_INWARD_DOCUMENT_SET: 'DOCUMENT_NK__CLAIM_INWARD_DOCUMENT_SET'
  LOCATION_HKEY__CLAIMANT_CORRESPONDENCE_ADDRESS: 'LOCATION_NK__CLAIMANT_CORRESPONDENCE_ADDRESS'
  LOCATION_HKEY__CLAIM_CORRESPONDENCE_ADDRESS: 'LOCATION_NK__CLAIM_CORRESPONDENCE_ADDRESS'
  LOCATION_HKEY__CLAIM_LOSS_LOCATION: 'LOCATION_NK__CLAIM_LOSS_LOCATION'
  LOCATION_HKEY__CLAIM_REFERENCE_ADDRESS: 'LOCATION_NK__CLAIM_REFERENCE_ADDRESS'
  LOCATION_HKEY__CUSTOMER_ANALYTICS_LOCATION: 'LOCATION_NK__CUSTOMER_ANALYTICS_LOCATION'
  LOCATION_HKEY__INSPECTION_ADDRESS: 'LOCATION_NK__INSPECTION_ADDRESS'
  LOCATION_HKEY__STORED_COUNTRY: 'LOCATION_NK__STORED_COUNTRY'
  LOCATION_HKEY__STORED_STATE: 'LOCATION_NK__STORED_STATE'
  LOSS_EVENT_HKEY: 'LOSS_EVENT_NK'
  LOSS_EVENT_HKEY__V2: 'LOSS_EVENT_NK__V2'
  ORG_UNIT_HKEY__COMPANY: 'ORG_UNIT_NK__COMPANY'
  ORG_UNIT_HKEY__OPERATING_HUB: 'ORG_UNIT_NK__OPERATING_HUB'
  PARTY_HKEY__CLAIMANT_CORRESPONDENCE_ADDRESS: 'PARTY_NK__CLAIMANT_CORRESPONDENCE_ADDRESS'
  PARTY_HKEY__CLAIMANT_CUSTOMER: 'PARTY_NK__CLAIMANT_CUSTOMER'
  PARTY_HKEY__CLAIM_COURT_COUNTERPARTY: 'PARTY_NK__CLAIM_COURT_COUNTERPARTY'
  PARTY_HKEY__INSURED_CUSTOMER: 'PARTY_NK__INSURED_CUSTOMER'
  PARTY_HKEY__INSURED_MEMBER: 'PARTY_NK__INSURED_MEMBER'
  PARTY_HKEY__SERVICE_PARTNER: 'PARTY_NK__SERVICE_PARTNER'
  PARTY_HKEY__SUB_INTERMEDIARY: 'PARTY_NK__SUB_INTERMEDIARY'
  PARTY_LOCATION_HKEY__CLAIMANT_CORRESPONDENCE_ADDRESS: 'PARTY_LOCATION_NK__CLAIMANT_CORRESPONDENCE_ADDRESS'
  POLICY_HKEY: 'POLICY_NK'
  POLICY_HKEY__MASTER_POLICY: 'POLICY_NK__MASTER_POLICY'
  PRODUCT_HKEY: 'PRODUCT_NK'
  RISK_OBJECT_HKEY__CLAIMED_RISK_ITEM: 'RISK_OBJECT_NK__CLAIMED_RISK_ITEM'
  HASHDIFF_CHANNEL_DEFINITION:
    is_hashdiff: true
    columns:
      - 'CHANNEL_NAME'
      - 'CHANNEL_REMARKS'
      - 'CHANNEL_TYPE'
      - 'SUB_CHANNEL_CODE'
      - 'SUB_CHANNEL_EFFECTIVE_DATE'
  HASHDIFF_CLAIM_BENEFIT_HEAD:
    is_hashdiff: true
    columns:
      - 'APPROVED_AMOUNT'
      - 'BENEFIT_HEAD_CODE'
      - 'CLAIMED_AMOUNT'
      - 'COVERAGE_REFERENCE__SAT_CLAIM_BENEFIT_HEAD'
      - 'DEDUCTION_AMOUNT'
      - 'DEDUCTION_REASON'
      - 'HEAD_DESCRIPTION'
      - 'SUB_LIMIT_APPLIED'
  HASHDIFF_CLAIM_CO_RI_SHARE:
    is_hashdiff: true
    columns:
      - 'CO_INSURANCE_OUR_SHARE_PERCENTAGE'
      - 'EXPENSE_SHARE_AMOUNT'
      - 'LEADER_INDICATOR'
  HASHDIFF_CLAIM_FNOL:
    is_hashdiff: true
    columns:
      - 'FNOL_CHANNEL'
      - 'FNOL_TIME'
      - 'PRELIMINARY_LOSS_DESCRIPTION'
      - 'PRELIMINARY_LOSS_ESTIMATE'
      - 'REPORTED_BY_CONTACT'
      - 'REPORTED_BY_NAME'
      - 'SELF_SERVICE_INDICATOR'
  HASHDIFF_CLAIM_FRAUD:
    is_hashdiff: true
    columns:
      - 'FRAUD_SCORE'
      - 'FRAUD_TRIGGER_REASON'
      - 'FRAUD_TYPE'
      - 'INVESTIGATION_REFERENCE'
      - 'INVESTIGATION_REFERRED_INDICATOR'
      - 'INVESTIGATION_STATUS'
  HASHDIFF_CLAIM_HEADER:
    is_hashdiff: true
    columns:
      - 'CATASTROPHE_CODE'
      - 'CLAIM_CATEGORY'
      - 'CLAIM_HANDLER_REFERENCE'
      - 'CLAIM_REFERENCE_NUMBER'
      - 'CLAIM_STATUS'
      - 'CLAIM_SUB_STATUS'
      - 'CLAIM_TYPE'
      - 'HANDLING_ORG_UNIT_CODE'
      - 'INTIMATED_BY_ROLE'
      - 'INTIMATION_CHANNEL'
      - 'LOSS_DATE'
      - 'NOTIFICATION_DATE'
      - 'PRIORITY_CODE'
      - 'REGISTRATION_DATE'
  HASHDIFF_CLAIM_HEALTH_DETAIL:
    is_hashdiff: true
    columns:
      - 'ADMISSION_DATE'
      - 'AILMENT_DESCRIPTION'
      - 'DISCHARGE_DATE'
      - 'HEALTH_CLAIM_REMARKS'
      - 'ICD_CODE'
      - 'LENGTH_OF_STAY'
      - 'PRE_EXISTING_DISEASE_RELATED_INDICATOR'
      - 'TREATING_DOCTOR_NAME'
      - 'TREATMENT_TYPE'
  HASHDIFF_CLAIM_LITIGATION:
    is_hashdiff: true
    columns:
      - 'AWARD_AMOUNT'
      - 'COURT_NAME'
      - 'COURT_TYPE'
  HASHDIFF_CLAIM_REPUDIATION:
    is_hashdiff: true
    columns:
      - 'REPUDIATION_REASON'
  HASHDIFF_CLAIM_TRAVEL_DETAIL:
    is_hashdiff: true
    columns:
      - 'CLAIM_SUB_TYPE'
      - 'COUNTRY_OF_INCIDENT'
      - 'CURRENCY_OF_LOSS'
      - 'INCIDENT_DATE'
      - 'LOSS_AMOUNT_FOREIGN'
      - 'LOSS_AMOUNT_INR'
  HASHDIFF_COMMON_ADDRESS:
    is_hashdiff: true
    columns:
      - 'ADDRESS_LINE_1'
      - 'ADDRESS_LINE_2'
      - 'ADDRESS_LINE_3'
      - 'ADDRESS_TYPE_CODE'
      - 'CARE_OF_NAME'
      - 'CITY'
      - 'COUNTRY_CODE__SAT_COMMON_ADDRESS'
      - 'COUNTRY_NAME'
      - 'DISTRICT'
      - 'LANDMARK'
      - 'LOCALITY'
      - 'POSTAL_CODE'
      - 'POST_OFFICE_NAME'
      - 'STATE_CODE__SAT_COMMON_ADDRESS'
      - 'STATE_NAME'
      - 'STREET_NAME'
  HASHDIFF_COMMON_ADMIN_GEOGRAPHY:
    is_hashdiff: true
    columns:
      - 'COUNTRY_CODE'
      - 'DISTRICT_NAME'
      - 'STATE_CODE'
      - 'STATE_NAME__SAT_COMMON_ADMIN_GEOGRAPHY'
      - 'TALUKA_NAME'
  HASHDIFF_COMMON_CLASSIFICATION:
    is_hashdiff: true
    columns:
      - 'CATEGORY_CODE'
      - 'SEGMENT_NAME'
      - 'TIER_CODE'
      - 'VALUE_BAND'
  HASHDIFF_COMMON_CONSENT:
    is_hashdiff: true
    columns:
      - 'CONSENT_GIVEN_INDICATOR'
  HASHDIFF_DOCUMENT_DEFINITION:
    is_hashdiff: true
    columns:
      - 'DOCUMENT_NAME'
      - 'DOCUMENT_REFERENCE_NUMBER'
      - 'DOCUMENT_TYPE'
      - 'ISSUE_DATE'
      - 'RECEIVED_DATE'
      - 'SOURCE_CHANNEL'
  HASHDIFF_LOSS_EVENT_DETAIL:
    is_hashdiff: true
    columns:
      - 'CAUSE_OF_LOSS'
      - 'FIR_DATE'
      - 'FIR_NUMBER'
      - 'LOSS_DESCRIPTION'
      - 'LOSS_TIME'
      - 'POLICE_STATION_NAME'
      - 'THIRD_PARTY_INVOLVED_INDICATOR'
  HASHDIFF_LOSS_EVENT_NOTIFICATION:
    is_hashdiff: true
    columns:
      - 'NOTIFIED_BY_ROLE'
  HASHDIFF_LOSS_LOCATION_ADDRESS:
    is_hashdiff: true
    columns:
      - 'ADDRESS_LINE_1__SAT_LOSS_LOCATION_ADDRESS'
      - 'LATITUDE'
      - 'LONGITUDE'
      - 'POSTAL_CODE__SAT_LOSS_LOCATION_ADDRESS'
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
      - 'PRIMARY_ACCOUNT_INDICATOR'
  HASHDIFF_PARTY_CLAIM_HISTORY:
    is_hashdiff: true
    columns:
      - 'TOTAL_CLAIM_AMOUNT'
  HASHDIFF_PARTY_CORRESPONDENCE:
    is_hashdiff: true
    columns:
      - 'DISPATCH_REFERENCE'
  HASHDIFF_PARTY_FINANCIAL_PROFILE:
    is_hashdiff: true
    columns:
      - 'CREDIT_SCORE'
      - 'INCOME_SOURCE'
  HASHDIFF_PARTY_IDENTITY:
    is_hashdiff: true
    columns:
      - 'AGE'
      - 'COUNTRY_OF_BIRTH'
      - 'COUNTRY_OF_RESIDENCE'
      - 'DATE_OF_BIRTH'
      - 'FIRST_NAME'
      - 'GENDER_CODE'
      - 'LAST_NAME'
      - 'MIDDLE_NAME'
      - 'NATIONALITY'
      - 'PARTY_FULL_NAME'
      - 'PARTY_LEGAL_NAME'
      - 'PARTY_STATUS'
      - 'PARTY_SUB_TYPE_CODE'
      - 'PARTY_TYPE_CODE'
      - 'SALUTATION'
  HASHDIFF_PARTY_POLICY_HISTORY:
    is_hashdiff: true
    columns:
      - 'TOTAL_POLICY_COUNT'
  HASHDIFF_PARTY_PORTFOLIO_SUMMARY:
    is_hashdiff: true
    columns:
      - 'ACTIVE_POLICY_COUNT'
  HASHDIFF_PARTY_RELATIONSHIP_PROFILE:
    is_hashdiff: true
    columns:
      - 'TOTAL_PREMIUM_PAID_LIFETIME'
  HASHDIFF_POLICY_CLASSIFICATION:
    is_hashdiff: true
    columns:
      - 'CLASSIFICATION_TYPE'
      - 'CLASSIFICATION_VALUE'
  HASHDIFF_POLICY_COVERAGE_SCHEDULE:
    is_hashdiff: true
    columns:
      - 'COVERAGE_END_DATE'
      - 'COVERAGE_OPTED_INDICATOR'
      - 'COVERAGE_REFERENCE'
      - 'COVERAGE_SEQUENCE'
      - 'COVERAGE_START_DATE'
      - 'CO_PAYMENT_PERCENTAGE'
      - 'DEDUCTIBLE_AMOUNT'
      - 'LIMIT_AMOUNT'
      - 'PREMIUM_FOR_COVERAGE'
      - 'SUM_INSURED'
  HASHDIFF_POLICY_HEADER:
    is_hashdiff: true
    columns:
      - 'CO_INSURANCE_INDICATOR'
      - 'CURRENCY_CODE'
      - 'FIRST_YEAR_INDICATOR'
      - 'POLICYHOLDER_REFERENCE'
      - 'POLICY_CHANNEL_TYPE'
      - 'POLICY_REFERENCE_NUMBER'
      - 'POLICY_REMARKS'
      - 'POLICY_STATUS'
      - 'POLICY_SUB_STATUS'
      - 'POLICY_TERM'
      - 'POLICY_TYPE'
      - 'PREMIUM_FREQUENCY'
      - 'PREMIUM_PAYER_REFERENCE'
      - 'PRODUCT_REFERENCE'
      - 'RISK_END_TIME'
      - 'RISK_EXPIRY_DATE'
      - 'RISK_INCEPTION_DATE'
      - 'RISK_START_TIME'
      - 'SUM_INSURED_TOTAL'
  HASHDIFF_POLICY_RENEWAL:
    is_hashdiff: true
    columns:
      - 'BREAK_IN_INDICATOR'
      - 'RENEWAL_DUE_DATE'
  HASHDIFF_POLICY_SERVICING_SUMMARY:
    is_hashdiff: true
    columns:
      - 'SERVICING_ORG_UNIT_CODE'
  HASHDIFF_PRODUCT_DEFINITION:
    is_hashdiff: true
    columns:
      - 'LINE_OF_BUSINESS'
      - 'PRODUCT_CATEGORY'
      - 'PRODUCT_NAME'
      - 'UIN'
  HASHDIFF_RISK_OBJECT_CORE:
    is_hashdiff: true
    columns:
      - 'EXPOSURE_QUANTITY'
      - 'EXPOSURE_UNIT'
      - 'RISK_CLASS_CODE'
      - 'RISK_OBJECT_DESCRIPTION'
      - 'RISK_OBJECT_REFERENCE_NUMBER'
      - 'RISK_OBJECT_TYPE'
derived_columns:
  CLAIM_BK: "nullif(trim(case when coalesce(nullif(trim(claimno),''), nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(claimno), ''), nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'')"
  CLAIM_NK: "'HUB_CLAIM|' || (nullif(trim(case when coalesce(nullif(trim(claimno),''), nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(claimno), ''), nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),''))"
  CLAIM_BK__CLAIM_COURT_COUNTERPARTY: "nullif(trim(case when coalesce(nullif(trim(claimno),''), nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(claimno), ''), nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'')"
  CLAIM_NK__CLAIM_COURT_COUNTERPARTY: "'HUB_CLAIM|' || (nullif(trim(case when coalesce(nullif(trim(claimno),''), nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(claimno), ''), nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),''))"
  CLAIM_BK__LINKED_CLAIM: "nullif(trim(case when coalesce(nullif(trim(linked_claim_number),'')) is not null then nullif(trim(linked_claim_number), '') end),'')"
  CLAIM_NK__LINKED_CLAIM: "'HUB_CLAIM|' || (nullif(trim(case when coalesce(nullif(trim(linked_claim_number),'')) is not null then nullif(trim(linked_claim_number), '') end),''))"
  CLAIM_PARTY_BK__CLAIM_COURT_COUNTERPARTY: "coalesce(nullif(trim(case when coalesce(nullif(trim(claimno),''), nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(claimno), ''), nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),''),'') || '|' || coalesce(nullif(trim(case when coalesce(nullif(trim(claim_court_party_code),'')) is not null then nullif(trim(claim_court_party_code), '') end),''),'')"
  CLAIM_PARTY_NK__CLAIM_COURT_COUNTERPARTY: "'LNK_CLAIM_PARTY|' || (coalesce(nullif(trim(case when coalesce(nullif(trim(claimno),''), nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(claimno), ''), nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),''),'') || '|' || coalesce(nullif(trim(case when coalesce(nullif(trim(claim_court_party_code),'')) is not null then nullif(trim(claim_court_party_code), '') end),''),''))"
  DISTRIBUTION_CHANNEL_BK__DEALER: "nullif(trim(case when coalesce(nullif(trim(dealer_code),'')) is not null then 'DEALER:' || nullif(trim(dealer_code), '') end),'')"
  DISTRIBUTION_CHANNEL_NK__DEALER: "'HUB_DISTRIBUTION_CHANNEL|' || (nullif(trim(case when coalesce(nullif(trim(dealer_code),'')) is not null then 'DEALER:' || nullif(trim(dealer_code), '') end),''))"
  DISTRIBUTION_CHANNEL_BK__INTERMEDIARY: "nullif(trim(case when coalesce(nullif(trim(intermediary_code),'')) is not null then 'IMD:' || nullif(trim(intermediary_code), '') end),'')"
  DISTRIBUTION_CHANNEL_NK__INTERMEDIARY: "'HUB_DISTRIBUTION_CHANNEL|' || (nullif(trim(case when coalesce(nullif(trim(intermediary_code),'')) is not null then 'IMD:' || nullif(trim(intermediary_code), '') end),''))"
  DOCUMENT_BK__CLAIM_INWARD: "nullif(trim(case when coalesce(nullif(trim(inward_number),'')) is not null then 'INWARD:' || nullif(trim(inward_number), '') end),'')"
  DOCUMENT_NK__CLAIM_INWARD: "'HUB_DOCUMENT|' || (nullif(trim(case when coalesce(nullif(trim(inward_number),'')) is not null then 'INWARD:' || nullif(trim(inward_number), '') end),''))"
  DOCUMENT_BK__CLAIM_INWARD_DOCUMENT_SET: "nullif(trim(case when coalesce(nullif(trim(inward_number),'')) is not null then 'INWARD:' || nullif(trim(inward_number), '') end),'')"
  DOCUMENT_NK__CLAIM_INWARD_DOCUMENT_SET: "'HUB_DOCUMENT|' || (nullif(trim(case when coalesce(nullif(trim(inward_number),'')) is not null then 'INWARD:' || nullif(trim(inward_number), '') end),''))"
  LOCATION_BK__CLAIMANT_CORRESPONDENCE_ADDRESS: "nullif(trim(case when coalesce(nullif(trim(correspondence_address),''), nullif(trim(area),''), nullif(trim(city),''), nullif(trim(state),''), nullif(trim(pin_code),'')) is not null then md5(upper(regexp_replace(trim(nullif(trim(coalesce(nullif(trim(correspondence_address), ''), '') || '|' || coalesce(nullif(trim(area), ''), '') || '|' || coalesce(nullif(trim(city), ''), '') || '|' || coalesce(nullif(trim(state), ''), '') || '|' || coalesce(nullif(trim(pin_code), ''), '')), '||||')), '[[:space:]]+', ' '))) end),'')"
  LOCATION_NK__CLAIMANT_CORRESPONDENCE_ADDRESS: "'HUB_LOCATION|' || (nullif(trim(case when coalesce(nullif(trim(correspondence_address),''), nullif(trim(area),''), nullif(trim(city),''), nullif(trim(state),''), nullif(trim(pin_code),'')) is not null then md5(upper(regexp_replace(trim(nullif(trim(coalesce(nullif(trim(correspondence_address), ''), '') || '|' || coalesce(nullif(trim(area), ''), '') || '|' || coalesce(nullif(trim(city), ''), '') || '|' || coalesce(nullif(trim(state), ''), '') || '|' || coalesce(nullif(trim(pin_code), ''), '')), '||||')), '[[:space:]]+', ' '))) end),''))"
  LOCATION_BK__CLAIM_CORRESPONDENCE_ADDRESS: "nullif(trim(case when coalesce(nullif(trim(street),''), nullif(trim(landmark),''), nullif(trim(state),''), nullif(trim(pin_code),'')) is not null then md5(upper(regexp_replace(trim(upper(nullif(trim(coalesce(nullif(trim(street), ''), '') || ' ' || coalesce(nullif(trim(landmark), ''), '') || ' ' || coalesce(nullif(trim(state), ''), '') || ' ' || coalesce(nullif(trim(pin_code), ''), '')), ''))), '[[:space:]]+', ' '))) end),'')"
  LOCATION_NK__CLAIM_CORRESPONDENCE_ADDRESS: "'HUB_LOCATION|' || (nullif(trim(case when coalesce(nullif(trim(street),''), nullif(trim(landmark),''), nullif(trim(state),''), nullif(trim(pin_code),'')) is not null then md5(upper(regexp_replace(trim(upper(nullif(trim(coalesce(nullif(trim(street), ''), '') || ' ' || coalesce(nullif(trim(landmark), ''), '') || ' ' || coalesce(nullif(trim(state), ''), '') || ' ' || coalesce(nullif(trim(pin_code), ''), '')), ''))), '[[:space:]]+', ' '))) end),''))"
  LOCATION_BK__CLAIM_LOSS_LOCATION: "nullif(trim(case when coalesce(nullif(trim(loss_address),''), nullif(trim(areaclaim),''), nullif(trim(stateclaim),''), nullif(trim(pincode_where_loss_happened),'')) is not null then md5(upper(regexp_replace(trim(nullif(trim(coalesce(nullif(trim(loss_address), ''), '') || '|' || coalesce(nullif(trim(areaclaim), ''), '') || '|' || coalesce(nullif(trim(stateclaim), ''), '') || '|' || coalesce(nullif(trim(pincode_where_loss_happened), ''), '')), '|||')), '[[:space:]]+', ' '))) end),'')"
  LOCATION_NK__CLAIM_LOSS_LOCATION: "'HUB_LOCATION|' || (nullif(trim(case when coalesce(nullif(trim(loss_address),''), nullif(trim(areaclaim),''), nullif(trim(stateclaim),''), nullif(trim(pincode_where_loss_happened),'')) is not null then md5(upper(regexp_replace(trim(nullif(trim(coalesce(nullif(trim(loss_address), ''), '') || '|' || coalesce(nullif(trim(areaclaim), ''), '') || '|' || coalesce(nullif(trim(stateclaim), ''), '') || '|' || coalesce(nullif(trim(pincode_where_loss_happened), ''), '')), '|||')), '[[:space:]]+', ' '))) end),''))"
  LOCATION_BK__CLAIM_REFERENCE_ADDRESS: "nullif(trim(case when coalesce(nullif(trim(address_for_reference),'')) is not null then md5(upper(regexp_replace(trim(nullif(trim(address_for_reference), '')), '[[:space:]]+', ' '))) end),'')"
  LOCATION_NK__CLAIM_REFERENCE_ADDRESS: "'HUB_LOCATION|' || (nullif(trim(case when coalesce(nullif(trim(address_for_reference),'')) is not null then md5(upper(regexp_replace(trim(nullif(trim(address_for_reference), '')), '[[:space:]]+', ' '))) end),''))"
  LOCATION_BK__CUSTOMER_ANALYTICS_LOCATION: "nullif(trim(case when coalesce(nullif(trim(customer_location_by_state),''), nullif(trim(customer_location_by_district),''), nullif(trim(customer_location_by_tehsil),'')) is not null then md5(upper(regexp_replace(trim(nullif(trim(coalesce(nullif(trim(customer_location_by_state), ''), '') || '|' || coalesce(nullif(trim(customer_location_by_district), ''), '') || '|' || coalesce(nullif(trim(customer_location_by_tehsil), ''), '')), '||')), '[[:space:]]+', ' '))) end),'')"
  LOCATION_NK__CUSTOMER_ANALYTICS_LOCATION: "'HUB_LOCATION|' || (nullif(trim(case when coalesce(nullif(trim(customer_location_by_state),''), nullif(trim(customer_location_by_district),''), nullif(trim(customer_location_by_tehsil),'')) is not null then md5(upper(regexp_replace(trim(nullif(trim(coalesce(nullif(trim(customer_location_by_state), ''), '') || '|' || coalesce(nullif(trim(customer_location_by_district), ''), '') || '|' || coalesce(nullif(trim(customer_location_by_tehsil), ''), '')), '||')), '[[:space:]]+', ' '))) end),''))"
  LOCATION_BK__INSPECTION_ADDRESS: "nullif(trim(case when coalesce(nullif(trim(select_inspection_address),'')) is not null then md5(upper(regexp_replace(trim(upper(nullif(trim(select_inspection_address), ''))), '[[:space:]]+', ' '))) end),'')"
  LOCATION_NK__INSPECTION_ADDRESS: "'HUB_LOCATION|' || (nullif(trim(case when coalesce(nullif(trim(select_inspection_address),'')) is not null then md5(upper(regexp_replace(trim(upper(nullif(trim(select_inspection_address), ''))), '[[:space:]]+', ' '))) end),''))"
  LOCATION_BK__STORED_COUNTRY: "nullif(trim(case when coalesce(nullif(trim(stored_country_code),'')) is not null then 'GEO:COUNTRY:' || nullif(trim(stored_country_code), '') end),'')"
  LOCATION_NK__STORED_COUNTRY: "'HUB_LOCATION|' || (nullif(trim(case when coalesce(nullif(trim(stored_country_code),'')) is not null then 'GEO:COUNTRY:' || nullif(trim(stored_country_code), '') end),''))"
  LOCATION_BK__STORED_STATE: "nullif(trim(case when coalesce(nullif(trim(stored_state_code),'')) is not null then 'GEO:STATE:' || nullif(trim(stored_state_code), '') end),'')"
  LOCATION_NK__STORED_STATE: "'HUB_LOCATION|' || (nullif(trim(case when coalesce(nullif(trim(stored_state_code),'')) is not null then 'GEO:STATE:' || nullif(trim(stored_state_code), '') end),''))"
  LOSS_EVENT_BK: "nullif(trim(case when coalesce(nullif(trim(intimation_number),''), nullif(trim(claimno),'')) is not null then 'LOSSEVT:' || coalesce(nullif(trim(intimation_number), ''), nullif(trim(claimno), '')) end),'')"
  LOSS_EVENT_NK: "'HUB_LOSS_EVENT|' || (nullif(trim(case when coalesce(nullif(trim(intimation_number),''), nullif(trim(claimno),'')) is not null then 'LOSSEVT:' || coalesce(nullif(trim(intimation_number), ''), nullif(trim(claimno), '')) end),''))"
  LOSS_EVENT_BK__V2: "nullif(trim(case when coalesce(nullif(trim(claimno),''), nullif(trim(w2_claimno),'')) is not null then 'LOSSEVT:' || coalesce(nullif(trim(claimno), ''), nullif(trim(w2_claimno), '')) end),'')"
  LOSS_EVENT_NK__V2: "'HUB_LOSS_EVENT|' || (nullif(trim(case when coalesce(nullif(trim(claimno),''), nullif(trim(w2_claimno),'')) is not null then 'LOSSEVT:' || coalesce(nullif(trim(claimno), ''), nullif(trim(w2_claimno), '')) end),''))"
  ORG_UNIT_BK__COMPANY: "nullif(trim(case when coalesce(nullif(trim(stored_company_code),'')) is not null then nullif(trim(stored_company_code), '') end),'')"
  ORG_UNIT_NK__COMPANY: "'HUB_ORG_UNIT|' || (nullif(trim(case when coalesce(nullif(trim(stored_company_code),'')) is not null then nullif(trim(stored_company_code), '') end),''))"
  ORG_UNIT_BK__OPERATING_HUB: "nullif(trim(case when coalesce(nullif(trim(hub_location),'')) is not null then 'ORGHUB:' || nullif(trim(hub_location), '') end),'')"
  ORG_UNIT_NK__OPERATING_HUB: "'HUB_ORG_UNIT|' || (nullif(trim(case when coalesce(nullif(trim(hub_location),'')) is not null then 'ORGHUB:' || nullif(trim(hub_location), '') end),''))"
  PARTY_BK__CLAIMANT_CORRESPONDENCE_ADDRESS: "nullif(trim(case when coalesce(nullif(trim(customerid),'')) is not null then nullif(trim(customerid), '') end),'')"
  PARTY_NK__CLAIMANT_CORRESPONDENCE_ADDRESS: "'HUB_PARTY|' || (nullif(trim(case when coalesce(nullif(trim(customerid),'')) is not null then nullif(trim(customerid), '') end),''))"
  PARTY_BK__CLAIMANT_CUSTOMER: "nullif(trim(case when coalesce(nullif(trim(customerid),'')) is not null then nullif(trim(customerid), '') end),'')"
  PARTY_NK__CLAIMANT_CUSTOMER: "'HUB_PARTY|' || (nullif(trim(case when coalesce(nullif(trim(customerid),'')) is not null then nullif(trim(customerid), '') end),''))"
  PARTY_BK__CLAIM_COURT_COUNTERPARTY: "nullif(trim(case when coalesce(nullif(trim(claim_court_party_code),'')) is not null then nullif(trim(claim_court_party_code), '') end),'')"
  PARTY_NK__CLAIM_COURT_COUNTERPARTY: "'HUB_PARTY|' || (nullif(trim(case when coalesce(nullif(trim(claim_court_party_code),'')) is not null then nullif(trim(claim_court_party_code), '') end),''))"
  PARTY_BK__INSURED_CUSTOMER: "nullif(trim(case when coalesce(nullif(trim(unique_customer_id),''), nullif(trim(customerid),'')) is not null then coalesce(nullif(trim(unique_customer_id), ''), nullif(trim(customerid), '')) end),'')"
  PARTY_NK__INSURED_CUSTOMER: "'HUB_PARTY|' || (nullif(trim(case when coalesce(nullif(trim(unique_customer_id),''), nullif(trim(customerid),'')) is not null then coalesce(nullif(trim(unique_customer_id), ''), nullif(trim(customerid), '')) end),''))"
  PARTY_BK__INSURED_MEMBER: "nullif(trim(case when coalesce(nullif(trim(member_uhc_code),'')) is not null then 'MEMBER:' || nullif(trim(member_uhc_code), '') end),'')"
  PARTY_NK__INSURED_MEMBER: "'HUB_PARTY|' || (nullif(trim(case when coalesce(nullif(trim(member_uhc_code),'')) is not null then 'MEMBER:' || nullif(trim(member_uhc_code), '') end),''))"
  PARTY_BK__SERVICE_PARTNER: "nullif(trim(case when coalesce(nullif(trim(ptpartnerid),'')) is not null then 'PTPARTNER:' || nullif(trim(ptpartnerid), '') end),'')"
  PARTY_NK__SERVICE_PARTNER: "'HUB_PARTY|' || (nullif(trim(case when coalesce(nullif(trim(ptpartnerid),'')) is not null then 'PTPARTNER:' || nullif(trim(ptpartnerid), '') end),''))"
  PARTY_BK__SUB_INTERMEDIARY: "nullif(trim(case when coalesce(nullif(trim(sub_imd_code),'')) is not null then 'IMD:' || nullif(trim(sub_imd_code), '') end),'')"
  PARTY_NK__SUB_INTERMEDIARY: "'HUB_PARTY|' || (nullif(trim(case when coalesce(nullif(trim(sub_imd_code),'')) is not null then 'IMD:' || nullif(trim(sub_imd_code), '') end),''))"
  PARTY_LOCATION_BK__CLAIMANT_CORRESPONDENCE_ADDRESS: "coalesce(nullif(trim(case when coalesce(nullif(trim(customerid),'')) is not null then nullif(trim(customerid), '') end),''),'') || '|' || coalesce(nullif(trim(case when coalesce(nullif(trim(correspondence_address),''), nullif(trim(area),''), nullif(trim(city),''), nullif(trim(state),''), nullif(trim(pin_code),'')) is not null then md5(upper(regexp_replace(trim(nullif(trim(coalesce(nullif(trim(correspondence_address), ''), '') || '|' || coalesce(nullif(trim(area), ''), '') || '|' || coalesce(nullif(trim(city), ''), '') || '|' || coalesce(nullif(trim(state), ''), '') || '|' || coalesce(nullif(trim(pin_code), ''), '')), '||||')), '[[:space:]]+', ' '))) end),''),'')"
  PARTY_LOCATION_NK__CLAIMANT_CORRESPONDENCE_ADDRESS: "'LNK_PARTY_LOCATION|' || (coalesce(nullif(trim(case when coalesce(nullif(trim(customerid),'')) is not null then nullif(trim(customerid), '') end),''),'') || '|' || coalesce(nullif(trim(case when coalesce(nullif(trim(correspondence_address),''), nullif(trim(area),''), nullif(trim(city),''), nullif(trim(state),''), nullif(trim(pin_code),'')) is not null then md5(upper(regexp_replace(trim(nullif(trim(coalesce(nullif(trim(correspondence_address), ''), '') || '|' || coalesce(nullif(trim(area), ''), '') || '|' || coalesce(nullif(trim(city), ''), '') || '|' || coalesce(nullif(trim(state), ''), '') || '|' || coalesce(nullif(trim(pin_code), ''), '')), '||||')), '[[:space:]]+', ' '))) end),''),''))"
  POLICY_BK: "nullif(trim(case when coalesce(nullif(trim(w1_policyno),'')) is not null then nullif(trim(w1_policyno), '') end),'')"
  POLICY_NK: "'HUB_POLICY|' || (nullif(trim(case when coalesce(nullif(trim(w1_policyno),'')) is not null then nullif(trim(w1_policyno), '') end),''))"
  POLICY_BK__MASTER_POLICY: "nullif(trim(case when coalesce(nullif(trim(master_policy_number),'')) is not null then nullif(trim(master_policy_number), '') end),'')"
  POLICY_NK__MASTER_POLICY: "'HUB_POLICY|' || (nullif(trim(case when coalesce(nullif(trim(master_policy_number),'')) is not null then nullif(trim(master_policy_number), '') end),''))"
  PRODUCT_BK: "nullif(trim(case when coalesce(nullif(trim(stored_product_code),'')) is not null then 'PROD:' || nullif(trim(stored_product_code), '') end),'')"
  PRODUCT_NK: "'HUB_PRODUCT|' || (nullif(trim(case when coalesce(nullif(trim(stored_product_code),'')) is not null then 'PROD:' || nullif(trim(stored_product_code), '') end),''))"
  RISK_OBJECT_BK__CLAIMED_RISK_ITEM: "nullif(trim(case when coalesce(nullif(trim(w3_policyno),''), nullif(trim(risk_code),'')) is not null then 'RISK:' || nullif(trim(w3_policyno), '') || '#' || nullif(trim(risk_code), '') end),'')"
  RISK_OBJECT_NK__CLAIMED_RISK_ITEM: "'HUB_RISK_OBJECT|' || (nullif(trim(case when coalesce(nullif(trim(w3_policyno),''), nullif(trim(risk_code),'')) is not null then 'RISK:' || nullif(trim(w3_policyno), '') || '#' || nullif(trim(risk_code), '') end),''))"
  ACCOUNT_HOLDER_NAME: 'name_on_bank_ac'
  ACCOUNT_NUMBER_MASKED: "coalesce(nullif(trim(bank_account_number), ''),'')"
  ACCOUNT_TYPE: 'coalesce(account_type, bank_account_type)'
  ACTIVE_POLICY_COUNT: 'no_of_active_policies'
  ADDRESS_LINE_1: 'coalesce(address_for_reference, correspondence_address, select_inspection_address)'
  ADDRESS_LINE_1__SAT_LOSS_LOCATION_ADDRESS: 'loss_address'
  ADDRESS_LINE_2: 'cast(null as varchar)'
  ADDRESS_LINE_3: 'cast(null as varchar)'
  ADDRESS_TYPE_CODE: 'cast(null as varchar)'
  ADMISSION_DATE: 'cast(null as varchar)'
  AGE: 'cast(null as varchar)'
  AILMENT_DESCRIPTION: 'final_diagnosis'
  APPROVED_AMOUNT: 'cast(null as varchar)'
  AWARD_AMOUNT: 'cast(null as varchar)'
  BANK_NAME: 'bank_name'
  BENEFIT_HEAD_CODE: "coalesce(nullif(trim(cover_name), ''),'')"
  BRANCH_NAME: 'bank_branch'
  BREAK_IN_INDICATOR: 'break_in'
  CARE_OF_NAME: 'cast(null as varchar)'
  CATASTROPHE_CODE: 'catastrophic_event_code'
  CATEGORY_CODE: 'customer_type_retail_or_institutional'
  CAUSE_OF_LOSS: 'cause_of_loss'
  CHANNEL_NAME: 'intermediary_name'
  CHANNEL_REMARKS: 'cast(null as varchar)'
  CHANNEL_TYPE: 'cast(null as varchar)'
  CITY: 'city'
  CLAIMED_AMOUNT: 'cast(null as varchar)'
  CLAIM_CATEGORY: 'claim_types'
  CLAIM_HANDLER_REFERENCE: 'claim_owner'
  CLAIM_REFERENCE_NUMBER: 'cast(null as varchar)'
  CLAIM_STATUS: 'cast(null as varchar)'
  CLAIM_SUB_STATUS: 'claim_substatus'
  CLAIM_SUB_TYPE: 'cast(null as varchar)'
  CLAIM_TYPE: 'type_of_claim'
  CLASSIFICATION_TYPE: "'TYPE_OF_BUSINESS'"
  CLASSIFICATION_VALUE: 'business_type'
  CONSENT_GIVEN_INDICATOR: 'customer_digital_claim_form_consent_received'
  COUNTRY_CODE: 'stored_country_code'
  COUNTRY_CODE__SAT_COMMON_ADDRESS: 'cast(null as varchar)'
  COUNTRY_NAME: 'cast(null as varchar)'
  COUNTRY_OF_BIRTH: 'cast(null as varchar)'
  COUNTRY_OF_INCIDENT: 'country_of_loss'
  COUNTRY_OF_RESIDENCE: 'cast(null as varchar)'
  COURT_NAME: 'court_name_as_per_intimation_details'
  COURT_TYPE: 'court_type'
  COVERAGE_END_DATE: 'pa_cover_expiry_date'
  COVERAGE_OPTED_INDICATOR: 'cast(null as varchar)'
  COVERAGE_REFERENCE: "'PA'"
  COVERAGE_REFERENCE__SAT_CLAIM_BENEFIT_HEAD: 'cast(null as varchar)'
  COVERAGE_SEQUENCE: "'1'"
  COVERAGE_START_DATE: 'pa_cover_inception_date'
  CO_INSURANCE_INDICATOR: 'cast(null as varchar)'
  CO_INSURANCE_OUR_SHARE_PERCENTAGE: 'coinsurance_contribution'
  CO_PAYMENT_PERCENTAGE: 'cast(null as varchar)'
  CREDIT_SCORE: 'creditscore'
  CURRENCY_CODE: 'cast(null as varchar)'
  CURRENCY_OF_LOSS: 'cast(null as varchar)'
  DATE_OF_BIRTH: 'enter_dob'
  DEDUCTIBLE_AMOUNT: 'cast(null as varchar)'
  DEDUCTION_AMOUNT: 'cast(null as varchar)'
  DEDUCTION_REASON: 'cast(null as varchar)'
  DISCHARGE_DATE: 'cast(null as varchar)'
  DISPATCH_REFERENCE: "coalesce(nullif(trim(pod_number), ''),'')"
  DISTRICT: 'cast(null as varchar)'
  DISTRICT_NAME: 'customer_location_by_district'
  DOCUMENT_NAME: 'cast(null as varchar)'
  DOCUMENT_REFERENCE_NUMBER: 'cast(null as varchar)'
  DOCUMENT_TYPE: 'document_type_inward'
  EXPENSE_SHARE_AMOUNT: 'cast(null as varchar)'
  EXPOSURE_QUANTITY: 'cast(null as varchar)'
  EXPOSURE_UNIT: 'cast(null as varchar)'
  FIRST_NAME: 'cast(null as varchar)'
  FIRST_YEAR_INDICATOR: 'cast(null as varchar)'
  FIR_DATE: 'coalesce(police_reported_date, police_report_date)'
  FIR_NUMBER: 'fir_gd_number'
  FNOL_CHANNEL: 'source_of_intimation'
  FNOL_TIME: 'claim_intimation_time'
  FRAUD_SCORE: 'score'
  FRAUD_TRIGGER_REASON: 'reason_for_ilm_flagging'
  FRAUD_TYPE: 'cast(null as varchar)'
  GENDER_CODE: 'cast(null as varchar)'
  HANDLING_ORG_UNIT_CODE: 'claim_handling_location_codemact_location_code'
  HEAD_DESCRIPTION: 'cover_name'
  HEALTH_CLAIM_REMARKS: 'medical_comments'
  ICD_CODE: 'cast(null as varchar)'
  IFSC_CODE: 'coalesce(bank_ifsc_code, ifsc)'
  INCIDENT_DATE: 'cast(null as varchar)'
  INCOME_SOURCE: 'cast(null as varchar)'
  INTIMATED_BY_ROLE: 'claim_reported_by'
  INTIMATION_CHANNEL: 'claim_intimation_type'
  INVESTIGATION_REFERENCE: 'investigation_id'
  INVESTIGATION_REFERRED_INDICATOR: 'investigationflag'
  INVESTIGATION_STATUS: 'investigation_status'
  ISSUE_DATE: 'cast(null as varchar)'
  LANDMARK: 'landmark'
  LAST_NAME: 'cast(null as varchar)'
  LATITUDE: 'latitude'
  LEADER_INDICATOR: 'leaderfollower'
  LENGTH_OF_STAY: 'cast(null as varchar)'
  LIMIT_AMOUNT: 'cast(null as varchar)'
  LINE_OF_BUSINESS: 'stored_lob_code'
  LOCALITY: 'coalesce(area, areaclaim)'
  LONGITUDE: 'longitude'
  LOSS_AMOUNT_FOREIGN: 'cast(null as varchar)'
  LOSS_AMOUNT_INR: 'cast(null as varchar)'
  LOSS_DATE: 'date_of_accident'
  LOSS_DESCRIPTION: 'coalesce(description_of_loss, loss_description)'
  LOSS_TIME: 'time_of_accident'
  MICR_CODE: 'micr_code'
  MIDDLE_NAME: 'cast(null as varchar)'
  NATIONALITY: 'cast(null as varchar)'
  NOTIFICATION_DATE: 'cast(null as varchar)'
  NOTIFIED_BY_ROLE: 'notified_by'
  PARTY_FULL_NAME: 'coalesce(insured_name, member_name, sub_imd_name)'
  PARTY_LEGAL_NAME: 'cast(null as varchar)'
  PARTY_STATUS: 'cast(null as varchar)'
  PARTY_SUB_TYPE_CODE: 'cast(null as varchar)'
  PARTY_TYPE_CODE: 'cast(null as varchar)'
  POLICE_STATION_NAME: 'name_of_police_station'
  POLICYHOLDER_REFERENCE: 'cast(null as varchar)'
  POLICY_CHANNEL_TYPE: 'cast(null as varchar)'
  POLICY_REFERENCE_NUMBER: 'cast(null as varchar)'
  POLICY_REMARKS: 'cast(null as varchar)'
  POLICY_STATUS: 'policy_status'
  POLICY_SUB_STATUS: 'cast(null as varchar)'
  POLICY_TERM: 'cast(null as varchar)'
  POLICY_TYPE: 'cast(null as varchar)'
  POSTAL_CODE: 'pin_code'
  POSTAL_CODE__SAT_LOSS_LOCATION_ADDRESS: 'pincode_where_loss_happened'
  POST_OFFICE_NAME: 'cast(null as varchar)'
  PRELIMINARY_LOSS_DESCRIPTION: 'claim_circumstances'
  PRELIMINARY_LOSS_ESTIMATE: 'estimated_loss_amount'
  PREMIUM_FOR_COVERAGE: 'cast(null as varchar)'
  PREMIUM_FREQUENCY: 'cast(null as varchar)'
  PREMIUM_PAYER_REFERENCE: 'cast(null as varchar)'
  PRE_EXISTING_DISEASE_RELATED_INDICATOR: 'cast(null as varchar)'
  PRIMARY_ACCOUNT_INDICATOR: 'cast(null as varchar)'
  PRIORITY_CODE: 'priority'
  PRODUCT_CATEGORY: 'cast(null as varchar)'
  PRODUCT_NAME: 'productplan'
  PRODUCT_REFERENCE: 'cast(null as varchar)'
  RECEIVED_DATE: 'coalesce(document_received_date, inward_date)'
  REGISTRATION_DATE: 'claim_registration_date'
  RENEWAL_DUE_DATE: 'renewal_date'
  REPORTED_BY_CONTACT: 'claim_intimator_mobile_number'
  REPORTED_BY_NAME: 'claim_intimator_name'
  REPUDIATION_REASON: 'repudiation_reason'
  RISK_CLASS_CODE: 'risk_code'
  RISK_END_TIME: 'cast(null as varchar)'
  RISK_EXPIRY_DATE: 'policy_expiry_date'
  RISK_INCEPTION_DATE: 'policy_inception_date'
  RISK_OBJECT_DESCRIPTION: 'risk_description'
  RISK_OBJECT_REFERENCE_NUMBER: 'cast(null as varchar)'
  RISK_OBJECT_TYPE: 'cast(null as varchar)'
  RISK_START_TIME: 'cast(null as varchar)'
  SALUTATION: 'cast(null as varchar)'
  SEGMENT_NAME: 'cast(null as varchar)'
  SELF_SERVICE_INDICATOR: 'portal_flag'
  SERVICING_ORG_UNIT_CODE: 'policy_branch'
  SOURCE_CHANNEL: 'coalesce(mode_of_document_inward, mode_of_inward)'
  STATE_CODE: 'stored_state_code'
  STATE_CODE__SAT_COMMON_ADDRESS: 'cast(null as varchar)'
  STATE_NAME: 'state'
  STATE_NAME__SAT_COMMON_ADMIN_GEOGRAPHY: 'customer_location_by_state'
  STREET_NAME: 'street'
  SUB_CHANNEL_CODE: 'cast(null as varchar)'
  SUB_CHANNEL_EFFECTIVE_DATE: 'cast(null as varchar)'
  SUB_LIMIT_APPLIED: 'cast(null as varchar)'
  SUM_INSURED: 'cast(null as varchar)'
  SUM_INSURED_TOTAL: 'cast(null as varchar)'
  TALUKA_NAME: 'customer_location_by_tehsil'
  THIRD_PARTY_INVOLVED_INDICATOR: 'tp_involvement_'
  TIER_CODE: 'cast(null as varchar)'
  TOTAL_CLAIM_AMOUNT: 'total_incurred_amount_for_claims_raised_by_customers'
  TOTAL_POLICY_COUNT: 'total_policies_purchased'
  TOTAL_PREMIUM_PAID_LIFETIME: 'total_premium_paid'
  TREATING_DOCTOR_NAME: 'cast(null as varchar)'
  TREATMENT_TYPE: 'cast(null as varchar)'
  UIN: 'cast(null as varchar)'
  VALUE_BAND: 'cast(null as varchar)'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
