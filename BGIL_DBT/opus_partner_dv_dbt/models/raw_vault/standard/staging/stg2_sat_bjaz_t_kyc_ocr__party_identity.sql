{{ config(materialized='view') }}

-- PARTNER+KYC per-table stage() for SAT_PARTY_IDENTITY, table 'BJAZ_T_KYC_OCR'.
-- Anchor HUB_PARTY, taken from data_7's parent field -- NOT from the satellite's name.
-- Payload rendered GLUED because the anchor is a HUB (DEC-01, counted from the baseline:
-- 131 hub-anchored GLUED, 23 link-anchored UNDERSCORED, 0 counterexamples).
--
-- Null-padded TO THE SATELLITE, not to this feeder (BUILD_RULES.md 6): 12 of 17
-- payload column(s) are not carried by BJAZ_T_KYC_OCR and are emitted as a typed NULL so
-- the HASHDIFF column list is identical across every branch of the union.
-- Padded: AGE, DATEOFDEATH, FIRSTNAME, MIDDLENAME, NAMESUFFIX, PARTYDISPLAYNAME, PARTYFULLNAME, PARTYLEGALNAME, PARTYSHORTNAME, PARTYSTATUS, PARTYTYPECODE, SALUTATION.
--
-- DEC-08 / BDEC-01: this scope's grain for SAT_PARTY_IDENTITY is BASELINE_GRAIN_SINGLE_ACTIVE.
--
-- KYC-SUBJECT PARTY KEY: FORM RATIFIED, SEMANTICS UNVERIFIED (KEY_FORM_RATIFIED_SEMANTICS_UNVERIFIED).
-- Operands on this table: FIELD_TYPE / FIELD_VALUE, selected by the ratified rule -- first COMPLETE pair
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
-- One line to switch this table off: pkyc_party_key.ENABLED['BJAZ_T_KYC_OCR'] = False.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_t_kyc_ocr'
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
  PARENT_BK: "nullif(upper(trim(coalesce(field_type,''))) || ':' || upper(trim(coalesce(field_value,''))), ':')"
  PARENT_NK: "'HUB_PARTY|' || (nullif(upper(trim(coalesce(field_type,''))) || ':' || upper(trim(coalesce(field_value,''))), ':'))"
  AGE: "cast(null as varchar)"
  DATEOFBIRTH: 'dob'
  DATEOFDEATH: "cast(null as varchar)"
  FIRSTNAME: "cast(null as varchar)"
  GENDERCODE: 'gender'
  LASTNAME: 'surname'
  MIDDLENAME: "cast(null as varchar)"
  NAMESUFFIX: "cast(null as varchar)"
  NATIONALITY: 'nationality'
  PARTYDISPLAYNAME: "cast(null as varchar)"
  PARTYFULLNAME: "cast(null as varchar)"
  PARTYLEGALNAME: "cast(null as varchar)"
  PARTYSHORTNAME: "cast(null as varchar)"
  PARTYSTATUS: "cast(null as varchar)"
  PARTYTYPECODE: "cast(null as varchar)"
  PLACEOFBIRTH: 'place_of_birth'
  SALUTATION: "cast(null as varchar)"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_BJAZ_T_KYC_OCR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
