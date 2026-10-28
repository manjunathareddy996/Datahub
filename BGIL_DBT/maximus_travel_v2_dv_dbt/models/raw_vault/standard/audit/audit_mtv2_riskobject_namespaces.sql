{{ config(materialized='view') }}

-- HUB_RISK_OBJECT carries TWO namespaces: 'RISK:' on 215 key rows and 'TRIP:' on 12,
-- and BOTH write SAT_RISK_PERSON_TRAVEL (open items RISKOBJ-TWO-NAMESPACES and
-- TRIPNO-FALLBACK). This counts the split so two populations are visible rather than
-- silent.
--
-- The TRIP: keys fall back to TRIP_NO when PNR is blank. If TRIP_NO is a per-policy
-- ordinal rather than a global trip identifier, every policy's first trip collapses onto
-- 'TRIP:1'. distinct_keys far below rows_in on the TRIP: namespace is that symptom.

    select 'clm_clmd_clmap_pv' as feeder, 'claimed-risk-item' as instance,
           split_part(RISK_OBJECT_BK__CLAIMED_RISK_ITEM, ':', 1) as namespace, count(*) as rows_in,
           count(distinct RISK_OBJECT_BK__CLAIMED_RISK_ITEM) as distinct_keys
    from {{ ref('stg2_mtv2__clm_clmd_clmap_pv') }} where RISK_OBJECT_BK__CLAIMED_RISK_ITEM is not null group by 1,2,3
union all
    select 'clm_clmd_clmrsk' as feeder, 'claimed-risk-item' as instance,
           split_part(RISK_OBJECT_BK__CLAIMED_RISK_ITEM, ':', 1) as namespace, count(*) as rows_in,
           count(distinct RISK_OBJECT_BK__CLAIMED_RISK_ITEM) as distinct_keys
    from {{ ref('stg2_mtv2__clm_clmd_clmrsk') }} where RISK_OBJECT_BK__CLAIMED_RISK_ITEM is not null group by 1,2,3
union all
    select 'uwr_pol_ins' as feeder, '-' as instance,
           split_part(RISK_OBJECT_BK, ':', 1) as namespace, count(*) as rows_in,
           count(distinct RISK_OBJECT_BK) as distinct_keys
    from {{ ref('stg2_mtv2__uwr_pol_ins') }} where RISK_OBJECT_BK is not null group by 1,2,3
union all
    select 'uwr_pol_ins' as feeder, 'insured-risk-line' as instance,
           split_part(RISK_OBJECT_BK__INSURED_RISK_LINE, ':', 1) as namespace, count(*) as rows_in,
           count(distinct RISK_OBJECT_BK__INSURED_RISK_LINE) as distinct_keys
    from {{ ref('stg2_mtv2__uwr_pol_ins') }} where RISK_OBJECT_BK__INSURED_RISK_LINE is not null group by 1,2,3
union all
    select 'uwr_pol_ins_cov_covp_sp_pv' as feeder, '-' as instance,
           split_part(RISK_OBJECT_BK, ':', 1) as namespace, count(*) as rows_in,
           count(distinct RISK_OBJECT_BK) as distinct_keys
    from {{ ref('stg2_mtv2__uwr_pol_ins_cov_covp_sp_pv') }} where RISK_OBJECT_BK is not null group by 1,2,3
union all
    select 'uwr_pol_ins_rskp_msp_msd_prop_pv' as feeder, '-' as instance,
           split_part(RISK_OBJECT_BK, ':', 1) as namespace, count(*) as rows_in,
           count(distinct RISK_OBJECT_BK) as distinct_keys
    from {{ ref('stg2_mtv2__uwr_pol_ins_rskp_msp_msd_prop_pv') }} where RISK_OBJECT_BK is not null group by 1,2,3
union all
    select 'uwr_pol_ins_rskp_sp_pv' as feeder, '-' as instance,
           split_part(RISK_OBJECT_BK, ':', 1) as namespace, count(*) as rows_in,
           count(distinct RISK_OBJECT_BK) as distinct_keys
    from {{ ref('stg2_mtv2__uwr_pol_ins_rskp_sp_pv') }} where RISK_OBJECT_BK is not null group by 1,2,3
union all
    select 'uwr_pol_ins_rskp_sp_pv' as feeder, 'insured-traveller-risk' as instance,
           split_part(RISK_OBJECT_BK__INSURED_TRAVELLER_RISK, ':', 1) as namespace, count(*) as rows_in,
           count(distinct RISK_OBJECT_BK__INSURED_TRAVELLER_RISK) as distinct_keys
    from {{ ref('stg2_mtv2__uwr_pol_ins_rskp_sp_pv') }} where RISK_OBJECT_BK__INSURED_TRAVELLER_RISK is not null group by 1,2,3
union all
    select 'uwr_pol_polp_msp_msd_prop_pv' as feeder, '-' as instance,
           split_part(RISK_OBJECT_BK, ':', 1) as namespace, count(*) as rows_in,
           count(distinct RISK_OBJECT_BK) as distinct_keys
    from {{ ref('stg2_mtv2__uwr_pol_polp_msp_msd_prop_pv') }} where RISK_OBJECT_BK is not null group by 1,2,3
union all
    select 'uwr_qpd_rskl' as feeder, '-' as instance,
           split_part(RISK_OBJECT_BK, ':', 1) as namespace, count(*) as rows_in,
           count(distinct RISK_OBJECT_BK) as distinct_keys
    from {{ ref('stg2_mtv2__uwr_qpd_rskl') }} where RISK_OBJECT_BK is not null group by 1,2,3
union all
    select 'uwr_qpd_rskl_msp_imsd_inp_pv' as feeder, '-' as instance,
           split_part(RISK_OBJECT_BK, ':', 1) as namespace, count(*) as rows_in,
           count(distinct RISK_OBJECT_BK) as distinct_keys
    from {{ ref('stg2_mtv2__uwr_qpd_rskl_msp_imsd_inp_pv') }} where RISK_OBJECT_BK is not null group by 1,2,3
union all
    select 'uwr_qpd_rskl_rskc' as feeder, '-' as instance,
           split_part(RISK_OBJECT_BK, ':', 1) as namespace, count(*) as rows_in,
           count(distinct RISK_OBJECT_BK) as distinct_keys
    from {{ ref('stg2_mtv2__uwr_qpd_rskl_rskc') }} where RISK_OBJECT_BK is not null group by 1,2,3
union all
    select 'uwr_qpd_rskl_rskc_rskc_prop_rl_pv' as feeder, '-' as instance,
           split_part(RISK_OBJECT_BK, ':', 1) as namespace, count(*) as rows_in,
           count(distinct RISK_OBJECT_BK) as distinct_keys
    from {{ ref('stg2_mtv2__uwr_qpd_rskl_rskc_rskc_prop_rl_pv') }} where RISK_OBJECT_BK is not null group by 1,2,3
union all
    select 'uwr_qpd_rskl_rskp_rl_pv' as feeder, '-' as instance,
           split_part(RISK_OBJECT_BK, ':', 1) as namespace, count(*) as rows_in,
           count(distinct RISK_OBJECT_BK) as distinct_keys
    from {{ ref('stg2_mtv2__uwr_qpd_rskl_rskp_rl_pv') }} where RISK_OBJECT_BK is not null group by 1,2,3
union all
    select 'uwr_qpd_rskl_rskp_rl_pv' as feeder, 'quoted-traveller-risk' as instance,
           split_part(RISK_OBJECT_BK__QUOTED_TRAVELLER_RISK, ':', 1) as namespace, count(*) as rows_in,
           count(distinct RISK_OBJECT_BK__QUOTED_TRAVELLER_RISK) as distinct_keys
    from {{ ref('stg2_mtv2__uwr_qpd_rskl_rskp_rl_pv') }} where RISK_OBJECT_BK__QUOTED_TRAVELLER_RISK is not null group by 1,2,3
