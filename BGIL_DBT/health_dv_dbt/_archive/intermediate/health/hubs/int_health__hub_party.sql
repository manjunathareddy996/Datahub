-- Intermediate harmonisation view for HUB_PARTY.
-- Unions the HUB_PARTY business key from every Health source table/column carrying it. (63 of 115 source columns are discovered/mapper-confirmed, not explicitly tagged in the original mapping -- see docs.)
-- Pure UNION ALL fan-in: 0-join complexity. This view alone fully supplies hub_party.sql.

with unioned as (

    select distinct
        part_id as business_key,
        'BA_HCP_DT_MEM' as record_source
    from {{ ref('stg_health__ba_hcp_dt_mem') }}
    where part_id is not null

    union all

    select distinct
        part_id as business_key,
        'BA_HCP_DT_MEM_COV' as record_source
    from {{ ref('stg_health__ba_hcp_dt_mem_cov') }}
    where part_id is not null

    union all

    select distinct
        part_id as business_key,
        'BA_HCP_DT_POL_COV' as record_source
    from {{ ref('stg_health__ba_hcp_dt_pol_cov') }}
    where part_id is not null

    union all

    -- DISCOVERED
    select distinct
        user_id as business_key,
        'BA_HCP_DT_PREMIUM' as record_source
    from {{ ref('stg_health__ba_hcp_dt_premium') }}
    where user_id is not null

    union all

    -- DISCOVERED
    select distinct
        user_id as business_key,
        'BA_HCP_POL_MST' as record_source
    from {{ ref('stg_health__ba_hcp_pol_mst') }}
    where user_id is not null

    union all

    select distinct
        alloted_to as business_key,
        'BA_HCP_PP_MEM_DTLS' as record_source
    from {{ ref('stg_health__ba_hcp_pp_mem_dtls') }}
    where alloted_to is not null

    union all

    select distinct
        pd_premium_payer_id as business_key,
        'BA_HCP_PROD_8428_GPG_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
    where pd_premium_payer_id is not null

    union all

    select distinct
        pd_premium_payer_id as business_key,
        'BA_HCP_PROD_8432_ECP_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
    where pd_premium_payer_id is not null

    union all

    select distinct
        pd_premium_payer_id as business_key,
        'BA_HCP_PROD_8433_FHC_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
    where pd_premium_payer_id is not null

    union all

    select distinct
        pd_premium_payer_id as business_key,
        'BA_HCP_PROD_8439_CLH_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
    where pd_premium_payer_id is not null

    union all

    select distinct
        emp_code as business_key,
        'BGIL_GMC_FINAL_INSTL_DATA' as record_source
    from {{ ref('stg_health__bgil_gmc_final_instl_data') }}
    where emp_code is not null

    union all

    select distinct
        customer_id as business_key,
        'BJAZ_BANDHAN_MEDI_CLAM' as record_source
    from {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
    where customer_id is not null

    union all

    select distinct
        emp_code as business_key,
        'BJAZ_ECARD_MEMBR_DEL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_ecard_membr_del_dtls') }}
    where emp_code is not null

    union all

    select distinct
        member_no as business_key,
        'BJAZ_EC_MEM_DTLS_EXTN' as record_source
    from {{ ref('stg_health__bjaz_ec_mem_dtls_extn') }}
    where member_no is not null

    union all

    select distinct
        user_id as business_key,
        'BJAZ_GP_HOSPITAL_CASH' as record_source
    from {{ ref('stg_health__bjaz_gp_hospital_cash') }}
    where user_id is not null

    union all

    select distinct
        client_id as business_key,
        'BJAZ_GP_HOSPITAL_CASH' as record_source
    from {{ ref('stg_health__bjaz_gp_hospital_cash') }}
    where client_id is not null

    union all

    select distinct
        customer_id as business_key,
        'BJAZ_GP_HOSPITAL_CASH' as record_source
    from {{ ref('stg_health__bjaz_gp_hospital_cash') }}
    where customer_id is not null

    union all

    select distinct
        sm_code as business_key,
        'BJAZ_GP_HOSPITAL_CASH' as record_source
    from {{ ref('stg_health__bjaz_gp_hospital_cash') }}
    where sm_code is not null

    union all

    select distinct
        bdr_code as business_key,
        'BJAZ_GP_HOSPITAL_CASH' as record_source
    from {{ ref('stg_health__bjaz_gp_hospital_cash') }}
    where bdr_code is not null

    union all

    select distinct
        rm_code as business_key,
        'BJAZ_GRP_HLT_IMD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_imd_dtls') }}
    where rm_code is not null

    union all

    select distinct
        tpa_code as business_key,
        'BJAZ_GRP_TPA_EXTN' as record_source
    from {{ ref('stg_health__bjaz_grp_tpa_extn') }}
    where tpa_code is not null

    union all

    select distinct
        member_id as business_key,
        'BJAZ_HAT_CASE_OCR_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hat_case_ocr_dtls') }}
    where member_id is not null

    union all

    select distinct
        member_no as business_key,
        'BJAZ_HAT_ID_MEM_DETLS' as record_source
    from {{ ref('stg_health__bjaz_hat_id_mem_detls') }}
    where member_no is not null

    union all

    select distinct
        part_id as business_key,
        'BJAZ_HAT_ID_MEM_DETLS' as record_source
    from {{ ref('stg_health__bjaz_hat_id_mem_detls') }}
    where part_id is not null

    union all

    select distinct
        member_no as business_key,
        'BJAZ_HCF_MEMBER_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hcf_member_dtls') }}
    where member_no is not null

    union all

    select distinct
        part_id as business_key,
        'BJAZ_HC_PART_EXTN' as record_source
    from {{ ref('stg_health__bjaz_hc_part_extn') }}
    where part_id is not null

    union all

    select distinct
        client_id as business_key,
        'BJAZ_HDFC_SEC_FHPP' as record_source
    from {{ ref('stg_health__bjaz_hdfc_sec_fhpp') }}
    where client_id is not null

    union all

    select distinct
        customer_id as business_key,
        'BJAZ_HDFC_SEC_FHPP' as record_source
    from {{ ref('stg_health__bjaz_hdfc_sec_fhpp') }}
    where customer_id is not null

    union all

    select distinct
        sm_code as business_key,
        'BJAZ_HDFC_SEC_FHPP' as record_source
    from {{ ref('stg_health__bjaz_hdfc_sec_fhpp') }}
    where sm_code is not null

    union all

    select distinct
        part_id as business_key,
        'BJAZ_HG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hg_pol_dtls') }}
    where part_id is not null

    union all

    select distinct
        prospect_id as business_key,
        'BJAZ_HG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hg_pol_dtls') }}
    where prospect_id is not null

    union all

    select distinct
        member_no as business_key,
        'BJAZ_HLT_ENSURE_MEM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hlt_ensure_mem_dtls') }}
    where member_no is not null

    union all

    -- DISCOVERED
    select distinct
        part_id as business_key,
        'BJAZ_HM_BILL_PAYMENT' as record_source
    from {{ ref('stg_health__bjaz_hm_bill_payment') }}
    where part_id is not null

    union all

    select distinct
        hospital_id as business_key,
        'BJAZ_HM_CASHLESS_INWARD' as record_source
    from {{ ref('stg_health__bjaz_hm_cashless_inward') }}
    where hospital_id is not null

    union all

    select distinct
        member_id as business_key,
        'BJAZ_HM_CLM_REGISTER' as record_source
    from {{ ref('stg_health__bjaz_hm_clm_register') }}
    where member_id is not null

    union all

    select distinct
        ldr_pid as business_key,
        'BJAZ_HM_COINSU_CLM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_coinsu_clm_dtls') }}
    where ldr_pid is not null

    union all

    select distinct
        hospital_id as business_key,
        'BJAZ_HM_HCM_EXTRACT' as record_source
    from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
    where hospital_id is not null

    union all

    select distinct
        pid as business_key,
        'BJAZ_HM_HCM_EXTRACT' as record_source
    from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
    where pid is not null

    union all

    select distinct
        hosid as business_key,
        'BJAZ_HM_HOSPITAL_MASTER' as record_source
    from {{ ref('stg_health__bjaz_hm_hospital_master') }}
    where hosid is not null

    union all

    select distinct
        hosid as business_key,
        'BJAZ_HM_HOSPITAL_MASTER_EXTN' as record_source
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where hosid is not null

    union all

    select distinct
        hosid as business_key,
        'BJAZ_HM_HOSP_MASTER_EXTN1' as record_source
    from {{ ref('stg_health__bjaz_hm_hosp_master_extn1') }}
    where hosid is not null

    union all

    -- DISCOVERED
    select distinct
        part_id as business_key,
        'BJAZ_HM_INVESTI_PAYMENT' as record_source
    from {{ ref('stg_health__bjaz_hm_investi_payment') }}
    where part_id is not null

    union all

    select distinct
        courier_id as business_key,
        'BJAZ_HM_INWARD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_inward_dtls') }}
    where courier_id is not null

    union all

    select distinct
        member_id as business_key,
        'BJAZ_HM_MEMBER_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_member_dtls') }}
    where member_id is not null

    union all

    -- CONFIRMED
    select distinct
        loginname as business_key,
        'BJAZ_HM_POLICY_USERMAPPING' as record_source
    from {{ ref('stg_health__bjaz_hm_policy_usermapping') }}
    where loginname is not null

    union all

    select distinct
        hosp_id as business_key,
        'BJAZ_HM_PREAUTH_ENHANCE' as record_source
    from {{ ref('stg_health__bjaz_hm_preauth_enhance') }}
    where hosp_id is not null

    union all

    select distinct
        patient_id_card as business_key,
        'BJAZ_HM_PREAUTH_ENHANCE' as record_source
    from {{ ref('stg_health__bjaz_hm_preauth_enhance') }}
    where patient_id_card is not null

    union all

    select distinct
        hosp_id as business_key,
        'BJAZ_HM_PREAUTH_QUERY' as record_source
    from {{ ref('stg_health__bjaz_hm_preauth_query') }}
    where hosp_id is not null

    union all

    select distinct
        patient_id_card as business_key,
        'BJAZ_HM_PREAUTH_QUERY' as record_source
    from {{ ref('stg_health__bjaz_hm_preauth_query') }}
    where patient_id_card is not null

    union all

    select distinct
        member_no as business_key,
        'BJAZ_IHG_MEM_DTLS_EXTN' as record_source
    from {{ ref('stg_health__bjaz_ihg_mem_dtls_extn') }}
    where member_no is not null

    union all

    select distinct
        payer_code as business_key,
        'BJAZ_REMEDINET_CLAIM_DETAILS' as record_source
    from {{ ref('stg_health__bjaz_remedinet_claim_details') }}
    where payer_code is not null

    union all

    select distinct
        member_identifier as business_key,
        'BJAZ_SCR_HLTH_PORTABLE_DTLS' as record_source
    from {{ ref('stg_health__bjaz_scr_hlth_portable_dtls') }}
    where member_identifier is not null

    union all

    select distinct
        member_reference_key as business_key,
        'BJAZ_SCR_HLTH_PORTABLE_DTLS' as record_source
    from {{ ref('stg_health__bjaz_scr_hlth_portable_dtls') }}
    where member_reference_key is not null

    union all

    select distinct
        member_identifier_key as business_key,
        'BJAZ_SCR_HLTH_PORTABLE_DTLS' as record_source
    from {{ ref('stg_health__bjaz_scr_hlth_portable_dtls') }}
    where member_identifier_key is not null

    union all

    select distinct
        member_no as business_key,
        'BJAZ_SH_MEM_DTLS_EXTN' as record_source
    from {{ ref('stg_health__bjaz_sh_mem_dtls_extn') }}
    where member_no is not null

    union all

    select distinct
        member_no as business_key,
        'BJAZ_SPP_MEMBER_DTLS' as record_source
    from {{ ref('stg_health__bjaz_spp_member_dtls') }}
    where member_no is not null

    union all

    select distinct
        customer_id as business_key,
        'BJAZ_TPA_CLAIM_DETAILS_WS' as record_source
    from {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
    where customer_id is not null

    union all

    -- DISCOVERED
    select distinct
        prospect_id as business_key,
        'BA_HDFC_LEAD' as record_source
    from {{ ref('stg_health__ba_hdfc_lead') }}
    where prospect_id is not null

    union all

    -- DISCOVERED
    select distinct
        sm_code as business_key,
        'BA_HDFC_LEAD' as record_source
    from {{ ref('stg_health__ba_hdfc_lead') }}
    where sm_code is not null

    union all

    -- DISCOVERED
    select distinct
        bdr_code as business_key,
        'BJAZ_ADLD_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_adld_prem_dtls') }}
    where bdr_code is not null

    union all

    -- DISCOVERED
    select distinct
        client_id as business_key,
        'BJAZ_ADLD_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_adld_prem_dtls') }}
    where client_id is not null

    union all

    -- DISCOVERED
    select distinct
        customer_id as business_key,
        'BJAZ_ADLD_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_adld_prem_dtls') }}
    where customer_id is not null

    union all

    -- DISCOVERED
    select distinct
        sm_code as business_key,
        'BJAZ_ADLD_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_adld_prem_dtls') }}
    where sm_code is not null

    union all

    -- DISCOVERED
    select distinct
        user_id as business_key,
        'BJAZ_ADLD_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_adld_prem_dtls') }}
    where user_id is not null

    union all

    -- DISCOVERED
    select distinct
        hospital_id as business_key,
        'BJAZ_CLM_PRE_AUTH_HLT_DTLS' as record_source
    from {{ ref('stg_health__bjaz_clm_pre_auth_hlt_dtls') }}
    where hospital_id is not null

    union all

    -- DISCOVERED
    select distinct
        emp_code as business_key,
        'BJAZ_EWR_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_ewr_pol_dtls') }}
    where emp_code is not null

    union all

    -- DISCOVERED
    select distinct
        part_id as business_key,
        'BJAZ_EWR_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_ewr_pol_dtls') }}
    where part_id is not null

    union all

    -- DISCOVERED
    select distinct
        prospect_id as business_key,
        'BJAZ_EWR_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_ewr_pol_dtls') }}
    where prospect_id is not null

    union all

    -- DISCOVERED
    select distinct
        rm_code as business_key,
        'BJAZ_EWR_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_ewr_pol_dtls') }}
    where rm_code is not null

    union all

    -- DISCOVERED
    select distinct
        bdr_code as business_key,
        'BJAZ_FLEXI_CYBER_DATA' as record_source
    from {{ ref('stg_health__bjaz_flexi_cyber_data') }}
    where bdr_code is not null

    union all

    -- DISCOVERED
    select distinct
        client_id as business_key,
        'BJAZ_FLEXI_CYBER_DATA' as record_source
    from {{ ref('stg_health__bjaz_flexi_cyber_data') }}
    where client_id is not null

    union all

    -- DISCOVERED
    select distinct
        customer_id as business_key,
        'BJAZ_FLEXI_CYBER_DATA' as record_source
    from {{ ref('stg_health__bjaz_flexi_cyber_data') }}
    where customer_id is not null

    union all

    -- DISCOVERED
    select distinct
        sm_code as business_key,
        'BJAZ_FLEXI_CYBER_DATA' as record_source
    from {{ ref('stg_health__bjaz_flexi_cyber_data') }}
    where sm_code is not null

    union all

    -- DISCOVERED
    select distinct
        user_id as business_key,
        'BJAZ_FLEXI_CYBER_DATA' as record_source
    from {{ ref('stg_health__bjaz_flexi_cyber_data') }}
    where user_id is not null

    union all

    -- DISCOVERED
    select distinct
        user_id as business_key,
        'BJAZ_GC_GROUP_GUARD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gc_group_guard_dtls') }}
    where user_id is not null

    union all

    -- DISCOVERED
    select distinct
        bdr_code as business_key,
        'BJAZ_GG_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gg_prem_dtls') }}
    where bdr_code is not null

    union all

    -- DISCOVERED
    select distinct
        client_id as business_key,
        'BJAZ_GG_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gg_prem_dtls') }}
    where client_id is not null

    union all

    -- DISCOVERED
    select distinct
        customer_id as business_key,
        'BJAZ_GG_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gg_prem_dtls') }}
    where customer_id is not null

    union all

    -- DISCOVERED
    select distinct
        sm_code as business_key,
        'BJAZ_GG_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gg_prem_dtls') }}
    where sm_code is not null

    union all

    -- DISCOVERED
    select distinct
        user_id as business_key,
        'BJAZ_GG_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gg_prem_dtls') }}
    where user_id is not null

    union all

    -- DISCOVERED
    select distinct
        bdr_code as business_key,
        'BJAZ_HDFC_FLEXIPA' as record_source
    from {{ ref('stg_health__bjaz_hdfc_flexipa') }}
    where bdr_code is not null

    union all

    -- DISCOVERED
    select distinct
        client_id as business_key,
        'BJAZ_HDFC_FLEXIPA' as record_source
    from {{ ref('stg_health__bjaz_hdfc_flexipa') }}
    where client_id is not null

    union all

    -- DISCOVERED
    select distinct
        customer_id as business_key,
        'BJAZ_HDFC_FLEXIPA' as record_source
    from {{ ref('stg_health__bjaz_hdfc_flexipa') }}
    where customer_id is not null

    union all

    -- DISCOVERED
    select distinct
        sm_code as business_key,
        'BJAZ_HDFC_FLEXIPA' as record_source
    from {{ ref('stg_health__bjaz_hdfc_flexipa') }}
    where sm_code is not null

    union all

    -- DISCOVERED
    select distinct
        user_id as business_key,
        'BJAZ_HDFC_FLEXIPA' as record_source
    from {{ ref('stg_health__bjaz_hdfc_flexipa') }}
    where user_id is not null

    union all

    -- DISCOVERED
    select distinct
        user_id as business_key,
        'BJAZ_HDFC_SURK_SHOP' as record_source
    from {{ ref('stg_health__bjaz_hdfc_surk_shop') }}
    where user_id is not null

    union all

    -- DISCOVERED
    select distinct
        part_id as business_key,
        'BJAZ_PC_ONLINE_POL_DTLS_MV' as record_source
    from {{ ref('stg_health__bjaz_pc_online_pol_dtls_mv') }}
    where part_id is not null

    union all

    -- DISCOVERED
    select distinct
        bdr_code as business_key,
        'BJAZ_PNB_GPA_DATA' as record_source
    from {{ ref('stg_health__bjaz_pnb_gpa_data') }}
    where bdr_code is not null

    union all

    -- DISCOVERED
    select distinct
        client_id as business_key,
        'BJAZ_PNB_GPA_DATA' as record_source
    from {{ ref('stg_health__bjaz_pnb_gpa_data') }}
    where client_id is not null

    union all

    -- DISCOVERED
    select distinct
        customer_id as business_key,
        'BJAZ_PNB_GPA_DATA' as record_source
    from {{ ref('stg_health__bjaz_pnb_gpa_data') }}
    where customer_id is not null

    union all

    -- DISCOVERED
    select distinct
        sm_code as business_key,
        'BJAZ_PNB_GPA_DATA' as record_source
    from {{ ref('stg_health__bjaz_pnb_gpa_data') }}
    where sm_code is not null

    union all

    -- DISCOVERED
    select distinct
        user_id as business_key,
        'BJAZ_PNB_GPA_DATA' as record_source
    from {{ ref('stg_health__bjaz_pnb_gpa_data') }}
    where user_id is not null

    union all

    -- DISCOVERED
    select distinct
        bdr_code as business_key,
        'BJAZ_RR_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_rr_prem_dtls') }}
    where bdr_code is not null

    union all

    -- DISCOVERED
    select distinct
        client_id as business_key,
        'BJAZ_RR_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_rr_prem_dtls') }}
    where client_id is not null

    union all

    -- DISCOVERED
    select distinct
        customer_id as business_key,
        'BJAZ_RR_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_rr_prem_dtls') }}
    where customer_id is not null

    union all

    -- DISCOVERED
    select distinct
        sm_code as business_key,
        'BJAZ_RR_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_rr_prem_dtls') }}
    where sm_code is not null

    union all

    -- DISCOVERED
    select distinct
        user_id as business_key,
        'BJAZ_RR_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_rr_prem_dtls') }}
    where user_id is not null

    union all

    -- DISCOVERED
    select distinct
        customer_id as business_key,
        'BJAZ_SUPER_SURAKSHA_DTLS' as record_source
    from {{ ref('stg_health__bjaz_super_suraksha_dtls') }}
    where customer_id is not null

    union all

    -- DISCOVERED
    select distinct
        user_id as business_key,
        'BJAZ_SUPER_SURAKSHA_DTLS' as record_source
    from {{ ref('stg_health__bjaz_super_suraksha_dtls') }}
    where user_id is not null

    union all

    -- REANCHOR
    select distinct
        hospital_code as business_key,
        'BJAZ_TPA_CLAIM_DETAILS_WS' as record_source
    from {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
    where hospital_code is not null

    union all

    -- REANCHOR
    select distinct
        pd_imd_rm_e_code as business_key,
        'BA_HCP_PROD_8428_GPG_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
    where pd_imd_rm_e_code is not null

    union all

    -- REANCHOR
    select distinct
        pd_bagic_rm_e_code as business_key,
        'BA_HCP_PROD_8428_GPG_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
    where pd_bagic_rm_e_code is not null

    union all

    -- REANCHOR
    select distinct
        pd_imd_rm_e_code as business_key,
        'BA_HCP_PROD_8432_ECP_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
    where pd_imd_rm_e_code is not null

    union all

    -- REANCHOR
    select distinct
        pd_bagic_rm_e_code as business_key,
        'BA_HCP_PROD_8432_ECP_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
    where pd_bagic_rm_e_code is not null

    union all

    -- REANCHOR
    select distinct
        pd_imd_rm_e_code as business_key,
        'BA_HCP_PROD_8433_FHC_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
    where pd_imd_rm_e_code is not null

    union all

    -- REANCHOR
    select distinct
        pd_bagic_rm_e_code as business_key,
        'BA_HCP_PROD_8433_FHC_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
    where pd_bagic_rm_e_code is not null

    union all

    -- REANCHOR
    select distinct
        pd_imd_rm_e_code as business_key,
        'BA_HCP_PROD_8439_CLH_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
    where pd_imd_rm_e_code is not null

    union all

    -- REANCHOR
    select distinct
        pd_bagic_rm_e_code as business_key,
        'BA_HCP_PROD_8439_CLH_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
    where pd_bagic_rm_e_code is not null

    union all

    -- REANCHOR
    select distinct
        bagic_e_code as business_key,
        'BJAZ_GPG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gpg_pol_dtls') }}
    where bagic_e_code is not null

    union all

    -- REANCHOR
    select distinct
        imd_code as business_key,
        'BJAZ_GPG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gpg_pol_dtls') }}
    where imd_code is not null

    union all

    -- REANCHOR
    select distinct
        sub_imd_code as business_key,
        'BJAZ_GPG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gpg_pol_dtls') }}
    where sub_imd_code is not null

    union all

    -- REANCHOR
    select distinct
        bagic_rm_e_code as business_key,
        'BJAZ_GPG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gpg_pol_dtls') }}
    where bagic_rm_e_code is not null

    union all

    -- REANCHOR
    select distinct
        imd_code as business_key,
        'BJAZ_GRP_HLT_IMD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_imd_dtls') }}
    where imd_code is not null

    union all

    -- REANCHOR
    select distinct
        sub_imd_code as business_key,
        'BJAZ_GRP_HLT_IMD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_imd_dtls') }}
    where sub_imd_code is not null

    union all

    -- REANCHOR
    select distinct
        remedinet_provider_code as business_key,
        'BJAZ_REMEDINET_CLAIM_DETAILS' as record_source
    from {{ ref('stg_health__bjaz_remedinet_claim_details') }}
    where remedinet_provider_code is not null

)

select distinct business_key, record_source
from unioned
