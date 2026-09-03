{{ config(materialized='view') }}

-- MAXIMUS PARTNER wide stage() for BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL.
-- 1 key(s), 4 single-active satellite(s).

{%- set yaml_metadata -%}
source_model: 'stg_maximus__pd'
hashed_columns:
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF_PARTY_HIERARCHY:
    is_hashdiff: true
    columns:
      - 'HIERARCHYLEVEL'
      - 'REPORTINGPARENTREFERENCE'
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
derived_columns:
  PARTY_BK: "party_code"
  PARTY_NK: "'HUB_PARTY|' || (party_code)"
  REPORTINGPARENTREFERENCE: "parent_party_code"
  HIERARCHYLEVEL: "cast(null as varchar)"
  PARTYLEGALNAME: "business_name"
  DATEOFBIRTH: "date_of_birth"
  FIRSTNAME: "first_name"
  GENDERCODE: "gender"
  LASTNAME: "last_name"
  MIDDLENAME: "middle_name"
  NATIONALITY: "nationality"
  PARTYORIGINATIONDATE: "party_start_date"
  PARTYSTATUS: "party_status"
  SALUTATION: "title"
  PARTYTYPECODE: "type_of_party"
  COUNTRYOFBIRTH: "cast(null as varchar)"
  COUNTRYOFRESIDENCE: "cast(null as varchar)"
  DATEOFDEATH: "cast(null as varchar)"
  AGE: "cast(null as varchar)"
  PARTYSUBTYPECODE: "cast(null as varchar)"
  PARTYFULLNAME: "cast(null as varchar)"
  OCCUPATIONCODE: "occupation"
  VEHICLEOWNEDINDICATOR: "cast(null as varchar)"
  SPOUSENAME: "cast(null as varchar)"
  OCCUPATIONDESCRIPTION: "cast(null as varchar)"
  FATHERNAME: "cast(null as varchar)"
  EDUCATIONALQUALIFICATION: "cast(null as varchar)"
  ANNUALINCOME: "cast(null as varchar)"
  YEARSINCITY: "cast(null as varchar)"
  DESIGNATION: "cast(null as varchar)"
  MARITALSTATUS: "cast(null as varchar)"
  HIGHESTDEGREE: "cast(null as varchar)"
  DATEOFINCORPORATION: "registration_date"
  BUSINESSREGISTRATIONNUMBER: "registration_no"
  LEGALCONSTITUTIONTYPE: "type_of_organization"
  INDUSTRYDESCRIPTION: "cast(null as varchar)"
  NATUREOFBUSINESS: "cast(null as varchar)"
  NUMBEROFEMPLOYEES: "cast(null as varchar)"
  PAIDUPCAPITAL: "cast(null as varchar)"
  ANNUALTURNOVER: "cast(null as varchar)"
  MSMEINDICATOR: "cast(null as varchar)"
  MSMECATEGORY: "cast(null as varchar)"
  INDUSTRYCODE: "cast(null as varchar)"
  GROUPNAME: "cast(null as varchar)"
  PARENTENTITYNAME: "cast(null as varchar)"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                     source_model=metadata_dict['source_model'],
                     hashed_columns=metadata_dict['hashed_columns'],
                     derived_columns=metadata_dict['derived_columns']) }}
