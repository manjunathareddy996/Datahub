{{ config(materialized='view') }}

-- FEED for SAT_COVERAGE_SUBLIMIT_SCHEDULE (target track): unions 1 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 3 payload column(s), 1 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_COVERAGE_SUBLIMIT_SCHEDULE to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        COVERAGE_HKEY as COVERAGE_HKEY,
        ACTIVE_SEQUENCE_NUMBER as ACTIVE_SEQUENCE_NUMBER,
        ITEM_DESCRIPTION as ITEM_DESCRIPTION,
        SUB_LIMIT_AMOUNT as SUB_LIMIT_AMOUNT,
        SUB_LIMIT_ITEM as SUB_LIMIT_ITEM,
        HASHDIFF_COVERAGE_SUBLIMIT_SCHEDULE as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_ins_cov_covp_msp_msd_prop_pv') }}
    where COVERAGE_HKEY is not null
