{{ config(materialized='view') }}

-- STANDARD-MODEL stitch view for SAT_LNK_ROLE_EMPLOYEE (HUB_PARTY grain).
-- Attribute-level merge across 10 table(s) sharing this grain: FULL OUTER JOIN + COALESCE.
-- Reads raw production staging directly (stg_health__*) -- NOT a per-table stage() output; there is
-- nothing to hash until this join has produced one clean row per key. Hashing happens exactly once,
-- downstream, in the companion stg2_lnk_role_employee.sql stage() model.

select parent_bk, role_type_ck, employee_code, record_source
from (
    select parent_bk, 'EMPLOYEE' as role_type_ck, employee_code, record_source
    from (
    with t0 as (
        select distinct
            pd_imd_rm_e_code as parent_bk,
            nullif(trim(to_varchar(pd_imd_rm_e_code)), '') as employee_code
        from {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
        where pd_imd_rm_e_code is not null
        qualify row_number() over (partition by parent_bk order by employee_code) = 1
    ),
         t1 as (
        select distinct
            pd_bagic_rm_e_code as parent_bk,
            nullif(trim(to_varchar(pd_bagic_rm_e_code)), '') as employee_code
        from {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
        where pd_bagic_rm_e_code is not null
        qualify row_number() over (partition by parent_bk order by employee_code) = 1
    ),
         t2 as (
        select distinct
            pd_imd_rm_e_code as parent_bk,
            nullif(trim(to_varchar(pd_imd_rm_e_code)), '') as employee_code
        from {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
        where pd_imd_rm_e_code is not null
        qualify row_number() over (partition by parent_bk order by employee_code) = 1
    ),
         t3 as (
        select distinct
            pd_bagic_rm_e_code as parent_bk,
            nullif(trim(to_varchar(pd_bagic_rm_e_code)), '') as employee_code
        from {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
        where pd_bagic_rm_e_code is not null
        qualify row_number() over (partition by parent_bk order by employee_code) = 1
    ),
         t4 as (
        select distinct
            pd_imd_rm_e_code as parent_bk,
            nullif(trim(to_varchar(pd_imd_rm_e_code)), '') as employee_code
        from {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
        where pd_imd_rm_e_code is not null
        qualify row_number() over (partition by parent_bk order by employee_code) = 1
    ),
         t5 as (
        select distinct
            pd_bagic_rm_e_code as parent_bk,
            nullif(trim(to_varchar(pd_bagic_rm_e_code)), '') as employee_code
        from {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
        where pd_bagic_rm_e_code is not null
        qualify row_number() over (partition by parent_bk order by employee_code) = 1
    ),
         t6 as (
        select distinct
            pd_imd_rm_e_code as parent_bk,
            nullif(trim(to_varchar(pd_imd_rm_e_code)), '') as employee_code
        from {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
        where pd_imd_rm_e_code is not null
        qualify row_number() over (partition by parent_bk order by employee_code) = 1
    ),
         t7 as (
        select distinct
            pd_bagic_rm_e_code as parent_bk,
            nullif(trim(to_varchar(pd_bagic_rm_e_code)), '') as employee_code
        from {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
        where pd_bagic_rm_e_code is not null
        qualify row_number() over (partition by parent_bk order by employee_code) = 1
    ),
         t8 as (
        select distinct
            bagic_e_code as parent_bk,
            nullif(trim(to_varchar(bagic_e_code)), '') as employee_code
        from {{ ref('stg_health__bjaz_gpg_pol_dtls') }}
        where bagic_e_code is not null
        qualify row_number() over (partition by parent_bk order by employee_code) = 1
    ),
         t9 as (
        select distinct
            bagic_e_code as parent_bk,
            nullif(trim(to_varchar(bagic_rm_e_code)), '') as employee_code
        from {{ ref('stg_health__bjaz_gpg_pol_dtls') }}
        where bagic_e_code is not null
        qualify row_number() over (partition by parent_bk order by employee_code) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk, t2.parent_bk, t3.parent_bk, t4.parent_bk, t5.parent_bk, t6.parent_bk, t7.parent_bk, t8.parent_bk, t9.parent_bk) as parent_bk,
        coalesce(t0.employee_code, t1.employee_code, t2.employee_code, t3.employee_code, t4.employee_code, t5.employee_code, t6.employee_code, t7.employee_code, t8.employee_code, t9.employee_code) as employee_code,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BA_HCP_PROD_8428_GPG_LOADER' end, case when t1.parent_bk is not null then 'BA_HCP_PROD_8428_GPG_LOADER' end, case when t2.parent_bk is not null then 'BA_HCP_PROD_8432_ECP_LOADER' end, case when t3.parent_bk is not null then 'BA_HCP_PROD_8432_ECP_LOADER' end, case when t4.parent_bk is not null then 'BA_HCP_PROD_8433_FHC_LOADER' end, case when t5.parent_bk is not null then 'BA_HCP_PROD_8433_FHC_LOADER' end, case when t6.parent_bk is not null then 'BA_HCP_PROD_8439_CLH_LOADER' end, case when t7.parent_bk is not null then 'BA_HCP_PROD_8439_CLH_LOADER' end, case when t8.parent_bk is not null then 'BJAZ_GPG_POL_DTLS' end, case when t9.parent_bk is not null then 'BJAZ_GPG_POL_DTLS' end), ', ') as record_source
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
    )
)
