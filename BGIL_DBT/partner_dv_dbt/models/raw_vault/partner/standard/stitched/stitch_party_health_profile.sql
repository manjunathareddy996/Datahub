{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL stitch view for SAT_PARTY_HEALTH_PROFILE (HUB_PARTY grain).
-- 4 table(s) contributing at this grain, same join_helpers logic used for Health.
-- Reads raw Partner staging directly (stg_partner__*) -- no hashing here.

select parent_bk, bodymassindex, height, maternitystatus, smokerindicator, weight, record_source
from (
    with t0 as (
        select distinct
            partner_id as parent_bk,
            nullif(trim(to_varchar(height_cm)), '') as height,
            nullif(trim(to_varchar(pregnant_yn)), '') as maternitystatus,
            nullif(trim(to_varchar(smoker_yn)), '') as smokerindicator,
            nullif(trim(to_varchar(weight_kg)), '') as weight
        from {{ ref('stg_partner__bjaz_ec_mem_dtls_extn') }}
        where partner_id is not null
        qualify row_number() over (partition by parent_bk order by height, maternitystatus, smokerindicator, weight) = 1
    ),
         t1 as (
        select distinct
            partner_id as parent_bk,
            nullif(trim(to_varchar(obesity_flag)), '') as bodymassindex,
            nullif(trim(to_varchar(height_flag)), '') as height,
            nullif(trim(to_varchar(smoker_flag)), '') as smokerindicator,
            nullif(trim(to_varchar(weight_flag)), '') as weight
        from {{ ref('stg_partner__bjaz_hcf_member_dtls') }}
        where partner_id is not null
        qualify row_number() over (partition by parent_bk order by bodymassindex, height, smokerindicator, weight) = 1
    ),
         t2 as (
        select distinct
            partner_id as parent_bk,
            nullif(trim(to_varchar(smoker_yn)), '') as smokerindicator
        from {{ ref('stg_partner__bjaz_sh_mem_dtls_extn') }}
        where partner_id is not null
        qualify row_number() over (partition by parent_bk order by smokerindicator) = 1
    ),
         t3 as (
        select distinct
            partner_id as parent_bk,
            nullif(trim(to_varchar(obesity)), '') as bodymassindex,
            nullif(trim(to_varchar(weight)), '') as weight
        from {{ ref('stg_partner__bjaz_spp_member_dtls') }}
        where partner_id is not null
        qualify row_number() over (partition by parent_bk order by bodymassindex, weight) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk, t2.parent_bk, t3.parent_bk) as parent_bk,
        coalesce(t1.bodymassindex, t3.bodymassindex) as bodymassindex,
        coalesce(t0.height, t1.height) as height,
        t0.maternitystatus as maternitystatus,
        coalesce(t0.smokerindicator, t1.smokerindicator, t2.smokerindicator) as smokerindicator,
        coalesce(t0.weight, t1.weight, t3.weight) as weight,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BJAZ_EC_MEM_DTLS_EXTN' end, case when t1.parent_bk is not null then 'BJAZ_HCF_MEMBER_DTLS' end, case when t2.parent_bk is not null then 'BJAZ_SH_MEM_DTLS_EXTN' end, case when t3.parent_bk is not null then 'BJAZ_SPP_MEMBER_DTLS' end), ', ') as record_source
    from t0
    full outer join t1 on t0.parent_bk = t1.parent_bk
    full outer join t2 on coalesce(t0.parent_bk, t1.parent_bk) = t2.parent_bk
    full outer join t3 on coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk) = t3.parent_bk
    )
