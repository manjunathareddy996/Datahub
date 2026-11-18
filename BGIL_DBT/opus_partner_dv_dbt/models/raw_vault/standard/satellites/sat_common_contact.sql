{{
    config(
        materialized='incremental',
        incremental_strategy='append',
    )
}}

-- PARTNER STANDARD-MODEL sat_multi_source() for SAT_COMMON_CONTACT (HUB_PARTY grain) -- 10 source table(s).

{%- set yaml_metadata -%}
source_model:
  - 'stg2_sat_azbj_partner_extn__common_contact'
  - 'stg2_sat_bjaz_clm_supp_extn__common_contact'
  - 'stg2_sat_bjaz_ctngy_gc_mem_data__common_contact'
  - 'stg2_sat_bjaz_ctngy_pa_mem_dtls__common_contact'
  - 'stg2_sat_bjaz_hm_hospital_master__common_contact'
  - 'stg2_sat_bjaz_hm_member_dtls__common_contact'
  - 'stg2_sat_bjaz_sh_mem_dtls_extn__common_contact'
  - 'stg2_sat_clm_suppliers__common_contact'
  - 'stg2_sat_cp_partners__common_contact'
  - 'stg2_sat_bjaz_t_ckyc_otp__common_contact'
  - 'stg2_sat_bjaz_t_ekyc__common_contact'
  - 'stg2_sat_bjaz_t_kyc_details__common_contact'
src_pk: 'PARTY_HKEY'
src_payload:
  - 'ALTERNATE_EMAIL_ADDRESS'
  - 'ALTERNATE_MOBILE_NUMBER'
  - 'EMAIL_ADDRESS'
  - 'FAX_NUMBER'
  - 'LANDLINE_NUMBER'
  - 'MOBILE_NUMBER'
  - 'PREFERRED_CONTACT_TIME'
  - 'STD_CODE'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
src_record_source_map:
  stg2_sat_azbj_partner_extn__common_contact: 'OPUS_PARTNER'
  stg2_sat_bjaz_clm_supp_extn__common_contact: 'OPUS_PARTNER'
  stg2_sat_bjaz_ctngy_gc_mem_data__common_contact: 'OPUS_PARTNER'
  stg2_sat_bjaz_ctngy_pa_mem_dtls__common_contact: 'OPUS_PARTNER'
  stg2_sat_bjaz_hm_hospital_master__common_contact: 'OPUS_PARTNER'
  stg2_sat_bjaz_hm_member_dtls__common_contact: 'OPUS_PARTNER'
  stg2_sat_bjaz_sh_mem_dtls_extn__common_contact: 'OPUS_PARTNER'
  stg2_sat_clm_suppliers__common_contact: 'OPUS_PARTNER'
  stg2_sat_cp_partners__common_contact: 'OPUS_PARTNER'
  stg2_sat_bjaz_t_ckyc_otp__common_contact: 'OPUS_PARTNER'
  stg2_sat_bjaz_t_ekyc__common_contact: 'OPUS_PARTNER'
  stg2_sat_bjaz_t_kyc_details__common_contact: 'OPUS_PARTNER'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ sat_multi_source(src_pk=metadata_dict['src_pk'],
                    src_payload=metadata_dict['src_payload'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model'],
                    src_record_source_map=metadata_dict['src_record_source_map'],
                    src_object_columns=['MOBILE_NUMBER'],
                    src_column_map={
                        'stg2_sat_azbj_partner_extn__common_contact': ['ALTERNATE_EMAIL_ADDRESS', 'ALTERNATE_MOBILE_NUMBER', 'LANDLINE_NUMBER', 'PREFERRED_CONTACT_TIME'],
                        'stg2_sat_bjaz_clm_supp_extn__common_contact': ['EMAIL_ADDRESS', 'LANDLINE_NUMBER', 'MOBILE_NUMBER', 'STD_CODE'],
                        'stg2_sat_bjaz_ctngy_gc_mem_data__common_contact': ['LANDLINE_NUMBER'],
                        'stg2_sat_bjaz_ctngy_pa_mem_dtls__common_contact': ['EMAIL_ADDRESS', 'FAX_NUMBER', 'LANDLINE_NUMBER', 'MOBILE_NUMBER'],
                        'stg2_sat_bjaz_hm_hospital_master__common_contact': ['EMAIL_ADDRESS', 'FAX_NUMBER', 'LANDLINE_NUMBER', 'STD_CODE'],
                        'stg2_sat_bjaz_hm_member_dtls__common_contact': ['EMAIL_ADDRESS', 'LANDLINE_NUMBER'],
                        'stg2_sat_bjaz_sh_mem_dtls_extn__common_contact': ['EMAIL_ADDRESS'],
                        'stg2_sat_clm_suppliers__common_contact': ['LANDLINE_NUMBER'],
                        'stg2_sat_cp_partners__common_contact': ['EMAIL_ADDRESS', 'FAX_NUMBER', 'LANDLINE_NUMBER'],
                        'stg2_sat_bjaz_t_ckyc_otp__common_contact': ['MOBILE_NUMBER'],
                        'stg2_sat_bjaz_t_ekyc__common_contact': ['MOBILE_NUMBER'],
                        'stg2_sat_bjaz_t_kyc_details__common_contact': ['MOBILE_NUMBER']
                    }) }}
