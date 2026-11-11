{{ config(materialized='view') }}
-- This part feeds SAT_LNK_PARTY_ROLE_CORE only. Original precedence comments are kept below (from stitch_v16_party).
-- CENTRAL VIEW v16_party -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_HM_PREAUTH_REQUEST (opus_health_v2)
--   BJAZ_INTERMEDIARY (opus_health_v2)
--   BJAZ_NEFT_PARTNER_DTLS (opus_health_v2)
--   BJAZ_PMSBY_DATA_WEB_SERVICE (opus_health_v2)
--   BA_HCP_PROD_8428_GPG_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8432_ECP_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8433_FHC_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8439_CLH_LOADER (opus_health_legacy_v4)
--   BJAZ_BANDHAN_MEDI_CLAM (opus_health_legacy_v4)
--   BJAZ_EC_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_GPG_POL_DTLS (opus_health_legacy_v4)
--   BJAZ_HG_POL_DTLS (opus_health_legacy_v4)
--   BJAZ_HLT_ENSURE_MEM_DTLS (opus_health_legacy_v4)
--   BJAZ_HM_HCM_EXTRACT (opus_health_legacy_v4)
--   BJAZ_HM_HOSPITAL_MASTER (opus_health_legacy_v4)
--   BJAZ_HM_HOSPITAL_MASTER_EXTN (opus_health_legacy_v4)
--   BJAZ_HM_INWARD_DTLS (opus_health_legacy_v4)
--   BJAZ_IHG_MEM_DTLS_EXTN (opus_health_legacy_v4)
--   BJAZ_REMEDINET_CLAIM_DETAILS (opus_health_legacy_v4)
--   BJAZ_TPA_CLAIM_DETAILS_WS (opus_health_legacy_v4)
--   BJAZ_POLICY_SUMMARY (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_PARTY_CONSENT_MANDATE
--   SAT_AUG_PARTY_IDENTIFICATION
--   SAT_AUG_PARTY_PAYOUT_PROFILE
--   SAT_COMMON_CLASSIFICATION
--   SAT_LNK_PARTY_ROLE_CORE
--   SAT_LNK_ROLE_AGENT
--   SAT_PARTY_CONSENT_MANDATE
--   SAT_PARTY_HIERARCHY
--   SAT_PARTY_IDENTIFICATION
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_PARTY_CHANNEL
-- OVER the table limit by rule 3: one satellite on this view needs every table above.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_neft_partner_dtls') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8428_gpg_loader') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8432_ecp_loader') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8433_fhc_loader') }}
-- depends_on: {{ ref('stg_health__ba_hcp_prod_8439_clh_loader') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_neft_partner_dtls',
      'alias': 't0',
      'key_column': "trim(to_varchar(nullif('PARTID:' || nullif(trim(part_id),''), 'PARTID:'))) || '|' || coalesce(supplier_type, '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_NEFT_PARTNER_DTLS',
      'columns': [
        {'src': "nullif('PARTID:' || nullif(trim(part_id),''), 'PARTID:')", 'tgt': 'party_bk'},
        {'src': 'supplier_type', 'tgt': 'lnk_party_role_core__role_code_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'lnk_party_role_core__role_sequence_ck'},
        {'src': 'supplier_type', 'tgt': 'lnk_party_role_core__role_type'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8428_gpg_loader',
      'alias': 't1',
      'key_column': "pd_premium_payer_id || '|' || 'PROPOSER' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8428_GPG_LOADER',
      'columns': [
        {'src': 'pd_premium_payer_id', 'tgt': 'party_bk'},
        {'src': "'PROPOSER'", 'tgt': 'lnk_party_role_core__role_code_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'lnk_party_role_core__role_sequence_ck'},
        {'src': 'md_is_proposer_yes_no', 'tgt': 'lnk_party_role_core__role_type'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8432_ecp_loader',
      'alias': 't2',
      'key_column': "pd_premium_payer_id || '|' || 'PROPOSER' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8432_ECP_LOADER',
      'columns': [
        {'src': 'pd_premium_payer_id', 'tgt': 'party_bk'},
        {'src': "'PROPOSER'", 'tgt': 'lnk_party_role_core__role_code_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'lnk_party_role_core__role_sequence_ck'},
        {'src': 'md_is_proposer_yes_no', 'tgt': 'lnk_party_role_core__role_type'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8433_fhc_loader',
      'alias': 't3',
      'key_column': "pd_premium_payer_id || '|' || 'PROPOSER' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8433_FHC_LOADER',
      'columns': [
        {'src': 'pd_premium_payer_id', 'tgt': 'party_bk'},
        {'src': "'PROPOSER'", 'tgt': 'lnk_party_role_core__role_code_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'lnk_party_role_core__role_sequence_ck'},
        {'src': 'md_is_proposer_yes_no', 'tgt': 'lnk_party_role_core__role_type'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8439_clh_loader',
      'alias': 't4',
      'key_column': "pd_premium_payer_id || '|' || 'PROPOSER' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8439_CLH_LOADER',
      'columns': [
        {'src': 'pd_premium_payer_id', 'tgt': 'party_bk'},
        {'src': "'PROPOSER'", 'tgt': 'lnk_party_role_core__role_code_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'lnk_party_role_core__role_sequence_ck'},
        {'src': 'md_is_proposer_yes_no', 'tgt': 'lnk_party_role_core__role_type'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8439_clh_loader',
      'alias': 't5',
      'key_column': "pd_premium_payer_id || '|' || 'BORROWER' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8439_CLH_LOADER',
      'columns': [
        {'src': 'pd_premium_payer_id', 'tgt': 'party_bk'},
        {'src': "'BORROWER'", 'tgt': 'lnk_party_role_core__role_code_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'lnk_party_role_core__role_sequence_ck'},
        {'src': 'plc_borrower_type', 'tgt': 'lnk_party_role_core__role_category'}
      ]
    },
    {
      'model': 'stg_health__ba_hcp_prod_8439_clh_loader',
      'alias': 't6',
      'key_column': "pd_premium_payer_id || '|' || 'ASSIGNOR' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_PROD_8439_CLH_LOADER',
      'columns': [
        {'src': 'pd_premium_payer_id', 'tgt': 'party_bk'},
        {'src': "'ASSIGNOR'", 'tgt': 'lnk_party_role_core__role_code_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'lnk_party_role_core__role_sequence_ck'},
        {'src': 'plc_type_of_assignor_dclr', 'tgt': 'lnk_party_role_core__role_type'}
      ]
    }
] -%}
{%- set output_columns = [
    'party_bk',
    'lnk_party_role_core__role_code_ck',
    'lnk_party_role_core__role_sequence_ck',
    'lnk_party_role_core__role_type',
    'lnk_party_role_core__role_category'
] -%}
{%- set coalesce_rules = {
    'party_bk': ['t0', 't1', 't2', 't3', 't4', 't5', 't6'],
    'lnk_party_role_core__role_code_ck': ['t0', 't1', 't2', 't3', 't4', 't5', 't6'],
    'lnk_party_role_core__role_sequence_ck': ['t0', 't1', 't2', 't3', 't4', 't5', 't6'],
    'lnk_party_role_core__role_type': ['t0', 't1', 't2', 't3', 't4', 't6'],
    'lnk_party_role_core__role_category': ['t5']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='lnk_party_role_core_pk',
    target_sat='sat_lnk_party_role_core'
) }}
