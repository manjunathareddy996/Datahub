{{ config(materialized='view') }}

-- FEED for SAT_ASSESSMENT_HEADER (target track): unions 1 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 4 payload column(s), 0 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_ASSESSMENT_HEADER to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        ASSESSMENT_HKEY__TELE_VERIFICATION as ASSESSMENT_HKEY,
        ASSESSMENT_STATUS as ASSESSMENT_STATUS,
        REQUESTED_DATE as REQUESTED_DATE,
        ASSESSMENT_END_TIME as ASSESSMENT_END_TIME,
        ASSESSMENT_START_TIME as ASSESSMENT_START_TIME,
        HASHDIFF_ASSESSMENT_HEADER as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mtv2__uwr_pol_tele') }}
    where ASSESSMENT_HKEY__TELE_VERIFICATION is not null
