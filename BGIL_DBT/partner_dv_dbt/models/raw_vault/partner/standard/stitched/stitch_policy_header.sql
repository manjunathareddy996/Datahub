{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL stitch view for SAT_POLICY_HEADER (HUB_POLICY grain).
-- 9 table(s) contributing at this grain, same join_helpers logic used for Health.
-- Reads raw Partner staging directly (stg_partner__*) -- no hashing here.

select parent_bk, masterpolicyreference, policyreferencenumber, policyterm, riskexpirydate, riskinceptiondate, record_source
from (
    with t0 as (
        select distinct
            existing_policy_pid as parent_bk,
            nullif(trim(to_varchar(policy_ref)), '') as policyreferencenumber
        from {{ ref('stg_partner__azbj_partner_extn') }}
        where existing_policy_pid is not null
        qualify row_number() over (partition by parent_bk order by policyreferencenumber) = 1
    ),
         t1 as (
        select distinct
            contract_id as parent_bk,
            nullif(trim(to_varchar(member_risk_expiry_date)), '') as riskexpirydate,
            nullif(trim(to_varchar(member_risk_inception_date)), '') as riskinceptiondate
        from {{ ref('stg_partner__bjaz_ctngy_pa_mem_dtls') }}
        where contract_id is not null
        qualify row_number() over (partition by parent_bk order by riskexpirydate, riskinceptiondate) = 1
    ),
         t2 as (
        select distinct
            contract_id as parent_bk,
            nullif(trim(to_varchar(policy_ref)), '') as policyreferencenumber,
            nullif(trim(to_varchar(expiry_date)), '') as riskexpirydate,
            nullif(trim(to_varchar(effetive_date)), '') as riskinceptiondate
        from {{ ref('stg_partner__bjaz_ec_mem_dtls_extn') }}
        where contract_id is not null
        qualify row_number() over (partition by parent_bk order by policyreferencenumber, riskexpirydate, riskinceptiondate) = 1
    ),
         t3 as (
        select distinct
            contract_id as parent_bk,
            nullif(trim(to_varchar(to_date)), '') as riskexpirydate,
            nullif(trim(to_varchar(from_date)), '') as riskinceptiondate
        from {{ ref('stg_partner__bjaz_hcf_member_dtls') }}
        where contract_id is not null
        qualify row_number() over (partition by parent_bk order by riskexpirydate, riskinceptiondate) = 1
    ),
         t4 as (
        select distinct
            contract_id as parent_bk,
            nullif(trim(to_varchar(inception_date)), '') as riskinceptiondate
        from {{ ref('stg_partner__bjaz_hc_part_extn') }}
        where contract_id is not null
        qualify row_number() over (partition by parent_bk order by riskinceptiondate) = 1
    ),
         t5 as (
        select distinct
            contract_id as parent_bk,
            nullif(trim(to_varchar(policy_ref)), '') as policyreferencenumber,
            nullif(trim(to_varchar(term_end_date)), '') as riskexpirydate,
            nullif(trim(to_varchar(term_start_date)), '') as riskinceptiondate
        from {{ ref('stg_partner__bjaz_hm_member_dtls') }}
        where contract_id is not null
        qualify row_number() over (partition by parent_bk order by policyreferencenumber, riskexpirydate, riskinceptiondate) = 1
    ),
         t6 as (
        select distinct
            contract_id as parent_bk,
            nullif(trim(to_varchar(inception_date)), '') as riskinceptiondate
        from {{ ref('stg_partner__bjaz_pa_detl_extn') }}
        where contract_id is not null
        qualify row_number() over (partition by parent_bk order by riskinceptiondate) = 1
    ),
         t7 as (
        select distinct
            contract_id as parent_bk,
            nullif(trim(to_varchar(policy_ref)), '') as policyreferencenumber,
            nullif(trim(to_varchar(period_of_insurance)), '') as policyterm,
            nullif(trim(to_varchar(expiry_date)), '') as riskexpirydate,
            nullif(trim(to_varchar(effetive_date)), '') as riskinceptiondate
        from {{ ref('stg_partner__bjaz_sh_mem_dtls_extn') }}
        where contract_id is not null
        qualify row_number() over (partition by parent_bk order by policyreferencenumber, policyterm, riskexpirydate, riskinceptiondate) = 1
    ),
         t8 as (
        select distinct
            contract_id as parent_bk,
            nullif(trim(to_varchar(to_date)), '') as riskexpirydate,
            nullif(trim(to_varchar(from_date)), '') as riskinceptiondate
        from {{ ref('stg_partner__bjaz_spp_member_dtls') }}
        where contract_id is not null
        qualify row_number() over (partition by parent_bk order by riskexpirydate, riskinceptiondate) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk, t2.parent_bk, t3.parent_bk, t4.parent_bk, t5.parent_bk, t6.parent_bk, t7.parent_bk, t8.parent_bk) as parent_bk,
        cast(null as varchar) as masterpolicyreference,
        coalesce(t0.policyreferencenumber, t2.policyreferencenumber, t5.policyreferencenumber, t7.policyreferencenumber) as policyreferencenumber,
        t7.policyterm as policyterm,
        coalesce(t1.riskexpirydate, t2.riskexpirydate, t3.riskexpirydate, t5.riskexpirydate, t7.riskexpirydate, t8.riskexpirydate) as riskexpirydate,
        coalesce(t1.riskinceptiondate, t2.riskinceptiondate, t3.riskinceptiondate, t4.riskinceptiondate, t5.riskinceptiondate, t6.riskinceptiondate, t7.riskinceptiondate, t8.riskinceptiondate) as riskinceptiondate,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'AZBJ_PARTNER_EXTN' end, case when t1.parent_bk is not null then 'BJAZ_CTNGY_PA_MEM_DTLS' end, case when t2.parent_bk is not null then 'BJAZ_EC_MEM_DTLS_EXTN' end, case when t3.parent_bk is not null then 'BJAZ_HCF_MEMBER_DTLS' end, case when t4.parent_bk is not null then 'BJAZ_HC_PART_EXTN' end, case when t5.parent_bk is not null then 'BJAZ_HM_MEMBER_DTLS' end, case when t6.parent_bk is not null then 'BJAZ_PA_DETL_EXTN' end, case when t7.parent_bk is not null then 'BJAZ_SH_MEM_DTLS_EXTN' end, case when t8.parent_bk is not null then 'BJAZ_SPP_MEMBER_DTLS' end), ', ') as record_source
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
