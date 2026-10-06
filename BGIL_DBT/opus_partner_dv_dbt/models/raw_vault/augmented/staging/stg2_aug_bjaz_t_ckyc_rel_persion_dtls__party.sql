{{ config(materialized='view') }}

-- KYC-SUBJECT PARTY KEY: BUILDER ASSUMPTION A1 (KEY_FORM_BUILDER_ASSUMED).
-- NOT RATIFIED BY ANYONE. This is the caller's decision to complete the build on a
-- documented assumption, and it is a DIFFERENT STANDING from the ten tables whose
-- form the mapping counterparty ratified (KEY_FORM_RATIFIED_SEMANTICS_UNVERIFIED).
--
-- WHAT: key HUB_PARTY on the centrally-issued CKYC number
-- EXPRESSION: nullif('CKYC:' || upper(trim(coalesce(ckyc_no,''))), 'CKYC:')
--
-- WHY: The CKYC number is a centrally-issued canonical KYC identifier and is the ONLY
-- party identifier either of these two tables declares; they carry no CATEGORY/INPUT, no
-- SEARCH_* and no FIELD_* pair.
--
-- RISK 1: A BLANK CKYC_NO is REJECTED by the nullif guard rather than keyed, so those
-- rows produce a NULL business key and AutomateDV will hash one bogus hub row per source
-- rather than silently merging them. Visible, not silent.
--
-- RISK 2: IF CKYC_NO IS NOT UNIQUE PER PARTY the hub OVER-MERGES: two different people
-- sharing a CKYC number become one party, and no check in this build can see it because
-- uniqueness is a property of the data, not of the schema.
--
-- RISK 3: These are the ONLY TWO TABLES IN THE PACK DECLARING NO PRIMARY KEY AT ALL
-- (build_profile.json ddl_profile.tables_with_no_resolvable_pk), so there is no row key
-- either: the satellite grain rests on the child key alone, and where no child key
-- resolves the unit stays refused rather than collapsing onto one row.
--
-- CONFIRM WITH: the source owner, on CKYC_NO's uniqueness per party.
-- ONE LINE TO OVERRULE: pkyc_party_key.ASSUMPTIONS_ENABLED['A1'] = False
--
-- ONE HUB, THREE KEY-SPACE PRODUCERS. HUB_PARTY is now keyed by the ratified
-- CATEGORY:INPUT form on 10 tables, by 'CKYC:<number>' under A1 on 2, and by
-- '<TYPE>:<number>' under A2 on 5. Whether a person reached through two of those routes
-- lands on ONE hub row depends entirely on whether CATEGORY's value vocabulary spells
-- the document type the same way A1 and A2 do -- which is the undetermined
-- identifier-versus-search-term question. If it does, the spaces coincide by design. If
-- it does not, the same person is two parties and nothing in this build can see it.
--
-- PARTNER+KYC AUGMENTED (unconfirmed) per-table stage() for HUB_PARTY, table 'BJAZ_T_CKYC_REL_PERSION_DTLS'.
-- 1 proposed attribute(s) from the mapper's Augmentation sheet, NOT in
-- data_7. Target(s) named by the map: SAT_COMMON_CONSENT, SAT_COMMON_CONTACT, SAT_LNK_PARTY_ROLE_CORE, SAT_PARTY_IDENTIFICATION, SAT_PARTY_IDENTITY, SAT_PARTY_INDIVIDUAL_DEMOGRAPHICS, SAT_PARTY_KYC, SAT_PARTY_KYC_REFERENCE.
--
-- Member names are UNDERSCORE(Proposed Attribute) -- the augmented track's own
-- convention, measured over the baseline's 147 decidable payload entries (141
-- follow it, 0 counterexamples). This is a CORRECTION to the profile's
-- 'raw source column verbatim'; see gen_pkyc_augmented's docstring.
--
-- Null-padded TO THE SATELLITE (51 of 52): CONSENT_PLACE, DOCUMENT_IMAGE_COUNT, ENTITY_LEGAL_FORM_OTHER_DESCRIPTION, FATHER_FIRST_NAME, FATHER_LAST_NAME, FATHER_MIDDLE_NAME, FATHER_NAME_SALUTATION, FATHER_OR_SPOUSE_NAME_TYPE_INDICATOR, IDENTIFICATION_APPLICATION_RECEIVED_DATE, IDENTIFICATION_APPLICATION_TYPE, IDENTIFICATION_ISSUING_COUNTRY, IDENTIFICATION_REGISTRY_LAST_UPDATED_DATE, IN_PERSON_VERIFICATION_INDICATOR, ISD_COUNTRY_CODE, KYC_DEACTIVATION_DATE, KYC_DEACTIVATION_REASON, KYC_VERSION, LOCAL_ADDRESS_RECORD_COUNT, MAIDEN_FIRST_NAME, MAIDEN_LAST_NAME, MAIDEN_MIDDLE_NAME, MAIDEN_NAME_SALUTATION, MOTHER_FIRST_NAME, MOTHER_LAST_NAME, MOTHER_MIDDLE_NAME, MOTHER_NAME_SALUTATION, PAN_HOLDER_CATEGORY, PERFORM_KYC_VERIFICATION_CONSENT_INDICATOR, RELATED_PERSON_COUNT, RELATIVE_OR_GUARDIAN_NAME, ROLE_DESCRIPTION_OTHERS, USE_POA_NAME_AS_POLICY_NAME_CONSENT_INDICATOR, USE_POI_NAME_AS_POLICY_NAME_CONSENT_INDICATOR, VERIFICATION_MATCH_SCORE, VERIFICATION_REQUESTED_NAME, VERIFICATION_RESPONSE_CODE, VERIFICATION_RESPONSE_DATE, VERIFICATION_RESPONSE_MESSAGE, VERIFICATION_RESULT_VALID_UNTIL_DATE, VERIFICATION_RETURNED_NAME, VERIFIED_AGE, VERIFIED_CITIZENSHIP, VERIFIED_DATE_OF_BIRTH, VERIFIED_FATHER_NAME, VERIFIED_FULL_NAME, VERIFIED_GENDER_CODE, VERIFIED_GIVEN_NAME, VERIFIED_LEGAL_NAME, VERIFIED_RELATIVE_NAME, VERIFIED_SURNAME, VERIFIED_TRADE_NAME.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_t_ckyc_rel_persion_dtls'
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
  PARENT_BK: "nullif('CKYC:' || upper(trim(coalesce(ckyc_no,''))), 'CKYC:')"
  PARENT_NK: "'HUB_PARTY|' || (nullif('CKYC:' || upper(trim(coalesce(ckyc_no,''))), 'CKYC:'))"
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
  KYC_DECLARATION_PLACE: 'dec_place'
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
  VERIFIED_DATE_OF_BIRTH: "cast(null as varchar)"
  VERIFIED_FATHER_NAME: "cast(null as varchar)"
  VERIFIED_FULL_NAME: "cast(null as varchar)"
  VERIFIED_GENDER_CODE: "cast(null as varchar)"
  VERIFIED_GIVEN_NAME: "cast(null as varchar)"
  VERIFIED_LEGAL_NAME: "cast(null as varchar)"
  VERIFIED_RELATIVE_NAME: "cast(null as varchar)"
  VERIFIED_SURNAME: "cast(null as varchar)"
  VERIFIED_TRADE_NAME: "cast(null as varchar)"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_BJAZ_T_CKYC_REL_PERSION_DTLS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
