-- Intermediate harmonisation view for SAT_PARTY_EMPLOYMENT (HUB_PARTY grain).
-- Stitched via a FULL OUTER JOIN + COALESCE chain across 8 table(s).
-- record_source lists every table that actually contributed to a given row.
select parent_bk, designation, employment_status, occupation_code, occupation_description, record_source
from (
    with t0 as (
        select distinct
            pd_premium_payer_id as parent_bk,
            nullif(trim(to_varchar(md_occupation_type)), '') as occupation_code
        from {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
        where pd_premium_payer_id is not null
        qualify row_number() over (partition by parent_bk order by occupation_code) = 1
    ),
         t1 as (
        select distinct
            member_no as parent_bk,
            nullif(trim(to_varchar(occupation)), '') as occupation_description
        from {{ ref('stg_health__bjaz_ec_mem_dtls_extn') }}
        where member_no is not null
        qualify row_number() over (partition by parent_bk order by occupation_description) = 1
    ),
         t2 as (
        select distinct
            member_no as parent_bk,
            nullif(trim(to_varchar(designation)), '') as designation,
            nullif(trim(to_varchar(profession)), '') as occupation_description
        from {{ ref('stg_health__bjaz_hat_id_mem_detls') }}
        where member_no is not null
        qualify row_number() over (partition by parent_bk order by designation, occupation_description) = 1
    ),
         t3 as (
        select distinct
            member_no as parent_bk,
            nullif(trim(to_varchar(member_occupation)), '') as occupation_description
        from {{ ref('stg_health__bjaz_hcf_member_dtls') }}
        where member_no is not null
        qualify row_number() over (partition by parent_bk order by occupation_description) = 1
    ),
         t4 as (
        select distinct
            part_id as parent_bk,
            nullif(trim(to_varchar(occupation)), '') as occupation_description
        from {{ ref('stg_health__bjaz_hc_part_extn') }}
        where part_id is not null
        qualify row_number() over (partition by parent_bk order by occupation_description) = 1
    ),
         t5 as (
        select distinct
            member_id as parent_bk,
            nullif(trim(to_varchar(designation)), '') as designation,
            nullif(trim(to_varchar(occupation)), '') as occupation_description
        from {{ ref('stg_health__bjaz_hm_member_dtls') }}
        where member_id is not null
        qualify row_number() over (partition by parent_bk order by designation, occupation_description) = 1
    ),
         t6 as (
        select distinct
            member_no as parent_bk,
            nullif(trim(to_varchar(occupation)), '') as occupation_description
        from {{ ref('stg_health__bjaz_ihg_mem_dtls_extn') }}
        where member_no is not null
        qualify row_number() over (partition by parent_bk order by occupation_description) = 1
    ),
         t7 as (
        select distinct
            member_no as parent_bk,
            nullif(trim(to_varchar(occupation)), '') as occupation_description
        from {{ ref('stg_health__bjaz_sh_mem_dtls_extn') }}
        where member_no is not null
        qualify row_number() over (partition by parent_bk order by occupation_description) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk, t2.parent_bk, t3.parent_bk, t4.parent_bk, t5.parent_bk, t6.parent_bk, t7.parent_bk) as parent_bk,
        coalesce(t2.designation, t5.designation) as designation,
        cast(null as varchar) as employment_status,
        coalesce(t0.occupation_code) as occupation_code,
        coalesce(t1.occupation_description, t2.occupation_description, t3.occupation_description, t4.occupation_description, t5.occupation_description, t6.occupation_description, t7.occupation_description) as occupation_description,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BA_HCP_PROD_8439_CLH_LOADER' end, case when t1.parent_bk is not null then 'BJAZ_EC_MEM_DTLS_EXTN' end, case when t2.parent_bk is not null then 'BJAZ_HAT_ID_MEM_DETLS' end, case when t3.parent_bk is not null then 'BJAZ_HCF_MEMBER_DTLS' end, case when t4.parent_bk is not null then 'BJAZ_HC_PART_EXTN' end, case when t5.parent_bk is not null then 'BJAZ_HM_MEMBER_DTLS' end, case when t6.parent_bk is not null then 'BJAZ_IHG_MEM_DTLS_EXTN' end, case when t7.parent_bk is not null then 'BJAZ_SH_MEM_DTLS_EXTN' end), ', ') as record_source
    from t0
    full outer join t1 on t0.parent_bk = t1.parent_bk
    full outer join t2 on coalesce(t0.parent_bk, t1.parent_bk) = t2.parent_bk
    full outer join t3 on coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk) = t3.parent_bk
    full outer join t4 on coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk) = t4.parent_bk
    full outer join t5 on coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk) = t5.parent_bk
    full outer join t6 on coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk) = t6.parent_bk
    full outer join t7 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk) = t7.parent_bk
    )
