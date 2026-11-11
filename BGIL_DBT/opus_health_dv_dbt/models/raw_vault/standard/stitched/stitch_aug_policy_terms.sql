{{ config(materialized='view') }}
-- This part feeds SAT_AUG_POLICY_TERMS only. Original precedence comments are kept below (from stitch_v28_policy).
-- CENTRAL VIEW v28_policy -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_CTNGY_GC_CONTROL (opus_health_v2)
--   BJAZ_ENROLL_POL_DTLS (opus_health_v2)
--   BJAZ_ECARD_POL_DTLS_CONFIG (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_CUST_DTLS (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_DTLS (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_MATERNITY_DTLS (opus_health_legacy_v4)
--   BJAZ_HCF_MEMBER_DTLS (opus_health_legacy_v4)
--   BJAZ_GMC_BASES_EXTN (opus_health_delta3)
--   BJAZ_GRP_HLT_COVERAGE_DTLS (opus_health_delta3)
--   BJAZ_STARPKG_POL_DTLS (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_POLICY_TERMS
--   SAT_POLICY_EXCESS_STRUCTURE
--   SAT_POLICY_SUM_INSURED_BREAKUP
--   SAT_PROPOSAL_HEADER
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_FINTXN_POLICY
--   LNK_PARTY_CHANNEL
--   LNK_POLICY_CHANNEL
--   LNK_POLICY_ORG_UNIT
--   LNK_POLICY_PARTY
--   LNK_POLICY_PRODUCT
--   LNK_POLICY_RISK_OBJECT
--   LNK_PROPOSAL_ASSESSMENT
--   LNK_PROPOSAL_POLICY
--   LNK_PROPOSAL_PRODUCT
--   LNK_QUOTE_PRODUCT
--   LNK_QUOTE_PROPOSAL
--   LNK_RISK_OBJECT_PARTY
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_ctngy_gc_control') }}
-- depends_on: {{ ref('stg_health__bjaz_enroll_pol_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_ecard_pol_dtls_config') }}
-- depends_on: {{ ref('stg_health__bjaz_grp_hlt_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_grp_hlt_maternity_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hcf_member_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_gmc_bases_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_grp_hlt_coverage_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_starpkg_pol_dtls') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_ctngy_gc_control',
      'alias': 't0',
      'key_column': "nullif(trim(policy_ref),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_CTNGY_GC_CONTROL',
      'columns': [
        {'src': 'backdate', 'tgt': 'aug_policy_terms__backdated_issuance_allowed_indicator'},
        {'src': 'cancel_expired_policy_yn', 'tgt': 'aug_policy_terms__expired_policy_cancellation_allowed_indicator'},
        {'src': 'cancel_generic_yn', 'tgt': 'aug_policy_terms__generic_cancellation_allowed_indicator'},
        {'src': 'allow_inst_id_yn', 'tgt': 'aug_policy_terms__instalment_identifier_allowed_indicator'},
        {'src': 'longterm', 'tgt': 'aug_policy_terms__long_term_term_allowed_indicator'},
        {'src': 'days_in_advance', 'tgt': 'aug_policy_terms__maximum_advance_issuance_days'},
        {'src': 'no_of_days_backdated', 'tgt': 'aug_policy_terms__maximum_backdated_issuance_days'},
        {'src': 'policy_period_days', 'tgt': 'aug_policy_terms__permitted_policy_period_days'},
        {'src': 'policy_period_months', 'tgt': 'aug_policy_terms__permitted_policy_period_months'},
        {'src': 'policy_period_years', 'tgt': 'aug_policy_terms__permitted_policy_period_years'},
        {'src': 'shortterm', 'tgt': 'aug_policy_terms__short_period_term_allowed_indicator'}
      ]
    },
    {
      'model': 'stg_health__bjaz_enroll_pol_dtls',
      'alias': 't1',
      'key_column': "nullif(trim(policy_no),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_ENROLL_POL_DTLS',
      'columns': [
        {'src': 'crc_clause', 'tgt': 'aug_policy_terms__crc_clause_text'},
        {'src': 'crc_percent', 'tgt': 'aug_policy_terms__crc_percentage'}
      ]
    },
    {
      'model': 'stg_health__bjaz_ecard_pol_dtls_config',
      'alias': 't2',
      'key_column': 'policy_ref',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_ECARD_POL_DTLS_CONFIG',
      'columns': [
        {'src': 'endrosement_winprd', 'tgt': 'aug_policy_terms__endorsement_enrolment_window_days'},
        {'src': 'inception_winprd', 'tgt': 'aug_policy_terms__inception_enrolment_window_days'},
        {'src': 'lock_in_period', 'tgt': 'aug_policy_terms__lock_in_period'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_dtls',
      'alias': 't3',
      'key_column': 'reg_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_DTLS',
      'columns': [
        {'src': 'continuity_guideline', 'tgt': 'aug_policy_terms__continuity_guideline'},
        {'src': 'guideline_addition', 'tgt': 'aug_policy_terms__member_addition_guideline'},
        {'src': 'guideline_deletion', 'tgt': 'aug_policy_terms__member_deletion_guideline'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_maternity_dtls',
      'alias': 't4',
      'key_column': 'reg_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_MATERNITY_DTLS',
      'columns': [
        {'src': 'coalesce(claim_review_per, claims_review_clause, crc_review_period, refund_per_annually)', 'tgt': 'aug_policy_terms__claims_review_experience_refund_clause_terms'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hcf_member_dtls',
      'alias': 't5',
      'key_column': 'contract_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HCF_MEMBER_DTLS',
      'columns': [
        {'src': 'concurrent_policy_details', 'tgt': 'aug_policy_terms__concurrent_insurance_details'}
      ]
    },
    {
      'model': 'stg_health__bjaz_gmc_bases_extn',
      'alias': 't6',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GMC_BASES_EXTN',
      'columns': [
        {'src': 'clauses', 'tgt': 'aug_policy_terms__attached_clauses_description'},
        {'src': 'exclusions', 'tgt': 'aug_policy_terms__policy_exclusions_description'},
        {'src': 'sp_perils', 'tgt': 'aug_policy_terms__special_perils_covered_description'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_coverage_dtls',
      'alias': 't7',
      'key_column': "nullif(trim(reg_no),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_COVERAGE_DTLS',
      'columns': [
        {'src': 'one_waiting_period', 'tgt': 'aug_policy_terms__initial_waiting_period_one_year'},
        {'src': 'thirty_waiting_period', 'tgt': 'aug_policy_terms__initial_waiting_period_thirty_day'},
        {'src': 'pre_existing_dis', 'tgt': 'aug_policy_terms__pre_existing_disease_cover_basis'}
      ]
    },
    {
      'model': 'stg_health__bjaz_starpkg_pol_dtls',
      'alias': 't8',
      'key_column': "nullif(trim(contract_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_STARPKG_POL_DTLS',
      'columns': [
        {'src': 'other_condition', 'tgt': 'aug_policy_terms__other_conditions'}
      ]
    }
] -%}
{%- set output_columns = [
    'aug_policy_terms__backdated_issuance_allowed_indicator',
    'aug_policy_terms__expired_policy_cancellation_allowed_indicator',
    'aug_policy_terms__generic_cancellation_allowed_indicator',
    'aug_policy_terms__instalment_identifier_allowed_indicator',
    'aug_policy_terms__long_term_term_allowed_indicator',
    'aug_policy_terms__maximum_advance_issuance_days',
    'aug_policy_terms__maximum_backdated_issuance_days',
    'aug_policy_terms__permitted_policy_period_days',
    'aug_policy_terms__permitted_policy_period_months',
    'aug_policy_terms__permitted_policy_period_years',
    'aug_policy_terms__short_period_term_allowed_indicator',
    'aug_policy_terms__crc_clause_text',
    'aug_policy_terms__crc_percentage',
    'aug_policy_terms__endorsement_enrolment_window_days',
    'aug_policy_terms__inception_enrolment_window_days',
    'aug_policy_terms__lock_in_period',
    'aug_policy_terms__continuity_guideline',
    'aug_policy_terms__member_addition_guideline',
    'aug_policy_terms__member_deletion_guideline',
    'aug_policy_terms__claims_review_experience_refund_clause_terms',
    'aug_policy_terms__concurrent_insurance_details',
    'aug_policy_terms__attached_clauses_description',
    'aug_policy_terms__policy_exclusions_description',
    'aug_policy_terms__special_perils_covered_description',
    'aug_policy_terms__initial_waiting_period_one_year',
    'aug_policy_terms__initial_waiting_period_thirty_day',
    'aug_policy_terms__pre_existing_disease_cover_basis',
    'aug_policy_terms__other_conditions'
] -%}
{%- set coalesce_rules = {
    'aug_policy_terms__backdated_issuance_allowed_indicator': ['t0'],
    'aug_policy_terms__expired_policy_cancellation_allowed_indicator': ['t0'],
    'aug_policy_terms__generic_cancellation_allowed_indicator': ['t0'],
    'aug_policy_terms__instalment_identifier_allowed_indicator': ['t0'],
    'aug_policy_terms__long_term_term_allowed_indicator': ['t0'],
    'aug_policy_terms__maximum_advance_issuance_days': ['t0'],
    'aug_policy_terms__maximum_backdated_issuance_days': ['t0'],
    'aug_policy_terms__permitted_policy_period_days': ['t0'],
    'aug_policy_terms__permitted_policy_period_months': ['t0'],
    'aug_policy_terms__permitted_policy_period_years': ['t0'],
    'aug_policy_terms__short_period_term_allowed_indicator': ['t0'],
    'aug_policy_terms__crc_clause_text': ['t1'],
    'aug_policy_terms__crc_percentage': ['t1'],
    'aug_policy_terms__endorsement_enrolment_window_days': ['t2'],
    'aug_policy_terms__inception_enrolment_window_days': ['t2'],
    'aug_policy_terms__lock_in_period': ['t2'],
    'aug_policy_terms__continuity_guideline': ['t3'],
    'aug_policy_terms__member_addition_guideline': ['t3'],
    'aug_policy_terms__member_deletion_guideline': ['t3'],
    'aug_policy_terms__claims_review_experience_refund_clause_terms': ['t4'],
    'aug_policy_terms__concurrent_insurance_details': ['t5'],
    'aug_policy_terms__attached_clauses_description': ['t6'],
    'aug_policy_terms__policy_exclusions_description': ['t6'],
    'aug_policy_terms__special_perils_covered_description': ['t6'],
    'aug_policy_terms__initial_waiting_period_one_year': ['t7'],
    'aug_policy_terms__initial_waiting_period_thirty_day': ['t7'],
    'aug_policy_terms__pre_existing_disease_cover_basis': ['t7'],
    'aug_policy_terms__other_conditions': ['t8']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='policy_bk',
    target_sat='sat_aug_policy_terms'
) }}
