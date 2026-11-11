{{ config(materialized='view') }}
-- This part feeds SAT_AUG_QUOTE_PREMIUM_RATE_AGE_BAND only. Original precedence comments are kept below (from stitch_v33_quote).
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
      'key_column': "trim(to_varchar(nullif(trim(quote_no),''))) || '|' || coalesce(premium_type, '~') || '|' || coalesce(si_age_band, '~') || '|' || '0-25'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_PREMIUM_DTLS_TYP1',
      'columns': [
        {'src': "nullif(trim(quote_no),'')", 'tgt': 'quote_bk'},
        {'src': 'premium_type', 'tgt': 'aug_quote_premium_rate_age_band__premium_type_ck'},
        {'src': 'si_age_band', 'tgt': 'aug_quote_premium_rate_age_band__sum_insured_slab_ck'},
        {'src': "'0-25'", 'tgt': 'aug_quote_premium_rate_age_band__age_band_code_ck'},
        {'src': 'age_0_25', 'tgt': 'aug_quote_premium_rate_age_band__age_band_premium_rate'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_premium_dtls_typ1',
      'alias': 't1',
      'key_column': "trim(to_varchar(nullif(trim(quote_no),''))) || '|' || coalesce(premium_type, '~') || '|' || coalesce(si_age_band, '~') || '|' || '26-35'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_PREMIUM_DTLS_TYP1',
      'columns': [
        {'src': "nullif(trim(quote_no),'')", 'tgt': 'quote_bk'},
        {'src': 'premium_type', 'tgt': 'aug_quote_premium_rate_age_band__premium_type_ck'},
        {'src': 'si_age_band', 'tgt': 'aug_quote_premium_rate_age_band__sum_insured_slab_ck'},
        {'src': "'26-35'", 'tgt': 'aug_quote_premium_rate_age_band__age_band_code_ck'},
        {'src': 'age_26_35', 'tgt': 'aug_quote_premium_rate_age_band__age_band_premium_rate'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_premium_dtls_typ1',
      'alias': 't2',
      'key_column': "trim(to_varchar(nullif(trim(quote_no),''))) || '|' || coalesce(premium_type, '~') || '|' || coalesce(si_age_band, '~') || '|' || '36-45'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_PREMIUM_DTLS_TYP1',
      'columns': [
        {'src': "nullif(trim(quote_no),'')", 'tgt': 'quote_bk'},
        {'src': 'premium_type', 'tgt': 'aug_quote_premium_rate_age_band__premium_type_ck'},
        {'src': 'si_age_band', 'tgt': 'aug_quote_premium_rate_age_band__sum_insured_slab_ck'},
        {'src': "'36-45'", 'tgt': 'aug_quote_premium_rate_age_band__age_band_code_ck'},
        {'src': 'age_36_45', 'tgt': 'aug_quote_premium_rate_age_band__age_band_premium_rate'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_premium_dtls_typ1',
      'alias': 't3',
      'key_column': "trim(to_varchar(nullif(trim(quote_no),''))) || '|' || coalesce(premium_type, '~') || '|' || coalesce(si_age_band, '~') || '|' || '46-55'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_PREMIUM_DTLS_TYP1',
      'columns': [
        {'src': "nullif(trim(quote_no),'')", 'tgt': 'quote_bk'},
        {'src': 'premium_type', 'tgt': 'aug_quote_premium_rate_age_band__premium_type_ck'},
        {'src': 'si_age_band', 'tgt': 'aug_quote_premium_rate_age_band__sum_insured_slab_ck'},
        {'src': "'46-55'", 'tgt': 'aug_quote_premium_rate_age_band__age_band_code_ck'},
        {'src': 'age_46_55', 'tgt': 'aug_quote_premium_rate_age_band__age_band_premium_rate'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_premium_dtls_typ1',
      'alias': 't4',
      'key_column': "trim(to_varchar(nullif(trim(quote_no),''))) || '|' || coalesce(premium_type, '~') || '|' || coalesce(si_age_band, '~') || '|' || '56-65'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_PREMIUM_DTLS_TYP1',
      'columns': [
        {'src': "nullif(trim(quote_no),'')", 'tgt': 'quote_bk'},
        {'src': 'premium_type', 'tgt': 'aug_quote_premium_rate_age_band__premium_type_ck'},
        {'src': 'si_age_band', 'tgt': 'aug_quote_premium_rate_age_band__sum_insured_slab_ck'},
        {'src': "'56-65'", 'tgt': 'aug_quote_premium_rate_age_band__age_band_code_ck'},
        {'src': 'age_56_65', 'tgt': 'aug_quote_premium_rate_age_band__age_band_premium_rate'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_premium_dtls_typ1',
      'alias': 't5',
      'key_column': "trim(to_varchar(nullif(trim(quote_no),''))) || '|' || coalesce(premium_type, '~') || '|' || coalesce(si_age_band, '~') || '|' || '66-70'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_PREMIUM_DTLS_TYP1',
      'columns': [
        {'src': "nullif(trim(quote_no),'')", 'tgt': 'quote_bk'},
        {'src': 'premium_type', 'tgt': 'aug_quote_premium_rate_age_band__premium_type_ck'},
        {'src': 'si_age_band', 'tgt': 'aug_quote_premium_rate_age_band__sum_insured_slab_ck'},
        {'src': "'66-70'", 'tgt': 'aug_quote_premium_rate_age_band__age_band_code_ck'},
        {'src': 'age_66_70', 'tgt': 'aug_quote_premium_rate_age_band__age_band_premium_rate'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_premium_dtls_typ1',
      'alias': 't6',
      'key_column': "trim(to_varchar(nullif(trim(quote_no),''))) || '|' || coalesce(premium_type, '~') || '|' || coalesce(si_age_band, '~') || '|' || '71-75'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_PREMIUM_DTLS_TYP1',
      'columns': [
        {'src': "nullif(trim(quote_no),'')", 'tgt': 'quote_bk'},
        {'src': 'premium_type', 'tgt': 'aug_quote_premium_rate_age_band__premium_type_ck'},
        {'src': 'si_age_band', 'tgt': 'aug_quote_premium_rate_age_band__sum_insured_slab_ck'},
        {'src': "'71-75'", 'tgt': 'aug_quote_premium_rate_age_band__age_band_code_ck'},
        {'src': 'age_71_75', 'tgt': 'aug_quote_premium_rate_age_band__age_band_premium_rate'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_premium_dtls_typ1',
      'alias': 't7',
      'key_column': "trim(to_varchar(nullif(trim(quote_no),''))) || '|' || coalesce(premium_type, '~') || '|' || coalesce(si_age_band, '~') || '|' || '76-80'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_PREMIUM_DTLS_TYP1',
      'columns': [
        {'src': "nullif(trim(quote_no),'')", 'tgt': 'quote_bk'},
        {'src': 'premium_type', 'tgt': 'aug_quote_premium_rate_age_band__premium_type_ck'},
        {'src': 'si_age_band', 'tgt': 'aug_quote_premium_rate_age_band__sum_insured_slab_ck'},
        {'src': "'76-80'", 'tgt': 'aug_quote_premium_rate_age_band__age_band_code_ck'},
        {'src': 'age_76_80', 'tgt': 'aug_quote_premium_rate_age_band__age_band_premium_rate'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_premium_dtls_typ1',
      'alias': 't8',
      'key_column': "trim(to_varchar(nullif(trim(quote_no),''))) || '|' || coalesce(premium_type, '~') || '|' || coalesce(si_age_band, '~') || '|' || 'ABOVE-80'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_PREMIUM_DTLS_TYP1',
      'columns': [
        {'src': "nullif(trim(quote_no),'')", 'tgt': 'quote_bk'},
        {'src': 'premium_type', 'tgt': 'aug_quote_premium_rate_age_band__premium_type_ck'},
        {'src': 'si_age_band', 'tgt': 'aug_quote_premium_rate_age_band__sum_insured_slab_ck'},
        {'src': "'ABOVE-80'", 'tgt': 'aug_quote_premium_rate_age_band__age_band_code_ck'},
        {'src': 'above_80', 'tgt': 'aug_quote_premium_rate_age_band__age_band_premium_rate'}
      ]
    }
] -%}
{%- set output_columns = [
    'quote_bk',
    'aug_quote_premium_rate_age_band__premium_type_ck',
    'aug_quote_premium_rate_age_band__sum_insured_slab_ck',
    'aug_quote_premium_rate_age_band__age_band_code_ck',
    'aug_quote_premium_rate_age_band__age_band_premium_rate'
] -%}
{%- set coalesce_rules = {
    'quote_bk': ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't7', 't8'],
    'aug_quote_premium_rate_age_band__premium_type_ck': ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't7', 't8'],
    'aug_quote_premium_rate_age_band__sum_insured_slab_ck': ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't7', 't8'],
    'aug_quote_premium_rate_age_band__age_band_code_ck': ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't7', 't8'],
    'aug_quote_premium_rate_age_band__age_band_premium_rate': ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't7', 't8']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='aug_quote_premium_rate_age_band_pk',
    target_sat='sat_aug_quote_premium_rate_age_band'
) }}
