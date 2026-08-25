{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL stitch view for SAT_POLICY_BONUS_TRACKING (HUB_POLICY grain).
-- 7 table(s) contributing at this grain.
-- Uses the stitch_incremental macro.

{%- set sources = [
    {
        'model': 'stg_partner__bjaz_ec_mem_dtls_extn',
        'alias': 't0',
        'key_column': 'contract_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'pre_pol_ncb_per', 'tgt': 'cumulativebonuspercentage'}
        ],
        'source_tag': 'BJAZ_EC_MEM_DTLS_EXTN'
    },
    {
        'model': 'stg_partner__bjaz_hcf_member_dtls',
        'alias': 't1',
        'key_column': 'contract_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'cumulative_amt', 'tgt': 'bonusamount'},
            {'src': 'cumulative_bnouz_per', 'tgt': 'cumulativebonuspercentage'}
        ],
        'source_tag': 'BJAZ_HCF_MEMBER_DTLS'
    },
    {
        'model': 'stg_partner__bjaz_hlt_ensure_mem_dtls',
        'alias': 't2',
        'key_column': 'contract_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'previous_cum_bonus', 'tgt': 'bonusamount'}
        ],
        'source_tag': 'BJAZ_HLT_ENSURE_MEM_DTLS'
    },
    {
        'model': 'stg_partner__bjaz_hm_member_dtls',
        'alias': 't3',
        'key_column': 'contract_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'bonus_si', 'tgt': 'bonusamount'},
            {'src': 'cumm_bonus_per', 'tgt': 'cumulativebonuspercentage'}
        ],
        'source_tag': 'BJAZ_HM_MEMBER_DTLS'
    },
    {
        'model': 'stg_partner__bjaz_pa_detl_extn',
        'alias': 't4',
        'key_column': 'contract_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'cummulative_bonus', 'tgt': 'bonusamount'}
        ],
        'source_tag': 'BJAZ_PA_DETL_EXTN'
    },
    {
        'model': 'stg_partner__bjaz_sh_mem_dtls_extn',
        'alias': 't5',
        'key_column': 'contract_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'cumm_bonus', 'tgt': 'bonusamount'},
            {'src': 'cumm_bonus_per', 'tgt': 'cumulativebonuspercentage'}
        ],
        'source_tag': 'BJAZ_SH_MEM_DTLS_EXTN'
    },
    {
        'model': 'stg_partner__bjaz_spp_member_dtls',
        'alias': 't6',
        'key_column': 'contract_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'cumulative_amt', 'tgt': 'bonusamount'},
            {'src': 'cumulative_bnouz_per', 'tgt': 'cumulativebonuspercentage'}
        ],
        'source_tag': 'BJAZ_SPP_MEMBER_DTLS'
    }
] -%}

{%- set output_columns = ['bonusamount', 'cumulativebonuspercentage'] -%}

{%- set coalesce_rules = {
    'bonusamount':               ['t1', 't2', 't3', 't4', 't5', 't6'],
    'cumulativebonuspercentage': ['t0', 't1', 't3', 't5', 't6']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='parent_bk',
    target_sat='sat_policy_bonus_tracking'
) }}
