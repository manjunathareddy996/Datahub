{{ config(materialized='view') }}
-- This part feeds SAT_AUG_CLAIM_BENEFIT_HEAD only. Original precedence comments are kept below (from stitch_v07_claim).
-- CENTRAL VIEW v07_claim -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_HM_CLAIM_CLOSE (opus_health_v2)
--   BJAZ_HM_CLAIM_REOPEN (opus_health_v2)
--   BJAZ_HM_CLAIM_TRACKER (opus_health_v2)
--   BJAZ_HM_GPA_BILL_DTLS (opus_health_v2)
--   BJAZ_HM_HCS_TECH_ASSESS_COV (opus_health_v2)
--   BJAZ_HM_PREAUTH_REQUEST (opus_health_v2)
--   BJAZ_HAT_OCR_FINA_DTLS_LST (opus_health_legacy_v4)
--   BJAZ_HM_COINSU_CLM_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_HCM_EXTRACT (opus_health_legacy_v4)
--   BJAZ_HM_ORPHAN_REG (opus_health_legacy_v4)
--   BJAZ_HM_PRO_ASSESSMENT (opus_health_legacy_v4)
--   BJAZ_REMEDINET_CLAIM_DETAILS (opus_health_legacy_v4)
--   BJAZ_TPA_CLAIM_DETAILS_WS (opus_health_legacy_v4)
--   BJAZ_RISK_TRANS_DTLS (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_CLAIM_BENEFIT_HEAD
--   SAT_AUG_CLAIM_REOPEN
--   SAT_CLAIM_BENEFIT_HEAD
--   SAT_CLAIM_HEADER
--   SAT_CLAIM_REPUDIATION
--   SAT_CLAIM_SETTLEMENT
-- Links whose legs come from one source row on this view (rule 6):
-- OVER the table limit by rule 3: one satellite on this view needs every table above.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_hm_gpa_bill_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_hcs_tech_assess_cov') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_hm_gpa_bill_dtls',
      'alias': 't0',
      'key_column': "nullif(trim(claim_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_GPA_BILL_DTLS',
      'columns': [
        {'src': 'coalesce(emi_no_days, ttd_dur_disablement)', 'tgt': 'aug_claim_benefit_head__head_assessed_duration_days'},
        {'src': 'coalesce(edu_no_children, no_emi_paid, no_of_child)', 'tgt': 'aug_claim_benefit_head__head_basis_count'},
        {'src': 'coalesce(cause_death, critical_illness, ptd_disability, ttd_disability)', 'tgt': 'aug_claim_benefit_head__head_basis_description'},
        {'src': 'ttd_dur_leaves', 'tgt': 'aug_claim_benefit_head__head_claimed_duration_days'},
        {'src': 'ttd_leave_from', 'tgt': 'aug_claim_benefit_head__head_claimed_period_from_date'},
        {'src': 'ttd_leave_to', 'tgt': 'aug_claim_benefit_head__head_claimed_period_to_date'},
        {'src': 'coalesce(family_travel_date, funeral_date, transport_date)', 'tgt': 'aug_claim_benefit_head__head_event_date'},
        {'src': 'coalesce(emi_jobloss_date, med_disable_date, ttd_inj_date)', 'tgt': 'aug_claim_benefit_head__head_onset_date'},
        {'src': 'coalesce(emi_otherorg_date, med_recover_date, ttd_fit_date)', 'tgt': 'aug_claim_benefit_head__head_resolution_date'},
        {'src': 'family_from_city', 'tgt': 'aug_claim_benefit_head__travel_from_city'},
        {'src': 'family_to_city', 'tgt': 'aug_claim_benefit_head__travel_to_city'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hcs_tech_assess_cov',
      'alias': 't1',
      'key_column': "nullif(trim(claim_id),'')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HCS_TECH_ASSESS_COV',
      'columns': [
        {'src': 'cum_bonus', 'tgt': 'aug_claim_benefit_head__cumulative_bonus_amount_on_head'},
        {'src': 'bsi', 'tgt': 'aug_claim_benefit_head__head_base_sum_insured'},
        {'src': 'sum_insured', 'tgt': 'aug_claim_benefit_head__sum_insured_for_head'}
      ]
    }
] -%}
{%- set output_columns = [
    'aug_claim_benefit_head__head_assessed_duration_days',
    'aug_claim_benefit_head__head_basis_count',
    'aug_claim_benefit_head__head_basis_description',
    'aug_claim_benefit_head__head_claimed_duration_days',
    'aug_claim_benefit_head__head_claimed_period_from_date',
    'aug_claim_benefit_head__head_claimed_period_to_date',
    'aug_claim_benefit_head__head_event_date',
    'aug_claim_benefit_head__head_onset_date',
    'aug_claim_benefit_head__head_resolution_date',
    'aug_claim_benefit_head__travel_from_city',
    'aug_claim_benefit_head__travel_to_city',
    'aug_claim_benefit_head__cumulative_bonus_amount_on_head',
    'aug_claim_benefit_head__head_base_sum_insured',
    'aug_claim_benefit_head__sum_insured_for_head'
] -%}
{%- set coalesce_rules = {
    'aug_claim_benefit_head__head_assessed_duration_days': ['t0'],
    'aug_claim_benefit_head__head_basis_count': ['t0'],
    'aug_claim_benefit_head__head_basis_description': ['t0'],
    'aug_claim_benefit_head__head_claimed_duration_days': ['t0'],
    'aug_claim_benefit_head__head_claimed_period_from_date': ['t0'],
    'aug_claim_benefit_head__head_claimed_period_to_date': ['t0'],
    'aug_claim_benefit_head__head_event_date': ['t0'],
    'aug_claim_benefit_head__head_onset_date': ['t0'],
    'aug_claim_benefit_head__head_resolution_date': ['t0'],
    'aug_claim_benefit_head__travel_from_city': ['t0'],
    'aug_claim_benefit_head__travel_to_city': ['t0'],
    'aug_claim_benefit_head__cumulative_bonus_amount_on_head': ['t1'],
    'aug_claim_benefit_head__head_base_sum_insured': ['t1'],
    'aug_claim_benefit_head__sum_insured_for_head': ['t1']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='claim_bk',
    target_sat='sat_aug_claim_benefit_head'
) }}
