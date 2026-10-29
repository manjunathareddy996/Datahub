{{ config(materialized='view') }}

-- WIDE stage() for Maximus Travel V2 view
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_ADDRESS_ADDRESS_PROPERTY_PIVOT_VW
-- Covers this view's 4 key slot(s) and its 3 1:1 satellite target(s) in one pass,
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
--   LOCATION_HKEY                      HUB_LOCATION  (8 row(s) in the map)
--   LOCATION_HKEY__PROPOSER            HUB_LOCATION / proposer  (1 row(s) in the map)
--   PARTY_HKEY__PROPOSER               HUB_PARTY / proposer  (7 row(s) in the map)
--   PARTY_LOCATION_HKEY__PROPOSER      LNK_PARTY_LOCATION / proposer  LINK
--   HASHDIFF_COMMON_ADDRESS            SAT_COMMON_ADDRESS payload 6 of 16 live here
--   HASHDIFF_COMMON_GEO                SAT_COMMON_GEO payload 3 of 3 live here
--   HASHDIFF_PARTY_CONTACT_ADDRESS_LINK SAT_PARTY_CONTACT_ADDRESS_LINK payload 0 of 1 live here

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__uwr_pol_prp_pa_address_prop_pv'
hashed_columns:
  LOCATION_HKEY: 'LOCATION_NK'
  LOCATION_HKEY__PROPOSER: 'LOCATION_NK__PROPOSER'
  PARTY_HKEY__PROPOSER: 'PARTY_NK__PROPOSER'
  PARTY_LOCATION_HKEY__PROPOSER: 'PARTY_LOCATION_NK__PROPOSER'
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
  HASHDIFF_COMMON_GEO:
    is_hashdiff: true
    columns:
      - 'ALTITUDE'
      - 'LATITUDE'
      - 'LONGITUDE'
  HASHDIFF_PARTY_CONTACT_ADDRESS_LINK:
    is_hashdiff: true
    columns:
      - 'ADDRESS_PROOF_TYPE'
      - 'ADDRESS_USAGE_TYPE'
derived_columns:
  LOCATION_BK: "nullif(trim(case when coalesce(nullif(trim(area),''), nullif(trim(land_mark),''), nullif(trim(city),''), nullif(trim(state),''), nullif(trim(pincode),'')) is not null then md5(upper(regexp_replace(trim(nullif(trim(coalesce(nullif(trim(area), ''), '') || '#' || coalesce(nullif(trim(land_mark), ''), '') || '#' || coalesce(nullif(trim(city), ''), '') || '#' || coalesce(nullif(trim(state), ''), '') || '#' || coalesce(nullif(trim(pincode), ''), '')), '####')), '[[:space:]]+', ' '))) end),'')"
  LOCATION_NK: "'HUB_LOCATION|' || (nullif(trim(case when coalesce(nullif(trim(area),''), nullif(trim(land_mark),''), nullif(trim(city),''), nullif(trim(state),''), nullif(trim(pincode),'')) is not null then md5(upper(regexp_replace(trim(nullif(trim(coalesce(nullif(trim(area), ''), '') || '#' || coalesce(nullif(trim(land_mark), ''), '') || '#' || coalesce(nullif(trim(city), ''), '') || '#' || coalesce(nullif(trim(state), ''), '') || '#' || coalesce(nullif(trim(pincode), ''), '')), '####')), '[[:space:]]+', ' '))) end),''))"
  LOCATION_BK__PROPOSER: "nullif(trim(case when coalesce(nullif(trim(area),''), nullif(trim(land_mark),''), nullif(trim(city),''), nullif(trim(state),''), nullif(trim(pincode),'')) is not null then md5(upper(regexp_replace(trim(nullif(trim(coalesce(nullif(trim(area), ''), '') || '#' || coalesce(nullif(trim(land_mark), ''), '') || '#' || coalesce(nullif(trim(city), ''), '') || '#' || coalesce(nullif(trim(state), ''), '') || '#' || coalesce(nullif(trim(pincode), ''), '')), '####')), '[[:space:]]+', ' '))) end),'')"
  LOCATION_NK__PROPOSER: "'HUB_LOCATION|' || (nullif(trim(case when coalesce(nullif(trim(area),''), nullif(trim(land_mark),''), nullif(trim(city),''), nullif(trim(state),''), nullif(trim(pincode),'')) is not null then md5(upper(regexp_replace(trim(nullif(trim(coalesce(nullif(trim(area), ''), '') || '#' || coalesce(nullif(trim(land_mark), ''), '') || '#' || coalesce(nullif(trim(city), ''), '') || '#' || coalesce(nullif(trim(state), ''), '') || '#' || coalesce(nullif(trim(pincode), ''), '')), '####')), '[[:space:]]+', ' '))) end),''))"
  PARTY_BK__PROPOSER: "nullif(trim(case when coalesce(nullif(trim(w0_party_code),'')) is not null then nullif(trim(w0_party_code), '') end),'')"
  PARTY_NK__PROPOSER: "'HUB_PARTY|' || (nullif(trim(case when coalesce(nullif(trim(w0_party_code),'')) is not null then nullif(trim(w0_party_code), '') end),''))"
  PARTY_LOCATION_BK__PROPOSER: "coalesce(nullif(trim(case when coalesce(nullif(trim(w0_party_code),'')) is not null then nullif(trim(w0_party_code), '') end),''),'') || '|' || coalesce(nullif(trim(case when coalesce(nullif(trim(area),''), nullif(trim(land_mark),''), nullif(trim(city),''), nullif(trim(state),''), nullif(trim(pincode),'')) is not null then md5(upper(regexp_replace(trim(nullif(trim(coalesce(nullif(trim(area), ''), '') || '#' || coalesce(nullif(trim(land_mark), ''), '') || '#' || coalesce(nullif(trim(city), ''), '') || '#' || coalesce(nullif(trim(state), ''), '') || '#' || coalesce(nullif(trim(pincode), ''), '')), '####')), '[[:space:]]+', ' '))) end),''),'')"
  PARTY_LOCATION_NK__PROPOSER: "'LNK_PARTY_LOCATION|' || (coalesce(nullif(trim(case when coalesce(nullif(trim(w0_party_code),'')) is not null then nullif(trim(w0_party_code), '') end),''),'') || '|' || coalesce(nullif(trim(case when coalesce(nullif(trim(area),''), nullif(trim(land_mark),''), nullif(trim(city),''), nullif(trim(state),''), nullif(trim(pincode),'')) is not null then md5(upper(regexp_replace(trim(nullif(trim(coalesce(nullif(trim(area), ''), '') || '#' || coalesce(nullif(trim(land_mark), ''), '') || '#' || coalesce(nullif(trim(city), ''), '') || '#' || coalesce(nullif(trim(state), ''), '') || '#' || coalesce(nullif(trim(pincode), ''), '')), '####')), '[[:space:]]+', ' '))) end),''),''))"
  ADDRESS_LINE_1: 'cast(null as varchar)'
  ADDRESS_LINE_2: 'cast(null as varchar)'
  ADDRESS_LINE_3: 'cast(null as varchar)'
  ADDRESS_PROOF_TYPE: 'cast(null as varchar)'
  ADDRESS_TYPE_CODE: 'cast(null as varchar)'
  ADDRESS_USAGE_TYPE: "coalesce(nullif(trim(location_type), ''),'')"
  CARE_OF_NAME: 'cast(null as varchar)'
  CITY: 'city'
  COUNTRY_CODE: 'cast(null as varchar)'
  COUNTRY_NAME: 'cast(null as varchar)'
  DISTRICT: 'cast(null as varchar)'
  LANDMARK: 'land_mark'
  LATITUDE: 'geo_coordinate_latitude'
  LOCALITY: 'area'
  LONGITUDE: 'geo_coordinate_longitude'
  POSTAL_CODE: 'pincode'
  POST_OFFICE_NAME: 'post_office'
  STATE_CODE: 'cast(null as varchar)'
  STATE_NAME: 'state'
  STREET_NAME: 'cast(null as varchar)'
  ALTITUDE: 'geo_coordinate_altitude'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_ADDRESS_ADDRESS_PROPERTY_PIVOT_VW'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
