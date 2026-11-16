{{ config(materialized='view') }}

-- UNPIVOT for SAT_CLAIM_NOTE from
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
-- one row PER INSTANCE: 9 branch(es), discriminated by NOTE_SEQUENCE.
-- The hash is taken once, downstream, by stg2_mt_up__clm_clmd_clmap_pv__sat_claim_note.
--
-- INCREMENTAL VIEW: returns only rows whose REC_REFRESH_AT is after the latest
-- LOAD_DATETIME this feeder already wrote to SAT_CLAIM_NOTE.
--   Incremental (default):  dbt run -s +sat_claim_note
--   Full load:              dbt run -s +sat_claim_note --vars '{full_load: true}'
--   (--full-refresh, or SAT_CLAIM_NOTE not existing yet, also gives full data)

{%- set sat_rel = adapter.get_relation(database=this.database, schema=this.schema, identifier='SAT_CLAIM_NOTE') if execute else none %}
{%- set is_full_load = var('full_load', false) or flags.FULL_REFRESH or sat_rel is none %}

with src as (
    select *
    from {{ ref('resolved_mt__clm_clmd_clmap_pv') }}
    {%- if not is_full_load %}
    where try_to_timestamp_ntz(to_varchar(rec_refresh_at)) > (
        select coalesce(max(try_to_timestamp_ntz(to_varchar(LOAD_DATETIME))), '1900-01-01'::timestamp_ntz)
        from {{ sat_rel }}
        where RECORD_SOURCE = 'MAXIMUS_TRAVEL_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW'
    )
    {%- endif %}
)

    select
        nullif(trim(case when coalesce(nullif(trim(claimno),''), nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(claimno), ''), nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'') as CLAIM_BK,
        'ACTION_TAKEN' as NOTE_SEQUENCE,
        action as ACTION_TAKEN,
        cast(null as varchar) as NOTE_TEXT,
        rec_refresh_at,
        'MAXIMUS_TRAVEL_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from src
    where action is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(claimno),''), nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(claimno), ''), nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'') as CLAIM_BK,
        'CLAIM_CLOSURE_REMARKS' as NOTE_SEQUENCE,
        cast(null as varchar) as ACTION_TAKEN,
        claim_close_remarks as NOTE_TEXT,
        rec_refresh_at,
        'MAXIMUS_TRAVEL_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from src
    where claim_close_remarks is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(claimno),''), nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(claimno), ''), nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'') as CLAIM_BK,
        'CLAIM_STATUS_REMARK' as NOTE_SEQUENCE,
        cast(null as varchar) as ACTION_TAKEN,
        claim_status_remark as NOTE_TEXT,
        rec_refresh_at,
        'MAXIMUS_TRAVEL_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from src
    where claim_status_remark is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(claimno),''), nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(claimno), ''), nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'') as CLAIM_BK,
        'GENERAL_COMMENTS' as NOTE_SEQUENCE,
        cast(null as varchar) as ACTION_TAKEN,
        comments as NOTE_TEXT,
        rec_refresh_at,
        'MAXIMUS_TRAVEL_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from src
    where comments is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(claimno),''), nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(claimno), ''), nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'') as CLAIM_BK,
        'INTERNAL_CLAIM_COMMENTS' as NOTE_SEQUENCE,
        cast(null as varchar) as ACTION_TAKEN,
        internal_claim_comments as NOTE_TEXT,
        rec_refresh_at,
        'MAXIMUS_TRAVEL_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from src
    where internal_claim_comments is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(claimno),''), nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(claimno), ''), nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'') as CLAIM_BK,
        'OTHER_REMARKS' as NOTE_SEQUENCE,
        cast(null as varchar) as ACTION_TAKEN,
        other_remarks as NOTE_TEXT,
        rec_refresh_at,
        'MAXIMUS_TRAVEL_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from src
    where other_remarks is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(claimno),''), nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(claimno), ''), nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'') as CLAIM_BK,
        'REMARKS' as NOTE_SEQUENCE,
        cast(null as varchar) as ACTION_TAKEN,
        remarks as NOTE_TEXT,
        rec_refresh_at,
        'MAXIMUS_TRAVEL_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from src
    where remarks is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(claimno),''), nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(claimno), ''), nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'') as CLAIM_BK,
        'SPECIAL_REMARKS' as NOTE_SEQUENCE,
        cast(null as varchar) as ACTION_TAKEN,
        any_special_remarks as NOTE_TEXT,
        rec_refresh_at,
        'MAXIMUS_TRAVEL_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from src
    where any_special_remarks is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(claimno),''), nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(claimno), ''), nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'') as CLAIM_BK,
        'TEAM_TRACKING_COMMENTS' as NOTE_SEQUENCE,
        cast(null as varchar) as ACTION_TAKEN,
        general_team_comments_tracking_comments as NOTE_TEXT,
        rec_refresh_at,
        'MAXIMUS_TRAVEL_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from src
    where general_team_comments_tracking_comments is not null
