{{ config(materialized='view') }}

-- PARTNER+KYC per-table stage() for SAT_PARTY_ORGANISATION_PROFILE, table 'BJAZ_M_KYC_GSTN'.
-- Anchor HUB_PARTY, taken from data_7's parent field -- NOT from the satellite's name.
-- Payload rendered GLUED because the anchor is a HUB (DEC-01, counted from the baseline:
-- 131 hub-anchored GLUED, 23 link-anchored UNDERSCORED, 0 counterexamples).
--
-- Null-padded TO THE SATELLITE, not to this feeder (BUILD_RULES.md 6): 7 of 8
-- payload column(s) are not carried by BJAZ_M_KYC_GSTN and are emitted as a typed NULL so
-- the HASHDIFF column list is identical across every branch of the union.
-- Padded: ANNUALTURNOVER, DATEOFINCORPORATION, GROUPNAME, INDUSTRYDESCRIPTION, MSMEINDICATOR, PAIDUPCAPITAL, PARENTENTITYNAME.
--
-- DEC-08 / BDEC-01: this scope's grain for SAT_PARTY_ORGANISATION_PROFILE is BASELINE_GRAIN_SINGLE_ACTIVE.
--
-- PARTY KEY: part_id, resolved in stage_kyc__bjaz_m_kyc_gstn
-- (AUTH_ID -> BJAZ_T_KYC_DETAILS partner row).
-- Same key form as stg2_hub_cp_partners__party ('HUB_PARTY|' || part_id). Rows with no
-- resolved part_id hash to NULL and are dropped by sat_multi_source.

{%- set yaml_metadata -%}
source_model: 'stage_kyc__bjaz_m_kyc_gstn'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'ANNUALTURNOVER'
      - 'DATEOFINCORPORATION'
      - 'GROUPNAME'
      - 'INDUSTRYDESCRIPTION'
      - 'LEGALCONSTITUTIONTYPE'
      - 'MSMEINDICATOR'
      - 'PAIDUPCAPITAL'
      - 'PARENTENTITYNAME'
derived_columns:
  PARENT_BK: 'part_id'
  PARENT_NK: "'HUB_PARTY|' || (part_id)"
  ANNUALTURNOVER: "cast(null as varchar)"
  DATEOFINCORPORATION: "cast(null as varchar)"
  GROUPNAME: "cast(null as varchar)"
  INDUSTRYDESCRIPTION: "cast(null as varchar)"
  LEGALCONSTITUTIONTYPE: 'business_type'
  MSMEINDICATOR: "cast(null as varchar)"
  PAIDUPCAPITAL: "cast(null as varchar)"
  PARENTENTITYNAME: "cast(null as varchar)"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_PARTNER_BJAZ_M_KYC_GSTN'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
