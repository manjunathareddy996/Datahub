{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL stitch view for SAT_COMMON_CLASSIFICATION (HUB_PARTY grain).
-- 2 table(s) contributing at this grain.
-- Uses the stitch_incremental macro.

--
 --   KEY FIX (DM-R1 item 6): BJAZ_INTERMEDIARY was keyed to HUB_PARTY on
 --   intermediary_id, but the ratified HUB_PARTY key for this table is partner_id
 --   (intermediary_id is a HUB_AGREEMENT / HUB_DISTRIBUTION_CHANNEL key). Re-keyed
 --   to partner_id so the satellite rows join a real HUB_PARTY row.
 --   Also dropped BJAZ_HM_MEMBER_DTLS: it is not a HUB_PARTY-grain producer
 --   (policy-grain / augmentation only per MAPPER_QUESTIONS_PARTNER.md), so its
 --  rows had no parent in HUB_PARTY. Its sole contribution was prioritycode,
 --   which now comes from AZBJ_PARTNER_EXTN (t0) alone.
--
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
        'model': 'stg_partner__bjaz_intermediary',
        'alias': 't3',
        'key_column': 'partner_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'flagging', 'tgt': 'segmentcode'}
        ],
        'source_tag': 'OPUS_BJAZ_INTERMEDIARY'
    }
] -%}

{%- set output_columns = ['prioritycode', 'segmentcode'] -%}

{%- set coalesce_rules = {
    'prioritycode': ['t0'],
    'segmentcode':  ['t0', 't3']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='parent_bk',
    target_sat='sat_common_classification'
) }}
