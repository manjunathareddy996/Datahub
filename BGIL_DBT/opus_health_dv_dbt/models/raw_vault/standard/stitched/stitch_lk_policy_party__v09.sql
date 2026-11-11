{{ config(materialized='view') }}
-- This part feeds LNK_POLICY_PARTY only. Original precedence comments are kept below (from stitch_v09_claim).
-- CENTRAL VIEW v09_claim -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_HM_USER_TAT (opus_health_v2)
--   BGIL_GMC_FINAL_INSTL_DATA (opus_health_legacy_v4)
--   BJAZ_ECARD_MEMBR_DEL_DTLS (opus_health_legacy_v4)
--   BJAZ_HAT_ID_MEM_DETLS (opus_health_legacy_v4)
--   BJAZ_HC_PART_EXTN (opus_health_legacy_v4)
--   BJAZ_HM_COINSU_CLM_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_HCM_EXTRACT (opus_health_legacy_v4)
--   BJAZ_HM_MEMBER_DTLS (opus_health_legacy_v4)
--   BJAZ_REMEDINET_CLAIM_DETAILS (opus_health_legacy_v4)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_CLAIM_CO_RI_SHARE
--   SAT_AUG_CLAIM_PROCESS_STEP_LOG
--   SAT_AUG_PARTY_CLAIM_HISTORY
--   SAT_AUG_PARTY_INDIVIDUAL_DEMOGRAPHICS
--   SAT_AUG_POLICY_CERTIFICATE
--   SAT_CLAIM_CO_RI_SHARE
--   SAT_CLAIM_RESERVE
--   SAT_DOCUMENT_CHECKLIST
--   SAT_INSTRUMENT_DEFINITION
--   SAT_LOCATION_PROFILE
--   SAT_PARTY_GROUP_CENSUS
--   SAT_PARTY_GROUP_SCHEME
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_AGREEMENT_DOCUMENT
--   LNK_AGREEMENT_PARTY
--   LNK_CLAIM_DOCUMENT
--   LNK_CLAIM_LOCATION
--   LNK_CLAIM_LOSS_EVENT
--   LNK_CLAIM_PARTY
--   LNK_CLAIM_PAYMENT_INSTRUMENT
--   LNK_CLAIM_POLICY
--   LNK_FINTXN_ACCOUNT
--   LNK_FINTXN_CLAIM
--   LNK_FINTXN_INSTRUMENT
--   LNK_FINTXN_PARTY
--   LNK_FINTXN_POLICY
--   LNK_LOSS_EVENT_LOCATION
--   LNK_PARTY_CHANNEL
--   LNK_PARTY_DOCUMENT
--   LNK_PARTY_LOCATION
--   LNK_PARTY_PAYMENT_INSTRUMENT
--   LNK_POLICY_CHANNEL
--   LNK_POLICY_DOCUMENT
--   LNK_POLICY_LOCATION
--   LNK_POLICY_PARTY
--   LNK_POLICY_PAYMENT_INSTRUMENT
--   LNK_POLICY_PRODUCT
--   LNK_QUOTE_PARTY
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bgil_gmc_final_instl_data') }}
-- depends_on: {{ ref('stg_health__bjaz_hat_id_mem_detls') }}
-- depends_on: {{ ref('stg_health__bjaz_hc_part_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_coinsu_clm_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hm_hcm_extract') }}
-- depends_on: {{ ref('stg_health__bjaz_remedinet_claim_details') }}

{%- set sources = [
    {
      'model': 'stg_health__bgil_gmc_final_instl_data',
      'alias': 't0',
      'key_column': "emp_code || '|' || policy_no",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BGIL_GMC_FINAL_INSTL_DATA',
      'columns': [
        {'src': 'emp_code', 'tgt': 'party_bk'},
        {'src': 'policy_no', 'tgt': 'policy_bk'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hat_id_mem_detls',
      'alias': 't1',
      'key_column': "member_no || '|' || contract_id",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HAT_ID_MEM_DETLS',
      'columns': [
        {'src': 'member_no', 'tgt': 'party_bk'},
        {'src': 'contract_id', 'tgt': 'policy_bk'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hc_part_extn',
      'alias': 't2',
      'key_column': "part_id || '|' || contract_id",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HC_PART_EXTN',
      'columns': [
        {'src': 'part_id', 'tgt': 'party_bk'},
        {'src': 'contract_id', 'tgt': 'policy_bk'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_coinsu_clm_dtls',
      'alias': 't3',
      'key_column': "ldr_pid || '|' || policy_ref",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_COINSU_CLM_DTLS',
      'columns': [
        {'src': 'ldr_pid', 'tgt': 'party_bk'},
        {'src': 'policy_ref', 'tgt': 'policy_bk'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hm_hcm_extract',
      'alias': 't4',
      'key_column': "hospital_id || '|' || policy",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HM_HCM_EXTRACT',
      'columns': [
        {'src': 'hospital_id', 'tgt': 'party_bk'},
        {'src': 'policy', 'tgt': 'policy_bk'}
      ]
    },
    {
      'model': 'stg_health__bjaz_remedinet_claim_details',
      'alias': 't5',
      'key_column': "payer_code || '|' || policy_no",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_REMEDINET_CLAIM_DETAILS',
      'columns': [
        {'src': 'payer_code', 'tgt': 'party_bk'},
        {'src': 'policy_no', 'tgt': 'policy_bk'}
      ]
    }
] -%}
{%- set output_columns = [
    'party_bk',
    'policy_bk'
] -%}
{%- set coalesce_rules = {
    'party_bk': ['t0', 't1', 't2', 't3', 't4', 't5'],
    'policy_bk': ['t0', 't1', 't2', 't3', 't4', 't5']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='policy_party_lk',
    target_sat='lnk_policy_party'
) }}
