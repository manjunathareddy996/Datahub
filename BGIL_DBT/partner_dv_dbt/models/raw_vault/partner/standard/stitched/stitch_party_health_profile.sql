{{ config(materialized='view') }}

-- Incremental stitch for SAT_PARTY_HEALTH_PROFILE (HUB_PARTY grain).
-- 4 sources contributing at this grain via the stitch_incremental macro.

{%- set sources = [
    {
        'model': 'stg_partner__bjaz_ec_mem_dtls_extn',
        'alias': 't0',
        'key_column': 'partner_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'height_cm', 'tgt': 'height'},
            {'src': 'pregnant_yn', 'tgt': 'maternitystatus'},
            {'src': 'smoker_yn', 'tgt': 'smokerindicator'},
            {'src': 'weight_kg', 'tgt': 'weight'}
        ],
        'source_tag': 'BJAZ_EC_MEM_DTLS_EXTN'
    },
    {
        'model': 'stg_partner__bjaz_hcf_member_dtls',
        'alias': 't1',
        'key_column': 'partner_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'obesity_flag', 'tgt': 'bodymassindex'},
            {'src': 'height_flag', 'tgt': 'height'},
            {'src': 'smoker_flag', 'tgt': 'smokerindicator'},
            {'src': 'weight_flag', 'tgt': 'weight'}
        ],
        'source_tag': 'BJAZ_HCF_MEMBER_DTLS'
    },
    {
        'model': 'stg_partner__bjaz_sh_mem_dtls_extn',
        'alias': 't2',
        'key_column': 'partner_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'smoker_yn', 'tgt': 'smokerindicator'}
        ],
        'source_tag': 'BJAZ_SH_MEM_DTLS_EXTN'
    },
    {
        'model': 'stg_partner__bjaz_spp_member_dtls',
        'alias': 't3',
        'key_column': 'partner_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'obesity', 'tgt': 'bodymassindex'},
            {'src': 'weight', 'tgt': 'weight'}
        ],
        'source_tag': 'BJAZ_SPP_MEMBER_DTLS'
    }
] -%}

{%- set output_columns = ['bodymassindex', 'height', 'maternitystatus', 'smokerindicator', 'weight'] -%}

{%- set coalesce_rules = {
    'bodymassindex': ['t1', 't3'],
    'height': ['t0', 't1'],
    'maternitystatus': ['t0'],
    'smokerindicator': ['t0', 't1', 't2'],
    'weight': ['t0', 't1', 't3']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='parent_bk',
    target_sat='sat_party_health_profile'
) }}
