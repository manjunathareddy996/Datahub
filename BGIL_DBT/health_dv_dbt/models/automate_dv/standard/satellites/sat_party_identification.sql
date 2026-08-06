{{ config(materialized='incremental') }}

-- STANDARD-MODEL ma_sat() for SAT_PARTY_IDENTIFICATION (HUB_PARTY grain) -- union of 16 table(s), no join needed.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_sat_ba_hcp_prod_8428_gpg_loader__party_identification'
  - 'stg2_sat_ba_hcp_prod_8432_ecp_loader__party_identification'
  - 'stg2_sat_ba_hcp_prod_8433_fhc_loader__party_identification'
  - 'stg2_sat_ba_hcp_prod_8439_clh_loader__party_identification'
  - 'stg2_sat_bjaz_bandhan_medi_clam__party_identification'
  - 'stg2_sat_bjaz_ec_mem_dtls_extn__party_identification'
  - 'stg2_sat_bjaz_gpg_pol_dtls__party_identification'
  - 'stg2_sat_bjaz_hg_pol_dtls__party_identification'
  - 'stg2_sat_bjaz_hlt_ensure_mem_dtls__party_identification'
  - 'stg2_sat_bjaz_hm_hcm_extract__party_identification'
  - 'stg2_sat_bjaz_hm_hospital_master__party_identification'
  - 'stg2_sat_bjaz_hm_hospital_master_extn__party_identification'
  - 'stg2_sat_bjaz_hm_inward_dtls__party_identification'
  - 'stg2_sat_bjaz_ihg_mem_dtls_extn__party_identification'
  - 'stg2_sat_bjaz_remedinet_claim_details__party_identification'
  - 'stg2_sat_bjaz_tpa_claim_details_ws__party_identification'
src_pk: 'PARTY_HK'
src_cdk:
  - 'IDENTIFICATION_TYPE_CODE_CK'
src_payload:
  - 'AADHAAR_NUMBER'
  - 'AGE_PROOF_TYPE'
  - 'EIA_NUMBER'
  - 'GSTIN'
  - 'IDENTIFICATION_NUMBER'
  - 'PAN_NUMBER'
  - 'PASSPORT_NUMBER'
  - 'TAN_NUMBER'
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
