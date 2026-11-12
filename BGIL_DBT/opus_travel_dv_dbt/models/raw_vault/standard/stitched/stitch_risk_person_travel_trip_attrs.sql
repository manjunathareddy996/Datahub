{{ config(materialized='view') }}
-- TRAVEL STANDARD-MODEL stitch view for SAT_RISK_PERSON_TRAVEL (grain: POLICY_REF).
-- 2 table(s) contributing at this grain.
-- Uses the stitch_incremental macro.
--
-- The ONE genuine join needed anywhere in this LOB build (every other satellite here is a
-- plain per-table union -- see README Architecture section for why).
--   t1 = BJAZ_TRV_LOADER_DATA   : each MEMBERn passport number + the 5 non-MemberN-prefixed
--                                 trip columns (AREAPLAN, DEPARTUREDATE, NOOFJOURNEYDAYS,
--                                 PRJOURNEY, RETURNDATE -- the "Fix A" columns the original
--                                 per-member generator silently missed).
--   t2 = BA_TRV_DATA_POLICY_DTLS: trip attributes (DESTINATION, NO_OF_DAYS, TRAVEL_AREA_PLAN_NM/NO,
--                                 TYPE_OF_VISA), stitched on the shared POLICY_REF (round 3,
--                                 mapper-confirmed: same key, same value space).
-- Each output column comes from exactly ONE source, so attribute-level COALESCE between the two
-- sources still happens downstream, per attribute, in each member's stage()
-- (see stg2_risk_person_travel_bjaz_trv_loader_data_memberN.sql). This view stays raw, zero hashing,
-- matching the Health/Partner convention.
--
-- Output columns keep the names the member stages already read (policy_ref, member1passportno,
-- ..., destination, type_of_visa, inc_job_updated_at). The macro also emits record_source
-- (the contributing source tags), which the member stages do not select.
--
-- BEHAVIOUR vs the previous hand-written view: that view was a LEFT JOIN from BJAZ_TRV_LOADER_DATA, so
-- only policies present in the loader table were emitted. stitch_incremental builds its key set from
-- the UNION of both sources' changed keys, so a POLICY_REF that exists only in BA_TRV_DATA_POLICY_DTLS
-- is now emitted too (loader columns NULL; the member stages then see a NULL passport number).
-- Rows are also limited to keys whose source row changed inside the load window
-- (from_date < inc_job_updated_at <= to_date; from_date = MAX(DBT_RUN_TS) of
-- sat_risk_person_travel for the OPUS record sources, to_date = run time in IST, both overridable
-- with --vars).
{%- set sources = [
    {
        'model': 'stg_travel__bjaz_trv_loader_data',
        'alias': 't1',
        'key_column': 'policy_ref',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'member1passportno', 'tgt': 'member1passportno'},
            {'src': 'member2passportno', 'tgt': 'member2passportno'},
            {'src': 'member3passportno', 'tgt': 'member3passportno'},
            {'src': 'member4passportno', 'tgt': 'member4passportno'},
            {'src': 'member5passportno', 'tgt': 'member5passportno'},
            {'src': 'areaplan',          'tgt': 'areaplan'},
            {'src': 'departuredate',     'tgt': 'departuredate'},
            {'src': 'noofjourneydays',   'tgt': 'noofjourneydays'},
            {'src': 'prjourney',         'tgt': 'prjourney'},
            {'src': 'returndate',        'tgt': 'returndate'}
        ],
        'source_tag': 'OPUS_TRAVEL_BJAZ_TRV_LOADER_DATA'
    },
    {
        'model': 'stg_travel__ba_trv_data_policy_dtls',
        'alias': 't2',
        'key_column': 'policy_ref',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'destination',         'tgt': 'destination'},
            {'src': 'no_of_days',          'tgt': 'no_of_days'},
            {'src': 'travel_area_plan_nm', 'tgt': 'travel_area_plan_nm'},
            {'src': 'travel_area_plan_no', 'tgt': 'travel_area_plan_no'},
            {'src': 'type_of_visa',        'tgt': 'type_of_visa'}
        ],
        'source_tag': 'OPUS_TRAVEL_BA_TRV_DATA_POLICY_DTLS'
    }
] -%}
{%- set output_columns = [
    'member1passportno', 'member2passportno', 'member3passportno', 'member4passportno', 'member5passportno',
    'areaplan', 'departuredate', 'noofjourneydays', 'prjourney', 'returndate',
    'destination', 'no_of_days', 'travel_area_plan_nm', 'travel_area_plan_no', 'type_of_visa'
] -%}
{%- set coalesce_rules = {
    'member1passportno':   ['t1'],
    'member2passportno':   ['t1'],
    'member3passportno':   ['t1'],
    'member4passportno':   ['t1'],
    'member5passportno':   ['t1'],
    'areaplan':            ['t1'],
    'departuredate':       ['t1'],
    'noofjourneydays':     ['t1'],
    'prjourney':           ['t1'],
    'returndate':          ['t1'],
    'destination':         ['t2'],
    'no_of_days':          ['t2'],
    'travel_area_plan_nm': ['t2'],
    'travel_area_plan_no': ['t2'],
    'type_of_visa':        ['t2']
} %}
{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='policy_ref',
    target_sat='sat_risk_person_travel'
) }}
