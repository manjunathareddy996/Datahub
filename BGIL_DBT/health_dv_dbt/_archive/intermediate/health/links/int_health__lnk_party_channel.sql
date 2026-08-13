-- Intermediate harmonisation view for LNK_PARTY_CHANNEL (Party via Channel).
-- Derived link: co-occurrence of the member hub business keys (explicit/discovered/mapper-
-- confirmed) on the same Health source row is treated as evidence of the association.
-- Pure UNION ALL: 0-join complexity.

with unioned as (

    select distinct
        partner_id as distribution_channel_bk,
        user_id as party_bk,
        'BA_HCP_POL_MST' as record_source
    from {{ ref('stg_health__ba_hcp_pol_mst') }}
    where partner_id is not null and user_id is not null

    union all

    select distinct
        pd_partner_id as distribution_channel_bk,
        pd_premium_payer_id as party_bk,
        'BA_HCP_PROD_8428_GPG_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
    where pd_partner_id is not null and pd_premium_payer_id is not null

    union all

    select distinct
        pd_partner_id as distribution_channel_bk,
        pd_premium_payer_id as party_bk,
        'BA_HCP_PROD_8432_ECP_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
    where pd_partner_id is not null and pd_premium_payer_id is not null

    union all

    select distinct
        pd_partner_id as distribution_channel_bk,
        pd_premium_payer_id as party_bk,
        'BA_HCP_PROD_8433_FHC_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
    where pd_partner_id is not null and pd_premium_payer_id is not null

    union all

    select distinct
        pd_partner_id as distribution_channel_bk,
        pd_premium_payer_id as party_bk,
        'BA_HCP_PROD_8439_CLH_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
    where pd_partner_id is not null and pd_premium_payer_id is not null

    union all

    select distinct
        partner_id as distribution_channel_bk,
        customer_id as party_bk,
        'BJAZ_BANDHAN_MEDI_CLAM' as record_source
    from {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
    where partner_id is not null and customer_id is not null

    union all

    select distinct
        partner_id as distribution_channel_bk,
        member_no as party_bk,
        'BJAZ_EC_MEM_DTLS_EXTN' as record_source
    from {{ ref('stg_health__bjaz_ec_mem_dtls_extn') }}
    where partner_id is not null and member_no is not null

    union all

    select distinct
        imd_code as distribution_channel_bk,
        bagic_e_code as party_bk,
        'BJAZ_GPG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gpg_pol_dtls') }}
    where imd_code is not null and bagic_e_code is not null

    union all

    select distinct
        imd_code as distribution_channel_bk,
        user_id as party_bk,
        'BJAZ_GP_HOSPITAL_CASH' as record_source
    from {{ ref('stg_health__bjaz_gp_hospital_cash') }}
    where imd_code is not null and user_id is not null

    union all

    select distinct
        imd_code as distribution_channel_bk,
        rm_code as party_bk,
        'BJAZ_GRP_HLT_IMD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_imd_dtls') }}
    where imd_code is not null and rm_code is not null

    union all

    select distinct
        imd_code as distribution_channel_bk,
        member_id as party_bk,
        'BJAZ_HAT_CASE_OCR_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hat_case_ocr_dtls') }}
    where imd_code is not null and member_id is not null

    union all

    select distinct
        partner_id as distribution_channel_bk,
        member_no as party_bk,
        'BJAZ_HCF_MEMBER_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hcf_member_dtls') }}
    where partner_id is not null and member_no is not null

    union all

    select distinct
        imd_code as distribution_channel_bk,
        client_id as party_bk,
        'BJAZ_HDFC_SEC_FHPP' as record_source
    from {{ ref('stg_health__bjaz_hdfc_sec_fhpp') }}
    where imd_code is not null and client_id is not null

    union all

    select distinct
        business_source as distribution_channel_bk,
        part_id as party_bk,
        'BJAZ_HG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hg_pol_dtls') }}
    where business_source is not null and part_id is not null

    union all

    select distinct
        partner_id as distribution_channel_bk,
        member_no as party_bk,
        'BJAZ_HLT_ENSURE_MEM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hlt_ensure_mem_dtls') }}
    where partner_id is not null and member_no is not null

    union all

    select distinct
        main_agent_code as distribution_channel_bk,
        member_id as party_bk,
        'BJAZ_HM_CLM_REGISTER' as record_source
    from {{ ref('stg_health__bjaz_hm_clm_register') }}
    where main_agent_code is not null and member_id is not null

    union all

    select distinct
        imd_code as distribution_channel_bk,
        hospital_id as party_bk,
        'BJAZ_HM_HCM_EXTRACT' as record_source
    from {{ ref('stg_health__bjaz_hm_hcm_extract') }}
    where imd_code is not null and hospital_id is not null

    union all

    select distinct
        partner_id as distribution_channel_bk,
        hosid as party_bk,
        'BJAZ_HM_HOSPITAL_MASTER' as record_source
    from {{ ref('stg_health__bjaz_hm_hospital_master') }}
    where partner_id is not null and hosid is not null

    union all

    select distinct
        distribution_partner as distribution_channel_bk,
        hosid as party_bk,
        'BJAZ_HM_HOSPITAL_MASTER_EXTN' as record_source
    from {{ ref('stg_health__bjaz_hm_hospital_master_extn') }}
    where distribution_partner is not null and hosid is not null

    union all

    select distinct
        partner_id as distribution_channel_bk,
        member_id as party_bk,
        'BJAZ_HM_MEMBER_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_member_dtls') }}
    where partner_id is not null and member_id is not null

    union all

    select distinct
        partner_id as distribution_channel_bk,
        member_no as party_bk,
        'BJAZ_IHG_MEM_DTLS_EXTN' as record_source
    from {{ ref('stg_health__bjaz_ihg_mem_dtls_extn') }}
    where partner_id is not null and member_no is not null

    union all

    select distinct
        partner_id as distribution_channel_bk,
        member_no as party_bk,
        'BJAZ_SH_MEM_DTLS_EXTN' as record_source
    from {{ ref('stg_health__bjaz_sh_mem_dtls_extn') }}
    where partner_id is not null and member_no is not null

    union all

    select distinct
        partner_id as distribution_channel_bk,
        member_no as party_bk,
        'BJAZ_SPP_MEMBER_DTLS' as record_source
    from {{ ref('stg_health__bjaz_spp_member_dtls') }}
    where partner_id is not null and member_no is not null

    union all

    select distinct
        partner_id as distribution_channel_bk,
        customer_id as party_bk,
        'BJAZ_TPA_CLAIM_DETAILS_WS' as record_source
    from {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
    where partner_id is not null and customer_id is not null

    union all

    select distinct
        imd_code as distribution_channel_bk,
        bdr_code as party_bk,
        'BJAZ_ADLD_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_adld_prem_dtls') }}
    where imd_code is not null and bdr_code is not null

    union all

    select distinct
        business_source as distribution_channel_bk,
        emp_code as party_bk,
        'BJAZ_EWR_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_ewr_pol_dtls') }}
    where business_source is not null and emp_code is not null

    union all

    select distinct
        imd_code as distribution_channel_bk,
        bdr_code as party_bk,
        'BJAZ_FLEXI_CYBER_DATA' as record_source
    from {{ ref('stg_health__bjaz_flexi_cyber_data') }}
    where imd_code is not null and bdr_code is not null

    union all

    select distinct
        lg_code as distribution_channel_bk,
        user_id as party_bk,
        'BJAZ_GC_GROUP_GUARD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gc_group_guard_dtls') }}
    where lg_code is not null and user_id is not null

    union all

    select distinct
        imd_code as distribution_channel_bk,
        bdr_code as party_bk,
        'BJAZ_GG_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gg_prem_dtls') }}
    where imd_code is not null and bdr_code is not null

    union all

    select distinct
        imd_code as distribution_channel_bk,
        bdr_code as party_bk,
        'BJAZ_HDFC_FLEXIPA' as record_source
    from {{ ref('stg_health__bjaz_hdfc_flexipa') }}
    where imd_code is not null and bdr_code is not null

    union all

    select distinct
        imd_code as distribution_channel_bk,
        user_id as party_bk,
        'BJAZ_HDFC_SURK_SHOP' as record_source
    from {{ ref('stg_health__bjaz_hdfc_surk_shop') }}
    where imd_code is not null and user_id is not null

    union all

    select distinct
        main_agent_code as distribution_channel_bk,
        part_id as party_bk,
        'BJAZ_PC_ONLINE_POL_DTLS_MV' as record_source
    from {{ ref('stg_health__bjaz_pc_online_pol_dtls_mv') }}
    where main_agent_code is not null and part_id is not null

    union all

    select distinct
        imd_code as distribution_channel_bk,
        bdr_code as party_bk,
        'BJAZ_PNB_GPA_DATA' as record_source
    from {{ ref('stg_health__bjaz_pnb_gpa_data') }}
    where imd_code is not null and bdr_code is not null

    union all

    select distinct
        imd_code as distribution_channel_bk,
        bdr_code as party_bk,
        'BJAZ_RR_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_rr_prem_dtls') }}
    where imd_code is not null and bdr_code is not null

    union all

    select distinct
        imd_code as distribution_channel_bk,
        customer_id as party_bk,
        'BJAZ_SUPER_SURAKSHA_DTLS' as record_source
    from {{ ref('stg_health__bjaz_super_suraksha_dtls') }}
    where imd_code is not null and customer_id is not null

)

select distinct distribution_channel_bk, party_bk, record_source
from unioned
