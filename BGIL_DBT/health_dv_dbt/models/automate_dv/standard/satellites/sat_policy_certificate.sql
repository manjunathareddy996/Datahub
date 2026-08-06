{{ config(materialized='incremental') }}

-- STANDARD-MODEL ma_sat() for SAT_POLICY_CERTIFICATE (HUB_POLICY grain) -- union of 14 table(s), no join needed.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_sat_bjaz_hm_inward_dtls__policy_certificate'
  - 'stg2_sat_ba_hcp_dt_mem__policy_certificate'
  - 'stg2_sat_ba_hcp_dt_mem_cov__policy_certificate'
  - 'stg2_sat_ba_hcp_dt_pol_cov__policy_certificate'
  - 'stg2_sat_bgil_gmc_final_instl_data__policy_certificate'
  - 'stg2_sat_bjaz_ctngy_pa_mem_dtls__policy_certificate'
  - 'stg2_sat_bjaz_ec_mem_dtls_extn__policy_certificate'
  - 'stg2_sat_bjaz_hat_id_mem_detls__policy_certificate'
  - 'stg2_sat_bjaz_hcf_member_dtls__policy_certificate'
  - 'stg2_sat_bjaz_hc_part_extn__policy_certificate'
  - 'stg2_sat_bjaz_hm_hcm_extract__policy_certificate'
  - 'stg2_sat_bjaz_hm_member_dtls__policy_certificate'
  - 'stg2_sat_bjaz_ihg_mem_dtls_extn__policy_certificate'
  - 'stg2_sat_bjaz_sh_mem_dtls_extn__policy_certificate'
src_pk: 'POLICY_HK'
src_cdk:
  - 'CERTIFICATE_NUMBER_CK'
src_payload:
  - 'CERTIFICATE_NUMBER'
  - 'COVERAGE_END_DATE'
  - 'COVERAGE_START_DATE'
  - 'ENROLMENT_DATE'
  - 'MEMBER_PREMIUM'
  - 'MEMBER_STATUS'
  - 'RELATIONSHIP_TO_PRIMARY'
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
