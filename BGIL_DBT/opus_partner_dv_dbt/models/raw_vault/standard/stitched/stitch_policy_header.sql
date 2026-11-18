{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL stitch view for SAT_POLICY_HEADER (HUB_POLICY grain).
-- 9 table(s) contributing at this grain.
-- Uses the stitch_incremental macro.

{%- set sources = [
    {
        'model': 'stg_partner__azbj_partner_extn',
        'alias': 't0',
        'key_column': 'existing_policy_pid',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'policy_ref', 'tgt': 'policy_reference_number'}
        ],
        'source_tag': 'OPUS_PARTNER_AZBJ_PARTNER_EXTN'
    },
    {
        'model': 'stg_partner__bjaz_ctngy_gc_mem_data',
        'alias': 't0b',
        'key_column': 'policy_ref',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'master_policy_ref', 'tgt': 'master_policy_reference'}
        ],
        'source_tag': 'OPUS_PARTNER_BJAZ_CTNGY_GC_MEM_DATA'
    },
    {
        'model': 'stg_partner__bjaz_ctngy_pa_mem_dtls',
        'alias': 't1',
        'key_column': 'contract_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'member_risk_expiry_date', 'tgt': 'risk_expiry_date'},
            {'src': 'member_risk_inception_date', 'tgt': 'risk_inception_date'}
        ],
        'source_tag': 'OPUS_PARTNER_BJAZ_CTNGY_PA_MEM_DTLS'
    },
    {
        'model': 'stg_partner__bjaz_ec_mem_dtls_extn',
        'alias': 't2',
        'key_column': 'contract_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'policy_ref', 'tgt': 'policy_reference_number'},
            {'src': 'expiry_date', 'tgt': 'risk_expiry_date'},
            {'src': 'effetive_date', 'tgt': 'risk_inception_date'}
        ],
        'source_tag': 'OPUS_PARTNER_BJAZ_EC_MEM_DTLS_EXTN'
    },
    {
        'model': 'stg_partner__bjaz_hcf_member_dtls',
        'alias': 't3',
        'key_column': 'contract_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'to_date', 'tgt': 'risk_expiry_date'},
            {'src': 'from_date', 'tgt': 'risk_inception_date'}
        ],
        'source_tag': 'OPUS_PARTNER_BJAZ_HCF_MEMBER_DTLS'
    },
    {
        'model': 'stg_partner__bjaz_hc_part_extn',
        'alias': 't4',
        'key_column': 'contract_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'inception_date', 'tgt': 'risk_inception_date'}
        ],
        'source_tag': 'OPUS_PARTNER_BJAZ_HC_PART_EXTN'
    },
    {
        'model': 'stg_partner__bjaz_hm_member_dtls',
        'alias': 't5',
        'key_column': 'contract_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'policy_ref', 'tgt': 'policy_reference_number'},
            {'src': 'term_end_date', 'tgt': 'risk_expiry_date'},
            {'src': 'term_start_date', 'tgt': 'risk_inception_date'}
        ],
        'source_tag': 'OPUS_PARTNER_BJAZ_HM_MEMBER_DTLS'
    },
    {
        'model': 'stg_partner__bjaz_pa_detl_extn',
        'alias': 't6',
        'key_column': 'contract_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'inception_date', 'tgt': 'risk_inception_date'}
        ],
        'source_tag': 'OPUS_PARTNER_BJAZ_PA_DETL_EXTN'
    },
    {
        'model': 'stg_partner__bjaz_sh_mem_dtls_extn',
        'alias': 't7',
        'key_column': 'contract_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'policy_ref', 'tgt': 'policy_reference_number'},
            {'src': 'period_of_insurance', 'tgt': 'policy_term'},
            {'src': 'expiry_date', 'tgt': 'risk_expiry_date'},
            {'src': 'effetive_date', 'tgt': 'risk_inception_date'}
        ],
        'source_tag': 'OPUS_PARTNER_BJAZ_SH_MEM_DTLS_EXTN'
    },
    {
        'model': 'stg_partner__bjaz_spp_member_dtls',
        'alias': 't8',
        'key_column': 'contract_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'to_date', 'tgt': 'risk_expiry_date'},
            {'src': 'from_date', 'tgt': 'risk_inception_date'}
        ],
        'source_tag': 'OPUS_PARTNER_BJAZ_SPP_MEMBER_DTLS'
    }
] -%}

{%- set output_columns = ['master_policy_reference', 'policy_reference_number', 'policy_term', 'risk_expiry_date', 'risk_inception_date'] -%}

{%- set coalesce_rules = {
    'master_policy_reference':  ['t0b'],
    'policy_reference_number':  ['t0', 't2', 't5', 't7'],
    'policy_term':             ['t7'],
    'risk_expiry_date':         ['t1', 't2', 't3', 't5', 't7', 't8'],
    'risk_inception_date':      ['t1', 't2', 't3', 't4', 't5', 't6', 't7', 't8']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='parent_bk',
    target_sat='sat_policy_header'
) }}
