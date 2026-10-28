{{ config(materialized='view') }}

-- MAXIMUS TRAVEL V2 AUGMENTED stage for SAT_AUG_PARTY_IDENTIFICATION from
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS_PARTY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
--
-- BUILD-SIDE PROPOSAL, not ratified against data_7.js. One model per (view, satellite),
-- so withdrawing a proposal is deleting a model rather than editing the standard
-- track's wide stage. Nothing here feeds a standard satellite.
--
-- 15 payload column(s); the child key is IDENTIFICATION_TYPE_CODE.

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__uwr_pol_ins_mbr_pp_msp_msd_prop_pv'
hashed_columns:
  PARTY_HKEY__INSURED_MEMBER: 'PARTY_NK__INSURED_MEMBER'
  HASHDIFF_PARTY_IDENTIFICATION:
    is_hashdiff: true
    columns:
      - 'EIA_CREDIT_REQUIRED_INDICATOR'
      - 'EIA_DETAILS_NARRATIVE'
      - 'EIA_HELD_INDICATOR'
      - 'EIA_LINKED_DATE'
      - 'EIA_REQUIRED_INDICATOR'
      - 'IDENTIFICATION_DETAILS_NARRATIVE'
      - 'IDENTIFICATION_TYPE_CODE'
      - 'IDENTIFICATION_VERIFICATION_STATUS'
      - 'NAME_AS_PER_IDENTIFICATION_DOCUMENT'
      - 'OVD_CATEGORY_OTHER_DESCRIPTION'
      - 'PAN_AADHAAR_LINKED_INDICATOR'
      - 'PASSPORT_DETAIL_DESCRIPTION'
      - 'PASSPORT_FILE_NUMBER'
      - 'PASSPORT_ISSUING_COUNTRY'
      - 'PROOF_OF_ADDRESS_OTHER_DESCRIPTION'
      - 'STATE_WISE_GSTIN_REGISTRATION_DETAILS'
derived_columns:
  PARTY_BK__INSURED_MEMBER: "nullif(trim(case when coalesce(nullif(trim(w0_party_code),'')) is not null then nullif(trim(w0_party_code), '') end),'')"
  PARTY_NK__INSURED_MEMBER: "'HUB_PARTY|' || (nullif(trim(case when coalesce(nullif(trim(w0_party_code),'')) is not null then nullif(trim(w0_party_code), '') end),''))"
  IDENTIFICATION_TYPE_CODE: "'PASSPORT'"
  EIA_CREDIT_REQUIRED_INDICATOR: 'cast(null as varchar)'
  EIA_DETAILS_NARRATIVE: 'cast(null as varchar)'
  EIA_HELD_INDICATOR: 'cast(null as varchar)'
  EIA_LINKED_DATE: 'cast(null as varchar)'
  EIA_REQUIRED_INDICATOR: 'cast(null as varchar)'
  IDENTIFICATION_DETAILS_NARRATIVE: 'cast(null as varchar)'
  IDENTIFICATION_VERIFICATION_STATUS: 'cast(null as varchar)'
  NAME_AS_PER_IDENTIFICATION_DOCUMENT: 'cast(null as varchar)'
  OVD_CATEGORY_OTHER_DESCRIPTION: 'cast(null as varchar)'
  PAN_AADHAAR_LINKED_INDICATOR: 'cast(null as varchar)'
  PASSPORT_DETAIL_DESCRIPTION: 'cast(null as varchar)'
  PASSPORT_FILE_NUMBER: 'passport_file_no'
  PASSPORT_ISSUING_COUNTRY: 'passport_issue_country'
  PROOF_OF_ADDRESS_OTHER_DESCRIPTION: 'cast(null as varchar)'
  STATE_WISE_GSTIN_REGISTRATION_DETAILS: 'cast(null as varchar)'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS_PARTY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
