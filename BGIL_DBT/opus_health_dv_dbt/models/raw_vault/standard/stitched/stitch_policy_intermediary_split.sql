{{ config(materialized='view') }}
-- This part feeds SAT_POLICY_INTERMEDIARY_SPLIT only. Original precedence comments are kept below (from stitch_v27_policy).
-- CENTRAL VIEW v27_policy -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_ENROLL_SCR_DTLS (opus_health_v2)
--   BJAZ_PMSBY_DATA_WEB_SERVICE (opus_health_v2)
--   BA_HCP_DT_PREMIUM (opus_health_legacy_v4)
--   BA_HCP_POL_MST (opus_health_legacy_v4)
--   BA_HCP_PRIME_RIDER_DTLS (opus_health_legacy_v4)
--   BA_HCP_PROD_8428_GPG_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8432_ECP_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8433_FHC_LOADER (opus_health_legacy_v4)
--   BA_HCP_PROD_8439_CLH_LOADER (opus_health_legacy_v4)
--   BGIL_GMC_FINAL_INSTL_DATA (opus_health_legacy_v4)
--   BJAZ_BANDHAN_MEDI_CLAM (opus_health_legacy_v4)
--   BJAZ_EHH_POL_DTLS (opus_health_legacy_v4)
--   BJAZ_GENERIC_LOADER_LOG_TABLE (opus_health_legacy_v4)
--   BJAZ_GPG_POL_DTLS (opus_health_legacy_v4)
--   BJAZ_GP_HOSPITAL_CASH (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_DTLS (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_MATERNITY_DTLS (opus_health_legacy_v4)
--   BJAZ_HDFC_SEC_FHPP (opus_health_legacy_v4)
--   BJAZ_HEALTH_WEBSERVICE_INFO (opus_health_legacy_v4)
--   BJAZ_HG_POL_DTLS (opus_health_legacy_v4)
--   BA_CCP_SUB_MATER_DTLS (opus_health_delta3)
--   BJAZ_POLICY_BASES_EXTN (opus_health_delta3)
--   BJAZ_POLICY_SUMMARY (opus_health_delta3)
--   BJAZ_STARPKG_POL_DTLS (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_POLICY_DISCOUNT_LOADING_APPLIED
--   SAT_AUG_POLICY_PREMIUM_SUMMARY
--   SAT_PARTY_GROUP_HOUSEHOLD
--   SAT_POLICY_DISCOUNT_LOADING_APPLIED
--   SAT_POLICY_INTERMEDIARY_SPLIT
--   SAT_POLICY_PREMIUM_SUMMARY
--   SAT_POLICY_TAX_BREAKUP
--   SAT_POLICY_TAX_HEAD
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_PARTY_CHANNEL
--   LNK_PARTY_LOCATION
--   LNK_POLICY_CHANNEL
--   LNK_POLICY_LOCATION
--   LNK_POLICY_PARTY
--   LNK_POLICY_PRODUCT
-- OVER the table limit by rule 3: one satellite on this view needs every table above.
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__bjaz_enroll_scr_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_pmsby_data_web_service') }}
-- depends_on: {{ ref('stg_health__bjaz_generic_loader_log_table') }}
-- depends_on: {{ ref('stg_health__bjaz_policy_bases_extn') }}
-- depends_on: {{ ref('stg_health__bjaz_policy_summary') }}

{%- set sources = [
    {
      'model': 'stg_health__bjaz_enroll_scr_dtls',
      'alias': 't0',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_ENROLL_SCR_DTLS',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_intermediary_split__intermediary_reference_ck'},
        {'src': 'commision', 'tgt': 'policy_intermediary_split__commission_rate'}
      ]
    },
    {
      'model': 'stg_health__bjaz_pmsby_data_web_service',
      'alias': 't1',
      'key_column': "trim(to_varchar(nullif(trim(policy_ref),''))) || '|' || coalesce(imd_code, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_PMSBY_DATA_WEB_SERVICE',
      'columns': [
        {'src': "nullif(trim(policy_ref),'')", 'tgt': 'policy_bk'},
        {'src': 'imd_code', 'tgt': 'policy_intermediary_split__intermediary_reference_ck'},
        {'src': 'imd_code', 'tgt': 'policy_intermediary_split__imd_code'}
      ]
    },
    {
      'model': 'stg_health__bjaz_generic_loader_log_table',
      'alias': 't2',
      'key_column': "pmasterpolicynumber || '|' || coalesce(intermediary, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GENERIC_LOADER_LOG_TABLE',
      'columns': [
        {'src': 'pmasterpolicynumber', 'tgt': 'policy_bk'},
        {'src': 'intermediary', 'tgt': 'policy_intermediary_split__intermediary_reference_ck'},
        {'src': 'intermediary', 'tgt': 'policy_intermediary_split__intermediary_reference'}
      ]
    },
    {
      'model': 'stg_health__bjaz_policy_bases_extn',
      'alias': 't3',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || coalesce(sub_agent_code, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_POLICY_BASES_EXTN',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': 'sub_agent_code', 'tgt': 'policy_intermediary_split__intermediary_reference_ck'},
        {'src': 'sub_agent_comm_amt', 'tgt': 'policy_intermediary_split__commission_amount'},
        {'src': 'sub_agent_comm_rate', 'tgt': 'policy_intermediary_split__commission_rate'},
        {'src': 'sub_agent_code', 'tgt': 'policy_intermediary_split__sub_imd_code'}
      ]
    },
    {
      'model': 'stg_health__bjaz_policy_bases_extn',
      'alias': 't4',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || coalesce(main_agent_code, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_POLICY_BASES_EXTN',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': 'main_agent_code', 'tgt': 'policy_intermediary_split__intermediary_reference_ck'},
        {'src': 'main_agent_comm_amt', 'tgt': 'policy_intermediary_split__commission_amount'},
        {'src': 'main_agent_comm_rate', 'tgt': 'policy_intermediary_split__commission_rate'},
        {'src': 'main_agent_code', 'tgt': 'policy_intermediary_split__imd_code'}
      ]
    },
    {
      'model': 'stg_health__bjaz_policy_summary',
      'alias': 't5',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || coalesce(sub_agent_code, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_POLICY_SUMMARY',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': 'sub_agent_code', 'tgt': 'policy_intermediary_split__intermediary_reference_ck'},
        {'src': 'sub_agent_comm_amt', 'tgt': 'policy_intermediary_split__commission_amount'},
        {'src': 'sub_agent_comm_rate', 'tgt': 'policy_intermediary_split__commission_rate'},
        {'src': 'sub_agent_code', 'tgt': 'policy_intermediary_split__sub_imd_code'}
      ]
    },
    {
      'model': 'stg_health__bjaz_policy_summary',
      'alias': 't6',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || coalesce(intermediary_code, '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_POLICY_SUMMARY',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': 'intermediary_code', 'tgt': 'policy_intermediary_split__intermediary_reference_ck'},
        {'src': 'main_agent_comm_amt', 'tgt': 'policy_intermediary_split__commission_amount'},
        {'src': 'main_agent_comm_rate', 'tgt': 'policy_intermediary_split__commission_rate'},
        {'src': 'intermediary_code', 'tgt': 'policy_intermediary_split__imd_code'}
      ]
    }
] -%}
{%- set output_columns = [
    'policy_bk',
    'policy_intermediary_split__intermediary_reference_ck',
    'policy_intermediary_split__commission_rate',
    'policy_intermediary_split__imd_code',
    'policy_intermediary_split__intermediary_reference',
    'policy_intermediary_split__commission_amount',
    'policy_intermediary_split__sub_imd_code'
] -%}
{%- set coalesce_rules = {
    'policy_bk': ['t0', 't1', 't2', 't3', 't4', 't5', 't6'],
    'policy_intermediary_split__intermediary_reference_ck': ['t0', 't1', 't2', 't3', 't4', 't5', 't6'],
    'policy_intermediary_split__commission_rate': ['t0', 't3', 't4', 't5', 't6'],
    'policy_intermediary_split__imd_code': ['t1', 't4', 't6'],
    'policy_intermediary_split__intermediary_reference': ['t2'],
    'policy_intermediary_split__commission_amount': ['t3', 't4', 't5', 't6'],
    'policy_intermediary_split__sub_imd_code': ['t3', 't5']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='policy_intermediary_split_pk',
    target_sat='sat_policy_intermediary_split'
) }}
