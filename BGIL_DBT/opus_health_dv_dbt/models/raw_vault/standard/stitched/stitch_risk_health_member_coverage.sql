{{ config(materialized='view') }}
-- This part feeds SAT_RISK_HEALTH_MEMBER_COVERAGE only. Original precedence comments are kept below (from stitch_v34_risk_object).
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
-- depends_on: {{ ref('stg_health__bjaz_ec_mem_dtls_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_hcf_member_dtls') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_hm_member_hlth_dtls',
      'alias': 't0',
      'key_column': "trim(to_varchar(nullif('MEMBER:' || coalesce(nullif(trim(contract_id),''),'') || '#' || coalesce(nullif(trim(member_id),''),''), 'MEMBER:#'))) || '|' || coalesce(member_id, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_MEMBER_HLTH_DTLS',
      'columns': [
        {'src': "nullif('MEMBER:' || coalesce(nullif(trim(contract_id),''),'') || '#' || coalesce(nullif(trim(member_id),''),''), 'MEMBER:#')", 'tgt': 'risk_object_bk'},
        {'src': 'member_id', 'tgt': 'risk_health_member_coverage__member_reference_ck'},
        {'src': 'medical_checkup', 'tgt': 'risk_health_member_coverage__pre_policy_checkup_indicator'}
      ]
    },
    {
      'model': 'stg_health__bjaz_ec_mem_dtls_extn',
      'alias': 't1',
      'key_column': "trim(to_varchar(nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_no)), ''))) || '|' || coalesce(member_no, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_EC_MEM_DTLS_EXTN',
      'columns': [
        {'src': "nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_no)), '')", 'tgt': 'risk_object_bk'},
        {'src': 'member_no', 'tgt': 'risk_health_member_coverage__member_reference_ck'},
        {'src': 'sum_insured', 'tgt': 'risk_health_member_coverage__member_sum_insured'},
        {'src': 'medical_checkup', 'tgt': 'risk_health_member_coverage__pre_policy_checkup_indicator'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hcf_member_dtls',
      'alias': 't2',
      'key_column': "trim(to_varchar(nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_no)), ''))) || '|' || coalesce(member_no, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HCF_MEMBER_DTLS',
      'columns': [
        {'src': "nullif(trim(to_varchar(contract_id)), '') || '|' || nullif(trim(to_varchar(member_no)), '')", 'tgt': 'risk_object_bk'},
        {'src': 'member_no', 'tgt': 'risk_health_member_coverage__member_reference_ck'},
        {'src': 'loading_reason', 'tgt': 'risk_health_member_coverage__loading_reason'},
        {'src': 'sum_insured', 'tgt': 'risk_health_member_coverage__member_sum_insured'}
      ]
    }
] -%}
{%- set output_columns = [
    'risk_object_bk',
    'risk_health_member_coverage__member_reference_ck',
    'risk_health_member_coverage__pre_policy_checkup_indicator',
    'risk_health_member_coverage__member_sum_insured',
    'risk_health_member_coverage__loading_reason'
] -%}
{%- set coalesce_rules = {
    'risk_object_bk': ['t0', 't1', 't2'],
    'risk_health_member_coverage__member_reference_ck': ['t0', 't1', 't2'],
    'risk_health_member_coverage__pre_policy_checkup_indicator': ['t0', 't1'],
    'risk_health_member_coverage__member_sum_insured': ['t1', 't2'],
    'risk_health_member_coverage__loading_reason': ['t2']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='risk_health_member_coverage_pk',
    target_sat='sat_risk_health_member_coverage'
) }}
