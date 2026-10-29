{{ config(materialized='view') }}

-- FEED for SAT_POLICY_SUM_INSURED_BREAKUP (target track): unions 3 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 2 payload column(s), 1 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_POLICY_SUM_INSURED_BREAKUP to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        POLICY_HKEY as POLICY_HKEY,
        SUM_INSURED_HEAD as SUM_INSURED_HEAD,
        SUM_INSURED_AMOUNT as SUM_INSURED_AMOUNT,
        SUM_INSURED_BREAK_UP_DETAIL as SUM_INSURED_BREAK_UP_DETAIL,
        HASHDIFF_POLICY_SUM_INSURED_BREAKUP as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_ins_cov_covp_sp_pv') }}
    where POLICY_HKEY is not null
union all
    select
        POLICY_HKEY as POLICY_HKEY,
        SUM_INSURED_HEAD as SUM_INSURED_HEAD,
        SUM_INSURED_AMOUNT as SUM_INSURED_AMOUNT,
        SUM_INSURED_BREAK_UP_DETAIL as SUM_INSURED_BREAK_UP_DETAIL,
        HASHDIFF_POLICY_SUM_INSURED_BREAKUP as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_ins_rskp_sp_pv') }}
    where POLICY_HKEY is not null
union all
    select
        POLICY_HKEY as POLICY_HKEY,
        SUM_INSURED_HEAD as SUM_INSURED_HEAD,
        SUM_INSURED_AMOUNT as SUM_INSURED_AMOUNT,
        SUM_INSURED_BREAK_UP_DETAIL as SUM_INSURED_BREAK_UP_DETAIL,
        HASHDIFF_POLICY_SUM_INSURED_BREAKUP as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_polp_msp_msd_prop_pv') }}
    where POLICY_HKEY is not null
