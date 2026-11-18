{{ config(materialized='view') }}

-- PARTNER+KYC per-table stage() for SAT_PARTY_IDENTITY, table 'BJAZ_T_EKYC'.
-- Anchor HUB_PARTY, taken from data_7's parent field -- NOT from the satellite's name.
-- Payload rendered GLUED because the anchor is a HUB (DEC-01, counted from the baseline:
-- 131 hub-anchored GLUED, 23 link-anchored UNDERSCORED, 0 counterexamples).
--
-- Null-padded TO THE SATELLITE, not to this feeder (BUILD_RULES.md 6): 14 of 17
-- payload column(s) are not carried by BJAZ_T_EKYC and are emitted as a typed NULL so
-- the HASHDIFF column list is identical across every branch of the union.
-- Padded: AGE, DATEOFDEATH, FIRSTNAME, LASTNAME, MIDDLENAME, NAMESUFFIX, NATIONALITY, PARTYDISPLAYNAME, PARTYLEGALNAME, PARTYSHORTNAME, PARTYSTATUS, PARTYTYPECODE, PLACEOFBIRTH, SALUTATION.
--
-- GRAIN CONFLICT, BUILT AS MAPPED AND RAISED (BUILD_RULES.md 5.7):
-- 3 attribute(s) of this single-active satellite are written by this table AND
-- by BJAZ_T_CKYC_SEARCH, BJAZ_T_KYC_AUTH, BJAZ_T_KYC_DETAILS under a BYTE-IDENTICAL HUB_PARTY key, with an EMPTY discriminator.
-- One load silently overwrites the other. The builder does not choose between
-- two writers -- that IS the mapping decision. Attributes: Date Of Birth, Gender Code, Party Full Name.
--
-- DEC-08 / BDEC-01: this scope's grain for SAT_PARTY_IDENTITY is BASELINE_GRAIN_SINGLE_ACTIVE.
--
-- PARTY KEY: part_id, resolved in stage_kyc__bjaz_t_ekyc
-- (EKYC_ID -> BJAZ_T_KYC_DETAILS partner row).
-- Same key form as stg2_hub_cp_partners__party ('HUB_PARTY|' || part_id). Rows with no
-- resolved part_id hash to NULL and are dropped by sat_multi_source.

{%- set yaml_metadata -%}
source_model: 'stage_kyc__bjaz_t_ekyc'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'AGE'
      - 'DATE_OF_BIRTH'
      - 'DATE_OF_DEATH'
      - 'FIRST_NAME'
      - 'GENDER_CODE'
      - 'LAST_NAME'
      - 'MIDDLE_NAME'
      - 'NAME_SUFFIX'
      - 'NATIONALITY'
      - 'PARTY_DISPLAY_NAME'
      - 'PARTY_FULL_NAME'
      - 'PARTY_LEGAL_NAME'
      - 'PARTYSHORTNAME'
      - 'PARTY_STATUS'
      - 'PARTY_TYPE_CODE'
      - 'PLACEOFBIRTH'
      - 'SALUTATION'
derived_columns:
  PARENT_BK: 'part_id'
  PARENT_NK: "'HUB_PARTY|' || (part_id)"
  AGE: "cast(null as varchar)"
  DATE_OF_BIRTH: 'dob'
  DATE_OF_DEATH: "cast(null as varchar)"
  FIRST_NAME: "cast(null as varchar)"
  GENDER_CODE: 'gender'
  LAST_NAME: "cast(null as varchar)"
  MIDDLE_NAME: "cast(null as varchar)"
  NAME_SUFFIX: "cast(null as varchar)"
  NATIONALITY: "cast(null as varchar)"
  PARTY_DISPLAY_NAME: "cast(null as varchar)"
  PARTY_FULL_NAME: 'full_name'
  PARTY_LEGAL_NAME: "cast(null as varchar)"
  PARTYSHORTNAME: "cast(null as varchar)"
  PARTY_STATUS: "cast(null as varchar)"
  PARTY_TYPE_CODE: "cast(null as varchar)"
  PLACEOFBIRTH: "cast(null as varchar)"
  SALUTATION: "cast(null as varchar)"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_PARTNER_BJAZ_T_EKYC'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
