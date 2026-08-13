-- Intermediate harmonisation view for LNK_POLICY_PARTY (Policy Party).
-- Derived link: co-occurrence of the member hub business keys (explicit/discovered/mapper-
-- confirmed) on the same Health source row is treated as evidence of the association.
-- Pure UNION ALL: 0-join complexity.

with unioned as (

    select distinct
        part_id as party_bk,
        contract_id as policy_bk,
        'BA_HCP_DT_MEM' as record_source
    from {{ ref('stg_health__ba_hcp_dt_mem') }}
    where part_id is not null and contract_id is not null

    union all

    select distinct
        part_id as party_bk,
        contract_id as policy_bk,
        'BA_HCP_DT_MEM_COV' as record_source
    from {{ ref('stg_health__ba_hcp_dt_mem_cov') }}
    where part_id is not null and contract_id is not null

    union all

    select distinct
        part_id as party_bk,
        contract_id as policy_bk,
        'BA_HCP_DT_POL_COV' as record_source
    from {{ ref('stg_health__ba_hcp_dt_pol_cov') }}
    where part_id is not null and contract_id is not null

    union all

    select distinct
        user_id as party_bk,
        contract_id as policy_bk,
        'BA_HCP_DT_PREMIUM' as record_source
    from {{ ref('stg_health__ba_hcp_dt_premium') }}
    where user_id is not null and contract_id is not null

    union all

    select distinct
        user_id as party_bk,
        contract_id as policy_bk,
        'BA_HCP_POL_MST' as record_source
    from {{ ref('stg_health__ba_hcp_pol_mst') }}
    where user_id is not null and contract_id is not null

    union all

    select distinct
        alloted_to as party_bk,
        contract_id as policy_bk,
        'BA_HCP_PP_MEM_DTLS' as record_source
    from {{ ref('stg_health__ba_hcp_pp_mem_dtls') }}
    where alloted_to is not null and contract_id is not null

    union all

    select distinct
        pd_premium_payer_id as party_bk,
        pol_serial_no as policy_bk,
        'BA_HCP_PROD_8428_GPG_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
    where pd_premium_payer_id is not null and pol_serial_no is not null

    union all

    select distinct
        pd_premium_payer_id as party_bk,
        pol_serial_no as policy_bk,
        'BA_HCP_PROD_8432_ECP_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
    where pd_premium_payer_id is not null and pol_serial_no is not null

    union all

    select distinct
        pd_premium_payer_id as party_bk,
        pol_serial_no as policy_bk,
        'BA_HCP_PROD_8433_FHC_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
    where pd_premium_payer_id is not null and pol_serial_no is not null

    union all

    select distinct
        pd_premium_payer_id as party_bk,
        pol_serial_no as policy_bk,
        'BA_HCP_PROD_8439_CLH_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
    where pd_premium_payer_id is not null and pol_serial_no is not null

    union all

    select distinct
        emp_code as party_bk,
        policy_no as policy_bk,
        'BGIL_GMC_FINAL_INSTL_DATA' as record_source
    from {{ ref('stg_health__bgil_gmc_final_instl_data') }}
    where emp_code is not null and policy_no is not null

    union all

    select distinct
        customer_id as party_bk,
        policy_ref as policy_bk,
        'BJAZ_BANDHAN_MEDI_CLAM' as record_source
    from {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
    where customer_id is not null and policy_ref is not null

    union all

    select distinct
        member_no as party_bk,
        contract_id as policy_bk,
        'BJAZ_EC_MEM_DTLS_EXTN' as record_source
    from {{ ref('stg_health__bjaz_ec_mem_dtls_extn') }}
    where member_no is not null and contract_id is not null

    union all

    select distinct
        bagic_e_code as party_bk,
        reference_id as policy_bk,
        'BJAZ_GPG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gpg_pol_dtls') }}
    where bagic_e_code is not null and reference_id is not null

    union all

    select distinct
        user_id as party_bk,
        master_policy_no as policy_bk,
        'BJAZ_GP_HOSPITAL_CASH' as record_source
    from {{ ref('stg_health__bjaz_gp_hospital_cash') }}
    where user_id is not null and master_policy_no is not null

    union all

    select distinct
        rm_code as party_bk,
        reg_no as policy_bk,
        'BJAZ_GRP_HLT_IMD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_imd_dtls') }}
    where rm_code is not null and reg_no is not null

    union all

    select distinct
        tpa_code as party_bk,
        contract_id as policy_bk,
        'BJAZ_GRP_TPA_EXTN' as record_source
    from {{ ref('stg_health__bjaz_grp_tpa_extn') }}
    where tpa_code is not null and contract_id is not null

    union all

    select distinct
        member_id as party_bk,
        policy_number as policy_bk,
        'BJAZ_HAT_CASE_OCR_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hat_case_ocr_dtls') }}
    where member_id is not null and policy_number is not null

    union all

    select distinct
        member_no as party_bk,
        contract_id as policy_bk,
        'BJAZ_HAT_ID_MEM_DETLS' as record_source
    from {{ ref('stg_health__bjaz_hat_id_mem_detls') }}
    where member_no is not null and contract_id is not null

    union all

    select distinct
        member_no as party_bk,
        contract_id as policy_bk,
        'BJAZ_HCF_MEMBER_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hcf_member_dtls') }}
    where member_no is not null and contract_id is not null

    union all

    select distinct
        part_id as party_bk,
        contract_id as policy_bk,
        'BJAZ_HC_PART_EXTN' as record_source
    from {{ ref('stg_health__bjaz_hc_part_extn') }}
    where part_id is not null and contract_id is not null

    union all

    select distinct
        client_id as party_bk,
        reference_id as policy_bk,
        'BJAZ_HDFC_SEC_FHPP' as record_source
    from {{ ref('stg_health__bjaz_hdfc_sec_fhpp') }}
    where client_id is not null and reference_id is not null

    union all

    select distinct
        part_id as party_bk,
        contract_id as policy_bk,
        'BJAZ_HG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hg_pol_dtls') }}
    where part_id is not null and contract_id is not null

    union all

    select distinct
        member_no as party_bk,
        contract_id as policy_bk,
        'BJAZ_HLT_ENSURE_MEM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hlt_ensure_mem_dtls') }}
    where member_no is not null and contract_id is not null

    union all

    select distinct
        hospital_id as party_bk,
        policy_ref as policy_bk,
        'BJAZ_HM_CASHLESS_INWARD' as record_source
    from {{ ref('stg_health__bjaz_hm_cashless_inward') }}
    where hospital_id is not null and policy_ref is not null

    union all

    select distinct
        member_id as party_bk,
        contract_id as policy_bk,
        'BJAZ_HM_CLM_REGISTER' as record_source
    from {{ ref('stg_health__bjaz_hm_clm_register') }}
    where member_id is not null and contract_id is not null

    union all

    select distinct
        ldr_pid as party_bk,
        policy_ref as policy_bk,
        'BJAZ_HM_COINSU_CLM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_coinsu_clm_dtls') }}
    where ldr_pid is not null and policy_ref is not null

    union all

    select distinct
        hospital_id as party_bk,
        policy as policy_bk,
        'BJAZ_HM_HCM_EXTRACT' as record_source
    from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
    where hospital_id is not null and policy is not null

    union all

    select distinct
        courier_id as party_bk,
        policy_ref as policy_bk,
        'BJAZ_HM_INWARD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_inward_dtls') }}
    where courier_id is not null and policy_ref is not null

    union all

    select distinct
        member_id as party_bk,
        contract_id as policy_bk,
        'BJAZ_HM_MEMBER_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_member_dtls') }}
    where member_id is not null and contract_id is not null

    union all

    select distinct
        loginname as party_bk,
        policy_ref as policy_bk,
        'BJAZ_HM_POLICY_USERMAPPING' as record_source
    from {{ ref('stg_health__bjaz_hm_policy_usermapping') }}
    where loginname is not null and policy_ref is not null

    union all

    select distinct
        member_no as party_bk,
        contract_id as policy_bk,
        'BJAZ_IHG_MEM_DTLS_EXTN' as record_source
    from {{ ref('stg_health__bjaz_ihg_mem_dtls_extn') }}
    where member_no is not null and contract_id is not null

    union all

    select distinct
        payer_code as party_bk,
        policy_no as policy_bk,
        'BJAZ_REMEDINET_CLAIM_DETAILS' as record_source
    from {{ ref('stg_health__bjaz_remedinet_claim_details') }}
    where payer_code is not null and policy_no is not null

    union all

    select distinct
        member_no as party_bk,
        contract_id as policy_bk,
        'BJAZ_SH_MEM_DTLS_EXTN' as record_source
    from {{ ref('stg_health__bjaz_sh_mem_dtls_extn') }}
    where member_no is not null and contract_id is not null

    union all

    select distinct
        member_no as party_bk,
        contract_id as policy_bk,
        'BJAZ_SPP_MEMBER_DTLS' as record_source
    from {{ ref('stg_health__bjaz_spp_member_dtls') }}
    where member_no is not null and contract_id is not null

    union all

    select distinct
        customer_id as party_bk,
        policy_no as policy_bk,
        'BJAZ_TPA_CLAIM_DETAILS_WS' as record_source
    from {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
    where customer_id is not null and policy_no is not null

    union all

    select distinct
        prospect_id as party_bk,
        policy_ref as policy_bk,
        'BA_HDFC_LEAD' as record_source
    from {{ ref('stg_health__ba_hdfc_lead') }}
    where prospect_id is not null and policy_ref is not null

    union all

    select distinct
        bdr_code as party_bk,
        master_policy_no as policy_bk,
        'BJAZ_ADLD_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_adld_prem_dtls') }}
    where bdr_code is not null and master_policy_no is not null

    union all

    select distinct
        hospital_id as party_bk,
        contract_id as policy_bk,
        'BJAZ_CLM_PRE_AUTH_HLT_DTLS' as record_source
    from {{ ref('stg_health__bjaz_clm_pre_auth_hlt_dtls') }}
    where hospital_id is not null and contract_id is not null

    union all

    select distinct
        emp_code as party_bk,
        contract_id as policy_bk,
        'BJAZ_EWR_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_ewr_pol_dtls') }}
    where emp_code is not null and contract_id is not null

    union all

    select distinct
        bdr_code as party_bk,
        master_policy_no as policy_bk,
        'BJAZ_FLEXI_CYBER_DATA' as record_source
    from {{ ref('stg_health__bjaz_flexi_cyber_data') }}
    where bdr_code is not null and master_policy_no is not null

    union all

    select distinct
        user_id as party_bk,
        policy_ref as policy_bk,
        'BJAZ_GC_GROUP_GUARD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gc_group_guard_dtls') }}
    where user_id is not null and policy_ref is not null

    union all

    select distinct
        bdr_code as party_bk,
        master_policy_no as policy_bk,
        'BJAZ_GG_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gg_prem_dtls') }}
    where bdr_code is not null and master_policy_no is not null

    union all

    select distinct
        user_id as party_bk,
        master_policy_no as policy_bk,
        'BJAZ_HDFC_SURK_SHOP' as record_source
    from {{ ref('stg_health__bjaz_hdfc_surk_shop') }}
    where user_id is not null and master_policy_no is not null

    union all

    select distinct
        part_id as party_bk,
        contract_id as policy_bk,
        'BJAZ_PC_ONLINE_POL_DTLS_MV' as record_source
    from {{ ref('stg_health__bjaz_pc_online_pol_dtls_mv') }}
    where part_id is not null and contract_id is not null

    union all

    select distinct
        bdr_code as party_bk,
        master_policy_no as policy_bk,
        'BJAZ_PNB_GPA_DATA' as record_source
    from {{ ref('stg_health__bjaz_pnb_gpa_data') }}
    where bdr_code is not null and master_policy_no is not null

    union all

    select distinct
        bdr_code as party_bk,
        master_policy_no as policy_bk,
        'BJAZ_RR_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_rr_prem_dtls') }}
    where bdr_code is not null and master_policy_no is not null

    union all

    select distinct
        customer_id as party_bk,
        contract_id as policy_bk,
        'BJAZ_SUPER_SURAKSHA_DTLS' as record_source
    from {{ ref('stg_health__bjaz_super_suraksha_dtls') }}
    where customer_id is not null and contract_id is not null

)

select distinct party_bk, policy_bk, record_source
from unioned
