{{ config(materialized='view') }}

-- UNPIVOT for SAT_CLAIM_NOTE from
--   NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW
-- one row PER INSTANCE: 9 branch(es).
--
-- Each branch below is ONE instance of the satellite, carrying all of its own
-- attributes on a single row and discriminated by NOTE_SEQUENCE.
-- The hash is taken once, downstream, by stg2_mtv2_up__clm_clmd_clmap_pv__sat_claim_note.
--
-- Payload is null-padded to the SATELLITE's full payload (2 column(s)), not to this
-- feeder's columns, so every feeder of SAT_CLAIM_NOTE is union-compatible (BUILD_RULES 6).
--
-- Instances on this view:
--   action_taken                             1 attribute(s)
--   claim_closure_remarks                    1 attribute(s)
--   claim_status_remark                      1 attribute(s)
--   general_comments                         1 attribute(s)
--   internal_claim_comments                  1 attribute(s)
--   other_remarks                            1 attribute(s)
--   remarks                                  1 attribute(s)
--   special_remarks                          1 attribute(s)
--   team_tracking_comments                   1 attribute(s)

    select
        nullif(trim(case when coalesce(nullif(trim(claimno),''), nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(claimno), ''), nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'') as CLAIM_BK,
        'ACTION_TAKEN' as NOTE_SEQUENCE,
        action as ACTION_TAKEN,
        cast(null as varchar) as NOTE_TEXT,
        'MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__clm_clmd_clmap_pv') }}
    where action is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(claimno),''), nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(claimno), ''), nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'') as CLAIM_BK,
        'CLAIM_CLOSURE_REMARKS' as NOTE_SEQUENCE,
        cast(null as varchar) as ACTION_TAKEN,
        claim_close_remarks as NOTE_TEXT,
        'MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__clm_clmd_clmap_pv') }}
    where claim_close_remarks is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(claimno),''), nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(claimno), ''), nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'') as CLAIM_BK,
        'CLAIM_STATUS_REMARK' as NOTE_SEQUENCE,
        cast(null as varchar) as ACTION_TAKEN,
        claim_status_remark as NOTE_TEXT,
        'MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__clm_clmd_clmap_pv') }}
    where claim_status_remark is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(claimno),''), nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(claimno), ''), nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'') as CLAIM_BK,
        'GENERAL_COMMENTS' as NOTE_SEQUENCE,
        cast(null as varchar) as ACTION_TAKEN,
        comments as NOTE_TEXT,
        'MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__clm_clmd_clmap_pv') }}
    where comments is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(claimno),''), nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(claimno), ''), nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'') as CLAIM_BK,
        'INTERNAL_CLAIM_COMMENTS' as NOTE_SEQUENCE,
        cast(null as varchar) as ACTION_TAKEN,
        internal_claim_comments as NOTE_TEXT,
        'MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__clm_clmd_clmap_pv') }}
    where internal_claim_comments is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(claimno),''), nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(claimno), ''), nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'') as CLAIM_BK,
        'OTHER_REMARKS' as NOTE_SEQUENCE,
        cast(null as varchar) as ACTION_TAKEN,
        other_remarks as NOTE_TEXT,
        'MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__clm_clmd_clmap_pv') }}
    where other_remarks is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(claimno),''), nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(claimno), ''), nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'') as CLAIM_BK,
        'REMARKS' as NOTE_SEQUENCE,
        cast(null as varchar) as ACTION_TAKEN,
        remarks as NOTE_TEXT,
        'MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__clm_clmd_clmap_pv') }}
    where remarks is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(claimno),''), nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(claimno), ''), nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'') as CLAIM_BK,
        'SPECIAL_REMARKS' as NOTE_SEQUENCE,
        cast(null as varchar) as ACTION_TAKEN,
        any_special_remarks as NOTE_TEXT,
        'MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__clm_clmd_clmap_pv') }}
    where any_special_remarks is not null
union all
    select
        nullif(trim(case when coalesce(nullif(trim(claimno),''), nullif(trim(w0_claimno),''), nullif(trim(foreign_key),'')) is not null then coalesce(nullif(trim(claimno), ''), nullif(trim(w0_claimno), ''), nullif(trim(foreign_key), '')) end),'') as CLAIM_BK,
        'TEAM_TRACKING_COMMENTS' as NOTE_SEQUENCE,
        cast(null as varchar) as ACTION_TAKEN,
        general_team_comments_tracking_comments as NOTE_TEXT,
        'MAXIMUS_NONHLTH_TRV_CLM_VW_DATA_CLAIM_DETAILS_CLAIM_ATTRIBUTE_PROPERTIES_PIVOT_VW' as record_source
    from {{ ref('resolved_mtv2__clm_clmd_clmap_pv') }}
    where general_team_comments_tracking_comments is not null
