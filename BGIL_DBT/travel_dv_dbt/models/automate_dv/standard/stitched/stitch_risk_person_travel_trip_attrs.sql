{{ config(materialized='view') }}

-- TRAVEL STANDARD-MODEL stitch for SAT_RISK_PERSON_TRAVEL (HUB_RISK_OBJECT grain, via
-- POLICY_REF). The ONE genuine join in this LOB build: BJAZ_TRV_LOADER_DATA_MV's own
-- traveller columns (policy_ref, each MEMBERn passport, and the 5 non-MemberN-prefixed
-- trip columns) PLUS BA_TRV_DATA_POLICY_DTLS_MV's trip attributes, joined on the shared
-- POLICY_REF (round 3, mapper-confirmed same key/value space on both).
--
-- Converted to the stitch_incremental macro (task 4). The unique_key is kept as
-- 'policy_ref' -- NOT the macro default 'parent_bk' -- because the downstream member
-- stages (stg2_risk_person_travel_bjaz_trv_loader_data_mv_memberN.sql) derive their
-- PARENT_BK/PARENT_NK from a raw 'policy_ref' column and read the passthrough columns by
-- their original lowercase names. The macro's LEFT JOINs over the affected_keys union
-- preserve every loader-side policy (matching the original LEFT JOIN from the loader).
-- No attribute is fed by more than one source, so every coalesce_rule is single-source
-- (macro emits a bare column, no 1-arg COALESCE). Attribute-level COALESCE between the
-- two sources still happens per-member downstream in each stage()'s derived_columns.
--
-- Fix A (self-caught, round 3): AREAPLAN/DEPARTUREDATE/NOOFJOURNEYDAYS/PRJOURNEY/
-- RETURNDATE are valid mapped columns with no MemberN prefix that the original per-member
-- generator silently never built. Passed through here so every member stage fans them out.

{%- set sources = [
    {
        'model': 'stg_travel__bjaz_trv_loader_data_mv',
        'alias': 't0',
        'key_column': 'policy_ref',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'member1passportno', 'tgt': 'member1passportno'},
            {'src': 'member2passportno', 'tgt': 'member2passportno'},
            {'src': 'member3passportno', 'tgt': 'member3passportno'},
            {'src': 'member4passportno', 'tgt': 'member4passportno'},
            {'src': 'member5passportno', 'tgt': 'member5passportno'},
            {'src': 'areaplan', 'tgt': 'areaplan'},
            {'src': 'departuredate', 'tgt': 'departuredate'},
            {'src': 'noofjourneydays', 'tgt': 'noofjourneydays'},
            {'src': 'prjourney', 'tgt': 'prjourney'},
            {'src': 'returndate', 'tgt': 'returndate'}
        ],
        'source_tag': 'BJAZ_TRV_LOADER_DATA_MV'
    },
    {
        'model': 'stg_travel__ba_trv_data_policy_dtls_mv',
        'alias': 't1',
        'key_column': 'policy_ref',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'destination', 'tgt': 'destination'},
            {'src': 'no_of_days', 'tgt': 'no_of_days'},
            {'src': 'travel_area_plan_nm', 'tgt': 'travel_area_plan_nm'},
            {'src': 'travel_area_plan_no', 'tgt': 'travel_area_plan_no'},
            {'src': 'type_of_visa', 'tgt': 'type_of_visa'}
        ],
        'source_tag': 'BA_TRV_DATA_POLICY_DTLS_MV'
    }
] -%}

{%- set output_columns = [
    'member1passportno',
    'member2passportno',
    'member3passportno',
    'member4passportno',
    'member5passportno',
    'areaplan',
    'departuredate',
    'noofjourneydays',
    'prjourney',
    'returndate',
    'destination',
    'no_of_days',
    'travel_area_plan_nm',
    'travel_area_plan_no',
    'type_of_visa'
] -%}

{%- set coalesce_rules = {
    'member1passportno':   ['t0'],
    'member2passportno':   ['t0'],
    'member3passportno':   ['t0'],
    'member4passportno':   ['t0'],
    'member5passportno':   ['t0'],
    'areaplan':            ['t0'],
    'departuredate':       ['t0'],
    'noofjourneydays':     ['t0'],
    'prjourney':           ['t0'],
    'returndate':          ['t0'],
    'destination':         ['t1'],
    'no_of_days':          ['t1'],
    'travel_area_plan_nm': ['t1'],
    'travel_area_plan_no': ['t1'],
    'type_of_visa':        ['t1']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='policy_ref',
    target_sat='sat_travel_risk_person_travel'
) }}
