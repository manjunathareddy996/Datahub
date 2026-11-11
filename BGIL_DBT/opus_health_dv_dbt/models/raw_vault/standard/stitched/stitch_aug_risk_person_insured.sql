{{ config(materialized='view') }}
-- This part feeds SAT_AUG_RISK_PERSON_INSURED only. Original precedence comments are kept below (from stitch_v34_risk_object).
-- CENTRAL VIEW v34_risk_object -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_HM_CLAIM_TRACKER (opus_health_v2)
--   BJAZ_HM_HCS_TECH_ASSESS_COV (opus_health_v2)
--   BJAZ_HM_MEMBER_HLTH_DTLS (opus_health_v2)
--   BJAZ_PMSBY_DATA_WEB_SERVICE (opus_health_v2)
--   BA_HCP_PROD_8428_GPG_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8433_FHC_LOADER (opus_health_legacy_v4)
--   BJAZ_EC_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_HCF_MEMBER_DTLS (opus_health_legacy_v4)
--   BJAZ_REMEDINET_PATIENT_DETAILS (opus_health_delta3)
--   BJAZ_RISK_TRANS_DTLS (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_CHANNEL_DIGITAL_INTEGRATION
--   SAT_AUG_CLAIM_STATUS_TRANSITION
--   SAT_AUG_RISK_HEALTH_MEMBER_MEDICAL
--   SAT_AUG_RISK_PERSON_INSURED
--   SAT_CLAIM_SLA_TRACKING
--   SAT_LNK_ROLE_BANCASSURANCE
--   SAT_PARTY_INDIVIDUAL_DEMOGRAPHICS
--   SAT_POLICY_PREMIUM_SETTLEMENT
--   SAT_RISK_HEALTH_MEMBER_COVERAGE
--   SAT_RISK_HEALTH_MEMBER_MEDICAL
--   SAT_RISK_PERSON_INSURED
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_CLAIM_RISK_OBJECT
--   LNK_POLICY_CHANNEL
--   LNK_POLICY_RISK_OBJECT
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_hm_member_hlth_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_pmsby_data_web_service') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_hm_member_hlth_dtls',
      'alias': 't0',
      'key_column': "nullif('MEMBER:' || coalesce(nullif(trim(contract_id),''),'') || '#' || coalesce(nullif(trim(member_id),''),''), 'MEMBER:#')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_MEMBER_HLTH_DTLS',
      'columns': [
        {'src': 'age_proof', 'tgt': 'aug_risk_person_insured__age_proof_submitted_indicator'},
        {'src': 'claim_history', 'tgt': 'aug_risk_person_insured__declared_claim_history_detail'},
        {'src': 'amount_claimed', 'tgt': 'aug_risk_person_insured__declared_prior_claim_amount'},
        {'src': 'gmc_family_hist_details', 'tgt': 'aug_risk_person_insured__family_medical_history_detail'},
        {'src': 'gmc_family_hist', 'tgt': 'aug_risk_person_insured__family_medical_history_indicator'},
        {'src': 'gmc_load_flag', 'tgt': 'aug_risk_person_insured__member_loading_applied_indicator'},
        {'src': 'other_hlt_dtls', 'tgt': 'aug_risk_person_insured__other_health_declaration_detail'},
        {'src': 'prev_sum_insured', 'tgt': 'aug_risk_person_insured__previous_sum_insured'}
      ]
    },
    {
      'model': 'stg_health__bjaz_pmsby_data_web_service',
      'alias': 't1',
      'key_column': "nullif('CUSTID:' || nullif(trim(cust_id),''), 'CUSTID:')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_PMSBY_DATA_WEB_SERVICE',
      'columns': [
        {'src': 'card_status', 'tgt': 'aug_risk_person_insured__health_card_status'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8433_fhc_loader',
      'alias': 't2',
      'key_column': "pol_serial_no || '|' || md_seq_no",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8433_FHC_LOADER',
      'columns': [
        {'src': 'md_spcl_condtn_member_level', 'tgt': 'aug_risk_person_insured__member_special_condition'}
      ]
    }
] -%}
{%- set output_columns = [
    'aug_risk_person_insured__age_proof_submitted_indicator',
    'aug_risk_person_insured__declared_claim_history_detail',
    'aug_risk_person_insured__declared_prior_claim_amount',
    'aug_risk_person_insured__family_medical_history_detail',
    'aug_risk_person_insured__family_medical_history_indicator',
    'aug_risk_person_insured__member_loading_applied_indicator',
    'aug_risk_person_insured__other_health_declaration_detail',
    'aug_risk_person_insured__previous_sum_insured',
    'aug_risk_person_insured__health_card_status',
    'aug_risk_person_insured__member_special_condition'
] -%}
{%- set coalesce_rules = {
    'aug_risk_person_insured__age_proof_submitted_indicator': ['t0'],
    'aug_risk_person_insured__declared_claim_history_detail': ['t0'],
    'aug_risk_person_insured__declared_prior_claim_amount': ['t0'],
    'aug_risk_person_insured__family_medical_history_detail': ['t0'],
    'aug_risk_person_insured__family_medical_history_indicator': ['t0'],
    'aug_risk_person_insured__member_loading_applied_indicator': ['t0'],
    'aug_risk_person_insured__other_health_declaration_detail': ['t0'],
    'aug_risk_person_insured__previous_sum_insured': ['t0'],
    'aug_risk_person_insured__health_card_status': ['t1'],
    'aug_risk_person_insured__member_special_condition': ['t2']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='risk_object_bk',
    target_sat='sat_aug_risk_person_insured'
) }}
