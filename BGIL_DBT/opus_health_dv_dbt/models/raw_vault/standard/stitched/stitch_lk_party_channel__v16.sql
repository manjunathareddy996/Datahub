{{ config(materialized='view') }}
-- This part feeds LNK_PARTY_CHANNEL only. Original precedence comments are kept below (from stitch_v16_party).
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
-- depends_on: {{ ref('stg_health__bjaz_intermediary') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_intermediary',
      'alias': 't0',
      'key_column': "trim(to_varchar(nullif(trim(business_channel),''))) || '|' || trim(to_varchar(nullif(trim(intermediary_id),'')))",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_INTERMEDIARY',
      'columns': [
        {'src': "nullif(trim(business_channel),'')", 'tgt': 'distribution_channel_bk'},
        {'src': "nullif(trim(intermediary_id),'')", 'tgt': 'party_bk'}
      ]
    }
] -%}
{%- set output_columns = [
    'distribution_channel_bk',
    'party_bk'
] -%}
{%- set coalesce_rules = {
    'distribution_channel_bk': ['t0'],
    'party_bk': ['t0']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='party_channel_lk',
    target_sat='lnk_party_channel'
) }}
