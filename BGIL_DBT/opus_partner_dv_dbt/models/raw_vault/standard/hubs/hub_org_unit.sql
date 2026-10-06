{{ config(materialized='incremental') }}

-- PARTNER+KYC STANDARD-MODEL hub() for HUB_ORG_UNIT over 10 source_model entry(ies).
-- src_nk is PARENT_BK and the business key is namespaced with a PIPE -- the sibling's
-- conventions, counted from the artifact (PARENT_BK x10, pipe x344, colon x0).
--
-- 2 KEY SPELLINGS SHIP ON THIS HUB, BUILT AS MAPPED AND RAISED (5.7).
-- Class: CASE_FOLDING_VARIANT_OF_ONE_KEY.
--   6 table(s): BJAZ_T_CKYC_SEARCH, BJAZ_T_EKYC, BJAZ_T_KYC_AUTH, BJAZ_T_KYC_DETAILS, BJAZ_T_KYC_POA_DOCUMENT, BJAZ_T_KYC_POI_DOCUMENT
--     upper(trim(business_unit))
--   4 table(s): BJAZ_T_CKYC_OTP, BJAZ_T_KYC_INCOMING, BJAZ_T_KYC_NAME_MATCH, BJAZ_T_KYC_OCR
--     trim(business_unit)
-- Same column set, differing only in normalisation. Any source value whose case differs
-- between these table groups yields TWO HUB_ORG_UNIT rows for one entity,
-- deterministically. This is profile flag 8 / OI-08, LIVE -- and it is in BUILDABLE
-- scope, so it ships. Built as mapped (5.7); one spelling per hub is a mapper ruling,
-- not a builder's licence to normalise.
-- The majority form is the first listed. Routed to mapper-liaison.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_hub_bjaz_t_ckyc_otp__org_unit'
  - 'stg2_hub_bjaz_t_ckyc_search__org_unit'
  - 'stg2_hub_bjaz_t_ekyc__org_unit'
  - 'stg2_hub_bjaz_t_kyc_auth__org_unit'
  - 'stg2_hub_bjaz_t_kyc_details__org_unit'
  - 'stg2_hub_bjaz_t_kyc_incoming__org_unit'
  - 'stg2_hub_bjaz_t_kyc_name_match__org_unit'
  - 'stg2_hub_bjaz_t_kyc_ocr__org_unit'
  - 'stg2_hub_bjaz_t_kyc_poa_document__org_unit'
  - 'stg2_hub_bjaz_t_kyc_poi_document__org_unit'
src_pk: 'ORG_UNIT_HKEY'
src_nk: 'PARENT_BK'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.hub(src_pk=metadata_dict['src_pk'],
                   src_nk=metadata_dict['src_nk'],
                   src_ldts=metadata_dict['src_ldts'],
                   src_source=metadata_dict['src_source'],
                   source_model=metadata_dict['source_model']) }}
