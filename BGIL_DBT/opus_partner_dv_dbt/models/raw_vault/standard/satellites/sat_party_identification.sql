{{
    config(
        materialized='incremental',
        incremental_strategy='append',
    )
}}

-- PARTNER STANDARD-MODEL sat_multi_source() for SAT_PARTY_IDENTIFICATION (HUB_PARTY grain) -- 11 source table(s).

{%- set yaml_metadata -%}
source_model:
  - 'stg2_sat_azbj_partner_extn__party_identification'
  - 'stg2_sat_bjaz_clm_supp_extn__party_identification'
  - 'stg2_sat_bjaz_ctngy_ff_dtls_extn__party_identification'
  - 'stg2_sat_bjaz_ctngy_pa_mem_dtls__party_identification'
  - 'stg2_sat_bjaz_ec_mem_dtls_extn__party_identification'
  - 'stg2_sat_bjaz_hcf_member_dtls__party_identification'
  - 'stg2_sat_bjaz_hlt_ensure_mem_dtls__party_identification'
  - 'stg2_sat_bjaz_hm_hospital_master__party_identification'
  - 'stg2_sat_bjaz_intermediary__party_identification'
  - 'stg2_sat_bjaz_starpkg_ff_dtls__party_identification'
  - 'stg2_sat_cp_partners__party_identification'
  - 'stg2_sat_bjaz_m_kyc_driving_licence__party_identification'
  - 'stg2_sat_bjaz_m_kyc_gstn__party_identification'
  - 'stg2_sat_bjaz_m_kyc_pan__party_identification'
  - 'stg2_sat_bjaz_m_kyc_passport__party_identification'
  - 'stg2_sat_bjaz_m_kyc_voter__party_identification'
  - 'stg2_sat_bjaz_t_ckyc_otp__party_identification'
  - 'stg2_sat_bjaz_t_kyc_incoming__party_identification'
  - 'stg2_sat_bjaz_t_kyc_name_match__party_identification'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'AADHAAR_NUMBER'
  - 'AGE_PROOF_TYPE'
  - 'EIA_NUMBER'
  - 'GSTIN'
  - 'GST_REGISTRATION_STATUS'
  - 'GST_TAXPAYER_TYPE'
  - 'IDENTIFICATION_NUMBER'
  - 'PAN_NUMBER'
  - 'PASSPORT_NUMBER'
  - 'TAN_NUMBER'
  - 'VATREGISTRATIONNUMBER'
  - 'VOTER_ID_NUMBER'
  - 'CKYCNUMBER'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_record_source_map:
  stg2_sat_azbj_partner_extn__party_identification: 'OPUS_PARTNER'
  stg2_sat_bjaz_clm_supp_extn__party_identification: 'OPUS_PARTNER'
  stg2_sat_bjaz_ctngy_ff_dtls_extn__party_identification: 'OPUS_PARTNER'
  stg2_sat_bjaz_ctngy_pa_mem_dtls__party_identification: 'OPUS_PARTNER'
  stg2_sat_bjaz_ec_mem_dtls_extn__party_identification: 'OPUS_PARTNER'
  stg2_sat_bjaz_hcf_member_dtls__party_identification: 'OPUS_PARTNER'
  stg2_sat_bjaz_hlt_ensure_mem_dtls__party_identification: 'OPUS_PARTNER'
  stg2_sat_bjaz_hm_hospital_master__party_identification: 'OPUS_PARTNER'
  stg2_sat_bjaz_intermediary__party_identification: 'OPUS_PARTNER'
  stg2_sat_bjaz_starpkg_ff_dtls__party_identification: 'OPUS_PARTNER'
  stg2_sat_cp_partners__party_identification: 'OPUS_PARTNER'
  stg2_sat_bjaz_m_kyc_driving_licence__party_identification: 'OPUS_PARTNER'
  stg2_sat_bjaz_m_kyc_gstn__party_identification: 'OPUS_PARTNER'
  stg2_sat_bjaz_m_kyc_pan__party_identification: 'OPUS_PARTNER'
  stg2_sat_bjaz_m_kyc_passport__party_identification: 'OPUS_PARTNER'
  stg2_sat_bjaz_m_kyc_voter__party_identification: 'OPUS_PARTNER'
  stg2_sat_bjaz_t_ckyc_otp__party_identification: 'OPUS_PARTNER'
  stg2_sat_bjaz_t_kyc_incoming__party_identification: 'OPUS_PARTNER'
  stg2_sat_bjaz_t_kyc_name_match__party_identification: 'OPUS_PARTNER'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ sat_multi_source(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model'],
                    src_record_source_map=metadata_dict['src_record_source_map'],
                    src_object_columns=['AADHAAR_NUMBER', 'GSTIN', 'PAN_NUMBER', 'PASSPORT_NUMBER', 'VOTER_ID_NUMBER', 'CKYCNUMBER'],
                    src_column_map={
                        'stg2_sat_azbj_partner_extn__party_identification': ['IDENTIFICATION_NUMBER', 'EIA_NUMBER'],
                        'stg2_sat_bjaz_clm_supp_extn__party_identification': ['GST_TAXPAYER_TYPE', 'PAN_NUMBER', 'TAN_NUMBER'],
                        'stg2_sat_bjaz_ctngy_ff_dtls_extn__party_identification': ['PASSPORT_NUMBER'],
                        'stg2_sat_bjaz_ctngy_pa_mem_dtls__party_identification': ['AADHAAR_NUMBER', 'IDENTIFICATION_NUMBER', 'PAN_NUMBER', 'PASSPORT_NUMBER', 'EIA_NUMBER'],
                        'stg2_sat_bjaz_ec_mem_dtls_extn__party_identification': ['AGE_PROOF_TYPE'],
                        'stg2_sat_bjaz_hcf_member_dtls__party_identification': ['AGE_PROOF_TYPE'],
                        'stg2_sat_bjaz_hlt_ensure_mem_dtls__party_identification': ['AGE_PROOF_TYPE'],
                        'stg2_sat_bjaz_hm_hospital_master__party_identification': ['IDENTIFICATION_NUMBER'],
                        'stg2_sat_bjaz_intermediary__party_identification': ['GST_REGISTRATION_STATUS', 'GSTIN', 'PAN_NUMBER'],
                        'stg2_sat_bjaz_starpkg_ff_dtls__party_identification': ['PASSPORT_NUMBER'],
                        'stg2_sat_cp_partners__party_identification': ['IDENTIFICATION_NUMBER', 'VATREGISTRATIONNUMBER'],
                        'stg2_sat_bjaz_m_kyc_driving_licence__party_identification': [],
                        'stg2_sat_bjaz_m_kyc_gstn__party_identification': ['GSTIN', 'GST_REGISTRATION_STATUS', 'GST_TAXPAYER_TYPE'],
                        'stg2_sat_bjaz_m_kyc_pan__party_identification': ['PAN_NUMBER'],
                        'stg2_sat_bjaz_m_kyc_passport__party_identification': ['PASSPORT_NUMBER'],
                        'stg2_sat_bjaz_m_kyc_voter__party_identification': ['VOTER_ID_NUMBER'],
                        'stg2_sat_bjaz_t_ckyc_otp__party_identification': ['IDENTIFICATION_NUMBER'],
                        'stg2_sat_bjaz_t_kyc_incoming__party_identification': ['IDENTIFICATION_NUMBER'],
                        'stg2_sat_bjaz_t_kyc_name_match__party_identification': ['IDENTIFICATION_NUMBER']
                    }) }}
