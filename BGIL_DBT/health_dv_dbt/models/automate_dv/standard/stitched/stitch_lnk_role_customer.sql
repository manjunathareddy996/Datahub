{{ config(materialized='view') }}

-- STANDARD-MODEL stitch view for SAT_LNK_ROLE_CUSTOMER (HUB_PARTY grain).
-- Attribute-level merge across 3 table(s) sharing this grain: FULL OUTER JOIN + COALESCE.
-- Reads raw production staging directly (stg_health__*) -- NOT a per-table stage() output; there is
-- nothing to hash until this join has produced one clean row per key. Hashing happens exactly once,
-- downstream, in the companion stg2_lnk_role_customer.sql stage() model.

select parent_bk, role_type_ck, vip_indicator, record_source
from (
    select parent_bk, 'CUSTOMER' as role_type_ck, vip_indicator, record_source
    from (
    with t0 as (
        select distinct
            hospital_id as parent_bk,
            nullif(trim(to_varchar(vip_flag_inward)), '') as vip_indicator
        from {{ ref('stg_health__bjaz_hm_cashless_inward') }}
        where hospital_id is not null
        qualify row_number() over (partition by parent_bk order by vip_indicator) = 1
    ),
         t1 as (
        select distinct
            courier_id as parent_bk,
            nullif(trim(to_varchar(vip_flag)), '') as vip_indicator
        from {{ ref('stg_health__bjaz_hm_inward_dtls') }}
        where courier_id is not null
        qualify row_number() over (partition by parent_bk order by vip_indicator) = 1
    ),
         t2 as (
        select distinct
            member_id as parent_bk,
            nullif(trim(to_varchar(vip_flg)), '') as vip_indicator
        from {{ ref('stg_health__bjaz_hm_member_dtls') }}
        where member_id is not null
        qualify row_number() over (partition by parent_bk order by vip_indicator) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk, t2.parent_bk) as parent_bk,
        coalesce(t0.vip_indicator, t1.vip_indicator, t2.vip_indicator) as vip_indicator,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BJAZ_HM_CASHLESS_INWARD' end, case when t1.parent_bk is not null then 'BJAZ_HM_INWARD_DTLS' end, case when t2.parent_bk is not null then 'BJAZ_HM_MEMBER_DTLS' end), ', ') as record_source
    from t0
    full outer join t1 on t0.parent_bk = t1.parent_bk
    full outer join t2 on coalesce(t0.parent_bk, t1.parent_bk) = t2.parent_bk
    )
)
