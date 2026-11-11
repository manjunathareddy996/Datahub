{{ config(materialized='view') }}
-- This part feeds SAT_AUG_CLAIM_COVER_SECTION_ASSESSMENT only. Original precedence comments are kept below (from stitch_v05_claim).
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
      'key_column': "trim(to_varchar(nullif(trim(claim_id),''))) || '|' || coalesce(cover_section, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HCS_TECH_ASSESS_COV',
      'columns': [
        {'src': "nullif(trim(claim_id),'')", 'tgt': 'claim_bk'},
        {'src': 'cover_section', 'tgt': 'aug_claim_cover_section_assessment__cover_section_code_ck'},
        {'src': 'adv_sports', 'tgt': 'aug_claim_cover_section_assessment__adventure_sports_involvement'},
        {'src': 'adv_medi_hist', 'tgt': 'aug_claim_cover_section_assessment__adverse_medical_history_finding'},
        {'src': 'assess_end_date', 'tgt': 'aug_claim_cover_section_assessment__assessment_completed_date'},
        {'src': 'param10', 'tgt': 'aug_claim_cover_section_assessment__assessment_parameter_slot_10_value'},
        {'src': 'param11', 'tgt': 'aug_claim_cover_section_assessment__assessment_parameter_slot_11_value'},
        {'src': 'param12', 'tgt': 'aug_claim_cover_section_assessment__assessment_parameter_slot_12_value'},
        {'src': 'param1', 'tgt': 'aug_claim_cover_section_assessment__assessment_parameter_slot_1_value'},
        {'src': 'comments', 'tgt': 'aug_claim_cover_section_assessment__assessor_comment'},
        {'src': 'gen_remarks', 'tgt': 'aug_claim_cover_section_assessment__assessor_general_remarks'},
        {'src': 'case_mgmt', 'tgt': 'aug_claim_cover_section_assessment__case_management_indicator'},
        {'src': 'edu_no_of_child', 'tgt': 'aug_claim_cover_section_assessment__education_benefit_child_count'},
        {'src': 'emi_no_days', 'tgt': 'aug_claim_cover_section_assessment__emi_benefit_day_count'},
        {'src': 'emi_fitness_date', 'tgt': 'aug_claim_cover_section_assessment__emi_benefit_fitness_date'},
        {'src': 'emi_inj_date', 'tgt': 'aug_claim_cover_section_assessment__emi_benefit_injury_date'},
        {'src': 'emi_amount', 'tgt': 'aug_claim_cover_section_assessment__emi_instalment_amount'},
        {'src': 'no_of_emi', 'tgt': 'aug_claim_cover_section_assessment__emi_instalment_count'},
        {'src': 'funeral_date', 'tgt': 'aug_claim_cover_section_assessment__funeral_date'},
        {'src': 'more_info_req', 'tgt': 'aug_claim_cover_section_assessment__further_information_required'},
        {'src': 'hosp_days_disallow', 'tgt': 'aug_claim_cover_section_assessment__hospitalisation_days_disallowed'},
        {'src': 'hosp_particular', 'tgt': 'aug_claim_cover_section_assessment__hospitalisation_particulars'},
        {'src': 'last_emi_paid_date', 'tgt': 'aug_claim_cover_section_assessment__last_emi_paid_date'},
        {'src': 'non_disclosure', 'tgt': 'aug_claim_cover_section_assessment__non_disclosure_finding'},
        {'src': 'outstd_loan_amt', 'tgt': 'aug_claim_cover_section_assessment__outstanding_loan_amount'}
      ]
    }
] -%}
{%- set output_columns = [
    'claim_bk',
    'aug_claim_cover_section_assessment__cover_section_code_ck',
    'aug_claim_cover_section_assessment__adventure_sports_involvement',
    'aug_claim_cover_section_assessment__adverse_medical_history_finding',
    'aug_claim_cover_section_assessment__assessment_completed_date',
    'aug_claim_cover_section_assessment__assessment_parameter_slot_10_value',
    'aug_claim_cover_section_assessment__assessment_parameter_slot_11_value',
    'aug_claim_cover_section_assessment__assessment_parameter_slot_12_value',
    'aug_claim_cover_section_assessment__assessment_parameter_slot_1_value',
    'aug_claim_cover_section_assessment__assessor_comment',
    'aug_claim_cover_section_assessment__assessor_general_remarks',
    'aug_claim_cover_section_assessment__case_management_indicator',
    'aug_claim_cover_section_assessment__education_benefit_child_count',
    'aug_claim_cover_section_assessment__emi_benefit_day_count',
    'aug_claim_cover_section_assessment__emi_benefit_fitness_date',
    'aug_claim_cover_section_assessment__emi_benefit_injury_date',
    'aug_claim_cover_section_assessment__emi_instalment_amount',
    'aug_claim_cover_section_assessment__emi_instalment_count',
    'aug_claim_cover_section_assessment__funeral_date',
    'aug_claim_cover_section_assessment__further_information_required',
    'aug_claim_cover_section_assessment__hospitalisation_days_disallowed',
    'aug_claim_cover_section_assessment__hospitalisation_particulars',
    'aug_claim_cover_section_assessment__last_emi_paid_date',
    'aug_claim_cover_section_assessment__non_disclosure_finding',
    'aug_claim_cover_section_assessment__outstanding_loan_amount'
] -%}
{%- set coalesce_rules = {
    'claim_bk': ['t0'],
    'aug_claim_cover_section_assessment__cover_section_code_ck': ['t0'],
    'aug_claim_cover_section_assessment__adventure_sports_involvement': ['t0'],
    'aug_claim_cover_section_assessment__adverse_medical_history_finding': ['t0'],
    'aug_claim_cover_section_assessment__assessment_completed_date': ['t0'],
    'aug_claim_cover_section_assessment__assessment_parameter_slot_10_value': ['t0'],
    'aug_claim_cover_section_assessment__assessment_parameter_slot_11_value': ['t0'],
    'aug_claim_cover_section_assessment__assessment_parameter_slot_12_value': ['t0'],
    'aug_claim_cover_section_assessment__assessment_parameter_slot_1_value': ['t0'],
    'aug_claim_cover_section_assessment__assessor_comment': ['t0'],
    'aug_claim_cover_section_assessment__assessor_general_remarks': ['t0'],
    'aug_claim_cover_section_assessment__case_management_indicator': ['t0'],
    'aug_claim_cover_section_assessment__education_benefit_child_count': ['t0'],
    'aug_claim_cover_section_assessment__emi_benefit_day_count': ['t0'],
    'aug_claim_cover_section_assessment__emi_benefit_fitness_date': ['t0'],
    'aug_claim_cover_section_assessment__emi_benefit_injury_date': ['t0'],
    'aug_claim_cover_section_assessment__emi_instalment_amount': ['t0'],
    'aug_claim_cover_section_assessment__emi_instalment_count': ['t0'],
    'aug_claim_cover_section_assessment__funeral_date': ['t0'],
    'aug_claim_cover_section_assessment__further_information_required': ['t0'],
    'aug_claim_cover_section_assessment__hospitalisation_days_disallowed': ['t0'],
    'aug_claim_cover_section_assessment__hospitalisation_particulars': ['t0'],
    'aug_claim_cover_section_assessment__last_emi_paid_date': ['t0'],
    'aug_claim_cover_section_assessment__non_disclosure_finding': ['t0'],
    'aug_claim_cover_section_assessment__outstanding_loan_amount': ['t0']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='aug_claim_cover_section_assessment_pk',
    target_sat='sat_aug_claim_cover_section_assessment'
) }}
