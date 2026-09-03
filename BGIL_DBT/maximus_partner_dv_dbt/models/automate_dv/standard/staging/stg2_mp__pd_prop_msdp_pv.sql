{{ config(materialized='view') }}

-- MAXIMUS PARTNER wide stage() for BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW_2_1.
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
      - 'ALTERNATEEMAILADDRESS'
      - 'ALTERNATEMOBILENUMBER'
      - 'EMAILADDRESS'
      - 'FAXNUMBER'
      - 'LANDLINENUMBER'
      - 'MOBILENUMBER'
      - 'SOCIALMEDIAHANDLE'
      - 'STDCODE'
  HASHDIFF_INSTRUMENT_DEFINITION:
    is_hashdiff: true
    columns:
      - 'CARDNUMBERMASKED'
      - 'CARDTYPE'
  HASHDIFF_PARTY_AGENT_LICENCE_LINE:
    is_hashdiff: true
    columns:
      - 'AUTHORISEDINDICATOR'
      - 'EXAMINATIONREFERENCE'
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
  HASHDIFF_PARTY_PAYOUT_PROFILE:
    is_hashdiff: true
    columns:
      - 'GSTAPPLICABLEINDICATOR'
      - 'PAYOUTHOLDREASON'
      - 'TDSAPPLICABLEINDICATOR'
      - 'TDSRATE'
derived_columns:
  FINANCIAL_ACCOUNT_BK: "account_code"
  FINANCIAL_ACCOUNT_NK: "'HUB_FINANCIAL_ACCOUNT|' || (account_code)"
  ORG_UNIT_BK: "company"
  ORG_UNIT_NK: "'HUB_ORG_UNIT|' || (company)"
  PARTY_BK: "foreign_key"
  PARTY_NK: "'HUB_PARTY|' || (foreign_key)"
  PAYMENT_INSTRUMENT_BK: "'HUB_PAYMENT_INSTRUMENT|' || foreign_key"
  PAYMENT_INSTRUMENT_NK: "'HUB_PAYMENT_INSTRUMENT|' || ('HUB_PAYMENT_INSTRUMENT|' || foreign_key)"
  EMAILADDRESS: "email_id"
  MOBILENUMBER: "mobile_no"
  LANDLINENUMBER: "cast(null as varchar)"
  SOCIALMEDIAHANDLE: "cast(null as varchar)"
  FAXNUMBER: "cast(null as varchar)"
  STDCODE: "cast(null as varchar)"
  ALTERNATEEMAILADDRESS: "cast(null as varchar)"
  ALTERNATEMOBILENUMBER: "cast(null as varchar)"
  CARDNUMBERMASKED: "credit_card_number"
  CARDTYPE: "credit_card_type"
  AUTHORISEDINDICATOR: "coalesce(aviation, credit_insurance, crop_insurance, engineering, fire, health, liability, marine_cargo, marine_hull, miscellaneous, motor, overseas_medical, personal_accident, property, rural, travel, weather_insurance, workmens_compensation)"
  EXAMINATIONREFERENCE: "cast(null as varchar)"
  ACCOUNTHOLDERNAME: "account_holder_name"
  ACCOUNTNUMBERMASKED: "account_number"
  ACCOUNTTYPE: "account_type"
  BRANCHNAME: "bank_branch_name"
  BANKNAME: "bank_name"
  IFSCCODE: "ifsc"
  MICRCODE: "micr"
  PENNYDROPVERIFIEDINDICATOR: "pennydropless_flag"
  PRIMARYACCOUNTINDICATOR: "primary_secondary"
  MAXIMUMAMOUNT: "mandate_amount"
  MANDATESTARTDATE: "mandate_registered_on"
  MANDATETYPE: "mandate_type"
  BANKREFERENCE: "name_of_the_bank"
  MANDATEREFERENCE: "umrn_no"
  FREQUENCY: "cast(null as varchar)"
  PASSPORTEXPIRYDATE: "passport_expiry_date"
  IDENTIFICATIONISSUEDATE: "passport_issue_date"
  PASSPORTNUMBER: "passport_number"
  AADHAARNUMBER: "cast(null as varchar)"
  AGEPROOFTYPE: "cast(null as varchar)"
  IDENTIFICATIONTYPECODE: "cast(null as varchar)"
  NREGACARDNUMBER: "cast(null as varchar)"
  GSTREGISTRATIONSTATUS: "cast(null as varchar)"
  DRIVINGLICENCENUMBER: "cast(null as varchar)"
  DRIVINGLICENCEEXPIRYDATE: "cast(null as varchar)"
  CINNUMBER: "cast(null as varchar)"
  IDENTIFICATIONNUMBER: "cast(null as varchar)"
  IDENTIFICATIONISSUINGAUTHORITY: "cast(null as varchar)"
  AADHAARVERIFICATIONSTATUS: "cast(null as varchar)"
  IDENTIFICATIONEXPIRYDATE: "cast(null as varchar)"
  VOTERIDNUMBER: "cast(null as varchar)"
  GSTTAXPAYERTYPE: "cast(null as varchar)"
  FORM60INDICATOR: "cast(null as varchar)"
  PANNUMBER: "cast(null as varchar)"
  IDENTIFICATIONVERIFIEDINDICATOR: "cast(null as varchar)"
  TANNUMBER: "cast(null as varchar)"
  GSTIN: "cast(null as varchar)"
  PANVERIFICATIONSTATUS: "cast(null as varchar)"
  EIANUMBER: "cast(null as varchar)"
  INSURANCEREPOSITORYNAME: "cast(null as varchar)"
  OVDCATEGORY: "cast(null as varchar)"
  TDSAPPLICABLEINDICATOR: "tax_to_deduct"
  TDSRATE: "tds_rate"
  GSTAPPLICABLEINDICATOR: "cast(null as varchar)"
  PAYOUTHOLDREASON: "cast(null as varchar)"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW_2_1'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                     source_model=metadata_dict['source_model'],
                     hashed_columns=metadata_dict['hashed_columns'],
                     derived_columns=metadata_dict['derived_columns']) }}
