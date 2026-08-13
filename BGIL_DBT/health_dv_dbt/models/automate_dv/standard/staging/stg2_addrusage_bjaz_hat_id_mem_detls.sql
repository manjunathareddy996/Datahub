{{ config(materialized='view') }}

-- STANDARD-MODEL per-table stage() for the M4 party-address route.
-- Table 'BJAZ_HAT_ID_MEM_DETLS', usage = 'member'.
-- Round-4 fix (ADDRESS_KEY_FIX_HEALTH.md / Health_address_rekey.csv): this table also carries
-- CITY/STATE/PIN -- the same member address's remaining parts, previously nulled out ("never
-- tagged against this usage -- not assumed"). Now incorporated. Key is the content hash of
-- the FULL address (ADDLINE1 + ADDLINE2 + CITY + STATE + PIN), not ADDLINE1/2 alone.
-- Column names match lnk_party_location.sql's existing convention.

{%- set yaml_metadata -%}
source_model: 'stg_health__bjaz_hat_id_mem_detls'
hashed_columns:
  PARTY_HKEY: 'PARTY_HKEY_NK'
  LOCATION_HKEY: 'LOCATION_HKEY_NK'
  PARTY_LOCATION_HKEY: 'PARTY_LOCATION_HKEY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ADDRESS_USAGE_TYPE'
derived_columns:
  PARTY_BK: 'MEMBER_NO'
  PARTY_HKEY_NK: "'HUB_PARTY|' || MEMBER_NO"
  LOCATION_CODE_KEY: "coalesce(nullif(upper(trim(to_varchar(ADDLINE1))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(ADDLINE2))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(CITY))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(STATE))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(PIN))), ''), '')"
  LOCATION_HKEY_NK: "'HUB_LOCATION|' || (coalesce(nullif(upper(trim(to_varchar(ADDLINE1))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(ADDLINE2))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(CITY))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(STATE))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(PIN))), ''), ''))"
  PARTY_LOCATION_HKEY_NK: "'LNK_PARTY_LOCATION|' || MEMBER_NO || '|' || (coalesce(nullif(upper(trim(to_varchar(ADDLINE1))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(ADDLINE2))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(CITY))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(STATE))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(PIN))), ''), ''))"
  ADDRESS_USAGE_TYPE: '!member'
  ADDRESS_LINE_1: 'ADDLINE1'
  ADDRESS_LINE_2: 'ADDLINE2'
  CITY: 'CITY'
  STATE_CODE: 'STATE'
  POSTAL_CODE: 'to_varchar(PIN)'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!BJAZ_HAT_ID_MEM_DETLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
