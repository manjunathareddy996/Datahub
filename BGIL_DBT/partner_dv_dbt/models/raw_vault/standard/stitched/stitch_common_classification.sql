{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL stitch view for SAT_COMMON_CLASSIFICATION (HUB_PARTY grain).
-- 3 table(s) contributing at this grain.
-- Uses the stitch_incremental macro.

{%- set sources = [
    {
        'model': 'stg_partner__azbj_partner_extn',
        'alias': 't0',
        'key_column': 'part_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'vip_cust', 'tgt': 'prioritycode'},
            {'src': 'ucic_flag', 'tgt': 'segmentcode'}
        ],
        'source_tag': 'OPUS_AZBJ_PARTNER_EXTN'
    },
    {
        'model': 'stg_partner__bjaz_hm_member_dtls',
        'alias': 't2',
        'key_column': 'partner_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'vip_flg', 'tgt': 'prioritycode'}
        ],
        'source_tag': 'OPUS_BJAZ_HM_MEMBER_DTLS'
    },
    {
        'model': 'stg_partner__bjaz_intermediary',
        'alias': 't3',
        'key_column': 'intermediary_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'flagging', 'tgt': 'segmentcode'}
        ],
        'source_tag': 'OPUS_BJAZ_INTERMEDIARY'
    }
] -%}

{%- set output_columns = ['prioritycode', 'segmentcode'] -%}

{%- set coalesce_rules = {
    'prioritycode': ['t0', 't2'],
    'segmentcode':  ['t0', 't3']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='parent_bk',
    target_sat='sat_partner_common_classification'
) }}
