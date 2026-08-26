{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL stitch view for SAT_COMMON_ADMIN_GEOGRAPHY, SAT_COMMON_GEO (HUB_LOCATION grain).
-- 2 table(s) contributing at this grain.
-- Uses the stitch_incremental macro.

{%- set sources = [
    {
        'model': 'stg_partner__bjaz_pincode',
        'alias': 't0',
        'key_column': 'pincode',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'pincode', 'tgt': 'pincode'},
            {'src': 'zone1', 'tgt': 'regioncode'},
            {'src': 'state', 'tgt': 'regionname'},
            {'src': 'zone2', 'tgt': 'subzonecode'},
            {'src': 'zone', 'tgt': 'zonecode'}
        ],
        'source_tag': 'BJAZ_PINCODE'
    },
    {
        'model': 'stg_partner__bjaz_pincode_master',
        'alias': 't1',
        'key_column': 'pincode',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'pincode', 'tgt': 'pincode'},
            {'src': 'zone1', 'tgt': 'regioncode'},
            {'src': 'state', 'tgt': 'regionname'},
            {'src': 'zone2', 'tgt': 'subzonecode'},
            {'src': 'zone_pin', 'tgt': 'zonecode'}
        ],
        'source_tag': 'BJAZ_PINCODE_MASTER'
    }
] -%}

{%- set output_columns = ['pincode', 'regioncode', 'regionname', 'subzonecode', 'zonecode'] -%}

{%- set coalesce_rules = {
    'pincode':      ['t0', 't1'],
    'regioncode':   ['t0', 't1'],
    'regionname':   ['t0', 't1'],
    'subzonecode':  ['t0', 't1'],
    'zonecode':     ['t0', 't1']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='parent_bk',
    target_sat='sat_partner_common_admin_geography'
) }}
