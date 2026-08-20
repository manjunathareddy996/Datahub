{{ config(materialized='view') }}

-- DEMO: Stitch view for SAT_A_B_STITCHED (grain: id / HUB_PARTY).
-- Uses stitch_incremental macro (same as stitch_common_classification_incr).
-- COALESCE priority: TABLE_A wins for phone_1, TABLE_B is sole source for phone_2.

{%- set sources = [
    {
        'model': 'stg_a',
        'alias': 't0',
        'key_column': 'id',
        'ldts_column': 'updated_at',
        'columns': [
            {'src': 'phone_1', 'tgt': 'phone_1'}
        ],
        'source_tag': 'TABLE_A'
    },
    {
        'model': 'stg_b',
        'alias': 't1',
        'key_column': 'id',
        'ldts_column': 'updated_at',
        'columns': [
            {'src': 'phone_1', 'tgt': 'phone_1'},
            {'src': 'phone_2', 'tgt': 'phone_2'}
        ],
        'source_tag': 'TABLE_B'
    }
] -%}

{%- set output_columns = ['phone_1', 'phone_2'] -%}

{%- set coalesce_rules = {
    'phone_1': ['t0', 't1'],
    'phone_2': ['t1']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='parent_bk',
    target_sat='sat_a_b_stitched'
) }}
