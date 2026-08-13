{{ config(materialized='incremental') }}

-- STANDARD-MODEL hub() for HUB_PRODUCT, 45 contributing table(s)
-- across 35 source_model entries (2 via stitch-stage,
-- 33 direct per-table stage()).
-- Rebuilt from the existing, mapper-reviewed production hub model -- same source
-- tables and columns, moved to stage()-computed namespaced hashing.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_hub_ba_hcp_dt_premium__product'
  - 'stg2_hub_ba_hcp_prime_rider_dtls__product'
  - 'stg2_hub_ba_hcp_prod_8428_gpg_loader__product'
  - 'stg2_hub_ba_hcp_prod_8432_ecp_loader__product'
  - 'stg2_product_definition'
  - 'stg2_hub_bjaz_bandhan_medi_clam__product'
  - 'stg2_hub_bjaz_ehh_pol_dtls__product'
  - 'stg2_hub_bjaz_generic_loader_log_table__product'
  - 'stg2_hub_bjaz_gpg_pol_dtls__product'
  - 'stg2_hub_bjaz_gp_hospital_cash__product'
  - 'stg2_hub_bjaz_grp_hlt_cust_dtls__product'
  - 'stg2_product_terms'
  - 'stg2_hub_bjaz_grp_hlt_imd_dtls__product'
  - 'stg2_hub_bjaz_hat_case_ocr_dtls__product'
  - 'stg2_hub_bjaz_hcp_transcript_url__product'
  - 'stg2_hub_bjaz_hdfc_sec_fhpp__product'
  - 'stg2_hub_bjaz_health_webservice_info__product'
  - 'stg2_hub_bjaz_hm_coinsu_clm_dtls__product'
  - 'stg2_hub_bjaz_adld_prem_dtls__product'
  - 'stg2_hub_bjaz_clm_pre_auth_hlt_dtls__product'
  - 'stg2_hub_bjaz_clm_wg_trans_dtls__product'
  - 'stg2_hub_bjaz_clm_wg_trans_dtls_hist__product'
  - 'stg2_hub_bjaz_ctngy_ff_dtls_extn__product'
  - 'stg2_hub_bjaz_ctngy_pa_mem_dtls__product'
  - 'stg2_hub_bjaz_ewr_pol_dtls__product'
  - 'stg2_hub_bjaz_flexi_cyber_data__product'
  - 'stg2_hub_bjaz_gc_group_guard_dtls__product'
  - 'stg2_hub_bjaz_gg_prem_dtls__product'
  - 'stg2_hub_bjaz_hdfc_flexipa__product'
  - 'stg2_hub_bjaz_hdfc_surk_shop__product'
  - 'stg2_hub_bjaz_pc_online_pol_dtls_mv__product'
  - 'stg2_hub_bjaz_pnb_gpa_data__product'
  - 'stg2_hub_bjaz_rr_prem_dtls__product'
  - 'stg2_hub_bjaz_super_suraksha_dtls__product'
  - 'stg2_hub_t_prem_data_com__product'
src_pk: 'PRODUCT_HKEY'
src_nk: 'PARENT_BK'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.hub(src_pk=metadata_dict['src_pk'],
                    src_nk=metadata_dict['src_nk'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model']) }}
