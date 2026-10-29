{{ config(materialized='view') }}

-- MAXIMUS TRAVEL AUGMENTED stage for SAT_AUG_PARTY_CONTACT_ADDRESS_LINK from
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 3 payload column(s); the child key is ADDRESS_USAGE_TYPE.

{%- set yaml_metadata -%}
source_model: 'resolved_mt__clm_clmd_clmap_pv'
hashed_columns:
  PARTY_LOCATION_HKEY__CLAIMANT_CORRESPONDENCE_ADDRESS: 'PARTY_LOCATION_NK__CLAIMANT_CORRESPONDENCE_ADDRESS'
  HASHDIFF_PARTY_CONTACT_ADDRESS_LINK:
    is_hashdiff: true
    columns:
      - 'ADDRESS_PROOF_EFFECTIVE_DATE'
      - 'ADDRESS_USAGE_TYPE'
      - 'SAME_AS_CORRESPONDENCE_ADDRESS_INDICATOR'
      - 'SAME_AS_POLICY_ADDRESS_INDICATOR'
derived_columns:
  PARTY_LOCATION_BK__CLAIMANT_CORRESPONDENCE_ADDRESS: "coalesce(nullif(trim(case when nullif(trim(customerid),'') is not null then nullif(trim(customerid), '') end),''),'') || '|' || coalesce(nullif(trim(case when coalesce(nullif(trim(correspondence_address),''), nullif(trim(area),''), nullif(trim(city),''), nullif(trim(state),''), nullif(trim(pin_code),'')) is not null then md5(upper(regexp_replace(trim(nullif(trim(coalesce(nullif(trim(correspondence_address), ''), '') || '|' || coalesce(nullif(trim(area), ''), '') || '|' || coalesce(nullif(trim(city), ''), '') || '|' || coalesce(nullif(trim(state), ''), '') || '|' || coalesce(nullif(trim(pin_code), ''), '')), '||||')), '[[:space:]]+', ' '))) end),''),'')"
  PARTY_LOCATION_NK__CLAIMANT_CORRESPONDENCE_ADDRESS: "'LNK_PARTY_LOCATION|' || (coalesce(nullif(trim(case when nullif(trim(customerid),'') is not null then nullif(trim(customerid), '') end),''),'') || '|' || coalesce(nullif(trim(case when coalesce(nullif(trim(correspondence_address),''), nullif(trim(area),''), nullif(trim(city),''), nullif(trim(state),''), nullif(trim(pin_code),'')) is not null then md5(upper(regexp_replace(trim(nullif(trim(coalesce(nullif(trim(correspondence_address), ''), '') || '|' || coalesce(nullif(trim(area), ''), '') || '|' || coalesce(nullif(trim(city), ''), '') || '|' || coalesce(nullif(trim(state), ''), '') || '|' || coalesce(nullif(trim(pin_code), ''), '')), '||||')), '[[:space:]]+', ' '))) end),''),''))"
  ADDRESS_USAGE_TYPE: "'CORRESPONDENCE'"
  ADDRESS_PROOF_EFFECTIVE_DATE: 'cast(null as varchar)'
  SAME_AS_CORRESPONDENCE_ADDRESS_INDICATOR: 'cast(null as varchar)'
  SAME_AS_POLICY_ADDRESS_INDICATOR: 'is_the_correspondence_address_is_same_as_mentioned_on_policy'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW'
  LOAD_DATETIME: 'REC_REFRESH_AT'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
