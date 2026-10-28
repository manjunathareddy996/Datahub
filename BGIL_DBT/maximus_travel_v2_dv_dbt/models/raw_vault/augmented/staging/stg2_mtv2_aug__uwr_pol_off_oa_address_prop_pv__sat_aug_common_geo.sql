{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_COMMON_GEO from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_OFFICE_DETAILS_OFFICE_ADDRESS_ADDRESS_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 1 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__uwr_pol_off_oa_address_prop_pv'
hashed_columns:
  LOCATION_HKEY: 'LOCATION_NK'
  HASHDIFF_COMMON_GEO:
    is_hashdiff: true
    columns:
      - 'ALTITUDE'
derived_columns:
  LOCATION_BK: "nullif(trim(case when coalesce(nullif(trim(w0_address1),''), nullif(trim(w1_address2),''), nullif(trim(w2_address3),''), nullif(trim(w3_city),''), nullif(trim(w4_state),''), nullif(trim(w5_pincode),'')) is not null then md5(upper(regexp_replace(trim(nullif(trim(coalesce(nullif(trim(w0_address1), ''), '') || '#' || coalesce(nullif(trim(w1_address2), ''), '') || '#' || coalesce(nullif(trim(w2_address3), ''), '') || '#' || coalesce(nullif(trim(w3_city), ''), '') || '#' || coalesce(nullif(trim(w4_state), ''), '') || '#' || coalesce(nullif(trim(w5_pincode), ''), '')), '#####')), '[[:space:]]+', ' '))) end),'')"
  LOCATION_NK: "'HUB_LOCATION|' || (nullif(trim(case when coalesce(nullif(trim(w0_address1),''), nullif(trim(w1_address2),''), nullif(trim(w2_address3),''), nullif(trim(w3_city),''), nullif(trim(w4_state),''), nullif(trim(w5_pincode),'')) is not null then md5(upper(regexp_replace(trim(nullif(trim(coalesce(nullif(trim(w0_address1), ''), '') || '#' || coalesce(nullif(trim(w1_address2), ''), '') || '#' || coalesce(nullif(trim(w2_address3), ''), '') || '#' || coalesce(nullif(trim(w3_city), ''), '') || '#' || coalesce(nullif(trim(w4_state), ''), '') || '#' || coalesce(nullif(trim(w5_pincode), ''), '')), '#####')), '[[:space:]]+', ' '))) end),''))"
  ALTITUDE: 'geo_coordinate_altitude'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_OFFICE_DETAILS_OFFICE_ADDRESS_ADDRESS_PROPERTY_PIVOT_VW'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
