{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL stitch view for SAT_PARTY_CLAIM_HISTORY (HUB_PARTY grain).
-- 6 table(s) contributing at this grain.
-- Uses the stitch_incremental macro.

{%- set sources = [
    {
        'model': 'stg_partner__bjaz_ec_mem_dtls_extn',
        'alias': 't0',
        'key_column': 'partner_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'claim_received', 'tgt': 'totalclaimcount'}
        ],
        'source_tag': 'BJAZ_EC_MEM_DTLS_EXTN'
    },
    {
        'model': 'stg_partner__bjaz_hcf_member_dtls',
        'alias': 't1',
        'key_column': 'partner_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'claim_dtls', 'tgt': 'totalclaimcount'}
        ],
        'source_tag': 'BJAZ_HCF_MEMBER_DTLS'
    },
    {
        'model': 'stg_partner__bjaz_hc_part_extn',
        'alias': 't2',
        'key_column': 'part_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'amount_claimed', 'tgt': 'totalclaimamount'},
            {'src': 'claim_history', 'tgt': 'totalclaimcount'}
        ],
        'source_tag': 'BJAZ_HC_PART_EXTN'
    },
    {
        'model': 'stg_partner__bjaz_hm_member_dtls',
        'alias': 't3',
        'key_column': 'partner_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'claim_count', 'tgt': 'totalclaimcount'}
        ],
        'source_tag': 'BJAZ_HM_MEMBER_DTLS'
    },
    {
        'model': 'stg_partner__bjaz_sh_mem_dtls_extn',
        'alias': 't4',
        'key_column': 'partner_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'amount_claimed', 'tgt': 'totalclaimamount'},
            {'src': 'claim_history', 'tgt': 'totalclaimcount'}
        ],
        'source_tag': 'BJAZ_SH_MEM_DTLS_EXTN'
    },
    {
        'model': 'stg_partner__bjaz_spp_member_dtls',
        'alias': 't5',
        'key_column': 'partner_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'claim_dtls', 'tgt': 'totalclaimcount'}
        ],
        'source_tag': 'BJAZ_SPP_MEMBER_DTLS'
    }
] -%}

{%- set output_columns = ['totalclaimamount', 'totalclaimcount'] -%}

{%- set coalesce_rules = {
    'totalclaimamount': ['t2', 't4'],
    'totalclaimcount':  ['t0', 't1', 't2', 't3', 't4', 't5']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='parent_bk',
    target_sat='sat_partner_party_claim_history'
) }}
