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
            {'src': 'pincode', 'tgt': 'pin_code'},
            {'src': 'zone1', 'tgt': 'regioncode'},
            {'src': 'state', 'tgt': 'region_name'},
            {'src': 'zone2', 'tgt': 'subzonecode'},
            {'src': 'zone', 'tgt': 'zone_code'}
        ],
        'source_tag': 'OPUS_PARTNER_BJAZ_PINCODE'
    },
    {
        'model': 'stg_partner__bjaz_pincode_master',
        'alias': 't1',
        'key_column': 'pincode',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'pincode', 'tgt': 'pin_code'},
            {'src': 'zone1', 'tgt': 'regioncode'},
            {'src': 'state', 'tgt': 'region_name'},
            {'src': 'zone2', 'tgt': 'subzonecode'},
            {'src': 'zone_pin', 'tgt': 'zone_code'}
        ],
        'source_tag': 'OPUS_PARTNER_BJAZ_PINCODE_MASTER'
    }
] -%}

{%- set output_columns = ['pin_code', 'regioncode', 'region_name', 'subzonecode', 'zone_code'] -%}

{%- set coalesce_rules = {
    'pin_code':      ['t0', 't1'],
    'regioncode':   ['t0', 't1'],
    'region_name':   ['t0', 't1'],
    'subzonecode':  ['t0', 't1'],
    'zone_code':     ['t0', 't1']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='parent_bk',
    target_sat='sat_common_admin_geography'
) }}
