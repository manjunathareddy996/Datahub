{{ config(materialized='view') }}

-- FEED for SAT_QUOTE_HEADER (target track): unions 3 feeder(s).
--
-- Payload is the union over ALL feeders, null-padded to the SATELLITE -- not to any one
-- feeder group (BUILD_RULES 6). 8 payload column(s), 0 child-key column(s).
--
-- The hashdiff is renamed here from the wide stage's HASHDIFF_QUOTE_HEADER to the bare HASHDIFF the sibling
-- writes on all 45 of its satellites. The wide stage cannot use the bare name because
-- 27 views feed more than one sibling-built satellite (BD7 / BUILD_RULES 12).

    select
        QUOTE_HKEY as QUOTE_HKEY,
        LEAD_REFERENCE as LEAD_REFERENCE,
        PROSPECT_REFERENCE as PROSPECT_REFERENCE,
        QUOTE_REMARKS as QUOTE_REMARKS,
        QUOTE_SOURCE as QUOTE_SOURCE,
        QUOTE_STATUS as QUOTE_STATUS,
        REQUESTED_COVER_START_DATE as REQUESTED_COVER_START_DATE,
        REQUESTED_POLICY_TERM as REQUESTED_POLICY_TERM,
        REQUESTED_SUM_INSURED as REQUESTED_SUM_INSURED,
        HASHDIFF_QUOTE_HEADER as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_qpd') }}
    where QUOTE_HKEY is not null
union all
    select
        QUOTE_HKEY as QUOTE_HKEY,
        LEAD_REFERENCE as LEAD_REFERENCE,
        PROSPECT_REFERENCE as PROSPECT_REFERENCE,
        QUOTE_REMARKS as QUOTE_REMARKS,
        QUOTE_SOURCE as QUOTE_SOURCE,
        QUOTE_STATUS as QUOTE_STATUS,
        REQUESTED_COVER_START_DATE as REQUESTED_COVER_START_DATE,
        REQUESTED_POLICY_TERM as REQUESTED_POLICY_TERM,
        REQUESTED_SUM_INSURED as REQUESTED_SUM_INSURED,
        HASHDIFF_QUOTE_HEADER as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_qpd_polp_rl_pv') }}
    where QUOTE_HKEY is not null
union all
    select
        QUOTE_HKEY as QUOTE_HKEY,
        LEAD_REFERENCE as LEAD_REFERENCE,
        PROSPECT_REFERENCE as PROSPECT_REFERENCE,
        QUOTE_REMARKS as QUOTE_REMARKS,
        QUOTE_SOURCE as QUOTE_SOURCE,
        QUOTE_STATUS as QUOTE_STATUS,
        REQUESTED_COVER_START_DATE as REQUESTED_COVER_START_DATE,
        REQUESTED_POLICY_TERM as REQUESTED_POLICY_TERM,
        REQUESTED_SUM_INSURED as REQUESTED_SUM_INSURED,
        HASHDIFF_QUOTE_HEADER as HASHDIFF,
        LOAD_DATETIME, RECORD_SOURCE
    from {{ ref('stg2_mt__uwr_qpd_rskl_rskp_rl_pv') }}
    where QUOTE_HKEY is not null
