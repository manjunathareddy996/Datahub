{{ config(materialized='view') }}

-- KYC-SUBJECT PARTY KEY: BUILDER ASSUMPTION A2 (KEY_FORM_BUILDER_ASSUMED).
-- NOT RATIFIED BY ANYONE. This is the caller's decision to complete the build on a
-- documented assumption, and it is a DIFFERENT STANDING from the ten tables whose
-- form the mapping counterparty ratified (KEY_FORM_RATIFIED_SEMANTICS_UNVERIFIED).
--
-- WHAT: key HUB_PARTY on the CREDENTIAL HOLDER, dropping the AUTH_ID requester walk
-- EXPRESSION: nullif('LICENCE:' || upper(trim(coalesce(licence_number,''))), 'LICENCE:')
--
-- WHY: The facts these satellites carry -- Verified Trade Name, Verified Legal Name,
-- verification status -- describe the HOLDER of the credential, not whoever submitted
-- the request; keying them to the requester would attribute a third party's verified
-- identity to the requester, which is the worse of the two errors.
--
-- RISK 1: ON BJAZ_M_KYC_GSTN A GSTIN BELONGS TO AN ORGANISATION, so those rows key an
-- ORGANISATION into HUB_PARTY alongside individuals. That is correct under this
-- assumption and it WIDENS the existing registry-mixing risk on this hub. Said out loud
-- rather than left to pass silently.
--
-- RISK 2: THE TYPE LITERAL IS DERIVED FROM THE COLUMN PREFIX ('LICENCE', not
-- 'DRIVING_LICENCE'). If the enterprise document-type vocabulary spells it differently,
-- these keys live in a DIFFERENT KEY SPACE from any other producer of the same
-- credential and the two never join -- an orphan that compiles.
--
-- RISK 3: The AUTH_ID walk the map declares is DROPPED, so any fact that genuinely
-- belongs to the requester is now attributed to the holder. The conflation is not
-- removed, it is RESOLVED IN ONE DIRECTION.
--
-- CONFIRM WITH: the modeller, on which party the master's key identifies; and the source owner on the document-type vocabulary.
-- ONE LINE TO OVERRULE: pkyc_party_key.ASSUMPTIONS_ENABLED['A2'] = False
--
-- ONE HUB, THREE KEY-SPACE PRODUCERS. HUB_PARTY is now keyed by the ratified
-- CATEGORY:INPUT form on 10 tables, by 'CKYC:<number>' under A1 on 2, and by
-- '<TYPE>:<number>' under A2 on 5. Whether a person reached through two of those routes
-- lands on ONE hub row depends entirely on whether CATEGORY's value vocabulary spells
-- the document type the same way A1 and A2 do -- which is the undetermined
-- identifier-versus-search-term question. If it does, the spaces coincide by design. If
-- it does not, the same person is two parties and nothing in this build can see it.
--
-- PARTNER+KYC AUGMENTED (unconfirmed) per-table stage() for HUB_PARTY, table 'BJAZ_M_KYC_DRIVING_LICENCE'.
-- 6 proposed attribute(s) from the mapper's Augmentation sheet, NOT in
-- data_7. Target(s) named by the map: SAT_COMMON_CONSENT, SAT_COMMON_CONTACT, SAT_LNK_PARTY_ROLE_CORE, SAT_PARTY_IDENTIFICATION, SAT_PARTY_IDENTITY, SAT_PARTY_INDIVIDUAL_DEMOGRAPHICS, SAT_PARTY_KYC, SAT_PARTY_KYC_REFERENCE.
--
-- Member names are UNDERSCORE(Proposed Attribute) -- the augmented track's own
-- convention, measured over the baseline's 147 decidable payload entries (141
-- follow it, 0 counterexamples). This is a CORRECTION to the profile's
-- 'raw source column verbatim'; see gen_pkyc_augmented's docstring.
--
-- Null-padded TO THE SATELLITE (46 of 52): CONSENT_PLACE, DOCUMENT_IMAGE_COUNT, ENTITY_LEGAL_FORM_OTHER_DESCRIPTION, FATHER_FIRST_NAME, FATHER_LAST_NAME, FATHER_MIDDLE_NAME, FATHER_NAME_SALUTATION, FATHER_OR_SPOUSE_NAME_TYPE_INDICATOR, IDENTIFICATION_APPLICATION_RECEIVED_DATE, IDENTIFICATION_APPLICATION_TYPE, IDENTIFICATION_ISSUING_COUNTRY, IDENTIFICATION_REGISTRY_LAST_UPDATED_DATE, IN_PERSON_VERIFICATION_INDICATOR, ISD_COUNTRY_CODE, KYC_DEACTIVATION_DATE, KYC_DEACTIVATION_REASON, KYC_DECLARATION_PLACE, KYC_VERSION, LOCAL_ADDRESS_RECORD_COUNT, MAIDEN_FIRST_NAME, MAIDEN_LAST_NAME, MAIDEN_MIDDLE_NAME, MAIDEN_NAME_SALUTATION, MOTHER_FIRST_NAME, MOTHER_LAST_NAME, MOTHER_MIDDLE_NAME, MOTHER_NAME_SALUTATION, PAN_HOLDER_CATEGORY, PERFORM_KYC_VERIFICATION_CONSENT_INDICATOR, RELATED_PERSON_COUNT, RELATIVE_OR_GUARDIAN_NAME, ROLE_DESCRIPTION_OTHERS, USE_POA_NAME_AS_POLICY_NAME_CONSENT_INDICATOR, USE_POI_NAME_AS_POLICY_NAME_CONSENT_INDICATOR, VERIFICATION_MATCH_SCORE, VERIFICATION_REQUESTED_NAME, VERIFICATION_RESPONSE_CODE, VERIFICATION_RESPONSE_DATE, VERIFICATION_RESPONSE_MESSAGE, VERIFICATION_RETURNED_NAME, VERIFIED_AGE, VERIFIED_GIVEN_NAME, VERIFIED_LEGAL_NAME, VERIFIED_RELATIVE_NAME, VERIFIED_SURNAME, VERIFIED_TRADE_NAME.

{%- set yaml_metadata -%}
source_model: 'stg_partner__bjaz_m_kyc_driving_licence'
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
  PARENT_BK: "nullif('LICENCE:' || upper(trim(coalesce(licence_number,''))), 'LICENCE:')"
  PARENT_NK: "'HUB_PARTY|' || (nullif('LICENCE:' || upper(trim(coalesce(licence_number,''))), 'LICENCE:'))"
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
  VERIFICATION_RESULT_VALID_UNTIL_DATE: 'expiry_date'
  VERIFICATION_RETURNED_NAME: "cast(null as varchar)"
  VERIFIED_AGE: "cast(null as varchar)"
  VERIFIED_CITIZENSHIP: 'citizenship'
  VERIFIED_DATE_OF_BIRTH: 'dob'
  VERIFIED_FATHER_NAME: 'father_name'
  VERIFIED_FULL_NAME: 'name'
  VERIFIED_GENDER_CODE: 'gender'
  VERIFIED_GIVEN_NAME: "cast(null as varchar)"
  VERIFIED_LEGAL_NAME: "cast(null as varchar)"
  VERIFIED_RELATIVE_NAME: "cast(null as varchar)"
  VERIFIED_SURNAME: "cast(null as varchar)"
  VERIFIED_TRADE_NAME: "cast(null as varchar)"
  LOAD_DATETIME: 'INC_JOB_UPDATED_AT'
  RECORD_SOURCE: '!OPUS_BJAZ_M_KYC_DRIVING_LICENCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=false,
                      source_model=metadata_dict['source_model'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      derived_columns=metadata_dict['derived_columns']) }}
