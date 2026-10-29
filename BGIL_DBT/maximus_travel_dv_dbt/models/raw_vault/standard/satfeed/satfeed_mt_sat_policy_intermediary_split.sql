{{ config(materialized='view') }}

-- FEED for SAT_POLICY_INTERMEDIARY_SPLIT (target track): unions 2 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 2 payload column(s), 1 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_POLICY_INTERMEDIARY_SPLIT to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        POLICY_HKEY as POLICY_HKEY,
        INTERMEDIARY_REFERENCE as INTERMEDIARY_REFERENCE,
        COMMISSION_AMOUNT as COMMISSION_AMOUNT,
        SUB_IMD_CODE as SUB_IMD_CODE,
        HASHDIFF_POLICY_INTERMEDIARY_SPLIT as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol') }}
    where POLICY_HKEY is not null
union all
    select
        POLICY_HKEY as POLICY_HKEY,
        INTERMEDIARY_REFERENCE as INTERMEDIARY_REFERENCE,
        COMMISSION_AMOUNT as COMMISSION_AMOUNT,
        SUB_IMD_CODE as SUB_IMD_CODE,
        HASHDIFF_POLICY_INTERMEDIARY_SPLIT as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_pol_polp_sp_pv') }}
    where POLICY_HKEY is not null
