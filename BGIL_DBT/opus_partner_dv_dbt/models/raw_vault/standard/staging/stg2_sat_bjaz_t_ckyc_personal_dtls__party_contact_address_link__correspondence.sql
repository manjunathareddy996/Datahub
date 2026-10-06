{{ config(materialized='view') }}

-- PARTNER+KYC per-table stage() for SAT_PARTY_CONTACT_ADDRESS_LINK, table 'BJAZ_T_CKYC_PERSONAL_DTLS'.
-- Anchor LNK_PARTY_LOCATION, taken from data_7's parent field -- NOT from the satellite's name.
-- Payload rendered UNDERSCORED because the anchor is a LINK (DEC-01, counted from the baseline:
-- 131 hub-anchored GLUED, 23 link-anchored UNDERSCORED, 0 counterexamples).
--
-- Null-padded TO THE SATELLITE, not to this feeder (BUILD_RULES.md 6): 1 of 1
-- payload column(s) are not carried by BJAZ_T_CKYC_PERSONAL_DTLS and are emitted as a typed NULL so
-- the HASHDIFF column list is identical across every branch of the union.
-- Padded: PRIMARY_ADDRESS_INDICATOR.
--
-- DEC-08 / BDEC-01: this scope's grain for SAT_PARTY_CONTACT_ADDRESS_LINK is BASELINE_GRAIN_MULTI_ACTIVE.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_t_ckyc_personal_dtls'
hashed_columns:
  PARTY_LOCATION_HKEY: 'PARTY_LOCATION_HKEY_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'PRIMARY_ADDRESS_INDICATOR'
derived_columns:
  PARTY_LOCATION_HKEY_NK: "'LNK_PARTY_LOCATION|' || (nullif('CKYC:' || upper(trim(coalesce(ckyc_no,''))), 'CKYC:') || '|' || coalesce(nullif(upper(trim(to_varchar(corres_line1))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(corres_line2))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(corres_line3))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(corres_city))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(corres_dist))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(corres_state))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(corres_pin))), ''), '') || '|' || coalesce(nullif(upper(trim(to_varchar(corres_country))), ''), ''))"
  ADDRESS_USAGE_TYPE: "'CORRESPONDENCE'"
  PRIMARY_ADDRESS_INDICATOR: "cast(null as varchar)"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_BJAZ_T_CKYC_PERSONAL_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
