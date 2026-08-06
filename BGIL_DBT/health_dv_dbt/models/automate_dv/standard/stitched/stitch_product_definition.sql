{{ config(materialized='view') }}

-- STANDARD-MODEL stitch view for SAT_PRODUCT_DEFINITION (HUB_PRODUCT grain).
-- Attribute-level merge across 7 table(s) sharing this grain: FULL OUTER JOIN + COALESCE.
-- Reads raw production staging directly (stg_health__*) -- NOT a per-table stage() output; there is
-- nothing to hash until this join has produced one clean row per key. Hashing happens exactly once,
-- downstream, in the companion stg2_product_definition.sql stage() model.

select parent_bk, line_of_business, product_category, product_description, product_display_name, product_name, record_source
from (
    with t0 as (
        select distinct
            pd_product_code as parent_bk,
            nullif(trim(to_varchar(plan_option)), '') as product_display_name,
            nullif(trim(to_varchar(plan_name)), '') as product_name
        from {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
        where pd_product_code is not null
        qualify row_number() over (partition by parent_bk order by product_display_name, product_name) = 1
    ),
         t1 as (
        select distinct
            pd_product_code as parent_bk,
            nullif(trim(to_varchar(plan_option)), '') as product_display_name,
            nullif(trim(to_varchar(plan_name)), '') as product_name
        from {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
        where pd_product_code is not null
        qualify row_number() over (partition by parent_bk order by product_display_name, product_name) = 1
    ),
         t2 as (
        select distinct
            scheme_code as parent_bk,
            nullif(trim(to_varchar(health_product)), '') as line_of_business,
            nullif(trim(to_varchar(scheme_desc)), '') as product_name
        from {{ ref('stg_health__bjaz_ctngy_scheme_mst') }}
        where scheme_code is not null
        qualify row_number() over (partition by parent_bk order by line_of_business, product_name) = 1
    ),
         t3 as (
        select distinct
            product as parent_bk,
            nullif(trim(to_varchar(category)), '') as product_category,
            nullif(trim(to_varchar(product_name)), '') as product_name
        from {{ ref('stg_health__bjaz_grp_hlt_dtls') }}
        where product is not null
        qualify row_number() over (partition by parent_bk order by product_category, product_name) = 1
    ),
         t4 as (
        select distinct
            product_code as parent_bk,
            nullif(trim(to_varchar(plan_name)), '') as product_name
        from {{ ref('stg_health__bjaz_hcs_plansi_mapp') }}
        where product_code is not null
        qualify row_number() over (partition by parent_bk order by product_name) = 1
    ),
         t5 as (
        select distinct
            product_4digit_code as parent_bk,
            nullif(trim(to_varchar(plan_desc)), '') as product_description
        from {{ ref('stg_health__bjaz_hg_pol_dtls') }}
        where product_4digit_code is not null
        qualify row_number() over (partition by parent_bk order by product_description) = 1
    ),
         t6 as (
        select distinct
            product_code as parent_bk,
            nullif(trim(to_varchar(plan_name)), '') as product_name
        from {{ ref('stg_health__bjaz_hm_member_dtls') }}
        where product_code is not null
        qualify row_number() over (partition by parent_bk order by product_name) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk, t2.parent_bk, t3.parent_bk, t4.parent_bk, t5.parent_bk, t6.parent_bk) as parent_bk,
        coalesce(t2.line_of_business) as line_of_business,
        coalesce(t3.product_category) as product_category,
        coalesce(t5.product_description) as product_description,
        coalesce(t0.product_display_name, t1.product_display_name) as product_display_name,
        coalesce(t0.product_name, t1.product_name, t2.product_name, t3.product_name, t4.product_name, t6.product_name) as product_name,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BA_HCP_PROD_8433_FHC_LOADER' end, case when t1.parent_bk is not null then 'BA_HCP_PROD_8439_CLH_LOADER' end, case when t2.parent_bk is not null then 'BJAZ_CTNGY_SCHEME_MST' end, case when t3.parent_bk is not null then 'BJAZ_GRP_HLT_DTLS' end, case when t4.parent_bk is not null then 'BJAZ_HCS_PLANSI_MAPP' end, case when t5.parent_bk is not null then 'BJAZ_HG_POL_DTLS' end, case when t6.parent_bk is not null then 'BJAZ_HM_MEMBER_DTLS' end), ', ') as record_source
    from t0
    full outer join t1 on t0.parent_bk = t1.parent_bk
    full outer join t2 on coalesce(t0.parent_bk, t1.parent_bk) = t2.parent_bk
    full outer join t3 on coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk) = t3.parent_bk
    full outer join t4 on coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk) = t4.parent_bk
    full outer join t5 on coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk) = t5.parent_bk
    full outer join t6 on coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk) = t6.parent_bk
    )
