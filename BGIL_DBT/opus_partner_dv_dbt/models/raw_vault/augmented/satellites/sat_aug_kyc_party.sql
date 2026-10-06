{{
    config(
        materialized='incremental',
        incremental_strategy='append',
    )
}}

-- PARTNER+KYC AUGMENTED (unconfirmed) sat_multi_source() for SAT_AUG_KYC_PARTY (HUB_PARTY grain).
-- 13 contributing table(s). LOB-local satellite for mapper-proposed attributes that are
-- NOT in data_7 -- needs mapper review before being treated as equivalent to a
-- standard-model satellite.
-- Map target(s): SAT_COMMON_CONSENT, SAT_COMMON_CONTACT, SAT_LNK_PARTY_ROLE_CORE, SAT_PARTY_IDENTIFICATION,
-- SAT_PARTY_IDENTITY, SAT_PARTY_INDIVIDUAL_DEMOGRAPHICS, SAT_PARTY_KYC, SAT_PARTY_KYC_REFERENCE.
-- Kept separate from sat_aug_party so its hashdiff is not re-chained.
-- Payload is the 52 columns from partner_kyc_opus_latest, unchanged. source_model lists each
-- stage once (latest listed some stages more than once). Each source supplies only the
-- columns in src_column_map; the macro pads the rest with NULL.
-- KNOWN GAP (from latest, not changed here): 26 payload columns are built by no source
-- stage and stay NULL until the KYC build regenerates those feeds.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_aug_bjaz_m_kyc_driving_licence__party'
  - 'stg2_aug_bjaz_m_kyc_gstn__party'
  - 'stg2_aug_bjaz_m_kyc_pan__party'
  - 'stg2_aug_bjaz_m_kyc_passport__party'
  - 'stg2_aug_bjaz_m_kyc_voter__party'
  - 'stg2_aug_bjaz_t_ckyc_personal_dtls__party'
  - 'stg2_aug_bjaz_t_ckyc_rel_persion_dtls__party'
  - 'stg2_aug_bjaz_t_ckyc_search__party'
  - 'stg2_aug_bjaz_t_ekyc__party'
  - 'stg2_aug_bjaz_t_kyc_auth__party'
  - 'stg2_aug_bjaz_t_kyc_details__party'
  - 'stg2_aug_bjaz_t_kyc_name_match__party'
  - 'stg2_aug_bjaz_t_kyc_ocr__party'
src_pk: 'PARTY_HKEY'
src_payload:
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
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_record_source_map:
  stg2_aug_bjaz_m_kyc_driving_licence__party: 'OPUS'
  stg2_aug_bjaz_m_kyc_gstn__party: 'OPUS'
  stg2_aug_bjaz_m_kyc_pan__party: 'OPUS'
  stg2_aug_bjaz_m_kyc_passport__party: 'OPUS'
  stg2_aug_bjaz_m_kyc_voter__party: 'OPUS'
  stg2_aug_bjaz_t_ckyc_personal_dtls__party: 'OPUS'
  stg2_aug_bjaz_t_ckyc_rel_persion_dtls__party: 'OPUS'
  stg2_aug_bjaz_t_ckyc_search__party: 'OPUS'
  stg2_aug_bjaz_t_ekyc__party: 'OPUS'
  stg2_aug_bjaz_t_kyc_auth__party: 'OPUS'
  stg2_aug_bjaz_t_kyc_details__party: 'OPUS'
  stg2_aug_bjaz_t_kyc_name_match__party: 'OPUS'
  stg2_aug_bjaz_t_kyc_ocr__party: 'OPUS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ sat_multi_source(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model'],
                    src_record_source_map=metadata_dict['src_record_source_map'],
                    src_column_map={
                        'stg2_aug_bjaz_m_kyc_driving_licence__party': ['VERIFICATION_RESULT_VALID_UNTIL_DATE', 'VERIFIED_CITIZENSHIP', 'VERIFIED_DATE_OF_BIRTH', 'VERIFIED_FATHER_NAME', 'VERIFIED_FULL_NAME', 'VERIFIED_GENDER_CODE'],
                        'stg2_aug_bjaz_m_kyc_gstn__party': ['VERIFICATION_RESULT_VALID_UNTIL_DATE', 'VERIFIED_LEGAL_NAME', 'VERIFIED_TRADE_NAME'],
                        'stg2_aug_bjaz_m_kyc_pan__party': ['VERIFICATION_RESULT_VALID_UNTIL_DATE', 'VERIFIED_FULL_NAME'],
                        'stg2_aug_bjaz_m_kyc_passport__party': ['VERIFICATION_RESULT_VALID_UNTIL_DATE', 'VERIFIED_DATE_OF_BIRTH', 'VERIFIED_FULL_NAME', 'VERIFIED_GIVEN_NAME', 'VERIFIED_SURNAME'],
                        'stg2_aug_bjaz_m_kyc_voter__party': ['VERIFICATION_RESULT_VALID_UNTIL_DATE', 'VERIFIED_AGE', 'VERIFIED_FULL_NAME', 'VERIFIED_GENDER_CODE', 'VERIFIED_RELATIVE_NAME'],
                        'stg2_aug_bjaz_t_ckyc_personal_dtls__party': ['DOCUMENT_IMAGE_COUNT', 'IN_PERSON_VERIFICATION_INDICATOR', 'LOCAL_ADDRESS_RECORD_COUNT', 'RELATED_PERSON_COUNT'],
                        'stg2_aug_bjaz_t_ckyc_rel_persion_dtls__party': ['KYC_DECLARATION_PLACE'],
                        'stg2_aug_bjaz_t_ckyc_search__party': ['VERIFICATION_RESPONSE_CODE', 'VERIFICATION_RESPONSE_MESSAGE', 'VERIFIED_AGE', 'VERIFIED_DATE_OF_BIRTH', 'VERIFIED_FATHER_NAME', 'VERIFIED_FULL_NAME', 'VERIFIED_GENDER_CODE'],
                        'stg2_aug_bjaz_t_ekyc__party': ['VERIFICATION_RESPONSE_CODE', 'VERIFICATION_RESPONSE_MESSAGE', 'VERIFIED_DATE_OF_BIRTH', 'VERIFIED_FULL_NAME', 'VERIFIED_GENDER_CODE'],
                        'stg2_aug_bjaz_t_kyc_auth__party': ['VERIFICATION_RESPONSE_CODE', 'VERIFICATION_RESPONSE_MESSAGE', 'VERIFIED_DATE_OF_BIRTH', 'VERIFIED_FATHER_NAME', 'VERIFIED_FULL_NAME', 'VERIFIED_GENDER_CODE'],
                        'stg2_aug_bjaz_t_kyc_details__party': ['VERIFIED_DATE_OF_BIRTH', 'VERIFIED_FULL_NAME'],
                        'stg2_aug_bjaz_t_kyc_name_match__party': ['VERIFICATION_MATCH_SCORE', 'VERIFICATION_REQUESTED_NAME', 'VERIFICATION_RESPONSE_DATE', 'VERIFICATION_RETURNED_NAME'],
                        'stg2_aug_bjaz_t_kyc_ocr__party': ['PERFORM_KYC_VERIFICATION_CONSENT_INDICATOR', 'USE_POA_NAME_AS_POLICY_NAME_CONSENT_INDICATOR', 'USE_POI_NAME_AS_POLICY_NAME_CONSENT_INDICATOR']
                    }) }}
