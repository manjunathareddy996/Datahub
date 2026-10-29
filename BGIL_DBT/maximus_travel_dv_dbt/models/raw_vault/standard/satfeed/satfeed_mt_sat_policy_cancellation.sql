{{ config(materialized='view') }}

-- FEED for SAT_POLICY_CANCELLATION (target track): unions 1 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 5 payload column(s), 0 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_POLICY_CANCELLATION to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        POLICY_HKEY as POLICY_HKEY,
        CANCELLATION_REQUESTED_BY_ROLE as CANCELLATION_REQUESTED_BY_ROLE,
        CANCELLATION_PREMIUM_BASIS as CANCELLATION_PREMIUM_BASIS,
        ELAPSED_PERIOD_PREMIUM_AMOUNT as ELAPSED_PERIOD_PREMIUM_AMOUNT,
        RETAINED_ADMIN_CHARGES_AMOUNT as RETAINED_ADMIN_CHARGES_AMOUNT,
        UNEXPIRED_PERIOD_PREMIUM_AMOUNT as UNEXPIRED_PERIOD_PREMIUM_AMOUNT,
        HASHDIFF_POLICY_CANCELLATION as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_polp_sp_pv') }}
    where POLICY_HKEY is not null
