{{ config(materialized='view') }}

-- PARTNER+KYC per-table stage() for SAT_PARTY_KYC, table 'BJAZ_T_CKYC_REL_PERSION_DTLS'.
-- Anchor HUB_PARTY, taken from data_7's parent field -- NOT from the satellite's name.
-- Payload rendered GLUED because the anchor is a HUB (DEC-01, counted from the baseline:
-- 131 hub-anchored GLUED, 23 link-anchored UNDERSCORED, 0 counterexamples).
--
-- Null-padded TO THE SATELLITE, not to this feeder (BUILD_RULES.md 6): 7 of 8
-- payload column(s) are not carried by BJAZ_T_CKYC_REL_PERSION_DTLS and are emitted as a typed NULL so
-- the HASHDIFF column list is identical across every branch of the union.
-- Padded: CKYCNUMBER, CKYCREGISTRATIONSTATUS, KYCMODE, KYCSTATUS, KYCTYPE, LASTKYCREVIEWDATE, OVDSUBMITTEDCOUNT.
--
-- PARTY KEY: part_id, resolved in stage_kyc__bjaz_t_ckyc_rel_persion_dtls
-- (CKYC_NO -> BJAZ_T_CKYC_SEARCH.CKYC_NUMBER -> SEARCH_ID -> BJAZ_T_KYC_DETAILS partner row).
-- Same key form as stg2_hub_cp_partners__party ('HUB_PARTY|' || part_id). Rows with no
-- resolved part_id hash to NULL and are dropped by sat_multi_source.

{%- set yaml_metadata -%}
source_model: 'stage_kyc__bjaz_t_ckyc_rel_persion_dtls'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CKYCNUMBER'
      - 'CKYCREGISTRATIONSTATUS'
      - 'KYCCOMPLETIONDATE'
      - 'KYCMODE'
      - 'KYCSTATUS'
      - 'KYCTYPE'
      - 'LASTKYCREVIEWDATE'
      - 'OVDSUBMITTEDCOUNT'
derived_columns:
  PARENT_BK: 'part_id'
  PARENT_NK: "'HUB_PARTY|' || (part_id)"
  CKYCNUMBER: "cast(null as varchar)"
  CKYCREGISTRATIONSTATUS: "cast(null as varchar)"
  KYCCOMPLETIONDATE: 'dec_date'
  KYCMODE: "cast(null as varchar)"
  KYCSTATUS: "cast(null as varchar)"
  KYCTYPE: "cast(null as varchar)"
  LASTKYCREVIEWDATE: "cast(null as varchar)"
  OVDSUBMITTEDCOUNT: "cast(null as varchar)"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_PARTNER_BJAZ_T_CKYC_REL_PERSION_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
