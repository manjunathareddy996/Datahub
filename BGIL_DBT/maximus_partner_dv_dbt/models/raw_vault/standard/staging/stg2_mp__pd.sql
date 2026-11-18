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
      - 'HIERARCHY_LEVEL'
      - 'REPORTING_PARENT_REFERENCE'
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
derived_columns:
  PARTY_BK: "party_code"
  PARTY_NK: "'HUB_PARTY|' || (party_code)"
  REPORTING_PARENT_REFERENCE: "parent_party_code"
  HIERARCHY_LEVEL: "cast(null as varchar)"
  PARTY_LEGAL_NAME: "business_name"
  DATE_OF_BIRTH: "date_of_birth"
  FIRST_NAME: "first_name"
  GENDER_CODE: "gender"
  LAST_NAME: "last_name"
  MIDDLE_NAME: "middle_name"
  NATIONALITY: "nationality"
  PARTY_ORIGINATION_DATE: "party_start_date"
  PARTY_STATUS: "party_status"
  SALUTATION: "title"
  PARTY_TYPE_CODE: "type_of_party"
  COUNTRY_OF_BIRTH: "cast(null as varchar)"
  COUNTRY_OF_RESIDENCE: "cast(null as varchar)"
  DATE_OF_DEATH: "cast(null as varchar)"
  AGE: "cast(null as varchar)"
  PARTY_SUB_TYPE_CODE: "cast(null as varchar)"
  PARTY_FULL_NAME: "cast(null as varchar)"
  OCCUPATIONCODE: "occupation"
  VEHICLE_OWNED_INDICATOR: "cast(null as varchar)"
  SPOUSE_NAME: "cast(null as varchar)"
  OCCUPATION_DESCRIPTION: "cast(null as varchar)"
  FATHER_NAME: "cast(null as varchar)"
  EDUCATIONAL_QUALIFICATION: "cast(null as varchar)"
  ANNUAL_INCOME: "cast(null as varchar)"
  YEARS_IN_CITY: "cast(null as varchar)"
  DESIGNATION: "cast(null as varchar)"
  MARITAL_STATUS: "cast(null as varchar)"
  HIGHEST_DEGREE: "cast(null as varchar)"
  DATE_OF_INCORPORATION: "registration_date"
  BUSINESS_REGISTRATION_NUMBER: "registration_no"
  LEGAL_CONSTITUTION_TYPE: "type_of_organization"
  INDUSTRY_DESCRIPTION: "cast(null as varchar)"
  NATURE_OF_BUSINESS: "cast(null as varchar)"
  NUMBEROFEMPLOYEES: "cast(null as varchar)"
  PAID_UP_CAPITAL: "cast(null as varchar)"
  ANNUAL_TURNOVER: "cast(null as varchar)"
  MSME_INDICATOR: "cast(null as varchar)"
  MSME_CATEGORY: "cast(null as varchar)"
  INDUSTRY_CODE: "cast(null as varchar)"
  GROUP_NAME: "cast(null as varchar)"
  PARENT_ENTITY_NAME: "cast(null as varchar)"
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                     source_model=metadata_dict['source_model'],
                     hashed_columns=metadata_dict['hashed_columns'],
                     derived_columns=metadata_dict['derived_columns']) }}
