{{
    config(
        materialized='incremental',
        incremental_strategy='append',
    )
}}

-- PARTNER STANDARD-MODEL ma_sat() for SAT_PARTY_CONTACT_ADDRESS_LINK, per data_5a.js
-- (parent LNK_PARTY_LOCATION, childkey "Address Usage Type").
-- Payload gap, not an oversight: only Primary Address Indicator has real data among
-- this satellite's other 6 canonical attributes -- left unbuilt, not fabricated.
-- KYC: 2 KYC feed(s) added; converted automate_dv.ma_sat -> ma_sat_multi_source (same payload,
-- grain and hashdiff). Each KYC source supplies only its own columns via src_column_map.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_pcal_bjaz_cp_address_link'
  - 'stg2_sat_bjaz_t_ckyc_personal_dtls__party_contact_address_link__correspondence'
  - 'stg2_sat_bjaz_t_ckyc_personal_dtls__party_contact_address_link__permanent'
src_pk: 'PARTY_LOCATION_HKEY'
src_cdk:
  - 'ADDRESS_USAGE_TYPE'
src_payload:
  - 'PRIMARY_ADDRESS_INDICATOR'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_record_source_map:
  stg2_pcal_bjaz_cp_address_link: 'OPUS'
  stg2_sat_bjaz_t_ckyc_personal_dtls__party_contact_address_link__correspondence: 'OPUS'
  stg2_sat_bjaz_t_ckyc_personal_dtls__party_contact_address_link__permanent: 'OPUS'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ ma_sat_multi_source(src_pk=metadata_dict['src_pk'],
                       src_cdk=metadata_dict['src_cdk'],
                       src_payload=metadata_dict['src_payload'],
                       src_hashdiff=metadata_dict['src_hashdiff'],
                       src_ldts=metadata_dict['src_ldts'],
                       src_source=metadata_dict['src_source'],
                       source_model=metadata_dict['source_model'],
                       src_record_source_map=metadata_dict['src_record_source_map'],
                       src_column_map={
                           'stg2_pcal_bjaz_cp_address_link': ['PRIMARY_ADDRESS_INDICATOR'],
                           'stg2_sat_bjaz_t_ckyc_personal_dtls__party_contact_address_link__correspondence': [],
                           'stg2_sat_bjaz_t_ckyc_personal_dtls__party_contact_address_link__permanent': []
                       }) }}
