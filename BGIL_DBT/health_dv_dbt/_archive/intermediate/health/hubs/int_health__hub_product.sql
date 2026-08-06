-- Intermediate harmonisation view for HUB_PRODUCT.
-- Unions the HUB_PRODUCT business key from every Health source table/column carrying it. (19 of 45 source columns are discovered/mapper-confirmed, not explicitly tagged in the original mapping -- see docs.)
-- Pure UNION ALL fan-in: 0-join complexity. This view alone fully supplies hub_product.sql.

with unioned as (

    select distinct
        product_code as business_key,
        'BA_HCP_DT_PREMIUM' as record_source
    from {{ ref('stg_health__ba_hcp_dt_premium') }}
    where product_code is not null

    union all

    select distinct
        product_code as business_key,
        'BA_HCP_PRIME_RIDER_DTLS' as record_source
    from {{ ref('stg_health__ba_hcp_prime_rider_dtls') }}
    where product_code is not null

    union all

    select distinct
        plan_id as business_key,
        'BA_HCP_PRIME_RIDER_DTLS' as record_source
    from {{ ref('stg_health__ba_hcp_prime_rider_dtls') }}
    where plan_id is not null

    union all

    select distinct
        pd_product_code as business_key,
        'BA_HCP_PROD_8428_GPG_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
    where pd_product_code is not null

    union all

    select distinct
        pd_product_code as business_key,
        'BA_HCP_PROD_8432_ECP_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
    where pd_product_code is not null

    union all

    select distinct
        pd_product_code as business_key,
        'BA_HCP_PROD_8433_FHC_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
    where pd_product_code is not null

    union all

    select distinct
        pd_product_code as business_key,
        'BA_HCP_PROD_8439_CLH_LOADER' as record_source
    from {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
    where pd_product_code is not null

    union all

    select distinct
        product_code as business_key,
        'BJAZ_BANDHAN_MEDI_CLAM' as record_source
    from {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
    where product_code is not null

    union all

    select distinct
        plan_id as business_key,
        'BJAZ_BANDHAN_MEDI_CLAM' as record_source
    from {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
    where plan_id is not null

    union all

    select distinct
        scheme_code as business_key,
        'BJAZ_CTNGY_SCHEME_MST' as record_source
    from {{ ref('stg_health__bjaz_ctngy_scheme_mst') }}
    where scheme_code is not null

    union all

    select distinct
        product_4digit_code as business_key,
        'BJAZ_EHH_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_ehh_pol_dtls') }}
    where product_4digit_code is not null

    union all

    select distinct
        schemecode as business_key,
        'BJAZ_GENERIC_LOADER_LOG_TABLE' as record_source
    from {{ ref('stg_health__bjaz_generic_loader_log_table') }}
    where schemecode is not null

    union all

    select distinct
        planid as business_key,
        'BJAZ_GENERIC_LOADER_LOG_TABLE' as record_source
    from {{ ref('stg_health__bjaz_generic_loader_log_table') }}
    where planid is not null

    union all

    select distinct
        product_code as business_key,
        'BJAZ_GPG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gpg_pol_dtls') }}
    where product_code is not null

    union all

    select distinct
        product_code as business_key,
        'BJAZ_GP_HOSPITAL_CASH' as record_source
    from {{ ref('stg_health__bjaz_gp_hospital_cash') }}
    where product_code is not null

    union all

    select distinct
        product as business_key,
        'BJAZ_GRP_HLT_CUST_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_cust_dtls') }}
    where product is not null

    union all

    select distinct
        product as business_key,
        'BJAZ_GRP_HLT_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_dtls') }}
    where product is not null

    union all

    select distinct
        product as business_key,
        'BJAZ_GRP_HLT_IMD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_imd_dtls') }}
    where product is not null

    union all

    select distinct
        product as business_key,
        'BJAZ_GRP_HLT_MATERNITY_DTLS' as record_source
    from {{ ref('stg_health__bjaz_grp_hlt_maternity_dtls') }}
    where product is not null

    union all

    -- DISCOVERED
    select distinct
        product_code as business_key,
        'BJAZ_HAT_CASE_OCR_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hat_case_ocr_dtls') }}
    where product_code is not null

    union all

    select distinct
        product_code as business_key,
        'BJAZ_HCP_TRANSCRIPT_URL' as record_source
    from {{ ref('stg_health__bjaz_hcp_transcript_url') }}
    where product_code is not null

    union all

    select distinct
        product_code as business_key,
        'BJAZ_HCS_PLANSI_MAPP' as record_source
    from {{ ref('stg_health__bjaz_hcs_plansi_mapp') }}
    where product_code is not null

    union all

    select distinct
        product_code as business_key,
        'BJAZ_HDFC_SEC_FHPP' as record_source
    from {{ ref('stg_health__bjaz_hdfc_sec_fhpp') }}
    where product_code is not null

    union all

    select distinct
        product_code as business_key,
        'BJAZ_HEALTH_WEBSERVICE_INFO' as record_source
    from {{ ref('stg_health__bjaz_health_webservice_info') }}
    where product_code is not null

    union all

    select distinct
        product_4digit_code as business_key,
        'BJAZ_HG_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hg_pol_dtls') }}
    where product_4digit_code is not null

    union all

    select distinct
        prod_cd as business_key,
        'BJAZ_HM_COINSU_CLM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_coinsu_clm_dtls') }}
    where prod_cd is not null

    union all

    select distinct
        product_code as business_key,
        'BJAZ_HM_MEMBER_DTLS' as record_source
    from {{ ref('stg_health__bjaz_hm_member_dtls') }}
    where product_code is not null

    union all

    -- DISCOVERED
    select distinct
        product_code as business_key,
        'BJAZ_ADLD_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_adld_prem_dtls') }}
    where product_code is not null

    union all

    -- DISCOVERED
    select distinct
        product_4digit_code as business_key,
        'BJAZ_CLM_PRE_AUTH_HLT_DTLS' as record_source
    from {{ ref('stg_health__bjaz_clm_pre_auth_hlt_dtls') }}
    where product_4digit_code is not null

    union all

    -- DISCOVERED
    select distinct
        product_code as business_key,
        'BJAZ_CLM_WG_TRANS_DTLS' as record_source
    from {{ ref('stg_health__bjaz_clm_wg_trans_dtls') }}
    where product_code is not null

    union all

    -- DISCOVERED
    select distinct
        product_code as business_key,
        'BJAZ_CLM_WG_TRANS_DTLS_HIST' as record_source
    from {{ ref('stg_health__bjaz_clm_wg_trans_dtls_hist') }}
    where product_code is not null

    union all

    -- DISCOVERED
    select distinct
        scheme_code as business_key,
        'BJAZ_CTNGY_FF_DTLS_EXTN' as record_source
    from {{ ref('stg_health__bjaz_ctngy_ff_dtls_extn') }}
    where scheme_code is not null

    union all

    -- DISCOVERED
    select distinct
        scheme_code as business_key,
        'BJAZ_CTNGY_PA_MEM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_ctngy_pa_mem_dtls') }}
    where scheme_code is not null

    union all

    -- DISCOVERED
    select distinct
        product_4digit_code as business_key,
        'BJAZ_EWR_POL_DTLS' as record_source
    from {{ ref('stg_health__bjaz_ewr_pol_dtls') }}
    where product_4digit_code is not null

    union all

    -- DISCOVERED
    select distinct
        product_code as business_key,
        'BJAZ_FLEXI_CYBER_DATA' as record_source
    from {{ ref('stg_health__bjaz_flexi_cyber_data') }}
    where product_code is not null

    union all

    -- DISCOVERED
    select distinct
        plan_id as business_key,
        'BJAZ_GC_GROUP_GUARD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gc_group_guard_dtls') }}
    where plan_id is not null

    union all

    -- DISCOVERED
    select distinct
        product_code as business_key,
        'BJAZ_GC_GROUP_GUARD_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gc_group_guard_dtls') }}
    where product_code is not null

    union all

    -- DISCOVERED
    select distinct
        product_code as business_key,
        'BJAZ_GG_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_gg_prem_dtls') }}
    where product_code is not null

    union all

    -- DISCOVERED
    select distinct
        product_code as business_key,
        'BJAZ_HDFC_FLEXIPA' as record_source
    from {{ ref('stg_health__bjaz_hdfc_flexipa') }}
    where product_code is not null

    union all

    -- DISCOVERED
    select distinct
        product_code as business_key,
        'BJAZ_HDFC_SURK_SHOP' as record_source
    from {{ ref('stg_health__bjaz_hdfc_surk_shop') }}
    where product_code is not null

    union all

    -- DISCOVERED
    select distinct
        product_4digit_code as business_key,
        'BJAZ_PC_ONLINE_POL_DTLS_MV' as record_source
    from {{ ref('stg_health__bjaz_pc_online_pol_dtls_mv') }}
    where product_4digit_code is not null

    union all

    -- DISCOVERED
    select distinct
        product_code as business_key,
        'BJAZ_PNB_GPA_DATA' as record_source
    from {{ ref('stg_health__bjaz_pnb_gpa_data') }}
    where product_code is not null

    union all

    -- DISCOVERED
    select distinct
        product_code as business_key,
        'BJAZ_RR_PREM_DTLS' as record_source
    from {{ ref('stg_health__bjaz_rr_prem_dtls') }}
    where product_code is not null

    union all

    -- DISCOVERED
    select distinct
        product_code as business_key,
        'BJAZ_SUPER_SURAKSHA_DTLS' as record_source
    from {{ ref('stg_health__bjaz_super_suraksha_dtls') }}
    where product_code is not null

    union all

    -- DISCOVERED
    select distinct
        product_code as business_key,
        'T_PREM_DATA_COM' as record_source
    from {{ ref('stg_health__t_prem_data_com') }}
    where product_code is not null

)

select distinct business_key, record_source
from unioned
