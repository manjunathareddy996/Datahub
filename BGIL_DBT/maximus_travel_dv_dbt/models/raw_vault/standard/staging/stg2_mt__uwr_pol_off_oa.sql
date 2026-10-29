{{ config(materialized='view') }}

-- WIDE stage() for Maximus Travel view
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_OFFICE_DETAILS_OFFICE_ADDRESS
-- Covers this view's 2 key slot(s) and its 1 1:1 satellite target(s) in one pass,
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
--   LOCATION_HKEY__OFFICE_ADDRESS      HUB_LOCATION / office-address  (9 row(s) in the map)
--   ORG_UNIT_HKEY__OFFICE_ADDRESS      HUB_ORG_UNIT / office-address  (8 row(s) in the map)
--   HASHDIFF_COMMON_ADDRESS            SAT_COMMON_ADDRESS payload 9 of 16 live here

{%- set yaml_metadata -%}
source_model: 'resolved_mt__uwr_pol_off_oa'
hashed_columns:
  LOCATION_HKEY__OFFICE_ADDRESS: 'LOCATION_NK__OFFICE_ADDRESS'
  ORG_UNIT_HKEY__OFFICE_ADDRESS: 'ORG_UNIT_NK__OFFICE_ADDRESS'
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
derived_columns:
  LOCATION_BK__OFFICE_ADDRESS: "nullif(trim(case when coalesce(nullif(trim(address1),''), nullif(trim(address2),''), nullif(trim(address3),''), nullif(trim(city),''), nullif(trim(district),''), nullif(trim(state),''), nullif(trim(country),''), nullif(trim(pincode),'')) is not null then md5(upper(regexp_replace(trim(nullif(trim(coalesce(nullif(trim(address1), ''), '') || '|' || coalesce(nullif(trim(address2), ''), '') || '|' || coalesce(nullif(trim(address3), ''), '') || '|' || coalesce(nullif(trim(city), ''), '') || '|' || coalesce(nullif(trim(district), ''), '') || '|' || coalesce(nullif(trim(state), ''), '') || '|' || coalesce(nullif(trim(country), ''), '') || '|' || coalesce(nullif(trim(pincode), ''), '')), '|||||||')), '[[:space:]]+', ' '))) end),'')"
  LOCATION_NK__OFFICE_ADDRESS: "'HUB_LOCATION|' || (nullif(trim(case when coalesce(nullif(trim(address1),''), nullif(trim(address2),''), nullif(trim(address3),''), nullif(trim(city),''), nullif(trim(district),''), nullif(trim(state),''), nullif(trim(country),''), nullif(trim(pincode),'')) is not null then md5(upper(regexp_replace(trim(nullif(trim(coalesce(nullif(trim(address1), ''), '') || '|' || coalesce(nullif(trim(address2), ''), '') || '|' || coalesce(nullif(trim(address3), ''), '') || '|' || coalesce(nullif(trim(city), ''), '') || '|' || coalesce(nullif(trim(district), ''), '') || '|' || coalesce(nullif(trim(state), ''), '') || '|' || coalesce(nullif(trim(country), ''), '') || '|' || coalesce(nullif(trim(pincode), ''), '')), '|||||||')), '[[:space:]]+', ' '))) end),''))"
  ORG_UNIT_BK__OFFICE_ADDRESS: "nullif(trim(case when nullif(trim(w0_office_code),'') is not null then 'ORGUNIT:' || nullif(trim(w0_office_code), '') end),'')"
  ORG_UNIT_NK__OFFICE_ADDRESS: "'HUB_ORG_UNIT|' || (nullif(trim(case when nullif(trim(w0_office_code),'') is not null then 'ORGUNIT:' || nullif(trim(w0_office_code), '') end),''))"
  ADDRESS_LINE_1: 'address1'
  ADDRESS_LINE_2: 'address2'
  ADDRESS_LINE_3: 'address3'
  ADDRESS_TYPE_CODE: 'address_type'
  CARE_OF_NAME: 'cast(null as varchar)'
  CITY: 'city'
  COUNTRY_CODE: 'cast(null as varchar)'
  COUNTRY_NAME: 'country'
  DISTRICT: 'district'
  LANDMARK: 'cast(null as varchar)'
  LOCALITY: 'cast(null as varchar)'
  POSTAL_CODE: 'pincode'
  POST_OFFICE_NAME: 'cast(null as varchar)'
  STATE_CODE: 'cast(null as varchar)'
  STATE_NAME: 'state'
  STREET_NAME: 'cast(null as varchar)'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_OFFICE_DETAILS_OFFICE_ADDRESS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
