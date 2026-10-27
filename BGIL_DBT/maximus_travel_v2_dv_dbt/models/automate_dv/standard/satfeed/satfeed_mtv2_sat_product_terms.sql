{{ config(materialized='view') }}

-- FEED for SAT_PRODUCT_TERMS (target track): unions 2 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 1 payload column(s), 0 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_PRODUCT_TERMS to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        PRODUCT_HKEY as PRODUCT_HKEY,
        FREE_LOOK_PERIOD as FREE_LOOK_PERIOD,
        HASHDIFF_PRODUCT_TERMS as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_ins_rskp_sp_pv') }}
    where PRODUCT_HKEY is not null
union all
    select
        PRODUCT_HKEY as PRODUCT_HKEY,
        FREE_LOOK_PERIOD as FREE_LOOK_PERIOD,
        HASHDIFF_PRODUCT_TERMS as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_qpd_rskl_rskp_rl_pv') }}
    where PRODUCT_HKEY is not null
