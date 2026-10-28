{{ config(materialized='view') }}

-- FEED for SAT_PARTY_PORTFOLIO_SUMMARY (target track): unions 1 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 1 payload column(s), 0 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_PARTY_PORTFOLIO_SUMMARY to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        PARTY_HKEY__INSURED_CUSTOMER as PARTY_HKEY,
        ACTIVE_POLICY_COUNT as ACTIVE_POLICY_COUNT,
        HASHDIFF_PARTY_PORTFOLIO_SUMMARY as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmap_pv') }}
    where PARTY_HKEY__INSURED_CUSTOMER is not null
