{{ config(materialized='view') }}

-- PARTNER+KYC per-table stage() for SAT_POLICY_PREMIUM_SUMMARY, table 'BJAZ_T_KYC_OCR'.
-- Anchor HUB_POLICY, taken from data_7's parent field -- NOT from the satellite's name.
-- Payload rendered GLUED because the anchor is a HUB (DEC-01, counted from the baseline:
-- 131 hub-anchored GLUED, 23 link-anchored UNDERSCORED, 0 counterexamples).
--
-- GRAIN CONFLICT, BUILT AS MAPPED AND RAISED (BUILD_RULES.md 5.7):
-- 1 attribute(s) of this single-active satellite are written by this table AND
-- by BJAZ_T_KYC_INCOMING under a BYTE-IDENTICAL HUB_POLICY key, with an EMPTY discriminator.
-- One load silently overwrites the other. The builder does not choose between
-- two writers -- that IS the mapping decision. Attributes: Gross Premium.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_t_kyc_ocr'
hashed_columns:
  POLICY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'GROSSPREMIUM'
derived_columns:
  PARENT_BK: "case when upper(trim(field_type)) like 'POLICY%' then trim(field_value) end"
  PARENT_NK: "'HUB_POLICY|' || (case when upper(trim(field_type)) like 'POLICY%' then trim(field_value) end)"
  GROSSPREMIUM: 'premium_amount'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_BJAZ_T_KYC_OCR'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
