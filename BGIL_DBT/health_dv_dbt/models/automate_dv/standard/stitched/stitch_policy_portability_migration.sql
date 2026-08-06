{{ config(materialized='view') }}

-- STANDARD-MODEL stitch view for SAT_POLICY_PORTABILITY_MIGRATION (HUB_POLICY grain).
-- Attribute-level merge across 13 table(s) sharing this grain: FULL OUTER JOIN + COALESCE.
-- Reads raw production staging directly (stg_health__*) -- NOT a per-table stage() output; there is
-- nothing to hash until this join has produced one clean row per key. Hashing happens exactly once,
-- downstream, in the companion stg2_policy_portability_migration.sql stage() model.

select parent_bk, continuity_period_granted, cumulative_bonus_ported, portability_indicator, previous_insurer_name, previous_policy_number, previous_sum_insured, record_source
from (
    with t0 as (
        select distinct
            contract_id as parent_bk,
            nullif(trim(to_varchar(prev_insurer)), '') as previous_insurer_name,
            nullif(trim(to_varchar(prev_policy_no)), '') as previous_policy_number,
            nullif(trim(to_varchar(prev_si)), '') as previous_sum_insured
        from {{ ref('stg_health__ba_hcp_port_wordings') }}
        where contract_id is not null
        qualify row_number() over (partition by parent_bk order by previous_insurer_name, previous_policy_number, previous_sum_insured) = 1
    ),
         t1 as (
        select distinct
            pol_serial_no as parent_bk,
            nullif(trim(to_varchar(md_prev_comp_name)), '') as previous_insurer_name,
            nullif(trim(to_varchar(md_prev_policy_number)), '') as previous_policy_number,
            nullif(trim(to_varchar(md_prev_sum_insured)), '') as previous_sum_insured
        from {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
        where pol_serial_no is not null
        qualify row_number() over (partition by parent_bk order by previous_insurer_name, previous_policy_number, previous_sum_insured) = 1
    ),
         t2 as (
        select distinct
            pol_serial_no as parent_bk,
            nullif(trim(to_varchar(md_prev_comp_name)), '') as previous_insurer_name,
            nullif(trim(to_varchar(md_prev_policy_number)), '') as previous_policy_number,
            nullif(trim(to_varchar(md_prev_sum_insured)), '') as previous_sum_insured
        from {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}
        where pol_serial_no is not null
        qualify row_number() over (partition by parent_bk order by previous_insurer_name, previous_policy_number, previous_sum_insured) = 1
    ),
         t3 as (
        select distinct
            contract_id as parent_bk,
            nullif(trim(to_varchar(pre_pol_ncb_per)), '') as cumulative_bonus_ported,
            nullif(trim(to_varchar(prev_company_name)), '') as previous_insurer_name,
            nullif(trim(to_varchar(prev_policy_dtls)), '') as previous_policy_number,
            nullif(trim(to_varchar(prev_sum_insured)), '') as previous_sum_insured
        from {{ ref('stg_health__bjaz_ec_mem_dtls_extn') }}
        where contract_id is not null
        qualify row_number() over (partition by parent_bk order by cumulative_bonus_ported, previous_insurer_name, previous_policy_number, previous_sum_insured) = 1
    ),
         t4 as (
        select distinct
            reference_id as parent_bk,
            nullif(trim(to_varchar(prev_policy_comp_name)), '') as previous_insurer_name,
            nullif(trim(to_varchar(prev_pol_no)), '') as previous_policy_number
        from {{ ref('stg_health__bjaz_gpg_pol_dtls') }}
        where reference_id is not null
        qualify row_number() over (partition by parent_bk order by previous_insurer_name, previous_policy_number) = 1
    ),
         t5 as (
        select distinct
            reg_no as parent_bk,
            nullif(trim(to_varchar(pre_insurer_name)), '') as previous_insurer_name,
            nullif(trim(to_varchar(prv_policy_no)), '') as previous_policy_number
        from {{ ref('stg_health__bjaz_grp_hlt_dtls') }}
        where reg_no is not null
        qualify row_number() over (partition by parent_bk order by previous_insurer_name, previous_policy_number) = 1
    ),
         t6 as (
        select distinct
            contract_id as parent_bk,
            nullif(trim(to_varchar(prev_policy_details)), '') as previous_policy_number
        from {{ ref('stg_health__bjaz_hat_id_mem_detls') }}
        where contract_id is not null
        qualify row_number() over (partition by parent_bk order by previous_policy_number) = 1
    ),
         t7 as (
        select distinct
            contract_id as parent_bk,
            nullif(trim(to_varchar(previous_si)), '') as previous_sum_insured
        from {{ ref('stg_health__bjaz_hcf_member_dtls') }}
        where contract_id is not null
        qualify row_number() over (partition by parent_bk order by previous_sum_insured) = 1
    ),
         t8 as (
        select distinct
            contract_id as parent_bk,
            nullif(trim(to_varchar(first_policy_ref)), '') as previous_policy_number
        from {{ ref('stg_health__bjaz_hc_part_extn') }}
        where contract_id is not null
        qualify row_number() over (partition by parent_bk order by previous_policy_number) = 1
    ),
         t9 as (
        select distinct
            contract_id as parent_bk,
            nullif(trim(to_varchar(pol_benefit_tran_yn)), '') as portability_indicator,
            nullif(trim(to_varchar(prev_policy_no)), '') as previous_policy_number,
            nullif(trim(to_varchar(prev_sum_insured)), '') as previous_sum_insured
        from {{ ref('stg_health__bjaz_hg_pol_dtls') }}
        where contract_id is not null
        qualify row_number() over (partition by parent_bk order by portability_indicator, previous_policy_number, previous_sum_insured) = 1
    ),
         t10 as (
        select distinct
            contract_id as parent_bk,
            nullif(trim(to_varchar(previous_since_noof_years)), '') as continuity_period_granted,
            nullif(trim(to_varchar(previous_cum_bonus)), '') as cumulative_bonus_ported,
            nullif(trim(to_varchar(previous_company_name)), '') as previous_insurer_name,
            nullif(trim(to_varchar(prev_policy_no)), '') as previous_policy_number,
            nullif(trim(to_varchar(previous_sum_insured)), '') as previous_sum_insured
        from {{ ref('stg_health__bjaz_hlt_ensure_mem_dtls') }}
        where contract_id is not null
        qualify row_number() over (partition by parent_bk order by continuity_period_granted, cumulative_bonus_ported, previous_insurer_name, previous_policy_number, previous_sum_insured) = 1
    ),
         t11 as (
        select distinct
            contract_id as parent_bk,
            nullif(trim(to_varchar(prev_policy_dtls)), '') as previous_policy_number,
            nullif(trim(to_varchar(prev_sum_insured)), '') as previous_sum_insured
        from {{ ref('stg_health__bjaz_ihg_mem_dtls_extn') }}
        where contract_id is not null
        qualify row_number() over (partition by parent_bk order by previous_policy_number, previous_sum_insured) = 1
    ),
         t12 as (
        select distinct
            contract_id as parent_bk,
            nullif(trim(to_varchar(prev_policy_dtls)), '') as previous_policy_number,
            nullif(trim(to_varchar(prev_sum_insured)), '') as previous_sum_insured
        from {{ ref('stg_health__bjaz_sh_mem_dtls_extn') }}
        where contract_id is not null
        qualify row_number() over (partition by parent_bk order by previous_policy_number, previous_sum_insured) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk, t2.parent_bk, t3.parent_bk, t4.parent_bk, t5.parent_bk, t6.parent_bk, t7.parent_bk, t8.parent_bk, t9.parent_bk, t10.parent_bk, t11.parent_bk, t12.parent_bk) as parent_bk,
        coalesce(t10.continuity_period_granted) as continuity_period_granted,
        coalesce(t3.cumulative_bonus_ported, t10.cumulative_bonus_ported) as cumulative_bonus_ported,
        coalesce(t9.portability_indicator) as portability_indicator,
        coalesce(t0.previous_insurer_name, t1.previous_insurer_name, t2.previous_insurer_name, t3.previous_insurer_name, t4.previous_insurer_name, t5.previous_insurer_name, t10.previous_insurer_name) as previous_insurer_name,
        coalesce(t0.previous_policy_number, t1.previous_policy_number, t2.previous_policy_number, t3.previous_policy_number, t4.previous_policy_number, t5.previous_policy_number, t6.previous_policy_number, t8.previous_policy_number, t9.previous_policy_number, t10.previous_policy_number, t11.previous_policy_number, t12.previous_policy_number) as previous_policy_number,
        coalesce(t0.previous_sum_insured, t1.previous_sum_insured, t2.previous_sum_insured, t3.previous_sum_insured, t7.previous_sum_insured, t9.previous_sum_insured, t10.previous_sum_insured, t11.previous_sum_insured, t12.previous_sum_insured) as previous_sum_insured,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BA_HCP_PORT_WORDINGS' end, case when t1.parent_bk is not null then 'BA_HCP_PROD_8428_GPG_LOADER' end, case when t2.parent_bk is not null then 'BA_HCP_PROD_8439_CLH_LOADER' end, case when t3.parent_bk is not null then 'BJAZ_EC_MEM_DTLS_EXTN' end, case when t4.parent_bk is not null then 'BJAZ_GPG_POL_DTLS' end, case when t5.parent_bk is not null then 'BJAZ_GRP_HLT_DTLS' end, case when t6.parent_bk is not null then 'BJAZ_HAT_ID_MEM_DETLS' end, case when t7.parent_bk is not null then 'BJAZ_HCF_MEMBER_DTLS' end, case when t8.parent_bk is not null then 'BJAZ_HC_PART_EXTN' end, case when t9.parent_bk is not null then 'BJAZ_HG_POL_DTLS' end, case when t10.parent_bk is not null then 'BJAZ_HLT_ENSURE_MEM_DTLS' end, case when t11.parent_bk is not null then 'BJAZ_IHG_MEM_DTLS_EXTN' end, case when t12.parent_bk is not null then 'BJAZ_SH_MEM_DTLS_EXTN' end), ', ') as record_source
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
    full outer join t10 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk) = t10.parent_bk
    full outer join t11 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk) = t11.parent_bk
    full outer join t12 on coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk), t5.parent_bk), t6.parent_bk), t7.parent_bk), t8.parent_bk), t9.parent_bk), t10.parent_bk), t11.parent_bk) = t12.parent_bk
    )
