{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_COMMON_GEO from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_ADDRESS_ADDRESS_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 1 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__uwr_pol_prp_pa_address_prop_pv'
hashed_columns:
  LOCATION_HKEY: 'LOCATION_NK'
  HASHDIFF_COMMON_GEO:
    is_hashdiff: true
    columns:
      - 'ALTITUDE'
derived_columns:
  LOCATION_BK: "nullif(trim(case when coalesce(nullif(trim(area),''), nullif(trim(land_mark),''), nullif(trim(city),''), nullif(trim(state),''), nullif(trim(pincode),'')) is not null then md5(upper(regexp_replace(trim(nullif(trim(coalesce(nullif(trim(area), ''), '') || '#' || coalesce(nullif(trim(land_mark), ''), '') || '#' || coalesce(nullif(trim(city), ''), '') || '#' || coalesce(nullif(trim(state), ''), '') || '#' || coalesce(nullif(trim(pincode), ''), '')), '####')), '[[:space:]]+', ' '))) end),'')"
  LOCATION_NK: "'HUB_LOCATION|' || (nullif(trim(case when coalesce(nullif(trim(area),''), nullif(trim(land_mark),''), nullif(trim(city),''), nullif(trim(state),''), nullif(trim(pincode),'')) is not null then md5(upper(regexp_replace(trim(nullif(trim(coalesce(nullif(trim(area), ''), '') || '#' || coalesce(nullif(trim(land_mark), ''), '') || '#' || coalesce(nullif(trim(city), ''), '') || '#' || coalesce(nullif(trim(state), ''), '') || '#' || coalesce(nullif(trim(pincode), ''), '')), '####')), '[[:space:]]+', ' '))) end),''))"
  ALTITUDE: 'geo_coordinate_altitude'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_ADDRESS_ADDRESS_PROPERTY_PIVOT_VW'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
