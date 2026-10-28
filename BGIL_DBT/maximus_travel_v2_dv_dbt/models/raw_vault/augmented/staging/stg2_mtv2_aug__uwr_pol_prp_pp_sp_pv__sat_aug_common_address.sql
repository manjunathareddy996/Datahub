{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_COMMON_ADDRESS from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 1 payload column(s); the child key is absent (single-active).

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__uwr_pol_prp_pp_sp_pv'
hashed_columns:
  LOCATION_HKEY__PERMANENT_OVERSEAS: 'LOCATION_NK__PERMANENT_OVERSEAS'
  HASHDIFF_COMMON_ADDRESS:
    is_hashdiff: true
    columns:
      - 'FULL_ADDRESS_TEXT'
derived_columns:
  LOCATION_BK__PERMANENT_OVERSEAS: "nullif(trim(case when coalesce(nullif(trim(current_permanent_overseas_address_line_1),''), nullif(trim(current_permanent_overseas_address_line_2),''), nullif(trim(current_permanent_overseas_address_line_3),''), nullif(trim(current_permanent_overseas_address_city_town_village),''), nullif(trim(current_permanent_overseas_address_state_ut),''), nullif(trim(current_permanent_overseas_address_country),''), nullif(trim(current_permanent_overseas_address_pin_code),'')) is not null then md5(upper(regexp_replace(trim(nullif(trim(coalesce(nullif(trim(current_permanent_overseas_address_line_1), ''), '') || '|' || coalesce(nullif(trim(current_permanent_overseas_address_line_2), ''), '') || '|' || coalesce(nullif(trim(current_permanent_overseas_address_line_3), ''), '') || '|' || coalesce(nullif(trim(current_permanent_overseas_address_city_town_village), ''), '') || '|' || coalesce(nullif(trim(current_permanent_overseas_address_state_ut), ''), '') || '|' || coalesce(nullif(trim(current_permanent_overseas_address_country), ''), '') || '|' || coalesce(nullif(trim(current_permanent_overseas_address_pin_code), ''), '')), '||||||')), '[[:space:]]+', ' '))) end),'')"
  LOCATION_NK__PERMANENT_OVERSEAS: "'HUB_LOCATION|' || (nullif(trim(case when coalesce(nullif(trim(current_permanent_overseas_address_line_1),''), nullif(trim(current_permanent_overseas_address_line_2),''), nullif(trim(current_permanent_overseas_address_line_3),''), nullif(trim(current_permanent_overseas_address_city_town_village),''), nullif(trim(current_permanent_overseas_address_state_ut),''), nullif(trim(current_permanent_overseas_address_country),''), nullif(trim(current_permanent_overseas_address_pin_code),'')) is not null then md5(upper(regexp_replace(trim(nullif(trim(coalesce(nullif(trim(current_permanent_overseas_address_line_1), ''), '') || '|' || coalesce(nullif(trim(current_permanent_overseas_address_line_2), ''), '') || '|' || coalesce(nullif(trim(current_permanent_overseas_address_line_3), ''), '') || '|' || coalesce(nullif(trim(current_permanent_overseas_address_city_town_village), ''), '') || '|' || coalesce(nullif(trim(current_permanent_overseas_address_state_ut), ''), '') || '|' || coalesce(nullif(trim(current_permanent_overseas_address_country), ''), '') || '|' || coalesce(nullif(trim(current_permanent_overseas_address_pin_code), ''), '')), '||||||')), '[[:space:]]+', ' '))) end),''))"
  FULL_ADDRESS_TEXT: 'current_permanent_overseas_address_'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
