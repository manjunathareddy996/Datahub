{{ config(materialized='view') }}

-- UNPIVOT for SAT_CLAIM_NOTE from
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_PROPERTIES_PIVOT_VW
-- one row PER INSTANCE: 3 branch(es).
--
-- Each branch below is ONE instance of the satellite, carrying all of its own
-- attributes on a single row and discriminated by NOTE_SEQUENCE.
-- The hash is taken once, downstream, by stg2_mt_up__clm_clmd_clmrsk_rska_properties_pv__sat_claim_note.
--
-- Payload is null-padded to the SATELLITE's full payload (2 column(s)), not to this
-- feeder's columns, so every feeder of SAT_CLAIM_NOTE is union-compatible (BUILD_RULES 6).
--
-- Instances on this view:
--   general_comments                         1 attribute(s)
--   reason                                   1 attribute(s)
--   team_tracking_comments                   1 attribute(s)

    select
        nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'') as CLAIM_BK,
        'GENERAL_COMMENTS' as NOTE_SEQUENCE,
        cast(null as varchar) as ACTION_TAKEN,
        comments as NOTE_TEXT,
        'MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__clm_clmd_clmrsk_rska_properties_pv') }}
    where comments is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'') as CLAIM_BK,
        'REASON' as NOTE_SEQUENCE,
        cast(null as varchar) as ACTION_TAKEN,
        reason as NOTE_TEXT,
        'MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__clm_clmd_clmrsk_rska_properties_pv') }}
    where reason is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'') as CLAIM_BK,
        'TEAM_TRACKING_COMMENTS' as NOTE_SEQUENCE,
        cast(null as varchar) as ACTION_TAKEN,
        general_team_comments_tracking_comments as NOTE_TEXT,
        'MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from {{ ref('resolved_mt__clm_clmd_clmrsk_rska_properties_pv') }}
    where general_team_comments_tracking_comments is not null
