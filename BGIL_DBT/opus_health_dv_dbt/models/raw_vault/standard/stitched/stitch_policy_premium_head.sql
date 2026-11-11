{{ config(materialized='view') }}
-- This part feeds SAT_POLICY_PREMIUM_HEAD only. Original precedence comments are kept below (from stitch_v31_product).
-- CENTRAL VIEW v31_product -- the layer the governing central-view rule is about.
-- Tables merged, in source precedence (v2, then legacy, then delta 3):
--   BJAZ_CTNGY_COVERS_EXT (opus_health_v2)
--   BJAZ_CTNGY_SCHEME_NR_PARMS (opus_health_v2)
--   BJAZ_CTNGY_SCHEME_PLANS (opus_health_v2)
--   BA_HCP_DT_MEM (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_DTLS (opus_health_legacy_v4)
--   BJAZ_GRP_HLT_MATERNITY_DTLS (opus_health_legacy_v4)
--   BJAZ_HCF_MEMBER_DTLS (opus_health_legacy_v4)
--   BJAZ_HCS_PLANSI_MAPP (opus_health_legacy_v4)
--   BJAZ_HEALTH_WEBSERVICE_INFO (opus_health_legacy_v4)
--   BA_CCP_SUB_MATER_DTLS (opus_health_delta3)
-- Satellites fed WHOLE from this view (rule 2):
--   SAT_AUG_PRODUCT_CAPTURE_PARAMETER
--   SAT_AUG_PRODUCT_DISTRIBUTION_RULES
--   SAT_AUG_PRODUCT_ISSUANCE_OUTPUT_RULE
--   SAT_AUG_PRODUCT_RATING_STRUCTURE
--   SAT_AUG_RISK_OBJECT_INSURABLE_INTEREST
--   SAT_FINTXN_COMMISSION
--   SAT_FINTXN_HEADER
--   SAT_FINTXN_PREMIUM
--   SAT_FINTXN_RECON_INSTRUMENT
--   SAT_FIN_RECEIPT
--   SAT_POLICY_CLAUSE_ATTACHED
--   SAT_POLICY_PREMIUM_HEAD
--   SAT_POLICY_RENEWAL
--   SAT_PRODUCT_DISTRIBUTION_RULES
--   SAT_PRODUCT_HEALTH_MEMBERSHIP_RULES
--   SAT_PRODUCT_TERMS
--   SAT_PRODUCT_VERSION
--   SAT_PROPOSAL_UNDERWRITING
--   SAT_QUOTE_RATING
--   SAT_RISK_OBJECT_INSURABLE_INTEREST
-- Links whose legs come from one source row on this view (rule 6):
--   LNK_AGREEMENT_CHANNEL
--   LNK_AGREEMENT_PRODUCT
--   LNK_CHANNEL_ORG_UNIT
--   LNK_FINTXN_ACCOUNT
--   LNK_FINTXN_POLICY
--   LNK_POLICY_CHANNEL
--   LNK_POLICY_COVERAGE
--   LNK_POLICY_ORG_UNIT
--   LNK_POLICY_PARTY
--   LNK_POLICY_PRODUCT
--   LNK_POLICY_RISK_OBJECT
-- No hash is computed here. Hashing happens once, in automate_dv.stage() downstream.
-- depends_on: {{ ref('stg_health__ba_hcp_dt_mem') }}
-- depends_on: {{ ref('stg_health__bjaz_grp_hlt_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_grp_hlt_maternity_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_hcf_member_dtls') }}
-- depends_on: {{ ref('stg_health__bjaz_health_webservice_info') }}
-- depends_on: {{ ref('stg_health__ba_ccp_sub_mater_dtls') }}

{%- set sources = [
    {
      'model': 'stg_health__ba_hcp_dt_mem',
      'alias': 't0',
      'key_column': "contract_id || '|' || 'BASE_COVER' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_HCP_DT_MEM',
      'columns': [
        {'src': 'contract_id', 'tgt': 'policy_bk'},
        {'src': "'BASE_COVER'", 'tgt': 'policy_premium_head__premium_head_code_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_premium_head__coverage_reference_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_premium_head__section_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_premium_head__adjusted_indicator_ck'},
        {'src': 'prem_base_cover', 'tgt': 'policy_premium_head__base_amount'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_dtls',
      'alias': 't1',
      'key_column': "reg_no || '|' || 'PER_PERSON' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_DTLS',
      'columns': [
        {'src': 'reg_no', 'tgt': 'policy_bk'},
        {'src': "'PER_PERSON'", 'tgt': 'policy_premium_head__premium_head_code_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_premium_head__coverage_reference_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_premium_head__section_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_premium_head__adjusted_indicator_ck'},
        {'src': 'per_person_prem_type', 'tgt': 'policy_premium_head__premium_basis'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_maternity_dtls',
      'alias': 't2',
      'key_column': "reg_no || '|' || 'CORPORATE_BUFFER' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_MATERNITY_DTLS',
      'columns': [
        {'src': 'reg_no', 'tgt': 'policy_bk'},
        {'src': "'CORPORATE_BUFFER'", 'tgt': 'policy_premium_head__premium_head_code_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_premium_head__coverage_reference_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_premium_head__section_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_premium_head__adjusted_indicator_ck'},
        {'src': 'permium_co_buffer', 'tgt': 'policy_premium_head__net_head_premium'}
      ]
    },
    {
      'model': 'stg_health__bjaz_grp_hlt_maternity_dtls',
      'alias': 't3',
      'key_column': "reg_no || '|' || 'PRIME_RIDER_BASE' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_GRP_HLT_MATERNITY_DTLS',
      'columns': [
        {'src': 'reg_no', 'tgt': 'policy_bk'},
        {'src': "'PRIME_RIDER_BASE'", 'tgt': 'policy_premium_head__premium_head_code_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_premium_head__coverage_reference_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_premium_head__section_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_premium_head__adjusted_indicator_ck'},
        {'src': 'prime_rider_base_prem', 'tgt': 'policy_premium_head__base_amount'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hcf_member_dtls',
      'alias': 't4',
      'key_column': "contract_id || '|' || 'ADDON' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HCF_MEMBER_DTLS',
      'columns': [
        {'src': 'contract_id', 'tgt': 'policy_bk'},
        {'src': "'ADDON'", 'tgt': 'policy_premium_head__premium_head_code_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_premium_head__coverage_reference_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_premium_head__section_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_premium_head__adjusted_indicator_ck'},
        {'src': 'adon_premium', 'tgt': 'policy_premium_head__net_head_premium'}
      ]
    },
    {
      'model': 'stg_health__bjaz_hcf_member_dtls',
      'alias': 't5',
      'key_column': "contract_id || '|' || 'FLOATER' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HCF_MEMBER_DTLS',
      'columns': [
        {'src': 'contract_id', 'tgt': 'policy_bk'},
        {'src': "'FLOATER'", 'tgt': 'policy_premium_head__premium_head_code_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_premium_head__coverage_reference_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_premium_head__section_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_premium_head__adjusted_indicator_ck'},
        {'src': 'float_premium', 'tgt': 'policy_premium_head__net_head_premium'}
      ]
    },
    {
      'model': 'stg_health__bjaz_health_webservice_info',
      'alias': 't6',
      'key_column': "policy_ref || '|' || 'SURGICAL_COVER_BASE' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BJAZ_HEALTH_WEBSERVICE_INFO',
      'columns': [
        {'src': 'policy_ref', 'tgt': 'policy_bk'},
        {'src': "'SURGICAL_COVER_BASE'", 'tgt': 'policy_premium_head__premium_head_code_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_premium_head__coverage_reference_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_premium_head__section_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_premium_head__adjusted_indicator_ck'},
        {'src': 'surg_cover_base_prem', 'tgt': 'policy_premium_head__base_amount'}
      ]
    },
    {
      'model': 'stg_health__ba_ccp_sub_mater_dtls',
      'alias': 't7',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || 'CI' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_CCP_SUB_MATER_DTLS',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': "'CI'", 'tgt': 'policy_premium_head__premium_head_code_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_premium_head__coverage_reference_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_premium_head__section_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_premium_head__adjusted_indicator_ck'},
        {'src': 'ci_prem', 'tgt': 'policy_premium_head__net_head_premium'}
      ]
    },
    {
      'model': 'stg_health__ba_ccp_sub_mater_dtls',
      'alias': 't8',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || 'ACC' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_CCP_SUB_MATER_DTLS',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': "'ACC'", 'tgt': 'policy_premium_head__premium_head_code_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_premium_head__coverage_reference_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_premium_head__section_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_premium_head__adjusted_indicator_ck'},
        {'src': 'acc_prem', 'tgt': 'policy_premium_head__net_head_premium'}
      ]
    },
    {
      'model': 'stg_health__ba_ccp_sub_mater_dtls',
      'alias': 't9',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || 'EMI' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_CCP_SUB_MATER_DTLS',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': "'EMI'", 'tgt': 'policy_premium_head__premium_head_code_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_premium_head__coverage_reference_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_premium_head__section_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_premium_head__adjusted_indicator_ck'},
        {'src': 'emi_prem', 'tgt': 'policy_premium_head__net_head_premium'}
      ]
    },
    {
      'model': 'stg_health__ba_ccp_sub_mater_dtls',
      'alias': 't10',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || 'SECTION_TOTAL | Section = SEC1' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_CCP_SUB_MATER_DTLS',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': "'SECTION_TOTAL | Section = SEC1'", 'tgt': 'policy_premium_head__premium_head_code_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_premium_head__coverage_reference_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_premium_head__section_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_premium_head__adjusted_indicator_ck'},
        {'src': 'sec1_prem', 'tgt': 'policy_premium_head__net_head_premium'}
      ]
    },
    {
      'model': 'stg_health__ba_ccp_sub_mater_dtls',
      'alias': 't11',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || 'FIREBUILD | Section = SEC2' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_CCP_SUB_MATER_DTLS',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': "'FIREBUILD | Section = SEC2'", 'tgt': 'policy_premium_head__premium_head_code_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_premium_head__coverage_reference_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_premium_head__section_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_premium_head__adjusted_indicator_ck'},
        {'src': 'sec2_firebuild_prem', 'tgt': 'policy_premium_head__net_head_premium'}
      ]
    },
    {
      'model': 'stg_health__ba_ccp_sub_mater_dtls',
      'alias': 't12',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || 'FIRECONTENT | Section = SEC2' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_CCP_SUB_MATER_DTLS',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': "'FIRECONTENT | Section = SEC2'", 'tgt': 'policy_premium_head__premium_head_code_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_premium_head__coverage_reference_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_premium_head__section_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_premium_head__adjusted_indicator_ck'},
        {'src': 'sec2_firecontent_prem', 'tgt': 'policy_premium_head__net_head_premium'}
      ]
    },
    {
      'model': 'stg_health__ba_ccp_sub_mater_dtls',
      'alias': 't13',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || 'BURGCONTENT | Section = SEC2' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_CCP_SUB_MATER_DTLS',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': "'BURGCONTENT | Section = SEC2'", 'tgt': 'policy_premium_head__premium_head_code_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_premium_head__coverage_reference_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_premium_head__section_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_premium_head__adjusted_indicator_ck'},
        {'src': 'sec2_burgcontent_prem', 'tgt': 'policy_premium_head__net_head_premium'}
      ]
    },
    {
      'model': 'stg_health__ba_ccp_sub_mater_dtls',
      'alias': 't14',
      'key_column': "trim(to_varchar(nullif(trim(contract_id),''))) || '|' || 'BURGJWEL | Section = SEC2' || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~') || '|' || coalesce(trim(to_varchar(cast(null as varchar))), '~')",
      'ldts_column': 'inc_job_updated_at',
      'source_tag': 'OPUS_BA_CCP_SUB_MATER_DTLS',
      'columns': [
        {'src': "nullif(trim(contract_id),'')", 'tgt': 'policy_bk'},
        {'src': "'BURGJWEL | Section = SEC2'", 'tgt': 'policy_premium_head__premium_head_code_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_premium_head__coverage_reference_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_premium_head__section_ck'},
        {'src': 'cast(null as varchar)', 'tgt': 'policy_premium_head__adjusted_indicator_ck'},
        {'src': 'sec2_burgjwel_prem', 'tgt': 'policy_premium_head__net_head_premium'}
      ]
    }
] -%}
{%- set output_columns = [
    'policy_bk',
    'policy_premium_head__premium_head_code_ck',
    'policy_premium_head__coverage_reference_ck',
    'policy_premium_head__section_ck',
    'policy_premium_head__adjusted_indicator_ck',
    'policy_premium_head__base_amount',
    'policy_premium_head__premium_basis',
    'policy_premium_head__net_head_premium'
] -%}
{%- set coalesce_rules = {
    'policy_bk': ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't12', 't13', 't14'],
    'policy_premium_head__premium_head_code_ck': ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't12', 't13', 't14'],
    'policy_premium_head__coverage_reference_ck': ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't12', 't13', 't14'],
    'policy_premium_head__section_ck': ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't12', 't13', 't14'],
    'policy_premium_head__adjusted_indicator_ck': ['t0', 't1', 't2', 't3', 't4', 't5', 't6', 't7', 't8', 't9', 't10', 't11', 't12', 't13', 't14'],
    'policy_premium_head__base_amount': ['t0', 't3', 't6'],
    'policy_premium_head__premium_basis': ['t1'],
    'policy_premium_head__net_head_premium': ['t2', 't4', 't5', 't7', 't8', 't9', 't10', 't11', 't12', 't13', 't14']
} %}

{{ stitch_incremental(
    sources=sources,
    output_columns=output_columns,
    coalesce_rules=coalesce_rules,
    unique_key='policy_premium_head_pk',
    target_sat='sat_policy_premium_head'
) }}
