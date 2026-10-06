{{
    config(
        materialized='incremental',
        incremental_strategy='append',
    )
}}

-- PARTNER STANDARD-MODEL sat() for SAT_PARTY_ORGANISATION_PROFILE (HUB_PARTY grain) -- stitch-backed, 5 table(s).
-- Source: stg2_party_organisation_profile.
-- KYC: 2 KYC feed(s) added; converted automate_dv.sat -> sat_multi_source (same payload,
-- grain and hashdiff). Each KYC source supplies only its own columns via src_column_map.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_party_organisation_profile'
  - 'stg2_sat_bjaz_m_kyc_gstn__party_organisation_profile'
  - 'stg2_sat_bjaz_t_ckyc_personal_dtls__party_organisation_profile'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'ANNUALTURNOVER'
  - 'DATEOFINCORPORATION'
  - 'GROUPNAME'
  - 'INDUSTRYDESCRIPTION'
  - 'LEGALCONSTITUTIONTYPE'
  - 'MSMEINDICATOR'
  - 'PAIDUPCAPITAL'
  - 'PARENTENTITYNAME'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_extra_columns:
  - 'DBT_RUN_TS'
src_record_source_map:
  stg2_party_organisation_profile: 'OPUS'
  stg2_sat_bjaz_m_kyc_gstn__party_organisation_profile: 'OPUS'
  stg2_sat_bjaz_t_ckyc_personal_dtls__party_organisation_profile: 'OPUS'
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
                        'stg2_party_organisation_profile': ['ANNUALTURNOVER', 'DATEOFINCORPORATION', 'GROUPNAME', 'INDUSTRYDESCRIPTION', 'LEGALCONSTITUTIONTYPE', 'MSMEINDICATOR', 'PAIDUPCAPITAL', 'PARENTENTITYNAME'],
                        'stg2_sat_bjaz_m_kyc_gstn__party_organisation_profile': ['LEGALCONSTITUTIONTYPE'],
                        'stg2_sat_bjaz_t_ckyc_personal_dtls__party_organisation_profile': []
                    }) }}
