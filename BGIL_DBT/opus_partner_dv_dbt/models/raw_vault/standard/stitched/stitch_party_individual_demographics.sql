{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL stitch view for SAT_PARTY_INDIVIDUAL_DEMOGRAPHICS (HUB_PARTY grain).
-- 8 table(s) contributing at this grain.
-- Uses the stitch_incremental macro.

{%- set sources = [
    {
        'model': 'stg_partner__azbj_partner_extn',
        'alias': 't0',
        'key_column': 'part_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'family_monthly_income', 'tgt': 'annual_household_income'},
            {'src': 'education', 'tgt': 'educational_qualification'},
            {'src': 'father_name', 'tgt': 'father_name'},
            {'src': 'no_of_children', 'tgt': 'number_of_children'},
            {'src': 'occupation_desc_gen', 'tgt': 'occupation_description'},
            {'src': 'spouse_name', 'tgt': 'spouse_name'}
        ],
        'source_tag': 'OPUS_PARTNER_AZBJ_PARTNER_EXTN'
    },
    {
        'model': 'stg_partner__bjaz_ec_mem_dtls_extn',
        'alias': 't3',
        'key_column': 'partner_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'gross_income', 'tgt': 'annual_income'},
            {'src': 'occupation', 'tgt': 'occupationcode'}
        ],
        'source_tag': 'OPUS_PARTNER_BJAZ_EC_MEM_DTLS_EXTN'
    },
    {
        'model': 'stg_partner__bjaz_hcf_member_dtls',
        'alias': 't4',
        'key_column': 'partner_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'monthly_income', 'tgt': 'annual_income'},
            {'src': 'member_occupation', 'tgt': 'occupationcode'}
        ],
        'source_tag': 'OPUS_PARTNER_BJAZ_HCF_MEMBER_DTLS'
    },
    {
        'model': 'stg_partner__bjaz_hc_part_extn',
        'alias': 't5',
        'key_column': 'part_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'occupation', 'tgt': 'occupationcode'}
        ],
        'source_tag': 'OPUS_PARTNER_BJAZ_HC_PART_EXTN'
    },
    {
        'model': 'stg_partner__bjaz_hm_member_dtls',
        'alias': 't6',
        'key_column': 'partner_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'gross_income', 'tgt': 'annual_income'},
            {'src': 'designation', 'tgt': 'designation'},
            {'src': 'occupation', 'tgt': 'occupationcode'}
        ],
        'source_tag': 'OPUS_PARTNER_BJAZ_HM_MEMBER_DTLS'
    },
    {
        'model': 'stg_partner__bjaz_sh_mem_dtls_extn',
        'alias': 't7',
        'key_column': 'partner_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'gross_income', 'tgt': 'annual_income'},
            {'src': 'occupation', 'tgt': 'occupationcode'}
        ],
        'source_tag': 'OPUS_PARTNER_BJAZ_SH_MEM_DTLS_EXTN'
    },
    {
        'model': 'stg_partner__bjaz_spp_member_dtls',
        'alias': 't8',
        'key_column': 'partner_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'member_occupation', 'tgt': 'occupationcode'}
        ],
        'source_tag': 'OPUS_PARTNER_BJAZ_SPP_MEMBER_DTLS'
    },
    {
        'model': 'stg_partner__cp_partners',
        'alias': 't9',
        'key_column': 'part_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'marital_status', 'tgt': 'marital_status'},
            {'src': 'occupation', 'tgt': 'occupationcode'}
        ],
        'source_tag': 'OPUS_PARTNER_CP_PARTNERS'
    }
] -%}

{%- set output_columns = ['annual_household_income', 'annual_income', 'designation', 'educational_qualification', 'father_name', 'marital_status', 'number_of_children', 'occupationcode', 'occupation_description', 'spouse_name'] -%}

{%- set coalesce_rules = {
    'annual_household_income':    ['t0'],
    'annual_income':             ['t3', 't4', 't6', 't7'],
    'designation':              ['t6'],
    'educational_qualification': ['t0'],
    'father_name':               ['t0'],
    'marital_status':            ['t9'],
    'number_of_children':         ['t0'],
    'occupationcode':           ['t3', 't4', 't5', 't6', 't7', 't8', 't9'],
    'occupation_description':    ['t0'],
    'spouse_name':               ['t0']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='parent_bk',
    target_sat='sat_party_individual_demographics'
) }}
