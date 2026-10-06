{{ config(materialized='view') }}

-- PARTNER+KYC per-table stage() for SAT_PARTY_IDENTITY, table 'BJAZ_T_KYC_DETAILS'.
-- Anchor HUB_PARTY, taken from data_7's parent field -- NOT from the satellite's name.
-- Payload rendered GLUED because the anchor is a HUB (DEC-01, counted from the baseline:
-- 131 hub-anchored GLUED, 23 link-anchored UNDERSCORED, 0 counterexamples).
--
-- Null-padded TO THE SATELLITE, not to this feeder (BUILD_RULES.md 6): 14 of 17
-- payload column(s) are not carried by BJAZ_T_KYC_DETAILS and are emitted as a typed NULL so
-- the HASHDIFF column list is identical across every branch of the union.
-- Padded: AGE, DATEOFDEATH, FIRSTNAME, GENDERCODE, LASTNAME, MIDDLENAME, NAMESUFFIX, NATIONALITY, PARTYLEGALNAME, PARTYSHORTNAME, PARTYSTATUS, PARTYTYPECODE, PLACEOFBIRTH, SALUTATION.
--
-- GRAIN CONFLICT, BUILT AS MAPPED AND RAISED (BUILD_RULES.md 5.7):
-- 2 attribute(s) of this single-active satellite are written by this table AND
-- by BJAZ_T_CKYC_SEARCH, BJAZ_T_EKYC, BJAZ_T_KYC_AUTH under a BYTE-IDENTICAL HUB_PARTY key, with an EMPTY discriminator.
-- One load silently overwrites the other. The builder does not choose between
-- two writers -- that IS the mapping decision. Attributes: Date Of Birth, Party Full Name.
--
-- DEC-08 / BDEC-01: this scope's grain for SAT_PARTY_IDENTITY is BASELINE_GRAIN_SINGLE_ACTIVE.
--
-- KYC-SUBJECT PARTY KEY: FORM RATIFIED, SEMANTICS UNVERIFIED (KEY_FORM_RATIFIED_SEMANTICS_UNVERIFIED).
-- Operands on this table: CATEGORY / INPUT, selected by the ratified rule -- first COMPLETE pair
-- of (CATEGORY, INPUT), (SEARCH_CATEGORY, SEARCH_INPUT), (FIELD_TYPE, FIELD_VALUE).
-- Re-derived from the source DDL and asserted against the ratified table pair for pair;
-- a disagreement fails the build. Authority: ratified by the mapping counterparty on its caller's authority; re-derived from inputs/KYC_Tables_source_ddl.xlsx and asserted against the counterparty's table pair for pair at import time.
--
-- THE nullif(..., ':') GUARD IS PART OF THE KEY, NOT DECORATION. Without it an all-blank
-- row reduces to the bare constant ':' and every such row keys to ONE party.
--
-- UNDETERMINED, AND SETTLEABLE ONLY BY THE SOURCE OWNER: is this pair an identifier TYPE
-- and VALUE, or a record of what was SEARCHED FOR? If the latter, keying HUB_PARTY on it
-- MERGES EVERY PARTY EVER SEARCHED BY THE SAME VALUE. Built as mapped and raised (5.7).
-- BJAZ_T_KYC_INCOMING IS THE ROW TO CHANGE FIRST: it is the request root and its
-- SEARCH_CATEGORY is VARCHAR2(2) against CATEGORY's 10 or 20, so a two-character category
-- reads more like a search-type flag than an identifier type. Refusing the request root
-- would strand the 8 tables that foreign-key to INCOMING_ID, so it is built.
-- One line to switch this table off: pkyc_party_key.ENABLED['BJAZ_T_KYC_DETAILS'] = False.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_t_kyc_details'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'AGE'
      - 'DATEOFBIRTH'
      - 'DATEOFDEATH'
      - 'FIRSTNAME'
      - 'GENDERCODE'
      - 'LASTNAME'
      - 'MIDDLENAME'
      - 'NAMESUFFIX'
      - 'NATIONALITY'
      - 'PARTYDISPLAYNAME'
      - 'PARTYFULLNAME'
      - 'PARTYLEGALNAME'
      - 'PARTYSHORTNAME'
      - 'PARTYSTATUS'
      - 'PARTYTYPECODE'
      - 'PLACEOFBIRTH'
      - 'SALUTATION'
derived_columns:
  PARENT_BK: "nullif(upper(trim(coalesce(category,''))) || ':' || upper(trim(coalesce(input,''))), ':')"
  PARENT_NK: "'HUB_PARTY|' || (nullif(upper(trim(coalesce(category,''))) || ':' || upper(trim(coalesce(input,''))), ':'))"
  AGE: "cast(null as varchar)"
  DATEOFBIRTH: 'request_dob'
  DATEOFDEATH: "cast(null as varchar)"
  FIRSTNAME: "cast(null as varchar)"
  GENDERCODE: "cast(null as varchar)"
  LASTNAME: "cast(null as varchar)"
  MIDDLENAME: "cast(null as varchar)"
  NAMESUFFIX: "cast(null as varchar)"
  NATIONALITY: "cast(null as varchar)"
  PARTYDISPLAYNAME: 'policy_name'
  PARTYFULLNAME: 'request_full_name'
  PARTYLEGALNAME: "cast(null as varchar)"
  PARTYSHORTNAME: "cast(null as varchar)"
  PARTYSTATUS: "cast(null as varchar)"
  PARTYTYPECODE: "cast(null as varchar)"
  PLACEOFBIRTH: "cast(null as varchar)"
  SALUTATION: "cast(null as varchar)"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_BJAZ_T_KYC_DETAILS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
