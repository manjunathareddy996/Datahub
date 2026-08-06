{{ config(materialized='incremental') }}

-- STANDARD-MODEL link() for LNK_POLICY_CHANNEL, 43 contributing table(s).
-- Member ends: HUB_DISTRIBUTION_CHANNEL (DISTRIBUTION_CHANNEL_HKEY), HUB_POLICY (POLICY_HKEY).
-- Rebuilt from the existing, mapper-reviewed production link model (lnk_policy_channel.sql) --
-- same source tables and columns, moved to stage()-computed hashing.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_link_ba_hcp_pol_mst__policy_channel'
  - 'stg2_link_ba_hcp_port_wordings__policy_channel'
  - 'stg2_link_ba_hcp_prod_8428_gpg_loader__policy_channel'
  - 'stg2_link_ba_hcp_prod_8432_ecp_loader__policy_channel'
  - 'stg2_link_ba_hcp_prod_8433_fhc_loader__policy_channel'
  - 'stg2_link_ba_hcp_prod_8439_clh_loader__policy_channel'
  - 'stg2_link_bjaz_bandhan_medi_clam__policy_channel'
  - 'stg2_link_bjaz_card_dtls__policy_channel'
  - 'stg2_link_bjaz_ec_mem_dtls_extn__policy_channel'
  - 'stg2_link_bjaz_ehh_pol_dtls__policy_channel'
  - 'stg2_link_bjaz_generic_loader_log_table__policy_channel'
  - 'stg2_link_bjaz_gpg_pol_dtls__policy_channel'
  - 'stg2_link_bjaz_gp_hospital_cash__policy_channel'
  - 'stg2_link_bjaz_grp_hlt_imd_dtls__policy_channel'
  - 'stg2_link_bjaz_hat_case_ocr_dtls__policy_channel'
  - 'stg2_link_bjaz_hcf_member_dtls__policy_channel'
  - 'stg2_link_bjaz_hdfc_sec_fhpp__policy_channel'
  - 'stg2_link_bjaz_health_webservice_info__policy_channel'
  - 'stg2_link_bjaz_hg_pol_dtls__policy_channel'
  - 'stg2_link_bjaz_hlt_ensure_mem_dtls__policy_channel'
  - 'stg2_link_bjaz_hm_clm_register__policy_channel'
  - 'stg2_link_bjaz_hm_hcm_extract__policy_channel'
  - 'stg2_link_bjaz_hm_member_dtls__policy_channel'
  - 'stg2_link_bjaz_ihg_mem_dtls_extn__policy_channel'
  - 'stg2_link_bjaz_sh_mem_dtls_extn__policy_channel'
  - 'stg2_link_bjaz_spp_member_dtls__policy_channel'
  - 'stg2_link_bjaz_tpa_claim_details_ws__policy_channel'
  - 'stg2_link_bjaz_adld_prem_dtls__policy_channel'
  - 'stg2_link_bjaz_ctngy_ff_dtls_extn__policy_channel'
  - 'stg2_link_bjaz_ctngy_gc_mem_data__policy_channel'
  - 'stg2_link_bjaz_ctngy_pa_mem_dtls__policy_channel'
  - 'stg2_link_bjaz_ewr_pol_dtls__policy_channel'
  - 'stg2_link_bjaz_flexi_cyber_data__policy_channel'
  - 'stg2_link_bjaz_gc_group_guard_dtls__policy_channel'
  - 'stg2_link_bjaz_gg_prem_dtls__policy_channel'
  - 'stg2_link_bjaz_hdfc_surk_shop__policy_channel'
  - 'stg2_link_bjaz_pa_detl_extn__policy_channel'
  - 'stg2_link_bjaz_pc_online_pol_dtls_mv__policy_channel'
  - 'stg2_link_bjaz_pnb_gpa_data__policy_channel'
  - 'stg2_link_bjaz_rr_prem_dtls__policy_channel'
  - 'stg2_link_bjaz_starpkg_ff_dtls__policy_channel'
  - 'stg2_link_bjaz_super_suraksha_dtls__policy_channel'
  - 'stg2_link_t_prem_data_com__policy_channel'
src_pk: 'POLICY_CHANNEL_HKEY'
src_fk:
  - 'DISTRIBUTION_CHANNEL_HKEY'
  - 'POLICY_HKEY'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.link(src_pk=metadata_dict['src_pk'],
                     src_fk=metadata_dict['src_fk'],
                     src_ldts=metadata_dict['src_ldts'],
                     src_source=metadata_dict['src_source'],
                     source_model=metadata_dict['source_model']) }}
