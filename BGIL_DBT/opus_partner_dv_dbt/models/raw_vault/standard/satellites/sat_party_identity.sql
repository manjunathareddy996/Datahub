{{
    config(
        materialized='incremental',
        incremental_strategy='append',
    )
}}

-- PARTNER STANDARD-MODEL sat() for SAT_PARTY_IDENTITY (HUB_PARTY grain) -- stitch-backed, 22 table(s).
-- Source: stg2_party_identity.
-- KYC: 8 KYC feeds added; converted automate_dv.sat -> sat_multi_source (same payload,
-- grain and hashdiff). Each KYC source supplies only its columns via src_column_map.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_party_identity'
  - 'stg2_sat_bjaz_t_ckyc_personal_dtls__party_identity'
  - 'stg2_sat_bjaz_t_ckyc_rel_persion_dtls__party_identity__related_person'
  - 'stg2_sat_bjaz_t_ckyc_search__party_identity'
  - 'stg2_sat_bjaz_t_ekyc__party_identity'
  - 'stg2_sat_bjaz_t_kyc_auth__party_identity'
  - 'stg2_sat_bjaz_t_kyc_details__party_identity'
  - 'stg2_sat_bjaz_t_kyc_incoming__party_identity'
  - 'stg2_sat_bjaz_t_kyc_ocr__party_identity'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'AGE'
  - 'DATE_OF_BIRTH'
  - 'DATE_OF_DEATH'
  - 'FIRST_NAME'
  - 'GENDER_CODE'
  - 'LAST_NAME'
  - 'MIDDLE_NAME'
  - 'NAME_SUFFIX'
  - 'NATIONALITY'
  - 'PARTY_DISPLAY_NAME'
  - 'PARTY_FULL_NAME'
  - 'PARTY_LEGAL_NAME'
  - 'PARTYSHORTNAME'
  - 'PARTY_STATUS'
  - 'PARTY_TYPE_CODE'
  - 'PLACEOFBIRTH'
  - 'SALUTATION'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_extra_columns:
  - 'DBT_RUN_TS'
src_record_source_map:
  stg2_party_identity: 'OPUS_PARTNER'
  stg2_sat_bjaz_t_ckyc_personal_dtls__party_identity: 'OPUS_PARTNER'
  stg2_sat_bjaz_t_ckyc_rel_persion_dtls__party_identity__related_person: 'OPUS_PARTNER'
  stg2_sat_bjaz_t_ckyc_search__party_identity: 'OPUS_PARTNER'
  stg2_sat_bjaz_t_ekyc__party_identity: 'OPUS_PARTNER'
  stg2_sat_bjaz_t_kyc_auth__party_identity: 'OPUS_PARTNER'
  stg2_sat_bjaz_t_kyc_details__party_identity: 'OPUS_PARTNER'
  stg2_sat_bjaz_t_kyc_incoming__party_identity: 'OPUS_PARTNER'
  stg2_sat_bjaz_t_kyc_ocr__party_identity: 'OPUS_PARTNER'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ sat_multi_source(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_extra_columns=metadata_dict['src_extra_columns'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model'],
                    src_record_source_map=metadata_dict['src_record_source_map'],
                    src_column_map={
                        'stg2_party_identity': ['AGE', 'DATE_OF_BIRTH', 'DATE_OF_DEATH', 'FIRST_NAME', 'GENDER_CODE', 'LAST_NAME', 'MIDDLE_NAME', 'NAME_SUFFIX', 'NATIONALITY', 'PARTY_DISPLAY_NAME', 'PARTY_FULL_NAME', 'PARTY_LEGAL_NAME', 'PARTYSHORTNAME', 'PARTY_STATUS', 'PARTY_TYPE_CODE', 'PLACEOFBIRTH', 'SALUTATION'],
                        'stg2_sat_bjaz_t_ckyc_personal_dtls__party_identity': ['DATE_OF_BIRTH', 'FIRST_NAME', 'GENDER_CODE', 'LAST_NAME', 'MIDDLE_NAME', 'NATIONALITY', 'PARTY_FULL_NAME', 'PLACEOFBIRTH', 'SALUTATION'],
                        'stg2_sat_bjaz_t_ckyc_rel_persion_dtls__party_identity__related_person': ['FIRST_NAME', 'LAST_NAME', 'MIDDLE_NAME', 'SALUTATION'],
                        'stg2_sat_bjaz_t_ckyc_search__party_identity': ['DATE_OF_BIRTH', 'GENDER_CODE', 'PARTY_FULL_NAME'],
                        'stg2_sat_bjaz_t_ekyc__party_identity': ['DATE_OF_BIRTH', 'GENDER_CODE', 'PARTY_FULL_NAME'],
                        'stg2_sat_bjaz_t_kyc_auth__party_identity': ['DATE_OF_BIRTH', 'GENDER_CODE', 'PARTY_FULL_NAME'],
                        'stg2_sat_bjaz_t_kyc_details__party_identity': ['DATE_OF_BIRTH', 'PARTY_DISPLAY_NAME', 'PARTY_FULL_NAME'],
                        'stg2_sat_bjaz_t_kyc_incoming__party_identity': ['DATE_OF_BIRTH', 'GENDER_CODE', 'PARTY_FULL_NAME', 'PARTY_TYPE_CODE'],
                        'stg2_sat_bjaz_t_kyc_ocr__party_identity': ['DATE_OF_BIRTH', 'GENDER_CODE', 'LAST_NAME', 'NATIONALITY', 'PLACEOFBIRTH']
                    }) }}
