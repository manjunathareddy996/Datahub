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
  - 'DATEOFBIRTH'
  - 'DATEOFDEATH'
  - 'FIRSTNAME'
  - 'GENDERCODE'
  - 'LASTNAME'
  - 'MIDDLENAME'
  - 'NAMESUFFIX'
  - 'NATIONALITY'
  - 'PARTYDISPLAYNAME'
  - 'PARTYFULLNAME'
  - 'PARTYLEGALNAME'
  - 'PARTYSHORTNAME'
  - 'PARTYSTATUS'
  - 'PARTYTYPECODE'
  - 'PLACEOFBIRTH'
  - 'SALUTATION'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_extra_columns:
  - 'DBT_RUN_TS'
src_record_source_map:
  stg2_party_identity: 'OPUS'
  stg2_sat_bjaz_t_ckyc_personal_dtls__party_identity: 'OPUS'
  stg2_sat_bjaz_t_ckyc_rel_persion_dtls__party_identity__related_person: 'OPUS'
  stg2_sat_bjaz_t_ckyc_search__party_identity: 'OPUS'
  stg2_sat_bjaz_t_ekyc__party_identity: 'OPUS'
  stg2_sat_bjaz_t_kyc_auth__party_identity: 'OPUS'
  stg2_sat_bjaz_t_kyc_details__party_identity: 'OPUS'
  stg2_sat_bjaz_t_kyc_incoming__party_identity: 'OPUS'
  stg2_sat_bjaz_t_kyc_ocr__party_identity: 'OPUS'
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
                        'stg2_party_identity': ['AGE', 'DATEOFBIRTH', 'DATEOFDEATH', 'FIRSTNAME', 'GENDERCODE', 'LASTNAME', 'MIDDLENAME', 'NAMESUFFIX', 'NATIONALITY', 'PARTYDISPLAYNAME', 'PARTYFULLNAME', 'PARTYLEGALNAME', 'PARTYSHORTNAME', 'PARTYSTATUS', 'PARTYTYPECODE', 'PLACEOFBIRTH', 'SALUTATION'],
                        'stg2_sat_bjaz_t_ckyc_personal_dtls__party_identity': ['DATEOFBIRTH', 'FIRSTNAME', 'GENDERCODE', 'LASTNAME', 'MIDDLENAME', 'NATIONALITY', 'PARTYFULLNAME', 'PLACEOFBIRTH', 'SALUTATION'],
                        'stg2_sat_bjaz_t_ckyc_rel_persion_dtls__party_identity__related_person': ['FIRSTNAME', 'LASTNAME', 'MIDDLENAME', 'SALUTATION'],
                        'stg2_sat_bjaz_t_ckyc_search__party_identity': ['DATEOFBIRTH', 'GENDERCODE', 'PARTYFULLNAME'],
                        'stg2_sat_bjaz_t_ekyc__party_identity': ['DATEOFBIRTH', 'GENDERCODE', 'PARTYFULLNAME'],
                        'stg2_sat_bjaz_t_kyc_auth__party_identity': ['DATEOFBIRTH', 'GENDERCODE', 'PARTYFULLNAME'],
                        'stg2_sat_bjaz_t_kyc_details__party_identity': ['DATEOFBIRTH', 'PARTYDISPLAYNAME', 'PARTYFULLNAME'],
                        'stg2_sat_bjaz_t_kyc_incoming__party_identity': ['DATEOFBIRTH', 'GENDERCODE', 'PARTYFULLNAME', 'PARTYTYPECODE'],
                        'stg2_sat_bjaz_t_kyc_ocr__party_identity': ['DATEOFBIRTH', 'GENDERCODE', 'LASTNAME', 'NATIONALITY', 'PLACEOFBIRTH']
                    }) }}
