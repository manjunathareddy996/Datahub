{{ config(materialized='incremental') }}

-- STANDARD-MODEL link() for LNK_POLICY_PRODUCT, 37 contributing table(s).
-- Member ends: HUB_POLICY (POLICY_HKEY), HUB_PRODUCT (PRODUCT_HKEY).
-- Rebuilt from the existing, mapper-reviewed production link model (lnk_policy_product.sql) --
-- same source tables and columns, moved to stage()-computed hashing.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_link_ba_hcp_dt_premium__policy_product'
  - 'stg2_link_ba_hcp_prime_rider_dtls__policy_product'
  - 'stg2_link_ba_hcp_prod_8428_gpg_loader__policy_product'
  - 'stg2_link_ba_hcp_prod_8432_ecp_loader__policy_product'
  - 'stg2_link_ba_hcp_prod_8433_fhc_loader__policy_product'
  - 'stg2_link_ba_hcp_prod_8439_clh_loader__policy_product'
  - 'stg2_link_bjaz_bandhan_medi_clam__policy_product'
  - 'stg2_link_bjaz_ehh_pol_dtls__policy_product'
  - 'stg2_link_bjaz_generic_loader_log_table__policy_product'
  - 'stg2_link_bjaz_gpg_pol_dtls__policy_product'
  - 'stg2_link_bjaz_gp_hospital_cash__policy_product'
  - 'stg2_link_bjaz_grp_hlt_cust_dtls__policy_product'
  - 'stg2_link_bjaz_grp_hlt_dtls__policy_product'
  - 'stg2_link_bjaz_grp_hlt_imd_dtls__policy_product'
  - 'stg2_link_bjaz_grp_hlt_maternity_dtls__policy_product'
  - 'stg2_link_bjaz_hat_case_ocr_dtls__policy_product'
  - 'stg2_link_bjaz_hdfc_sec_fhpp__policy_product'
  - 'stg2_link_bjaz_health_webservice_info__policy_product'
  - 'stg2_link_bjaz_hg_pol_dtls__policy_product'
  - 'stg2_link_bjaz_hm_coinsu_clm_dtls__policy_product'
  - 'stg2_link_bjaz_hm_member_dtls__policy_product'
  - 'stg2_link_bjaz_adld_prem_dtls__policy_product'
  - 'stg2_link_bjaz_clm_pre_auth_hlt_dtls__policy_product'
  - 'stg2_link_bjaz_clm_wg_trans_dtls__policy_product'
  - 'stg2_link_bjaz_clm_wg_trans_dtls_hist__policy_product'
  - 'stg2_link_bjaz_ctngy_ff_dtls_extn__policy_product'
  - 'stg2_link_bjaz_ctngy_pa_mem_dtls__policy_product'
  - 'stg2_link_bjaz_ewr_pol_dtls__policy_product'
  - 'stg2_link_bjaz_flexi_cyber_data__policy_product'
  - 'stg2_link_bjaz_gc_group_guard_dtls__policy_product'
  - 'stg2_link_bjaz_gg_prem_dtls__policy_product'
  - 'stg2_link_bjaz_hdfc_surk_shop__policy_product'
  - 'stg2_link_bjaz_pc_online_pol_dtls_mv__policy_product'
  - 'stg2_link_bjaz_pnb_gpa_data__policy_product'
  - 'stg2_link_bjaz_rr_prem_dtls__policy_product'
  - 'stg2_link_bjaz_super_suraksha_dtls__policy_product'
  - 'stg2_link_t_prem_data_com__policy_product'
src_pk: 'POLICY_PRODUCT_HKEY'
src_fk:
  - 'POLICY_HKEY'
  - 'PRODUCT_HKEY'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.link(src_pk=metadata_dict['src_pk'],
                     src_fk=metadata_dict['src_fk'],
                     src_ldts=metadata_dict['src_ldts'],
                     src_source=metadata_dict['src_source'],
                     source_model=metadata_dict['source_model']) }}
