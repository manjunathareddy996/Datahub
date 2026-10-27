{{ config(materialized='view') }}

-- WIDE stage() for Maximus Travel V2 view
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS
-- Covers this view's 4 key slot(s) and its 4 1:1 satellite target(s) in one pass,
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
--   PARTY_HKEY__PARENT_PARTY           HUB_PARTY / parent-party  (1 row(s) in the map)
--   PARTY_HKEY__PROPOSER               HUB_PARTY / proposer  (20 row(s) in the map)
--   POLICY_HKEY__PROPOSER              HUB_POLICY / proposer  (2 row(s) in the map)
--   POLICY_PARTY_HKEY__PROPOSER        LNK_POLICY_PARTY / proposer  LINK
--   HASHDIFF_LNK_POLICY_PARTY_ROLE     SAT_LNK_POLICY_PARTY_ROLE payload 2 of 3 live here
--   HASHDIFF_PARTY_EMPLOYMENT          SAT_PARTY_EMPLOYMENT payload 1 of 4 live here
--   HASHDIFF_PARTY_IDENTITY            SAT_PARTY_IDENTITY payload 10 of 15 live here
--   HASHDIFF_PARTY_ORGANISATION_PROFILE SAT_PARTY_ORGANISATION_PROFILE payload 3 of 11 live here

{%- set yaml_metadata -%}
source_model: 'resolved_mtv2__uwr_pol_prp'
hashed_columns:
  PARTY_HKEY__PARENT_PARTY: 'PARTY_NK__PARENT_PARTY'
  PARTY_HKEY__PROPOSER: 'PARTY_NK__PROPOSER'
  POLICY_HKEY__PROPOSER: 'POLICY_NK__PROPOSER'
  POLICY_PARTY_HKEY__PROPOSER: 'POLICY_PARTY_NK__PROPOSER'
  HASHDIFF_LNK_POLICY_PARTY_ROLE:
    is_hashdiff: true
    columns:
      - 'ATTRIBUTION_PERCENTAGE'
      - 'PARTY_ROLE_TYPE'
      - 'ROLE_EFFECTIVE_DATE'
      - 'ROLE_END_DATE'
      - 'ROLE_SEQUENCE'
  HASHDIFF_PARTY_EMPLOYMENT:
    is_hashdiff: true
    columns:
      - 'EMPLOYER_NAME'
      - 'OCCUPATION_CODE'
      - 'OCCUPATION_DESCRIPTION'
      - 'PROFESSIONAL_REGISTRATION_NUMBER'
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
  HASHDIFF_PARTY_ORGANISATION_PROFILE:
    is_hashdiff: true
    columns:
      - 'ANNUAL_TURNOVER'
      - 'BUSINESS_REGISTRATION_NUMBER'
      - 'DATE_OF_INCORPORATION'
      - 'INDUSTRY_CODE'
      - 'LEGAL_CONSTITUTION_TYPE'
      - 'MSME_CATEGORY'
      - 'MSME_INDICATOR'
      - 'NATURE_OF_BUSINESS'
      - 'NIC_CODE'
      - 'PAID_UP_CAPITAL'
      - 'PARENT_ENTITY_NAME'
derived_columns:
  PARTY_BK__PARENT_PARTY: "nullif(trim(case when coalesce(nullif(trim(parent_party_code),'')) is not null then nullif(trim(parent_party_code), '') end),'')"
  PARTY_NK__PARENT_PARTY: "'HUB_PARTY|' || (nullif(trim(case when coalesce(nullif(trim(parent_party_code),'')) is not null then nullif(trim(parent_party_code), '') end),''))"
  PARTY_BK__PROPOSER: "nullif(trim(case when coalesce(nullif(trim(party_code),'')) is not null then nullif(trim(party_code), '') end),'')"
  PARTY_NK__PROPOSER: "'HUB_PARTY|' || (nullif(trim(case when coalesce(nullif(trim(party_code),'')) is not null then nullif(trim(party_code), '') end),''))"
  POLICY_BK__PROPOSER: "nullif(trim(case when coalesce(nullif(trim(w0_policy_number),'')) is not null then nullif(trim(w0_policy_number), '') end),'')"
  POLICY_NK__PROPOSER: "'HUB_POLICY|' || (nullif(trim(case when coalesce(nullif(trim(w0_policy_number),'')) is not null then nullif(trim(w0_policy_number), '') end),''))"
  POLICY_PARTY_BK__PROPOSER: "coalesce(nullif(trim(case when coalesce(nullif(trim(w0_policy_number),'')) is not null then nullif(trim(w0_policy_number), '') end),''),'') || '|' || coalesce(nullif(trim(case when coalesce(nullif(trim(party_code),'')) is not null then nullif(trim(party_code), '') end),''),'')"
  POLICY_PARTY_NK__PROPOSER: "'LNK_POLICY_PARTY|' || (coalesce(nullif(trim(case when coalesce(nullif(trim(w0_policy_number),'')) is not null then nullif(trim(w0_policy_number), '') end),''),'') || '|' || coalesce(nullif(trim(case when coalesce(nullif(trim(party_code),'')) is not null then nullif(trim(party_code), '') end),''),''))"
  AGE: 'cast(null as varchar)'
  ANNUAL_TURNOVER: 'cast(null as varchar)'
  ATTRIBUTION_PERCENTAGE: 'cast(null as varchar)'
  BUSINESS_REGISTRATION_NUMBER: 'registration_no'
  COUNTRY_OF_BIRTH: 'cast(null as varchar)'
  COUNTRY_OF_RESIDENCE: 'cast(null as varchar)'
  DATE_OF_BIRTH: 'date_of_birth'
  DATE_OF_INCORPORATION: 'registration_date'
  EMPLOYER_NAME: 'cast(null as varchar)'
  FIRST_NAME: 'first_name'
  GENDER_CODE: 'gender'
  INDUSTRY_CODE: 'cast(null as varchar)'
  LAST_NAME: 'last_name'
  LEGAL_CONSTITUTION_TYPE: 'type_of_organization'
  MIDDLE_NAME: 'middle_name'
  MSME_CATEGORY: 'cast(null as varchar)'
  MSME_INDICATOR: 'cast(null as varchar)'
  NATIONALITY: 'nationality'
  NATURE_OF_BUSINESS: 'cast(null as varchar)'
  NIC_CODE: 'cast(null as varchar)'
  OCCUPATION_CODE: 'cast(null as varchar)'
  OCCUPATION_DESCRIPTION: 'occupation'
  PAID_UP_CAPITAL: 'cast(null as varchar)'
  PARENT_ENTITY_NAME: 'cast(null as varchar)'
  PARTY_FULL_NAME: 'cast(null as varchar)'
  PARTY_LEGAL_NAME: 'business_name'
  PARTY_ROLE_TYPE: "'PROPOSER'"
  PARTY_STATUS: 'party_status'
  PARTY_SUB_TYPE_CODE: 'cast(null as varchar)'
  PARTY_TYPE_CODE: 'type_of_party'
  PROFESSIONAL_REGISTRATION_NUMBER: 'cast(null as varchar)'
  ROLE_EFFECTIVE_DATE: 'party_start_date'
  ROLE_END_DATE: 'party_end_date'
  ROLE_SEQUENCE: "'1'"
  SALUTATION: 'title'
  LOAD_DATETIME: '!CURRENT_TIMESTAMP()'
  RECORD_SOURCE: '!NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_PROPOSER_DETAILS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
