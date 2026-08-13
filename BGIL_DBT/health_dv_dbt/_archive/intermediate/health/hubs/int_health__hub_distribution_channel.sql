-- Intermediate harmonisation view for HUB_DISTRIBUTION_CHANNEL.
-- Unions the HUB_DISTRIBUTION_CHANNEL business key from every Health source table/column carrying it. (44 of 90 source columns are discovered/mapper-confirmed, not explicitly tagged in the original mapping -- see docs.)
-- Pure UNION ALL fan-in: 0-join complexity. This view alone fully supplies hub_distribution_channel.sql.

with unioned as (

    select distinct
        partner_id as business_key,
        'BA_HCP_POL_MST' as record_source
    from {{ ref('stg_health__ba_hcp_pol_mst') }}
    where partner_id is not null

    union all

    select distinct
        imd_code as business_key,
        'BA_HCP_POL_MST' as record_source
    from {{ ref('stg_health__ba_hcp_pol_mst') }}
    where imd_code is not null

    union all

    select distinct
        sub_imd_code as business_key,
        'BA_HCP_POL_MST' as record_source
    from {{ ref('stg_health__ba_hcp_pol_mst') }}
    where sub_imd_code is not null

    union all

    select distinct
        partner_id as business_key,
        'BA_HCP_PORT_WORDINGS' as record_source
    from {{ ref('stg_health__ba_hcp_port_wordings') }}
    where partner_id is not null

    union all

    select distinct
        pd_partner_id as business_key,
        'BA_HCP_PROD_8428_GPG_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
    where pd_partner_id is not null

    union all

    select distinct
        pd_imd_code as business_key,
        'BA_HCP_PROD_8428_GPG_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
    where pd_imd_code is not null

    union all

    select distinct
        pd_partner_id as business_key,
        'BA_HCP_PROD_8432_ECP_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
    where pd_partner_id is not null

    union all

    select distinct
        pd_imd_code as business_key,
        'BA_HCP_PROD_8432_ECP_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
    where pd_imd_code is not null

    union all

    select distinct
        pd_partner_id as business_key,
        'BA_HCP_PROD_8433_FHC_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
    where pd_partner_id is not null

    union all

    select distinct
        pd_imd_code as business_key,
        'BA_HCP_PROD_8433_FHC_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
    where pd_imd_code is not null

    union all

    select distinct
        pd_partner_id as business_key,
        'BA_HCP_PROD_8439_CLH_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
    where pd_partner_id is not null

    union all

    select distinct
        pd_imd_code as business_key,
        'BA_HCP_PROD_8439_CLH_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
    where pd_imd_code is not null

    union all

    select distinct
        partner_id as business_key,
        'BJAZ_BANDHAN_MEDI_CLAM' as record_source
    from {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
    where partner_id is not null

    union all

    select distinct
        imd_code as business_key,
        'BJAZ_BANDHAN_MEDI_CLAM' as record_source
    from {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
    where imd_code is not null

    union all

    select distinct
        subimd_code as business_key,
        'BJAZ_BANDHAN_MEDI_CLAM' as record_source
    from {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
    where subimd_code is not null

    union all

    select distinct
        lg_code as business_key,
        'BJAZ_BANDHAN_MEDI_CLAM' as record_source
    from {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
    where lg_code is not null

    union all

    select distinct
        partner_id as business_key,
        'BJAZ_CARD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_card_dtls') }}
    where partner_id is not null

    union all

    select distinct
        partner_id as business_key,
        'BJAZ_CTNGY_SCHEME_MST' as record_source
    from {{ ref('stg_health__bjaz_ctngy_scheme_mst') }}
    where partner_id is not null

    union all

    select distinct
        partner_id as business_key,
        'BJAZ_EC_MEM_DTLS_EXTN' as record_source
    from {{ ref('stg_health__bjaz_ec_mem_dtls_extn') }}
    where partner_id is not null

    union all

    select distinct
        partner_id as business_key,
        'BJAZ_EHH_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_ehh_pol_dtls') }}
    where partner_id is not null

    union all

    select distinct
        main_agent_code as business_key,
        'BJAZ_EHH_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_ehh_pol_dtls') }}
    where main_agent_code is not null

    union all

    select distinct
        partnerid as business_key,
        'BJAZ_GENERIC_LOADER_LOG_TABLE' as record_source
    from {{ ref('stg_health__bjaz_generic_loader_log_table') }}
    where partnerid is not null

    union all

    select distinct
        imd_code as business_key,
        'BJAZ_GPG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gpg_pol_dtls') }}
    where imd_code is not null

    union all

    select distinct
        sub_imd_code as business_key,
        'BJAZ_GPG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gpg_pol_dtls') }}
    where sub_imd_code is not null

    union all

    select distinct
        imd_code as business_key,
        'BJAZ_GP_HOSPITAL_CASH' as record_source
    from {{ ref('stg_health__bjaz_gp_hospital_cash') }}
    where imd_code is not null

    union all

    select distinct
        subimd_id as business_key,
        'BJAZ_GP_HOSPITAL_CASH' as record_source
    from {{ ref('stg_health__bjaz_gp_hospital_cash') }}
    where subimd_id is not null

    union all

    select distinct
        partner_id as business_key,
        'BJAZ_GP_HOSPITAL_CASH' as record_source
    from {{ ref('stg_health__bjaz_gp_hospital_cash') }}
    where partner_id is not null

    union all

    select distinct
        imd_code as business_key,
        'BJAZ_GRP_HLT_IMD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_imd_dtls') }}
    where imd_code is not null

    union all

    select distinct
        sub_imd_code as business_key,
        'BJAZ_GRP_HLT_IMD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_imd_dtls') }}
    where sub_imd_code is not null

    union all

    -- DISCOVERED
    select distinct
        imd_code as business_key,
        'BJAZ_HAT_CASE_OCR_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hat_case_ocr_dtls') }}
    where imd_code is not null

    union all

    select distinct
        partner_id as business_key,
        'BJAZ_HCF_MEMBER_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hcf_member_dtls') }}
    where partner_id is not null

    union all

    select distinct
        imd_code as business_key,
        'BJAZ_HCP_TRANSCRIPT_URL' as record_source
    from {{ ref('stg_health__bjaz_hcp_transcript_url') }}
    where imd_code is not null

    union all

    select distinct
        imd_code as business_key,
        'BJAZ_HDFC_SEC_FHPP' as record_source
    from {{ ref('stg_health__bjaz_hdfc_sec_fhpp') }}
    where imd_code is not null

    union all

    select distinct
        subimd_id as business_key,
        'BJAZ_HDFC_SEC_FHPP' as record_source
    from {{ ref('stg_health__bjaz_hdfc_sec_fhpp') }}
    where subimd_id is not null

    union all

    select distinct
        partner_id as business_key,
        'BJAZ_HDFC_SEC_FHPP' as record_source
    from {{ ref('stg_health__bjaz_hdfc_sec_fhpp') }}
    where partner_id is not null

    union all

    select distinct
        partner_id as business_key,
        'BJAZ_HEALTH_WEBSERVICE_INFO' as record_source
    from {{ ref('stg_health__bjaz_health_webservice_info') }}
    where partner_id is not null

    union all

    select distinct
        imd_code as business_key,
        'BJAZ_HEALTH_WEBSERVICE_INFO' as record_source
    from {{ ref('stg_health__bjaz_health_webservice_info') }}
    where imd_code is not null

    union all

    select distinct
        sub_imd_code as business_key,
        'BJAZ_HEALTH_WEBSERVICE_INFO' as record_source
    from {{ ref('stg_health__bjaz_health_webservice_info') }}
    where sub_imd_code is not null

    union all

    select distinct
        business_source as business_key,
        'BJAZ_HG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hg_pol_dtls') }}
    where business_source is not null

    union all

    select distinct
        main_agent_code as business_key,
        'BJAZ_HG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hg_pol_dtls') }}
    where main_agent_code is not null

    union all

    select distinct
        partner_id as business_key,
        'BJAZ_HLT_ENSURE_MEM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hlt_ensure_mem_dtls') }}
    where partner_id is not null

    union all

    -- DISCOVERED
    select distinct
        main_agent_code as business_key,
        'BJAZ_HM_CLM_REGISTER' as record_source
    from {{ ref('stg_health__bjaz_hm_clm_register') }}
    where main_agent_code is not null

    union all

    select distinct
        imd_code as business_key,
        'BJAZ_HM_HCM_EXTRACT' as record_source
    from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
    where imd_code is not null

    union all

    select distinct
        partner_id as business_key,
        'BJAZ_HM_HCM_EXTRACT' as record_source
    from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
    where partner_id is not null

    union all

    -- DISCOVERED
    select distinct
        partner_id as business_key,
        'BJAZ_HM_HOSPITAL_MASTER' as record_source
    from {{ ref('stg_health__bjaz_hm_hospital_master') }}
    where partner_id is not null

    union all

    select distinct
        distribution_partner as business_key,
        'BJAZ_HM_HOSPITAL_MASTER_EXTN' as record_source
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where distribution_partner is not null

    union all

    select distinct
        partner_id as business_key,
        'BJAZ_HM_MEMBER_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_member_dtls') }}
    where partner_id is not null

    union all

    select distinct
        partner_id as business_key,
        'BJAZ_IHG_MEM_DTLS_EXTN' as record_source
    from {{ ref('stg_health__bjaz_ihg_mem_dtls_extn') }}
    where partner_id is not null

    union all

    select distinct
        partner_id as business_key,
        'BJAZ_SH_MEM_DTLS_EXTN' as record_source
    from {{ ref('stg_health__bjaz_sh_mem_dtls_extn') }}
    where partner_id is not null

    union all

    -- DISCOVERED
    select distinct
        partner_id as business_key,
        'BJAZ_SPP_MEMBER_DTLS' as record_source
    from {{ ref('stg_health__bjaz_spp_member_dtls') }}
    where partner_id is not null

    union all

    -- DISCOVERED
    select distinct
        partner_id as business_key,
        'BJAZ_TPA_CLAIM_DETAILS_WS' as record_source
    from {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
    where partner_id is not null

    union all

    -- DISCOVERED
    select distinct
        imd_code as business_key,
        'BJAZ_ADLD_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_adld_prem_dtls') }}
    where imd_code is not null

    union all

    -- DISCOVERED
    select distinct
        partner_id as business_key,
        'BJAZ_ADLD_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_adld_prem_dtls') }}
    where partner_id is not null

    union all

    -- DISCOVERED
    select distinct
        subimd_id as business_key,
        'BJAZ_ADLD_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_adld_prem_dtls') }}
    where subimd_id is not null

    union all

    -- DISCOVERED
    select distinct
        imd_code as business_key,
        'BJAZ_CLM_SUPP_EXTN' as record_source
    from {{ ref('stg_health__bjaz_clm_supp_extn') }}
    where imd_code is not null

    union all

    -- DISCOVERED
    select distinct
        partner_id as business_key,
        'BJAZ_CLM_SUPP_EXTN' as record_source
    from {{ ref('stg_health__bjaz_clm_supp_extn') }}
    where partner_id is not null

    union all

    -- DISCOVERED
    select distinct
        sub_imd_code as business_key,
        'BJAZ_CLM_SUPP_EXTN' as record_source
    from {{ ref('stg_health__bjaz_clm_supp_extn') }}
    where sub_imd_code is not null

    union all

    -- DISCOVERED
    select distinct
        partner_id as business_key,
        'BJAZ_CTNGY_FF_DTLS_EXTN' as record_source
    from {{ ref('stg_health__bjaz_ctngy_ff_dtls_extn') }}
    where partner_id is not null

    union all

    -- DISCOVERED
    select distinct
        partner_id as business_key,
        'BJAZ_CTNGY_GC_MEM_DATA' as record_source
    from {{ ref('stg_health__bjaz_ctngy_gc_mem_data') }}
    where partner_id is not null

    union all

    -- DISCOVERED
    select distinct
        partner_id as business_key,
        'BJAZ_CTNGY_PA_MEM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_ctngy_pa_mem_dtls') }}
    where partner_id is not null

    union all

    -- DISCOVERED
    select distinct
        business_source as business_key,
        'BJAZ_EWR_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_ewr_pol_dtls') }}
    where business_source is not null

    union all

    -- DISCOVERED
    select distinct
        main_agent_code as business_key,
        'BJAZ_EWR_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_ewr_pol_dtls') }}
    where main_agent_code is not null

    union all

    -- DISCOVERED
    select distinct
        imd_code as business_key,
        'BJAZ_FLEXI_CYBER_DATA' as record_source
    from {{ ref('stg_health__bjaz_flexi_cyber_data') }}
    where imd_code is not null

    union all

    -- DISCOVERED
    select distinct
        partner_id as business_key,
        'BJAZ_FLEXI_CYBER_DATA' as record_source
    from {{ ref('stg_health__bjaz_flexi_cyber_data') }}
    where partner_id is not null

    union all

    -- DISCOVERED
    select distinct
        subimd_id as business_key,
        'BJAZ_FLEXI_CYBER_DATA' as record_source
    from {{ ref('stg_health__bjaz_flexi_cyber_data') }}
    where subimd_id is not null

    union all

    -- DISCOVERED
    select distinct
        lg_code as business_key,
        'BJAZ_GC_GROUP_GUARD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gc_group_guard_dtls') }}
    where lg_code is not null

    union all

    -- DISCOVERED
    select distinct
        partner_id as business_key,
        'BJAZ_GC_GROUP_GUARD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gc_group_guard_dtls') }}
    where partner_id is not null

    union all

    -- DISCOVERED
    select distinct
        imd_code as business_key,
        'BJAZ_GG_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gg_prem_dtls') }}
    where imd_code is not null

    union all

    -- DISCOVERED
    select distinct
        partner_id as business_key,
        'BJAZ_GG_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gg_prem_dtls') }}
    where partner_id is not null

    union all

    -- DISCOVERED
    select distinct
        subimd_id as business_key,
        'BJAZ_GG_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gg_prem_dtls') }}
    where subimd_id is not null

    union all

    -- DISCOVERED
    select distinct
        imd_code as business_key,
        'BJAZ_HDFC_FLEXIPA' as record_source
    from {{ ref('stg_health__bjaz_hdfc_flexipa') }}
    where imd_code is not null

    union all

    -- DISCOVERED
    select distinct
        partner_id as business_key,
        'BJAZ_HDFC_FLEXIPA' as record_source
    from {{ ref('stg_health__bjaz_hdfc_flexipa') }}
    where partner_id is not null

    union all

    -- DISCOVERED
    select distinct
        subimd_id as business_key,
        'BJAZ_HDFC_FLEXIPA' as record_source
    from {{ ref('stg_health__bjaz_hdfc_flexipa') }}
    where subimd_id is not null

    union all

    -- DISCOVERED
    select distinct
        imd_code as business_key,
        'BJAZ_HDFC_SURK_SHOP' as record_source
    from {{ ref('stg_health__bjaz_hdfc_surk_shop') }}
    where imd_code is not null

    union all

    -- DISCOVERED
    select distinct
        partner_id as business_key,
        'BJAZ_HDFC_SURK_SHOP' as record_source
    from {{ ref('stg_health__bjaz_hdfc_surk_shop') }}
    where partner_id is not null

    union all

    -- DISCOVERED
    select distinct
        subimd_id as business_key,
        'BJAZ_HDFC_SURK_SHOP' as record_source
    from {{ ref('stg_health__bjaz_hdfc_surk_shop') }}
    where subimd_id is not null

    union all

    -- DISCOVERED
    select distinct
        partner_id as business_key,
        'BJAZ_PA_DETL_EXTN' as record_source
    from {{ ref('stg_health__bjaz_pa_detl_extn') }}
    where partner_id is not null

    union all

    -- DISCOVERED
    select distinct
        main_agent_code as business_key,
        'BJAZ_PC_ONLINE_POL_DTLS_MV' as record_source
    from {{ ref('stg_health__bjaz_pc_online_pol_dtls_mv') }}
    where main_agent_code is not null

    union all

    -- DISCOVERED
    select distinct
        imd_code as business_key,
        'BJAZ_PNB_GPA_DATA' as record_source
    from {{ ref('stg_health__bjaz_pnb_gpa_data') }}
    where imd_code is not null

    union all

    -- DISCOVERED
    select distinct
        partner_id as business_key,
        'BJAZ_PNB_GPA_DATA' as record_source
    from {{ ref('stg_health__bjaz_pnb_gpa_data') }}
    where partner_id is not null

    union all

    -- DISCOVERED
    select distinct
        subimd_id as business_key,
        'BJAZ_PNB_GPA_DATA' as record_source
    from {{ ref('stg_health__bjaz_pnb_gpa_data') }}
    where subimd_id is not null

    union all

    -- DISCOVERED
    select distinct
        imd_code as business_key,
        'BJAZ_RR_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_rr_prem_dtls') }}
    where imd_code is not null

    union all

    -- DISCOVERED
    select distinct
        partner_id as business_key,
        'BJAZ_RR_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_rr_prem_dtls') }}
    where partner_id is not null

    union all

    -- DISCOVERED
    select distinct
        subimd_id as business_key,
        'BJAZ_RR_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_rr_prem_dtls') }}
    where subimd_id is not null

    union all

    -- DISCOVERED
    select distinct
        partner_id as business_key,
        'BJAZ_SCRUTINY_IP_DTLS' as record_source
    from {{ ref('stg_health__bjaz_scrutiny_ip_dtls') }}
    where partner_id is not null

    union all

    -- DISCOVERED
    select distinct
        partner_id as business_key,
        'BJAZ_STARPKG_FF_DTLS' as record_source
    from {{ ref('stg_health__bjaz_starpkg_ff_dtls') }}
    where partner_id is not null

    union all

    -- DISCOVERED
    select distinct
        imd_code as business_key,
        'BJAZ_SUPER_SURAKSHA_DTLS' as record_source
    from {{ ref('stg_health__bjaz_super_suraksha_dtls') }}
    where imd_code is not null

    union all

    -- DISCOVERED
    select distinct
        partner_id as business_key,
        'BJAZ_SUPER_SURAKSHA_DTLS' as record_source
    from {{ ref('stg_health__bjaz_super_suraksha_dtls') }}
    where partner_id is not null

    union all

    -- DISCOVERED
    select distinct
        subimd_code as business_key,
        'BJAZ_SUPER_SURAKSHA_DTLS' as record_source
    from {{ ref('stg_health__bjaz_super_suraksha_dtls') }}
    where subimd_code is not null

    union all

    -- DISCOVERED
    select distinct
        partner_id as business_key,
        'T_PREM_DATA_COM' as record_source
    from {{ ref('stg_health__t_prem_data_com') }}
    where partner_id is not null

)

select distinct business_key, record_source
from unioned
