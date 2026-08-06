{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL stitch view for SAT_PARTY_CLAIM_HISTORY (HUB_PARTY grain).
-- 6 table(s) contributing at this grain, same join_helpers logic used for Health.
-- Reads raw Partner staging directly (stg_partner__*) -- no hashing here.

select parent_bk, totalclaimamount, totalclaimcount, record_source
from (
    with t0 as (
        select distinct
            partner_id as parent_bk,
            nullif(trim(to_varchar(claim_received)), '') as totalclaimcount
        from {{ ref('stg_partner__bjaz_ec_mem_dtls_extn') }}
        where partner_id is not null
        qualify row_number() over (partition by parent_bk order by totalclaimcount) = 1
    ),
         t1 as (
        select distinct
            partner_id as parent_bk,
            nullif(trim(to_varchar(claim_dtls)), '') as totalclaimcount
        from {{ ref('stg_partner__bjaz_hcf_member_dtls') }}
        where partner_id is not null
        qualify row_number() over (partition by parent_bk order by totalclaimcount) = 1
    ),
         t2 as (
        select distinct
            part_id as parent_bk,
            nullif(trim(to_varchar(amount_claimed)), '') as totalclaimamount,
            nullif(trim(to_varchar(claim_history)), '') as totalclaimcount
        from {{ ref('stg_partner__bjaz_hc_part_extn') }}
        where part_id is not null
        qualify row_number() over (partition by parent_bk order by totalclaimamount, totalclaimcount) = 1
    ),
         t3 as (
        select distinct
            partner_id as parent_bk,
            nullif(trim(to_varchar(claim_count)), '') as totalclaimcount
        from {{ ref('stg_partner__bjaz_hm_member_dtls') }}
        where partner_id is not null
        qualify row_number() over (partition by parent_bk order by totalclaimcount) = 1
    ),
         t4 as (
        select distinct
            partner_id as parent_bk,
            nullif(trim(to_varchar(amount_claimed)), '') as totalclaimamount,
            nullif(trim(to_varchar(claim_history)), '') as totalclaimcount
        from {{ ref('stg_partner__bjaz_sh_mem_dtls_extn') }}
        where partner_id is not null
        qualify row_number() over (partition by parent_bk order by totalclaimamount, totalclaimcount) = 1
    ),
         t5 as (
        select distinct
            partner_id as parent_bk,
            nullif(trim(to_varchar(claim_dtls)), '') as totalclaimcount
        from {{ ref('stg_partner__bjaz_spp_member_dtls') }}
        where partner_id is not null
        qualify row_number() over (partition by parent_bk order by totalclaimcount) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk, t2.parent_bk, t3.parent_bk, t4.parent_bk, t5.parent_bk) as parent_bk,
        coalesce(t2.totalclaimamount, t4.totalclaimamount) as totalclaimamount,
        coalesce(t0.totalclaimcount, t1.totalclaimcount, t2.totalclaimcount, t3.totalclaimcount, t4.totalclaimcount, t5.totalclaimcount) as totalclaimcount,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BJAZ_EC_MEM_DTLS_EXTN' end, case when t1.parent_bk is not null then 'BJAZ_HCF_MEMBER_DTLS' end, case when t2.parent_bk is not null then 'BJAZ_HC_PART_EXTN' end, case when t3.parent_bk is not null then 'BJAZ_HM_MEMBER_DTLS' end, case when t4.parent_bk is not null then 'BJAZ_SH_MEM_DTLS_EXTN' end, case when t5.parent_bk is not null then 'BJAZ_SPP_MEMBER_DTLS' end), ', ') as record_source
    from t0
    full outer join t1 on t0.parent_bk = t1.parent_bk
    full outer join t2 on coalesce(t0.parent_bk, t1.parent_bk) = t2.parent_bk
    full outer join t3 on coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk) = t3.parent_bk
    full outer join t4 on coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk) = t4.parent_bk
    full outer join t5 on coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk) = t5.parent_bk
    )
