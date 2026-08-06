-- Intermediate harmonisation view for SAT_POLICY_PREMIUM_SUMMARY (HUB_POLICY grain).
-- Stitched via a FULL OUTER JOIN + COALESCE chain across 18 table(s).
-- record_source lists every table that actually contributed to a given row.
select parent_bk, add_on_premium, base_premium, gross_premium, group_discount_amount, instalment_count, long_term_discount_amount, net_premium, terrorism_premium, total_premium_collected, record_source
from (
    with t0 as (
        select distinct
            contract_id as parent_bk,
            nullif(trim(to_varchar(total_prem_on_base_cov_addon)), '') as add_on_premium,
            nullif(trim(to_varchar(total_prem_on_base_cov)), '') as base_premium,
            nullif(trim(to_varchar(pol_gross_prem_amt)), '') as gross_premium,
            nullif(trim(to_varchar(pol_net_prem_amt)), '') as net_premium
        from {{ ref('stg_health__ba_hcp_dt_premium') }}
        where contract_id is not null
        qualify row_number() over (partition by parent_bk order by add_on_premium, base_premium, gross_premium, net_premium) = 1
    ),
         t1 as (
        select distinct
            contract_id as parent_bk,
            nullif(trim(to_varchar(group_discount)), '') as group_discount_amount
        from {{ ref('stg_health__ba_hcp_pol_mst') }}
        where contract_id is not null
        qualify row_number() over (partition by parent_bk order by group_discount_amount) = 1
    ),
         t2 as (
        select distinct
            base_policy_ref as parent_bk,
            nullif(trim(to_varchar(total_final_premium)), '') as gross_premium,
            nullif(trim(to_varchar(total_net_premium)), '') as net_premium
        from {{ ref('stg_health__ba_hcp_prime_rider_dtls') }}
        where base_policy_ref is not null
        qualify row_number() over (partition by parent_bk order by gross_premium, net_premium) = 1
    ),
         t3 as (
        select distinct
            pol_serial_no as parent_bk,
            nullif(trim(to_varchar(pd_premium_including_st)), '') as gross_premium
        from {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
        where pol_serial_no is not null
        qualify row_number() over (partition by parent_bk order by gross_premium) = 1
    ),
         t4 as (
        select distinct
            pol_serial_no as parent_bk,
            nullif(trim(to_varchar(pd_premium_including_st)), '') as gross_premium
        from {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
        where pol_serial_no is not null
        qualify row_number() over (partition by parent_bk order by gross_premium) = 1
    ),
         t5 as (
        select distinct
            pol_serial_no as parent_bk,
            nullif(trim(to_varchar(pd_premium_including_st)), '') as gross_premium
        from {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
        where pol_serial_no is not null
        qualify row_number() over (partition by parent_bk order by gross_premium) = 1
    ),
         t6 as (
        select distinct
            pol_serial_no as parent_bk,
            nullif(trim(to_varchar(pd_premium_including_st)), '') as gross_premium
        from {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
        where pol_serial_no is not null
        qualify row_number() over (partition by parent_bk order by gross_premium) = 1
    ),
         t7 as (
        select distinct
            policy_no as parent_bk,
            nullif(trim(to_varchar(installments)), '') as instalment_count
        from {{ ref('stg_health__bgil_gmc_final_instl_data') }}
        where policy_no is not null
        qualify row_number() over (partition by parent_bk order by instalment_count) = 1
    ),
         t8 as (
        select distinct
            policy_ref as parent_bk,
            nullif(trim(to_varchar(gross_preminum)), '') as gross_premium
        from {{ ref('stg_health__bjaz_bandhan_medi_clam') }}
        where policy_ref is not null
        qualify row_number() over (partition by parent_bk order by gross_premium) = 1
    ),
         t9 as (
        select distinct
            policy_ref as parent_bk,
            nullif(trim(to_varchar(gross_premium)), '') as gross_premium
        from {{ ref('stg_health__bjaz_ehh_pol_dtls') }}
        where policy_ref is not null
        qualify row_number() over (partition by parent_bk order by gross_premium) = 1
    ),
         t10 as (
        select distinct
            pmasterpolicynumber as parent_bk,
            nullif(trim(to_varchar(pgrosspremium)), '') as gross_premium,
            nullif(trim(to_varchar(ptotalpremium)), '') as total_premium_collected
        from {{ ref('stg_health__bjaz_generic_loader_log_table') }}
        where pmasterpolicynumber is not null
        qualify row_number() over (partition by parent_bk order by gross_premium, total_premium_collected) = 1
    ),
         t11 as (
        select distinct
            reference_id as parent_bk,
            nullif(trim(to_varchar(total_addon_premium)), '') as add_on_premium,
            nullif(trim(to_varchar(total_base_premium)), '') as base_premium,
            nullif(trim(to_varchar(final_premium)), '') as gross_premium,
            nullif(trim(to_varchar(long_term_discount)), '') as long_term_discount_amount,
            nullif(trim(to_varchar(net_premium)), '') as net_premium,
            nullif(trim(to_varchar(full_yr_terr_prem)), '') as terrorism_premium
        from {{ ref('stg_health__bjaz_gpg_pol_dtls') }}
        where reference_id is not null
        qualify row_number() over (partition by parent_bk order by add_on_premium, base_premium, gross_premium, long_term_discount_amount, net_premium, terrorism_premium) = 1
    ),
         t12 as (
        select distinct
            master_policy_no as parent_bk,
            nullif(trim(to_varchar(gross_premium)), '') as gross_premium
        from {{ ref('stg_health__bjaz_gp_hospital_cash') }}
        where master_policy_no is not null
        qualify row_number() over (partition by parent_bk order by gross_premium) = 1
    ),
         t13 as (
        select distinct
            reg_no as parent_bk,
            nullif(trim(to_varchar(final_prm_ex_stax)), '') as net_premium
        from {{ ref('stg_health__bjaz_grp_hlt_dtls') }}
        where reg_no is not null
        qualify row_number() over (partition by parent_bk order by net_premium) = 1
    ),
         t14 as (
        select distinct
            reg_no as parent_bk,
            nullif(trim(to_varchar(base_premium)), '') as base_premium,
            nullif(trim(to_varchar(gross_permium)), '') as gross_premium,
            nullif(trim(to_varchar(total_permium)), '') as total_premium_collected
        from {{ ref('stg_health__bjaz_grp_hlt_maternity_dtls') }}
        where reg_no is not null
        qualify row_number() over (partition by parent_bk order by base_premium, gross_premium, total_premium_collected) = 1
    ),
         t15 as (
        select distinct
            reference_id as parent_bk,
            nullif(trim(to_varchar(gross_premium)), '') as gross_premium
        from {{ ref('stg_health__bjaz_hdfc_sec_fhpp') }}
        where reference_id is not null
        qualify row_number() over (partition by parent_bk order by gross_premium) = 1
    ),
         t16 as (
        select distinct
            policy_ref as parent_bk,
            nullif(trim(to_varchar(add_on_prem)), '') as add_on_premium,
            nullif(trim(to_varchar(gross_premium)), '') as gross_premium,
            nullif(trim(to_varchar(net_premium)), '') as net_premium
        from {{ ref('stg_health__bjaz_health_webservice_info') }}
        where policy_ref is not null
        qualify row_number() over (partition by parent_bk order by add_on_premium, gross_premium, net_premium) = 1
    ),
         t17 as (
        select distinct
            contract_id as parent_bk,
            nullif(trim(to_varchar(gross_premium)), '') as gross_premium
        from {{ ref('stg_health__bjaz_hg_pol_dtls') }}
        where contract_id is not null
        qualify row_number() over (partition by parent_bk order by gross_premium) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk, t2.parent_bk, t3.parent_bk, t4.parent_bk, t5.parent_bk, t6.parent_bk, t7.parent_bk, t8.parent_bk, t9.parent_bk, t10.parent_bk, t11.parent_bk, t12.parent_bk, t13.parent_bk, t14.parent_bk, t15.parent_bk, t16.parent_bk, t17.parent_bk) as parent_bk,
        coalesce(t0.add_on_premium, t11.add_on_premium, t16.add_on_premium) as add_on_premium,
        coalesce(t0.base_premium, t11.base_premium, t14.base_premium) as base_premium,
        coalesce(t0.gross_premium, t2.gross_premium, t3.gross_premium, t4.gross_premium, t5.gross_premium, t6.gross_premium, t8.gross_premium, t9.gross_premium, t10.gross_premium, t11.gross_premium, t12.gross_premium, t14.gross_premium, t15.gross_premium, t16.gross_premium, t17.gross_premium) as gross_premium,
        coalesce(t1.group_discount_amount) as group_discount_amount,
        coalesce(t7.instalment_count) as instalment_count,
        coalesce(t11.long_term_discount_amount) as long_term_discount_amount,
        coalesce(t0.net_premium, t2.net_premium, t11.net_premium, t13.net_premium, t16.net_premium) as net_premium,
        coalesce(t11.terrorism_premium) as terrorism_premium,
        coalesce(t10.total_premium_collected, t14.total_premium_collected) as total_premium_collected,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BA_HCP_DT_PREMIUM' end, case when t1.parent_bk is not null then 'BA_HCP_POL_MST' end, case when t2.parent_bk is not null then 'BA_HCP_PRIME_RIDER_DTLS' end, case when t3.parent_bk is not null then 'BA_HCP_PROD_8428_GPG_LOADER' end, case when t4.parent_bk is not null then 'BA_HCP_PROD_8432_ECP_LOADER' end, case when t5.parent_bk is not null then 'BA_HCP_PROD_8433_FHC_LOADER' end, case when t6.parent_bk is not null then 'BA_HCP_PROD_8439_CLH_LOADER' end, case when t7.parent_bk is not null then 'BGIL_GMC_FINAL_INSTL_DATA' end, case when t8.parent_bk is not null then 'BJAZ_BANDHAN_MEDI_CLAM' end, case when t9.parent_bk is not null then 'BJAZ_EHH_POL_DTLS' end, case when t10.parent_bk is not null then 'BJAZ_GENERIC_LOADER_LOG_TABLE' end, case when t11.parent_bk is not null then 'BJAZ_GPG_POL_DTLS' end, case when t12.parent_bk is not null then 'BJAZ_GP_HOSPITAL_CASH' end, case when t13.parent_bk is not null then 'BJAZ_GRP_HLT_DTLS' end, case when t14.parent_bk is not null then 'BJAZ_GRP_HLT_MATERNITY_DTLS' end, case when t15.parent_bk is not null then 'BJAZ_HDFC_SEC_FHPP' end, case when t16.parent_bk is not null then 'BJAZ_HEALTH_WEBSERVICE_INFO' end, case when t17.parent_bk is not null then 'BJAZ_HG_POL_DTLS' end), ', ') as record_source
    from t0
    full outer join t1 on t0.parent_bk = t1.parent_bk
    full outer join t2 on coalesce(t0.parent_bk, t1.parent_bk) = t2.parent_bk
    full outer join t3 on coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk) = t3.parent_bk
    full outer join t4 on coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk) = t4.parent_bk
    full outer join t5 on coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk) = t5.parent_bk
    full outer join t6 on coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk) = t6.parent_bk
    full outer join t7 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk) = t7.parent_bk
    full outer join t8 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk) = t8.parent_bk
    full outer join t9 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk) = t9.parent_bk
    full outer join t10 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk) = t10.parent_bk
    full outer join t11 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk) = t11.parent_bk
    full outer join t12 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk) = t12.parent_bk
    full outer join t13 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk) = t13.parent_bk
    full outer join t14 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk), t13.parent_bk) = t14.parent_bk
    full outer join t15 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk), t13.parent_bk), t14.parent_bk) = t15.parent_bk
    full outer join t16 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk), t13.parent_bk), t14.parent_bk), t15.parent_bk) = t16.parent_bk
    full outer join t17 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk), t12.parent_bk), t13.parent_bk), t14.parent_bk), t15.parent_bk), t16.parent_bk) = t17.parent_bk
    )
