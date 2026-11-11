{{ config(materialized='view') }}
-- This part feeds SAT_AUG_QUOTE_PREMIUM_RATE_SLAB only. Original precedence comments are kept below (from stitch_v33_quote).
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
-- depends_on: {{ ref('stg_health__bjaz_grp_hlt_premium_dtls_typ1') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_grp_hlt_premium_dtls_typ1',
      'alias': 't0',
      'key_column': "trim(to_varchar(nullif(trim(quote_no),''))) || '|' || coalesce(premium_type, '~') || '|' || coalesce(si_age_band, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_PREMIUM_DTLS_TYP1',
      'columns': [
        {'src': "nullif(trim(quote_no),'')", 'tgt': 'quote_bk'},
        {'src': 'premium_type', 'tgt': 'aug_quote_premium_rate_slab__premium_type_ck'},
        {'src': 'si_age_band', 'tgt': 'aug_quote_premium_rate_slab__sum_insured_slab_ck'},
        {'src': 'premium_type', 'tgt': 'aug_quote_premium_rate_slab__premium_rating_basis'},
        {'src': 'ppp_type', 'tgt': 'aug_quote_premium_rate_slab__rate_applicability_stage'},
        {'src': 'record_date', 'tgt': 'aug_quote_premium_rate_slab__rate_record_date'},
        {'src': 'source_name', 'tgt': 'aug_quote_premium_rate_slab__rate_source_name'},
        {'src': 'si_age_band', 'tgt': 'aug_quote_premium_rate_slab__sum_insured_slab_amount'}
      ]
    }
] -%}
{%- set output_columns = [
    'quote_bk',
    'aug_quote_premium_rate_slab__premium_type_ck',
    'aug_quote_premium_rate_slab__sum_insured_slab_ck',
    'aug_quote_premium_rate_slab__premium_rating_basis',
    'aug_quote_premium_rate_slab__rate_applicability_stage',
    'aug_quote_premium_rate_slab__rate_record_date',
    'aug_quote_premium_rate_slab__rate_source_name',
    'aug_quote_premium_rate_slab__sum_insured_slab_amount'
] -%}
{%- set coalesce_rules = {
    'quote_bk': ['t0'],
    'aug_quote_premium_rate_slab__premium_type_ck': ['t0'],
    'aug_quote_premium_rate_slab__sum_insured_slab_ck': ['t0'],
    'aug_quote_premium_rate_slab__premium_rating_basis': ['t0'],
    'aug_quote_premium_rate_slab__rate_applicability_stage': ['t0'],
    'aug_quote_premium_rate_slab__rate_record_date': ['t0'],
    'aug_quote_premium_rate_slab__rate_source_name': ['t0'],
    'aug_quote_premium_rate_slab__sum_insured_slab_amount': ['t0']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='aug_quote_premium_rate_slab_pk',
    target_sat='sat_aug_quote_premium_rate_slab'
) }}
