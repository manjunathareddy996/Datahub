{{ config(materialized='view') }}
-- This part feeds SAT_AUG_QUOTE_HEADER only. Original precedence comments are kept below (from stitch_v33_quote).
-- CENTRAL VIEW v33_quote -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_CTNGY_GC_CONTROL (opus_health_v2)
--   BJAZ_ENROLL_POL_DTLS (opus_health_v2)
--   BJAZ_ENROLL_SCR_DTLS (opus_health_v2)
--   BJAZ_GRP_HLT_PREMIUM_DTLS_TYP1 (opus_health_v2)
--   BJAZ_HM_MEMBER_HLTH_DTLS (opus_health_v2)
--   BJAZ_ECARD_POL_DTLS_CONFIG (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_DTLS (opus_health_legacy_v4)
--   BJAZ_GMC_BASES_EXTN (opus_health_delta3)
--   BJAZ_STARPKG_POL_DTLS (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_PARTY_ORGANISATION_PROFILE
--   SAT_AUG_POLICY_GROUP
--   SAT_AUG_POLICY_GROUP_DOCUMENT_CONTROL
--   SAT_AUG_PROPOSAL_HEADER
--   SAT_AUG_PROPOSAL_UNDERWRITING
--   SAT_AUG_QUOTE_HEADER
--   SAT_AUG_QUOTE_PREMIUM_RATE_AGE_BAND
--   SAT_AUG_QUOTE_PREMIUM_RATE_SLAB
--   SAT_AUG_QUOTE_RATING
--   SAT_AUG_RISK_HEALTH_MEMBER_COVERAGE
--   SAT_POLICY_DOC_CHECKLIST
--   SAT_QUOTE_RATING_INPUT
--   SAT_RISK_HEALTH_PED_WAITING
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_POLICY_RISK_OBJECT
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_enroll_pol_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_grp_hlt_dtls') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_enroll_pol_dtls',
      'alias': 't0',
      'key_column': "nullif(trim(quotation_no),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_ENROLL_POL_DTLS',
      'columns': [
        {'src': 'quotation_type', 'tgt': 'aug_quote_header__quote_business_type'},
        {'src': 'quote_copy', 'tgt': 'aug_quote_header__quote_copy_reference'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_dtls',
      'alias': 't1',
      'key_column': 'quote_sub_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_DTLS',
      'columns': [
        {'src': 'last_quote_sub_date', 'tgt': 'aug_quote_header__last_quote_submission_date'},
        {'src': 'data_information', 'tgt': 'aug_quote_header__quote_data_information'},
        {'src': 'description', 'tgt': 'aug_quote_header__quote_description'},
        {'src': 'priority', 'tgt': 'aug_quote_header__quote_priority'},
        {'src': 'resolution_date', 'tgt': 'aug_quote_header__quote_resolution_date'},
        {'src': 'subject', 'tgt': 'aug_quote_header__quote_subject'},
        {'src': 'quote_sub_status', 'tgt': 'aug_quote_header__quote_sub_status'},
        {'src': 'quote_sub_status_desc', 'tgt': 'aug_quote_header__quote_sub_status_description'}
      ]
    }
] -%}
{%- set output_columns = [
    'aug_quote_header__quote_business_type',
    'aug_quote_header__quote_copy_reference',
    'aug_quote_header__last_quote_submission_date',
    'aug_quote_header__quote_data_information',
    'aug_quote_header__quote_description',
    'aug_quote_header__quote_priority',
    'aug_quote_header__quote_resolution_date',
    'aug_quote_header__quote_subject',
    'aug_quote_header__quote_sub_status',
    'aug_quote_header__quote_sub_status_description'
] -%}
{%- set coalesce_rules = {
    'aug_quote_header__quote_business_type': ['t0'],
    'aug_quote_header__quote_copy_reference': ['t0'],
    'aug_quote_header__last_quote_submission_date': ['t1'],
    'aug_quote_header__quote_data_information': ['t1'],
    'aug_quote_header__quote_description': ['t1'],
    'aug_quote_header__quote_priority': ['t1'],
    'aug_quote_header__quote_resolution_date': ['t1'],
    'aug_quote_header__quote_subject': ['t1'],
    'aug_quote_header__quote_sub_status': ['t1'],
    'aug_quote_header__quote_sub_status_description': ['t1']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='quote_bk',
    target_sat='sat_aug_quote_header'
) }}
