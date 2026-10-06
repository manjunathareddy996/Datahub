{{
    config(
        materialized='incremental',
        incremental_strategy='append',
    )
}}

-- PARTNER STANDARD-MODEL sat() for SAT_PARTY_KYC_REFERENCE (HUB_PARTY grain) -- single source.
-- KYC: 3 KYC feeds added; converted automate_dv.sat -> sat_multi_source (same payload,
-- grain and hashdiff). The 3 KYC stages carry KYCREFERENCETYPE as NULL (merged mapping).

{%- set yaml_metadata -%}
source_model:
  - 'stg2_sat_cp_partners__party_kyc_reference'
  - 'stg2_sat_bjaz_t_ckyc_otp__party_kyc_reference'
  - 'stg2_sat_bjaz_t_ckyc_search__party_kyc_reference'
  - 'stg2_sat_bjaz_t_ckyc_rel_persion_dtls__party_kyc_reference__related_person'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'KYCREFERENCETYPE'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_record_source_map:
  stg2_sat_cp_partners__party_kyc_reference: 'OPUS'
  stg2_sat_bjaz_t_ckyc_otp__party_kyc_reference: 'OPUS'
  stg2_sat_bjaz_t_ckyc_search__party_kyc_reference: 'OPUS'
  stg2_sat_bjaz_t_ckyc_rel_persion_dtls__party_kyc_reference__related_person: 'OPUS'
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
                        'stg2_sat_cp_partners__party_kyc_reference': ['KYCREFERENCETYPE'],
                        'stg2_sat_bjaz_t_ckyc_otp__party_kyc_reference': [],
                        'stg2_sat_bjaz_t_ckyc_search__party_kyc_reference': [],
                        'stg2_sat_bjaz_t_ckyc_rel_persion_dtls__party_kyc_reference__related_person': []
                    }) }}
