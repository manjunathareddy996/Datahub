{{ config(materialized='view') }}

-- MAXIMUS PARTNER wide stage() for BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_ADDRESS.
-- 3 key(s), 2 single-active satellite(s).

{%- set yaml_metadata -%}
source_model: 'stg_maximus__pd_addr'
hashed_columns:
  LOCATION_HKEY: 'LOCATION_NK'
  PARTY_HKEY: 'PARTY_NK'
  PARTY_LOCATION_HKEY: 'PARTY_LOCATION_NK'
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
derived_columns:
  LOCATION_BK: "md5(concat_ws('|', upper(trim(to_varchar(address1))), upper(trim(to_varchar(address2))), upper(trim(to_varchar(address3))), upper(trim(to_varchar(city))), upper(trim(to_varchar(district))), upper(trim(to_varchar(state))), upper(trim(to_varchar(pincode))), upper(trim(to_varchar(country)))))"
  LOCATION_NK: "'HUB_LOCATION|' || (md5(concat_ws('|', upper(trim(to_varchar(address1))), upper(trim(to_varchar(address2))), upper(trim(to_varchar(address3))), upper(trim(to_varchar(city))), upper(trim(to_varchar(district))), upper(trim(to_varchar(state))), upper(trim(to_varchar(pincode))), upper(trim(to_varchar(country))))))"
  PARTY_BK: "foreign_key"
  PARTY_NK: "'HUB_PARTY|' || (foreign_key)"
  PARTY_LOCATION_BK: "(foreign_key) || '||' || (md5(concat_ws('|', upper(trim(to_varchar(address1))), upper(trim(to_varchar(address2))), upper(trim(to_varchar(address3))), upper(trim(to_varchar(city))), upper(trim(to_varchar(district))), upper(trim(to_varchar(state))), upper(trim(to_varchar(pincode))), upper(trim(to_varchar(country))))))"
  PARTY_LOCATION_NK: "'LNK_PARTY_LOCATION|' || ((foreign_key) || '||' || (md5(concat_ws('|', upper(trim(to_varchar(address1))), upper(trim(to_varchar(address2))), upper(trim(to_varchar(address3))), upper(trim(to_varchar(city))), upper(trim(to_varchar(district))), upper(trim(to_varchar(state))), upper(trim(to_varchar(pincode))), upper(trim(to_varchar(country)))))))"
  ADDRESSLINE1: "address1"
  ADDRESSLINE2: "address2"
  ADDRESSLINE3: "address3"
  CITY: "city"
  COUNTRYNAME: "country"
  DISTRICT: "district"
  POSTALCODE: "pincode"
  STATENAME: "state"
  POSTOFFICENAME: "cast(null as varchar)"
  CAREOFNAME: "cast(null as varchar)"
  LOCALITY: "cast(null as varchar)"
  LANDMARK: "cast(null as varchar)"
  ALTERNATEEMAILADDRESS: "alternate_email_id"
  EMAILADDRESS: "email_id"
  FAXNUMBER: "fax"
  LANDLINENUMBER: "coalesce(landline_no, phone_no, work_no)"
  MOBILENUMBER: "mobile_no"
  STDCODE: "std_code"
  SOCIALMEDIAHANDLE: "cast(null as varchar)"
  ALTERNATEMOBILENUMBER: "cast(null as varchar)"
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_ADDRESS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                     source_model=metadata_dict['source_model'],
                     hashed_columns=metadata_dict['hashed_columns'],
                     derived_columns=metadata_dict['derived_columns']) }}
