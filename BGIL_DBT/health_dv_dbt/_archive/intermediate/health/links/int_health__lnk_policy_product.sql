-- Intermediate harmonisation view for LNK_POLICY_PRODUCT (Policy Product).
-- Derived link: co-occurrence of the member hub business keys (explicit/discovered/mapper-
-- confirmed) on the same Health source row is treated as evidence of the association.
-- Pure UNION ALL: 0-join complexity.

with unioned as (

    select distinct
        contract_id as policy_bk,
        product_code as product_bk,
        'BA_HCP_DT_PREMIUM' as record_source
    from {{ ref('stg_health__ba_hcp_dt_premium') }}
    where contract_id is not null and product_code is not null

    union all

    select distinct
        base_policy_ref as policy_bk,
        product_code as product_bk,
        'BA_HCP_PRIME_RIDER_DTLS' as record_source
    from {{ ref('stg_health__ba_hcp_prime_rider_dtls') }}
    where base_policy_ref is not null and product_code is not null

    union all

    select distinct
        pol_serial_no as policy_bk,
        pd_product_code as product_bk,
        'BA_HCP_PROD_8428_GPG_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
    where pol_serial_no is not null and pd_product_code is not null

    union all

    select distinct
        pol_serial_no as policy_bk,
        pd_product_code as product_bk,
        'BA_HCP_PROD_8432_ECP_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
    where pol_serial_no is not null and pd_product_code is not null

    union all

    select distinct
        pol_serial_no as policy_bk,
        pd_product_code as product_bk,
        'BA_HCP_PROD_8433_FHC_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
    where pol_serial_no is not null and pd_product_code is not null

    union all

    select distinct
        pol_serial_no as policy_bk,
        pd_product_code as product_bk,
        'BA_HCP_PROD_8439_CLH_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
    where pol_serial_no is not null and pd_product_code is not null

    union all

    select distinct
        policy_ref as policy_bk,
        product_code as product_bk,
        'BJAZ_BANDHAN_MEDI_CLAM' as record_source
    from {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
    where policy_ref is not null and product_code is not null

    union all

    select distinct
        policy_ref as policy_bk,
        product_4digit_code as product_bk,
        'BJAZ_EHH_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_ehh_pol_dtls') }}
    where policy_ref is not null and product_4digit_code is not null

    union all

    select distinct
        pmasterpolicynumber as policy_bk,
        schemecode as product_bk,
        'BJAZ_GENERIC_LOADER_LOG_TABLE' as record_source
    from {{ ref('stg_health__bjaz_generic_loader_log_table') }}
    where pmasterpolicynumber is not null and schemecode is not null

    union all

    select distinct
        reference_id as policy_bk,
        product_code as product_bk,
        'BJAZ_GPG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gpg_pol_dtls') }}
    where reference_id is not null and product_code is not null

    union all

    select distinct
        master_policy_no as policy_bk,
        product_code as product_bk,
        'BJAZ_GP_HOSPITAL_CASH' as record_source
    from {{ ref('stg_health__bjaz_gp_hospital_cash') }}
    where master_policy_no is not null and product_code is not null

    union all

    select distinct
        reg_no as policy_bk,
        product as product_bk,
        'BJAZ_GRP_HLT_CUST_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_cust_dtls') }}
    where reg_no is not null and product is not null

    union all

    select distinct
        reg_no as policy_bk,
        product as product_bk,
        'BJAZ_GRP_HLT_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_dtls') }}
    where reg_no is not null and product is not null

    union all

    select distinct
        reg_no as policy_bk,
        product as product_bk,
        'BJAZ_GRP_HLT_IMD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_imd_dtls') }}
    where reg_no is not null and product is not null

    union all

    select distinct
        reg_no as policy_bk,
        product as product_bk,
        'BJAZ_GRP_HLT_MATERNITY_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_maternity_dtls') }}
    where reg_no is not null and product is not null

    union all

    select distinct
        policy_number as policy_bk,
        product_code as product_bk,
        'BJAZ_HAT_CASE_OCR_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hat_case_ocr_dtls') }}
    where policy_number is not null and product_code is not null

    union all

    select distinct
        reference_id as policy_bk,
        product_code as product_bk,
        'BJAZ_HDFC_SEC_FHPP' as record_source
    from {{ ref('stg_health__bjaz_hdfc_sec_fhpp') }}
    where reference_id is not null and product_code is not null

    union all

    select distinct
        policy_ref as policy_bk,
        product_code as product_bk,
        'BJAZ_HEALTH_WEBSERVICE_INFO' as record_source
    from {{ ref('stg_health__bjaz_health_webservice_info') }}
    where policy_ref is not null and product_code is not null

    union all

    select distinct
        contract_id as policy_bk,
        product_4digit_code as product_bk,
        'BJAZ_HG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hg_pol_dtls') }}
    where contract_id is not null and product_4digit_code is not null

    union all

    select distinct
        policy_ref as policy_bk,
        prod_cd as product_bk,
        'BJAZ_HM_COINSU_CLM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_coinsu_clm_dtls') }}
    where policy_ref is not null and prod_cd is not null

    union all

    select distinct
        contract_id as policy_bk,
        product_code as product_bk,
        'BJAZ_HM_MEMBER_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_member_dtls') }}
    where contract_id is not null and product_code is not null

    union all

    select distinct
        master_policy_no as policy_bk,
        product_code as product_bk,
        'BJAZ_ADLD_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_adld_prem_dtls') }}
    where master_policy_no is not null and product_code is not null

    union all

    select distinct
        contract_id as policy_bk,
        product_4digit_code as product_bk,
        'BJAZ_CLM_PRE_AUTH_HLT_DTLS' as record_source
    from {{ ref('stg_health__bjaz_clm_pre_auth_hlt_dtls') }}
    where contract_id is not null and product_4digit_code is not null

    union all

    select distinct
        policy_ref as policy_bk,
        product_code as product_bk,
        'BJAZ_CLM_WG_TRANS_DTLS' as record_source
    from {{ ref('stg_health__bjaz_clm_wg_trans_dtls') }}
    where policy_ref is not null and product_code is not null

    union all

    select distinct
        policy_ref as policy_bk,
        product_code as product_bk,
        'BJAZ_CLM_WG_TRANS_DTLS_HIST' as record_source
    from {{ ref('stg_health__bjaz_clm_wg_trans_dtls_hist') }}
    where policy_ref is not null and product_code is not null

    union all

    select distinct
        contract_id as policy_bk,
        scheme_code as product_bk,
        'BJAZ_CTNGY_FF_DTLS_EXTN' as record_source
    from {{ ref('stg_health__bjaz_ctngy_ff_dtls_extn') }}
    where contract_id is not null and scheme_code is not null

    union all

    select distinct
        contract_id as policy_bk,
        scheme_code as product_bk,
        'BJAZ_CTNGY_PA_MEM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_ctngy_pa_mem_dtls') }}
    where contract_id is not null and scheme_code is not null

    union all

    select distinct
        contract_id as policy_bk,
        product_4digit_code as product_bk,
        'BJAZ_EWR_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_ewr_pol_dtls') }}
    where contract_id is not null and product_4digit_code is not null

    union all

    select distinct
        master_policy_no as policy_bk,
        product_code as product_bk,
        'BJAZ_FLEXI_CYBER_DATA' as record_source
    from {{ ref('stg_health__bjaz_flexi_cyber_data') }}
    where master_policy_no is not null and product_code is not null

    union all

    select distinct
        policy_ref as policy_bk,
        plan_id as product_bk,
        'BJAZ_GC_GROUP_GUARD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gc_group_guard_dtls') }}
    where policy_ref is not null and plan_id is not null

    union all

    select distinct
        master_policy_no as policy_bk,
        product_code as product_bk,
        'BJAZ_GG_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gg_prem_dtls') }}
    where master_policy_no is not null and product_code is not null

    union all

    select distinct
        master_policy_no as policy_bk,
        product_code as product_bk,
        'BJAZ_HDFC_SURK_SHOP' as record_source
    from {{ ref('stg_health__bjaz_hdfc_surk_shop') }}
    where master_policy_no is not null and product_code is not null

    union all

    select distinct
        contract_id as policy_bk,
        product_4digit_code as product_bk,
        'BJAZ_PC_ONLINE_POL_DTLS_MV' as record_source
    from {{ ref('stg_health__bjaz_pc_online_pol_dtls_mv') }}
    where contract_id is not null and product_4digit_code is not null

    union all

    select distinct
        master_policy_no as policy_bk,
        product_code as product_bk,
        'BJAZ_PNB_GPA_DATA' as record_source
    from {{ ref('stg_health__bjaz_pnb_gpa_data') }}
    where master_policy_no is not null and product_code is not null

    union all

    select distinct
        master_policy_no as policy_bk,
        product_code as product_bk,
        'BJAZ_RR_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_rr_prem_dtls') }}
    where master_policy_no is not null and product_code is not null

    union all

    select distinct
        contract_id as policy_bk,
        product_code as product_bk,
        'BJAZ_SUPER_SURAKSHA_DTLS' as record_source
    from {{ ref('stg_health__bjaz_super_suraksha_dtls') }}
    where contract_id is not null and product_code is not null

    union all

    select distinct
        contract_id as policy_bk,
        product_code as product_bk,
        'T_PREM_DATA_COM' as record_source
    from {{ ref('stg_health__t_prem_data_com') }}
    where contract_id is not null and product_code is not null

)

select distinct policy_bk, product_bk, record_source
from unioned
