{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL stitch view for SAT_PARTY_ORGANISATION_PROFILE (HUB_PARTY grain).
-- 3 table(s) contributing at this grain.
-- Uses the stitch_incremental macro.

{%- set sources = [
    {
        'model': 'stg_partner__azbj_partner_extn',
        'alias': 't0',
        'key_column': 'part_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'global_co_name', 'tgt': 'group_name'},
            {'src': 'industry', 'tgt': 'industry_description'},
            {'src': 'msme_flag', 'tgt': 'msme_indicator'},
            {'src': 'paidup_capital', 'tgt': 'paid_up_capital'},
            {'src': 'parent_co', 'tgt': 'parent_entity_name'}
        ],
        'source_tag': 'OPUS_PARTNER_AZBJ_PARTNER_EXTN'
    },
    {
        'model': 'stg_partner__bjaz_clm_supp_extn',
        'alias': 't2',
        'key_column': 'partner_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'ann_turnover', 'tgt': 'annual_turnover'},
            {'src': 'establish_year', 'tgt': 'date_of_incorporation'},
            {'src': 'msme_class', 'tgt': 'msme_indicator'},
            {'src': 'parent_co_name', 'tgt': 'parent_entity_name'}
        ],
        'source_tag': 'OPUS_PARTNER_BJAZ_CLM_SUPP_EXTN'
    },
    {
        'model': 'stg_partner__cp_partners',
        'alias': 't4',
        'key_column': 'part_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'legal_form', 'tgt': 'legal_constitution_type'}
        ],
        'source_tag': 'OPUS_PARTNER_CP_PARTNERS'
    }
] -%}

{%- set output_columns = ['annual_turnover', 'date_of_incorporation', 'group_name', 'industry_description', 'legal_constitution_type', 'msme_indicator', 'paid_up_capital', 'parent_entity_name'] -%}

{%- set coalesce_rules = {
    'annual_turnover':        ['t2'],
    'date_of_incorporation':   ['t2'],
    'group_name':             ['t0'],
    'industry_description':   ['t0'],
    'legal_constitution_type': ['t4'],
    'msme_indicator':         ['t0', 't2'],
    'paid_up_capital':         ['t0'],
    'parent_entity_name':      ['t0', 't2']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='parent_bk',
    target_sat='sat_party_organisation_profile'
) }}
