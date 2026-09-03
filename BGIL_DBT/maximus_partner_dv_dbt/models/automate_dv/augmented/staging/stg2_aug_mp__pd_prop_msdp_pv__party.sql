{{ config(materialized='view') }}

-- MAXIMUS PARTNER AUGMENTED (unconfirmed) WIDE stage() for HUB_PARTY, view 'pd_prop_msdp_pv'.
-- Serves 6 augmented satellite(s), one HASHDIFF each, from 29
-- column(s) with no faithful home in data_7. The KEY is the standard track's own
-- expression for HUB_PARTY on this view; the ATTRIBUTE GROUPING is the mapper's
-- proposal and is NOT canonical.

{%- set yaml_metadata -%}
source_model: 'stg_maximus__pd_prop_msdp_pv'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF_AUG_PARTY_BANKING:
    is_hashdiff: true
    columns:
      - 'BANKINGDETAILSDESCRIPTION'
      - 'NEFTREGISTRATIONSTATUS'
      - 'REFUNDBENEFICIARYPARTYREFERENCE'
  HASHDIFF_AUG_PARTY_CREDIT_CONTROL_PAYMENT_TERMS:
    is_hashdiff: true
    columns:
      - 'APPROVEDEXPENSELIMIT'
      - 'AVAILABLECREDITLIMIT'
      - 'PAYMENTPLANNAME'
      - 'PAYMENTPLANTYPE'
      - 'SANCTIONEDCREDITLIMIT'
      - 'TEMPORARYCREDITLIMIT'
      - 'TEMPORARYCREDITLIMITEXPIRYDATE'
      - 'TEMPORARYCREDITLIMITSTARTDATE'
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
  HASHDIFF_AUG_PARTY_SOURCE_PROPERTY_SET_RECORD_GOVERNANCE:
    is_hashdiff: true
    columns:
      - 'APPROVEDREJECTEDBYREFERENCE'
      - 'APPROVEDREJECTEDDATE'
      - 'CHANGEEFFECTIVEFROMDATE'
      - 'PROPERTYEFFECTIVEDATE'
      - 'PROPERTYENDDATE'
      - 'PROPERTYEXPIRYDATE'
      - 'PROPERTYRECORDSTATUS'
      - 'PROPERTYSETREMARKS'
      - 'PROPERTYSTARTDATE'
derived_columns:
  PARTY_BK: "foreign_key"
  PARTY_NK: "'HUB_PARTY|' || (foreign_key)"
  ADDRESSPROOFTYPE: "cast(null as varchar)"
  APPROVEDEXPENSELIMIT: "app_expense_limit"
  APPROVEDREJECTEDBYREFERENCE: "approvedrejected_by"
  APPROVEDREJECTEDDATE: "approvedrejected_date"
  AVAILABLECREDITLIMIT: "avl_credit_limit"
  BANKINGDETAILSDESCRIPTION: "cast(null as varchar)"
  BASICQUALIFICATIONDETAILS: "cast(null as varchar)"
  BASICQUALIFICATIONROLLNUMBER: "cast(null as varchar)"
  CHANGEEFFECTIVEFROMDATE: "with_effective_from"
  DEFAULTCREDITGLACCOUNTCODE: "acc_code_cr"
  DEFAULTDEBITGLACCOUNTCODE: "acc_code_dr"
  EDUCATIONINSTITUTENAME: "cast(null as varchar)"
  EIAACCOUNTDETAILS: "cast(null as varchar)"
  EIAAVAILABLEINDICATOR: "cast(null as varchar)"
  EIACREDITREQUIREDINDICATOR: "cast(null as varchar)"
  EIALINKEDDATE: "cast(null as varchar)"
  EIAREQUIREDINDICATOR: "cast(null as varchar)"
  FATHERORSPOUSENAME: "cast(null as varchar)"
  FLOATACCOUNTACCESSINDICATOR: "cast(null as varchar)"
  FLOATREPLENISHMENTCONDITION: "cast(null as varchar)"
  INCOMEBANDLOWERBOUND: "from_income"
  INCOMEBANDUPPERBOUND: "to_income"
  INTERIMPAYMENTINDICATOR: "cast(null as varchar)"
  LOWERTDSCERTIFICATEREFERENCE: "cast(null as varchar)"
  MARRIAGEANNIVERSARYDATE: "cast(null as varchar)"
  MATRICULATIONQUALIFICATIONDETAIL: "cast(null as varchar)"
  MONTHLYGROSSINCOME: "cast(null as varchar)"
  MOTHERSMAIDENNAME: "cast(null as varchar)"
  NAMEASPERIDENTIFICATION: "cast(null as varchar)"
  NEFTREGISTRATIONSTATUS: "neft_status"
  NUMBEROFDAUGHTERS: "cast(null as varchar)"
  NUMBEROFSONS: "cast(null as varchar)"
  OCCUPATIONLIST: "cast(null as varchar)"
  OTHEROCCUPATION: "cast(null as varchar)"
  OTHERQUALIFICATION: "cast(null as varchar)"
  OVDCATEGORYOTHERDETAIL: "cast(null as varchar)"
  PASSPORTFILENUMBER: "passport_file_no"
  PASSPORTISSUINGCOUNTRY: "passport_issue_country"
  PAYCLAIMSCANCELMONTHLYINDICATOR: "cast(null as varchar)"
  PAYEECODE: "cast(null as varchar)"
  PAYEENAME: "cast(null as varchar)"
  PAYEETYPE: "payee_type"
  PAYMENTDETAILSDESCRIPTION: "cast(null as varchar)"
  PAYMENTMODE: "cast(null as varchar)"
  PAYMENTPLAN: "cast(null as varchar)"
  PAYMENTPLANNAME: "payment_plan_name"
  PAYMENTPLANTYPE: "payment_plan_type"
  PAYMENTSCHEDULE: "cast(null as varchar)"
  PERSONALDETAILSDESCRIPTION: "cast(null as varchar)"
  POSTGRADUATEQUALIFICATION: "cast(null as varchar)"
  PROFESSIONALQUALIFICATION: "cast(null as varchar)"
  PROPERTYEFFECTIVEDATE: "effective_date"
  PROPERTYENDDATE: "end_date"
  PROPERTYEXPIRYDATE: "expiry_date"
  PROPERTYRECORDSTATUS: "status"
  PROPERTYSETREMARKS: "remarks"
  PROPERTYSTARTDATE: "start_date"
  QUALIFICATIONBOARDNAME: "cast(null as varchar)"
  QUALIFICATIONDETAIL: "cast(null as varchar)"
  QUALIFICATIONPASSINGMONTH: "cast(null as varchar)"
  REFUNDBENEFICIARYPARTYREFERENCE: "cast(null as varchar)"
  REWARDSCHEMEAPPLICABLEINDICATOR: "cast(null as varchar)"
  SANCTIONEDCREDITLIMIT: "credit_limit"
  SERVICETAXAPPLICABLEINDICATOR: "cast(null as varchar)"
  TDSCERTIFICATEISSUEDATE: "certificate_issue_date"
  TDSCERTIFICATENUMBER: "tds_certificate_no"
  TDSCERTIFICATETYPE: "certificate_type"
  TDSCODE: "cast(null as varchar)"
  TDSCODEDESCRIPTION: "cast(null as varchar)"
  TDSDETAILDESCRIPTION: "cast(null as varchar)"
  TDSSECTIONCODE: "tds_section_code"
  TEMPORARYCREDITLIMIT: "temp_credit_limit"
  TEMPORARYCREDITLIMITEXPIRYDATE: "temp_cr_limit_exp_date"
  TEMPORARYCREDITLIMITSTARTDATE: "temp_cr_limit_start_date"
  UNDERGRADUATEQUALIFICATION: "cast(null as varchar)"
  YEAROFPASSINGQUALIFICATION: "cast(null as varchar)"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!pd_prop_msdp_pv'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                     source_model=metadata_dict['source_model'],
                     hashed_columns=metadata_dict['hashed_columns'],
                     derived_columns=metadata_dict['derived_columns']) }}
