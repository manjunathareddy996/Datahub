{{ config(materialized='view') }}

-- PARTNER+KYC per-table stage() for SAT_PARTY_IDENTIFICATION, table 'BJAZ_M_KYC_VOTER'.
-- Anchor HUB_PARTY, taken from data_7's parent field -- NOT from the satellite's name.
-- Payload rendered GLUED because the anchor is a HUB (DEC-01, counted from the baseline:
-- 131 hub-anchored GLUED, 23 link-anchored UNDERSCORED, 0 counterexamples).
--
-- Null-padded TO THE SATELLITE, not to this feeder (BUILD_RULES.md 6): 11 of 11
-- payload column(s) are not carried by BJAZ_M_KYC_VOTER and are emitted as a typed NULL so
-- the HASHDIFF column list is identical across every branch of the union.
-- Padded: AADHAARNUMBER, AGEPROOFTYPE, EIANUMBER, GSTIN, GSTREGISTRATIONSTATUS, GSTTAXPAYERTYPE, IDENTIFICATIONNUMBER, PANNUMBER, PASSPORTNUMBER, TANNUMBER, VATREGISTRATIONNUMBER.
--
-- DEC-08 / BDEC-01: this scope's grain for SAT_PARTY_IDENTIFICATION is BASELINE_GRAIN_SINGLE_ACTIVE_UNDER_KEYED.
-- data_7 declares this satellite MULTI-ACTIVE on childkey 'Identification Type Code', and this scope
-- builds it SINGLE-ACTIVE to match the baseline rows a builder has already
-- loaded. COST, STATED: two KYC reference types for one party overwrite each
-- other here. The leg stays a PAYLOAD column, which is what those loaded rows
-- were hashed with; promoting it to src_cdk would re-chain the hashdiff.
-- One line to change: KR.SWITCHES['SAT_PARTY_KYC_REFERENCE_GRAIN']['merged'].
--
-- PARTY KEY: part_id, resolved in stage_kyc__bjaz_m_kyc_voter
-- (AUTH_ID -> BJAZ_T_KYC_DETAILS partner row).
-- Same key form as stg2_hub_cp_partners__party ('HUB_PARTY|' || part_id). Rows with no
-- resolved part_id hash to NULL and are dropped by sat_multi_source.

{%- set yaml_metadata -%}
source_model: 'stage_kyc__bjaz_m_kyc_voter'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'AADHAARNUMBER'
      - 'AGEPROOFTYPE'
      - 'EIANUMBER'
      - 'GSTIN'
      - 'GSTREGISTRATIONSTATUS'
      - 'GSTTAXPAYERTYPE'
      - 'IDENTIFICATIONNUMBER'
      - 'PANNUMBER'
      - 'PASSPORTNUMBER'
      - 'TANNUMBER'
      - 'VATREGISTRATIONNUMBER'
      - 'VOTERIDNUMBER'
derived_columns:
  PARENT_BK: 'part_id'
  PARENT_NK: "'HUB_PARTY|' || (part_id)"
  AADHAARNUMBER: "cast(null as varchar)"
  AGEPROOFTYPE: "cast(null as varchar)"
  EIANUMBER: "cast(null as varchar)"
  GSTIN: "cast(null as varchar)"
  GSTREGISTRATIONSTATUS: "cast(null as varchar)"
  GSTTAXPAYERTYPE: "cast(null as varchar)"
  IDENTIFICATIONNUMBER: "cast(null as varchar)"
  PANNUMBER: "cast(null as varchar)"
  PASSPORTNUMBER: "cast(null as varchar)"
  TANNUMBER: "cast(null as varchar)"
  VATREGISTRATIONNUMBER: "cast(null as varchar)"
  VOTERIDNUMBER: 'voter_number'
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_PARTNER_BJAZ_M_KYC_VOTER'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
