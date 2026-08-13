{{ config(materialized='incremental') }}

-- STANDARD-MODEL hub() for HUB_POLICY, 103 contributing table(s)
-- across 43 source_model entries (4 via stitch-stage,
-- 39 direct per-table stage()).
-- Rebuilt from the existing, mapper-reviewed production hub model -- same source
-- tables and columns, moved to stage()-computed namespaced hashing.

{%- set yaml_metadata -%}
source_model:
  - 'stg2_hub_ba_hcp_dt_mem__policy'
  - 'stg2_hub_ba_hcp_dt_mem_cov__policy'
  - 'stg2_hub_ba_hcp_dt_pol_cov__policy'
  - 'stg2_policy_premium_summary'
  - 'stg2_policy_portability_migration'
  - 'stg2_hub_ba_hcp_pp_mem_dtls__policy'
  - 'stg2_policy_terms'
  - 'stg2_policy_header'
  - 'stg2_hub_bjaz_grp_hlt_cust_dtls__policy'
  - 'stg2_hub_bjaz_grp_hlt_imd_dtls__policy'
  - 'stg2_hub_bjaz_grp_tpa_extn__policy'
  - 'stg2_hub_bjaz_hat_case_ocr_dtls__policy'
  - 'stg2_hub_bjaz_hm_cashless_inward__policy'
  - 'stg2_hub_bjaz_hm_clm_register__policy'
  - 'stg2_hub_bjaz_hm_gmc_ahc__policy'
  - 'stg2_hub_bjaz_hm_inward_dtls__policy'
  - 'stg2_hub_bjaz_hm_outward_dtls__policy'
  - 'stg2_hub_bjaz_hm_policy_usermapping__policy'
  - 'stg2_hub_bjaz_remedinet_claim_details__policy'
  - 'stg2_hub_bjaz_spp_member_dtls__policy'
  - 'stg2_hub_bjaz_ws_family_dtls_bandhan__policy'
  - 'stg2_hub_stg_hcf_member_dtls__policy'
  - 'stg2_hub_ba_hdfc_lead__policy'
  - 'stg2_hub_bjaz_adld_prem_dtls__policy'
  - 'stg2_hub_bjaz_clm_pre_auth_hlt_dtls__policy'
  - 'stg2_hub_bjaz_clm_wg_trans_dtls__policy'
  - 'stg2_hub_bjaz_clm_wg_trans_dtls_hist__policy'
  - 'stg2_hub_bjaz_ctngy_ff_dtls_extn__policy'
  - 'stg2_hub_bjaz_ctngy_gc_mem_data__policy'
  - 'stg2_hub_bjaz_ctngy_pa_mem_dtls__policy'
  - 'stg2_hub_bjaz_ewr_pol_dtls__policy'
  - 'stg2_hub_bjaz_flexi_cyber_data__policy'
  - 'stg2_hub_bjaz_gc_group_guard_dtls__policy'
  - 'stg2_hub_bjaz_gg_prem_dtls__policy'
  - 'stg2_hub_bjaz_hdfc_surk_shop__policy'
  - 'stg2_hub_bjaz_pa_detl_extn__policy'
  - 'stg2_hub_bjaz_pc_online_pol_dtls_mv__policy'
  - 'stg2_hub_bjaz_pnb_gpa_data__policy'
  - 'stg2_hub_bjaz_rr_prem_dtls__policy'
  - 'stg2_hub_bjaz_starpkg_ff_dtls__policy'
  - 'stg2_hub_bjaz_super_suraksha_dtls__policy'
  - 'stg2_hub_bjaz_trv_clm_itrack_dtls__policy'
  - 'stg2_hub_t_prem_data_com__policy'
src_pk: 'POLICY_HKEY'
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
