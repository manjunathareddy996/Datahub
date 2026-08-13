{{ config(materialized='incremental') }}

-- STANDARD-MODEL link() for LNK_POLICY_PARTY, 48 contributing table(s).
-- Member ends: HUB_PARTY (PARTY_HKEY), HUB_POLICY (POLICY_HKEY).
-- Rebuilt from the existing, mapper-reviewed production link model (lnk_policy_party.sql) --
-- same source tables and columns, moved to stage()-computed hashing.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_link_ba_hcp_dt_mem__policy_party'
  - 'stg2_link_ba_hcp_dt_mem_cov__policy_party'
  - 'stg2_link_ba_hcp_dt_pol_cov__policy_party'
  - 'stg2_link_ba_hcp_dt_premium__policy_party'
  - 'stg2_link_ba_hcp_pol_mst__policy_party'
  - 'stg2_link_ba_hcp_pp_mem_dtls__policy_party'
  - 'stg2_link_ba_hcp_prod_8428_gpg_loader__policy_party'
  - 'stg2_link_ba_hcp_prod_8432_ecp_loader__policy_party'
  - 'stg2_link_ba_hcp_prod_8433_fhc_loader__policy_party'
  - 'stg2_link_ba_hcp_prod_8439_clh_loader__policy_party'
  - 'stg2_link_bgil_gmc_final_instl_data__policy_party'
  - 'stg2_link_bjaz_bandhan_medi_clam__policy_party'
  - 'stg2_link_bjaz_ec_mem_dtls_extn__policy_party'
  - 'stg2_link_bjaz_gpg_pol_dtls__policy_party'
  - 'stg2_link_bjaz_gp_hospital_cash__policy_party'
  - 'stg2_link_bjaz_grp_hlt_imd_dtls__policy_party'
  - 'stg2_link_bjaz_grp_tpa_extn__policy_party'
  - 'stg2_link_bjaz_hat_case_ocr_dtls__policy_party'
  - 'stg2_link_bjaz_hat_id_mem_detls__policy_party'
  - 'stg2_link_bjaz_hcf_member_dtls__policy_party'
  - 'stg2_link_bjaz_hc_part_extn__policy_party'
  - 'stg2_link_bjaz_hdfc_sec_fhpp__policy_party'
  - 'stg2_link_bjaz_hg_pol_dtls__policy_party'
  - 'stg2_link_bjaz_hlt_ensure_mem_dtls__policy_party'
  - 'stg2_link_bjaz_hm_cashless_inward__policy_party'
  - 'stg2_link_bjaz_hm_clm_register__policy_party'
  - 'stg2_link_bjaz_hm_coinsu_clm_dtls__policy_party'
  - 'stg2_link_bjaz_hm_hcm_extract__policy_party'
  - 'stg2_link_bjaz_hm_inward_dtls__policy_party'
  - 'stg2_link_bjaz_hm_member_dtls__policy_party'
  - 'stg2_link_bjaz_hm_policy_usermapping__policy_party'
  - 'stg2_link_bjaz_ihg_mem_dtls_extn__policy_party'
  - 'stg2_link_bjaz_remedinet_claim_details__policy_party'
  - 'stg2_link_bjaz_sh_mem_dtls_extn__policy_party'
  - 'stg2_link_bjaz_spp_member_dtls__policy_party'
  - 'stg2_link_bjaz_tpa_claim_details_ws__policy_party'
  - 'stg2_link_ba_hdfc_lead__policy_party'
  - 'stg2_link_bjaz_adld_prem_dtls__policy_party'
  - 'stg2_link_bjaz_clm_pre_auth_hlt_dtls__policy_party'
  - 'stg2_link_bjaz_ewr_pol_dtls__policy_party'
  - 'stg2_link_bjaz_flexi_cyber_data__policy_party'
  - 'stg2_link_bjaz_gc_group_guard_dtls__policy_party'
  - 'stg2_link_bjaz_gg_prem_dtls__policy_party'
  - 'stg2_link_bjaz_hdfc_surk_shop__policy_party'
  - 'stg2_link_bjaz_pc_online_pol_dtls_mv__policy_party'
  - 'stg2_link_bjaz_pnb_gpa_data__policy_party'
  - 'stg2_link_bjaz_rr_prem_dtls__policy_party'
  - 'stg2_link_bjaz_super_suraksha_dtls__policy_party'
src_pk: 'POLICY_PARTY_HKEY'
src_fk:
  - 'PARTY_HKEY'
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
