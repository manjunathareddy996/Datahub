{{ config(materialized='view') }}
-- This part feeds SAT_AUG_CLAIM_DISABILITY_HEAD only. Original precedence comments are kept below (from stitch_v05_claim).
-- CENTRAL VIEW v05_claim -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_HM_CLAIM_CLOSE (opus_health_v2)
--   BJAZ_HM_HCS_TECH_ASSESS_COV (opus_health_v2)
--   BJAZ_HM_PREAUTH_REQUEST (opus_health_v2)
--   BJAZ_HM_COINSU_CLM_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_HCM_EXTRACT (opus_health_legacy_v4)
--   BJAZ_HM_INWARD_AUTOALLOCATION (opus_health_legacy_v4)
--   BJAZ_HM_ORPHAN_REG (opus_health_legacy_v4)
--   BJAZ_HM_PREAUTH_QUERY (opus_health_legacy_v4)
--   BJAZ_RISK_TRANS_DTLS (opus_health_delta3)
--   NG_FAX_INWARD_DETAILS (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_CASE_HEADER
--   SAT_AUG_CLAIM_COVER_SECTION_ASSESSMENT
--   SAT_AUG_CLAIM_DISABILITY_HEAD
--   SAT_AUG_CLAIM_HEADER
--   SAT_AUG_CLAIM_HOSPITAL_DAY_LIMIT
--   SAT_AUG_CLAIM_PA_DETAIL
--   SAT_AUG_CLAIM_QUALITY_AUDIT
--   SAT_AUG_CLAIM_SLA_TRACKING
--   SAT_AUG_CLAIM_TRANSPORT_LEG
--   SAT_CASE_HEADER
--   SAT_CLAIM_RESERVE_HEAD
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_CASE_DOCUMENT
--   LNK_CASE_PARTY
--   LNK_CLAIM_CASE
--   LNK_CLAIM_DOCUMENT
--   LNK_CLAIM_PARTY
--   LNK_CLAIM_POLICY
--   LNK_CLAIM_RISK_OBJECT
--   LNK_PARTY_DOCUMENT
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_hm_hcs_tech_assess_cov') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_hm_hcs_tech_assess_cov',
      'alias': 't0',
      'key_column': "trim(to_varchar(nullif(trim(claim_id),''))) || '|' || coalesce(cover_section, '~') || '|' || 'FRACTURE'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HCS_TECH_ASSESS_COV',
      'columns': [
        {'src': "nullif(trim(claim_id),'')", 'tgt': 'claim_bk'},
        {'src': 'cover_section', 'tgt': 'aug_claim_disability_head__cover_section_code_ck'},
        {'src': "'FRACTURE'", 'tgt': 'aug_claim_disability_head__disability_type_code_ck'},
        {'src': 'fract_disability', 'tgt': 'aug_claim_disability_head__disability_description'},
        {'src': 'fract_percentage', 'tgt': 'aug_claim_disability_head__disability_percentage'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hcs_tech_assess_cov',
      'alias': 't1',
      'key_column': "trim(to_varchar(nullif(trim(claim_id),''))) || '|' || coalesce(cover_section, '~') || '|' || 'ADV'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HCS_TECH_ASSESS_COV',
      'columns': [
        {'src': "nullif(trim(claim_id),'')", 'tgt': 'claim_bk'},
        {'src': 'cover_section', 'tgt': 'aug_claim_disability_head__cover_section_code_ck'},
        {'src': "'ADV'", 'tgt': 'aug_claim_disability_head__disability_type_code_ck'},
        {'src': 'adv_disability', 'tgt': 'aug_claim_disability_head__disability_description'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hcs_tech_assess_cov',
      'alias': 't2',
      'key_column': "trim(to_varchar(nullif(trim(claim_id),''))) || '|' || coalesce(cover_section, '~') || '|' || 'PPD'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HCS_TECH_ASSESS_COV',
      'columns': [
        {'src': "nullif(trim(claim_id),'')", 'tgt': 'claim_bk'},
        {'src': 'cover_section', 'tgt': 'aug_claim_disability_head__cover_section_code_ck'},
        {'src': "'PPD'", 'tgt': 'aug_claim_disability_head__disability_type_code_ck'},
        {'src': 'ppd_disability', 'tgt': 'aug_claim_disability_head__disability_description'},
        {'src': 'ppd_percentage', 'tgt': 'aug_claim_disability_head__disability_percentage'},
        {'src': 'ppd_desc_func_loss', 'tgt': 'aug_claim_disability_head__functional_loss_description'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hcs_tech_assess_cov',
      'alias': 't3',
      'key_column': "trim(to_varchar(nullif(trim(claim_id),''))) || '|' || coalesce(cover_section, '~') || '|' || 'PTD'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HCS_TECH_ASSESS_COV',
      'columns': [
        {'src': "nullif(trim(claim_id),'')", 'tgt': 'claim_bk'},
        {'src': 'cover_section', 'tgt': 'aug_claim_disability_head__cover_section_code_ck'},
        {'src': "'PTD'", 'tgt': 'aug_claim_disability_head__disability_type_code_ck'},
        {'src': 'ptd_disability', 'tgt': 'aug_claim_disability_head__disability_description'},
        {'src': 'ptd_percentage', 'tgt': 'aug_claim_disability_head__disability_percentage'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hcs_tech_assess_cov',
      'alias': 't4',
      'key_column': "trim(to_varchar(nullif(trim(claim_id),''))) || '|' || coalesce(cover_section, '~') || '|' || 'TTD'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HCS_TECH_ASSESS_COV',
      'columns': [
        {'src': "nullif(trim(claim_id),'')", 'tgt': 'claim_bk'},
        {'src': 'cover_section', 'tgt': 'aug_claim_disability_head__cover_section_code_ck'},
        {'src': "'TTD'", 'tgt': 'aug_claim_disability_head__disability_type_code_ck'},
        {'src': 'ttd_approved_days', 'tgt': 'aug_claim_disability_head__approved_days_count'},
        {'src': 'ttd_disabilty', 'tgt': 'aug_claim_disability_head__disability_description'},
        {'src': 'ttd_disable_duration', 'tgt': 'aug_claim_disability_head__disability_duration'},
        {'src': 'ttd_fitness_date', 'tgt': 'aug_claim_disability_head__fitness_certified_date'},
        {'src': 'ttd_inj_date', 'tgt': 'aug_claim_disability_head__injury_date'},
        {'src': 'ttd_leave_duration', 'tgt': 'aug_claim_disability_head__leave_duration'},
        {'src': 'ttd_leave_from', 'tgt': 'aug_claim_disability_head__leave_from_date'},
        {'src': 'ttd_leave_to', 'tgt': 'aug_claim_disability_head__leave_to_date'},
        {'src': 'ttd_week_benefit', 'tgt': 'aug_claim_disability_head__weekly_benefit_amount'}
      ]
    }
] -%}
{%- set output_columns = [
    'claim_bk',
    'aug_claim_disability_head__cover_section_code_ck',
    'aug_claim_disability_head__disability_type_code_ck',
    'aug_claim_disability_head__disability_description',
    'aug_claim_disability_head__disability_percentage',
    'aug_claim_disability_head__functional_loss_description',
    'aug_claim_disability_head__approved_days_count',
    'aug_claim_disability_head__disability_duration',
    'aug_claim_disability_head__fitness_certified_date',
    'aug_claim_disability_head__injury_date',
    'aug_claim_disability_head__leave_duration',
    'aug_claim_disability_head__leave_from_date',
    'aug_claim_disability_head__leave_to_date',
    'aug_claim_disability_head__weekly_benefit_amount'
] -%}
{%- set coalesce_rules = {
    'claim_bk': ['t0', 't1', 't2', 't3', 't4'],
    'aug_claim_disability_head__cover_section_code_ck': ['t0', 't1', 't2', 't3', 't4'],
    'aug_claim_disability_head__disability_type_code_ck': ['t0', 't1', 't2', 't3', 't4'],
    'aug_claim_disability_head__disability_description': ['t0', 't1', 't2', 't3', 't4'],
    'aug_claim_disability_head__disability_percentage': ['t0', 't2', 't3'],
    'aug_claim_disability_head__functional_loss_description': ['t2'],
    'aug_claim_disability_head__approved_days_count': ['t4'],
    'aug_claim_disability_head__disability_duration': ['t4'],
    'aug_claim_disability_head__fitness_certified_date': ['t4'],
    'aug_claim_disability_head__injury_date': ['t4'],
    'aug_claim_disability_head__leave_duration': ['t4'],
    'aug_claim_disability_head__leave_from_date': ['t4'],
    'aug_claim_disability_head__leave_to_date': ['t4'],
    'aug_claim_disability_head__weekly_benefit_amount': ['t4']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='aug_claim_disability_head_pk',
    target_sat='sat_aug_claim_disability_head'
) }}
