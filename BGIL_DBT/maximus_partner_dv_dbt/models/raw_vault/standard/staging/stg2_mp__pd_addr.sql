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
      - 'ADDRESS_LINE_1'
      - 'ADDRESS_LINE_2'
      - 'ADDRESS_LINE_3'
      - 'CARE_OF_NAME'
      - 'CITY'
      - 'COUNTRY_NAME'
      - 'DISTRICT'
      - 'LANDMARK'
      - 'LOCALITY'
      - 'POSTAL_CODE'
      - 'POST_OFFICE_NAME'
      - 'STATE_NAME'
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
derived_columns:
  LOCATION_BK: "case when coalesce(upper(trim(to_varchar(address1))), upper(trim(to_varchar(address2))), upper(trim(to_varchar(address3))), upper(trim(to_varchar(city))), upper(trim(to_varchar(district))), upper(trim(to_varchar(state))), upper(trim(to_varchar(pincode))), upper(trim(to_varchar(country)))) is null then null else md5(concat_ws('|', coalesce(upper(trim(to_varchar(address1))), ''), coalesce(upper(trim(to_varchar(address2))), ''), coalesce(upper(trim(to_varchar(address3))), ''), coalesce(upper(trim(to_varchar(city))), ''), coalesce(upper(trim(to_varchar(district))), ''), coalesce(upper(trim(to_varchar(state))), ''), coalesce(upper(trim(to_varchar(pincode))), ''), coalesce(upper(trim(to_varchar(country))), ''))) end"
  LOCATION_NK: "'HUB_LOCATION|' || (case when coalesce(upper(trim(to_varchar(address1))), upper(trim(to_varchar(address2))), upper(trim(to_varchar(address3))), upper(trim(to_varchar(city))), upper(trim(to_varchar(district))), upper(trim(to_varchar(state))), upper(trim(to_varchar(pincode))), upper(trim(to_varchar(country)))) is null then null else md5(concat_ws('|', coalesce(upper(trim(to_varchar(address1))), ''), coalesce(upper(trim(to_varchar(address2))), ''), coalesce(upper(trim(to_varchar(address3))), ''), coalesce(upper(trim(to_varchar(city))), ''), coalesce(upper(trim(to_varchar(district))), ''), coalesce(upper(trim(to_varchar(state))), ''), coalesce(upper(trim(to_varchar(pincode))), ''), coalesce(upper(trim(to_varchar(country))), ''))) end)"
  PARTY_BK: "foreign_key"
  PARTY_NK: "'HUB_PARTY|' || (foreign_key)"
  PARTY_LOCATION_BK: "(foreign_key) || '||' || (case when coalesce(upper(trim(to_varchar(address1))), upper(trim(to_varchar(address2))), upper(trim(to_varchar(address3))), upper(trim(to_varchar(city))), upper(trim(to_varchar(district))), upper(trim(to_varchar(state))), upper(trim(to_varchar(pincode))), upper(trim(to_varchar(country)))) is null then null else md5(concat_ws('|', coalesce(upper(trim(to_varchar(address1))), ''), coalesce(upper(trim(to_varchar(address2))), ''), coalesce(upper(trim(to_varchar(address3))), ''), coalesce(upper(trim(to_varchar(city))), ''), coalesce(upper(trim(to_varchar(district))), ''), coalesce(upper(trim(to_varchar(state))), ''), coalesce(upper(trim(to_varchar(pincode))), ''), coalesce(upper(trim(to_varchar(country))), ''))) end)"
  PARTY_LOCATION_NK: "'LNK_PARTY_LOCATION|' || ((foreign_key) || '||' || (case when coalesce(upper(trim(to_varchar(address1))), upper(trim(to_varchar(address2))), upper(trim(to_varchar(address3))), upper(trim(to_varchar(city))), upper(trim(to_varchar(district))), upper(trim(to_varchar(state))), upper(trim(to_varchar(pincode))), upper(trim(to_varchar(country)))) is null then null else md5(concat_ws('|', coalesce(upper(trim(to_varchar(address1))), ''), coalesce(upper(trim(to_varchar(address2))), ''), coalesce(upper(trim(to_varchar(address3))), ''), coalesce(upper(trim(to_varchar(city))), ''), coalesce(upper(trim(to_varchar(district))), ''), coalesce(upper(trim(to_varchar(state))), ''), coalesce(upper(trim(to_varchar(pincode))), ''), coalesce(upper(trim(to_varchar(country))), ''))) end))"
  ADDRESS_LINE_1: "address1"
  ADDRESS_LINE_2: "address2"
  ADDRESS_LINE_3: "address3"
  CITY: "city"
  COUNTRY_NAME: "country"
  DISTRICT: "district"
  POSTAL_CODE: "pincode"
  STATE_NAME: "state"
  POST_OFFICE_NAME: "cast(null as varchar)"
  CARE_OF_NAME: "cast(null as varchar)"
  LOCALITY: "cast(null as varchar)"
  LANDMARK: "cast(null as varchar)"
  ALTERNATE_EMAIL_ADDRESS: "alternate_email_id"
  EMAIL_ADDRESS: "email_id"
  FAX_NUMBER: "fax"
  LANDLINE_NUMBER: "coalesce(landline_no, phone_no, work_no)"
  MOBILE_NUMBER: "mobile_no"
  STD_CODE: "std_code"
  SOCIALMEDIAHANDLE: "cast(null as varchar)"
  ALTERNATE_MOBILE_NUMBER: "cast(null as varchar)"
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_PARTNER_BUSINESS_PARTNERS_VW_DATA_PARTY_DETAIL_PARTY_ADDRESS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                     source_model=metadata_dict['source_model'],
                     hashed_columns=metadata_dict['hashed_columns'],
                     derived_columns=metadata_dict['derived_columns']) }}
