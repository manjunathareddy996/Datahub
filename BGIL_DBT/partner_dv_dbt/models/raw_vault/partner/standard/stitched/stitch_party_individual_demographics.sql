{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL stitch view for SAT_PARTY_INDIVIDUAL_DEMOGRAPHICS (HUB_PARTY grain).
-- 10 table(s) contributing at this grain.
-- Uses the stitch_incremental macro.

{%- set sources = [
    {
        'model': 'stg_partner__azbj_partner_extn',
        'alias': 't0',
        'key_column': 'part_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'family_monthly_income', 'tgt': 'annualhouseholdincome'},
            {'src': 'education', 'tgt': 'educationalqualification'},
            {'src': 'father_name', 'tgt': 'fathername'},
            {'src': 'no_of_children', 'tgt': 'numberofchildren'},
            {'src': 'occupation_desc_gen', 'tgt': 'occupationdescription'},
            {'src': 'spouse_name', 'tgt': 'spousename'}
        ],
        'source_tag': 'AZBJ_PARTNER_EXTN'
    },
    {
        'model': 'stg_partner__bjaz_azbj_part_ext_hist',
        'alias': 't1',
        'key_column': 'part_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'education', 'tgt': 'educationalqualification'},
            {'src': 'father_name', 'tgt': 'fathername'},
            {'src': 'occupation_desc_gen', 'tgt': 'occupationdescription'}
        ],
        'source_tag': 'BJAZ_AZBJ_PART_EXT_HIST'
    },
    {
        'model': 'stg_partner__bjaz_cp_part_hist',
        'alias': 't2',
        'key_column': 'part_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'marital_status', 'tgt': 'maritalstatus'},
            {'src': 'occupation', 'tgt': 'occupationcode'}
        ],
        'source_tag': 'BJAZ_CP_PART_HIST'
    },
    {
        'model': 'stg_partner__bjaz_ec_mem_dtls_extn',
        'alias': 't3',
        'key_column': 'partner_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'gross_income', 'tgt': 'annualincome'},
            {'src': 'occupation', 'tgt': 'occupationcode'}
        ],
        'source_tag': 'BJAZ_EC_MEM_DTLS_EXTN'
    },
    {
        'model': 'stg_partner__bjaz_hcf_member_dtls',
        'alias': 't4',
        'key_column': 'partner_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'monthly_income', 'tgt': 'annualincome'},
            {'src': 'member_occupation', 'tgt': 'occupationcode'}
        ],
        'source_tag': 'BJAZ_HCF_MEMBER_DTLS'
    },
    {
        'model': 'stg_partner__bjaz_hc_part_extn',
        'alias': 't5',
        'key_column': 'part_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'occupation', 'tgt': 'occupationcode'}
        ],
        'source_tag': 'BJAZ_HC_PART_EXTN'
    },
    {
        'model': 'stg_partner__bjaz_hm_member_dtls',
        'alias': 't6',
        'key_column': 'partner_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'gross_income', 'tgt': 'annualincome'},
            {'src': 'designation', 'tgt': 'designation'},
            {'src': 'occupation', 'tgt': 'occupationcode'}
        ],
        'source_tag': 'BJAZ_HM_MEMBER_DTLS'
    },
    {
        'model': 'stg_partner__bjaz_sh_mem_dtls_extn',
        'alias': 't7',
        'key_column': 'partner_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'gross_income', 'tgt': 'annualincome'},
            {'src': 'occupation', 'tgt': 'occupationcode'}
        ],
        'source_tag': 'BJAZ_SH_MEM_DTLS_EXTN'
    },
    {
        'model': 'stg_partner__bjaz_spp_member_dtls',
        'alias': 't8',
        'key_column': 'partner_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'member_occupation', 'tgt': 'occupationcode'}
        ],
        'source_tag': 'BJAZ_SPP_MEMBER_DTLS'
    },
    {
        'model': 'stg_partner__cp_partners',
        'alias': 't9',
        'key_column': 'part_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'marital_status', 'tgt': 'maritalstatus'},
            {'src': 'occupation', 'tgt': 'occupationcode'}
        ],
        'source_tag': 'CP_PARTNERS'
    }
] -%}

{%- set output_columns = ['annualhouseholdincome', 'annualincome', 'designation', 'educationalqualification', 'fathername', 'maritalstatus', 'numberofchildren', 'occupationcode', 'occupationdescription', 'spousename'] -%}

{%- set coalesce_rules = {
    'annualhouseholdincome':    ['t0'],
    'annualincome':             ['t3', 't4', 't6', 't7'],
    'designation':              ['t6'],
    'educationalqualification': ['t0', 't1'],
    'fathername':               ['t0', 't1'],
    'maritalstatus':            ['t2', 't9'],
    'numberofchildren':         ['t0'],
    'occupationcode':           ['t2', 't3', 't4', 't5', 't6', 't7', 't8', 't9'],
    'occupationdescription':    ['t0', 't1'],
    'spousename':               ['t0']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='parent_bk',
    target_sat='sat_partner_party_individual_demographics'
) }}
