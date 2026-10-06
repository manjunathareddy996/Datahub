{{ config(materialized='view') }}

-- KYC-SUBJECT PARTY KEY: FORM RATIFIED, SEMANTICS UNVERIFIED (KEY_FORM_RATIFIED_SEMANTICS_UNVERIFIED).
-- Operands on this table: CATEGORY / INPUT, selected by the ratified rule -- first COMPLETE pair
-- of (CATEGORY, INPUT), (SEARCH_CATEGORY, SEARCH_INPUT), (FIELD_TYPE, FIELD_VALUE).
-- Re-derived from the source DDL and asserted against the ratified table pair for pair;
-- a disagreement fails the build. Authority: ratified by the mapping counterparty on its caller's authority; re-derived from inputs/KYC_Tables_source_ddl.xlsx and asserted against the counterparty's table pair for pair at import time.
--
-- THE nullif(..., ':') GUARD IS PART OF THE KEY, NOT DECORATION. Without it an all-blank
-- row reduces to the bare constant ':' and every such row keys to ONE party.
--
-- UNDETERMINED, AND SETTLEABLE ONLY BY THE SOURCE OWNER: is this pair an identifier TYPE
-- and VALUE, or a record of what was SEARCHED FOR? If the latter, keying HUB_PARTY on it
-- MERGES EVERY PARTY EVER SEARCHED BY THE SAME VALUE. Built as mapped and raised (5.7).
-- BJAZ_T_KYC_INCOMING IS THE ROW TO CHANGE FIRST: it is the request root and its
-- SEARCH_CATEGORY is VARCHAR2(2) against CATEGORY's 10 or 20, so a two-character category
-- reads more like a search-type flag than an identifier type. Refusing the request root
-- would strand the 8 tables that foreign-key to INCOMING_ID, so it is built.
-- One line to switch this table off: pkyc_party_key.ENABLED['BJAZ_T_KYC_DETAILS'] = False.
--
-- PARTNER+KYC AUGMENTED (unconfirmed) per-table stage() for HUB_PARTY, table 'BJAZ_T_KYC_DETAILS'.
-- 2 proposed attribute(s) from the mapper's Augmentation sheet, NOT in
-- data_7. Target(s) named by the map: SAT_COMMON_CONSENT, SAT_COMMON_CONTACT, SAT_LNK_PARTY_ROLE_CORE, SAT_PARTY_IDENTIFICATION, SAT_PARTY_IDENTITY, SAT_PARTY_INDIVIDUAL_DEMOGRAPHICS, SAT_PARTY_KYC, SAT_PARTY_KYC_REFERENCE.
--
-- Member names are UNDERSCORE(Proposed Attribute) -- the augmented track's own
-- convention, measured over the baseline's 147 decidable payload entries (141
-- follow it, 0 counterexamples). This is a CORRECTION to the profile's
-- 'raw source column verbatim'; see gen_pkyc_augmented's docstring.
--
-- Null-padded TO THE SATELLITE (50 of 52): CONSENT_PLACE, DOCUMENT_IMAGE_COUNT, ENTITY_LEGAL_FORM_OTHER_DESCRIPTION, FATHER_FIRST_NAME, FATHER_LAST_NAME, FATHER_MIDDLE_NAME, FATHER_NAME_SALUTATION, FATHER_OR_SPOUSE_NAME_TYPE_INDICATOR, IDENTIFICATION_APPLICATION_RECEIVED_DATE, IDENTIFICATION_APPLICATION_TYPE, IDENTIFICATION_ISSUING_COUNTRY, IDENTIFICATION_REGISTRY_LAST_UPDATED_DATE, IN_PERSON_VERIFICATION_INDICATOR, ISD_COUNTRY_CODE, KYC_DEACTIVATION_DATE, KYC_DEACTIVATION_REASON, KYC_DECLARATION_PLACE, KYC_VERSION, LOCAL_ADDRESS_RECORD_COUNT, MAIDEN_FIRST_NAME, MAIDEN_LAST_NAME, MAIDEN_MIDDLE_NAME, MAIDEN_NAME_SALUTATION, MOTHER_FIRST_NAME, MOTHER_LAST_NAME, MOTHER_MIDDLE_NAME, MOTHER_NAME_SALUTATION, PAN_HOLDER_CATEGORY, PERFORM_KYC_VERIFICATION_CONSENT_INDICATOR, RELATED_PERSON_COUNT, RELATIVE_OR_GUARDIAN_NAME, ROLE_DESCRIPTION_OTHERS, USE_POA_NAME_AS_POLICY_NAME_CONSENT_INDICATOR, USE_POI_NAME_AS_POLICY_NAME_CONSENT_INDICATOR, VERIFICATION_MATCH_SCORE, VERIFICATION_REQUESTED_NAME, VERIFICATION_RESPONSE_CODE, VERIFICATION_RESPONSE_DATE, VERIFICATION_RESPONSE_MESSAGE, VERIFICATION_RESULT_VALID_UNTIL_DATE, VERIFICATION_RETURNED_NAME, VERIFIED_AGE, VERIFIED_CITIZENSHIP, VERIFIED_FATHER_NAME, VERIFIED_GENDER_CODE, VERIFIED_GIVEN_NAME, VERIFIED_LEGAL_NAME, VERIFIED_RELATIVE_NAME, VERIFIED_SURNAME, VERIFIED_TRADE_NAME.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_t_kyc_details'
hashed_columns:
  PARTY_HKEY: 'PARENT_NK'
  HASHDIFF:
    is_hashdiff: true
    columns:
      - 'CONSENT_PLACE'
      - 'DOCUMENT_IMAGE_COUNT'
      - 'ENTITY_LEGAL_FORM_OTHER_DESCRIPTION'
      - 'FATHER_FIRST_NAME'
      - 'FATHER_LAST_NAME'
      - 'FATHER_MIDDLE_NAME'
      - 'FATHER_NAME_SALUTATION'
      - 'FATHER_OR_SPOUSE_NAME_TYPE_INDICATOR'
      - 'IDENTIFICATION_APPLICATION_RECEIVED_DATE'
      - 'IDENTIFICATION_APPLICATION_TYPE'
      - 'IDENTIFICATION_ISSUING_COUNTRY'
      - 'IDENTIFICATION_REGISTRY_LAST_UPDATED_DATE'
      - 'IN_PERSON_VERIFICATION_INDICATOR'
      - 'ISD_COUNTRY_CODE'
      - 'KYC_DEACTIVATION_DATE'
      - 'KYC_DEACTIVATION_REASON'
      - 'KYC_DECLARATION_PLACE'
      - 'KYC_VERSION'
      - 'LOCAL_ADDRESS_RECORD_COUNT'
      - 'MAIDEN_FIRST_NAME'
      - 'MAIDEN_LAST_NAME'
      - 'MAIDEN_MIDDLE_NAME'
      - 'MAIDEN_NAME_SALUTATION'
      - 'MOTHER_FIRST_NAME'
      - 'MOTHER_LAST_NAME'
      - 'MOTHER_MIDDLE_NAME'
      - 'MOTHER_NAME_SALUTATION'
      - 'PAN_HOLDER_CATEGORY'
      - 'PERFORM_KYC_VERIFICATION_CONSENT_INDICATOR'
      - 'RELATED_PERSON_COUNT'
      - 'RELATIVE_OR_GUARDIAN_NAME'
      - 'ROLE_DESCRIPTION_OTHERS'
      - 'USE_POA_NAME_AS_POLICY_NAME_CONSENT_INDICATOR'
      - 'USE_POI_NAME_AS_POLICY_NAME_CONSENT_INDICATOR'
      - 'VERIFICATION_MATCH_SCORE'
      - 'VERIFICATION_REQUESTED_NAME'
      - 'VERIFICATION_RESPONSE_CODE'
      - 'VERIFICATION_RESPONSE_DATE'
      - 'VERIFICATION_RESPONSE_MESSAGE'
      - 'VERIFICATION_RESULT_VALID_UNTIL_DATE'
      - 'VERIFICATION_RETURNED_NAME'
      - 'VERIFIED_AGE'
      - 'VERIFIED_CITIZENSHIP'
      - 'VERIFIED_DATE_OF_BIRTH'
      - 'VERIFIED_FATHER_NAME'
      - 'VERIFIED_FULL_NAME'
      - 'VERIFIED_GENDER_CODE'
      - 'VERIFIED_GIVEN_NAME'
      - 'VERIFIED_LEGAL_NAME'
      - 'VERIFIED_RELATIVE_NAME'
      - 'VERIFIED_SURNAME'
      - 'VERIFIED_TRADE_NAME'
derived_columns:
  PARENT_BK: "nullif(upper(trim(coalesce(category,''))) || ':' || upper(trim(coalesce(input,''))), ':')"
  PARENT_NK: "'HUB_PARTY|' || (nullif(upper(trim(coalesce(category,''))) || ':' || upper(trim(coalesce(input,''))), ':'))"
  CONSENT_PLACE: "cast(null as varchar)"
  DOCUMENT_IMAGE_COUNT: "cast(null as varchar)"
  ENTITY_LEGAL_FORM_OTHER_DESCRIPTION: "cast(null as varchar)"
  FATHER_FIRST_NAME: "cast(null as varchar)"
  FATHER_LAST_NAME: "cast(null as varchar)"
  FATHER_MIDDLE_NAME: "cast(null as varchar)"
  FATHER_NAME_SALUTATION: "cast(null as varchar)"
  FATHER_OR_SPOUSE_NAME_TYPE_INDICATOR: "cast(null as varchar)"
  IDENTIFICATION_APPLICATION_RECEIVED_DATE: "cast(null as varchar)"
  IDENTIFICATION_APPLICATION_TYPE: "cast(null as varchar)"
  IDENTIFICATION_ISSUING_COUNTRY: "cast(null as varchar)"
  IDENTIFICATION_REGISTRY_LAST_UPDATED_DATE: "cast(null as varchar)"
  IN_PERSON_VERIFICATION_INDICATOR: "cast(null as varchar)"
  ISD_COUNTRY_CODE: "cast(null as varchar)"
  KYC_DEACTIVATION_DATE: "cast(null as varchar)"
  KYC_DEACTIVATION_REASON: "cast(null as varchar)"
  KYC_DECLARATION_PLACE: "cast(null as varchar)"
  KYC_VERSION: "cast(null as varchar)"
  LOCAL_ADDRESS_RECORD_COUNT: "cast(null as varchar)"
  MAIDEN_FIRST_NAME: "cast(null as varchar)"
  MAIDEN_LAST_NAME: "cast(null as varchar)"
  MAIDEN_MIDDLE_NAME: "cast(null as varchar)"
  MAIDEN_NAME_SALUTATION: "cast(null as varchar)"
  MOTHER_FIRST_NAME: "cast(null as varchar)"
  MOTHER_LAST_NAME: "cast(null as varchar)"
  MOTHER_MIDDLE_NAME: "cast(null as varchar)"
  MOTHER_NAME_SALUTATION: "cast(null as varchar)"
  PAN_HOLDER_CATEGORY: "cast(null as varchar)"
  PERFORM_KYC_VERIFICATION_CONSENT_INDICATOR: "cast(null as varchar)"
  RELATED_PERSON_COUNT: "cast(null as varchar)"
  RELATIVE_OR_GUARDIAN_NAME: "cast(null as varchar)"
  ROLE_DESCRIPTION_OTHERS: "cast(null as varchar)"
  USE_POA_NAME_AS_POLICY_NAME_CONSENT_INDICATOR: "cast(null as varchar)"
  USE_POI_NAME_AS_POLICY_NAME_CONSENT_INDICATOR: "cast(null as varchar)"
  VERIFICATION_MATCH_SCORE: "cast(null as varchar)"
  VERIFICATION_REQUESTED_NAME: "cast(null as varchar)"
  VERIFICATION_RESPONSE_CODE: "cast(null as varchar)"
  VERIFICATION_RESPONSE_DATE: "cast(null as varchar)"
  VERIFICATION_RESPONSE_MESSAGE: "cast(null as varchar)"
  VERIFICATION_RESULT_VALID_UNTIL_DATE: "cast(null as varchar)"
  VERIFICATION_RETURNED_NAME: "cast(null as varchar)"
  VERIFIED_AGE: "cast(null as varchar)"
  VERIFIED_CITIZENSHIP: "cast(null as varchar)"
  VERIFIED_DATE_OF_BIRTH: 'response_dob'
  VERIFIED_FATHER_NAME: "cast(null as varchar)"
  VERIFIED_FULL_NAME: 'poi_response_full_name'
  VERIFIED_GENDER_CODE: "cast(null as varchar)"
  VERIFIED_GIVEN_NAME: "cast(null as varchar)"
  VERIFIED_LEGAL_NAME: "cast(null as varchar)"
  VERIFIED_RELATIVE_NAME: "cast(null as varchar)"
  VERIFIED_SURNAME: "cast(null as varchar)"
  VERIFIED_TRADE_NAME: "cast(null as varchar)"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_BJAZ_T_KYC_DETAILS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
