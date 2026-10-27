{{ config(materialized='view') }}

-- FEED for SAT_LOSS_EVENT_NOTIFICATION (target track): unions 1 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 1 payload column(s), 0 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_LOSS_EVENT_NOTIFICATION to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        LOSS_EVENT_HKEY__V2 as LOSS_EVENT_HKEY,
        NOTIFIED_BY_ROLE as NOTIFIED_BY_ROLE,
        HASHDIFF_LOSS_EVENT_NOTIFICATION as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmap_pv') }}
    where LOSS_EVENT_HKEY__V2 is not null
