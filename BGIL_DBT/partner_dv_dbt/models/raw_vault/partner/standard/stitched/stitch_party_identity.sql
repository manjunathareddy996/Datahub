{{ config(materialized='view') }}

-- PARTNER STANDARD-MODEL stitch view for SAT_PARTY_IDENTITY (HUB_PARTY grain).
-- 22 table(s) contributing at this grain.
-- Uses the stitch_incremental macro.

{%- set sources = [
    {
        'model': 'stg_partner__azbj_partner_extn',
        'alias': 't0',
        'key_column': 'part_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'status', 'tgt': 'partystatus'},
            {'src': 'place_of_birth', 'tgt': 'placeofbirth'}
        ],
        'source_tag': 'AZBJ_PARTNER_EXTN'
    },
    {
        'model': 'stg_partner__ba_hcp_dt_mem',
        'alias': 't1',
        'key_column': 'part_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'member_name', 'tgt': 'partyfullname'}
        ],
        'source_tag': 'BA_HCP_DT_MEM'
    },
    {
        'model': 'stg_partner__bjaz_azbj_part_ext_hist',
        'alias': 't2',
        'key_column': 'part_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'place_of_birth', 'tgt': 'placeofbirth'}
        ],
        'source_tag': 'BJAZ_AZBJ_PART_EXT_HIST'
    },
    {
        'model': 'stg_partner__bjaz_clm_supp_extn',
        'alias': 't3',
        'key_column': 'partner_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'owners_name', 'tgt': 'firstname'},
            {'src': 'owners_sur_name', 'tgt': 'lastname'},
            {'src': 'owners_middle_name', 'tgt': 'middlename'},
            {'src': 'owners_full_name', 'tgt': 'partyfullname'},
            {'src': 'mfg_co_name', 'tgt': 'partylegalname'}
        ],
        'source_tag': 'BJAZ_CLM_SUPP_EXTN'
    },
    {
        'model': 'stg_partner__bjaz_cp_part_hist',
        'alias': 't4',
        'key_column': 'part_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'date_of_birth', 'tgt': 'dateofbirth'},
            {'src': 'date_of_death', 'tgt': 'dateofdeath'},
            {'src': 'first_name', 'tgt': 'firstname'},
            {'src': 'sex', 'tgt': 'gendercode'},
            {'src': 'surname', 'tgt': 'lastname'},
            {'src': 'middle_name', 'tgt': 'middlename'},
            {'src': 'after_title', 'tgt': 'namesuffix'},
            {'src': 'nationality', 'tgt': 'nationality'},
            {'src': 'name', 'tgt': 'partyfullname'},
            {'src': 'institution_name', 'tgt': 'partylegalname'},
            {'src': 'short_name', 'tgt': 'partyshortname'},
            {'src': 'partner_type', 'tgt': 'partytypecode'},
            {'src': 'before_title', 'tgt': 'salutation'}
        ],
        'source_tag': 'BJAZ_CP_PART_HIST'
    },
    {
        'model': 'stg_partner__bjaz_ctngy_ff_dtls_extn',
        'alias': 't5',
        'key_column': 'partner_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'dob', 'tgt': 'dateofbirth'},
            {'src': 'gender', 'tgt': 'gendercode'},
            {'src': 'member_name', 'tgt': 'partyfullname'}
        ],
        'source_tag': 'BJAZ_CTNGY_FF_DTLS_EXTN'
    },
    {
        'model': 'stg_partner__bjaz_ctngy_gc_mem_data',
        'alias': 't6',
        'key_column': 'partner_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'age', 'tgt': 'age'},
            {'src': 'date_of_birth', 'tgt': 'dateofbirth'},
            {'src': 'gender', 'tgt': 'gendercode'},
            {'src': 'member_name', 'tgt': 'partyfullname'}
        ],
        'source_tag': 'BJAZ_CTNGY_GC_MEM_DATA'
    },
    {
        'model': 'stg_partner__bjaz_ctngy_pa_mem_dtls',
        'alias': 't7',
        'key_column': 'partner_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'age', 'tgt': 'age'},
            {'src': 'dob', 'tgt': 'dateofbirth'},
            {'src': 'gender', 'tgt': 'gendercode'},
            {'src': 'last_name', 'tgt': 'lastname'},
            {'src': 'middle_name', 'tgt': 'middlename'},
            {'src': 'member_name', 'tgt': 'partyfullname'}
        ],
        'source_tag': 'BJAZ_CTNGY_PA_MEM_DTLS'
    },
    {
        'model': 'stg_partner__bjaz_ec_mem_dtls_extn',
        'alias': 't8',
        'key_column': 'partner_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'age', 'tgt': 'age'},
            {'src': 'date_of_birth', 'tgt': 'dateofbirth'},
            {'src': 'gender', 'tgt': 'gendercode'},
            {'src': 'name', 'tgt': 'partyfullname'},
            {'src': 'status', 'tgt': 'partystatus'}
        ],
        'source_tag': 'BJAZ_EC_MEM_DTLS_EXTN'
    },
    {
        'model': 'stg_partner__bjaz_hcf_member_dtls',
        'alias': 't9',
        'key_column': 'partner_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'age', 'tgt': 'age'},
            {'src': 'date_of_birth', 'tgt': 'dateofbirth'},
            {'src': 'gender', 'tgt': 'gendercode'},
            {'src': 'insured_name', 'tgt': 'partyfullname'},
            {'src': 'company_name', 'tgt': 'partylegalname'}
        ],
        'source_tag': 'BJAZ_HCF_MEMBER_DTLS'
    },
    {
        'model': 'stg_partner__bjaz_hc_part_extn',
        'alias': 't10',
        'key_column': 'part_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'age', 'tgt': 'age'},
            {'src': 'date_of_birth', 'tgt': 'dateofbirth'},
            {'src': 'sex', 'tgt': 'gendercode'},
            {'src': 'member_name', 'tgt': 'partyfullname'},
            {'src': 'status', 'tgt': 'partystatus'}
        ],
        'source_tag': 'BJAZ_HC_PART_EXTN'
    },
    {
        'model': 'stg_partner__bjaz_hlt_ensure_mem_dtls',
        'alias': 't11',
        'key_column': 'partner_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'age', 'tgt': 'age'},
            {'src': 'date_of_birth', 'tgt': 'dateofbirth'},
            {'src': 'gender', 'tgt': 'gendercode'},
            {'src': 'name', 'tgt': 'partyfullname'}
        ],
        'source_tag': 'BJAZ_HLT_ENSURE_MEM_DTLS'
    },
    {
        'model': 'stg_partner__bjaz_hm_hospital_master',
        'alias': 't12',
        'key_column': 'hosid',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'benname', 'tgt': 'partydisplayname'},
            {'src': 'hospital_name', 'tgt': 'partyfullname'}
        ],
        'source_tag': 'BJAZ_HM_HOSPITAL_MASTER'
    },
    {
        'model': 'stg_partner__bjaz_hm_member_dtls',
        'alias': 't13',
        'key_column': 'partner_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'age', 'tgt': 'age'},
            {'src': 'dob', 'tgt': 'dateofbirth'},
            {'src': 'gender', 'tgt': 'gendercode'},
            {'src': 'member_name', 'tgt': 'partyfullname'}
        ],
        'source_tag': 'BJAZ_HM_MEMBER_DTLS'
    },
    {
        'model': 'stg_partner__bjaz_intermediary',
        'alias': 't14',
        'key_column': 'intermediary_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'intermediary_name', 'tgt': 'partyfullname'}
        ],
        'source_tag': 'BJAZ_INTERMEDIARY'
    },
    {
        'model': 'stg_partner__bjaz_intermediary_hist',
        'alias': 't15',
        'key_column': 'intermediary_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'intermediary_name', 'tgt': 'partyfullname'}
        ],
        'source_tag': 'BJAZ_INTERMEDIARY_HIST'
    },
    {
        'model': 'stg_partner__bjaz_pa_detl_extn',
        'alias': 't16',
        'key_column': 'partner_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'age', 'tgt': 'age'},
            {'src': 'dob', 'tgt': 'dateofbirth'},
            {'src': 'member_name', 'tgt': 'partyfullname'}
        ],
        'source_tag': 'BJAZ_PA_DETL_EXTN'
    },
    {
        'model': 'stg_partner__bjaz_sh_mem_dtls_extn',
        'alias': 't17',
        'key_column': 'partner_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'age', 'tgt': 'age'},
            {'src': 'date_of_birth', 'tgt': 'dateofbirth'},
            {'src': 'gender', 'tgt': 'gendercode'},
            {'src': 'name', 'tgt': 'partyfullname'},
            {'src': 'company_name', 'tgt': 'partylegalname'},
            {'src': 'status', 'tgt': 'partystatus'}
        ],
        'source_tag': 'BJAZ_SH_MEM_DTLS_EXTN'
    },
    {
        'model': 'stg_partner__bjaz_spp_member_dtls',
        'alias': 't18',
        'key_column': 'partner_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'age', 'tgt': 'age'},
            {'src': 'date_of_birth', 'tgt': 'dateofbirth'},
            {'src': 'gender', 'tgt': 'gendercode'},
            {'src': 'insured_name', 'tgt': 'partyfullname'},
            {'src': 'company_name', 'tgt': 'partylegalname'}
        ],
        'source_tag': 'BJAZ_SPP_MEMBER_DTLS'
    },
    {
        'model': 'stg_partner__bjaz_starpkg_ff_dtls',
        'alias': 't19',
        'key_column': 'partner_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'age', 'tgt': 'age'},
            {'src': 'dob', 'tgt': 'dateofbirth'},
            {'src': 'gender', 'tgt': 'gendercode'},
            {'src': 'member_name', 'tgt': 'partyfullname'}
        ],
        'source_tag': 'BJAZ_STARPKG_FF_DTLS'
    },
    {
        'model': 'stg_partner__cp_partners',
        'alias': 't20',
        'key_column': 'part_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'date_of_birth', 'tgt': 'dateofbirth'},
            {'src': 'date_of_death', 'tgt': 'dateofdeath'},
            {'src': 'first_name', 'tgt': 'firstname'},
            {'src': 'sex', 'tgt': 'gendercode'},
            {'src': 'surname', 'tgt': 'lastname'},
            {'src': 'middle_name', 'tgt': 'middlename'},
            {'src': 'after_title', 'tgt': 'namesuffix'},
            {'src': 'nationality', 'tgt': 'nationality'},
            {'src': 'name', 'tgt': 'partyfullname'},
            {'src': 'institution_name', 'tgt': 'partylegalname'},
            {'src': 'short_name', 'tgt': 'partyshortname'},
            {'src': 'partner_type', 'tgt': 'partytypecode'},
            {'src': 'before_title', 'tgt': 'salutation'}
        ],
        'source_tag': 'CP_PARTNERS'
    },
    {
        'model': 'stg_partner__ocp_interested_parties',
        'alias': 't21',
        'key_column': 'partner_id',
        'ldts_column': 'inc_job_updated_at',
        'columns': [
            {'src': 'customer_name_text', 'tgt': 'partyfullname'}
        ],
        'source_tag': 'OCP_INTERESTED_PARTIES'
    }
] -%}

{%- set output_columns = ['age', 'dateofbirth', 'dateofdeath', 'firstname', 'gendercode', 'lastname', 'middlename', 'namesuffix', 'nationality', 'partydisplayname', 'partyfullname', 'partylegalname', 'partyshortname', 'partystatus', 'partytypecode', 'placeofbirth', 'salutation'] -%}

{%- set coalesce_rules = {
    'age':              ['t6', 't7', 't8', 't9', 't10', 't11', 't13', 't16', 't17', 't18', 't19'],
    'dateofbirth':      ['t4', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't13', 't16', 't17', 't18', 't19', 't20'],
    'dateofdeath':      ['t4', 't20'],
    'firstname':        ['t3', 't4', 't20'],
    'gendercode':       ['t4', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't13', 't17', 't18', 't19', 't20'],
    'lastname':         ['t3', 't4', 't7', 't20'],
    'middlename':       ['t3', 't4', 't7', 't20'],
    'namesuffix':       ['t4', 't20'],
    'nationality':      ['t4', 't20'],
    'partydisplayname': ['t12'],
    'partyfullname':    ['t1', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't12', 't13', 't14', 't15', 't16', 't17', 't18', 't19', 't20', 't21'],
    'partylegalname':   ['t3', 't4', 't9', 't17', 't18', 't20'],
    'partyshortname':   ['t4', 't20'],
    'partystatus':      ['t0', 't8', 't10', 't17'],
    'partytypecode':    ['t4', 't20'],
    'placeofbirth':     ['t0', 't2'],
    'salutation':       ['t4', 't20']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='parent_bk',
    target_sat='sat_partner_party_identity'
) }}
