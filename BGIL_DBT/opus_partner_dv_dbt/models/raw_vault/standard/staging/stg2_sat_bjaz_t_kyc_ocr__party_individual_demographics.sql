{{ config(materialized='view') }}

-- PARTNER+KYC per-table stage() for SAT_PARTY_INDIVIDUAL_DEMOGRAPHICS, table 'BJAZ_T_KYC_OCR'.
-- Anchor HUB_PARTY, taken from data_7's parent field -- NOT from the satellite's name.
-- Payload rendered GLUED because the anchor is a HUB (DEC-01, counted from the baseline:
-- 131 hub-anchored GLUED, 23 link-anchored UNDERSCORED, 0 counterexamples).
--
-- Null-padded TO THE SATELLITE, not to this feeder (BUILD_RULES.md 6): 9 of 10
-- payload column(s) are not carried by BJAZ_T_KYC_OCR and are emitted as a typed NULL so
-- the HASHDIFF column list is identical across every branch of the union.
-- Padded: ANNUALHOUSEHOLDINCOME, ANNUALINCOME, DESIGNATION, EDUCATIONALQUALIFICATION, MARITALSTATUS, NUMBEROFCHILDREN, OCCUPATIONCODE, OCCUPATIONDESCRIPTION, SPOUSENAME.
--
-- DEC-08 / BDEC-01: this scope's grain for SAT_PARTY_INDIVIDUAL_DEMOGRAPHICS is BASELINE_GRAIN_SINGLE_ACTIVE.
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
      - 'ANNUALHOUSEHOLDINCOME'
      - 'ANNUALINCOME'
      - 'DESIGNATION'
      - 'EDUCATIONALQUALIFICATION'
      - 'FATHERNAME'
      - 'MARITALSTATUS'
      - 'NUMBEROFCHILDREN'
      - 'OCCUPATIONCODE'
      - 'OCCUPATIONDESCRIPTION'
      - 'SPOUSENAME'
derived_columns:
  PARENT_BK: 'part_id'
  PARENT_NK: "'HUB_PARTY|' || (part_id)"
  ANNUALHOUSEHOLDINCOME: "cast(null as varchar)"
  ANNUALINCOME: "cast(null as varchar)"
  DESIGNATION: "cast(null as varchar)"
  EDUCATIONALQUALIFICATION: "cast(null as varchar)"
  FATHERNAME: 'father'
  MARITALSTATUS: "cast(null as varchar)"
  NUMBEROFCHILDREN: "cast(null as varchar)"
  OCCUPATIONCODE: "cast(null as varchar)"
  OCCUPATIONDESCRIPTION: "cast(null as varchar)"
  SPOUSENAME: "cast(null as varchar)"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_PARTNER_BJAZ_T_KYC_OCR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
