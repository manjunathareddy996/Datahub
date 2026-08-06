-- Intermediate harmonisation view for SAT_POLICY_BONUS_TRACKING (HUB_POLICY grain).
-- Stitched via a FULL OUTER JOIN + COALESCE chain across 6 table(s).
-- record_source lists every table that actually contributed to a given row.
select parent_bk, bonus_amount, cumulative_bonus_percentage, record_source
from (
    with t0 as (
        select distinct
            contract_id as parent_bk,
            nullif(trim(to_varchar(cumulative_bonus_amt)), '') as bonus_amount,
            nullif(trim(to_varchar(cumulative_bonus_rate)), '') as cumulative_bonus_percentage
        from {{ ref('stg_health__ba_hcp_dt_premium') }}
        where contract_id is not null
        qualify row_number() over (partition by parent_bk order by bonus_amount, cumulative_bonus_percentage) = 1
    ),
         t1 as (
        select distinct
            pol_serial_no as parent_bk,
            nullif(trim(to_varchar(plc_cb_amount)), '') as bonus_amount,
            nullif(trim(to_varchar(plc_cb_per)), '') as cumulative_bonus_percentage
        from {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
        where pol_serial_no is not null
        qualify row_number() over (partition by parent_bk order by bonus_amount, cumulative_bonus_percentage) = 1
    ),
         t2 as (
        select distinct
            contract_id as parent_bk,
            nullif(trim(to_varchar(cumm_bonus)), '') as bonus_amount,
            nullif(trim(to_varchar(cumm_bonus_per)), '') as cumulative_bonus_percentage
        from {{ ref('stg_health__bjaz_hm_member_dtls') }}
        where contract_id is not null
        qualify row_number() over (partition by parent_bk order by bonus_amount, cumulative_bonus_percentage) = 1
    ),
         t3 as (
        select distinct
            contract_id as parent_bk,
            nullif(trim(to_varchar(cumm_bonus)), '') as bonus_amount,
            nullif(trim(to_varchar(cumm_bonus_per)), '') as cumulative_bonus_percentage
        from {{ ref('stg_health__bjaz_ihg_mem_dtls_extn') }}
        where contract_id is not null
        qualify row_number() over (partition by parent_bk order by bonus_amount, cumulative_bonus_percentage) = 1
    ),
         t4 as (
        select distinct
            contract_id as parent_bk,
            nullif(trim(to_varchar(cumm_bonus)), '') as bonus_amount,
            nullif(trim(to_varchar(cumm_bonus_per)), '') as cumulative_bonus_percentage
        from {{ ref('stg_health__bjaz_sh_mem_dtls_extn') }}
        where contract_id is not null
        qualify row_number() over (partition by parent_bk order by bonus_amount, cumulative_bonus_percentage) = 1
    ),
         t5 as (
        select distinct
            policy_no as parent_bk,
            nullif(trim(to_varchar(bonus)), '') as bonus_amount
        from {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}
        where policy_no is not null
        qualify row_number() over (partition by parent_bk order by bonus_amount) = 1
    )
    select
        coalesce(t0.parent_bk, t1.parent_bk, t2.parent_bk, t3.parent_bk, t4.parent_bk, t5.parent_bk) as parent_bk,
        coalesce(t0.bonus_amount, t1.bonus_amount, t2.bonus_amount, t3.bonus_amount, t4.bonus_amount, t5.bonus_amount) as bonus_amount,
        coalesce(t0.cumulative_bonus_percentage, t1.cumulative_bonus_percentage, t2.cumulative_bonus_percentage, t3.cumulative_bonus_percentage, t4.cumulative_bonus_percentage) as cumulative_bonus_percentage,
        array_to_string(array_construct_compact(case when t0.parent_bk is not null then 'BA_HCP_DT_PREMIUM' end, case when t1.parent_bk is not null then 'BA_HCP_PROD_8433_FHC_LOADER' end, case when t2.parent_bk is not null then 'BJAZ_HM_MEMBER_DTLS' end, case when t3.parent_bk is not null then 'BJAZ_IHG_MEM_DTLS_EXTN' end, case when t4.parent_bk is not null then 'BJAZ_SH_MEM_DTLS_EXTN' end, case when t5.parent_bk is not null then 'BJAZ_TPA_CLAIM_DETAILS_WS' end), ', ') as record_source
    from t0
    full outer join t1 on t0.parent_bk = t1.parent_bk
    full outer join t2 on coalesce(t0.parent_bk, t1.parent_bk) = t2.parent_bk
    full outer join t3 on coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk) = t3.parent_bk
    full outer join t4 on coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk) = t4.parent_bk
    full outer join t5 on coalesce(coalesce(coalesce(coalesce(t0.parent_bk, t1.parent_bk), t2.parent_bk), t3.parent_bk), t4.parent_bk) = t5.parent_bk
    )
