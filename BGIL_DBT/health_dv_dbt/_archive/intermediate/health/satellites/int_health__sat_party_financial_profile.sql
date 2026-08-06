-- Intermediate harmonisation view for SAT_PARTY_FINANCIAL_PROFILE (HUB_PARTY grain).
-- Stitched via a FULL OUTER JOIN + COALESCE chain across 9 table(s).
-- record_source lists every table that actually contributed to a given row.
select parent_bk, annual_income, record_source
from (
    with t0 as (
        select distinct
            pd_premium_payer_id as parent_bk,
            nullif(trim(to_varchar(md_gross_monthly_income)), '') as annual_income
        from {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
        where pd_premium_payer_id is not null
        qualify row_number() over (partition by parent_bk order by annual_income) = 1
    ),
         t1 as (
        select distinct
            pd_premium_payer_id as parent_bk,
            nullif(trim(to_varchar(md_gross_monthly_income)), '') as annual_income
        from {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
        where pd_premium_payer_id is not null
        qualify row_number() over (partition by parent_bk order by annual_income) = 1
    ),
         t2 as (
        select distinct
            pd_premium_payer_id as parent_bk,
            nullif(trim(to_varchar(md_gross_monthly_income)), '') as annual_income
        from {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
        where pd_premium_payer_id is not null
        qualify row_number() over (partition by parent_bk order by annual_income) = 1
    ),
         t3 as (
        select distinct
            pd_premium_payer_id as parent_bk,
            nullif(trim(to_varchar(md_gross_monthly_income)), '') as annual_income
        from {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
        where pd_premium_payer_id is not null
        qualify row_number() over (partition by parent_bk order by annual_income) = 1
    ),
         t4 as (
        select distinct
            member_no as parent_bk,
            nullif(trim(to_varchar(gross_income)), '') as annual_income
        from {{ ref('stg_health__bjaz_ec_mem_dtls_extn') }}
        where member_no is not null
        qualify row_number() over (partition by parent_bk order by annual_income) = 1
    ),
         t5 as (
        select distinct
            member_no as parent_bk,
            nullif(trim(to_varchar(monthly_income)), '') as annual_income
        from {{ ref('stg_health__bjaz_hcf_member_dtls') }}
        where member_no is not null
        qualify row_number() over (partition by parent_bk order by annual_income) = 1
    ),
         t6 as (
        select distinct
            member_id as parent_bk,
            nullif(trim(to_varchar(gross_income)), '') as annual_income
        from {{ ref('stg_health__bjaz_hm_member_dtls') }}
        where member_id is not null
        qualify row_number() over (partition by parent_bk order by annual_income) = 1
    ),
         t7 as (
        select distinct
            member_no as parent_bk,
            nullif(trim(to_varchar(gross_income)), '') as annual_income
        from {{ ref('stg_health__bjaz_ihg_mem_dtls_extn') }}
        where member_no is not null
        qualify row_number() over (partition by parent_bk order by annual_income) = 1
    ),
         t8 as (
        select distinct
            member_no as parent_bk,
            nullif(trim(to_varchar(gross_income)), '') as annual_income
        from {{ ref('stg_health__bjaz_sh_mem_dtls_extn') }}
        where member_no is not null
        qualify row_number() over (partition by parent_bk order by annual_income) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk, t2.parent_bk, t3.parent_bk, t4.parent_bk, t5.parent_bk, t6.parent_bk, t7.parent_bk, t8.parent_bk) as parent_bk,
        coalesce(t0.annual_income, t1.annual_income, t2.annual_income, t3.annual_income, t4.annual_income, t5.annual_income, t6.annual_income, t7.annual_income, t8.annual_income) as annual_income,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BA_HCP_PROD_8428_GPG_LOADER' end, case when t1.parent_bk is not null then 'BA_HCP_PROD_8432_ECP_LOADER' end, case when t2.parent_bk is not null then 'BA_HCP_PROD_8433_FHC_LOADER' end, case when t3.parent_bk is not null then 'BA_HCP_PROD_8439_CLH_LOADER' end, case when t4.parent_bk is not null then 'BJAZ_EC_MEM_DTLS_EXTN' end, case when t5.parent_bk is not null then 'BJAZ_HCF_MEMBER_DTLS' end, case when t6.parent_bk is not null then 'BJAZ_HM_MEMBER_DTLS' end, case when t7.parent_bk is not null then 'BJAZ_IHG_MEM_DTLS_EXTN' end, case when t8.parent_bk is not null then 'BJAZ_SH_MEM_DTLS_EXTN' end), ', ') as record_source
    from t0
    full outer join t1 on t0.parent_bk = t1.parent_bk
    full outer join t2 on coalesce(t0.parent_bk, t1.parent_bk) = t2.parent_bk
    full outer join t3 on coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk) = t3.parent_bk
    full outer join t4 on coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk) = t4.parent_bk
    full outer join t5 on coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk) = t5.parent_bk
    full outer join t6 on coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk) = t6.parent_bk
    full outer join t7 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk) = t7.parent_bk
    full outer join t8 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk) = t8.parent_bk
    )
