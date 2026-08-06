{{ config(materialized='view') }}

-- STANDARD-MODEL stitch view for SAT_PARTY_CLAIM_HISTORY (HUB_PARTY grain).
-- Attribute-level merge across 5 table(s) sharing this grain: FULL OUTER JOIN + COALESCE.
-- Reads raw production staging directly (stg_health__*) -- NOT a per-table stage() output; there is
-- nothing to hash until this join has produced one clean row per key. Hashing happens exactly once,
-- downstream, in the companion stg2_party_claim_history.sql stage() model.

select parent_bk, total_claim_amount, total_claim_count, record_source
from (
    with t0 as (
        select distinct
            member_no as parent_bk,
            nullif(trim(to_varchar(prev_pol_clm_amt)), '') as total_claim_amount
        from {{ ref('stg_health__bjaz_hat_id_mem_detls') }}
        where member_no is not null
        qualify row_number() over (partition by parent_bk order by total_claim_amount) = 1
    ),
         t1 as (
        select distinct
            part_id as parent_bk,
            nullif(trim(to_varchar(amount_claimed)), '') as total_claim_amount
        from {{ ref('stg_health__bjaz_hc_part_extn') }}
        where part_id is not null
        qualify row_number() over (partition by parent_bk order by total_claim_amount) = 1
    ),
         t2 as (
        select distinct
            member_id as parent_bk,
            nullif(trim(to_varchar(claim_count)), '') as total_claim_count
        from {{ ref('stg_health__bjaz_hm_member_dtls') }}
        where member_id is not null
        qualify row_number() over (partition by parent_bk order by total_claim_count) = 1
    ),
         t3 as (
        select distinct
            member_no as parent_bk,
            nullif(trim(to_varchar(amount_claimed)), '') as total_claim_amount,
            nullif(trim(to_varchar(claim_history)), '') as total_claim_count
        from {{ ref('stg_health__bjaz_ihg_mem_dtls_extn') }}
        where member_no is not null
        qualify row_number() over (partition by parent_bk order by total_claim_amount, total_claim_count) = 1
    ),
         t4 as (
        select distinct
            member_no as parent_bk,
            nullif(trim(to_varchar(amount_claimed)), '') as total_claim_amount,
            nullif(trim(to_varchar(claim_history)), '') as total_claim_count
        from {{ ref('stg_health__bjaz_sh_mem_dtls_extn') }}
        where member_no is not null
        qualify row_number() over (partition by parent_bk order by total_claim_amount, total_claim_count) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk, t2.parent_bk, t3.parent_bk, t4.parent_bk) as parent_bk,
        coalesce(t0.total_claim_amount, t1.total_claim_amount, t3.total_claim_amount, t4.total_claim_amount) as total_claim_amount,
        coalesce(t2.total_claim_count, t3.total_claim_count, t4.total_claim_count) as total_claim_count,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BJAZ_HAT_ID_MEM_DETLS' end, case when t1.parent_bk is not null then 'BJAZ_HC_PART_EXTN' end, case when t2.parent_bk is not null then 'BJAZ_HM_MEMBER_DTLS' end, case when t3.parent_bk is not null then 'BJAZ_IHG_MEM_DTLS_EXTN' end, case when t4.parent_bk is not null then 'BJAZ_SH_MEM_DTLS_EXTN' end), ', ') as record_source
    from t0
    full outer join t1 on t0.parent_bk = t1.parent_bk
    full outer join t2 on coalesce(t0.parent_bk, t1.parent_bk) = t2.parent_bk
    full outer join t3 on coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk) = t3.parent_bk
    full outer join t4 on coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk) = t4.parent_bk
    )
