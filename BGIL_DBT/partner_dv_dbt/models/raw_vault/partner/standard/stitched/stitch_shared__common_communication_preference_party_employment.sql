{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL stitch view for SAT_COMMON_COMMUNICATION_PREFERENCE, SAT_PARTY_EMPLOYMENT (HUB_PARTY grain).
-- 2 table(s) contributing at this grain.
-- Uses the stitch_incremental macro.

{%- set sources = [
    {
        'model': 'stg_partner__bjaz_cp_part_hist',
        'alias': 't0',
        'key_column': 'part_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'language', 'tgt': 'correspondencelanguage'},
            {'src': 'literature', 'tgt': 'marketingoptinindicator'}
        ],
        'source_tag': 'BJAZ_CP_PART_HIST'
    },
    {
        'model': 'stg_partner__cp_partners',
        'alias': 't1',
        'key_column': 'part_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'language', 'tgt': 'correspondencelanguage'},
            {'src': 'literature', 'tgt': 'marketingoptinindicator'}
        ],
        'source_tag': 'CP_PARTNERS'
    }
] -%}

{%- set output_columns = ['correspondencelanguage', 'marketingoptinindicator', 'employmentstatus'] -%}

{%- set coalesce_rules = {
    'correspondencelanguage':  ['t0', 't1'],
    'marketingoptinindicator': ['t0', 't1'],
    'employmentstatus':        ['t0']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='parent_bk',
    target_sat='sat_partner_common_communication_preference'
) }}
