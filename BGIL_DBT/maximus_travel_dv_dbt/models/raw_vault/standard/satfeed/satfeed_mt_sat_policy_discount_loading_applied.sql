{{ config(materialized='view') }}

-- FEED for SAT_POLICY_DISCOUNT_LOADING_APPLIED (target track): unions 3 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 6 payload column(s), 1 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_POLICY_DISCOUNT_LOADING_APPLIED to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        POLICY_HKEY as POLICY_HKEY,
        ITEM_CODE as ITEM_CODE,
        AMOUNT_APPLIED as AMOUNT_APPLIED,
        ITEM_TYPE as ITEM_TYPE,
        PERCENTAGE_APPLIED as PERCENTAGE_APPLIED,
        APPLICABILITY_INDICATOR as APPLICABILITY_INDICATOR,
        RELATIVITY_APPLIED as RELATIVITY_APPLIED,
        RISK_LOADING_TYPE as RISK_LOADING_TYPE,
        HASHDIFF_POLICY_DISCOUNT_LOADING_APPLIED as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_ins_rskp_sp_pv') }}
    where POLICY_HKEY is not null
union all
    select
        POLICY_HKEY as POLICY_HKEY,
        ITEM_CODE as ITEM_CODE,
        AMOUNT_APPLIED as AMOUNT_APPLIED,
        ITEM_TYPE as ITEM_TYPE,
        PERCENTAGE_APPLIED as PERCENTAGE_APPLIED,
        APPLICABILITY_INDICATOR as APPLICABILITY_INDICATOR,
        RELATIVITY_APPLIED as RELATIVITY_APPLIED,
        RISK_LOADING_TYPE as RISK_LOADING_TYPE,
        HASHDIFF_POLICY_DISCOUNT_LOADING_APPLIED as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_polp_msp_msd_prop_pv') }}
    where POLICY_HKEY is not null
union all
    select
        POLICY_HKEY as POLICY_HKEY,
        ITEM_CODE as ITEM_CODE,
        AMOUNT_APPLIED as AMOUNT_APPLIED,
        ITEM_TYPE as ITEM_TYPE,
        PERCENTAGE_APPLIED as PERCENTAGE_APPLIED,
        APPLICABILITY_INDICATOR as APPLICABILITY_INDICATOR,
        RELATIVITY_APPLIED as RELATIVITY_APPLIED,
        RISK_LOADING_TYPE as RISK_LOADING_TYPE,
        HASHDIFF_POLICY_DISCOUNT_LOADING_APPLIED as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt_up__uwr_pol_polp_sp_pv__sat_policy_discount_loading_applied') }}
    where POLICY_HKEY is not null
