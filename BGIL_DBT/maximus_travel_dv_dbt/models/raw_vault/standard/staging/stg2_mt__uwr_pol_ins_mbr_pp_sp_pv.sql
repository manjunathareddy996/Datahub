{{ config(materialized='view') }}

-- WIDE stage() for Maximus Travel view
--   NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW
-- Covers this view's 13 key slot(s) and its 15 1:1 satellite target(s) in one pass,
-- with a separately-named hashdiff per satellite so each is scoped to its own payload.
-- The bare HASHDIFF the sibling contract requires is produced by the satfeed layer,
-- which is the only place one name can serve one satellite (BD7).
--
-- Fan-in families on this view, if any, are handled by the unpivot layer instead: one
-- row per instance cannot be expressed as columns of one row here.
--
-- Every BK is the guarded rendering. When every non-literal operand is blank the key is
-- NULL, the hub feed drops it, and audit_mt_key_rejections counts the drop per hub per
-- feeder -- so a zero is a measured zero (directive D-REJECT).
--
--   DISTRIBUTION_CHANNEL_HKEY          HUB_DISTRIBUTION_CHANNEL  (1 row(s) in the map)
--   LOCATION_HKEY__CORRESPONDENCE_LOCAL HUB_LOCATION / correspondence-local  (9 row(s) in the map)
--   LOCATION_HKEY__INSURED_MEMBER_CORRESPONDENCE_LOCAL HUB_LOCATION / insured-member@correspondence-local  (2 row(s) in the map)
--   LOCATION_HKEY__INSURED_MEMBER_PERMANENT_OVERSEAS HUB_LOCATION / insured-member@permanent-overseas  (2 row(s) in the map)
--   LOCATION_HKEY__PERMANENT_OVERSEAS  HUB_LOCATION / permanent-overseas  (8 row(s) in the map)
--   PARTY_HKEY__INSURED_MEMBER         HUB_PARTY / insured-member  (165 row(s) in the map)
--   PARTY_HKEY__INSURED_MEMBER_CORRESPONDENCE_LOCAL HUB_PARTY / insured-member@correspondence-local  (2 row(s) in the map)
--   PARTY_HKEY__INSURED_MEMBER_PERMANENT_OVERSEAS HUB_PARTY / insured-member@permanent-overseas  (2 row(s) in the map)
--   PARTY_HKEY__PARENT_PARTY           HUB_PARTY / parent-party  (1 row(s) in the map)
--   PARTY_LOCATION_HKEY__INSURED_MEMBER_CORRESPONDENCE_LOCAL LNK_PARTY_LOCATION / insured-member@correspondence-local  LINK
--   PARTY_LOCATION_HKEY__INSURED_MEMBER_PERMANENT_OVERSEAS LNK_PARTY_LOCATION / insured-member@permanent-overseas  LINK
--   PARTY_ROLE_HKEY__INSURED_MEMBER    LNK_PARTY_ROLE / insured-member  LINK
--   QUOTE_HKEY                         HUB_QUOTE  (1 row(s) in the map)
--   HASHDIFF_COMMON_ADDRESS            SAT_COMMON_ADDRESS payload 9 of 16 live here
--   HASHDIFF_COMMON_CLASSIFICATION     SAT_COMMON_CLASSIFICATION payload 4 of 4 live here
--   HASHDIFF_COMMON_COMMUNICATION_PREFERENCE SAT_COMMON_COMMUNICATION_PREFERENCE payload 3 of 4 live here
--   HASHDIFF_COMMON_CONSENT            SAT_COMMON_CONSENT payload 2 of 2 live here
--   HASHDIFF_LNK_PARTY_ROLE_CORE       SAT_LNK_PARTY_ROLE_CORE payload 1 of 1 live here
--   HASHDIFF_LNK_ROLE_EMPLOYEE         SAT_LNK_ROLE_EMPLOYEE payload 1 of 1 live here
--   HASHDIFF_PARTY_AML_SCREENING       SAT_PARTY_AML_SCREENING payload 1 of 1 live here
--   HASHDIFF_PARTY_CONTACT_ADDRESS_LINK SAT_PARTY_CONTACT_ADDRESS_LINK payload 1 of 1 live here
--   HASHDIFF_PARTY_EMPLOYMENT          SAT_PARTY_EMPLOYMENT payload 3 of 4 live here
--   HASHDIFF_PARTY_FRAUD_PROFILE       SAT_PARTY_FRAUD_PROFILE payload 4 of 4 live here
--   HASHDIFF_PARTY_HEALTH_PROFILE      SAT_PARTY_HEALTH_PROFILE payload 6 of 6 live here
--   HASHDIFF_PARTY_IDENTITY            SAT_PARTY_IDENTITY payload 7 of 15 live here
--   HASHDIFF_PARTY_INDIVIDUAL_DEMOGRAPHICS SAT_PARTY_INDIVIDUAL_DEMOGRAPHICS payload 4 of 6 live here
--   HASHDIFF_PARTY_KYC                 SAT_PARTY_KYC payload 7 of 8 live here
--   HASHDIFF_PARTY_ORGANISATION_PROFILE SAT_PARTY_ORGANISATION_PROFILE payload 14 of 18 live here

{%- set yaml_metadata -%}
source_model: 'resolved_mt__uwr_pol_ins_mbr_pp_sp_pv'
hashed_columns:
  DISTRIBUTION_CHANNEL_HKEY: 'DISTRIBUTION_CHANNEL_NK'
  LOCATION_HKEY__CORRESPONDENCE_LOCAL: 'LOCATION_NK__CORRESPONDENCE_LOCAL'
  LOCATION_HKEY__INSURED_MEMBER_CORRESPONDENCE_LOCAL: 'LOCATION_NK__INSURED_MEMBER_CORRESPONDENCE_LOCAL'
  LOCATION_HKEY__INSURED_MEMBER_PERMANENT_OVERSEAS: 'LOCATION_NK__INSURED_MEMBER_PERMANENT_OVERSEAS'
  LOCATION_HKEY__PERMANENT_OVERSEAS: 'LOCATION_NK__PERMANENT_OVERSEAS'
  PARTY_HKEY__INSURED_MEMBER: 'PARTY_NK__INSURED_MEMBER'
  PARTY_HKEY__INSURED_MEMBER_CORRESPONDENCE_LOCAL: 'PARTY_NK__INSURED_MEMBER_CORRESPONDENCE_LOCAL'
  PARTY_HKEY__INSURED_MEMBER_PERMANENT_OVERSEAS: 'PARTY_NK__INSURED_MEMBER_PERMANENT_OVERSEAS'
  PARTY_HKEY__PARENT_PARTY: 'PARTY_NK__PARENT_PARTY'
  PARTY_LOCATION_HKEY__INSURED_MEMBER_CORRESPONDENCE_LOCAL: 'PARTY_LOCATION_NK__INSURED_MEMBER_CORRESPONDENCE_LOCAL'
  PARTY_LOCATION_HKEY__INSURED_MEMBER_PERMANENT_OVERSEAS: 'PARTY_LOCATION_NK__INSURED_MEMBER_PERMANENT_OVERSEAS'
  PARTY_ROLE_HKEY__INSURED_MEMBER: 'PARTY_ROLE_NK__INSURED_MEMBER'
  QUOTE_HKEY: 'QUOTE_NK'
  HASHDIFF_COMMON_ADDRESS:
    is_hashdiff: true
    columns:
      - 'ADDRESS_LINE_1'
      - 'ADDRESS_LINE_2'
      - 'ADDRESS_LINE_3'
      - 'ADDRESS_TYPE_CODE'
      - 'CARE_OF_NAME'
      - 'CITY'
      - 'COUNTRY_CODE'
      - 'COUNTRY_NAME'
      - 'DISTRICT'
      - 'LANDMARK'
      - 'LOCALITY'
      - 'POSTAL_CODE'
      - 'POST_OFFICE_NAME'
      - 'STATE_CODE'
      - 'STATE_NAME'
      - 'STREET_NAME'
  HASHDIFF_COMMON_CLASSIFICATION:
    is_hashdiff: true
    columns:
      - 'CATEGORY_CODE'
      - 'SEGMENT_NAME'
      - 'TIER_CODE'
      - 'VALUE_BAND'
  HASHDIFF_COMMON_COMMUNICATION_PREFERENCE:
    is_hashdiff: true
    columns:
      - 'GO_GREEN_OPT_IN_INDICATOR'
      - 'PREFERRED_CHANNEL_CODE'
      - 'PREFERRED_LANGUAGE_CODE'
      - 'SMS_OPT_IN_INDICATOR'
  HASHDIFF_COMMON_CONSENT:
    is_hashdiff: true
    columns:
      - 'CONSENT_GIVEN_INDICATOR'
      - 'DATA_SHARING_CONSENT_INDICATOR'
  HASHDIFF_LNK_PARTY_ROLE_CORE:
    is_hashdiff: true
    columns:
      - 'ROLE_CODE'
      - 'ROLE_SEQUENCE'
      - 'ROLE_TYPE'
  HASHDIFF_LNK_ROLE_EMPLOYEE:
    is_hashdiff: true
    columns:
      - 'EMPLOYEE_CODE'
  HASHDIFF_PARTY_AML_SCREENING:
    is_hashdiff: true
    columns:
      - 'SCREENING_STATUS'
  HASHDIFF_PARTY_CONTACT_ADDRESS_LINK:
    is_hashdiff: true
    columns:
      - 'ADDRESS_PROOF_TYPE'
      - 'ADDRESS_USAGE_TYPE'
  HASHDIFF_PARTY_EMPLOYMENT:
    is_hashdiff: true
    columns:
      - 'EMPLOYER_NAME'
      - 'OCCUPATION_CODE'
      - 'OCCUPATION_DESCRIPTION'
      - 'PROFESSIONAL_REGISTRATION_NUMBER'
  HASHDIFF_PARTY_FRAUD_PROFILE:
    is_hashdiff: true
    columns:
      - 'NEGATIVE_LIST_DATE'
      - 'NEGATIVE_LIST_INDICATOR'
      - 'NEGATIVE_LIST_REASON'
      - 'NON_DISCLOSURE_ACTION_INITIATED_INDICATOR'
  HASHDIFF_PARTY_HEALTH_PROFILE:
    is_hashdiff: true
    columns:
      - 'CURRENT_MEDICATION_DETAIL'
      - 'DISABILITY_INDICATOR'
      - 'DISABILITY_PERCENTAGE'
      - 'HEIGHT'
      - 'PRE_EXISTING_DISEASE_DESCRIPTION'
      - 'WEIGHT'
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
  HASHDIFF_PARTY_INDIVIDUAL_DEMOGRAPHICS:
    is_hashdiff: true
    columns:
      - 'EDUCATIONAL_QUALIFICATION'
      - 'FATHER_NAME'
      - 'HIGHEST_DEGREE'
      - 'MARITAL_STATUS'
      - 'SPOUSE_NAME'
      - 'YEARS_IN_CITY'
  HASHDIFF_PARTY_KYC:
    is_hashdiff: true
    columns:
      - 'CKYC_DETAILS_NARRATIVE'
      - 'CKYC_NUMBER_HELD_DECLARED_INDICATOR'
      - 'CKYC_REGISTRATION_STATUS'
      - 'KYC_COMPLETION_DATE'
      - 'KYC_DETAILS_DESCRIPTION'
      - 'KYC_DETAIL_DESCRIPTION'
      - 'KYC_RELATED_DETAILS_DESCRIPTION'
      - 'KYC_STATUS'
  HASHDIFF_PARTY_ORGANISATION_PROFILE:
    is_hashdiff: true
    columns:
      - 'ANNUAL_TURNOVER'
      - 'BUSINESS_REGISTRATION_DATE'
      - 'BUSINESS_REGISTRATION_NUMBER'
      - 'BUSINESS_TYPE_CODE'
      - 'DATE_OF_INCORPORATION'
      - 'INDUSTRY_CODE'
      - 'INFRASTRUCTURE_SUB_SECTOR'
      - 'LEGAL_CONSTITUTION_TYPE'
      - 'MSME_CATEGORY'
      - 'MSME_INDICATOR'
      - 'NATURE_OF_BUSINESS'
      - 'NIC_CODE'
      - 'OTHER_INDUSTRY_TYPE_DESCRIPTION'
      - 'PAID_UP_CAPITAL'
      - 'PARENT_ENTITY_NAME'
      - 'REGISTERED_BUSINESS_TRUST_INDICATOR'
      - 'REGISTERED_COMPANY_DECLARED_INDICATOR'
      - 'TRADE_NAME'
derived_columns:
  DISTRIBUTION_CHANNEL_BK: "nullif(trim(case when nullif(trim(partner_ref),'') is not null then nullif(trim(partner_ref), '') end),'')"
  DISTRIBUTION_CHANNEL_NK: "'HUB_DISTRIBUTION_CHANNEL|' || (nullif(trim(case when nullif(trim(partner_ref),'') is not null then nullif(trim(partner_ref), '') end),''))"
  LOCATION_BK__CORRESPONDENCE_LOCAL: "nullif(trim(case when coalesce(nullif(trim(correspondence_local_address_line_1),''), nullif(trim(correspondence_local_address_line_2),''), nullif(trim(correspondence_local_address_line_3),''), nullif(trim(correspondence_local_address_city_town_village),''), nullif(trim(correspondence_local_address_district),''), nullif(trim(correspondence_local_address_state),''), nullif(trim(correspondence_local_address_country),''), nullif(trim(local_address_pin_code),'')) is not null then md5(upper(regexp_replace(trim(nullif(trim(coalesce(nullif(trim(correspondence_local_address_line_1), ''), '') || '|' || coalesce(nullif(trim(correspondence_local_address_line_2), ''), '') || '|' || coalesce(nullif(trim(correspondence_local_address_line_3), ''), '') || '|' || coalesce(nullif(trim(correspondence_local_address_city_town_village), ''), '') || '|' || coalesce(nullif(trim(correspondence_local_address_district), ''), '') || '|' || coalesce(nullif(trim(correspondence_local_address_state), ''), '') || '|' || coalesce(nullif(trim(correspondence_local_address_country), ''), '') || '|' || coalesce(nullif(trim(local_address_pin_code), ''), '')), '|||||||')), '[[:space:]]+', ' '))) end),'')"
  LOCATION_NK__CORRESPONDENCE_LOCAL: "'HUB_LOCATION|' || (nullif(trim(case when coalesce(nullif(trim(correspondence_local_address_line_1),''), nullif(trim(correspondence_local_address_line_2),''), nullif(trim(correspondence_local_address_line_3),''), nullif(trim(correspondence_local_address_city_town_village),''), nullif(trim(correspondence_local_address_district),''), nullif(trim(correspondence_local_address_state),''), nullif(trim(correspondence_local_address_country),''), nullif(trim(local_address_pin_code),'')) is not null then md5(upper(regexp_replace(trim(nullif(trim(coalesce(nullif(trim(correspondence_local_address_line_1), ''), '') || '|' || coalesce(nullif(trim(correspondence_local_address_line_2), ''), '') || '|' || coalesce(nullif(trim(correspondence_local_address_line_3), ''), '') || '|' || coalesce(nullif(trim(correspondence_local_address_city_town_village), ''), '') || '|' || coalesce(nullif(trim(correspondence_local_address_district), ''), '') || '|' || coalesce(nullif(trim(correspondence_local_address_state), ''), '') || '|' || coalesce(nullif(trim(correspondence_local_address_country), ''), '') || '|' || coalesce(nullif(trim(local_address_pin_code), ''), '')), '|||||||')), '[[:space:]]+', ' '))) end),''))"
  LOCATION_BK__INSURED_MEMBER_CORRESPONDENCE_LOCAL: "nullif(trim(case when coalesce(nullif(trim(correspondence_local_address_line_1),''), nullif(trim(correspondence_local_address_line_2),''), nullif(trim(correspondence_local_address_line_3),''), nullif(trim(correspondence_local_address_city_town_village),''), nullif(trim(correspondence_local_address_district),''), nullif(trim(correspondence_local_address_state),''), nullif(trim(correspondence_local_address_country),''), nullif(trim(local_address_pin_code),'')) is not null then md5(upper(regexp_replace(trim(nullif(trim(coalesce(nullif(trim(correspondence_local_address_line_1), ''), '') || '|' || coalesce(nullif(trim(correspondence_local_address_line_2), ''), '') || '|' || coalesce(nullif(trim(correspondence_local_address_line_3), ''), '') || '|' || coalesce(nullif(trim(correspondence_local_address_city_town_village), ''), '') || '|' || coalesce(nullif(trim(correspondence_local_address_district), ''), '') || '|' || coalesce(nullif(trim(correspondence_local_address_state), ''), '') || '|' || coalesce(nullif(trim(correspondence_local_address_country), ''), '') || '|' || coalesce(nullif(trim(local_address_pin_code), ''), '')), '|||||||')), '[[:space:]]+', ' '))) end),'')"
  LOCATION_NK__INSURED_MEMBER_CORRESPONDENCE_LOCAL: "'HUB_LOCATION|' || (nullif(trim(case when coalesce(nullif(trim(correspondence_local_address_line_1),''), nullif(trim(correspondence_local_address_line_2),''), nullif(trim(correspondence_local_address_line_3),''), nullif(trim(correspondence_local_address_city_town_village),''), nullif(trim(correspondence_local_address_district),''), nullif(trim(correspondence_local_address_state),''), nullif(trim(correspondence_local_address_country),''), nullif(trim(local_address_pin_code),'')) is not null then md5(upper(regexp_replace(trim(nullif(trim(coalesce(nullif(trim(correspondence_local_address_line_1), ''), '') || '|' || coalesce(nullif(trim(correspondence_local_address_line_2), ''), '') || '|' || coalesce(nullif(trim(correspondence_local_address_line_3), ''), '') || '|' || coalesce(nullif(trim(correspondence_local_address_city_town_village), ''), '') || '|' || coalesce(nullif(trim(correspondence_local_address_district), ''), '') || '|' || coalesce(nullif(trim(correspondence_local_address_state), ''), '') || '|' || coalesce(nullif(trim(correspondence_local_address_country), ''), '') || '|' || coalesce(nullif(trim(local_address_pin_code), ''), '')), '|||||||')), '[[:space:]]+', ' '))) end),''))"
  LOCATION_BK__INSURED_MEMBER_PERMANENT_OVERSEAS: "nullif(trim(case when coalesce(nullif(trim(current_permanent_overseas_address_line_1),''), nullif(trim(current_permanent_overseas_address_line_2),''), nullif(trim(current_permanent_overseas_address_line_3),''), nullif(trim(current_permanent_overseas_address_city_town_village),''), nullif(trim(current_permanent_overseas_address_state_ut),''), nullif(trim(current_permanent_overseas_address_country),''), nullif(trim(current_permanent_overseas_address_pin_code),'')) is not null then md5(upper(regexp_replace(trim(nullif(trim(coalesce(nullif(trim(current_permanent_overseas_address_line_1), ''), '') || '|' || coalesce(nullif(trim(current_permanent_overseas_address_line_2), ''), '') || '|' || coalesce(nullif(trim(current_permanent_overseas_address_line_3), ''), '') || '|' || coalesce(nullif(trim(current_permanent_overseas_address_city_town_village), ''), '') || '|' || coalesce(nullif(trim(current_permanent_overseas_address_state_ut), ''), '') || '|' || coalesce(nullif(trim(current_permanent_overseas_address_country), ''), '') || '|' || coalesce(nullif(trim(current_permanent_overseas_address_pin_code), ''), '')), '||||||')), '[[:space:]]+', ' '))) end),'')"
  LOCATION_NK__INSURED_MEMBER_PERMANENT_OVERSEAS: "'HUB_LOCATION|' || (nullif(trim(case when coalesce(nullif(trim(current_permanent_overseas_address_line_1),''), nullif(trim(current_permanent_overseas_address_line_2),''), nullif(trim(current_permanent_overseas_address_line_3),''), nullif(trim(current_permanent_overseas_address_city_town_village),''), nullif(trim(current_permanent_overseas_address_state_ut),''), nullif(trim(current_permanent_overseas_address_country),''), nullif(trim(current_permanent_overseas_address_pin_code),'')) is not null then md5(upper(regexp_replace(trim(nullif(trim(coalesce(nullif(trim(current_permanent_overseas_address_line_1), ''), '') || '|' || coalesce(nullif(trim(current_permanent_overseas_address_line_2), ''), '') || '|' || coalesce(nullif(trim(current_permanent_overseas_address_line_3), ''), '') || '|' || coalesce(nullif(trim(current_permanent_overseas_address_city_town_village), ''), '') || '|' || coalesce(nullif(trim(current_permanent_overseas_address_state_ut), ''), '') || '|' || coalesce(nullif(trim(current_permanent_overseas_address_country), ''), '') || '|' || coalesce(nullif(trim(current_permanent_overseas_address_pin_code), ''), '')), '||||||')), '[[:space:]]+', ' '))) end),''))"
  LOCATION_BK__PERMANENT_OVERSEAS: "nullif(trim(case when coalesce(nullif(trim(current_permanent_overseas_address_line_1),''), nullif(trim(current_permanent_overseas_address_line_2),''), nullif(trim(current_permanent_overseas_address_line_3),''), nullif(trim(current_permanent_overseas_address_city_town_village),''), nullif(trim(current_permanent_overseas_address_state_ut),''), nullif(trim(current_permanent_overseas_address_country),''), nullif(trim(current_permanent_overseas_address_pin_code),'')) is not null then md5(upper(regexp_replace(trim(nullif(trim(coalesce(nullif(trim(current_permanent_overseas_address_line_1), ''), '') || '|' || coalesce(nullif(trim(current_permanent_overseas_address_line_2), ''), '') || '|' || coalesce(nullif(trim(current_permanent_overseas_address_line_3), ''), '') || '|' || coalesce(nullif(trim(current_permanent_overseas_address_city_town_village), ''), '') || '|' || coalesce(nullif(trim(current_permanent_overseas_address_state_ut), ''), '') || '|' || coalesce(nullif(trim(current_permanent_overseas_address_country), ''), '') || '|' || coalesce(nullif(trim(current_permanent_overseas_address_pin_code), ''), '')), '||||||')), '[[:space:]]+', ' '))) end),'')"
  LOCATION_NK__PERMANENT_OVERSEAS: "'HUB_LOCATION|' || (nullif(trim(case when coalesce(nullif(trim(current_permanent_overseas_address_line_1),''), nullif(trim(current_permanent_overseas_address_line_2),''), nullif(trim(current_permanent_overseas_address_line_3),''), nullif(trim(current_permanent_overseas_address_city_town_village),''), nullif(trim(current_permanent_overseas_address_state_ut),''), nullif(trim(current_permanent_overseas_address_country),''), nullif(trim(current_permanent_overseas_address_pin_code),'')) is not null then md5(upper(regexp_replace(trim(nullif(trim(coalesce(nullif(trim(current_permanent_overseas_address_line_1), ''), '') || '|' || coalesce(nullif(trim(current_permanent_overseas_address_line_2), ''), '') || '|' || coalesce(nullif(trim(current_permanent_overseas_address_line_3), ''), '') || '|' || coalesce(nullif(trim(current_permanent_overseas_address_city_town_village), ''), '') || '|' || coalesce(nullif(trim(current_permanent_overseas_address_state_ut), ''), '') || '|' || coalesce(nullif(trim(current_permanent_overseas_address_country), ''), '') || '|' || coalesce(nullif(trim(current_permanent_overseas_address_pin_code), ''), '')), '||||||')), '[[:space:]]+', ' '))) end),''))"
  PARTY_BK__INSURED_MEMBER: "nullif(trim(case when nullif(trim(w0_party_code),'') is not null then nullif(trim(w0_party_code), '') end),'')"
  PARTY_NK__INSURED_MEMBER: "'HUB_PARTY|' || (nullif(trim(case when nullif(trim(w0_party_code),'') is not null then nullif(trim(w0_party_code), '') end),''))"
  PARTY_BK__INSURED_MEMBER_CORRESPONDENCE_LOCAL: "nullif(trim(case when nullif(trim(w0_party_code),'') is not null then nullif(trim(w0_party_code), '') end),'')"
  PARTY_NK__INSURED_MEMBER_CORRESPONDENCE_LOCAL: "'HUB_PARTY|' || (nullif(trim(case when nullif(trim(w0_party_code),'') is not null then nullif(trim(w0_party_code), '') end),''))"
  PARTY_BK__INSURED_MEMBER_PERMANENT_OVERSEAS: "nullif(trim(case when nullif(trim(w0_party_code),'') is not null then nullif(trim(w0_party_code), '') end),'')"
  PARTY_NK__INSURED_MEMBER_PERMANENT_OVERSEAS: "'HUB_PARTY|' || (nullif(trim(case when nullif(trim(w0_party_code),'') is not null then nullif(trim(w0_party_code), '') end),''))"
  PARTY_BK__PARENT_PARTY: "nullif(trim(case when nullif(trim(parent_party_code),'') is not null then nullif(trim(parent_party_code), '') end),'')"
  PARTY_NK__PARENT_PARTY: "'HUB_PARTY|' || (nullif(trim(case when nullif(trim(parent_party_code),'') is not null then nullif(trim(parent_party_code), '') end),''))"
  PARTY_LOCATION_BK__INSURED_MEMBER_CORRESPONDENCE_LOCAL: "coalesce(nullif(trim(case when nullif(trim(w0_party_code),'') is not null then nullif(trim(w0_party_code), '') end),''),'') || '|' || coalesce(nullif(trim(case when coalesce(nullif(trim(correspondence_local_address_line_1),''), nullif(trim(correspondence_local_address_line_2),''), nullif(trim(correspondence_local_address_line_3),''), nullif(trim(correspondence_local_address_city_town_village),''), nullif(trim(correspondence_local_address_district),''), nullif(trim(correspondence_local_address_state),''), nullif(trim(correspondence_local_address_country),''), nullif(trim(local_address_pin_code),'')) is not null then md5(upper(regexp_replace(trim(nullif(trim(coalesce(nullif(trim(correspondence_local_address_line_1), ''), '') || '|' || coalesce(nullif(trim(correspondence_local_address_line_2), ''), '') || '|' || coalesce(nullif(trim(correspondence_local_address_line_3), ''), '') || '|' || coalesce(nullif(trim(correspondence_local_address_city_town_village), ''), '') || '|' || coalesce(nullif(trim(correspondence_local_address_district), ''), '') || '|' || coalesce(nullif(trim(correspondence_local_address_state), ''), '') || '|' || coalesce(nullif(trim(correspondence_local_address_country), ''), '') || '|' || coalesce(nullif(trim(local_address_pin_code), ''), '')), '|||||||')), '[[:space:]]+', ' '))) end),''),'')"
  PARTY_LOCATION_NK__INSURED_MEMBER_CORRESPONDENCE_LOCAL: "'LNK_PARTY_LOCATION|' || (coalesce(nullif(trim(case when nullif(trim(w0_party_code),'') is not null then nullif(trim(w0_party_code), '') end),''),'') || '|' || coalesce(nullif(trim(case when coalesce(nullif(trim(correspondence_local_address_line_1),''), nullif(trim(correspondence_local_address_line_2),''), nullif(trim(correspondence_local_address_line_3),''), nullif(trim(correspondence_local_address_city_town_village),''), nullif(trim(correspondence_local_address_district),''), nullif(trim(correspondence_local_address_state),''), nullif(trim(correspondence_local_address_country),''), nullif(trim(local_address_pin_code),'')) is not null then md5(upper(regexp_replace(trim(nullif(trim(coalesce(nullif(trim(correspondence_local_address_line_1), ''), '') || '|' || coalesce(nullif(trim(correspondence_local_address_line_2), ''), '') || '|' || coalesce(nullif(trim(correspondence_local_address_line_3), ''), '') || '|' || coalesce(nullif(trim(correspondence_local_address_city_town_village), ''), '') || '|' || coalesce(nullif(trim(correspondence_local_address_district), ''), '') || '|' || coalesce(nullif(trim(correspondence_local_address_state), ''), '') || '|' || coalesce(nullif(trim(correspondence_local_address_country), ''), '') || '|' || coalesce(nullif(trim(local_address_pin_code), ''), '')), '|||||||')), '[[:space:]]+', ' '))) end),''),''))"
  PARTY_LOCATION_BK__INSURED_MEMBER_PERMANENT_OVERSEAS: "coalesce(nullif(trim(case when nullif(trim(w0_party_code),'') is not null then nullif(trim(w0_party_code), '') end),''),'') || '|' || coalesce(nullif(trim(case when coalesce(nullif(trim(current_permanent_overseas_address_line_1),''), nullif(trim(current_permanent_overseas_address_line_2),''), nullif(trim(current_permanent_overseas_address_line_3),''), nullif(trim(current_permanent_overseas_address_city_town_village),''), nullif(trim(current_permanent_overseas_address_state_ut),''), nullif(trim(current_permanent_overseas_address_country),''), nullif(trim(current_permanent_overseas_address_pin_code),'')) is not null then md5(upper(regexp_replace(trim(nullif(trim(coalesce(nullif(trim(current_permanent_overseas_address_line_1), ''), '') || '|' || coalesce(nullif(trim(current_permanent_overseas_address_line_2), ''), '') || '|' || coalesce(nullif(trim(current_permanent_overseas_address_line_3), ''), '') || '|' || coalesce(nullif(trim(current_permanent_overseas_address_city_town_village), ''), '') || '|' || coalesce(nullif(trim(current_permanent_overseas_address_state_ut), ''), '') || '|' || coalesce(nullif(trim(current_permanent_overseas_address_country), ''), '') || '|' || coalesce(nullif(trim(current_permanent_overseas_address_pin_code), ''), '')), '||||||')), '[[:space:]]+', ' '))) end),''),'')"
  PARTY_LOCATION_NK__INSURED_MEMBER_PERMANENT_OVERSEAS: "'LNK_PARTY_LOCATION|' || (coalesce(nullif(trim(case when nullif(trim(w0_party_code),'') is not null then nullif(trim(w0_party_code), '') end),''),'') || '|' || coalesce(nullif(trim(case when coalesce(nullif(trim(current_permanent_overseas_address_line_1),''), nullif(trim(current_permanent_overseas_address_line_2),''), nullif(trim(current_permanent_overseas_address_line_3),''), nullif(trim(current_permanent_overseas_address_city_town_village),''), nullif(trim(current_permanent_overseas_address_state_ut),''), nullif(trim(current_permanent_overseas_address_country),''), nullif(trim(current_permanent_overseas_address_pin_code),'')) is not null then md5(upper(regexp_replace(trim(nullif(trim(coalesce(nullif(trim(current_permanent_overseas_address_line_1), ''), '') || '|' || coalesce(nullif(trim(current_permanent_overseas_address_line_2), ''), '') || '|' || coalesce(nullif(trim(current_permanent_overseas_address_line_3), ''), '') || '|' || coalesce(nullif(trim(current_permanent_overseas_address_city_town_village), ''), '') || '|' || coalesce(nullif(trim(current_permanent_overseas_address_state_ut), ''), '') || '|' || coalesce(nullif(trim(current_permanent_overseas_address_country), ''), '') || '|' || coalesce(nullif(trim(current_permanent_overseas_address_pin_code), ''), '')), '||||||')), '[[:space:]]+', ' '))) end),''),''))"
  PARTY_ROLE_BK__INSURED_MEMBER: "coalesce(nullif(trim(case when nullif(trim(w0_party_code),'') is not null then nullif(trim(w0_party_code), '') end),''),'') || '|' || coalesce(coalesce(nullif(trim(party_function), ''),''),'')"
  PARTY_ROLE_NK__INSURED_MEMBER: "'LNK_PARTY_ROLE|' || (coalesce(nullif(trim(case when nullif(trim(w0_party_code),'') is not null then nullif(trim(w0_party_code), '') end),''),'') || '|' || coalesce(coalesce(nullif(trim(party_function), ''),''),''))"
  PARTY_ROLE_ROLE: "coalesce(nullif(trim(party_function), ''),'')"
  QUOTE_BK: "nullif(trim(case when nullif(trim(w1_quotation_number),'') is not null then nullif(trim(w1_quotation_number), '') end),'')"
  QUOTE_NK: "'HUB_QUOTE|' || (nullif(trim(case when nullif(trim(w1_quotation_number),'') is not null then nullif(trim(w1_quotation_number), '') end),''))"
  ADDRESS_LINE_1: 'coalesce(correspondence_local_address_line_1, current_permanent_overseas_address_line_1)'
  ADDRESS_LINE_2: 'coalesce(correspondence_local_address_line_2, current_permanent_overseas_address_line_2)'
  ADDRESS_LINE_3: 'coalesce(correspondence_local_address_line_3, current_permanent_overseas_address_line_3)'
  ADDRESS_PROOF_TYPE: 'address_proof'
  ADDRESS_TYPE_CODE: 'cast(null as varchar)'
  ADDRESS_USAGE_TYPE: "coalesce(nullif(trim(current_permanent_overseas_address_type), ''),'')"
  AGE: 'age'
  ANNUAL_TURNOVER: 'annual_turnover'
  BUSINESS_REGISTRATION_NUMBER: 'company_no'
  CARE_OF_NAME: 'addressee'
  CATEGORY_CODE: 'category'
  CITY: 'coalesce(correspondence_local_address_city_town_village, current_permanent_overseas_address_city_town_village)'
  CKYC_REGISTRATION_STATUS: 'coalesce(ckyc_status, claim_ckyc_status)'
  CONSENT_GIVEN_INDICATOR: 'customer_consent'
  COUNTRY_CODE: 'cast(null as varchar)'
  COUNTRY_NAME: 'coalesce(correspondence_local_address_country, current_permanent_overseas_address_country)'
  COUNTRY_OF_BIRTH: 'country_of_birth'
  COUNTRY_OF_RESIDENCE: 'country_of_residence'
  CURRENT_MEDICATION_DETAIL: 'medicine_name'
  DATE_OF_BIRTH: 'date_of_birth'
  DATE_OF_INCORPORATION: 'cast(null as varchar)'
  DISABILITY_INDICATOR: 'physically_challenged'
  DISABILITY_PERCENTAGE: 'disability_percentage'
  DISTRICT: 'correspondence_local_address_district'
  EDUCATIONAL_QUALIFICATION: 'education'
  EMPLOYEE_CODE: 'staff_number'
  EMPLOYER_NAME: 'employer_name'
  FATHER_NAME: 'father_name'
  FIRST_NAME: 'cast(null as varchar)'
  GENDER_CODE: 'gender'
  GO_GREEN_OPT_IN_INDICATOR: 'issue_all_policies_in_electronic_format'
  HEIGHT: 'height'
  HIGHEST_DEGREE: 'cast(null as varchar)'
  INDUSTRY_CODE: 'industry_code'
  KYC_COMPLETION_DATE: 'kyc_timestamp'
  KYC_STATUS: 'kyc_verification'
  LANDMARK: 'cast(null as varchar)'
  LAST_NAME: 'cast(null as varchar)'
  LEGAL_CONSTITUTION_TYPE: 'constitution_of_business'
  LOCALITY: 'cast(null as varchar)'
  MARITAL_STATUS: 'marital_status'
  MIDDLE_NAME: 'cast(null as varchar)'
  MSME_CATEGORY: 'msme_classification'
  MSME_INDICATOR: 'msme_applicable'
  NATIONALITY: 'country_of_citizenship'
  NATURE_OF_BUSINESS: 'cast(null as varchar)'
  NEGATIVE_LIST_INDICATOR: 'blacklisted'
  NEGATIVE_LIST_REASON: 'coalesce(blacklist_details, reason_for_blacklisting)'
  NIC_CODE: 'cast(null as varchar)'
  OCCUPATION_CODE: 'cast(null as varchar)'
  OCCUPATION_DESCRIPTION: 'occupation'
  PAID_UP_CAPITAL: 'paid_up_capital'
  PARENT_ENTITY_NAME: 'coalesce(global_co_name, parent_co)'
  PARTY_FULL_NAME: 'cast(null as varchar)'
  PARTY_LEGAL_NAME: 'coalesce(company, legal_name_of_business)'
  PARTY_STATUS: 'cast(null as varchar)'
  PARTY_SUB_TYPE_CODE: 'cast(null as varchar)'
  PARTY_TYPE_CODE: 'cast(null as varchar)'
  POSTAL_CODE: 'coalesce(current_permanent_overseas_address_pin_code, local_address_pin_code)'
  POST_OFFICE_NAME: 'cast(null as varchar)'
  PREFERRED_CHANNEL_CODE: 'preferred_mode_of_communication'
  PREFERRED_LANGUAGE_CODE: 'coalesce(communication_and_preferred_language, languages_preferred)'
  PRE_EXISTING_DISEASE_DESCRIPTION: 'disease_name'
  PROFESSIONAL_REGISTRATION_NUMBER: 'certification_no'
  ROLE_CODE: "coalesce(nullif(trim(party_function), ''),'')"
  ROLE_SEQUENCE: "'1'"
  ROLE_TYPE: 'type_of_insured'
  SALUTATION: 'cast(null as varchar)'
  SCREENING_STATUS: 'coalesce(aml_verification_status, claim_aml_verification_status)'
  SEGMENT_NAME: 'profile'
  SMS_OPT_IN_INDICATOR: 'cast(null as varchar)'
  SPOUSE_NAME: 'spouse_name'
  STATE_CODE: 'cast(null as varchar)'
  STATE_NAME: 'coalesce(correspondence_local_address_state, current_permanent_overseas_address_state_ut)'
  STREET_NAME: 'cast(null as varchar)'
  TIER_CODE: 'prive_flag'
  VALUE_BAND: 'hni_flag'
  WEIGHT: 'weight'
  YEARS_IN_CITY: 'cast(null as varchar)'
  DATA_SHARING_CONSENT_INDICATOR: 'customer_consent_for_data_sharing'
  NEGATIVE_LIST_DATE: 'date_of_blacklisting'
  NON_DISCLOSURE_ACTION_INITIATED_INDICATOR: 'nondisclosure_initiated'
  CKYC_DETAILS_NARRATIVE: 'coalesce(ckyc_details, claim_ckyc_details)'
  CKYC_NUMBER_HELD_DECLARED_INDICATOR: 'do_you_have_ckyc_number'
  KYC_DETAILS_DESCRIPTION: 'kyc_details'
  KYC_DETAIL_DESCRIPTION: 'cast(null as varchar)'
  KYC_RELATED_DETAILS_DESCRIPTION: 'kyc_related_details'
  BUSINESS_REGISTRATION_DATE: 'date_of_registration'
  BUSINESS_TYPE_CODE: 'business_type'
  INFRASTRUCTURE_SUB_SECTOR: 'infrastructure_subsector'
  OTHER_INDUSTRY_TYPE_DESCRIPTION: 'cast(null as varchar)'
  REGISTERED_BUSINESS_TRUST_INDICATOR: 'is_the_organisation_a_registered_business_trust'
  REGISTERED_COMPANY_DECLARED_INDICATOR: 'are_you_registered_company'
  TRADE_NAME: 'trade_name'
  LOAD_DATETIME: 'REC_REFRESH_AT'
  RECORD_SOURCE: '!MAXIMUS_NONHLTH_TRV_UWR_VW_DATA_POLICY_DETAILS_INSURED_DETAILS_MEMBER_DETAILS_PARTY_PROPERTY_SIMPLE_PROPERTY_PIVOT_VW'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
