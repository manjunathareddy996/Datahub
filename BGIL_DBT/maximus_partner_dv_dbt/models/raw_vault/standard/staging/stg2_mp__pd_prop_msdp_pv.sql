{{ config(materialized='view') }}

-- MAXIMUS PARTNER wide stage() for BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW.
-- 4 key(s), 7 single-active satellite(s).

{%- set yaml_metadata -%}
source_model: 'stg_maximus__pd_prop_msdp_pv'
hashed_columns:
  FINANCIAL_ACCOUNT_HKEY: 'FINANCIAL_ACCOUNT_NK'
  ORG_UNIT_HKEY: 'ORG_UNIT_NK'
  PARTY_HKEY: 'PARTY_NK'
  PAYMENT_INSTRUMENT_HKEY: 'PAYMENT_INSTRUMENT_NK'
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
  HASHDIFF_INSTRUMENT_DEFINITION:
    is_hashdiff: true
    columns:
      - 'CARD_NUMBER_MASKED'
      - 'CARD_TYPE'
  HASHDIFF_PARTY_AGENT_LICENCE_LINE:
    is_hashdiff: true
    columns:
      - 'AUTHORISEDINDICATOR'
      - 'EXAMINATION_REFERENCE'
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
  HASHDIFF_PARTY_PAYOUT_PROFILE:
    is_hashdiff: true
    columns:
      - 'GST_APPLICABLE_INDICATOR'
      - 'PAYOUTHOLDREASON'
      - 'TDSAPPLICABLEINDICATOR'
      - 'TDS_RATE'
derived_columns:
  FINANCIAL_ACCOUNT_BK: "account_code"
  FINANCIAL_ACCOUNT_NK: "'HUB_FINANCIAL_ACCOUNT|' || (account_code)"
  ORG_UNIT_BK: "company"
  ORG_UNIT_NK: "'HUB_ORG_UNIT|' || (company)"
  PARTY_BK: "foreign_key"
  PARTY_NK: "'HUB_PARTY|' || (foreign_key)"
  PAYMENT_INSTRUMENT_BK: "'HUB_PAYMENT_INSTRUMENT|' || foreign_key"
  PAYMENT_INSTRUMENT_NK: "'HUB_PAYMENT_INSTRUMENT|' || ('HUB_PAYMENT_INSTRUMENT|' || foreign_key)"
  EMAIL_ADDRESS: "email_id"
  MOBILE_NUMBER: "mobile_no"
  LANDLINE_NUMBER: "cast(null as varchar)"
  SOCIALMEDIAHANDLE: "cast(null as varchar)"
  FAX_NUMBER: "cast(null as varchar)"
  STD_CODE: "cast(null as varchar)"
  ALTERNATE_EMAIL_ADDRESS: "cast(null as varchar)"
  ALTERNATE_MOBILE_NUMBER: "cast(null as varchar)"
  CARD_NUMBER_MASKED: "credit_card_number"
  CARD_TYPE: "credit_card_type"
  AUTHORISEDINDICATOR: "coalesce(aviation, credit_insurance, crop_insurance, engineering, fire, health, liability, marine_cargo, marine_hull, miscellaneous, motor, overseas_medical, personal_accident, property, rural, travel, weather_insurance, workmens_compensation)"
  EXAMINATION_REFERENCE: "cast(null as varchar)"
  ACCOUNT_HOLDER_NAME: "account_holder_name"
  ACCOUNT_NUMBER_MASKED: "account_number"
  ACCOUNT_TYPE: "account_type"
  BRANCH_NAME: "bank_branch_name"
  BANK_NAME: "bank_name"
  IFSC_CODE: "ifsc"
  MICR_CODE: "micr"
  PENNYDROPVERIFIEDINDICATOR: "pennydropless_flag"
  PRIMARYACCOUNTINDICATOR: "primary_secondary"
  MAXIMUMAMOUNT: "mandate_amount"
  MANDATESTARTDATE: "mandate_registered_on"
  MANDATE_TYPE: "mandate_type"
  BANKREFERENCE: "name_of_the_bank"
  MANDATEREFERENCE: "umrn_no"
  FREQUENCY: "cast(null as varchar)"
  PASSPORTEXPIRYDATE: "passport_expiry_date"
  IDENTIFICATION_ISSUE_DATE: "passport_issue_date"
  PASSPORT_NUMBER: "passport_number"
  AADHAAR_NUMBER: "cast(null as varchar)"
  AGE_PROOF_TYPE: "cast(null as varchar)"
  IDENTIFICATION_TYPE_CODE: "cast(null as varchar)"
  NREGA_CARD_NUMBER: "cast(null as varchar)"
  GST_REGISTRATION_STATUS: "cast(null as varchar)"
  DRIVING_LICENCE_NUMBER: "cast(null as varchar)"
  DRIVING_LICENCE_EXPIRY_DATE: "cast(null as varchar)"
  CIN_NUMBER: "cast(null as varchar)"
  IDENTIFICATION_NUMBER: "cast(null as varchar)"
  IDENTIFICATION_ISSUING_AUTHORITY: "cast(null as varchar)"
  AADHAAR_VERIFICATION_STATUS: "cast(null as varchar)"
  IDENTIFICATION_EXPIRY_DATE: "cast(null as varchar)"
  VOTER_ID_NUMBER: "cast(null as varchar)"
  GST_TAXPAYER_TYPE: "cast(null as varchar)"
  FORM60INDICATOR: "cast(null as varchar)"
  PAN_NUMBER: "cast(null as varchar)"
  IDENTIFICATION_VERIFIED_INDICATOR: "cast(null as varchar)"
  TAN_NUMBER: "cast(null as varchar)"
  GSTIN: "cast(null as varchar)"
  PAN_VERIFICATION_STATUS: "cast(null as varchar)"
  EIA_NUMBER: "cast(null as varchar)"
  INSURANCEREPOSITORYNAME: "cast(null as varchar)"
  OVD_CATEGORY: "cast(null as varchar)"
  TDSAPPLICABLEINDICATOR: "tax_to_deduct"
  TDS_RATE: "tds_rate"
  GST_APPLICABLE_INDICATOR: "cast(null as varchar)"
  PAYOUTHOLDREASON: "cast(null as varchar)"
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                     source_model=metadata_dict['source_model'],
                     hashed_columns=metadata_dict['hashed_columns'],
                     derived_columns=metadata_dict['derived_columns']) }}
