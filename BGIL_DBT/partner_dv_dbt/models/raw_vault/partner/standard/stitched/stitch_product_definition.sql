{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL stitch view for SAT_PRODUCT_DEFINITION (HUB_PRODUCT grain).
-- 3 table(s) contributing at this grain.
-- Uses the stitch_incremental macro.

{%- set sources = [
    {
        'model': 'stg_partner__bjaz_ctngy_ff_dtls_extn',
        'alias': 't0',
        'key_column': 'scheme_code',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'section_code', 'tgt': 'productcategory'},
            {'src': 'scheme_version', 'tgt': 'productgeneration'}
        ],
        'source_tag': 'BJAZ_CTNGY_FF_DTLS_EXTN'
    },
    {
        'model': 'stg_partner__bjaz_ctngy_pa_mem_dtls',
        'alias': 't1',
        'key_column': 'scheme_code',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'section_code', 'tgt': 'productcategory'},
            {'src': 'scheme_version', 'tgt': 'productgeneration'},
            {'src': 'plan', 'tgt': 'productname'}
        ],
        'source_tag': 'BJAZ_CTNGY_PA_MEM_DTLS'
    },
    {
        'model': 'stg_partner__bjaz_hm_member_dtls',
        'alias': 't2',
        'key_column': 'product_code',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'plan_name', 'tgt': 'productname'}
        ],
        'source_tag': 'BJAZ_HM_MEMBER_DTLS'
    }
] -%}

{%- set output_columns = ['productcategory', 'productgeneration', 'productname'] -%}

{%- set coalesce_rules = {
    'productcategory':   ['t0', 't1'],
    'productgeneration': ['t0', 't1'],
    'productname':       ['t1', 't2']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='parent_bk',
    target_sat='sat_partner_product_definition'
) }}
