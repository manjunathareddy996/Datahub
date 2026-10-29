{{ config(materialized='view') }}

-- FEED for SAT_LOSS_EVENT_DETAIL (target track): unions 1 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 8 payload column(s), 0 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_LOSS_EVENT_DETAIL to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        LOSS_EVENT_HKEY as LOSS_EVENT_HKEY,
        CAUSE_OF_LOSS as CAUSE_OF_LOSS,
        FIR_DATE as FIR_DATE,
        FIR_NUMBER as FIR_NUMBER,
        LOSS_DESCRIPTION as LOSS_DESCRIPTION,
        LOSS_TIME as LOSS_TIME,
        POLICE_STATION_NAME as POLICE_STATION_NAME,
        THIRD_PARTY_INVOLVED_INDICATOR as THIRD_PARTY_INVOLVED_INDICATOR,
        POLICE_REPORT_TIME as POLICE_REPORT_TIME,
        HASHDIFF_LOSS_EVENT_DETAIL as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__clm_clmd_clmap_pv') }}
    where LOSS_EVENT_HKEY is not null
