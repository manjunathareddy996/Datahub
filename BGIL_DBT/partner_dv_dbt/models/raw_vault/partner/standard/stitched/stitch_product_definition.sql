{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL stitch view for SAT_PRODUCT_DEFINITION (HUB_PRODUCT grain).
-- 3 table(s) contributing at this grain, same join_helpers logic used for Health.
-- Reads raw Partner staging directly (stg_partner__*) -- no hashing here.

select parent_bk, productcategory, productgeneration, productname, record_source
from (
    with t0 as (
        select distinct
            scheme_code as parent_bk,
            nullif(trim(to_varchar(section_code)), '') as productcategory,
            nullif(trim(to_varchar(scheme_version)), '') as productgeneration
        from {{ ref('stg_partner__bjaz_ctngy_ff_dtls_extn') }}
        where scheme_code is not null
        qualify row_number() over (partition by parent_bk order by productcategory, productgeneration) = 1
    ),
         t1 as (
        select distinct
            scheme_code as parent_bk,
            nullif(trim(to_varchar(section_code)), '') as productcategory,
            nullif(trim(to_varchar(scheme_version)), '') as productgeneration,
            nullif(trim(to_varchar(plan)), '') as productname
        from {{ ref('stg_partner__bjaz_ctngy_pa_mem_dtls') }}
        where scheme_code is not null
        qualify row_number() over (partition by parent_bk order by productcategory, productgeneration, productname) = 1
    ),
         t2 as (
        select distinct
            product_code as parent_bk,
            nullif(trim(to_varchar(plan_name)), '') as productname
        from {{ ref('stg_partner__bjaz_hm_member_dtls') }}
        where product_code is not null
        qualify row_number() over (partition by parent_bk order by productname) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk, t2.parent_bk) as parent_bk,
        coalesce(t0.productcategory, t1.productcategory) as productcategory,
        coalesce(t0.productgeneration, t1.productgeneration) as productgeneration,
        coalesce(t1.productname, t2.productname) as productname,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BJAZ_CTNGY_FF_DTLS_EXTN' end, case when t1.parent_bk is not null then 'BJAZ_CTNGY_PA_MEM_DTLS' end, case when t2.parent_bk is not null then 'BJAZ_HM_MEMBER_DTLS' end), ', ') as record_source
    from t0
    full outer join t1 on t0.parent_bk = t1.parent_bk
    full outer join t2 on coalesce(t0.parent_bk, t1.parent_bk) = t2.parent_bk
    )
