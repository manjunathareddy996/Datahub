{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for the M4 party-address route (data_5a.js):
-- LNK_PARTY_LOCATION + SAT_PARTY_CONTACT_ADDRESS_LINK (parent LNK_PARTY_LOCATION) +
-- SAT_COMMON_ADDRESS. Replaces the removed SAT_PARTY_ADDRESS_USAGE.
-- Table 'BA_HCP_PP_MEM_DTLS', usage = 'diagnostic-centre'.
-- Round-4 fix (ADDRESS_KEY_FIX_HEALTH.md / Health_address_rekey.csv): this table also carries
-- DC_LOCATION/DC_CITY/DC_STATE/DC_PINCODE -- the same diagnostic-centre address's remaining
-- parts, previously nulled out ("never tagged against this usage -- not assumed"). Now
-- incorporated. Key is the content hash of the FULL address (DC_ADDRESS + DC_LOCATION +
-- DC_CITY + DC_STATE + DC_PINCODE), not DC_ADDRESS alone -- SAT_COMMON_ADDRESS is
-- single-active, so a thinner key would risk collapsing distinct diagnostic-centre addresses.
-- Column names (PARTY_HKEY/LOCATION_HKEY/PARTY_LOCATION_HKEY) match the convention
-- lnk_party_location.sql's other 8 source entries already use -- link() needs the same
-- column names across every source_model entry. LOCATION_CODE_KEY/ADDRESS_LINE_1 etc. are
-- also exposed raw (unhashed) so stitch_common_address.sql can union this table in as a
-- plain, union-only branch (not attribute-joined, so a per-table stage is fine here).

{%- set yaml_metadata -%}
source_model: 'stg_health__ba_hcp_pp_mem_dtls'
hashed_columns:
  PARTY_HKEY: 'PARTY_HKEY_NK'
  LOCATION_HKEY: 'LOCATION_HKEY_NK'
  PARTY_LOCATION_HKEY: 'PARTY_LOCATION_HKEY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ADDRESS_USAGE_TYPE'
derived_columns:
  PARTY_BK: 'ALLOTED_TO'
  PARTY_HKEY_NK: "'HUB_PARTY|' || ALLOTED_TO"
  LOCATION_CODE_KEY: "coalesce(nullif(upper(trim(to_varchar(DC_ADDRESS))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(DC_LOCATION))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(DC_CITY))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(DC_STATE))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(DC_PINCODE))), ''), '')"
  LOCATION_HKEY_NK: "'HUB_LOCATION|' || (coalesce(nullif(upper(trim(to_varchar(DC_ADDRESS))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(DC_LOCATION))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(DC_CITY))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(DC_STATE))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(DC_PINCODE))), ''), ''))"
  PARTY_LOCATION_HKEY_NK: "'LNK_PARTY_LOCATION|' || ALLOTED_TO || '|' || (coalesce(nullif(upper(trim(to_varchar(DC_ADDRESS))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(DC_LOCATION))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(DC_CITY))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(DC_STATE))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(DC_PINCODE))), ''), ''))"
  ADDRESS_USAGE_TYPE: '!diagnostic-centre'
  ADDRESS_LINE_1: 'DC_ADDRESS'
  CITY: 'DC_CITY'
  STATE_CODE: 'DC_STATE'
  POSTAL_CODE: 'to_varchar(DC_PINCODE)'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BA_HCP_PP_MEM_DTLS'
null_columns:
  - 'ADDRESS_LINE_2'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns'],
                      null_columns=metadata_dict['null_columns']) }}
