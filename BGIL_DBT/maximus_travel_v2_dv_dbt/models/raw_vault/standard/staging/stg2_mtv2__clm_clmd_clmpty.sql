{{ config(materialized='view') }}

-- WIDE stage() for Maximus Travel V2 view
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_PARTY
-- Covers this view's 3 key slot(s) and its 3 1:1 satellite target(s) in one pass,
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
--   CLAIM_HKEY                         HUB_CLAIM  (1 row(s) in the map)
--   CLAIM_PARTY_HKEY                   LNK_CLAIM_PARTY  LINK
--   PARTY_HKEY                         HUB_PARTY  (7 row(s) in the map)
--   HASHDIFF_LNK_CLAIM_PARTY_ROLE      SAT_LNK_CLAIM_PARTY_ROLE payload 0 of 0 live here
--   HASHDIFF_PARTY_IDENTIFICATION      SAT_PARTY_IDENTIFICATION payload 1 of 25 live here
--   HASHDIFF_PARTY_IDENTITY            SAT_PARTY_IDENTITY payload 4 of 15 live here

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__clm_clmd_clmpty'
hashed_columns:
  CLAIM_HKEY: 'CLAIM_NK'
  CLAIM_PARTY_HKEY: 'CLAIM_PARTY_NK'
  PARTY_HKEY: 'PARTY_NK'
  HASHDIFF_LNK_CLAIM_PARTY_ROLE:
    is_hashdiff: true
    columns:
      - 'PARTY_ROLE_TYPE'
      - 'ROLE_SEQUENCE'
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
  HASHDIFF_PARTY_IDENTITY:
    is_hashdiff: true
    columns:
      - 'AGE'
      - 'COUNTRY_OF_BIRTH'
      - 'COUNTRY_OF_RESIDENCE'
      - 'DATE_OF_BIRTH'
      - 'FIRST_NAME'
      - 'GENDER_CODE'
      - 'LAST_NAME'
      - 'MIDDLE_NAME'
      - 'NATIONALITY'
      - 'PARTY_FULL_NAME'
      - 'PARTY_LEGAL_NAME'
      - 'PARTY_STATUS'
      - 'PARTY_SUB_TYPE_CODE'
      - 'PARTY_TYPE_CODE'
      - 'SALUTATION'
derived_columns:
  CLAIM_BK: "nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'')"
  CLAIM_NK: "'HUB_CLAIM|' || (nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),''))"
  CLAIM_PARTY_BK: "coalesce(nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),''),'') || '|' || coalesce(nullif(trim(case when coalesce(nullif(trim(partycode),'')) is not null then nullif(trim(partycode), '') end),''),'')"
  CLAIM_PARTY_NK: "'LNK_CLAIM_PARTY|' || (coalesce(nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),''),'') || '|' || coalesce(nullif(trim(case when coalesce(nullif(trim(partycode),'')) is not null then nullif(trim(partycode), '') end),''),''))"
  PARTY_BK: "nullif(trim(case when coalesce(nullif(trim(partycode),'')) is not null then nullif(trim(partycode), '') end),'')"
  PARTY_NK: "'HUB_PARTY|' || (nullif(trim(case when coalesce(nullif(trim(partycode),'')) is not null then nullif(trim(partycode), '') end),''))"
  AADHAAR_NUMBER: 'cast(null as varchar)'
  AADHAAR_VERIFICATION_STATUS: 'cast(null as varchar)'
  AGE: 'cast(null as varchar)'
  AGE_PROOF_TYPE: 'cast(null as varchar)'
  CIN_NUMBER: 'cast(null as varchar)'
  CKYC_NUMBER: 'cast(null as varchar)'
  COUNTRY_OF_BIRTH: 'cast(null as varchar)'
  COUNTRY_OF_RESIDENCE: 'cast(null as varchar)'
  DATE_OF_BIRTH: 'cast(null as varchar)'
  DRIVING_LICENCE_EXPIRY_DATE: 'cast(null as varchar)'
  DRIVING_LICENCE_NUMBER: 'cast(null as varchar)'
  EIA_NUMBER: 'cast(null as varchar)'
  FIRST_NAME: 'firstname'
  GENDER_CODE: 'cast(null as varchar)'
  GSTIN: 'cast(null as varchar)'
  GST_REGISTRATION_STATUS: 'cast(null as varchar)'
  GST_TAXPAYER_TYPE: 'cast(null as varchar)'
  IDENTIFICATION_EXPIRY_DATE: 'cast(null as varchar)'
  IDENTIFICATION_ISSUE_DATE: 'cast(null as varchar)'
  IDENTIFICATION_ISSUING_AUTHORITY: 'cast(null as varchar)'
  IDENTIFICATION_NUMBER: 'nif'
  IDENTIFICATION_TYPE_CODE: "'NIF'"
  IDENTIFICATION_VERIFIED_INDICATOR: 'cast(null as varchar)'
  INSURANCE_REPOSITORY_NAME: 'cast(null as varchar)'
  LAST_NAME: 'lastname'
  MIDDLE_NAME: 'middlename'
  NATIONALITY: 'cast(null as varchar)'
  NREGA_CARD_NUMBER: 'cast(null as varchar)'
  OVD_CATEGORY: 'cast(null as varchar)'
  PAN_NUMBER: 'cast(null as varchar)'
  PAN_VERIFICATION_STATUS: 'cast(null as varchar)'
  PARTY_FULL_NAME: 'cast(null as varchar)'
  PARTY_LEGAL_NAME: 'business_name'
  PARTY_ROLE_TYPE: "coalesce(nullif(trim(stakecode), ''),'')"
  PARTY_STATUS: 'cast(null as varchar)'
  PARTY_SUB_TYPE_CODE: 'cast(null as varchar)'
  PARTY_TYPE_CODE: 'cast(null as varchar)'
  PASSPORT_EXPIRY_DATE: 'cast(null as varchar)'
  PASSPORT_NUMBER: 'cast(null as varchar)'
  ROLE_SEQUENCE: "'1'"
  SALUTATION: 'cast(null as varchar)'
  TAN_NUMBER: 'cast(null as varchar)'
  VOTER_ID_NUMBER: 'cast(null as varchar)'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_PARTY'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
