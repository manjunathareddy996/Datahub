{{ config(materialized='incremental') }}

-- STANDARD-MODEL hub() for HUB_DISTRIBUTION_CHANNEL, 90 contributing table(s)
-- across 43 source_model entries (1 via stitch-stage,
-- 42 direct per-table stage()).
-- Rebuilt from the existing, mapper-reviewed production hub model -- same source
-- tables and columns, moved to stage()-computed namespaced hashing.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_hub_ba_hcp_pol_mst__distribution_channel'
  - 'stg2_hub_ba_hcp_port_wordings__distribution_channel'
  - 'stg2_channel_definition'
  - 'stg2_hub_bjaz_card_dtls__distribution_channel'
  - 'stg2_hub_bjaz_ctngy_scheme_mst__distribution_channel'
  - 'stg2_hub_bjaz_ec_mem_dtls_extn__distribution_channel'
  - 'stg2_hub_bjaz_generic_loader_log_table__distribution_channel'
  - 'stg2_hub_bjaz_gpg_pol_dtls__distribution_channel'
  - 'stg2_hub_bjaz_grp_hlt_imd_dtls__distribution_channel'
  - 'stg2_hub_bjaz_hat_case_ocr_dtls__distribution_channel'
  - 'stg2_hub_bjaz_hcf_member_dtls__distribution_channel'
  - 'stg2_hub_bjaz_hcp_transcript_url__distribution_channel'
  - 'stg2_hub_bjaz_health_webservice_info__distribution_channel'
  - 'stg2_hub_bjaz_hg_pol_dtls__distribution_channel'
  - 'stg2_hub_bjaz_hlt_ensure_mem_dtls__distribution_channel'
  - 'stg2_hub_bjaz_hm_clm_register__distribution_channel'
  - 'stg2_hub_bjaz_hm_hcm_extract__distribution_channel'
  - 'stg2_hub_bjaz_hm_hospital_master__distribution_channel'
  - 'stg2_hub_bjaz_hm_hospital_master_extn__distribution_channel'
  - 'stg2_hub_bjaz_hm_member_dtls__distribution_channel'
  - 'stg2_hub_bjaz_ihg_mem_dtls_extn__distribution_channel'
  - 'stg2_hub_bjaz_sh_mem_dtls_extn__distribution_channel'
  - 'stg2_hub_bjaz_spp_member_dtls__distribution_channel'
  - 'stg2_hub_bjaz_tpa_claim_details_ws__distribution_channel'
  - 'stg2_hub_bjaz_adld_prem_dtls__distribution_channel'
  - 'stg2_hub_bjaz_clm_supp_extn__distribution_channel'
  - 'stg2_hub_bjaz_ctngy_ff_dtls_extn__distribution_channel'
  - 'stg2_hub_bjaz_ctngy_gc_mem_data__distribution_channel'
  - 'stg2_hub_bjaz_ctngy_pa_mem_dtls__distribution_channel'
  - 'stg2_hub_bjaz_ewr_pol_dtls__distribution_channel'
  - 'stg2_hub_bjaz_flexi_cyber_data__distribution_channel'
  - 'stg2_hub_bjaz_gc_group_guard_dtls__distribution_channel'
  - 'stg2_hub_bjaz_gg_prem_dtls__distribution_channel'
  - 'stg2_hub_bjaz_hdfc_flexipa__distribution_channel'
  - 'stg2_hub_bjaz_hdfc_surk_shop__distribution_channel'
  - 'stg2_hub_bjaz_pa_detl_extn__distribution_channel'
  - 'stg2_hub_bjaz_pc_online_pol_dtls_mv__distribution_channel'
  - 'stg2_hub_bjaz_pnb_gpa_data__distribution_channel'
  - 'stg2_hub_bjaz_rr_prem_dtls__distribution_channel'
  - 'stg2_hub_bjaz_scrutiny_ip_dtls__distribution_channel'
  - 'stg2_hub_bjaz_starpkg_ff_dtls__distribution_channel'
  - 'stg2_hub_bjaz_super_suraksha_dtls__distribution_channel'
  - 'stg2_hub_t_prem_data_com__distribution_channel'
src_pk: 'DISTRIBUTION_CHANNEL_HKEY'
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
