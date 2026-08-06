{{ config(materialized='incremental') }}

-- STANDARD-MODEL ma_sat() for SAT_COMMON_CONTACT (HUB_PARTY grain) -- union of 16 table(s), no join needed.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_sat_ba_hcp_pp_mem_dtls__common_contact'
  - 'stg2_sat_ba_hcp_prod_8428_gpg_loader__common_contact'
  - 'stg2_sat_ba_hcp_prod_8432_ecp_loader__common_contact'
  - 'stg2_sat_ba_hcp_prod_8433_fhc_loader__common_contact'
  - 'stg2_sat_ba_hcp_prod_8439_clh_loader__common_contact'
  - 'stg2_sat_bjaz_bandhan_medi_clam__common_contact'
  - 'stg2_sat_bjaz_hat_id_mem_detls__common_contact'
  - 'stg2_sat_bjaz_hg_pol_dtls__common_contact'
  - 'stg2_sat_bjaz_hm_hcm_extract__common_contact'
  - 'stg2_sat_bjaz_hm_hospital_master__common_contact'
  - 'stg2_sat_bjaz_hm_hospital_master_extn__common_contact'
  - 'stg2_sat_bjaz_hm_hosp_master_extn1__common_contact'
  - 'stg2_sat_bjaz_hm_inward_dtls__common_contact'
  - 'stg2_sat_bjaz_hm_member_dtls__common_contact'
  - 'stg2_sat_bjaz_sh_mem_dtls_extn__common_contact'
  - 'stg2_sat_bjaz_tpa_claim_details_ws__common_contact'
src_pk: 'PARTY_HK'
src_cdk:
  - 'CONTACT_POINT_TYPE_CK'
  - 'CONTACT_PRIORITY_ORDER_CK'
src_payload:
  - 'ALTERNATE_EMAIL_ADDRESS'
  - 'ALTERNATE_MOBILE_NUMBER'
  - 'EMAIL_ADDRESS'
  - 'FAX_NUMBER'
  - 'LANDLINE_NUMBER'
  - 'MOBILE_NUMBER'
  - 'STD_CODE'
src_hashdiff: 'HASHDIFF'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.ma_sat(src_pk=metadata_dict['src_pk'],
                       src_cdk=metadata_dict['src_cdk'],
                       src_payload=metadata_dict['src_payload'],
                       src_hashdiff=metadata_dict['src_hashdiff'],
                       src_ldts=metadata_dict['src_ldts'],
                       src_source=metadata_dict['src_source'],
                       source_model=metadata_dict['source_model']) }}
