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
-- PARTY KEY: part_id, resolved in stage_kyc__bjaz_t_kyc_ocr
-- (OCR_ID -> BJAZ_T_KYC_POI_DOCUMENT / BJAZ_T_KYC_POA_DOCUMENT -> POI_DOC_ID / POA_DOC_ID
--  -> BJAZ_T_KYC_DETAILS partner row).
-- Same key form as stg2_hub_cp_partners__party ('HUB_PARTY|' || part_id). Rows with no
-- resolved part_id hash to NULL and are dropped by sat_multi_source.

{%- set yaml_metadata -%}
source_model: 'stage_kyc__bjaz_t_kyc_ocr'
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
  PARENT_BK: 'part_id'
  PARENT_NK: "'HUB_PARTY|' || (part_id)"
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
  RECORD_SOURCE: '!OPUS_PARTNER_BJAZ_T_KYC_OCR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
