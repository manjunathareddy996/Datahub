{{ config(materialized='view') }}
-- This part feeds SAT_CLAIM_ASSESSMENT_SUMMARY only. Original precedence comments are kept below (from stitch_v01_agreement).
-- CENTRAL VIEW v01_agreement -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_HAT_OCR_FINA_PERTICULARS (opus_health_v2)
--   BJAZ_CARD_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_HCM_EXTRACT (opus_health_legacy_v4)
--   BJAZ_HM_HOSPITAL_MASTER (opus_health_legacy_v4)
--   BJAZ_HM_HOSPITAL_MASTER_EXTN (opus_health_legacy_v4)
--   BJAZ_HM_HOSP_MASTER_EXTN1 (opus_health_legacy_v4)
--   BJAZ_HM_INWARD_DTLS (opus_health_legacy_v4)
--   BJAZ_REMEDINET_CLAIM_DETAILS (opus_health_legacy_v4)
--   BJAZ_TPA_CLAIM_DETAILS_WS (opus_health_legacy_v4)
--   NG_FAX_INWARD_DETAILS (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AGREEMENT_COMMERCIAL_TERMS
--   SAT_AGREEMENT_DEFINITION
--   SAT_AGREEMENT_SLA
--   SAT_AUG_AGREEMENT_COMMERCIAL_TERMS
--   SAT_AUG_AGREEMENT_DEFINITION
--   SAT_AUG_DOCUMENT_DEFINITION
--   SAT_AUG_PARTY_FRAUD_PROFILE
--   SAT_CLAIM_ASSESSMENT_SUMMARY
--   SAT_DOCUMENT_DEFINITION
--   SAT_LNK_ROLE_PROVIDER
--   SAT_PARTY_FRAUD_PROFILE
--   SAT_PROVIDER_QUALITY
--   SAT_PROVIDER_TARIFF
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_AGREEMENT_CHANNEL
--   LNK_AGREEMENT_PARTY
--   LNK_PARTY_CHANNEL
--   LNK_POLICY_CHANNEL
--   LNK_POLICY_DOCUMENT
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_remedinet_claim_details') }}
-- depends_on: {{ ref('stg_health__bjaz_tpa_claim_details_ws') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_remedinet_claim_details',
      'alias': 't0',
      'key_column': 'claim_no',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_REMEDINET_CLAIM_DETAILS',
      'columns': [
        {'src': 'total_allowed_amount', 'tgt': 'claim_assessment_summary__admissible_loss_amount'},
        {'src': 'deduction_amount', 'tgt': 'claim_assessment_summary__total_deduction_amount'}
      ]
    },
    {
      'model': 'stg_health__bjaz_tpa_claim_details_ws',
      'alias': 't1',
      'key_column': 'bjaz_claim_id',
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_TPA_CLAIM_DETAILS_WS',
      'columns': [
        {'src': 'recommend_amount', 'tgt': 'claim_assessment_summary__admissible_loss_amount'},
        {'src': 'recommend_on', 'tgt': 'claim_assessment_summary__assessment_date'},
        {'src': 'compulsary_deduction', 'tgt': 'claim_assessment_summary__deductible_applied'},
        {'src': 'deducted_amount', 'tgt': 'claim_assessment_summary__total_deduction_amount'}
      ]
    }
] -%}
{%- set output_columns = [
    'claim_assessment_summary__admissible_loss_amount',
    'claim_assessment_summary__total_deduction_amount',
    'claim_assessment_summary__assessment_date',
    'claim_assessment_summary__deductible_applied'
] -%}
{%- set coalesce_rules = {
    'claim_assessment_summary__admissible_loss_amount': ['t0', 't1'],
    'claim_assessment_summary__total_deduction_amount': ['t0', 't1'],
    'claim_assessment_summary__assessment_date': ['t1'],
    'claim_assessment_summary__deductible_applied': ['t1']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='claim_bk',
    target_sat='sat_claim_assessment_summary'
) }}
