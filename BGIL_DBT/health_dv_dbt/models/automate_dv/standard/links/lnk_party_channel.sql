{{ config(materialized='incremental') }}

-- STANDARD-MODEL link() for LNK_PARTY_CHANNEL, 35 contributing table(s).
-- Member ends: HUB_DISTRIBUTION_CHANNEL (DISTRIBUTION_CHANNEL_HKEY), HUB_PARTY (PARTY_HKEY).
-- Rebuilt from the existing, mapper-reviewed production link model (lnk_party_channel.sql) --
-- same source tables and columns, moved to stage()-computed hashing.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_link_ba_hcp_pol_mst__party_channel'
  - 'stg2_link_ba_hcp_prod_8428_gpg_loader__party_channel'
  - 'stg2_link_ba_hcp_prod_8432_ecp_loader__party_channel'
  - 'stg2_link_ba_hcp_prod_8433_fhc_loader__party_channel'
  - 'stg2_link_ba_hcp_prod_8439_clh_loader__party_channel'
  - 'stg2_link_bjaz_bandhan_medi_clam__party_channel'
  - 'stg2_link_bjaz_ec_mem_dtls_extn__party_channel'
  - 'stg2_link_bjaz_gpg_pol_dtls__party_channel'
  - 'stg2_link_bjaz_gp_hospital_cash__party_channel'
  - 'stg2_link_bjaz_grp_hlt_imd_dtls__party_channel'
  - 'stg2_link_bjaz_hat_case_ocr_dtls__party_channel'
  - 'stg2_link_bjaz_hcf_member_dtls__party_channel'
  - 'stg2_link_bjaz_hdfc_sec_fhpp__party_channel'
  - 'stg2_link_bjaz_hg_pol_dtls__party_channel'
  - 'stg2_link_bjaz_hlt_ensure_mem_dtls__party_channel'
  - 'stg2_link_bjaz_hm_clm_register__party_channel'
  - 'stg2_link_bjaz_hm_hcm_extract__party_channel'
  - 'stg2_link_bjaz_hm_hospital_master__party_channel'
  - 'stg2_link_bjaz_hm_hospital_master_extn__party_channel'
  - 'stg2_link_bjaz_hm_member_dtls__party_channel'
  - 'stg2_link_bjaz_ihg_mem_dtls_extn__party_channel'
  - 'stg2_link_bjaz_sh_mem_dtls_extn__party_channel'
  - 'stg2_link_bjaz_spp_member_dtls__party_channel'
  - 'stg2_link_bjaz_tpa_claim_details_ws__party_channel'
  - 'stg2_link_bjaz_adld_prem_dtls__party_channel'
  - 'stg2_link_bjaz_ewr_pol_dtls__party_channel'
  - 'stg2_link_bjaz_flexi_cyber_data__party_channel'
  - 'stg2_link_bjaz_gc_group_guard_dtls__party_channel'
  - 'stg2_link_bjaz_gg_prem_dtls__party_channel'
  - 'stg2_link_bjaz_hdfc_flexipa__party_channel'
  - 'stg2_link_bjaz_hdfc_surk_shop__party_channel'
  - 'stg2_link_bjaz_pc_online_pol_dtls_mv__party_channel'
  - 'stg2_link_bjaz_pnb_gpa_data__party_channel'
  - 'stg2_link_bjaz_rr_prem_dtls__party_channel'
  - 'stg2_link_bjaz_super_suraksha_dtls__party_channel'
src_pk: 'PARTY_CHANNEL_HKEY'
src_fk:
  - 'DISTRIBUTION_CHANNEL_HKEY'
  - 'PARTY_HKEY'
src_ldts: 'LOAD_DATETIME'
src_source: 'RECORD_SOURCE'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.link(src_pk=metadata_dict['src_pk'],
                     src_fk=metadata_dict['src_fk'],
                     src_ldts=metadata_dict['src_ldts'],
                     src_source=metadata_dict['src_source'],
                     source_model=metadata_dict['source_model']) }}
