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
            {'src': 'global_co_name', 'tgt': 'groupname'},
            {'src': 'industry', 'tgt': 'industrydescription'},
            {'src': 'msme_flag', 'tgt': 'msmeindicator'},
            {'src': 'paidup_capital', 'tgt': 'paidupcapital'},
            {'src': 'parent_co', 'tgt': 'parententityname'}
        ],
        'source_tag': 'OPUS_AZBJ_PARTNER_EXTN'
    },
    {
        'model': 'stg_partner__bjaz_clm_supp_extn',
        'alias': 't2',
        'key_column': 'partner_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'ann_turnover', 'tgt': 'annualturnover'},
            {'src': 'establish_year', 'tgt': 'dateofincorporation'},
            {'src': 'msme_class', 'tgt': 'msmeindicator'},
            {'src': 'parent_co_name', 'tgt': 'parententityname'}
        ],
        'source_tag': 'OPUS_BJAZ_CLM_SUPP_EXTN'
    },
    {
        'model': 'stg_partner__cp_partners',
        'alias': 't4',
        'key_column': 'part_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'legal_form', 'tgt': 'legalconstitutiontype'}
        ],
        'source_tag': 'OPUS_CP_PARTNERS'
    }
] -%}

{%- set output_columns = ['annualturnover', 'dateofincorporation', 'groupname', 'industrydescription', 'legalconstitutiontype', 'msmeindicator', 'paidupcapital', 'parententityname'] -%}

{%- set coalesce_rules = {
    'annualturnover':        ['t2'],
    'dateofincorporation':   ['t2'],
    'groupname':             ['t0'],
    'industrydescription':   ['t0'],
    'legalconstitutiontype': ['t4'],
    'msmeindicator':         ['t0', 't2'],
    'paidupcapital':         ['t0'],
    'parententityname':      ['t0', 't2']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='parent_bk',
    target_sat='sat_partner_party_organisation_profile'
) }}
