{{ config(materialized='view') }}

-- Incremental stitch for SAT_COMMON_CLASSIFICATION (HUB_PARTY grain).
-- Original stitch_incremental structure preserved. The only change vs the base:
-- the affected_keys window is now parameterized (from_date/to_date on inc_job_updated_at)
-- instead of DATEADD(DAY,-1,CURRENT_DATE()), enabled by passing target_sat.

{%- set sources = [
    {
        'model': 'stg_partner__azbj_partner_extn',
        'alias': 't0',
        'key_column': 'part_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'vip_cust',  'tgt': 'prioritycode'},
            {'src': 'ucic_flag', 'tgt': 'segmentcode'}
        ],
        'source_tag': 'AZBJ_PARTNER_EXTN'
    },
    {
        'model': 'stg_partner__bjaz_azbj_part_ext_hist',
        'alias': 't1',
        'key_column': 'part_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'vip_cust', 'tgt': 'prioritycode'}
        ],
        'source_tag': 'BJAZ_AZBJ_PART_EXT_HIST'
    },
    {
        'model': 'stg_partner__bjaz_hm_member_dtls',
        'alias': 't2',
        'key_column': 'partner_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'vip_flg', 'tgt': 'prioritycode'}
        ],
        'source_tag': 'BJAZ_HM_MEMBER_DTLS'
    },
    {
        'model': 'stg_partner__bjaz_intermediary',
        'alias': 't3',
        'key_column': 'intermediary_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'flagging', 'tgt': 'segmentcode'}
        ],
        'source_tag': 'BJAZ_INTERMEDIARY'
    },
    {
        'model': 'stg_partner__bjaz_intermediary_hist',
        'alias': 't4',
        'key_column': 'intermediary_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'flagging', 'tgt': 'segmentcode'}
        ],
        'source_tag': 'BJAZ_INTERMEDIARY_HIST'
    }
] -%}

{%- set output_columns = ['prioritycode', 'segmentcode'] -%}

{%- set coalesce_rules = {
    'prioritycode': ['t0', 't1', 't2'],
    'segmentcode':  ['t0', 't3', 't4']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='parent_bk',
    target_sat='sat_common_classification_incr'
) }}
