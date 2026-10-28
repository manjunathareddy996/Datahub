{{ config(materialized='view') }}

-- WIDE stage() for Maximus Travel V2 view
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW
-- Covers this view's 1 key slot(s) and its 2 1:1 satellite target(s) in one pass,
-- with a separately-named hashdiff per satellite so each is scoped to its own payload.
-- The bare HASHDIFF the sibling contract requires is produced by the satfeed layer,
-- which is the only place one name can serve one satellite (BD7).
--
-- Fan-in families on this view, if any, are handled by the unpivot layer instead: one
-- row per instance cannot be expressed as columns of one row here.
--
-- Every BK is the guarded rendering. When every non-literal operand is blank the key is
-- NULL, the hub feed drops it, and audit_mtv2_key_rejections counts the drop per hub per
-- feeder -- so a zero is a measured zero (directive D-REJECT).
--
--   PARTY_HKEY__PROPOSER               HUB_PARTY / proposer  (21 row(s) in the map)
--   HASHDIFF_PARTY_BANKING             SAT_PARTY_BANKING payload 7 of 7 live here
--   HASHDIFF_PARTY_IDENTIFICATION      SAT_PARTY_IDENTIFICATION payload 3 of 25 live here

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__uwr_pol_prp_pp_msp_msd_prop_pv'
hashed_columns:
  PARTY_HKEY__PROPOSER: 'PARTY_NK__PROPOSER'
  HASHDIFF_PARTY_BANKING:
    is_hashdiff: true
    columns:
      - 'ACCOUNT_HOLDER_NAME'
      - 'ACCOUNT_NUMBER_MASKED'
      - 'ACCOUNT_TYPE'
      - 'BANK_NAME'
      - 'BRANCH_NAME'
      - 'IFSC_CODE'
      - 'MICR_CODE'
      - 'PRIMARY_ACCOUNT_INDICATOR'
  HASHDIFF_PARTY_IDENTIFICATION:
    is_hashdiff: true
    columns:
      - 'AADHAAR_NUMBER'
      - 'AADHAAR_VERIFICATION_STATUS'
      - 'AGE_PROOF_TYPE'
      - 'CIN_NUMBER'
      - 'CKYC_NUMBER'
      - 'DRIVING_LICENCE_EXPIRY_DATE'
      - 'DRIVING_LICENCE_NUMBER'
      - 'EIA_NUMBER'
      - 'GSTIN'
      - 'GST_REGISTRATION_STATUS'
      - 'GST_TAXPAYER_TYPE'
      - 'IDENTIFICATION_EXPIRY_DATE'
      - 'IDENTIFICATION_ISSUE_DATE'
      - 'IDENTIFICATION_ISSUING_AUTHORITY'
      - 'IDENTIFICATION_NUMBER'
      - 'IDENTIFICATION_TYPE_CODE'
      - 'IDENTIFICATION_VERIFIED_INDICATOR'
      - 'INSURANCE_REPOSITORY_NAME'
      - 'NREGA_CARD_NUMBER'
      - 'OVD_CATEGORY'
      - 'PAN_NUMBER'
      - 'PAN_VERIFICATION_STATUS'
      - 'PASSPORT_EXPIRY_DATE'
      - 'PASSPORT_NUMBER'
      - 'TAN_NUMBER'
      - 'VOTER_ID_NUMBER'
derived_columns:
  PARTY_BK__PROPOSER: "nullif(trim(case when coalesce(nullif(trim(w0_party_code),'')) is not null then nullif(trim(w0_party_code), '') end),'')"
  PARTY_NK__PROPOSER: "'HUB_PARTY|' || (nullif(trim(case when coalesce(nullif(trim(w0_party_code),'')) is not null then nullif(trim(w0_party_code), '') end),''))"
  AADHAAR_NUMBER: 'cast(null as varchar)'
  AADHAAR_VERIFICATION_STATUS: 'cast(null as varchar)'
  ACCOUNT_HOLDER_NAME: 'name_as_per_bank_ac'
  ACCOUNT_NUMBER_MASKED: "coalesce(nullif(trim(bank_account_number), ''),'')"
  ACCOUNT_TYPE: 'account_type'
  AGE_PROOF_TYPE: 'cast(null as varchar)'
  BANK_NAME: 'name_of_the_bank'
  BRANCH_NAME: 'bank_branch_name'
  CIN_NUMBER: 'cast(null as varchar)'
  CKYC_NUMBER: 'cast(null as varchar)'
  DRIVING_LICENCE_EXPIRY_DATE: 'cast(null as varchar)'
  DRIVING_LICENCE_NUMBER: 'cast(null as varchar)'
  EIA_NUMBER: 'cast(null as varchar)'
  GSTIN: 'cast(null as varchar)'
  GST_REGISTRATION_STATUS: 'cast(null as varchar)'
  GST_TAXPAYER_TYPE: 'cast(null as varchar)'
  IDENTIFICATION_EXPIRY_DATE: 'cast(null as varchar)'
  IDENTIFICATION_ISSUE_DATE: 'passport_issue_date'
  IDENTIFICATION_ISSUING_AUTHORITY: 'cast(null as varchar)'
  IDENTIFICATION_NUMBER: 'cast(null as varchar)'
  IDENTIFICATION_TYPE_CODE: "'PASSPORT'"
  IDENTIFICATION_VERIFIED_INDICATOR: 'cast(null as varchar)'
  IFSC_CODE: 'ifsc'
  INSURANCE_REPOSITORY_NAME: 'cast(null as varchar)'
  MICR_CODE: 'micr'
  NREGA_CARD_NUMBER: 'cast(null as varchar)'
  OVD_CATEGORY: 'cast(null as varchar)'
  PAN_NUMBER: 'cast(null as varchar)'
  PAN_VERIFICATION_STATUS: 'cast(null as varchar)'
  PASSPORT_EXPIRY_DATE: 'passport_expiry_date'
  PASSPORT_NUMBER: 'passport_number'
  PRIMARY_ACCOUNT_INDICATOR: 'primary_secondary'
  TAN_NUMBER: 'cast(null as varchar)'
  VOTER_ID_NUMBER: 'cast(null as varchar)'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS_PARTY_PROPERTY_MULTI_SET_PROPERTY_MULTI_SET_DETAIL_PROPERTY_PIVOT_VW'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
