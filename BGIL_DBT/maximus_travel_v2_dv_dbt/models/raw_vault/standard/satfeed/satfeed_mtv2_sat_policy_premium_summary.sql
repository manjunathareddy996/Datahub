{{ config(materialized='view') }}

-- FEED for SAT_POLICY_PREMIUM_SUMMARY (target track): unions 5 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 7 payload column(s), 0 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_POLICY_PREMIUM_SUMMARY to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        POLICY_HKEY as POLICY_HKEY,
        BASE_PREMIUM as BASE_PREMIUM,
        GROSS_PREMIUM as GROSS_PREMIUM,
        LOADING_AMOUNT as LOADING_AMOUNT,
        NET_PREMIUM as NET_PREMIUM,
        PREMIUM_OUTSTANDING as PREMIUM_OUTSTANDING,
        REFUND_AMOUNT as REFUND_AMOUNT,
        TOTAL_PREMIUM_COLLECTED as TOTAL_PREMIUM_COLLECTED,
        HASHDIFF_POLICY_PREMIUM_SUMMARY as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol') }}
    where POLICY_HKEY is not null
union all
    select
        POLICY_HKEY as POLICY_HKEY,
        BASE_PREMIUM as BASE_PREMIUM,
        GROSS_PREMIUM as GROSS_PREMIUM,
        LOADING_AMOUNT as LOADING_AMOUNT,
        NET_PREMIUM as NET_PREMIUM,
        PREMIUM_OUTSTANDING as PREMIUM_OUTSTANDING,
        REFUND_AMOUNT as REFUND_AMOUNT,
        TOTAL_PREMIUM_COLLECTED as TOTAL_PREMIUM_COLLECTED,
        HASHDIFF_POLICY_PREMIUM_SUMMARY as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_ins_rskp_sp_pv') }}
    where POLICY_HKEY is not null
union all
    select
        POLICY_HKEY as POLICY_HKEY,
        BASE_PREMIUM as BASE_PREMIUM,
        GROSS_PREMIUM as GROSS_PREMIUM,
        LOADING_AMOUNT as LOADING_AMOUNT,
        NET_PREMIUM as NET_PREMIUM,
        PREMIUM_OUTSTANDING as PREMIUM_OUTSTANDING,
        REFUND_AMOUNT as REFUND_AMOUNT,
        TOTAL_PREMIUM_COLLECTED as TOTAL_PREMIUM_COLLECTED,
        HASHDIFF_POLICY_PREMIUM_SUMMARY as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_polp_sp_pv') }}
    where POLICY_HKEY is not null
union all
    select
        POLICY_HKEY__PREVIOUS_POLICY as POLICY_HKEY,
        BASE_PREMIUM as BASE_PREMIUM,
        GROSS_PREMIUM as GROSS_PREMIUM,
        LOADING_AMOUNT as LOADING_AMOUNT,
        NET_PREMIUM as NET_PREMIUM,
        PREMIUM_OUTSTANDING as PREMIUM_OUTSTANDING,
        REFUND_AMOUNT as REFUND_AMOUNT,
        TOTAL_PREMIUM_COLLECTED as TOTAL_PREMIUM_COLLECTED,
        HASHDIFF_POLICY_PREMIUM_SUMMARY as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_prevpol') }}
    where POLICY_HKEY__PREVIOUS_POLICY is not null
union all
    select
        POLICY_HKEY as POLICY_HKEY,
        BASE_PREMIUM as BASE_PREMIUM,
        GROSS_PREMIUM as GROSS_PREMIUM,
        LOADING_AMOUNT as LOADING_AMOUNT,
        NET_PREMIUM as NET_PREMIUM,
        PREMIUM_OUTSTANDING as PREMIUM_OUTSTANDING,
        REFUND_AMOUNT as REFUND_AMOUNT,
        TOTAL_PREMIUM_COLLECTED as TOTAL_PREMIUM_COLLECTED,
        HASHDIFF_POLICY_PREMIUM_SUMMARY as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_prem') }}
    where POLICY_HKEY is not null
