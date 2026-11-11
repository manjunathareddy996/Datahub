{{ config(materialized='view') }}
-- This part feeds SAT_AUG_CLAIM_HOSPITAL_DAY_LIMIT only. Original precedence comments are kept below (from stitch_v05_claim).
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
      'key_column': "trim(to_varchar(nullif(trim(claim_id),''))) || '|' || coalesce(cover_section, '~') || '|' || 'NORMAL'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HCS_TECH_ASSESS_COV',
      'columns': [
        {'src': "nullif(trim(claim_id),'')", 'tgt': 'claim_bk'},
        {'src': 'cover_section', 'tgt': 'aug_claim_hospital_day_limit__cover_section_code_ck'},
        {'src': "'NORMAL'", 'tgt': 'aug_claim_hospital_day_limit__ward_class_code_ck'},
        {'src': 'hosp_normal', 'tgt': 'aug_claim_hospital_day_limit__assessed_component_value'},
        {'src': 'hosp_bal_norm_days', 'tgt': 'aug_claim_hospital_day_limit__balance_days'},
        {'src': 'hosp_elgi_amt_norm', 'tgt': 'aug_claim_hospital_day_limit__eligible_amount_per_day'},
        {'src': 'hosp_tot_norm_days', 'tgt': 'aug_claim_hospital_day_limit__total_days'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hcs_tech_assess_cov',
      'alias': 't1',
      'key_column': "trim(to_varchar(nullif(trim(claim_id),''))) || '|' || coalesce(cover_section, '~') || '|' || 'ICU'",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HCS_TECH_ASSESS_COV',
      'columns': [
        {'src': "nullif(trim(claim_id),'')", 'tgt': 'claim_bk'},
        {'src': 'cover_section', 'tgt': 'aug_claim_hospital_day_limit__cover_section_code_ck'},
        {'src': "'ICU'", 'tgt': 'aug_claim_hospital_day_limit__ward_class_code_ck'},
        {'src': 'hosp_icu', 'tgt': 'aug_claim_hospital_day_limit__assessed_component_value'},
        {'src': 'hosp_bal_icu_days', 'tgt': 'aug_claim_hospital_day_limit__balance_days'},
        {'src': 'hosp_elgi_amt_icu', 'tgt': 'aug_claim_hospital_day_limit__eligible_amount_per_day'},
        {'src': 'hosp_tot_icu_days', 'tgt': 'aug_claim_hospital_day_limit__total_days'}
      ]
    }
] -%}
{%- set output_columns = [
    'claim_bk',
    'aug_claim_hospital_day_limit__cover_section_code_ck',
    'aug_claim_hospital_day_limit__ward_class_code_ck',
    'aug_claim_hospital_day_limit__assessed_component_value',
    'aug_claim_hospital_day_limit__balance_days',
    'aug_claim_hospital_day_limit__eligible_amount_per_day',
    'aug_claim_hospital_day_limit__total_days'
] -%}
{%- set coalesce_rules = {
    'claim_bk': ['t0', 't1'],
    'aug_claim_hospital_day_limit__cover_section_code_ck': ['t0', 't1'],
    'aug_claim_hospital_day_limit__ward_class_code_ck': ['t0', 't1'],
    'aug_claim_hospital_day_limit__assessed_component_value': ['t0', 't1'],
    'aug_claim_hospital_day_limit__balance_days': ['t0', 't1'],
    'aug_claim_hospital_day_limit__eligible_amount_per_day': ['t0', 't1'],
    'aug_claim_hospital_day_limit__total_days': ['t0', 't1']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='aug_claim_hospital_day_limit_pk',
    target_sat='sat_aug_claim_hospital_day_limit'
) }}
