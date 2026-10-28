{{ config(materialized='view') }}

-- UNPIVOT STAGE for SAT_PARTY_KYC_REFERENCE from uwr_pol_ins_mbr_pp_sp_pv.
-- Hashes once over the fanned-out rows. include_source_columns is FALSE and every
-- column is listed explicitly: a stage that passes its source's columns through makes
-- the satellite's real feeder columns invisible to anything reading the YAML, which is
-- how a set of child keys went missing on an earlier build (BUILD_RULES 6.2).

{%- set yaml_metadata -%}
source_model: 'up_mtv2__uwr_pol_ins_mbr_pp_sp_pv__sat_party_kyc_reference'
hashed_columns:
  PARTY_HKEY__INSURED_MEMBER: 'PARTY_NK__INSURED_MEMBER'
  HASHDIFF_PARTY_KYC_REFERENCE:
    is_hashdiff: true
    columns:
      - 'KYC_REFERENCE_TYPE'
      - 'VERIFICATION_STATUS'
derived_columns:
  PARTY_NK__INSURED_MEMBER: "'HUB_PARTY|' || (PARTY_BK__INSURED_MEMBER)"
  PARTY_BK__INSURED_MEMBER: 'PARTY_BK__INSURED_MEMBER'
  KYC_REFERENCE_TYPE: 'KYC_REFERENCE_TYPE'
  VERIFICATION_STATUS: 'VERIFICATION_STATUS'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: 'record_source'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
