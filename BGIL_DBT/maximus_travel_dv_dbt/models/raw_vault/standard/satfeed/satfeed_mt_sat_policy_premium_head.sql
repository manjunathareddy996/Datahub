{{ config(materialized='view') }}

-- FEED for SAT_POLICY_PREMIUM_HEAD (target track): unions 4 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 4 payload column(s), 4 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_POLICY_PREMIUM_HEAD to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        POLICY_HKEY as POLICY_HKEY,
        ADJUSTED_INDICATOR as ADJUSTED_INDICATOR,
        COVERAGE_REFERENCE__SAT_POLICY_PREMIUM_HEAD as COVERAGE_REFERENCE,
        PREMIUM_HEAD_CODE as PREMIUM_HEAD_CODE,
        SECTION as SECTION,
        BASE_AMOUNT as BASE_AMOUNT,
        LOADING_AMOUNT as LOADING_AMOUNT,
        NET_HEAD_PREMIUM as NET_HEAD_PREMIUM,
        PREMIUM_BASIS as PREMIUM_BASIS,
        HASHDIFF_POLICY_PREMIUM_HEAD as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_ins_cov') }}
    where POLICY_HKEY is not null
union all
    select
        POLICY_HKEY as POLICY_HKEY,
        ADJUSTED_INDICATOR as ADJUSTED_INDICATOR,
        COVERAGE_REFERENCE as COVERAGE_REFERENCE,
        PREMIUM_HEAD_CODE as PREMIUM_HEAD_CODE,
        SECTION as SECTION,
        BASE_AMOUNT as BASE_AMOUNT,
        LOADING_AMOUNT as LOADING_AMOUNT,
        NET_HEAD_PREMIUM as NET_HEAD_PREMIUM,
        PREMIUM_BASIS as PREMIUM_BASIS,
        HASHDIFF_POLICY_PREMIUM_HEAD as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_up__uwr_pol_ins_cov_covp_sp_pv__sat_policy_premium_head') }}
    where POLICY_HKEY is not null
union all
    select
        POLICY_HKEY as POLICY_HKEY,
        ADJUSTED_INDICATOR as ADJUSTED_INDICATOR,
        COVERAGE_REFERENCE as COVERAGE_REFERENCE,
        PREMIUM_HEAD_CODE as PREMIUM_HEAD_CODE,
        SECTION as SECTION,
        BASE_AMOUNT as BASE_AMOUNT,
        LOADING_AMOUNT as LOADING_AMOUNT,
        NET_HEAD_PREMIUM as NET_HEAD_PREMIUM,
        PREMIUM_BASIS as PREMIUM_BASIS,
        HASHDIFF_POLICY_PREMIUM_HEAD as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_up__uwr_pol_ins_rskp_sp_pv__sat_policy_premium_head') }}
    where POLICY_HKEY is not null
union all
    select
        POLICY_HKEY as POLICY_HKEY,
        ADJUSTED_INDICATOR as ADJUSTED_INDICATOR,
        COVERAGE_REFERENCE as COVERAGE_REFERENCE,
        PREMIUM_HEAD_CODE as PREMIUM_HEAD_CODE,
        SECTION as SECTION,
        BASE_AMOUNT as BASE_AMOUNT,
        LOADING_AMOUNT as LOADING_AMOUNT,
        NET_HEAD_PREMIUM as NET_HEAD_PREMIUM,
        PREMIUM_BASIS as PREMIUM_BASIS,
        HASHDIFF_POLICY_PREMIUM_HEAD as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_up__uwr_pol_polp_msp_msd_prop_pv__sat_policy_premium_head') }}
    where POLICY_HKEY is not null
