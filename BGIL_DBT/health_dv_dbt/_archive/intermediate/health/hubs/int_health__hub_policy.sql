-- Intermediate harmonisation view for HUB_POLICY.
-- Unions the HUB_POLICY business key from every Health source table/column carrying it. (31 of 103 source columns are discovered/mapper-confirmed, not explicitly tagged in the original mapping -- see docs.)
-- Pure UNION ALL fan-in: 0-join complexity. This view alone fully supplies hub_policy.sql.

with unioned as (

    select distinct
        contract_id as business_key,
        'BA_HCP_DT_MEM' as record_source
    from {{ ref('stg_health__ba_hcp_dt_mem') }}
    where contract_id is not null

    union all

    select distinct
        contract_id as business_key,
        'BA_HCP_DT_MEM_COV' as record_source
    from {{ ref('stg_health__ba_hcp_dt_mem_cov') }}
    where contract_id is not null

    union all

    select distinct
        contract_id as business_key,
        'BA_HCP_DT_POL_COV' as record_source
    from {{ ref('stg_health__ba_hcp_dt_pol_cov') }}
    where contract_id is not null

    union all

    select distinct
        contract_id as business_key,
        'BA_HCP_DT_PREMIUM' as record_source
    from {{ ref('stg_health__ba_hcp_dt_premium') }}
    where contract_id is not null

    union all

    select distinct
        contract_id as business_key,
        'BA_HCP_POL_MST' as record_source
    from {{ ref('stg_health__ba_hcp_pol_mst') }}
    where contract_id is not null

    union all

    select distinct
        policy_ref as business_key,
        'BA_HCP_POL_MST' as record_source
    from {{ ref('stg_health__ba_hcp_pol_mst') }}
    where policy_ref is not null

    union all

    select distinct
        contract_id as business_key,
        'BA_HCP_PORT_WORDINGS' as record_source
    from {{ ref('stg_health__ba_hcp_port_wordings') }}
    where contract_id is not null

    union all

    select distinct
        contract_id as business_key,
        'BA_HCP_PP_MEM_DTLS' as record_source
    from {{ ref('stg_health__ba_hcp_pp_mem_dtls') }}
    where contract_id is not null

    union all

    select distinct
        base_policy_ref as business_key,
        'BA_HCP_PRIME_RIDER_DTLS' as record_source
    from {{ ref('stg_health__ba_hcp_prime_rider_dtls') }}
    where base_policy_ref is not null

    union all

    select distinct
        base_contract_id as business_key,
        'BA_HCP_PRIME_RIDER_DTLS' as record_source
    from {{ ref('stg_health__ba_hcp_prime_rider_dtls') }}
    where base_contract_id is not null

    union all

    select distinct
        han_number as business_key,
        'BA_HCP_PRIME_RIDER_DTLS' as record_source
    from {{ ref('stg_health__ba_hcp_prime_rider_dtls') }}
    where han_number is not null

    union all

    select distinct
        pol_serial_no as business_key,
        'BA_HCP_PROD_8428_GPG_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
    where pol_serial_no is not null

    union all

    select distinct
        policy_ref as business_key,
        'BA_HCP_PROD_8428_GPG_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
    where policy_ref is not null

    union all

    select distinct
        pol_serial_no as business_key,
        'BA_HCP_PROD_8432_ECP_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
    where pol_serial_no is not null

    union all

    select distinct
        policy_ref as business_key,
        'BA_HCP_PROD_8432_ECP_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
    where policy_ref is not null

    union all

    select distinct
        pol_serial_no as business_key,
        'BA_HCP_PROD_8433_FHC_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
    where pol_serial_no is not null

    union all

    select distinct
        policy_ref as business_key,
        'BA_HCP_PROD_8433_FHC_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
    where policy_ref is not null

    union all

    select distinct
        pol_serial_no as business_key,
        'BA_HCP_PROD_8439_CLH_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
    where pol_serial_no is not null

    union all

    select distinct
        policy_ref as business_key,
        'BA_HCP_PROD_8439_CLH_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
    where policy_ref is not null

    union all

    select distinct
        policy_no as business_key,
        'BGIL_GMC_FINAL_INSTL_DATA' as record_source
    from {{ ref('stg_health__bgil_gmc_final_instl_data') }}
    where policy_no is not null

    union all

    select distinct
        policy_ref as business_key,
        'BJAZ_BANDHAN_MEDI_CLAM' as record_source
    from {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
    where policy_ref is not null

    union all

    select distinct
        contract_id as business_key,
        'BJAZ_BANDHAN_MEDI_CLAM' as record_source
    from {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
    where contract_id is not null

    union all

    select distinct
        policy_ref as business_key,
        'BJAZ_CARD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_card_dtls') }}
    where policy_ref is not null

    union all

    select distinct
        contract_id as business_key,
        'BJAZ_CARD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_card_dtls') }}
    where contract_id is not null

    union all

    select distinct
        policy_ref as business_key,
        'BJAZ_ECARD_POL_DTLS_CONFIG' as record_source
    from {{ ref('stg_health__bjaz_ecard_pol_dtls_config') }}
    where policy_ref is not null

    union all

    select distinct
        contract_id as business_key,
        'BJAZ_EC_MEM_DTLS_EXTN' as record_source
    from {{ ref('stg_health__bjaz_ec_mem_dtls_extn') }}
    where contract_id is not null

    union all

    select distinct
        policy_ref as business_key,
        'BJAZ_EC_MEM_DTLS_EXTN' as record_source
    from {{ ref('stg_health__bjaz_ec_mem_dtls_extn') }}
    where policy_ref is not null

    union all

    select distinct
        policy_ref as business_key,
        'BJAZ_EHH_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_ehh_pol_dtls') }}
    where policy_ref is not null

    union all

    select distinct
        contract_id as business_key,
        'BJAZ_EHH_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_ehh_pol_dtls') }}
    where contract_id is not null

    union all

    select distinct
        pmasterpolicynumber as business_key,
        'BJAZ_GENERIC_LOADER_LOG_TABLE' as record_source
    from {{ ref('stg_health__bjaz_generic_loader_log_table') }}
    where pmasterpolicynumber is not null

    union all

    select distinct
        pcontractid as business_key,
        'BJAZ_GENERIC_LOADER_LOG_TABLE' as record_source
    from {{ ref('stg_health__bjaz_generic_loader_log_table') }}
    where pcontractid is not null

    union all

    select distinct
        policynumber as business_key,
        'BJAZ_GENERIC_LOADER_LOG_TABLE' as record_source
    from {{ ref('stg_health__bjaz_generic_loader_log_table') }}
    where policynumber is not null

    union all

    select distinct
        reference_id as business_key,
        'BJAZ_GPG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gpg_pol_dtls') }}
    where reference_id is not null

    union all

    select distinct
        policy_ref as business_key,
        'BJAZ_GPG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gpg_pol_dtls') }}
    where policy_ref is not null

    union all

    select distinct
        contract_id as business_key,
        'BJAZ_GPG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gpg_pol_dtls') }}
    where contract_id is not null

    union all

    select distinct
        master_policy_no as business_key,
        'BJAZ_GP_HOSPITAL_CASH' as record_source
    from {{ ref('stg_health__bjaz_gp_hospital_cash') }}
    where master_policy_no is not null

    union all

    select distinct
        reg_no as business_key,
        'BJAZ_GRP_HLT_CUST_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_cust_dtls') }}
    where reg_no is not null

    union all

    select distinct
        reg_no as business_key,
        'BJAZ_GRP_HLT_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_dtls') }}
    where reg_no is not null

    union all

    select distinct
        policy_no as business_key,
        'BJAZ_GRP_HLT_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_dtls') }}
    where policy_no is not null

    union all

    select distinct
        reg_no as business_key,
        'BJAZ_GRP_HLT_IMD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_imd_dtls') }}
    where reg_no is not null

    union all

    select distinct
        reg_no as business_key,
        'BJAZ_GRP_HLT_MATERNITY_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_maternity_dtls') }}
    where reg_no is not null

    union all

    select distinct
        contract_id as business_key,
        'BJAZ_GRP_TPA_EXTN' as record_source
    from {{ ref('stg_health__bjaz_grp_tpa_extn') }}
    where contract_id is not null

    union all

    -- DISCOVERED
    select distinct
        policy_number as business_key,
        'BJAZ_HAT_CASE_OCR_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hat_case_ocr_dtls') }}
    where policy_number is not null

    union all

    select distinct
        contract_id as business_key,
        'BJAZ_HAT_ID_MEM_DETLS' as record_source
    from {{ ref('stg_health__bjaz_hat_id_mem_detls') }}
    where contract_id is not null

    union all

    select distinct
        contract_id as business_key,
        'BJAZ_HCF_MEMBER_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hcf_member_dtls') }}
    where contract_id is not null

    union all

    select distinct
        policy_number as business_key,
        'BJAZ_HCF_MEMBER_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hcf_member_dtls') }}
    where policy_number is not null

    union all

    select distinct
        contract_id as business_key,
        'BJAZ_HC_PART_EXTN' as record_source
    from {{ ref('stg_health__bjaz_hc_part_extn') }}
    where contract_id is not null

    union all

    select distinct
        reference_id as business_key,
        'BJAZ_HDFC_SEC_FHPP' as record_source
    from {{ ref('stg_health__bjaz_hdfc_sec_fhpp') }}
    where reference_id is not null

    union all

    select distinct
        master_policy_no as business_key,
        'BJAZ_HDFC_SEC_FHPP' as record_source
    from {{ ref('stg_health__bjaz_hdfc_sec_fhpp') }}
    where master_policy_no is not null

    union all

    select distinct
        policy_ref as business_key,
        'BJAZ_HEALTH_WEBSERVICE_INFO' as record_source
    from {{ ref('stg_health__bjaz_health_webservice_info') }}
    where policy_ref is not null

    union all

    select distinct
        contract_id as business_key,
        'BJAZ_HEALTH_WEBSERVICE_INFO' as record_source
    from {{ ref('stg_health__bjaz_health_webservice_info') }}
    where contract_id is not null

    union all

    select distinct
        contract_id as business_key,
        'BJAZ_HG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hg_pol_dtls') }}
    where contract_id is not null

    union all

    select distinct
        policy_ref as business_key,
        'BJAZ_HG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hg_pol_dtls') }}
    where policy_ref is not null

    union all

    select distinct
        contract_id as business_key,
        'BJAZ_HLT_ENSURE_MEM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hlt_ensure_mem_dtls') }}
    where contract_id is not null

    union all

    select distinct
        policy_ref as business_key,
        'BJAZ_HM_CASHLESS_INWARD' as record_source
    from {{ ref('stg_health__bjaz_hm_cashless_inward') }}
    where policy_ref is not null

    union all

    -- DISCOVERED
    select distinct
        contract_id as business_key,
        'BJAZ_HM_CLM_REGISTER' as record_source
    from {{ ref('stg_health__bjaz_hm_clm_register') }}
    where contract_id is not null

    union all

    -- DISCOVERED
    select distinct
        policy_ref as business_key,
        'BJAZ_HM_CLM_REGISTER' as record_source
    from {{ ref('stg_health__bjaz_hm_clm_register') }}
    where policy_ref is not null

    union all

    select distinct
        policy_ref as business_key,
        'BJAZ_HM_COINSU_CLM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_coinsu_clm_dtls') }}
    where policy_ref is not null

    union all

    select distinct
        policy_no as business_key,
        'BJAZ_HM_GMC_AHC' as record_source
    from {{ ref('stg_health__bjaz_hm_gmc_ahc') }}
    where policy_no is not null

    union all

    select distinct
        policy as business_key,
        'BJAZ_HM_HCM_EXTRACT' as record_source
    from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
    where policy is not null

    union all

    select distinct
        policy_ref as business_key,
        'BJAZ_HM_INWARD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_inward_dtls') }}
    where policy_ref is not null

    union all

    select distinct
        contract_id as business_key,
        'BJAZ_HM_MEMBER_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_member_dtls') }}
    where contract_id is not null

    union all

    select distinct
        policy_ref as business_key,
        'BJAZ_HM_MEMBER_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_member_dtls') }}
    where policy_ref is not null

    union all

    select distinct
        policy_number as business_key,
        'BJAZ_HM_ORPHAN_REG' as record_source
    from {{ ref('stg_health__bjaz_hm_orphan_reg') }}
    where policy_number is not null

    union all

    -- DISCOVERED
    select distinct
        policy_ref as business_key,
        'BJAZ_HM_OUTWARD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_outward_dtls') }}
    where policy_ref is not null

    union all

    select distinct
        policy_ref as business_key,
        'BJAZ_HM_POLICY_USERMAPPING' as record_source
    from {{ ref('stg_health__bjaz_hm_policy_usermapping') }}
    where policy_ref is not null

    union all

    select distinct
        contract_id as business_key,
        'BJAZ_IHG_MEM_DTLS_EXTN' as record_source
    from {{ ref('stg_health__bjaz_ihg_mem_dtls_extn') }}
    where contract_id is not null

    union all

    select distinct
        policy_ref as business_key,
        'BJAZ_IHG_MEM_DTLS_EXTN' as record_source
    from {{ ref('stg_health__bjaz_ihg_mem_dtls_extn') }}
    where policy_ref is not null

    union all

    select distinct
        contract_id as business_key,
        'BJAZ_ILLNESS_BASES_EXTN' as record_source
    from {{ ref('stg_health__bjaz_illness_bases_extn') }}
    where contract_id is not null

    union all

    select distinct
        policy_ref as business_key,
        'BJAZ_PMJAY_PRMBOOK_DTLS' as record_source
    from {{ ref('stg_health__bjaz_pmjay_prmbook_dtls') }}
    where policy_ref is not null

    union all

    select distinct
        policy_no as business_key,
        'BJAZ_REMEDINET_CLAIM_DETAILS' as record_source
    from {{ ref('stg_health__bjaz_remedinet_claim_details') }}
    where policy_no is not null

    union all

    select distinct
        contract_id as business_key,
        'BJAZ_SH_MEM_DTLS_EXTN' as record_source
    from {{ ref('stg_health__bjaz_sh_mem_dtls_extn') }}
    where contract_id is not null

    union all

    select distinct
        policy_ref as business_key,
        'BJAZ_SH_MEM_DTLS_EXTN' as record_source
    from {{ ref('stg_health__bjaz_sh_mem_dtls_extn') }}
    where policy_ref is not null

    union all

    -- DISCOVERED
    select distinct
        contract_id as business_key,
        'BJAZ_SPP_MEMBER_DTLS' as record_source
    from {{ ref('stg_health__bjaz_spp_member_dtls') }}
    where contract_id is not null

    union all

    -- DISCOVERED
    select distinct
        policy_number as business_key,
        'BJAZ_SPP_MEMBER_DTLS' as record_source
    from {{ ref('stg_health__bjaz_spp_member_dtls') }}
    where policy_number is not null

    union all

    select distinct
        policy_no as business_key,
        'BJAZ_TPA_CLAIM_DETAILS_WS' as record_source
    from {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
    where policy_no is not null

    union all

    select distinct
        pmasterpolicynumber as business_key,
        'BJAZ_WS_FAMILY_DTLS_BANDHAN' as record_source
    from {{ ref('stg_health__bjaz_ws_family_dtls_bandhan') }}
    where pmasterpolicynumber is not null

    union all

    select distinct
        contract_id as business_key,
        'STG_HCF_MEMBER_DTLS' as record_source
    from {{ ref('stg_health__stg_hcf_member_dtls') }}
    where contract_id is not null

    union all

    -- DISCOVERED
    select distinct
        policy_ref as business_key,
        'BA_HDFC_LEAD' as record_source
    from {{ ref('stg_health__ba_hdfc_lead') }}
    where policy_ref is not null

    union all

    -- DISCOVERED
    select distinct
        master_policy_no as business_key,
        'BJAZ_ADLD_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_adld_prem_dtls') }}
    where master_policy_no is not null

    union all

    -- DISCOVERED
    select distinct
        contract_id as business_key,
        'BJAZ_CLM_PRE_AUTH_HLT_DTLS' as record_source
    from {{ ref('stg_health__bjaz_clm_pre_auth_hlt_dtls') }}
    where contract_id is not null

    union all

    -- DISCOVERED
    select distinct
        policy_ref as business_key,
        'BJAZ_CLM_WG_TRANS_DTLS' as record_source
    from {{ ref('stg_health__bjaz_clm_wg_trans_dtls') }}
    where policy_ref is not null

    union all

    -- DISCOVERED
    select distinct
        policy_ref as business_key,
        'BJAZ_CLM_WG_TRANS_DTLS_HIST' as record_source
    from {{ ref('stg_health__bjaz_clm_wg_trans_dtls_hist') }}
    where policy_ref is not null

    union all

    -- DISCOVERED
    select distinct
        contract_id as business_key,
        'BJAZ_CTNGY_FF_DTLS_EXTN' as record_source
    from {{ ref('stg_health__bjaz_ctngy_ff_dtls_extn') }}
    where contract_id is not null

    union all

    -- DISCOVERED
    select distinct
        policy_ref as business_key,
        'BJAZ_CTNGY_GC_MEM_DATA' as record_source
    from {{ ref('stg_health__bjaz_ctngy_gc_mem_data') }}
    where policy_ref is not null

    union all

    -- DISCOVERED
    select distinct
        contract_id as business_key,
        'BJAZ_CTNGY_PA_MEM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_ctngy_pa_mem_dtls') }}
    where contract_id is not null

    union all

    -- DISCOVERED
    select distinct
        contract_id as business_key,
        'BJAZ_EWR_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_ewr_pol_dtls') }}
    where contract_id is not null

    union all

    -- DISCOVERED
    select distinct
        policy_ref as business_key,
        'BJAZ_EWR_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_ewr_pol_dtls') }}
    where policy_ref is not null

    union all

    -- DISCOVERED
    select distinct
        master_policy_no as business_key,
        'BJAZ_FLEXI_CYBER_DATA' as record_source
    from {{ ref('stg_health__bjaz_flexi_cyber_data') }}
    where master_policy_no is not null

    union all

    -- DISCOVERED
    select distinct
        policy_ref as business_key,
        'BJAZ_GC_GROUP_GUARD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gc_group_guard_dtls') }}
    where policy_ref is not null

    union all

    -- DISCOVERED
    select distinct
        master_policy_no as business_key,
        'BJAZ_GG_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gg_prem_dtls') }}
    where master_policy_no is not null

    union all

    -- DISCOVERED
    select distinct
        master_policy_no as business_key,
        'BJAZ_HDFC_SURK_SHOP' as record_source
    from {{ ref('stg_health__bjaz_hdfc_surk_shop') }}
    where master_policy_no is not null

    union all

    -- DISCOVERED
    select distinct
        policy_ref as business_key,
        'BJAZ_HDFC_SURK_SHOP' as record_source
    from {{ ref('stg_health__bjaz_hdfc_surk_shop') }}
    where policy_ref is not null

    union all

    -- DISCOVERED
    select distinct
        contract_id as business_key,
        'BJAZ_PA_DETL_EXTN' as record_source
    from {{ ref('stg_health__bjaz_pa_detl_extn') }}
    where contract_id is not null

    union all

    -- DISCOVERED
    select distinct
        contract_id as business_key,
        'BJAZ_PC_ONLINE_POL_DTLS_MV' as record_source
    from {{ ref('stg_health__bjaz_pc_online_pol_dtls_mv') }}
    where contract_id is not null

    union all

    -- DISCOVERED
    select distinct
        master_policy_no as business_key,
        'BJAZ_PNB_GPA_DATA' as record_source
    from {{ ref('stg_health__bjaz_pnb_gpa_data') }}
    where master_policy_no is not null

    union all

    -- DISCOVERED
    select distinct
        master_policy_no as business_key,
        'BJAZ_RR_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_rr_prem_dtls') }}
    where master_policy_no is not null

    union all

    -- DISCOVERED
    select distinct
        contract_id as business_key,
        'BJAZ_STARPKG_FF_DTLS' as record_source
    from {{ ref('stg_health__bjaz_starpkg_ff_dtls') }}
    where contract_id is not null

    union all

    -- DISCOVERED
    select distinct
        contract_id as business_key,
        'BJAZ_SUPER_SURAKSHA_DTLS' as record_source
    from {{ ref('stg_health__bjaz_super_suraksha_dtls') }}
    where contract_id is not null

    union all

    -- DISCOVERED
    select distinct
        policy_ref as business_key,
        'BJAZ_SUPER_SURAKSHA_DTLS' as record_source
    from {{ ref('stg_health__bjaz_super_suraksha_dtls') }}
    where policy_ref is not null

    union all

    -- DISCOVERED
    select distinct
        policy_no as business_key,
        'BJAZ_TRV_CLM_ITRACK_DTLS' as record_source
    from {{ ref('stg_health__bjaz_trv_clm_itrack_dtls') }}
    where policy_no is not null

    union all

    -- DISCOVERED
    select distinct
        contract_id as business_key,
        'T_PREM_DATA_COM' as record_source
    from {{ ref('stg_health__t_prem_data_com') }}
    where contract_id is not null

    union all

    -- DISCOVERED
    select distinct
        policy_ref as business_key,
        'T_PREM_DATA_COM' as record_source
    from {{ ref('stg_health__t_prem_data_com') }}
    where policy_ref is not null

)

select distinct business_key, record_source
from unioned
