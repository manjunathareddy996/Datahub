{{ config(materialized='view') }}

-- WIDE stage() for Maximus Travel view
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
-- Covers this view's 20 key slot(s) and its 14 1:1 satellite target(s) in one pass,
-- with a separately-named hashdiff per satellite so each is scoped to its own payload.
-- The bare HASHDIFF the sibling contract requires is produced by the satfeed layer,
-- which is the only place one name can serve one satellite (BD7).
--
-- Fan-in families on this view, if any, are handled by the unpivot layer instead: one
-- row per instance cannot be expressed as columns of one row here.
--
-- Every BK is the guarded rendering. When every non-literal operand is blank the key is
-- NULL, the hub feed drops it, and audit_mt_key_rejections counts the drop per hub per
-- feeder -- so a zero is a measured zero (directive D-REJECT).
--
--   CLAIM_HKEY                         HUB_CLAIM  (89 row(s) in the map)
--   CLAIM_HKEY__CLAIMANT               HUB_CLAIM / claimant  (1 row(s) in the map)
--   CLAIM_HKEY__EXPENSE_LINE_PARTY     HUB_CLAIM / expense-line-party  (1 row(s) in the map)
--   CLAIM_HKEY__EXPENSE_PAYEE          HUB_CLAIM / expense-payee  (1 row(s) in the map)
--   CLAIM_HKEY__PAYEE                  HUB_CLAIM / payee  (1 row(s) in the map)
--   CLAIM_HKEY__TDS_DEDUCTEE           HUB_CLAIM / tds-deductee  (1 row(s) in the map)
--   CLAIM_PARTY_HKEY__CLAIMANT         LNK_CLAIM_PARTY / claimant  LINK
--   CLAIM_PARTY_HKEY__EXPENSE_LINE_PARTY LNK_CLAIM_PARTY / expense-line-party  LINK
--   CLAIM_PARTY_HKEY__EXPENSE_PAYEE    LNK_CLAIM_PARTY / expense-payee  LINK
--   CLAIM_PARTY_HKEY__PAYEE            LNK_CLAIM_PARTY / payee  LINK
--   CLAIM_PARTY_HKEY__TDS_DEDUCTEE     LNK_CLAIM_PARTY / tds-deductee  LINK
--   FINANCIAL_TRANSACTION_HKEY__CLAIM_BILL_INVOICE HUB_FINANCIAL_TRANSACTION / claim-bill-invoice  (11 row(s) in the map)
--   FINANCIAL_TRANSACTION_HKEY__CLAIM_PAYMENT HUB_FINANCIAL_TRANSACTION / claim-payment  (17 row(s) in the map)
--   LOCATION_HKEY__CLAIM_EXPENSE_PARTY_ADDRESS HUB_LOCATION / claim-expense-party-address  (1 row(s) in the map)
--   PARTY_HKEY__CLAIMANT               HUB_PARTY / claimant  (4 row(s) in the map)
--   PARTY_HKEY__EXPENSE_LINE_PARTY     HUB_PARTY / expense-line-party  (3 row(s) in the map)
--   PARTY_HKEY__EXPENSE_PAYEE          HUB_PARTY / expense-payee  (2 row(s) in the map)
--   PARTY_HKEY__PAYEE                  HUB_PARTY / payee  (2 row(s) in the map)
--   PARTY_HKEY__TDS_DEDUCTEE           HUB_PARTY / tds-deductee  (3 row(s) in the map)
--   POLICY_HKEY                        HUB_POLICY  (2 row(s) in the map)
--   HASHDIFF_CLAIM_CO_RI_SHARE         SAT_CLAIM_CO_RI_SHARE payload 1 of 3 live here
--   HASHDIFF_CLAIM_FRAUD               SAT_CLAIM_FRAUD payload 2 of 6 live here
--   HASHDIFF_CLAIM_HEALTH_DETAIL       SAT_CLAIM_HEALTH_DETAIL payload 3 of 16 live here
--   HASHDIFF_CLAIM_LITIGATION          SAT_CLAIM_LITIGATION payload 1 of 3 live here
--   HASHDIFF_CLAIM_PAYMENT_TRANCHE     SAT_CLAIM_PAYMENT_TRANCHE payload 7 of 10 live here
--   HASHDIFF_CLAIM_PROVIDER_BILLING    SAT_CLAIM_PROVIDER_BILLING payload 5 of 5 live here
--   HASHDIFF_CLAIM_RECOVERY_SALVAGE    SAT_CLAIM_RECOVERY_SALVAGE payload 1 of 1 live here
--   HASHDIFF_CLAIM_SETTLEMENT          SAT_CLAIM_SETTLEMENT payload 1 of 1 live here
--   HASHDIFF_CLAIM_TRAVEL_DETAIL       SAT_CLAIM_TRAVEL_DETAIL payload 2 of 6 live here
--   HASHDIFF_COMMON_ADDRESS            SAT_COMMON_ADDRESS payload 1 of 16 live here
--   HASHDIFF_LNK_CLAIM_PARTY_ROLE      SAT_LNK_CLAIM_PARTY_ROLE payload 0 of 0 live here
--   HASHDIFF_PARTY_IDENTIFICATION      SAT_PARTY_IDENTIFICATION payload 1 of 25 live here
--   HASHDIFF_PARTY_IDENTITY            SAT_PARTY_IDENTITY payload 1 of 15 live here
--   HASHDIFF_POLICY_HEADER             SAT_POLICY_HEADER payload 2 of 19 live here

{%- set yaml_metadata -%}
source_model: 'resolved_mt__clm_clmd_clmrsk_rska_msp_msd_prop_pv'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  CLAIM_HKEY__CLAIMANT: 'CLAIM_NK__CLAIMANT'
  CLAIM_HKEY__EXPENSE_LINE_PARTY: 'CLAIM_NK__EXPENSE_LINE_PARTY'
  CLAIM_HKEY__EXPENSE_PAYEE: 'CLAIM_NK__EXPENSE_PAYEE'
  CLAIM_HKEY__PAYEE: 'CLAIM_NK__PAYEE'
  CLAIM_HKEY__TDS_DEDUCTEE: 'CLAIM_NK__TDS_DEDUCTEE'
  CLAIM_PARTY_HKEY__CLAIMANT: 'CLAIM_PARTY_NK__CLAIMANT'
  CLAIM_PARTY_HKEY__EXPENSE_LINE_PARTY: 'CLAIM_PARTY_NK__EXPENSE_LINE_PARTY'
  CLAIM_PARTY_HKEY__EXPENSE_PAYEE: 'CLAIM_PARTY_NK__EXPENSE_PAYEE'
  CLAIM_PARTY_HKEY__PAYEE: 'CLAIM_PARTY_NK__PAYEE'
  CLAIM_PARTY_HKEY__TDS_DEDUCTEE: 'CLAIM_PARTY_NK__TDS_DEDUCTEE'
  FINANCIAL_TRANSACTION_HKEY__CLAIM_BILL_INVOICE: 'FINANCIAL_TRANSACTION_NK__CLAIM_BILL_INVOICE'
  FINANCIAL_TRANSACTION_HKEY__CLAIM_PAYMENT: 'FINANCIAL_TRANSACTION_NK__CLAIM_PAYMENT'
  LOCATION_HKEY__CLAIM_EXPENSE_PARTY_ADDRESS: 'LOCATION_NK__CLAIM_EXPENSE_PARTY_ADDRESS'
  PARTY_HKEY__CLAIMANT: 'PARTY_NK__CLAIMANT'
  PARTY_HKEY__EXPENSE_LINE_PARTY: 'PARTY_NK__EXPENSE_LINE_PARTY'
  PARTY_HKEY__EXPENSE_PAYEE: 'PARTY_NK__EXPENSE_PAYEE'
  PARTY_HKEY__PAYEE: 'PARTY_NK__PAYEE'
  PARTY_HKEY__TDS_DEDUCTEE: 'PARTY_NK__TDS_DEDUCTEE'
  POLICY_HKEY: 'POLICY_NK'
  HASHDIFF_CLAIM_CO_RI_SHARE:
    is_hashdiff: true
    columns:
      - 'CO_INSURANCE_OUR_SHARE_PERCENTAGE'
      - 'EXPENSE_SHARE_AMOUNT'
      - 'LEADER_INDICATOR'
  HASHDIFF_CLAIM_FRAUD:
    is_hashdiff: true
    columns:
      - 'FRAUD_SCORE'
      - 'FRAUD_TRIGGER_REASON'
      - 'FRAUD_TYPE'
      - 'INVESTIGATION_REFERENCE'
      - 'INVESTIGATION_REFERRED_INDICATOR'
      - 'INVESTIGATION_STATUS'
  HASHDIFF_CLAIM_HEALTH_DETAIL:
    is_hashdiff: true
    columns:
      - 'ADMISSION_DATE'
      - 'ADVERSE_MEDICAL_HISTORY_DESCRIPTION'
      - 'AILMENT_DESCRIPTION'
      - 'DISCHARGE_DATE'
      - 'DISEASE_CATEGORY'
      - 'HEALTH_CLAIM_REMARKS'
      - 'ICD_CODE'
      - 'ICD_DESCRIPTION'
      - 'LENGTH_OF_STAY'
      - 'MEDICALLY_ADMISSIBLE_INDICATOR'
      - 'PRE_EXISTING_DISEASE_DESCRIPTION'
      - 'PRE_EXISTING_DISEASE_RELATED_INDICATOR'
      - 'PRE_EXISTING_ILLNESS_DESCRIPTION'
      - 'SYSTEM_OF_MEDICINE'
      - 'TREATING_DOCTOR_NAME'
      - 'TREATMENT_TYPE'
  HASHDIFF_CLAIM_LITIGATION:
    is_hashdiff: true
    columns:
      - 'AWARD_AMOUNT'
      - 'COURT_NAME'
      - 'COURT_TYPE'
  HASHDIFF_CLAIM_PAYMENT_TRANCHE:
    is_hashdiff: true
    columns:
      - 'APPROVAL_REFERENCE'
      - 'FINAL_INDICATOR'
      - 'GROSS_AMOUNT'
      - 'HOLD_INDICATOR'
      - 'HOLD_REASON'
      - 'NET_AMOUNT'
      - 'PAYMENT_DATE'
      - 'PAYMENT_MODE'
      - 'PAYMENT_TYPE'
      - 'STATUS'
      - 'TRANCHE_NUMBER'
  HASHDIFF_CLAIM_PROVIDER_BILLING:
    is_hashdiff: true
    columns:
      - 'APPROVED_AMOUNT'
      - 'BILLED_AMOUNT'
      - 'BILL_NUMBER'
      - 'BILL_STATUS_TYPE'
      - 'DISALLOWANCE_REASON'
      - 'DISALLOWED_AMOUNT'
  HASHDIFF_CLAIM_RECOVERY_SALVAGE:
    is_hashdiff: true
    columns:
      - 'NET_RECOVERY_AMOUNT'
  HASHDIFF_CLAIM_SETTLEMENT:
    is_hashdiff: true
    columns:
      - 'INTEREST_PAID_AMOUNT'
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
      - 'COUNTRY_CODE'
      - 'COUNTRY_NAME'
      - 'DISTRICT'
      - 'LANDMARK'
      - 'LOCALITY'
      - 'POSTAL_CODE'
      - 'POST_OFFICE_NAME'
      - 'STATE_CODE'
      - 'STATE_NAME'
      - 'STREET_NAME'
  HASHDIFF_LNK_CLAIM_PARTY_ROLE:
    is_hashdiff: true
    columns:
      - 'PARTY_ROLE_TYPE'
      - 'ROLE_SEQUENCE'
  HASHDIFF_PARTY_IDENTIFICATION:
    is_hashdiff: true
    columns:
      - 'AADHAAR_NUMBER'
      - 'AADHAAR_VERIFICATION_STATUS'
      - 'AGE_PROOF_TYPE'
      - 'CIN_NUMBER'
      - 'CKYC_NUMBER'
      - 'DRIVING_LICENCE_EXPIRY_DATE'
      - 'DRIVING_LICENCE_NUMBER'
      - 'EIA_NUMBER'
      - 'GSTIN'
      - 'GST_REGISTRATION_STATUS'
      - 'GST_TAXPAYER_TYPE'
      - 'IDENTIFICATION_EXPIRY_DATE'
      - 'IDENTIFICATION_ISSUE_DATE'
      - 'IDENTIFICATION_ISSUING_AUTHORITY'
      - 'IDENTIFICATION_NUMBER'
      - 'IDENTIFICATION_TYPE_CODE'
      - 'IDENTIFICATION_VERIFIED_INDICATOR'
      - 'INSURANCE_REPOSITORY_NAME'
      - 'NREGA_CARD_NUMBER'
      - 'OVD_CATEGORY'
      - 'PAN_NUMBER'
      - 'PAN_VERIFICATION_STATUS'
      - 'PASSPORT_EXPIRY_DATE'
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
derived_columns:
  CLAIM_BK: "nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'')"
  CLAIM_NK: "'HUB_CLAIM|' || (nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),''))"
  CLAIM_BK__CLAIMANT: "nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'')"
  CLAIM_NK__CLAIMANT: "'HUB_CLAIM|' || (nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),''))"
  CLAIM_BK__EXPENSE_LINE_PARTY: "nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'')"
  CLAIM_NK__EXPENSE_LINE_PARTY: "'HUB_CLAIM|' || (nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),''))"
  CLAIM_BK__EXPENSE_PAYEE: "nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'')"
  CLAIM_NK__EXPENSE_PAYEE: "'HUB_CLAIM|' || (nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),''))"
  CLAIM_BK__PAYEE: "nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'')"
  CLAIM_NK__PAYEE: "'HUB_CLAIM|' || (nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),''))"
  CLAIM_BK__TDS_DEDUCTEE: "nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'')"
  CLAIM_NK__TDS_DEDUCTEE: "'HUB_CLAIM|' || (nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),''))"
  CLAIM_PARTY_BK__CLAIMANT: "coalesce(nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),''),'') || '|' || coalesce(nullif(trim(case when coalesce(nullif(trim(claimant_party_code),'')) is not null then nullif(trim(claimant_party_code), '') end),''),'')"
  CLAIM_PARTY_NK__CLAIMANT: "'LNK_CLAIM_PARTY|' || (coalesce(nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),''),'') || '|' || coalesce(nullif(trim(case when coalesce(nullif(trim(claimant_party_code),'')) is not null then nullif(trim(claimant_party_code), '') end),''),''))"
  CLAIM_PARTY_BK__EXPENSE_LINE_PARTY: "coalesce(nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),''),'') || '|' || coalesce(nullif(trim(case when coalesce(nullif(trim(party_name_code),'')) is not null then nullif(trim(party_name_code), '') end),''),'')"
  CLAIM_PARTY_NK__EXPENSE_LINE_PARTY: "'LNK_CLAIM_PARTY|' || (coalesce(nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),''),'') || '|' || coalesce(nullif(trim(case when coalesce(nullif(trim(party_name_code),'')) is not null then nullif(trim(party_name_code), '') end),''),''))"
  CLAIM_PARTY_BK__EXPENSE_PAYEE: "coalesce(nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),''),'') || '|' || coalesce(nullif(trim(case when coalesce(nullif(trim(expense_payee_party_code),'')) is not null then nullif(trim(expense_payee_party_code), '') end),''),'')"
  CLAIM_PARTY_NK__EXPENSE_PAYEE: "'LNK_CLAIM_PARTY|' || (coalesce(nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),''),'') || '|' || coalesce(nullif(trim(case when coalesce(nullif(trim(expense_payee_party_code),'')) is not null then nullif(trim(expense_payee_party_code), '') end),''),''))"
  CLAIM_PARTY_BK__PAYEE: "coalesce(nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),''),'') || '|' || coalesce(nullif(trim(case when coalesce(nullif(trim(payee_code),'')) is not null then nullif(trim(payee_code), '') end),''),'')"
  CLAIM_PARTY_NK__PAYEE: "'LNK_CLAIM_PARTY|' || (coalesce(nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),''),'') || '|' || coalesce(nullif(trim(case when coalesce(nullif(trim(payee_code),'')) is not null then nullif(trim(payee_code), '') end),''),''))"
  CLAIM_PARTY_BK__TDS_DEDUCTEE: "coalesce(nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),''),'') || '|' || coalesce(nullif(trim(case when coalesce(nullif(trim(tds_claimant_party_code),'')) is not null then nullif(trim(tds_claimant_party_code), '') end),''),'')"
  CLAIM_PARTY_NK__TDS_DEDUCTEE: "'LNK_CLAIM_PARTY|' || (coalesce(nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),''),'') || '|' || coalesce(nullif(trim(case when coalesce(nullif(trim(tds_claimant_party_code),'')) is not null then nullif(trim(tds_claimant_party_code), '') end),''),''))"
  FINANCIAL_TRANSACTION_BK__CLAIM_BILL_INVOICE: "nullif(trim(case when coalesce(nullif(trim(invoice_number),'')) is not null then 'INV:' || nullif(trim(invoice_number), '') end),'')"
  FINANCIAL_TRANSACTION_NK__CLAIM_BILL_INVOICE: "'HUB_FINANCIAL_TRANSACTION|' || (nullif(trim(case when coalesce(nullif(trim(invoice_number),'')) is not null then 'INV:' || nullif(trim(invoice_number), '') end),''))"
  FINANCIAL_TRANSACTION_BK__CLAIM_PAYMENT: "nullif(trim(case when coalesce(nullif(trim(payment_id),'')) is not null then 'PAY:' || nullif(trim(payment_id), '') end),'')"
  FINANCIAL_TRANSACTION_NK__CLAIM_PAYMENT: "'HUB_FINANCIAL_TRANSACTION|' || (nullif(trim(case when coalesce(nullif(trim(payment_id),'')) is not null then 'PAY:' || nullif(trim(payment_id), '') end),''))"
  LOCATION_BK__CLAIM_EXPENSE_PARTY_ADDRESS: "nullif(trim(case when coalesce(nullif(trim(address),'')) is not null then md5(upper(regexp_replace(trim(nullif(trim(address), '')), '[[:space:]]+', ' '))) end),'')"
  LOCATION_NK__CLAIM_EXPENSE_PARTY_ADDRESS: "'HUB_LOCATION|' || (nullif(trim(case when coalesce(nullif(trim(address),'')) is not null then md5(upper(regexp_replace(trim(nullif(trim(address), '')), '[[:space:]]+', ' '))) end),''))"
  PARTY_BK__CLAIMANT: "nullif(trim(case when coalesce(nullif(trim(claimant_party_code),'')) is not null then nullif(trim(claimant_party_code), '') end),'')"
  PARTY_NK__CLAIMANT: "'HUB_PARTY|' || (nullif(trim(case when coalesce(nullif(trim(claimant_party_code),'')) is not null then nullif(trim(claimant_party_code), '') end),''))"
  PARTY_BK__EXPENSE_LINE_PARTY: "nullif(trim(case when coalesce(nullif(trim(party_name_code),'')) is not null then nullif(trim(party_name_code), '') end),'')"
  PARTY_NK__EXPENSE_LINE_PARTY: "'HUB_PARTY|' || (nullif(trim(case when coalesce(nullif(trim(party_name_code),'')) is not null then nullif(trim(party_name_code), '') end),''))"
  PARTY_BK__EXPENSE_PAYEE: "nullif(trim(case when coalesce(nullif(trim(expense_payee_party_code),'')) is not null then nullif(trim(expense_payee_party_code), '') end),'')"
  PARTY_NK__EXPENSE_PAYEE: "'HUB_PARTY|' || (nullif(trim(case when coalesce(nullif(trim(expense_payee_party_code),'')) is not null then nullif(trim(expense_payee_party_code), '') end),''))"
  PARTY_BK__PAYEE: "nullif(trim(case when coalesce(nullif(trim(payee_code),'')) is not null then nullif(trim(payee_code), '') end),'')"
  PARTY_NK__PAYEE: "'HUB_PARTY|' || (nullif(trim(case when coalesce(nullif(trim(payee_code),'')) is not null then nullif(trim(payee_code), '') end),''))"
  PARTY_BK__TDS_DEDUCTEE: "nullif(trim(case when coalesce(nullif(trim(tds_claimant_party_code),'')) is not null then nullif(trim(tds_claimant_party_code), '') end),'')"
  PARTY_NK__TDS_DEDUCTEE: "'HUB_PARTY|' || (nullif(trim(case when coalesce(nullif(trim(tds_claimant_party_code),'')) is not null then nullif(trim(tds_claimant_party_code), '') end),''))"
  POLICY_BK: "nullif(trim(case when coalesce(nullif(trim(w1_policyno),'')) is not null then nullif(trim(w1_policyno), '') end),'')"
  POLICY_NK: "'HUB_POLICY|' || (nullif(trim(case when coalesce(nullif(trim(w1_policyno),'')) is not null then nullif(trim(w1_policyno), '') end),''))"
  AADHAAR_NUMBER: 'cast(null as varchar)'
  AADHAAR_VERIFICATION_STATUS: 'cast(null as varchar)'
  ADDRESS_LINE_1: 'address'
  ADDRESS_LINE_2: 'cast(null as varchar)'
  ADDRESS_LINE_3: 'cast(null as varchar)'
  ADDRESS_TYPE_CODE: 'cast(null as varchar)'
  ADMISSION_DATE: 'cast(null as varchar)'
  AGE: 'cast(null as varchar)'
  AGE_PROOF_TYPE: 'cast(null as varchar)'
  AILMENT_DESCRIPTION: 'icd_description'
  APPROVAL_REFERENCE: 'cast(null as varchar)'
  APPROVED_AMOUNT: 'approved_amount'
  AWARD_AMOUNT: 'award_amount'
  BILLED_AMOUNT: 'bill_amount'
  BILL_NUMBER: "coalesce(nullif(trim(bill_no), ''),'')"
  BILL_STATUS_TYPE: 'bill_status'
  CARE_OF_NAME: 'cast(null as varchar)'
  CIN_NUMBER: 'cast(null as varchar)'
  CITY: 'cast(null as varchar)'
  CKYC_NUMBER: 'cast(null as varchar)'
  CLAIM_SUB_TYPE: 'type_of_loss'
  COUNTRY_CODE: 'cast(null as varchar)'
  COUNTRY_NAME: 'cast(null as varchar)'
  COUNTRY_OF_BIRTH: 'cast(null as varchar)'
  COUNTRY_OF_INCIDENT: 'country_of_loss'
  COUNTRY_OF_RESIDENCE: 'cast(null as varchar)'
  COURT_NAME: 'cast(null as varchar)'
  COURT_TYPE: 'cast(null as varchar)'
  CO_INSURANCE_INDICATOR: 'cast(null as varchar)'
  CO_INSURANCE_OUR_SHARE_PERCENTAGE: 'cast(null as varchar)'
  CURRENCY_CODE: 'total_si_policy_currency'
  CURRENCY_OF_LOSS: 'cast(null as varchar)'
  DATE_OF_BIRTH: 'cast(null as varchar)'
  DISALLOWANCE_REASON: 'disallowance_reason'
  DISALLOWED_AMOUNT: 'disallowed_amount'
  DISCHARGE_DATE: 'cast(null as varchar)'
  DISTRICT: 'cast(null as varchar)'
  DRIVING_LICENCE_EXPIRY_DATE: 'cast(null as varchar)'
  DRIVING_LICENCE_NUMBER: 'cast(null as varchar)'
  EIA_NUMBER: 'cast(null as varchar)'
  EXPENSE_SHARE_AMOUNT: 'coinsurance_expense_amount'
  FINAL_INDICATOR: 'payment_type_interimfinal'
  FIRST_NAME: 'cast(null as varchar)'
  FIRST_YEAR_INDICATOR: 'cast(null as varchar)'
  FRAUD_SCORE: 'cast(null as varchar)'
  FRAUD_TRIGGER_REASON: 'fraud_trigger_type'
  FRAUD_TYPE: 'fraud_type'
  GENDER_CODE: 'cast(null as varchar)'
  GROSS_AMOUNT: 'cast(null as varchar)'
  GSTIN: 'cast(null as varchar)'
  GST_REGISTRATION_STATUS: 'cast(null as varchar)'
  GST_TAXPAYER_TYPE: 'cast(null as varchar)'
  HEALTH_CLAIM_REMARKS: 'cast(null as varchar)'
  HOLD_INDICATOR: 'no_payment_release_flag'
  HOLD_REASON: 'no_payment_release_reason'
  ICD_CODE: 'icd_code'
  IDENTIFICATION_EXPIRY_DATE: 'cast(null as varchar)'
  IDENTIFICATION_ISSUE_DATE: 'cast(null as varchar)'
  IDENTIFICATION_ISSUING_AUTHORITY: 'cast(null as varchar)'
  IDENTIFICATION_NUMBER: 'cast(null as varchar)'
  IDENTIFICATION_TYPE_CODE: "'PAN'"
  IDENTIFICATION_VERIFIED_INDICATOR: 'cast(null as varchar)'
  INCIDENT_DATE: 'cast(null as varchar)'
  INSURANCE_REPOSITORY_NAME: 'cast(null as varchar)'
  INTEREST_PAID_AMOUNT: 'interest_amount'
  INVESTIGATION_REFERENCE: 'cast(null as varchar)'
  INVESTIGATION_REFERRED_INDICATOR: 'cast(null as varchar)'
  INVESTIGATION_STATUS: 'cast(null as varchar)'
  LANDMARK: 'cast(null as varchar)'
  LAST_NAME: 'cast(null as varchar)'
  LEADER_INDICATOR: 'cast(null as varchar)'
  LENGTH_OF_STAY: 'cast(null as varchar)'
  LOCALITY: 'cast(null as varchar)'
  LOSS_AMOUNT_FOREIGN: 'cast(null as varchar)'
  LOSS_AMOUNT_INR: 'cast(null as varchar)'
  MIDDLE_NAME: 'cast(null as varchar)'
  NATIONALITY: 'cast(null as varchar)'
  NET_AMOUNT: 'cast(null as varchar)'
  NET_RECOVERY_AMOUNT: 'recovery_amount'
  NREGA_CARD_NUMBER: 'cast(null as varchar)'
  OVD_CATEGORY: 'cast(null as varchar)'
  PAN_NUMBER: 'coalesce(pan_no, tds_pan_number)'
  PAN_VERIFICATION_STATUS: 'cast(null as varchar)'
  PARTY_FULL_NAME: 'party_name'
  PARTY_LEGAL_NAME: 'cast(null as varchar)'
  PARTY_ROLE_TYPE: "coalesce(nullif(trim(claimant_stake_code), ''),'')"
  PARTY_STATUS: 'cast(null as varchar)'
  PARTY_SUB_TYPE_CODE: 'cast(null as varchar)'
  PARTY_TYPE_CODE: 'cast(null as varchar)'
  PASSPORT_EXPIRY_DATE: 'cast(null as varchar)'
  PASSPORT_NUMBER: 'cast(null as varchar)'
  PAYMENT_DATE: 'payment_date'
  PAYMENT_MODE: 'payment_mode'
  PAYMENT_TYPE: 'type_of_payment'
  POLICYHOLDER_REFERENCE: 'cast(null as varchar)'
  POLICY_CHANNEL_TYPE: 'cast(null as varchar)'
  POLICY_REFERENCE_NUMBER: 'cast(null as varchar)'
  POLICY_REMARKS: 'cast(null as varchar)'
  POLICY_STATUS: 'cast(null as varchar)'
  POLICY_SUB_STATUS: 'cast(null as varchar)'
  POLICY_TERM: 'cast(null as varchar)'
  POLICY_TYPE: 'cast(null as varchar)'
  POSTAL_CODE: 'cast(null as varchar)'
  POST_OFFICE_NAME: 'cast(null as varchar)'
  PREMIUM_FREQUENCY: 'cast(null as varchar)'
  PREMIUM_PAYER_REFERENCE: 'cast(null as varchar)'
  PRE_EXISTING_DISEASE_RELATED_INDICATOR: 'cast(null as varchar)'
  PRODUCT_REFERENCE: 'cast(null as varchar)'
  RISK_END_TIME: 'cast(null as varchar)'
  RISK_EXPIRY_DATE: 'cast(null as varchar)'
  RISK_INCEPTION_DATE: 'cast(null as varchar)'
  RISK_START_TIME: 'cast(null as varchar)'
  ROLE_SEQUENCE: "'1'"
  SALUTATION: 'cast(null as varchar)'
  STATE_CODE: 'cast(null as varchar)'
  STATE_NAME: 'cast(null as varchar)'
  STATUS: 'payment_status'
  STREET_NAME: 'cast(null as varchar)'
  SUM_INSURED_TOTAL: 'total_si_amount_in_policy_si_currency'
  TAN_NUMBER: 'cast(null as varchar)'
  TRANCHE_NUMBER: "coalesce(nullif(trim(payment_id), ''),'')"
  TREATING_DOCTOR_NAME: 'cast(null as varchar)'
  TREATMENT_TYPE: 'cast(null as varchar)'
  VOTER_ID_NUMBER: 'cast(null as varchar)'
  ADVERSE_MEDICAL_HISTORY_DESCRIPTION: 'cast(null as varchar)'
  DISEASE_CATEGORY: 'disease_category'
  ICD_DESCRIPTION: 'cast(null as varchar)'
  MEDICALLY_ADMISSIBLE_INDICATOR: 'cast(null as varchar)'
  PRE_EXISTING_DISEASE_DESCRIPTION: 'cast(null as varchar)'
  PRE_EXISTING_ILLNESS_DESCRIPTION: 'cast(null as varchar)'
  SYSTEM_OF_MEDICINE: 'cast(null as varchar)'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
