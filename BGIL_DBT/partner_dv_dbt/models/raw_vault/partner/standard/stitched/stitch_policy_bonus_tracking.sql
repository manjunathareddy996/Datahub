{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL stitch view for SAT_POLICY_BONUS_TRACKING (HUB_POLICY grain).
-- 7 table(s) contributing at this grain, same join_helpers logic used for Health.
-- Reads raw Partner staging directly (stg_partner__*) -- no hashing here.

select parent_bk, bonusamount, cumulativebonuspercentage, record_source
from (
    with t0 as (
        select distinct
            contract_id as parent_bk,
            nullif(trim(to_varchar(pre_pol_ncb_per)), '') as cumulativebonuspercentage
        from {{ ref('stg_partner__bjaz_ec_mem_dtls_extn') }}
        where contract_id is not null
        qualify row_number() over (partition by parent_bk order by cumulativebonuspercentage) = 1
    ),
         t1 as (
        select distinct
            contract_id as parent_bk,
            nullif(trim(to_varchar(cumulative_amt)), '') as bonusamount,
            nullif(trim(to_varchar(cumulative_bnouz_per)), '') as cumulativebonuspercentage
        from {{ ref('stg_partner__bjaz_hcf_member_dtls') }}
        where contract_id is not null
        qualify row_number() over (partition by parent_bk order by bonusamount, cumulativebonuspercentage) = 1
    ),
         t2 as (
        select distinct
            contract_id as parent_bk,
            nullif(trim(to_varchar(previous_cum_bonus)), '') as bonusamount
        from {{ ref('stg_partner__bjaz_hlt_ensure_mem_dtls') }}
        where contract_id is not null
        qualify row_number() over (partition by parent_bk order by bonusamount) = 1
    ),
         t3 as (
        select distinct
            contract_id as parent_bk,
            nullif(trim(to_varchar(bonus_si)), '') as bonusamount,
            nullif(trim(to_varchar(cumm_bonus_per)), '') as cumulativebonuspercentage
        from {{ ref('stg_partner__bjaz_hm_member_dtls') }}
        where contract_id is not null
        qualify row_number() over (partition by parent_bk order by bonusamount, cumulativebonuspercentage) = 1
    ),
         t4 as (
        select distinct
            contract_id as parent_bk,
            nullif(trim(to_varchar(cummulative_bonus)), '') as bonusamount
        from {{ ref('stg_partner__bjaz_pa_detl_extn') }}
        where contract_id is not null
        qualify row_number() over (partition by parent_bk order by bonusamount) = 1
    ),
         t5 as (
        select distinct
            contract_id as parent_bk,
            nullif(trim(to_varchar(cumm_bonus)), '') as bonusamount,
            nullif(trim(to_varchar(cumm_bonus_per)), '') as cumulativebonuspercentage
        from {{ ref('stg_partner__bjaz_sh_mem_dtls_extn') }}
        where contract_id is not null
        qualify row_number() over (partition by parent_bk order by bonusamount, cumulativebonuspercentage) = 1
    ),
         t6 as (
        select distinct
            contract_id as parent_bk,
            nullif(trim(to_varchar(cumulative_amt)), '') as bonusamount,
            nullif(trim(to_varchar(cumulative_bnouz_per)), '') as cumulativebonuspercentage
        from {{ ref('stg_partner__bjaz_spp_member_dtls') }}
        where contract_id is not null
        qualify row_number() over (partition by parent_bk order by bonusamount, cumulativebonuspercentage) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk, t2.parent_bk, t3.parent_bk, t4.parent_bk, t5.parent_bk, t6.parent_bk) as parent_bk,
        coalesce(t1.bonusamount, t2.bonusamount, t3.bonusamount, t4.bonusamount, t5.bonusamount, t6.bonusamount) as bonusamount,
        coalesce(t0.cumulativebonuspercentage, t1.cumulativebonuspercentage, t3.cumulativebonuspercentage, t5.cumulativebonuspercentage, t6.cumulativebonuspercentage) as cumulativebonuspercentage,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BJAZ_EC_MEM_DTLS_EXTN' end, case when t1.parent_bk is not null then 'BJAZ_HCF_MEMBER_DTLS' end, case when t2.parent_bk is not null then 'BJAZ_HLT_ENSURE_MEM_DTLS' end, case when t3.parent_bk is not null then 'BJAZ_HM_MEMBER_DTLS' end, case when t4.parent_bk is not null then 'BJAZ_PA_DETL_EXTN' end, case when t5.parent_bk is not null then 'BJAZ_SH_MEM_DTLS_EXTN' end, case when t6.parent_bk is not null then 'BJAZ_SPP_MEMBER_DTLS' end), ', ') as record_source
    from t0
    full outer join t1 on t0.parent_bk = t1.parent_bk
    full outer join t2 on coalesce(t0.parent_bk, t1.parent_bk) = t2.parent_bk
    full outer join t3 on coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk) = t3.parent_bk
    full outer join t4 on coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk) = t4.parent_bk
    full outer join t5 on coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk) = t5.parent_bk
    full outer join t6 on coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk) = t6.parent_bk
    )
