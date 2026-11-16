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

-- INCREMENTAL VIEW: returns only rows whose REC_REFRESH_AT is after the latest
-- LOAD_DATETIME this feeder already wrote to SAT_CLAIM_NOTE.
--   Incremental (default):  dbt run -s +sat_claim_note
--   Full load:              dbt run -s +sat_claim_note --vars '{full_load: true}'
--   (--full-refresh, or SAT_CLAIM_NOTE not existing yet, also gives full data)

{%- set sat_rel = adapter.get_relation(database=this.database, schema=this.schema, identifier='SAT_CLAIM_NOTE') if execute else none %}
{%- set is_full_load = var('full_load', false) or flags.FULL_REFRESH or sat_rel is none %}

with src as (
    select *
    from {{ ref('resolved_mt__clm_clmd_clmrsk_rska_properties_pv') }}
    {%- if not is_full_load %}
    where try_to_timestamp_ntz(to_varchar(rec_refresh_at)) > (
        select coalesce(max(try_to_timestamp_ntz(to_varchar(LOAD_DATETIME))), '1900-01-01'::timestamp_ntz)
        from {{ sat_rel }}
        where RECORD_SOURCE = 'MAXIMUS_TRAVEL_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_PROPERTIES_PIVOT_VW'
    )
    {%- endif %}
)

    select
        nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'') as CLAIM_BK,
        'GENERAL_COMMENTS' as NOTE_SEQUENCE,
        cast(null as varchar) as ACTION_TAKEN,
        comments as NOTE_TEXT,
        rec_refresh_at,
        'MAXIMUS_TRAVEL_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from src
    where comments is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'') as CLAIM_BK,
        'REASON' as NOTE_SEQUENCE,
        cast(null as varchar) as ACTION_TAKEN,
        reason as NOTE_TEXT,
        rec_refresh_at,
        'MAXIMUS_TRAVEL_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from src
    where reason is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'') as CLAIM_BK,
        'TEAM_TRACKING_COMMENTS' as NOTE_SEQUENCE,
        cast(null as varchar) as ACTION_TAKEN,
        general_team_comments_tracking_comments as NOTE_TEXT,
        rec_refresh_at,
        'MAXIMUS_TRAVEL_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_RISK_RISK_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from src
    where general_team_comments_tracking_comments is not null
