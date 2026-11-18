{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL stitch view for SAT_PARTY_IDENTITY (HUB_PARTY grain).
-- 19 table(s) contributing at this grain.
-- (Removed hist tables BJAZ_CP_PART_HIST, BJAZ_AZBJ_PART_EXT_HIST, BJAZ_INTERMEDIARY_HIST --
--  each was redundant with its current counterpart: CP_PARTNERS, AZBJ_PARTNER_EXTN, BJAZ_INTERMEDIARY.)
-- Uses the stitch_incremental macro.

{%- set sources = [
    {
        'model': 'stg_partner__azbj_partner_extn',
        'alias': 't0',
        'key_column': 'part_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'status', 'tgt': 'party_status'},
            {'src': 'place_of_birth', 'tgt': 'placeofbirth'}
        ],
        'source_tag': 'OPUS_PARTNER_AZBJ_PARTNER_EXTN'
    },
    {
        'model': 'stg_partner__ba_hcp_dt_mem',
        'alias': 't1',
        'key_column': 'part_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'member_name', 'tgt': 'party_full_name'}
        ],
        'source_tag': 'OPUS_PARTNER_BA_HCP_DT_MEM'
    },
    {
        'model': 'stg_partner__bjaz_clm_supp_extn',
        'alias': 't3',
        'key_column': 'partner_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'owners_name', 'tgt': 'first_name'},
            {'src': 'owners_sur_name', 'tgt': 'last_name'},
            {'src': 'owners_middle_name', 'tgt': 'middle_name'},
            {'src': 'owners_full_name', 'tgt': 'party_full_name'},
            {'src': 'mfg_co_name', 'tgt': 'party_legal_name'}
        ],
        'source_tag': 'OPUS_PARTNER_BJAZ_CLM_SUPP_EXTN'
    },
    {
        'model': 'stg_partner__bjaz_ctngy_ff_dtls_extn',
        'alias': 't5',
        'key_column': 'partner_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'dob', 'tgt': 'date_of_birth'},
            {'src': 'gender', 'tgt': 'gender_code'},
            {'src': 'member_name', 'tgt': 'party_full_name'}
        ],
        'source_tag': 'OPUS_PARTNER_BJAZ_CTNGY_FF_DTLS_EXTN'
    },
    {
        'model': 'stg_partner__bjaz_ctngy_gc_mem_data',
        'alias': 't6',
        'key_column': 'partner_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'age', 'tgt': 'age'},
            {'src': 'date_of_birth', 'tgt': 'date_of_birth'},
            {'src': 'gender', 'tgt': 'gender_code'},
            {'src': 'member_name', 'tgt': 'party_full_name'}
        ],
        'source_tag': 'OPUS_PARTNER_BJAZ_CTNGY_GC_MEM_DATA'
    },
    {
        'model': 'stg_partner__bjaz_ctngy_pa_mem_dtls',
        'alias': 't7',
        'key_column': 'partner_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'age', 'tgt': 'age'},
            {'src': 'dob', 'tgt': 'date_of_birth'},
            {'src': 'gender', 'tgt': 'gender_code'},
            {'src': 'last_name', 'tgt': 'last_name'},
            {'src': 'middle_name', 'tgt': 'middle_name'},
            {'src': 'member_name', 'tgt': 'party_full_name'}
        ],
        'source_tag': 'OPUS_PARTNER_BJAZ_CTNGY_PA_MEM_DTLS'
    },
    {
        'model': 'stg_partner__bjaz_ec_mem_dtls_extn',
        'alias': 't8',
        'key_column': 'partner_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'age', 'tgt': 'age'},
            {'src': 'date_of_birth', 'tgt': 'date_of_birth'},
            {'src': 'gender', 'tgt': 'gender_code'},
            {'src': 'name', 'tgt': 'party_full_name'},
            {'src': 'status', 'tgt': 'party_status'}
        ],
        'source_tag': 'OPUS_PARTNER_BJAZ_EC_MEM_DTLS_EXTN'
    },
    {
        'model': 'stg_partner__bjaz_hcf_member_dtls',
        'alias': 't9',
        'key_column': 'partner_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'age', 'tgt': 'age'},
            {'src': 'date_of_birth', 'tgt': 'date_of_birth'},
            {'src': 'gender', 'tgt': 'gender_code'},
            {'src': 'insured_name', 'tgt': 'party_full_name'},
            {'src': 'company_name', 'tgt': 'party_legal_name'}
        ],
        'source_tag': 'OPUS_PARTNER_BJAZ_HCF_MEMBER_DTLS'
    },
    {
        'model': 'stg_partner__bjaz_hc_part_extn',
        'alias': 't10',
        'key_column': 'part_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'age', 'tgt': 'age'},
            {'src': 'date_of_birth', 'tgt': 'date_of_birth'},
            {'src': 'sex', 'tgt': 'gender_code'},
            {'src': 'member_name', 'tgt': 'party_full_name'},
            {'src': 'status', 'tgt': 'party_status'}
        ],
        'source_tag': 'OPUS_PARTNER_BJAZ_HC_PART_EXTN'
    },
    {
        'model': 'stg_partner__bjaz_hlt_ensure_mem_dtls',
        'alias': 't11',
        'key_column': 'partner_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'age', 'tgt': 'age'},
            {'src': 'date_of_birth', 'tgt': 'date_of_birth'},
            {'src': 'gender', 'tgt': 'gender_code'},
            {'src': 'name', 'tgt': 'party_full_name'}
        ],
        'source_tag': 'OPUS_PARTNER_BJAZ_HLT_ENSURE_MEM_DTLS'
    },
    {
        'model': 'stg_partner__bjaz_hm_hospital_master',
        'alias': 't12',
        'key_column': 'hosid',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'benname', 'tgt': 'party_display_name'},
            {'src': 'hospital_name', 'tgt': 'party_full_name'}
        ],
        'source_tag': 'OPUS_PARTNER_BJAZ_HM_HOSPITAL_MASTER'
    },
    {
        'model': 'stg_partner__bjaz_hm_member_dtls',
        'alias': 't13',
        'key_column': 'partner_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'age', 'tgt': 'age'},
            {'src': 'dob', 'tgt': 'date_of_birth'},
            {'src': 'gender', 'tgt': 'gender_code'},
            {'src': 'member_name', 'tgt': 'party_full_name'}
        ],
        'source_tag': 'OPUS_PARTNER_BJAZ_HM_MEMBER_DTLS'
    },
    {
        'model': 'stg_partner__bjaz_intermediary',
        'alias': 't14',
        'key_column': 'intermediary_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'intermediary_name', 'tgt': 'party_full_name'}
        ],
        'source_tag': 'OPUS_PARTNER_BJAZ_INTERMEDIARY'
    },
    {
        'model': 'stg_partner__bjaz_pa_detl_extn',
        'alias': 't16',
        'key_column': 'partner_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'age', 'tgt': 'age'},
            {'src': 'dob', 'tgt': 'date_of_birth'},
            {'src': 'member_name', 'tgt': 'party_full_name'}
        ],
        'source_tag': 'OPUS_PARTNER_BJAZ_PA_DETL_EXTN'
    },
    {
        'model': 'stg_partner__bjaz_sh_mem_dtls_extn',
        'alias': 't17',
        'key_column': 'partner_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'age', 'tgt': 'age'},
            {'src': 'date_of_birth', 'tgt': 'date_of_birth'},
            {'src': 'gender', 'tgt': 'gender_code'},
            {'src': 'name', 'tgt': 'party_full_name'},
            {'src': 'company_name', 'tgt': 'party_legal_name'},
            {'src': 'status', 'tgt': 'party_status'}
        ],
        'source_tag': 'OPUS_PARTNER_BJAZ_SH_MEM_DTLS_EXTN'
    },
    {
        'model': 'stg_partner__bjaz_spp_member_dtls',
        'alias': 't18',
        'key_column': 'partner_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'age', 'tgt': 'age'},
            {'src': 'date_of_birth', 'tgt': 'date_of_birth'},
            {'src': 'gender', 'tgt': 'gender_code'},
            {'src': 'insured_name', 'tgt': 'party_full_name'},
            {'src': 'company_name', 'tgt': 'party_legal_name'}
        ],
        'source_tag': 'OPUS_PARTNER_BJAZ_SPP_MEMBER_DTLS'
    },
    {
        'model': 'stg_partner__bjaz_starpkg_ff_dtls',
        'alias': 't19',
        'key_column': 'partner_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'age', 'tgt': 'age'},
            {'src': 'dob', 'tgt': 'date_of_birth'},
            {'src': 'gender', 'tgt': 'gender_code'},
            {'src': 'member_name', 'tgt': 'party_full_name'}
        ],
        'source_tag': 'OPUS_PARTNER_BJAZ_STARPKG_FF_DTLS'
    },
    {
        'model': 'stg_partner__cp_partners',
        'alias': 't20',
        'key_column': 'part_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'date_of_birth', 'tgt': 'date_of_birth'},
            {'src': 'date_of_death', 'tgt': 'date_of_death'},
            {'src': 'first_name', 'tgt': 'first_name'},
            {'src': 'sex', 'tgt': 'gender_code'},
            {'src': 'surname', 'tgt': 'last_name'},
            {'src': 'middle_name', 'tgt': 'middle_name'},
            {'src': 'after_title', 'tgt': 'name_suffix'},
            {'src': 'nationality', 'tgt': 'nationality'},
            {'src': 'name', 'tgt': 'party_full_name'},
            {'src': 'institution_name', 'tgt': 'party_legal_name'},
            {'src': 'short_name', 'tgt': 'partyshortname'},
            {'src': 'partner_type', 'tgt': 'party_type_code'},
            {'src': 'before_title', 'tgt': 'salutation'}
        ],
        'source_tag': 'OPUS_PARTNER_CP_PARTNERS'
    },
    {
        'model': 'stg_partner__ocp_interested_parties',
        'alias': 't21',
        'key_column': 'partner_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'customer_name_text', 'tgt': 'party_full_name'}
        ],
        'source_tag': 'OPUS_PARTNER_OCP_INTERESTED_PARTIES'
    }
] -%}

{%- set output_columns = ['age', 'date_of_birth', 'date_of_death', 'first_name', 'gender_code', 'last_name', 'middle_name', 'name_suffix', 'nationality', 'party_display_name', 'party_full_name', 'party_legal_name', 'partyshortname', 'party_status', 'party_type_code', 'placeofbirth', 'salutation'] -%}

{%- set coalesce_rules = {
    'age':              ['t6', 't7', 't8', 't9', 't10', 't11', 't13', 't16', 't17', 't18', 't19'],
    'date_of_birth':      ['t5', 't6', 't7', 't8', 't9', 't10', 't11', 't13', 't16', 't17', 't18', 't19', 't20'],
    'date_of_death':      ['t20'],
    'first_name':        ['t3', 't20'],
    'gender_code':       ['t5', 't6', 't7', 't8', 't9', 't10', 't11', 't13', 't17', 't18', 't19', 't20'],
    'last_name':         ['t3', 't7', 't20'],
    'middle_name':       ['t3', 't7', 't20'],
    'name_suffix':       ['t20'],
    'nationality':      ['t20'],
    'party_display_name': ['t12'],
    'party_full_name':    ['t1', 't3', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't12', 't13', 't14', 't16', 't17', 't18', 't19', 't20', 't21'],
    'party_legal_name':   ['t3', 't9', 't17', 't18', 't20'],
    'partyshortname':   ['t20'],
    'party_status':      ['t0', 't8', 't10', 't17'],
    'party_type_code':    ['t20'],
    'placeofbirth':     ['t0'],
    'salutation':       ['t20']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='parent_bk',
    target_sat='sat_party_identity'
) }}
