{{ config(materialized='view') }}

-- MAXIMUS TRAVEL AUGMENTED stage for SAT_AUG_PARTY_CONTACT_ADDRESS_LINK from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 3 payload column(s); the child key is ADDRESS_USAGE_TYPE.

{%- set yaml_metadata -%}
source_model: 'resolved_mt__uwr_pol_ins_mbr_pp_sp_pv'
hashed_columns:
  PARTY_LOCATION_HKEY__INSURED_MEMBER_CORRESPONDENCE_LOCAL: 'PARTY_LOCATION_NK__INSURED_MEMBER_CORRESPONDENCE_LOCAL'
  HASHDIFF_PARTY_CONTACT_ADDRESS_LINK:
    is_hashdiff: true
    columns:
      - 'ADDRESS_PROOF_EFFECTIVE_DATE'
      - 'ADDRESS_USAGE_TYPE'
      - 'SAME_AS_CORRESPONDENCE_ADDRESS_INDICATOR'
      - 'SAME_AS_POLICY_ADDRESS_INDICATOR'
derived_columns:
  PARTY_LOCATION_BK__INSURED_MEMBER_CORRESPONDENCE_LOCAL: "coalesce(nullif(trim(case when coalesce(nullif(trim(w0_party_code),'')) is not null then nullif(trim(w0_party_code), '') end),''),'') || '|' || coalesce(nullif(trim(case when coalesce(nullif(trim(correspondence_local_address_line_1),''), nullif(trim(correspondence_local_address_line_2),''), nullif(trim(correspondence_local_address_line_3),''), nullif(trim(correspondence_local_address_city_town_village),''), nullif(trim(correspondence_local_address_district),''), nullif(trim(correspondence_local_address_state),''), nullif(trim(correspondence_local_address_country),''), nullif(trim(local_address_pin_code),'')) is not null then md5(upper(regexp_replace(trim(nullif(trim(coalesce(nullif(trim(correspondence_local_address_line_1), ''), '') || '|' || coalesce(nullif(trim(correspondence_local_address_line_2), ''), '') || '|' || coalesce(nullif(trim(correspondence_local_address_line_3), ''), '') || '|' || coalesce(nullif(trim(correspondence_local_address_city_town_village), ''), '') || '|' || coalesce(nullif(trim(correspondence_local_address_district), ''), '') || '|' || coalesce(nullif(trim(correspondence_local_address_state), ''), '') || '|' || coalesce(nullif(trim(correspondence_local_address_country), ''), '') || '|' || coalesce(nullif(trim(local_address_pin_code), ''), '')), '|||||||')), '[[:space:]]+', ' '))) end),''),'')"
  PARTY_LOCATION_NK__INSURED_MEMBER_CORRESPONDENCE_LOCAL: "'LNK_PARTY_LOCATION|' || (coalesce(nullif(trim(case when coalesce(nullif(trim(w0_party_code),'')) is not null then nullif(trim(w0_party_code), '') end),''),'') || '|' || coalesce(nullif(trim(case when coalesce(nullif(trim(correspondence_local_address_line_1),''), nullif(trim(correspondence_local_address_line_2),''), nullif(trim(correspondence_local_address_line_3),''), nullif(trim(correspondence_local_address_city_town_village),''), nullif(trim(correspondence_local_address_district),''), nullif(trim(correspondence_local_address_state),''), nullif(trim(correspondence_local_address_country),''), nullif(trim(local_address_pin_code),'')) is not null then md5(upper(regexp_replace(trim(nullif(trim(coalesce(nullif(trim(correspondence_local_address_line_1), ''), '') || '|' || coalesce(nullif(trim(correspondence_local_address_line_2), ''), '') || '|' || coalesce(nullif(trim(correspondence_local_address_line_3), ''), '') || '|' || coalesce(nullif(trim(correspondence_local_address_city_town_village), ''), '') || '|' || coalesce(nullif(trim(correspondence_local_address_district), ''), '') || '|' || coalesce(nullif(trim(correspondence_local_address_state), ''), '') || '|' || coalesce(nullif(trim(correspondence_local_address_country), ''), '') || '|' || coalesce(nullif(trim(local_address_pin_code), ''), '')), '|||||||')), '[[:space:]]+', ' '))) end),''),''))"
  ADDRESS_USAGE_TYPE: "coalesce(nullif(trim(current_permanent_overseas_address_type), ''),'')"
  ADDRESS_PROOF_EFFECTIVE_DATE: 'address_proof_effective_date'
  SAME_AS_CORRESPONDENCE_ADDRESS_INDICATOR: 'flag_indicating_if_current_permanent_overseas_address_is_same_as_correspondence_local_address'
  SAME_AS_POLICY_ADDRESS_INDICATOR: 'cast(null as varchar)'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
